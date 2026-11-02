# Phase 2: GBIF 記録数の集計（公開スナップショット Parquet + API）

gbif_snapshot <- "occurrence/2026-11-01/occurrence.parquet"
# ミラーは環境変数 GBIF_REGION で選ぶ（既定 us-east-1。日本からは ap-southeast-2 も同等の速度）
gbif_bucket <- function(region = Sys.getenv("GBIF_REGION", "us-east-1"))
  arrow::s3_bucket(paste0("gbif-open-data-", region), region = region, anonymous = TRUE)

# API のファセットを全件ページングで取る
gbif_facet_all <- function(query, facet = "datasetKey", page = 1000) {
  out <- list(); off <- 0
  repeat {
    url <- paste0("https://api.gbif.org/v1/occurrence/search?limit=0&facet=", facet,
                  "&facetLimit=", page, "&facetOffset=", off, "&", query)
    js <- jsonlite::fromJSON(url)
    cnt <- js$facets$counts[[1]]
    if (is.null(cnt) || NROW(cnt) == 0) break
    out[[length(out) + 1]] <- cnt
    if (NROW(cnt) < page) break
    off <- off + page
  }
  dplyr::bind_rows(out) |> dplyr::rename(key = name, n = count)
}

# データセットの区分表：DNA 拡張つき / eBird / iNaturalist
dataset_classes <- function(out = "data/raw/gbif_api/dataset_classes.csv") {
  dna <- gbif_facet_all("dwcaExtension=http://rs.gbif.org/terms/1.0/DNADerivedData")
  tot <- gbif_facet_all("") # 全データセットの総記録数
  special <- c(ebird = "4fa7b334-ce0d-4e88-aaae-2e0c138d049e", inat = "50c9509d-22c7-4a22-a47d-8c48425ef4a7")
  titles <- vapply(special, \(k) jsonlite::fromJSON(paste0("https://api.gbif.org/v1/dataset/", k))$title, "")
  d <- tot |> dplyr::rename(n_total = n) |>
    dplyr::left_join(dplyr::rename(dna, n_dna_ext = n), by = "key") |>
    dplyr::mutate(n_dna_ext = dplyr::coalesce(n_dna_ext, 0L),
                  ds_class = dplyr::case_when(key == special["ebird"] ~ "ebird",
                                              key == special["inat"] ~ "inat",
                                              n_dna_ext > 0 ~ "dna_ext", TRUE ~ "other"))
  attr(d, "titles") <- titles
  readr::write_csv(d, out)
  message("special dataset titles: ", paste(names(titles), titles, sep = "=", collapse = "; "))
  d
}

# 1ファイルを集計して2種類の部分表を書く
aggregate_snapshot_file <- function(f, ds_map, outdir = "data/derived/gbif_agg") {
  id <- basename(f)
  fa <- file.path(outdir, "parts_taxon", paste0(id, ".parquet"))
  fb <- file.path(outdir, "parts_dataset", paste0(id, ".parquet"))
  if (file.exists(fa) && file.exists(fb)) return(invisible("skip"))
  x <- arrow::read_parquet(gbif_bucket()$path(f),
         col_select = c(datasetkey, kingdom, phylum, class, order, family, genus, specieskey, species,
                        taxonrank, year, basisofrecord, individualcount, occurrencestatus)) |>
    dplyr::filter(is.na(occurrencestatus) | occurrencestatus != "ABSENT") |>
    dplyr::left_join(ds_map, by = c("datasetkey" = "key")) |>
    dplyr::mutate(ds_class = dplyr::coalesce(ds_class, "other"),
                  ic = dplyr::if_else(!is.na(individualcount) & individualcount > 0, individualcount, NA_integer_))
  a <- x |> dplyr::group_by(kingdom, phylum, class, order, family, genus, specieskey, species, taxonrank,
                            year, basisofrecord, ds_class) |>
    dplyr::summarise(n = dplyr::n(), n_ic = sum(!is.na(ic)), sum_ic = sum(as.numeric(ic), na.rm = TRUE), .groups = "drop")
  b <- x |> dplyr::group_by(datasetkey, kingdom, phylum, class, year, basisofrecord) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop")
  dir.create(dirname(fa), FALSE, TRUE); dir.create(dirname(fb), FALSE, TRUE)
  arrow::write_parquet(a, paste0(fa, ".tmp")); file.rename(paste0(fa, ".tmp"), fa)
  arrow::write_parquet(b, paste0(fb, ".tmp")); file.rename(paste0(fb, ".tmp"), fb)
  invisible(nrow(x))
}
