# 探索的（2）：占有ベースの比較用に、主10グループ＋哺乳類の記録を 種 × 1° セル × 年 で集計し直す
cell_groups <- function() tibble::tribble(
  ~group_id, ~rank, ~values,
  "soil_nematodes", "phylum", "Nematoda",
  "springtails", "class", "Collembola",
  "mites", "order", "Sarcoptiformes;Mesostigmata;Trombidiformes",
  "ants", "family", "Formicidae",
  "enchytraeids", "family", "Enchytraeidae",
  "copepods", "class", "Copepoda",
  "pteropods", "order", "Pteropoda",
  "jellyfish", "class", "Scyphozoa;Cubozoa",
  "mesopelagic_fish", "family", "Myctophidae",
  "krill", "species", "Euphausia superba",
  "mammals", "class", "Mammalia")

aggregate_cells_file <- function(f, ds_map, outdir = "data/derived/gbif_cells/parts") {
  out <- file.path(outdir, paste0(basename(f), ".parquet"))
  if (file.exists(out)) return(invisible("skip"))
  x <- arrow::read_parquet(gbif_bucket()$path(f),
         col_select = c(datasetkey, phylum, class, order, family, species, specieskey, year, basisofrecord,
                        decimallatitude, decimallongitude, occurrencestatus)) |>
    dplyr::filter(is.na(occurrencestatus) | occurrencestatus != "ABSENT", !is.na(decimallatitude), !is.na(decimallongitude),
                  !is.na(specieskey), specieskey != "", !is.na(year), basisofrecord != "FOSSIL_SPECIMEN")
  g <- cell_groups()
  x$group_id <- NA_character_
  for (i in seq_len(nrow(g))) {
    v <- strsplit(g$values[i], ";")[[1]]
    hit <- is.na(x$group_id) & x[[g$rank[i]]] %in% v
    x$group_id[hit] <- g$group_id[i]
  }
  x <- x |> dplyr::filter(!is.na(group_id)) |> dplyr::left_join(ds_map, by = c("datasetkey" = "key")) |>
    dplyr::mutate(ds_class = dplyr::coalesce(ds_class, "other"),
                  cell = paste(floor(decimallatitude), floor(decimallongitude), sep = "_")) |>
    dplyr::group_by(group_id, specieskey, species, year, cell, ds_class) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop")
  dir.create(outdir, FALSE, TRUE)
  arrow::write_parquet(x, paste0(out, ".tmp")); file.rename(paste0(out, ".tmp"), out)
  invisible(nrow(x))
}
