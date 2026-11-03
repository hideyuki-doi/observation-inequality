# vert_census: marine mammal species-level N from Greenspoon 2025 (primary) and 2023 (IUCN-text, cross-check)
# Run from project dir: Rscript <this file>
suppressMessages({library(readr); library(readxl); library(dplyr)})
out <- "data/derived/vert_census/"
g23 <- "data/raw/greenspoon2023/mammal_biomass/data/marine_data/"
g25 <- "data/raw/greenspoon2025/mammal_biomass_since_1850/"

## ---------- Greenspoon 2023: replicate marine_mammal_biomass.ipynb sections 2-4 ----------
mc <- read.csv(file.path(g23, "manually_curated_data.csv"), check.names = FALSE, stringsAsFactors = FALSE,
               fileEncoding = "latin1")
nm <- names(mc)
# duplicated column names: 'mature/total/partial' (x2), 'Extracted total population' (x2)
i_type <- which(nm == "mature/total/partial"); i_pop <- which(nm == "Extracted total population")
mc$type0 <- mc[[i_type[1]]]; mc$type1 <- mc[[i_type[2]]]
mc$pop0 <- mc[[i_pop[1]]];   mc$pop1 <- mc[[i_pop[2]]]
mc$Binomial <- paste(mc$Genus, mc$Species); names(mc) <- make.unique(ifelse(is.na(names(mc)) | names(mc)=="", "X", names(mc)))
pop_types <- c(" "="other","mature"="mature","partial"="partial","total"="total","mature "="mature",
  "partial "="partial","*partial"="partial","  "="other","total "="total"," total"="total","Partial"="partial",
  "Partial:  In Russia nursery colonies up to several dozen or hundreds females are known."="partial",
  "unspecified"="other"," mature"="mature")
adj <- function(s) { s2 <- ifelse(s %in% names(pop_types), pop_types[s], s); s2[is.na(s2) | s2 == ""] <- "other"; s2 }
mc$type0 <- adj(mc$type0); mc$type1 <- adj(mc$type1)
clean <- function(v) {
  v <- gsub(",|<|>|~", "", v); v <- gsub("common locally|rare|extinct", "0", v); v <- gsub("*", "0", v, fixed = TRUE)
  v <- sapply(v, function(x) if (!is.na(x) && grepl("-", x)) { p <- as.numeric(strsplit(x, "-")[[1]]); mean(p) } else suppressWarnings(as.numeric(x)))
  v[is.na(v)] <- 0; unname(v)
}
sp <- trimws(read.csv(file.path(g23, "marine_mammal_species.csv"))$Binomial)
m <- mc %>% filter(Binomial %in% sp, `Red List status` != "EX")
m$p0 <- clean(m$pop0); m$p1 <- clean(m$pop1)
m <- m %>% mutate(mature = p0*(type0=="mature") + p1*(type1=="mature"),
                  total  = p0*(type0=="total")  + p1*(type1=="total"),
                  partial= p0*(type0=="partial")+ p1*(type1=="partial"),
                  other  = p0*(type1=="other")  + p1*(type1=="other"))   # replicates notebook (is_other uses .1 twice)
mat <- as.matrix(m[, c("mature","total","partial","other")])
m$population <- apply(mat, 1, max)
m$est_type <- c("mature","total","partial","other")[apply(mat, 1, which.max)]
m$est_type <- ifelse(m$est_type != "other", m$est_type, ifelse(m$total > 0, "total", ifelse(m$mature > 0, "total", "partial")))
g23tab <- m %>% filter(population > 0) %>%
  transmute(species = Binomial, N23 = population, type23 = est_type, RL = `Red List status`,
            yr23 = `Year assessed`, popdetail = substr(`Population details`, 1, 400))
cat("G2023 species with population>0:", nrow(g23tab), " partial:", sum(g23tab$type23 == "partial"), "\n")
top <- read.csv("data/raw/greenspoon2023/mammal_biomass/results/top_10_marine.csv")
chk <- merge(top[, c("Binomial","population_millions")], g23tab, by.x = "Binomial", by.y = "species")
cat("top10 reproduction max abs diff:", max(abs(chk$population_millions*1e6 - chk$N23)), "\n")

## ---------- Greenspoon 2025: 2020 N per species ----------
mi <- read_excel(file.path(g25, "data/wild_marine/model_input.xlsx"), sheet = "params")
cn2sci <- mi %>% distinct(`Common name`, `Scientific name`) %>% filter(!is.na(`Common name`))
bm <- read_excel(file.path(g25, "data/wild_marine/species properties.xlsx"), sheet = "body mass") %>%
  mutate(w_t = `Avg. weight male (t)`*`Male : Female ratio (% OF` + `Avg. weight female (t)`*(1-`Male : Female ratio (% OF`))
