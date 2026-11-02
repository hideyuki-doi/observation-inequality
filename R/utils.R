# 共通関数
write_csv_target <- function(x, path) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  readr::write_csv(x, path, na = "")
  path
}
`%||%` <- function(a, b) if (is.null(a)) b else a
