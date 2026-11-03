# 改訂（Reviewer 2）：データセット単位と「採集イベント」単位の集計
# 出力1（records）：group × order × family × 種 × 年 × データセット × basisOfRecord の記録数
# 出力2（events）：種 × 年 × データセット × 0.1° セル × 日付 の一意な組（＝種の採集イベント）。KRILLBASE のような個体ごとの記録を 1 件にまとめる
event_groups <- function() {
  meso <- readr::read_csv("docs/taxon_scope_variants.csv", show_col_types = FALSE) |>
    dplyr::filter(rule == "include_family_mesopelagic15") |> dplyr::pull(taxon)
  dplyr::bind_rows(
    dplyr::filter(cell_groups(), group_id != "mesopelagic_fish"),
    tibble::tibble(group_id = "mesopelagic_fish", rank = "family", values = paste(meso, collapse = ";")))
}
aggregate_events_file <- function(f, ds_map, outdir = "data/derived/gbif_events") {
  o1 <- file.path(outdir, "records", paste0(basename(f), ".parquet")); o2 <- file.path(outdir, "events", paste0(basename(f), ".parquet"))
  if (file.exists(o1) && file.exists(o2)) return(invisible("skip"))
  x <- arrow::read_parquet(gbif_bucket()$path(f),
         col_select = c(datasetkey, phylum, class, order, family, species, specieskey, year, eventdate, basisofrecord,
                        decimallatitude, decimallongitude, occurrencestatus)) |>
    dplyr::filter(is.na(occurrencestatus) | occurrencestatus != "ABSENT", !is.na(year), basisofrecord != "FOSSIL_SPECIMEN")
  g <- event_groups(); x$group_id <- NA_character_
  for (i in seq_len(nrow(g))) { v <- strsplit(g$values[i], ";")[[1]]; hit <- is.na(x$group_id) & x[[g$rank[i]]] %in% v; x$group_id[hit] <- g$group_id[i] }
  x <- dplyr::filter(x, !is.na(group_id)) |> dplyr::left_join(ds_map, by = c("datasetkey" = "key")) |> dplyr::mutate(ds_class = dplyr::coalesce(ds_class, "other"))
  r <- x |> dplyr::group_by(group_id, order, family, specieskey, species, year, datasetkey, basisofrecord, ds_class) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop")
  e <- x |> dplyr::filter(!is.na(specieskey), specieskey != "") |>
    dplyr::mutate(cell01 = ifelse(is.na(decimallatitude), "nocoord", paste(floor(decimallatitude * 10), floor(decimallongitude * 10), sep = "_")),
                  date = as.Date(eventdate)) |>
    dplyr::distinct(group_id, family, specieskey, year, datasetkey, ds_class, basisofrecord, cell01, date)
  dir.create(dirname(o1), FALSE, TRUE); dir.create(dirname(o2), FALSE, TRUE)
  arrow::write_parquet(r, paste0(o1, ".tmp")); file.rename(paste0(o1, ".tmp"), o1)
  arrow::write_parquet(e, paste0(o2, ".tmp")); file.rename(paste0(o2, ".tmp"), o2)
  invisible(nrow(x))
}
