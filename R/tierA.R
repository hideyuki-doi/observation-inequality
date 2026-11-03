# Tier A：種レベルの N・体重・GBIF 記録数（種名の完全一致で照合。照合規則は docs/taxon_matching.md）

mammal_species <- function(dir = "data/raw/greenspoon2023/mammal_biomass", combine = "data/raw/combine/trait_data_reported.csv") {
  res <- readr::read_csv(file.path(dir, "results/wild_land_mammal_biomass_inluding_populations.csv"), show_col_types = FALSE)
  rep <- readr::read_csv(file.path(dir, "data/species_w_pop_reports.csv"), show_col_types = FALSE)
  cb <- readr::read_csv(combine, show_col_types = FALSE) |> dplyr::select(iucn2020_binomial, order, adult_mass_g) |>
    dplyr::filter(!is.na(adult_mass_g)) |> dplyr::distinct(iucn2020_binomial, .keep_all = TRUE)
  res |> dplyr::transmute(species = binomial, N = estimated_population, N_lo = estimated_population_2pt5,
                          N_hi = estimated_population_97pt5, B_g = biomass_g) |>
    dplyr::mutate(report_based = species %in% rep$binomial,
                  method_class = dplyr::if_else(report_based, "unclear(report)", "allometry-derived(SVR)")) |>
    dplyr::left_join(cb, by = c("species" = "iucn2020_binomial")) |> dplyr::rename(M_g = adult_mass_g)
}

bird_species <- function(zip = "data/raw/callaghan2021/zenodo_4723365/Tables.zip", avonet = "data/raw/avonet/AVONET_Supplementary_dataset_1.xlsx") {
  x <- readr::read_csv(unz(zip, "Tables/all_species_summary_table.csv"), show_col_types = FALSE)
  av <- readxl::read_excel(avonet, sheet = "AVONET2_eBird") |> dplyr::select(Species2, Mass) |> dplyr::distinct(Species2, .keep_all = TRUE)
  x |> dplyr::transmute(species = `Scientific name`, N = `Abundance estimate`, N_lo = `95% Lower CI`, N_hi = `95% Upper CI`,
                        training = `Training species`, method_class = "occurrence-derived") |>
    dplyr::left_join(av, by = c("species" = "Species2")) |> dplyr::rename(M_g = Mass)
}

# GBIF 種別・年別・記録種類別の件数（class で絞って種名で照合）
gbif_species_year <- function(taxon_file, cls) {
  arrow::open_dataset(taxon_file) |> dplyr::filter(class == cls, !is.na(species)) |>
    dplyr::group_by(species, year, basisofrecord, ds_class) |>
    dplyr::summarise(n = sum(n), n_ic = sum(n_ic), sum_ic = sum(sum_ic), .groups = "drop") |> dplyr::collect() |>
    dplyr::mutate(rtype = record_type(basisofrecord, ds_class))
}

match_summary <- function(sp, gy, label) {
  g <- gy |> dplyr::group_by(species) |> dplyr::summarise(R_all = sum(n), .groups = "drop")
  tibble::tibble(set = label, n_census = nrow(sp), n_exact = sum(sp$name_route == "exact"),
                 n_synonym = sum(sp$name_route == "synonym"), n_unmatched = sum(sp$name_route == "unmatched"),
                 n_dup_target = sum(sp$dup_target),
                 n_with_mass = sum(!is.na(sp$M_g)),
                 share_gbif_records_matched = sum(g$R_all[g$species %in% sp$gbif_name]) / sum(g$R_all),
                 unmatched_examples = paste(head(sp$species[sp$name_route == "unmatched"], 15), collapse = "; "))
}

# 照合できない種名を COL XR（GBIF v2 species match）で受理名に解決する。結果はキャッシュ（取得日つき）
colxr_key <- "7ddf754f-d193-4cc9-b351-99906754a03b"
resolve_names <- function(names, cache = "data/raw/gbif_api/name_match_cache.csv") {
  old <- if (file.exists(cache)) readr::read_csv(cache, col_types = "ccccci") else NULL
  todo <- setdiff(unique(names), old$query)
  new <- purrr::map(todo, function(nm) {
    js <- tryCatch(jsonlite::fromJSON(paste0("https://api.gbif.org/v2/species/match?checklistKey=", colxr_key,
                                             "&scientificName=", utils::URLencode(nm, reserved = TRUE))), error = function(e) NULL)
    acc <- if (!is.null(js$acceptedUsage)) js$acceptedUsage else js$usage
    tibble::tibble(query = nm, status = js$usage$status %||% NA_character_, accepted = acc$canonicalName %||% NA_character_,
                   rank = acc$rank %||% NA_character_, match_type = js$diagnostics$matchType %||% NA_character_,
                   confidence = as.integer(js$diagnostics$confidence %||% NA))
  }) |> purrr::list_rbind()
  out <- dplyr::bind_rows(old, new)
  if (nrow(new)) readr::write_csv(out, cache)
  out |> dplyr::filter(query %in% names)
}

# 照合列 gbif_name を付ける：完全一致 → 受理名（EXACT 一致・種ランクのみ）。同じ受理名に複数種が落ちたら dup_target
add_gbif_name <- function(sp, gy) {
  have <- unique(gy$species)
  miss <- setdiff(sp$species, have)
  # 受理名が亜種なら種の部分（先頭2語）を使う（例：Tetrao tetrix → Lyrurus tetrix tetrix → Lyrurus tetrix）
  rs <- resolve_names(miss) |> dplyr::filter(match_type == "EXACT", rank %in% c("SPECIES", "SUBSPECIES")) |>
    dplyr::mutate(accepted = stringr::word(accepted, 1, 2))
  sp |> dplyr::left_join(dplyr::select(rs, query, accepted), by = c("species" = "query")) |>
    dplyr::mutate(gbif_name = dplyr::case_when(species %in% have ~ species, accepted %in% have ~ accepted, TRUE ~ NA_character_),
                  name_route = dplyr::case_when(species %in% have ~ "exact", !is.na(gbif_name) ~ "synonym", TRUE ~ "unmatched")) |>
    dplyr::add_count(gbif_name, name = "n_same_target") |>
    dplyr::mutate(dup_target = !is.na(gbif_name) & n_same_target > 1) |> dplyr::select(-accepted, -n_same_target)
}
