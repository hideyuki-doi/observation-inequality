# Build docs/provenance_parts/vert_census.csv (run from project dir)
# 1) Rscript scripts/vert_census/marine.R ; 2) marine_assemble.R ; 3) ram_fish.R
# terrestrial.csv and iwc.csv in data/derived/vert_census/ were hand-curated from saved raw files
# (data/raw/{chase2016_gec,aesr2016,rhino_cop20,regehr2016_polarbear,iwc}); see vert_census.md.
d <- "data/derived/vert_census/"
cols <- c("species","class","N_est","N_lo","N_hi","interval_type","year_of_estimate","scope","method_class",
          "method_evidence","citation","doi_or_url","location_in_source","mass_g","mass_source","verified","notes")
rd <- function(f) { x <- read.csv(file.path(d, f), stringsAsFactors = FALSE, check.names = FALSE, colClasses = "character"); stopifnot(identical(names(x), cols)); x }
mm <- rd("marine_mammals.csv"); te <- rd("terrestrial.csv"); fi <- rd("fish.csv")
fi$notes <- paste0("STOCK-LEVEL row (species-population), not a species total; ", fi$notes)
all <- rbind(mm, te, fi)
write.csv(all, "docs/provenance_parts/vert_census.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
iw <- rd("iwc.csv")
write.csv(iw, "docs/provenance_parts/vert_census_iwc_populations.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
cat("vert_census rows:", nrow(all), "\n"); print(table(all$class, all$method_class))
