# Phase 1: 各担当のセンサス表を統合する
build_census <- function(files) {
  files |>
    purrr::map(\(f) readr::read_csv(f, col_types = readr::cols(.default = "c")) |>
                 dplyr::mutate(part = tools::file_path_sans_ext(basename(f)))) |>
    purrr::list_rbind()
}
