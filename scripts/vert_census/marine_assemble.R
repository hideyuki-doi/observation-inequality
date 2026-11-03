# Assemble marine-mammal rows for vert_census.csv (run from project dir after marine.R)
suppressMessages({library(dplyr); library(readr); library(readxl)})
out <- "data/derived/vert_census/"
g25 <- "data/raw/greenspoon2025/mammal_biomass_since_1850/"
pops <- read.csv(file.path(out, "g2025_marine_populations_2020.csv"), stringsAsFactors = FALSE)
g23  <- read.csv(file.path(out, "g2023_species.csv"), stringsAsFactors = FALSE)
mass25 <- read.csv(file.path(out, "g2025_mass.csv"), stringsAsFactors = FALSE)
comb <- read_csv("data/raw/combine/trait_data_reported.csv", show_col_types = FALSE) %>%
  select(iucn2020_binomial, adult_mass_g) %>% filter(!is.na(adult_mass_g)) %>% distinct(iucn2020_binomial, .keep_all = TRUE)

# last abundance-data year per modelled population (model_input 'Year' column)
mi <- read_excel(file.path(g25, "data/wild_marine/model_input.xlsx"), sheet = "params")
yrs <- suppressWarnings(as.integer(substr(as.character(mi$Year), 1, 4)))
lastyr <- tapply(yrs, mi$`Scientific name`, function(v) if (all(is.na(v))) NA else max(v, na.rm = TRUE))
names(lastyr)[names(lastyr) == "Globicephaia melas"] <- "Globicephala melas"

# --- source-level corrections, each documented in notes ---
pops$sci[pops$sci == "Globicephaia melas"] <- "Globicephala melas"   # typo in species properties.xlsx
pops$drop <- FALSE
# NZ fur seal: two 'entire' rows (200,000 [1,000-2,000,000] and 150,000 [135,000-200,000]); SI Note 6.1.1 states the first.
pops$drop[pops$sci == "Arctocephalus forsteri" & pops$N_med == 150000] <- TRUE
sirenia_si <- c("Dugong dugon" = 160000, "Trichechus inunguis" = 30000, "Trichechus senegalensis" = 10000, "Trichechus manatus" = 4000)

placeholder <- function(lo, med, hi) med == 1500 & lo == 1000 & hi == 3000
sp <- pops %>% filter(!drop) %>% group_by(sci) %>%
  summarise(N = sum(N_med), lo = sum(N_lo), hi = sum(N_hi), nmodel = sum(src == "model"),
            n_entire = sum(src == "unexploited:entire"), n_rest = sum(src == "unexploited:rest"),
            share_model = sum(N_med[src == "model"]) / sum(N_med),
            any_placeholder = any(placeholder(N_lo, N_med, N_hi) & src != "model"),
            comps = paste0(ifelse(src == "model", "model2020", sub("unexploited:", "unexpl-", src)), "[", region, ":",
                           formatC(N_med, format = "g", digits = 4), "]", collapse = "; "), .groups = "drop")

syn <- c("Otaria flavescens"="Otaria byronia","Kogia simus"="Kogia sima","Platanista minor"="Platanista gangetica","Delphinus tropicalis"="Delphinus capensis")
mass25$Scientific.name[mass25$Scientific.name == "Globicephaia melas"] <- "Globicephala melas"
sp$mkey <- ifelse(sp$sci %in% names(syn), syn[sp$sci], sp$sci)
rows <- sp %>% left_join(g23, by = c("sci" = "species")) %>%
  left_join(comb, by = c("mkey" = "iucn2020_binomial")) %>%
  left_join(mass25 %>% select(Scientific.name, w_t) %>% distinct(Scientific.name, .keep_all = TRUE), by = c("sci" = "Scientific.name"))
rows$lastyr <- unname(lastyr[rows$sci])

