# SI の表をすべて結果ファイルから生成する（手で数値を書かない）。出力：manuscript/si_tables.md（改訂版、表 S1–S20）
suppressPackageStartupMessages({ library(dplyr); library(readr); library(tidyr); library(targets) })
f2 <- function(x, d = 2) formatC(x, digits = d, format = "f")
sci <- function(x) formatC(x, digits = 2, format = "e")
ci <- function(m, l, u) ifelse(is.na(m), "", paste0(f2(m), " [", f2(l), ", ", f2(u), "]"))
md <- function(df) knitr::kable(df, format = "pipe")
r <- function(f) read_csv(f, show_col_types = FALSE)
out <- character()
add <- function(title, df, note = NULL) out <<- c(out, paste0("\n### ", title, "\n"), md(df), if (!is.null(note)) paste0("\n*", note, "*\n"))

# S1
cm <- r("data/derived/census_main.csv") |> filter(role == "main")
tg <- r("docs/taxon_groups.csv") |> filter(variant %in% c("main", "myctophidae_only"))
tbm <- tar_read(tb_main)
add("Table S1. Census estimates and GBIF matching for the ten groups with independent censuses",
    cm |> left_join(tg, by = "group_id") |>
      transmute(Group = group_id, `N (individuals)` = sci(N), `B (g wet)` = sci(B_g_wet), `M (g wet)` = sci(M_g_wet), `Census source` = citation,
                `GBIF rule` = paste0(rank, ": ", gsub(";", ", ", values)), `Records 2000–2024` = format(tbm$Rt$all[match(group_id, tbm$Rt$label)], big.mark = ",")),
    "All ten abundances classified independent. Provenance, verbatim quotations and uncertainty conversions: docs/data_provenance.md.")
# S2
s <- r("models/tierB_summary.csv"); h <- r("models/tierB_h4.csv")
add("Table S2. Preregistered analysis: exponents of records per individual on body mass (main and sensitivity analyses)",
    s |> mutate(v = ci(beta_med, beta_lo, beta_hi)) |> select(analysis, type, v) |> pivot_wider(names_from = type, values_from = v) |>
      left_join(s |> filter(type == "all") |> select(analysis, R2_med, H1, H2), by = "analysis") |> left_join(h |> select(analysis, P_dna_lt_human, H4), by = "analysis") |>
      transmute(Analysis = analysis, `β all` = all, `β human obs.` = human_obs, `β specimen` = specimen, `β DNA` = dna, `R² (all)` = f2(R2_med), H1, H2,
                `P(β_DNA<β_human)` = f2(P_dna_lt_human, 3), H4),
    "Preregistered decision labels are reported as computed; they are not interpretable as evidence about detection because the exponent is not identifiable (Tables S11–S12). The S13 interval propagates census uncertainty only (not the regression sampling uncertainty) and is therefore narrower than the credible intervals. Sensitivity results are a robustness range, not independent replications.")
# S3
ta <- r("models/tierA_summary.csv")
m <- tar_read(ta_mam_report_d); fo <- summary(lm(log10(R + 0.5) ~ log10(N) + log10(M_g), data = m))$coefficients
add("Table S3. Species-level models within mammals and birds",
    bind_rows(ta |> transmute(Model = paste0("Preregistered PLN, ", set), Species = n_species, `Exponent [95% CrI]` = ci(beta_med, beta_lo, beta_hi), Note = "exponent of records per individual on body mass"),
              tibble(Model = "OLS log10(R+0.5) ~ log10 N + log10 M, mammals with reported populations", Species = nrow(m),
                     `Exponent [95% CrI]` = paste0("N: ", f2(fo[2, 1]), " (SE ", f2(fo[2, 2]), "); M: ", f2(fo[3, 1]), " (SE ", f2(fo[3, 2]), ")"), Note = "exploratory")))
