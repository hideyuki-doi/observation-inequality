suppressMessages({library(readr);library(dplyr);library(readxl);library(arrow)})
d <- read_csv("data/raw/lpd/rlpi_example/LPI_LPR2016data_public.csv", col_types=cols(.default="c"), na=character()) |>
  mutate(name = gsub("_"," ",Binomial))
cb <- read_csv("data/raw/combine/trait_data_reported.csv", show_col_types=FALSE, guess_max=1e5)
cat("COMBINE rows",nrow(cb),"; has cols:", all(c("iucn2020_binomial","adult_mass_g") %in% names(cb)),"\n")
av <- read_excel("data/raw/avonet/AVONET_Supplementary_dataset_1.xlsx", sheet="AVONET1_BirdLife")
cat("AVONET rows",nrow(av),"; cols:", all(c("Species1","Mass") %in% names(av)),"\n")
fb <- read_parquet("data/raw/fishbase/v25.04/species.parquet")
cat("FishBase species rows",nrow(fb),"\n"); print(intersect(names(fb), c("SpecCode","Genus","Species","Weight","Length","LTypeMaxM","CommonLength")))
fb <- fb |> mutate(name=paste(Genus,Species))
am <- read_csv("data/raw/amphibio/extracted/AmphiBIO_v1.csv", show_col_types=FALSE, guess_max=1e5)
cat("AmphiBIO rows",nrow(am),"; Body_mass_g non-NA",sum(!is.na(am$Body_mass_g)),"; mass==size(mm)",sum(am$Body_mass_g==am$Body_size_mm,na.rm=TRUE),"\n")
src <- list(
  Mammalia = cb |> transmute(name=iucn2020_binomial, mass=adult_mass_g),
  Aves     = av |> transmute(name=Species1, mass=Mass),
  Fish     = fb |> transmute(name, mass=Weight),
  Amphibia = am |> transmute(name=Species, mass=Body_mass_g))
fishcl <- c("Actinopterygii","Elasmobranchii","Holocephali","Myxini","Sarcopterygii","Cephalaspidomorphi","Chondrichthyes")
d$grp <- ifelse(d$Class %in% fishcl, "Fish", d$Class)
out <- list()
for (g in names(src)) {
  s <- src[[g]]; nm_any <- unique(s$name); nm_mass <- unique(s$name[!is.na(s$mass)])
  x <- d |> filter(grp==g)
  sp <- unique(x$name)
  out[[g]] <- data.frame(group=g, lpd_species=length(sp), sp_name_match=sum(sp %in% nm_any), sp_mass_match=sum(sp %in% nm_mass),
    lpd_pops=nrow(x), pop_name_match=sum(x$name %in% nm_any), pop_mass_match=sum(x$name %in% nm_mass))
}
r <- bind_rows(out) |> mutate(sp_mass_pct=round(100*sp_mass_match/lpd_species,1), pop_mass_pct=round(100*pop_mass_match/lpd_pops,1), sp_name_pct=round(100*sp_name_match/lpd_species,1))
print(r)
# fish by class
x <- d |> filter(grp=="Fish"); nm <- unique(fb$name[!is.na(fb$Weight)])
print(x |> group_by(Class) |> summarise(species=n_distinct(name), sp_mass=n_distinct(name[name %in% nm]), sp_name=n_distinct(name[name %in% fb$name])))
cat("Reptilia: no source obtained; species",n_distinct(d$name[d$Class=="Reptilia"]),"pops",sum(d$Class=="Reptilia"),"\n")
