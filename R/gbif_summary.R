# Phase 2: 部分集計の統合とグループ別の集計・診断

# 記録の種類：DNA = DNA-derived data 拡張つきデータセットの記録（データセット単位の判定）。
# MATERIAL_SAMPLE はネット採集などの非 DNA 試料も多い（例：オキアミの 61 万件）ので DNA とはみなさない
record_type <- function(bor, ds_class) dplyr::case_when(
  ds_class == "dna_ext" ~ "dna",
  bor == "MATERIAL_SAMPLE" ~ "material_sample",
  bor == "HUMAN_OBSERVATION" ~ "human_obs",
  bor == "PRESERVED_SPECIMEN" ~ "specimen",
  bor == "MACHINE_OBSERVATION" ~ "machine",
  bor == "FOSSIL_SPECIMEN" ~ "fossil",
  TRUE ~ "other")

combine_taxon_parts <- function(dir = "data/derived/gbif_agg/parts_taxon", out = "data/derived/gbif_taxon_year.parquet") {
  arrow::open_dataset(dir) |>
    dplyr::group_by(kingdom, phylum, class, order, family, genus, specieskey, species, taxonrank, year, basisofrecord, ds_class) |>
    dplyr::summarise(n = sum(n), n_ic = sum(n_ic), sum_ic = sum(sum_ic), .groups = "drop") |>
    arrow::write_parquet(sink = out)
  out
}

combine_dataset_parts <- function(dir = "data/derived/gbif_agg/parts_dataset", out = "data/derived/gbif_dataset_year.parquet") {
  arrow::open_dataset(dir) |>
    dplyr::group_by(datasetkey, kingdom, phylum, class, year, basisofrecord) |>
    dplyr::summarise(n = sum(n), .groups = "drop") |>
    arrow::write_parquet(sink = out)
  out
}

# グループ定義に合う記録を抜き出す（docs/taxon_groups.csv）
group_records <- function(taxon_file, groups_file) {
  g <- readr::read_csv(groups_file, col_types = "cccc")
  d <- arrow::open_dataset(taxon_file)
  purrr::pmap(g, function(group_id, variant, rank, values) {
    v <- strsplit(values, ";")[[1]]
    d |> dplyr::filter(!!rlang::sym(rank) %in% v) |> dplyr::collect() |>
      dplyr::mutate(group_id = group_id, variant = variant)
  }) |> purrr::list_rbind() |>
    dplyr::mutate(rtype = record_type(basisofrecord, ds_class))
}

# グループ×年×記録種類の件数（eBird 除外版も）
records_by_group_year <- function(gr) {
  gr |> dplyr::group_by(group_id, variant, year, rtype) |>
    dplyr::summarise(n = sum(n), n_no_ebird = sum(n[ds_class != "ebird"]),
                     n_species_level = sum(n[!is.na(specieskey) & specieskey != ""]),
                     n_ic = sum(n_ic), sum_ic = sum(sum_ic), .groups = "drop")
}

# 診断：上位種・上位データセットへの集中度、年増加率
group_diagnostics <- function(gr, dataset_file, groups_file, years = 2000:2024) {
  sp <- gr |> dplyr::filter(!is.na(specieskey), specieskey != "") |>
    dplyr::group_by(group_id, variant, specieskey) |> dplyr::summarise(n = sum(n), .groups = "drop") |>
    dplyr::group_by(group_id, variant) |> dplyr::arrange(dplyr::desc(n), .by_group = TRUE) |>
    dplyr::summarise(n_species_recorded = dplyr::n(), top1_species_share = n[1] / sum(n),
                     top10_species_share = sum(head(n, 10)) / sum(n), .groups = "drop")
  tot <- gr |> dplyr::group_by(group_id, variant) |>
    dplyr::summarise(R_all = sum(n), R_2000_2024 = sum(n[year %in% years]),
                     share_ebird = sum(n[ds_class == "ebird"]) / sum(n),
                     share_inat = sum(n[ds_class == "inat"]) / sum(n),
                     share_dna = sum(n[rtype == "dna"]) / sum(n),
                     share_human_obs = sum(n[rtype == "human_obs"]) / sum(n),
                     share_specimen = sum(n[rtype == "specimen"]) / sum(n),
                     share_material_sample = sum(n[rtype == "material_sample"]) / sum(n),
                     share_ic = sum(n_ic) / sum(n), .groups = "drop")
  trend <- gr |> dplyr::filter(year %in% years) |> dplyr::group_by(group_id, variant, year) |>
    dplyr::summarise(n = sum(n), .groups = "drop") |> dplyr::group_by(group_id, variant) |>
    dplyr::summarise(growth_per_yr = if (sum(n > 0) >= 5) exp(coef(lm(log(n) ~ year, subset = n > 0))[2]) - 1 else NA_real_,
                     .groups = "drop")
  # 上位データセットの占有率（データセット表は class 以上の分類しかないので、class/phylum/kingdom で定義されたグループだけ）
  g <- readr::read_csv(groups_file, col_types = "cccc") |> dplyr::filter(rank %in% c("kingdom", "phylum", "class"))
  dd <- arrow::open_dataset(dataset_file)
  ds <- purrr::pmap(g, function(group_id, variant, rank, values) {
    v <- strsplit(values, ";")[[1]]
    dd |> dplyr::filter(!!rlang::sym(rank) %in% v) |>
      dplyr::group_by(datasetkey) |> dplyr::summarise(n = sum(n)) |> dplyr::collect() |>
      dplyr::arrange(dplyr::desc(n)) |>
      dplyr::summarise(group_id = group_id, variant = variant, n_datasets = dplyr::n(),
                       top1_dataset = datasetkey[1], top1_dataset_share = n[1] / sum(n),
                       top5_dataset_share = sum(head(n, 5)) / sum(n))
  }) |> purrr::list_rbind()
  tot |> dplyr::left_join(sp, by = c("group_id", "variant")) |> dplyr::left_join(trend, by = c("group_id", "variant")) |>
    dplyr::left_join(ds, by = c("group_id", "variant"))
}
