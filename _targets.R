# targets パイプライン（Phase ごとに追加していく）
library(targets)
library(tarchetypes)
tar_option_set(packages = c("tidyverse"), seed = 20261103)
tar_source("R")

list(
  # Phase 1: センサス表（手作業で検証した provenance_parts を統合）
  tar_target(census_parts, list.files("docs/provenance_parts", "\\.csv$", full.names = TRUE), format = "file", cue = tar_cue("always")),
  tar_target(census, build_census(census_parts)),
  tar_target(census_csv, write_csv_target(census, "data/derived/census.csv"), format = "file"),
  tar_target(census_sel_csv, "docs/census_main_selection.csv", format = "file"),
  tar_target(census_main, build_census_main(census, census_sel_csv)),
  tar_target(census_main_csv, write_csv_target(census_main, "data/derived/census_main.csv"), format = "file"),

  # Phase 2: GBIF スナップショット 2026-11-01 の部分集計（scripts/phase2_launch.sh で作成済み）を統合
  tar_target(dataset_classes_csv, "data/raw/gbif_api/dataset_classes.csv", format = "file"),
  tar_target(taxon_year_file, combine_taxon_parts(), format = "file"),
  tar_target(dataset_year_file, combine_dataset_parts(), format = "file"),
  tar_target(taxon_groups_csv, "docs/taxon_groups.csv", format = "file"),
  tar_target(group_recs, group_records(taxon_year_file, taxon_groups_csv)),
  tar_target(rec_group_year, records_by_group_year(group_recs)),
  tar_target(rec_group_year_csv, write_csv_target(rec_group_year, "data/derived/records_by_group_year.csv"), format = "file"),
  tar_target(fig_p2_year, fig_records_by_year(rec_group_year), format = "file"),
  tar_target(group_diag, group_diagnostics(group_recs, dataset_year_file, taxon_groups_csv)),
  tar_target(group_diag_csv, write_csv_target(group_diag, "data/derived/records_diagnostics.csv"), format = "file"),

  # Phase 2: Tier A 種レベル
  tar_target(mam_sp0, mammal_species()),
  tar_target(bird_sp0, bird_species()),
  tar_target(mam_gy, gbif_species_year(taxon_year_file, "Mammalia")),
  tar_target(bird_gy, gbif_species_year(taxon_year_file, "Aves")),
  tar_target(mam_sp, add_gbif_name(mam_sp0, mam_gy)),
  tar_target(bird_sp, add_gbif_name(bird_sp0, bird_gy)),
  tar_target(tierA_match, dplyr::bind_rows(match_summary(mam_sp, mam_gy, "mammals_all"),
                                           match_summary(dplyr::filter(mam_sp, report_based), mam_gy, "mammals_report"),
                                           match_summary(bird_sp, bird_gy, "birds_callaghan"))),
  tar_target(tierA_match_csv, write_csv_target(tierA_match, "data/derived/tierA_match.csv"), format = "file"),
  tar_target(mam_sp_csv, write_csv_target(mam_sp, "data/derived/tierA_mammals.csv"), format = "file"),
  tar_target(bird_sp_csv, write_csv_target(bird_sp, "data/derived/tierA_birds.csv"), format = "file"),
  tar_target(tierA_gy_file, {f <- "data/derived/tierA_gbif_species_year.parquet"
    arrow::write_parquet(dplyr::bind_rows(dplyr::mutate(mam_gy, class = "Mammalia"), dplyr::mutate(bird_gy, class = "Aves")), f); f},
    format = "file"),

  # Phase 4: Tier B 主解析（PREREG v1.0 §3）
  tar_target(tb_groups, tibble::tibble(
    group_id = c("soil_nematodes", "springtails", "mites", "ants", "enchytraeids", "copepods", "pteropods", "jellyfish", "mesopelagic_fish", "krill"),
    variant = c(rep("main", 8), "myctophidae_only", "main")) |> dplyr::mutate(label = group_id)),
  tar_target(tb_cm, dplyr::filter(census_main, role == "main")),
  tar_target(tb_obs, census_obs(tb_cm)),
  tar_target(tb_R, R_table(group_recs, tb_groups)),
  tar_target(tb_main, fit_tierB(tb_obs, tb_R)),
  tar_target(tb_main_sum, summarise_tierB(tb_main, "main")),
  tar_target(tb_main_h4, h4_test(tb_main, "main")),
  tar_target(tb_main_pts, tierB_points(tb_main, "main")),
  tar_target(sens_name, sens_names),
  tar_target(sens, run_sens(sens_name, census_main = census_main, group_recs = group_recs, tb_groups = tb_groups,
                            mam_sp = mam_sp, bird_sp = bird_sp, mam_gy = mam_gy, bird_gy = bird_gy),
             pattern = map(sens_name), iteration = "list"),
  tar_target(s13, s13_mc_ols(tb_obs, tb_R)),
  tar_target(tb_sum_all, dplyr::bind_rows(c(list(tb_main_sum), unname(purrr::map(sens, "sum"))))),
  tar_target(tb_h4_all, dplyr::bind_rows(c(list(tb_main_h4), unname(purrr::map(sens, "h4"))))),
  tar_target(tb_sum_csv, write_csv_target(dplyr::bind_rows(tb_sum_all, s13), "models/tierB_summary.csv"), format = "file"),
  tar_target(tb_h4_csv, write_csv_target(tb_h4_all, "models/tierB_h4.csv"), format = "file"),
  tar_target(tb_pts_csv, write_csv_target(dplyr::bind_rows(c(list(tb_main_pts), unname(purrr::map(sens, "pts")))), "models/tierB_points.csv"), format = "file"),

  tar_target(fig_p4_scaling, fig_tierB_scaling(tb_main, dplyr::bind_rows(c(list(tb_main_pts), unname(purrr::map(sens, "pts"))))), format = "file"),
  tar_target(fig_p4_sens, fig_sensitivity(tb_sum_all, s13), format = "file"),
  tar_target(fig_p4_tierA, fig_tierA(ta_mam_report_d), format = "file"),

  # Phase 4: Tier A（PREREG §4）
  tar_target(ta_mam_report_d, tierA_data(mam_sp, mam_gy, subset = "report")),
  tar_target(ta_mam_all_d, tierA_data(mam_sp, mam_gy, subset = "all")),
  tar_target(ta_bird_d, tierA_data(dplyr::mutate(bird_sp, report_based = TRUE, order = NA_character_) |>
                                     dplyr::left_join(dplyr::distinct(dplyr::select(readr::read_csv(unz("data/raw/callaghan2021/zenodo_4723365/Tables.zip",
                                       "Tables/all_species_summary_table.csv"), show_col_types = FALSE), species = `Scientific name`, order2 = Order)), by = "species") |>
                                     dplyr::mutate(order = order2), bird_gy, subset = "all")),
  tar_target(ta_fit_mam_report, dplyr::mutate(fit_tierA(ta_mam_report_d), set = "mammals_report (main)")),
  tar_target(ta_fit_mam_all, dplyr::mutate(fit_tierA(ta_mam_all_d), set = "mammals_all (sens; SVR allometry-derived)")),
  tar_target(ta_fit_bird, dplyr::mutate(fit_tierA(ta_bird_d), set = "birds_callaghan (sens; occurrence-derived)")),
  tar_target(ta_fits, dplyr::bind_rows(ta_fit_mam_report, ta_fit_mam_all, ta_fit_bird)),
  tar_target(ta_fits_csv, write_csv_target(ta_fits, "models/tierA_summary.csv"), format = "file"),

  # Phase 2: BOLD と NCBI（API 取得、取得日時を記録）
  tar_target(bold_tbl, bold_counts(taxon_groups_csv)),
  tar_target(bold_year, bold_by_year(bold_tbl)),
  tar_target(ncbi_tbl, ncbi_counts(taxon_groups_csv)),
  tar_target(seq_counts_csv, write_csv_target(dplyr::full_join(bold_tbl, ncbi_tbl, by = c("group_id", "variant")),
                                              "data/derived/bold_ncbi_counts.csv"), format = "file"),
  tar_target(bold_year_csv, write_csv_target(bold_year, "data/derived/bold_by_year.csv"), format = "file")
)
