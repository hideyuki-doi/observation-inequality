# 使い方: Rscript scripts/phase2_worker.R <worker_id> <n_workers>
args <- as.integer(commandArgs(TRUE)); k <- args[1]; K <- args[2]
source("R/gbif.R")
arrow::set_cpu_count(2); arrow::set_io_thread_count(4)
ds_map <- readr::read_csv("data/raw/gbif_api/dataset_classes.csv", col_types = "c__c") 
files <- readRDS("data/derived/gbif_agg/file_list.rds")
mine <- files[seq_along(files) %% K == k]
if (nzchar(Sys.getenv("REVERSE"))) mine <- rev(mine)  # 追加ワーカー用：後ろから処理（済みは飛ばす）
for (f in mine) {
  for (try in 1:4) {
    ok <- tryCatch({ aggregate_snapshot_file(f, ds_map); TRUE },
                   error = function(e) { message(Sys.time(), " ", f, " try ", try, ": ", conditionMessage(e)); FALSE })
    if (ok) break
    Sys.sleep(2^try)
  }
}
message(Sys.time(), " worker ", k, " done")
