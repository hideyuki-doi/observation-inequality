# Build stock-level total-abundance-in-numbers rows from RAM Legacy v4.66
# Run from project dir: Rscript <this file>
suppressMessages({library(dplyr); library(readr)})
load("data/raw/ramlegacy/extracted/RAMLDB v4.66/R Data/DBdata[asmt][v4.66].RData")
out_dir <- "data/derived/vert_census/"

v  <- timeseries_values_views
u  <- timeseries_units_views
a  <- timeseries_assessments_views
nt <- timeseries_notes_views
ids <- timeseries_ids_views

tn_stocks <- u$stockid[!is.na(u$TN) & u$TN == "E00"]
cat("stocks with TN in E00 (views):", length(tn_stocks), "\n")
cat("stocks with TN index (views):", sum(!is.na(u$TN) & u$TN == "index"), "\n")

last <- v %>% filter(stockid %in% tn_stocks, !is.na(TN)) %>%
  group_by(stockid) %>% arrange(desc(year)) %>% slice(1) %>% ungroup() %>%
  select(stockid, year, TN, TB, SSB)

meta <- u %>% select(stockid, TB_unit = TB) %>%
  left_join(a %>% select(stockid, TN_assess = TN, TB_assess = TB), by = "stockid") %>%
  left_join(nt %>% select(stockid, TN_note = TN), by = "stockid") %>%
  left_join(ids %>% select(stockid, TB_id = TB), by = "stockid")

st <- stock %>% select(stockid, scientificname, commonname, areaid, region, state)
ar <- area %>% select(areaid, areaname, country)
tx <- taxonomy %>% select(scientificname, classname, FisheryType, taxGroup) %>% distinct(scientificname, .keep_all = TRUE)
asm <- assessment %>% select(assessid, assessyear, assessmethod, assessorid)

d <- last %>% left_join(meta, by = "stockid") %>% left_join(st, by = "stockid") %>%
  left_join(ar, by = "areaid") %>% left_join(tx, by = "scientificname") %>%
  left_join(asm, by = c("TN_assess" = "assessid"))

# Mean mass from TB/TN only if TB is metric tons and from the same assessment
d <- d %>% mutate(
  tbtn_ok = !is.na(TB) & !is.na(TB_unit) & TB_unit == "MT" & !is.na(TB_assess) & TB_assess == TN_assess,
  mass_tbtn_g = ifelse(tbtn_ok & TN > 0, TB * 1e6 / TN, NA_real_))

fb <- arrow::read_parquet("data/raw/fishbase/v25.04/species.parquet") %>%
  mutate(sci = paste(Genus, Species)) %>% select(sci, SpecCode, Weight) %>% distinct(sci, .keep_all = TRUE)
d <- d %>% left_join(fb, by = c("scientificname" = "sci"))

d <- d %>% mutate(
  mass_g = ifelse(!is.na(mass_tbtn_g), mass_tbtn_g, Weight),
  mass_source = case_when(
    !is.na(mass_tbtn_g) ~ sprintf("RAM v4.66 TB/TN same assessment & year (%s, %d): TB %s t / TN %s; stock mean, TB may be exploitable biomass", TN_assess, year, format(TB, digits = 6), format(TN, digits = 6)),
    !is.na(Weight) ~ sprintf("FishBase v25.04 species.Weight (max published weight, NOT mean) SpecCode %d", SpecCode),
    TRUE ~ "未確認 (no TB/TN and no FishBase Weight)"),
  fb_note = ifelse(!is.na(Weight), sprintf("FishBase max weight %s g", format(Weight, digits = 6)), "FishBase Weight NA/no match"))

