# Phase 2: BOLD（portal.boldsystems.org/api）と NCBI（E-utilities）の件数
# グループ定義は docs/taxon_groups.csv と同じ（rank, values）

bold_counts <- function(groups_file, out_dir = "data/raw/bold") {
  dir.create(out_dir, FALSE, TRUE)
  g <- readr::read_csv(groups_file, col_types = "cccc")
  purrr::pmap(g, function(group_id, variant, rank, values) {
    q <- paste0("tax:", rank, ":", strsplit(values, ";")[[1]], collapse = ";")
    u <- paste0("https://portal.boldsystems.org/api/counts?query=", utils::URLencode(q, reserved = TRUE))
    js <- jsonlite::fromJSON(u)
    # 採集年月の分布（年別集計用）。生の応答を保存
    us <- paste0("https://portal.boldsystems.org/api/summary?query=", utils::URLencode(q, reserved = TRUE),
                 "&fields=collection_date_start&reduce_operation=count")
    raw <- tryCatch(jsonlite::fromJSON(us), error = function(e) NULL)
    jsonlite::write_json(raw, file.path(out_dir, paste0(group_id, "__", variant, "_dates.json")), auto_unbox = TRUE)
    tibble::tibble(group_id, variant, query = q, bold_records = js$records, retrieved = Sys.time())
  }) |> purrr::list_rbind()
}

bold_by_year <- function(bold_tbl, out_dir = "data/raw/bold") {
  purrr::pmap(bold_tbl[c("group_id", "variant")], function(group_id, variant) {
    x <- jsonlite::fromJSON(file.path(out_dir, paste0(group_id, "__", variant, "_dates.json")))$collection_date_start
    if (is.null(x)) return(NULL)
    tibble::tibble(group_id, variant, ym = names(x), n = unlist(x)) |>
      dplyr::mutate(year = suppressWarnings(as.integer(substr(ym, 1, 4)))) |>
      dplyr::group_by(group_id, variant, year) |> dplyr::summarise(n = sum(n), .groups = "drop")
  }) |> purrr::list_rbind()
}

ncbi_get <- function(url) { Sys.sleep(0.4); jsonlite::fromJSON(url) }  # 鍵なしは 3 req/s まで

ncbi_counts <- function(groups_file) {
  g <- readr::read_csv(groups_file, col_types = "cccc")
  base <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?retmode=json&"
  purrr::pmap(g, function(group_id, variant, rank, values) {
    v <- strsplit(values, ";")[[1]]
    tax <- purrr::map_chr(v, function(nm) {
      js <- ncbi_get(paste0(base, "db=taxonomy&term=", utils::URLencode(paste0('"', nm, '"[Scientific Name]'), reserved = TRUE)))
      ids <- js$esearchresult$idlist
      if (length(ids) == 1) ids else NA_character_   # 0件・複数件は NA（同名異物を避ける）
    })
    term <- paste0("txid", tax, "[Organism:exp]", collapse = " OR ")
    n <- if (anyNA(tax)) NA_integer_ else
      as.integer(ncbi_get(paste0(base, "db=nuccore&rettype=count&term=", utils::URLencode(term, reserved = TRUE)))$esearchresult$count)
    tibble::tibble(group_id, variant, taxids = paste(tax, collapse = ";"), nuccore_records = n, retrieved = Sys.time())
  }) |> purrr::list_rbind()
}
