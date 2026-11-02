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

  # Phase 2: BOLD と NCBI（API 取得、取得日時を記録）
  tar_target(bold_tbl, bold_counts(taxon_groups_csv)),
  tar_target(bold_year, bold_by_year(bold_tbl)),
  tar_target(ncbi_tbl, ncbi_counts(taxon_groups_csv)),
  tar_target(seq_counts_csv, write_csv_target(dplyr::full_join(bold_tbl, ncbi_tbl, by = c("group_id", "variant")),
                                              "data/derived/bold_ncbi_counts.csv"), format = "file"),
  tar_target(bold_year_csv, write_csv_target(bold_year, "data/derived/bold_by_year.csv"), format = "file")
)
