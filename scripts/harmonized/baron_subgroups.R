# Recompute Bar-On et al. 2018 subgroup biomasses and per-individual carbon masses
# from the repository input files (data/raw/baron2018/biomass_distribution), following
# the original notebooks line by line. Output: printed values (used in docs/provenance_parts/harmonized.*)
suppressMessages(library(readxl))
b <- "data/raw/baron2018/biomass_distribution/"
gm <- function(x) exp(mean(log(x)))
frac_mean <- function(f) { a <- f/(1-f); m <- 10^mean(log10(a), na.rm=TRUE); 1/(1+1/m) }
ts1 <- as.data.frame(read_excel(paste0(b,"results.xlsx"),"Table S1", .name_repair="minimal"))
names(ts1)[1:2] <- c("k","g"); Nres <- setNames(ts1[["Number of individuals"]], ts1$g)
out <- list()

## Marine arthropods: mesozooplankton arthropods (copepods) -- marine_arthropods.py cells 2-6, 11
sq <- as.data.frame(read_excel(paste0(b,"animals/arthropods/marine_arthropods/marine_arthropods_data.xlsx"),"de Vargas",skip=1))
fs <- frac_mean(sq[["Arthropod surface"]]/(1-sq[["Rhizaria surface"]]))
fd <- frac_mean(sq[["Arthropod DCM"]]/(1-sq[["Rhizaria DCM"]]))
af <- frac_mean(c(fd,fs))
meso <- gm(c(0.33e15,0.59e15))*af/0.619
cop_c <- 4e-6
out$copepods <- c(B_gC=meso, mass_gC=cop_c, N_recomp=meso/cop_c, N_results=Nres[["Marine arthropods"]], arth_frac=af)

## Annelids: Enchytraeids -- annelids.py cells 2, 12
fi <- as.data.frame(read_excel(paste0(b,"animals/annelids/annelid_biomass_data.xlsx"),"Fierer",skip=1))
ar <- as.data.frame(read_excel(paste0(b,"animals/annelids/annelid_biomass_data.xlsx"),"Biome area",skip=1))
en <- fi[fi$Taxon=="Enchytraeids",]
A <- ar[["Area [m^2]"]][match(en$Biome, ar$Biome)]
mean_en <- sum(en[["Average biomass density [g C m^-2]"]]*A, na.rm=TRUE)
med_en  <- sum(en[["Median biomass density [g C m^-2]"]]*A, na.rm=TRUE)
ench <- gm(c(mean_en,med_en))
out$enchytraeids <- c(B_gC=ench, B_mean_gC=mean_en, B_median_gC=med_en, mass_gC=25e-6, N_recomp=ench/25e-6, N_results=Nres[["Annelids"]])

## Molluscs: pteropods -- molluscs.py cells 2, 8
pt <- gm(c(0.67e15,0.026e15))
cc <- as.data.frame(read_excel(paste0(b,"animals/molluscs/carbon_content_data.xlsx"),skip=4))
pt_c <- mean(cc[["Biomass (mg/m3)"]],na.rm=TRUE)/mean(cc[["Abundace (ind./m3)"]],na.rm=TRUE)*1e-3
out$pteropods <- c(B_gC=pt, mass_gC=pt_c, N_recomp=pt/pt_c, N_results=Nres[["Molluscs"]], n_rows=nrow(cc))

## Cnidarians: planktonic (jellyfish) -- cnidarians.py cells 2, 22
jb <- 0.04e15
jd <- as.data.frame(read_excel(paste0(b,"animals/cnidarians/carbon_content_data.xls"),"Biometric equations",skip=1))
x <- jd[["mg C ind-1"]]*1e-3
j_c <- gm(c(median(x,na.rm=TRUE),mean(x,na.rm=TRUE)))
out$jellyfish <- c(B_gC=jb, mass_gC=j_c, median_gC=median(x,na.rm=TRUE), mean_gC=mean(x,na.rm=TRUE), n_species=sum(!is.na(x)), N_recomp=jb/j_c, N_results=Nres[["Cnidarians"]])

## Fish: mesopelagic -- fish_biomass_estimate.py
sc <- as.data.frame(read_excel(paste0(b,"animals/chordates/fish/fish_biomass_data.xlsx"),"Total scatter",skip=1))
bs <- as.numeric(sc[["Total sA [m^4 nmi^-2]"]])/(4*pi*1852^2)
best_bs <- gm(c(gm(bs),6.02e9))
ts <- as.data.frame(read_excel(paste0(b,"animals/chordates/fish/fish_biomass_data.xlsx"),"Target strength",skip=1))
TS <- tapply(ts[["dB kg^-1"]], ts$Swimbladder, mean, na.rm=TRUE)   # No, Yes (alphabetical as pandas groupby)
sonar <- best_bs/(0.5*10^(TS[["No"]]/10)+0.5*10^(TS[["Yes"]]/10))*1000*0.15
meso_f <- gm(c(sonar,1.5e14))
fe <- as.data.frame(read_excel(paste0(b,"animals/chordates/fish/fish_biomass_data.xlsx"),"Fock & Ehrich",skip=1))
my <- fe[fe$Family=="Myctophidae",]
L <- mean(c(as.numeric(my[["Maximum length (mm)"]]),as.numeric(my[["Minimum length (mm)"]])))  # np.mean over list -> scalar
W <- my[["a(SL)"]]*(L/10)^my[["b(SL)"]]
fish_c <- gm(as.numeric(W))*0.15
out$mesopelagic_fish <- c(B_gC=meso_f, sonar_gC=sonar, trawl_gC=1.5e14, mass_gC=fish_c, mass_wet_g=gm(as.numeric(W)), mean_len_mm=L, n_species=nrow(my), N_recomp=meso_f/fish_c, N_results=Nres[["Fish"]])

## Nematodes (scope already matched); terrestrial split for reference -- nematodes.py
nf <- as.data.frame(read_excel(paste0(b,"animals/nematodes/nematode_biomass_data.xlsx"),"Fierer",skip=1))
na <- as.data.frame(read_excel(paste0(b,"animals/nematodes/nematode_biomass_data.xlsx"),"Biome area",skip=1))
av <- nf[["Average biomass density [g C m^-2]"]]; md <- nf[["Median biomass density [g C m^-2]"]]
fill <- c("Native tropical savanna","Tropical pastures","Crops")
gav <- gm(av[!is.na(av)]); gmd <- gm(md[!is.na(md)])
dd <- data.frame(Biome=c(nf$Biome, setdiff(fill, nf$Biome)))
dd$av <- c(av, rep(NA, nrow(dd)-length(av))); dd$md <- c(md, rep(NA, nrow(dd)-length(md)))
dd$av[dd$Biome %in% fill] <- gav; dd$md[dd$Biome %in% fill] <- gmd
A2 <- na[["Area [m^2]"]][match(dd$Biome, na$Biome)]
terr <- gm(c(sum(dd$av*A2,na.rm=TRUE), sum(dd$md*A2,na.rm=TRUE)))
out$nematodes <- c(B_terr_gC=terr, B_marine_gC=0.014e15, B_gC=terr+0.014e15, mass_gC=0.05e-6, N_recomp=(terr+0.014e15)/0.05e-6, N_results=Nres[["Nematodes"]], N_terr_derived=terr/0.05e-6, N_marine_derived=0.014e15/0.05e-6, unmatched_biomes=sum(is.na(A2)))
for (n in names(out)) { cat("==", n, "\n"); print(signif(out[[n]], 6)) }