mk <- function(r) {
  sir <- r$sci %in% names(sirenia_si)
  N <- if (sir) unname(sirenia_si[r$sci]) else r$N
  lo <- if (sir) NA else r$lo; hi <- if (sir) NA else r$hi
  mclass <- if (r$nmodel > 0 && r$share_model >= 0.5) "independent" else if (r$any_placeholder) "unclear" else
    if (sir || r$sci %in% c("Lobodon carcinophaga", "Arctocephalus forsteri", "Mirounga angustirostris")) "independent" else "unclear"
  ev <- if (r$nmodel > 0) sprintf("SSRA logistic model (Christensen 2006 variant) fitted to catch records + survey abundance points (model_input.xlsx); %d modelled population(s) = %.0f%% of species N; no occurrence data, no body-size predictor of density (r prior by superfamily).", r$nmodel, 100*r$share_model)
        else if (sir) "SI Note 6.2: current-day estimates from regional surveys (dugong) / IUCN Red List (manatees); underlying survey methods per IUCN, not re-verified."
        else if (r$any_placeholder) "Supplementary Data 1 value 1500 (1000-3000) identical across many data-deficient beaked whales: looks like a default guess (Christensen 2006 compilation), not a survey."
        else "Supplementary Data 1 (unexploited populations); SI: 'For all other populations, we used values curated by Christensen' (2006 UBC thesis) - underlying survey method 未確認."
  if (r$nmodel > 0 && r$share_model < 0.5) ev <- paste(ev, "Majority of N from 'rest' (unexploited) rows curated by Christensen 2006; method of those 未確認.")
  if (r$nmodel > 0 && r$share_model < 0.5) mclass <- "mixed"
  scope <- if (r$n_entire > 0 || r$n_rest > 0) "global (source species total)" else
    "near-global: sum of modelled populations only (source has no 'rest' row; unlisted populations, if any, omitted)"
  notes <- c(sprintf("components: %s", r$comps))
  if ((r$n_entire > 0 && (r$n_rest > 0 || r$nmodel > 0)) || (r$n_entire > 1 && r$sci != "Arctocephalus forsteri")) notes <- c(notes, "WARNING: species has an 'entire' row plus other rows -> source total may double count")
  if (r$sci == "Arctocephalus forsteri") notes <- c(notes, "dropped duplicate 'entire' row 150,000 (135,000-200,000); kept 200,000 (1,000-2,000,000) as stated in SI Note 6.1.1")
  if (sir) notes <- c(notes, sprintf("N from SI Note 6.2 text; Suppl. Data 1 columns for sirenians are inconsistent (mean < min): xlsx mean=%s, min=%s, max=%s", formatC(r$N, format="d", big.mark=""), formatC(r$lo, format="d"), formatC(r$hi, format="d")))
  if (r$sci == "Tursiops truncatus") notes <- c(notes, "NWA population is mapped to Hyperoodon ampullatus in model_input.xlsx (source error); N recovered with the mass the source used and reassigned here to T. truncatus")
  if (!is.na(r$lastyr)) notes <- c(notes, sprintf("latest abundance data point fitted: %d", r$lastyr))
  if (!is.na(r$N23)) notes <- c(notes, sprintf("cross-check Greenspoon 2023 (IUCN text): %s (%s, RL assessed %s)", formatC(r$N23, format = "g", digits = 6), r$type23, r$yr23))
  if (!is.na(r$N23) && abs(log10(N / r$N23)) > 0.5) notes <- c(notes, sprintf("DISCREPANCY >3.2-fold vs Greenspoon 2023 IUCN value (ratio %.2f)%s", N / r$N23, ifelse(r$type23 != "partial" && N < r$N23, "; G2025 total may omit populations", "")))
  notes <- c(notes, sprintf("source mean mass %.4g t (Trites & Pauly 1998 based)", r$w_t))
  data.frame(species = r$sci, class = "Mammalia", N_est = N, N_lo = lo, N_hi = hi,
    interval_type = if (sir) "none" else if (r$nmodel > 0) "sum_of_population_quantiles_2.5_97.5 (model) + min/max (unexploited); not a joint CI" else "range (min-max, Suppl. Data 1)",
    year_of_estimate = if (r$nmodel > 0) "2020 (model year)" else "未確認 (compiled value; SI uses it as current-day)",
    scope = scope, method_class = mclass, method_evidence = ev,
    citation = "Greenspoon L, et al. 2025. Nat Commun (mammal biomass since 1850); data/code gitlab.com/milo-lab-public/mammal_biomass_since_1850",
    doi_or_url = "https://doi.org/10.1038/s41467-025-63888-z ; https://gitlab.com/milo-lab-public/mammal_biomass_since_1850",
    location_in_source = "results/marine_model_results/biomass/*.csv (col 2020, rows 0.025/0.5/0.975) / species properties.xlsx mean_weight; data/wild_marine/unexploited_populations.xlsx (=Suppl. Data 1)",
    mass_g = r$adult_mass_g, mass_source = ifelse(is.na(r$adult_mass_g), "未確認 (not in COMBINE reported)", paste0("COMBINE trait_data_reported.csv adult_mass_g", ifelse(r$mkey != r$sci, paste0(" (matched as ", r$mkey, "; taxonomic lump/synonym)"), ""))),
    verified = "yes", notes = paste(notes, collapse = " | "), stringsAsFactors = FALSE)
}
res <- bind_rows(lapply(seq_len(nrow(rows)), function(i) mk(rows[i, ])))
# species present only in Greenspoon 2023 (IUCN text)
# O. byronia = synonym of O. flavescens (already in G2025)
only23 <- g23 %>% filter(!species %in% res$species, species != "Otaria byronia") %>% left_join(comb, by = c("species" = "iucn2020_binomial"))
kw <- "survey|census|count|mark-recapture|photo-id|photo-identification|aerial|line transect|line-transect|sighting"
res23 <- bind_rows(lapply(seq_len(nrow(only23)), function(i) { r <- only23[i, ]
  data.frame(species = r$species, class = "Mammalia", N_est = r$N23, N_lo = NA, N_hi = NA, interval_type = "none (point; ranges in IUCN text averaged by source code)",
    year_of_estimate = paste0("IUCN assessment ", r$yr23), scope = ifelse(r$type23 == "partial", "partial (IUCN text reports only part of range)", "global (IUCN total/mature)"),
    method_class = ifelse(grepl(kw, tolower(r$popdetail)) & r$type23 != "partial", "independent", "unclear"),
    method_evidence = paste0("IUCN Red List 'Population' text extracted by Greenspoon 2023; keyword check on text: ", ifelse(grepl(kw, tolower(r$popdetail)), "survey/count wording present", "no survey wording"), ". Text start: ", gsub("\"", "'", substr(r$popdetail, 1, 200))),
    citation = "Greenspoon L, et al. 2023. PNAS 120:e2204892120 (marine species from IUCN Red List text)",
    doi_or_url = "https://doi.org/10.1073/pnas.2204892120 ; https://gitlab.com/milo-lab-public/mammal_biomass",
    location_in_source = "data/marine_data/manually_curated_data.csv ('Extracted total population' cols; reproduced marine_mammal_biomass.ipynb s.2-4)",
    mass_g = r$adult_mass_g, mass_source = ifelse(is.na(r$adult_mass_g), "未確認", "COMBINE trait_data_reported.csv adult_mass_g"),
    verified = "yes", notes = paste0("type=", r$type23, "; RL=", r$RL, "; not in Greenspoon 2025 tables"), stringsAsFactors = FALSE) }))
allm <- bind_rows(res, res23)
write.csv(allm, file.path(out, "marine_mammals.csv"), row.names = FALSE, na = "")
cat("rows:", nrow(allm), " from G2025:", nrow(res), " G2023-only:", nrow(res23), "\n")
print(table(allm$method_class)); cat("mass missing:", sum(is.na(allm$mass_g)), "\n")
print(allm %>% filter(is.na(mass_g)) %>% pull(species))
