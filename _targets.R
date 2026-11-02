# targets パイプライン（Phase ごとに追加していく）
library(targets)
library(tarchetypes)
tar_option_set(packages = c("tidyverse"), seed = 20261103)
tar_source("R")

list(
  # Phase 1: センサス表（手作業で検証した provenance_parts を統合）
  tar_target(census_parts, list.files("docs/provenance_parts", "\\.csv$", full.names = TRUE), format = "file"),
  tar_target(census, build_census(census_parts)),
  tar_target(census_csv, write_csv_target(census, "data/derived/census.csv"), format = "file")
)