files <- list.files(file.path(g25, "results/marine_model_results/biomass"), full.names = TRUE)
pops <- lapply(files, function(f) {
  x <- read.csv(f, check.names = FALSE); rownames(x) <- as.character(x[[1]])
  base <- sub("\\.csv$", "", basename(f)); cn <- gsub("_", " ", sub("__.*$", "", base)); reg <- sub("^.*__", "", base)
  yr <- "2020"
  data.frame(file = basename(f), common = cn, region = reg,
             B_lo = x["0.025", yr], B_med = x["0.5", yr], B_hi = x["0.975", yr])
}) %>% bind_rows()
# map common -> scientific (case-insensitive)
key <- function(s) tolower(gsub("[^a-z]", "", tolower(s)))
cn2sci$k <- key(cn2sci$`Common name`); bm$k <- key(bm$`Common name`)
pops$k <- key(pops$common)
# map by (common name, region) because 'Right whale' and 'Bottlenose dolphin' map to >1 scientific name
cr <- mi %>% distinct(`Common name`, Region, `Scientific name`) %>% filter(!is.na(`Common name`)) %>%
  mutate(Region = ifelse(is.na(Region), "NA", Region), kr = paste(key(`Common name`), key(Region)))
pops$kr <- paste(pops$k, key(pops$region))
pops$sci_model <- cr$`Scientific name`[match(pops$kr, cr$kr)]
cat("pops unmatched by common+region:", sum(is.na(pops$sci_model)), "\n"); print(pops$file[is.na(pops$sci_model)])
pops$sci_model[pops$file == "Sperm_whale__G.csv"] <- "Physeter macrocephalus"
pops$sci_model[pops$file == "Bearded_seal__Bering___Chukchi_Sea.csv"] <- "Erignathus barbatus"  # region string mismatch only
# mass exactly as the model used it (merge on model_input scientific name)
pops$w_t <- bm$w_t[match(pops$sci_model, bm$`Scientific name`)]
pops$sci <- pops$sci_model
pops$sci[pops$sci == "Globicephaia melas"] <- "Globicephala melas"          # typo in source
pops$sci[pops$file == "Bottlenose_dolphin__NWA.csv"] <- "Tursiops truncatus" # source maps NWA bottlenose dolphin to Hyperoodon ampullatus
pops <- pops %>% mutate(N_lo = B_lo / w_t, N_med = B_med / w_t, N_hi = B_hi / w_t, src = "model")
cat("unmapped pops:", sum(is.na(pops$sci)), " no mass:", sum(is.na(pops$w_t)), "\n")
print(pops[is.na(pops$sci) | is.na(pops$w_t), c("file","common")]); write.csv(pops, file.path(out, "g2025_model_pops_debug.csv"), row.names=FALSE)

ux <- read_excel(file.path(g25, "data/wild_marine/unexploited_populations.xlsx"))
ux$k <- key(ux$`Common name`)
ux$sci <- bm$`Scientific name`[match(ux$k, bm$k)]
ux$sci[is.na(ux$sci)] <- cn2sci$`Scientific name`[match(ux$k[is.na(ux$sci)], cn2sci$k)]
cat("unexploited unmapped:", sum(is.na(ux$sci)), "\n"); print(ux[is.na(ux$sci), 1:2])
uxp <- ux %>% transmute(file = "unexploited_populations.xlsx", common = `Common name`, region = `Fraction of range`,
                        sci, N_lo = min, N_med = mean, N_hi = max, src = paste0("unexploited:", `Fraction of range`))
allp <- bind_rows(pops %>% select(file, common, region, sci, N_lo, N_med, N_hi, src), uxp)
write.csv(allp, file.path(out, "g2025_marine_populations_2020.csv"), row.names = FALSE)
g25tab <- allp %>% filter(!is.na(sci)) %>% group_by(sci) %>%
  summarise(N25 = sum(N_med), N25lo = sum(N_lo), N25hi = sum(N_hi), npop = n(),
            nmodel = sum(src == "model"), comps = paste0(src, "[", common, "|", region, "]", collapse = "; "),
            entire = any(src == "unexploited:entire"), rest = any(src == "unexploited:rest"), .groups = "drop")
cat("G2025 species:", nrow(g25tab), "\n")
write.csv(g25tab, file.path(out, "g2025_species.csv"), row.names = FALSE)
write.csv(g23tab, file.path(out, "g2023_species.csv"), row.names = FALSE)
write.csv(bm %>% select(`Scientific name`, `Common name`, w_t), file.path(out, "g2025_mass.csv"), row.names = FALSE)