# S4
pm <- r("sim/phi_estimate.csv"); pb <- r("sim/explore_phi_by_mean.csv")
add("Table S4. Overdispersion of annual record counts: preregistered estimate and by recording intensity (mammals, species + year effects)",
    bind_rows(tibble(Set = "Preregistered (382 species)", `φ` = ci(pm$phi_med, pm$phi_lo, pm$phi_hi)),
              pb |> transmute(Set = paste0("Mean records/yr ", stratum, " (", n_species, " spp.)"), `φ` = paste0(f2(theta), " (SE ", f2(theta_se, 3), ")"))))
# S5
c5 <- r("sim/control_false_trends.csv") |> mutate(rate = cut(lambda0, c(0, 1, 10, Inf), right = FALSE, labels = c("<1", "1–10", "≥10"))) |>
  group_by(`Years` = T, `Records/species-yr` = rate) |>
  summarise(`(a) false decline` = mean(a), `(b) false decline` = mean(b), `(c) false decline` = mean(c), `(c) false increase` = mean(c_up), .groups = "drop") |>
  mutate(across(starts_with("("), \(x) paste0(f2(100 * x, 1), "%")))
add("Table S5. Spurious significant trends in preregistered simulations without decline, by record rate", c5,
    "Ten groups, 1,000 replicates each; independent years. (a) NB regression with effort offset; (b) binomial relative reporting rate; (c) NB regression on raw counts.")
# S6
po <- r("sim/explore_occupancy_phi.csv"); oc <- r("sim/explore_occupancy_tdetect.csv") |> select(group_id, stratum, index, T_detect) |> pivot_wider(names_from = index, values_from = T_detect)
add("Table S6. Record counts versus occupied 1° cells: overdispersion and years to detect a 30% decline per decade (exploratory)",
    po |> left_join(oc, by = c("group_id", "stratum")) |>
      transmute(Group = group_id, Stratum = stratum, Species = n_species, `φ records` = f2(phi_rec), `φ cells` = f2(phi_occ),
                `Years, records` = ifelse(is.infinite(records), ">100", records), `Years, cells` = ifelse(is.infinite(occupied_cells), ">100", occupied_cells)))
# S7
add("Table S7. Mammal species with census abundances relative to the extrapolated preregistered relationship (exploratory)",
    r("sim/explore_vertebrates_summary.csv") |> transmute(Set = set, Species = n, `log10 M range` = log10M_range, `Median residual (log10)` = f2(resid_vs_TierB_med),
                                                          `95% interval over line uncertainty` = paste0(f2(resid_draw_lo), " to ", f2(resid_draw_hi)), `Within-set slope` = f2(slope_within)),
    "census_independent: survey- or survey/catch-model-based abundances (duplicated elephant entry and unverified polar bear removed).")
# S8
h5 <- r("sim/h5_unrecorded.csv") |> filter(sigma10 == 1.5, T_years == 25)
add("Table S8. Never-recorded species predicted by the observation model (H5; exploratory, not supported)",
    h5 |> transmute(Group = group_id, `Estimated total species` = format(round(S_total), big.mark = ","), `Literature undescribed share` = f2(lit_undescribed_frac),
                    `Predicted never recorded (25 yr)` = ci(pred_never_recorded_med, pred_lo, pred_hi),
                    `Predicted recorded species` = format(round(S_total * (1 - pred_never_recorded_med)), big.mark = ","),
                    `Observed recorded 2000–2024` = format(recorded_2000_2024, big.mark = ","),
                    `Ratio predicted/observed` = f2(S_total * (1 - pred_never_recorded_med) / recorded_2000_2024, 1)),
    "The prediction and the benchmark share the literature richness totals; predicted recorded species exceed observed by 4–11 times in four groups.")
# S9
add("Table S9. Records, sampling events and dataset concentration, 2000–2024 (exploratory)",
    r("sim/rev_events_datasets.csv") |> transmute(Group = group_id, Records = format(R, big.mark = ","), `Sampling events` = format(R_events, big.mark = ","),
                                                   Datasets = n_datasets, `Top-1 share` = f2(top1), `Top-3 share` = f2(top3),
                                                   `Human obs.` = format(human_obs, big.mark = ","), Specimens = format(specimen, big.mark = ","),
                                                   `DNA barcodes (iBOL)` = format(dna_barcode, big.mark = ","), `DNA metabarcoding/eDNA` = format(dna_metabarcoding, big.mark = ",")),
    "Sampling event = unique species × dataset × 0.1° cell × date.")
