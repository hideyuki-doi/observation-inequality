# Phase 0: rgbif の認証確認（認証情報は ~/.Renviron。値は表示しない）
library(rgbif)
for (v in c("GBIF_USER", "GBIF_PWD", "GBIF_EMAIL")) cat(v, "set:", nzchar(Sys.getenv(v)), "\n")
cat("occ_count total:", occ_count(), "\n")
dl <- occ_download_list(user = Sys.getenv("GBIF_USER"), limit = 1)
cat("auth OK; past downloads:", dl$meta$count, "\n")
# SQL ダウンロード：構文検証のみ（利用権限は実際の投入時にしか分からない → Phase 2 で確認）
# validate は request 全体（list）を受け取る
req <- list(sendNotification = FALSE, format = jsonlite::unbox("SQL_TSV_ZIP"),
            sql = jsonlite::unbox('SELECT datasetKey, COUNT(*) AS n FROM occurrence WHERE "year" = 2020 GROUP BY datasetKey'))
res2 <- tryCatch(occ_download_sql_validate(q = req), error = function(e) paste("validate error:", conditionMessage(e)))
str(res2)
