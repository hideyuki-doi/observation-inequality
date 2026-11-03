# SI の表をすべて結果ファイルから生成する（手で数値を書かない）。出力：manuscript/si_tables.md
suppressPackageStartupMessages({ library(dplyr); library(readr); library(tidyr); library(targets) })
f2 <- function(x, d = 2) formatC(x, digits = d, format = "f")
sci <- function(x) formatC(x, digits = 2, format = "e")
md <- function(df) knitr::kable(df, format = "pipe")
out <- character()
add <- function(title, df, note = NULL) out <<- c(out, paste0("\n### ", title, "\n"), md(df), if (!is.null(note)) paste0("\n*", note, "*\n"))

# S1 センサス（主 10 グループ）
cm <- read_csv("data/derived/census_main.csv", show_col_types = FALSE) |> filter(role == "main")
tg <- read_csv("docs/taxon_groups.csv", show_col_types = FALSE) |> filter(variant %in% c("main", "myctophidae_only"))
tbm <- tar_read(tb_main)
s1 <- cm |> left_join(tg, by = "group_id") |>
  transmute(Group = group_id, `N (individuals)` = sci(N), `B (g wet)` = sci(B_g_wet), `M (g wet)` = sci(M_g_wet),
            `Census source` = citation, `GBIF rule` = paste0(rank, ": ", gsub(";", ", ", values)),
            `R 2000–2024` = format(tbm$Rt$all[match(group_id, tbm$Rt$label)], big.mark = ","))
add("Table S1. Census estimates and GBIF matching for the ten main groups", s1,
    "Method class of all ten census abundances: independent. Full provenance, verbatim quotes and uncertainty conversions in docs/data_provenance.md.")

# S2 感度分析
s <- read_csv("models/tierB_summary.csv", show_col_types = FALSE)
h <- read_csv("models/tierB_h4.csv", show_col_types = FALSE)
ci <- function(m, l, u) ifelse(is.na(m), "", paste0(f2(m), " [", f2(l), ", ", f2(u), "]"))
s2 <- s |> mutate(v = ci(beta_med, beta_lo, beta_hi)) |> select(analysis, type, v) |>
  pivot_wider(names_from = type, values_from = v) |>
  left_join(s |> filter(type == "all") |> select(analysis, R2_med, H1, H2), by = "analysis") |>
  left_join(h |> select(analysis, P_dna_lt_human, H4), by = "analysis") |>
  transmute(Analysis = analysis, `β all` = all, `β human obs.` = human_obs, `β specimen` = specimen, `β DNA` = dna,
            `R² (all)` = f2(R2_med), H1, H2, `P(β_DNA<β_human)` = f2(P_dna_lt_human, 3), H4)
add("Table S2. Scaling exponents in the main analysis and all sensitivity analyses", s2,
    "Posterior medians and 95% CrI. S13 uses Monte Carlo propagation with ordinary least squares (no CrI-based decisions). Decision rules in PREREG v1.0 §3.")

# S3 Tier A
ta <- read_csv("models/tierA_summary.csv", show_col_types = FALSE) |>
  transmute(Set = set, Species = n_species, `Zero-record species` = n_zero, Orders = n_orders,
            `β [95% CrI]` = ci(beta_med, beta_lo, beta_hi), `SD order` = f2(sd_order), τ = f2(tau), `R̂ max` = f2(rhat_max, 3), Divergences = divergent)
add("Table S3. Species-level scaling within mammals and birds", ta)

# S4 φ
pm <- read_csv("sim/phi_estimate.csv", show_col_types = FALSE)
pb <- read_csv("sim/explore_phi_by_mean.csv", show_col_types = FALSE)
pi <- read_csv("sim/explore_phi_inverts.csv", show_col_types = FALSE)
po <- read_csv("sim/explore_occupancy_phi.csv", show_col_types = FALSE)
s4a <- tibble(Set = "Mammals, reported populations (preregistered)", Species = pm$n_species, Observations = pm$n_obs,
              `φ [95% CrI]` = ci(pm$phi_med, pm$phi_lo, pm$phi_hi))
add("Table S4a. Overdispersion of annual record counts (preregistered estimate)", s4a)
add("Table S4b. Overdispersion by recording intensity, mammals (exploratory)", pb |> transmute(`Mean records/yr` = stratum, Species = n_species, φ = f2(theta), SE = f2(theta_se, 3)))
s4c <- po |> transmute(Group = group_id, Stratum = stratum, Species = n_species, `Mean records/yr` = f2(mean_rec), `Mean occupied cells/yr` = f2(mean_occ),
                       `φ records` = f2(phi_rec), `φ occupied cells` = f2(phi_occ))
add("Table S4c. Overdispersion of record counts and occupied 1° cells by group and stratum (exploratory)", s4c,
    "Up to 300 species sampled per stratum (seed 20261103); negative binomial with species and year fixed effects.")