# S10
dt <- r("data/derived/dna_dataset_types.csv") |> mutate(dna_type = ifelse(grepl("EUKARYOME|reference database", title), "reference_db", dna_type))
rec <- arrow::open_dataset("data/derived/gbif_events/records") |> filter(year >= 2000, year <= 2024, ds_class == "dna_ext") |>
  group_by(datasetkey) |> summarise(n = sum(n)) |> collect()
add("Table S10. DNA-derived records by dataset type (all analysed groups and mammals, 2000–2024)",
    rec |> left_join(dt, by = "datasetkey") |> group_by(Type = dna_type) |> summarise(Datasets = n(), Records = format(sum(n), big.mark = ","), `Largest dataset` = title[which.max(n)]))
# S11
rn <- r("sim/rev_ratio_null.csv")
add("Table S11. Ratio artefact: exponent of records per individual on body mass under null record allocations",
    tibble(Allocation = c("Observed records (OLS on point estimates)", "Identical records in every group", "Records permuted among groups (5,000)", "Preregistered EIV estimate"),
           `Exponent` = c(f2(rn$observed_beta_ols), f2(rn$constant_records_beta), paste0(f2(rn$perm_median), " [", f2(rn$perm_lo), ", ", f2(rn$perm_hi), "]"), "0.72 [0.49, 0.94]")))
# S12
fe <- bind_rows(r("sim/rev_free_exponent.csv") |> transmute(Analysis = model, param, med, lo, hi, P_gt0),
                r("sim/rev_scope_free_exponent.csv") |> transmute(Analysis = "scope-corrected records, N + M + log S", param, med, lo, hi, P_gt0),
                r("sim/rev_events_free_exponent.csv") |> transmute(Analysis = paste0(response, ", N + M + log S"), param, med, lo, hi, P_gt0),
                r("sim/rev_free_sensitivity.csv") |> transmute(Analysis = paste0(analysis, ", N + M + log S"), param, med, lo, hi, P_gt0))
add("Table S12. Errors-in-variables models of log records with free coefficients (exploratory)",
    fe |> transmute(Analysis, Parameter = param, `Estimate [95% CrI]` = ci(med, lo, hi), `P(>0)` = f2(P_gt0)),
    "γ = 1 would mean records proportional to individuals. Posterior predictive coverage of observed records by 95% intervals was 10/10 in all variants (sim/rev_free_sensitivity.csv). R̂ ≤ 1.01 throughout; 2–9 divergent transitions of 8,000 in models with described species.")
# S13
add13 <- function(df) add("Table S13. Records per described species and share of species without records", df,
  "For birds, GBIF (COL eXtended Release) recognises more species than the Catalogue of Life count of described species used here, so the share without records is truncated at zero.")
add13(
    r("sim/rev_species_rates.csv") |> transmute(Group = group_id, `log10 M` = f2(log10M), `Described species` = format(S, big.mark = ","),
                                                `Recorded 2015–2024` = format(recorded, big.mark = ","), `No records 2015–2024` = paste0(f2(100 * pmax(share_zero, 0), 1), "%"),
                                                `Records/species/yr (2000–2024)` = f2(R_per_species, 1), `Median λ, recorded species` = f2(median_recorded)))
# S14
add("Table S14. DNA-derived relative to human-observation records against body mass (abundance cancels; exploratory)",
    r("sim/rev_h4_contrast.csv") |> transmute(Contrast = contrast, `Slope per log10 g [95%]` = ci(slope, lo, hi), `P(<0)` = f2(P_lt0, 3)))
