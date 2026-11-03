# 改訂（Reviewer 2）：DNA 拡張つきデータセットの中身を分類する（タイトルと説明を GBIF API から取得して保存）
source("sim/explore_common.R")
r <- arrow::open_dataset("data/derived/gbif_events/records") |> filter(year >= 2000, year <= 2024, ds_class == "dna_ext") |>
  group_by(datasetkey) |> summarise(n = sum(n)) |> collect() |> arrange(desc(n))
cache <- "data/raw/gbif_api/dna_dataset_meta.csv"
old <- if (file.exists(cache)) readr::read_csv(cache, show_col_types = FALSE) else tibble(datasetkey = character())
todo <- setdiff(r$datasetkey, old$datasetkey)
new <- purrr::map(todo, function(k) { js <- tryCatch(jsonlite::fromJSON(paste0("https://api.gbif.org/v1/dataset/", k)), error = function(e) NULL)
  tibble(datasetkey = k, title = js$title %||% NA_character_, publisher = js$publishingOrganizationKey %||% NA_character_,
         description = substr(gsub("\\s+", " ", js$description %||% ""), 1, 400)) }) |> bind_rows()
meta <- bind_rows(old, new); readr::write_csv(meta, cache)
# 分類規則：タイトル・説明に BOLD / Barcode of Life / iBOL / BIN を含むものは「標本バーコード」、それ以外は「メタバーコーディング・環境 DNA など」
meta <- meta |> mutate(dna_type = ifelse(grepl("BOLD|Barcode of Life|iBOL|barcode index|BIN", paste(title, description), ignore.case = FALSE), "barcode_specimen", "metabarcoding_other"))
readr::write_csv(meta, "data/derived/dna_dataset_types.csv")
x <- left_join(r, meta, by = "datasetkey")
print(x |> group_by(dna_type) |> summarise(datasets = n(), records = sum(n)))
print(head(select(x, n, dna_type, title), 15))