rows <- d %>% transmute(
  species = scientificname,
  class = classname,
  N_est = TN, N_lo = NA, N_hi = NA, interval_type = "none",
  year_of_estimate = year,
  scope = sprintf("partial: stock %s (%s)", stockid, ifelse(is.na(areaname), areaid, areaname)),
  method_class = "independent (stock assessment)",
  method_evidence = sprintf("RAM TN = 'Total abundance; in numbers' from assessment %s (assessyear %s; method %s; assessor %s); model fitted to catch + survey/index data", TN_assess, assessyear, assessmethod, assessorid),
  citation = "RAM Legacy Stock Assessment Database v4.66 (2024-11-06)",
  doi_or_url = "https://doi.org/10.5281/zenodo.14043031",
  location_in_source = sprintf("R Data/DBdata[asmt][v4.66].RData: timeseries_values_views$TN (units E00 = Individuals), stockid %s, year %d", stockid, year),
  mass_g = mass_g, mass_source = mass_source,
  verified = "yes",
  notes = paste0("stock-level (species-population); region ", region, "; stock state ", state,
                 "; ", FisheryType, "; ", fb_note,
                 ifelse(is.na(TN_note) | TN_note == "", "", paste0("; RAM TN note: ", gsub("[\r\n]+", " ", TN_note)))))

rows <- rows %>% mutate(notes = ifelse(grepl("SALM", location_in_source),
  paste0(notes, "; Pacific salmon stock: RAM gives no TN note; whether TN here is total run/return size or in-river/ocean abundance 未確認; assessment method recorded as 'Unknown'"), notes),
  notes = ifelse(N_est == 0, paste0(notes, "; latest TN value is 0 (check)"), notes))
rows_all <- rows
rows <- rows %>% filter(class %in% c("Actinopterygii", "Elasmobranchii"))
cat("dropped non-vertebrate rows:", nrow(rows_all) - nrow(rows), "\n")
write_csv(rows %>% arrange(class, species, year_of_estimate), paste0(out_dir, "fish.csv"), na = "", quote = "all")

# summaries
print(rows %>% count(class, species) %>% arrange(desc(n)), n=40)
cat("rows:", nrow(rows), "\n")
cat("distinct species:", n_distinct(rows$species), "\n")
print(table(rows$class, useNA = "a"))
print(table(d$FisheryType, useNA = "a"))
cat("species by class:\n"); print(rows %>% distinct(species, class) %>% count(class))
cat("stock state:\n"); print(table(d$state, useNA = "a"))
cat("latest year distribution:\n"); print(summary(d$year)); print(table(cut(d$year, c(1900, 1990, 2000, 2010, 2015, 2020, 2030))))
cat("mass from TB/TN:", sum(!is.na(d$mass_tbtn_g)), " from FishBase:", sum(is.na(d$mass_tbtn_g) & !is.na(d$Weight)), " none:", sum(is.na(d$mass_g)), "\n")
cat("species with >1 TN stock:", sum(table(rows$species) > 1), "\n")
# species where all RAM stocks (current) have TN
allst <- stock %>% filter(state == "Current") %>% count(scientificname, name = "n_all")
tns <- d %>% filter(state == "Current") %>% count(scientificname, name = "n_tn")
cmp <- tns %>% left_join(allst, by = "scientificname")
cat("species (current stocks) where every current RAM stock has TN:", sum(cmp$n_tn == cmp$n_all), "of", nrow(cmp), "\n")
cat("assess methods:\n"); print(sort(table(d$assessmethod), decreasing = TRUE)[1:15])
cat("ratio mass_tbtn/FishBase max (quantiles):\n"); print(quantile(d$mass_tbtn_g / d$Weight, c(0, .1, .5, .9, 1), na.rm = TRUE))
cat("any area 'global'?\n"); print(d$areaname[grepl("global|world|entire", d$areaname, ignore.case = TRUE)])
cat("TN range:\n"); print(summary(d$TN))
cat("non-fish:\n"); print(d %>% filter(!classname %in% c("Actinopterygii", "Elasmobranchii", "Chondrichthyes")) %>% select(stockid, scientificname, classname))
write_csv(cmp, paste0(out_dir, "fish_species_stockcoverage.csv"))