# S15
an <- r("sim/rev_detection_analytic.csv") |> filter(lambda %in% c(10, Inf))
add("Table S15. Analytic detection metrics (power 0.8, one-sided α = 0.05)",
    an |> transmute(`φ` = phi, `Records/species-yr` = ifelse(is.infinite(lambda), "∞", lambda), `Years, 30%/decade` = f2(T30, 1), `Years, 50%/decade` = f2(T50, 1),
                    `Min. decline detectable in 10 yr` = paste0(f2(100 * min_decline_10yr, 0), "%"), `Lost at detection (30%/decade)` = paste0(f2(100 * lost_at_detection_30, 0), "%")))
# S16
add("Table S16. Overdispersion and residual autocorrelation estimated per species with an effort offset (exploratory)",
    r("sim/rev_phi_species_summary.csv") |> filter(n_species >= 5) |>
      transmute(Set = set, `Records/yr` = stratum, Species = n_species, `φ, no trend` = f2(phi_none), `φ, linear trend` = f2(phi_linear), `φ, quadratic trend` = f2(phi_quadratic),
                `Lag-1 autocorrelation` = f2(ac1_linear)))
# S17
add("Table S17. Effect of year-to-year autocorrelation on the effort-offset method (φ = 0.69; exploratory)",
    r("sim/rev_autocorrelation.csv") |> transmute(Scenario = scenario, `Records/species-yr` = lambda0, Years = T, rho = paste0("ρ = ", rho), dec) |>
      pivot_wider(names_from = rho, values_from = dec) |> mutate(across(starts_with("ρ"), \(x) paste0(f2(100 * x, 1), "%"))),
    "Share of 1,000 series flagged as significantly declining (one-sided α = 0.05).")
# S18
add("Table S18. British butterflies 2000–2019: GBIF record-based trends versus UK Butterfly Monitoring Scheme trends (48 species; exploratory)",
    r("sim/rev_validation_ukbms_summary.csv") |> transmute(Method = c(a = "(a) effort offset", b = "(b) relative reporting rate", c = "(c) raw counts")[method],
                                                         `Pearson r` = f2(pearson_slopes), `Spearman ρ` = f2(spearman_slopes),
                                                         `UKBMS declines detected` = paste0(detected_of_uk_declines, "/", uk_declines),
                                                         `False declines` = paste0(false_declines, "/", uk_not_declining), `Opposite significant sign` = opposite_sign_sig))
# S19
add("Table S19. Share of described species by time to detect a 30% decline per decade (exploratory)",
    r("sim/rev_detectability_totals.csv") |> transmute(Group = group_id, Species = n, `Never recorded 2015–2024` = paste0(f2(100 * never_recorded, 1), "%"),
                                                      `Undetectable within 100 yr` = paste0(f2(100 * undetectable_100, 1), "%"),
                                                      `Among recorded species` = paste0(f2(100 * undetectable_100_among_recorded, 1), "%"),
                                                      `Detectable within 50 yr` = paste0(f2(100 * within_50, 1), "%"), `Detectable within 25 yr` = paste0(f2(100 * within_25, 1), "%")))
# S20
add("Table S20. Taxonomic scope corrections (exploratory)",
    r("sim/rev_scope_variants.csv") |> transmute(Group = group_id, `Records, main rule` = format(R_main, big.mark = ","), `Records, corrected` = format(R_scope, big.mark = ","),
                                                `Described species used` = format(S_used, big.mark = ","), `Below 0.32 records/yr` = paste0(f2(100 * share_lt_0.32, 1), "%"),
                                                `Same, alternative species count` = ifelse(is.na(share_lt_0.32_altS), "", paste0(f2(100 * share_lt_0.32_altS, 1), "% (", format(S_alt, big.mark = ","), ")"))),
    "Mites: water-mite, plant-, animal-associated and stored-product families excluded; nematodes: marine-dominated orders and animal-parasitic taxa excluded; mesopelagic fishes: 15 families (species count = species ever recorded). Alternative counts from literature compilations.")
writeLines(c("## Supplementary tables", out), "manuscript/si_tables.md")
cat("written\n")