# S5 対照シナリオ
cf <- read_csv("sim/control_false_trends.csv", show_col_types = FALSE) |> group_by(T) |>
  summarise(`(a) false decline` = mean(a), `(b) false decline` = mean(b), `(c) false decline` = mean(c), `(c) false increase` = mean(c_up), .groups = "drop") |>
  mutate(across(-T, \(x) paste0(f2(100 * x, 1), "%"))) |> rename(`Monitoring years` = T)
add("Table S5. Rates of spurious significant trends in simulations without decline", cf,
    "Averaged over the ten groups and 36 values of λ0; 1,000 replicates each. (a) NB regression with effort offset; (b) binomial model of relative reporting rate; (c) NB regression on raw counts.")

# S6 占有ベースの検出年数
oc <- read_csv("sim/explore_occupancy_tdetect.csv", show_col_types = FALSE) |> select(group_id, stratum, index, T_detect) |>
  pivot_wider(names_from = index, values_from = T_detect) |>
  transmute(Group = group_id, Stratum = stratum, `Years, record counts` = ifelse(is.infinite(records), ">100", records),
            `Years, occupied cells` = ifelse(is.infinite(occupied_cells), ">100", occupied_cells))
add("Table S6. Years to detect a 30% decline per decade: record counts vs occupied cells (exploratory)", oc,
    "Constant effort; occupancy index assumed to decline in proportion to abundance (optimistic).")

# S7 脊椎動物
vs <- read_csv("sim/explore_vertebrates_summary.csv", show_col_types = FALSE) |>
  transmute(Set = set, Species = n, `log10 M range` = log10M_range, `Median residual (log10)` = f2(resid_vs_TierB_med),
            `95% interval over line uncertainty` = paste0(f2(resid_draw_lo), " to ", f2(resid_draw_hi)), `Residual vs 2/3 line` = f2(resid_vs_opt_med),
            `Within-set slope (OLS)` = f2(slope_within))
add("Table S7. Mammal species with census abundances, relative to the main relationship (exploratory)", vs,
    "census_independent: survey- or survey/catch-model-based (Greenspoon et al. 2025; CITES CoP20; Great Elephant Census; IUCN). report_land: populations reported in Greenspoon et al. 2023. Species lists in sim/explore_vertebrates_species.csv.")

# S8 H5
h5 <- read_csv("sim/h5_unrecorded.csv", show_col_types = FALSE) |> filter(sigma10 == 1.5) |>
  transmute(Group = group_id, `Window (yr)` = T_years, `Estimated total species` = format(round(S_total), big.mark = ","),
            `Described` = format(S_described, big.mark = ","), `Recorded 2000–2024` = format(recorded_2000_2024, big.mark = ","),
            `Literature undescribed share` = f2(lit_undescribed_frac), `Predicted never recorded [95%]` = ci(pred_never_recorded_med, pred_lo, pred_hi))
add("Table S8. Predicted share of species never recorded vs literature undescribed share (exploratory)", h5)

# S9 LPD
lp <- read_csv("sim/lpd2016_mass_bias_summary.csv", show_col_types = FALSE) |>
  transmute(Class = class, `Species with mass` = n_all, `Species in LPD` = n_lpd, `Median mass, all (g)` = f2(median_M_all, 1),
            `Median mass, LPD species (g)` = f2(median_M_lpd_species, 1), `Median mass, population-weighted (g)` = f2(median_M_lpd_popweighted, 1),
            `Ratio (species)` = f2(ratio_species, 1), `KS p` = formatC(ks_p, digits = 1, format = "e"))
add("Table S9. Body-size representation in the Living Planet Database 2016 public release (exploratory)", lp)

# S10 経験的な検出不能割合
eg <- read_csv("sim/explore_empirical_groupphi.csv", show_col_types = FALSE) |> filter(decline == "30%/10yr") |>
  transmute(Group = group_id, `log10 M` = f2(log10M), `Described species` = format(S, big.mark = ","), `Recorded 2015–2024` = format(recorded, big.mark = ","),
            `λ threshold (records/yr)` = f2(lambda_never), `Detection floor (yr)` = T_floor, `Undetectable within 100 yr` = paste0(f2(100 * share_never, 1), "%"))
va <- read_csv("sim/explore_empirical_vert_all.csv", show_col_types = FALSE) |> filter(decline == "30%/10yr") |>
  transmute(Group = group_id, `Species with mass` = S, `Median λ` = f2(median_lambda, 1), `Undetectable within 100 yr` = paste0(f2(100 * share_never, 1), "%"))
add("Table S10a. Share of described species whose decline is undetectable within 100 years, invertebrate and small marine groups (exploratory)", eg)
add("Table S10b. Same, mammals and birds (φ = 0.69)", va)

writeLines(c("## SI tables (generated by manuscript/make_si_tables.R)", out), "manuscript/si_tables.md")
cat("written\n")
