library(arrow); library(dplyr)
b <- s3_bucket("gbif-open-data-us-east-1", region = "us-east-1", anonymous = TRUE)
p <- "occurrence/2026-11-01/occurrence.parquet"
fs <- b$ls(p); cat(head(fs, 3), sep = "\n")
info <- b$GetFileInfo(fs[1:20]); cat("sizes MB:", round(sapply(info, \(i) i$size)/1e6), "\n")
t0 <- Sys.time()
x <- read_parquet(b$path(fs[1]), col_select = c(specieskey, kingdom, phylum, class, order, family, genus, species,
       year, basisofrecord, datasetkey, individualcount, occurrencestatus, taxonrank), as_data_frame = TRUE)
print(Sys.time() - t0); print(dim(x)); print(count(x, basisofrecord)); print(count(x, occurrencestatus)); print(head(count(x, taxonrank, sort=TRUE)))
