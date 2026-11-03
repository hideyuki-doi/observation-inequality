# Provenance notes — id `lpd` (Living Planet Database + body-mass sources, for Phase 6 「指標の重み」)

Written 2026-11-03. Everything below was read from files or HTTP responses retrieved on this date. Nothing was filled in from memory. Items I could not check are marked **未確認**. I computed no trends.

## 1. Living Planet Database (LPD)

### 1a. Current public release: download gated by a form, so NOT downloaded

* Portal: https://www.livingplanetindex.org/data_portal (HTTP 200, fetched 2026-11-03). Page text, verbatim:
  > "This dataset contains time-series of population abundance data for vertebrate species spanning years between 1970 and 2022. This is the public version of the database as confidential records that cannot be shared have been removed."
  > "In order to download the data, please give us a short description of how you plan to use the data and agree to the data-use agreement below Your name Your email address How do you plan to use the data? Please tick the box below to agree to our data-use policy"
* The portal is a Shiny app. The download sits behind a form that asks for name, email and intended use, plus an "Agree" tick box. **I did not submit the form or try to get around it.**
* Version: the Data Use Policy names the citation as "ZSL/WWF 2026. Living Planet Database 2026.1". The FAQ says "The most recent report was released in October 2026" and that "The LPD contains more than 35,803 population records of 5790 species". These counts describe the whole LPD, not necessarily the public subset. The exact population and species counts of the public 2026.1 file are **未確認** because I did not download it.
* Licence and terms: `data/raw/lpd/LPI_Data_Use_Policy_2026.pdf` (sha256 `96d94abc8138569735ba60db9ec1732c69854712ad6a5c440e7c3605e0d10ea8`). This is a bespoke licence, not Creative Commons. Key terms, verbatim:
  * "1. The Data are supplied for conservation purposes, scientific analysis or research only."
  * "2. … The preferred citation format … is: 'ZSL/WWF 2026. Living Planet Database 2026.1 <www.livingplanetindex.org/data_portal>. Downloaded on MM/DD/YYYY'. For any publications making substantial use of the Data, ZSL and WWF welcome the opportunity for co-authorship…"
  * "4. The user will not pass any Data on to third parties…"
  * "5. The user will not publish the Data in their original format, either whole or in part…"
  * "6. The user may only pass on datasets derived from the Data ('Derived Data') if the Derived Data are supplied with these same terms of use."
  * "9. A copy of all products using the Data will be sent electronically to LivingPlanetIndex@ioz.ac.uk"
  * Only the published LPI trends are CC BY-SA 4.0.
* FAQ: `data/raw/lpd/FAQs_2026.pdf` (sha256 `0c597bc77da268b7425eb906fb20fa84300812ef31735309571e4dfd44ed5fe7`).

**What the human must do:** open https://www.livingplanetindex.org/data_portal in a browser and enter name, email and a short use description, for example "Phase 6 of a research project: compare the body-size composition of LPD species with abundance/biomass censuses; non-commercial research". Then tick "Agree", click Download, and put the file unchanged in `data/raw/lpd/` with the download date. That date is needed for the citation. Consequences of the terms for this project:
* the raw file and any derived per-population table must not go into a public repo or supplement (terms 4–6). `data/` is already gitignored.
* the final products must be sent to LivingPlanetIndex@ioz.ac.uk (term 9).
* because use is "substantial", ZSL/WWF ask to be contacted about co-authorship.

### 1b. Old public release that is directly downloadable (used here only for the counts and match rates below)

* Source: the GitHub repo `Zoological-Society-of-London/rlpi` (linked from the data portal), file `inst/extdata/example_data/LPI_LPR2016data_public.csv`, commit `bfa317723cd2c5cf4ab36b27524535a11d50dd3f` (2026-05-04). URL: https://raw.githubusercontent.com/Zoological-Society-of-London/rlpi/bfa317723cd2c5cf4ab36b27524535a11d50dd3f/inst/extdata/example_data/LPI_LPR2016data_public.csv
* Local copy: `data/raw/lpd/rlpi_example/LPI_LPR2016data_public.csv`, 8,148,031 bytes (the size matches the GitHub tree), sha256 `29a9c5ba9b8c54a35f151fe8791310ecc7242059f25cda893e468a9f8caf471a`. I also saved the repo's `README.md` and `DESCRIPTION` alongside it.
* Licence: the repo has no licence file (GitHub API `license: null`). The package DESCRIPTION says `License: GPL-2`, which covers the code. I found no statement about the bundled data. I treat it as falling under the LPI Data Use Policy above. That is my assumption and is **未確認**.
* Version: the file name says it is the LPR 2016 public dataset. Year columns run 1950–2017. **It is NOT the current release.** Use it only for planning.

**Columns (28 metadata columns, then one column per year 1950…2017):** ID, Binomial, Reference, Class, Order, Family, Genus, Species, Subspecies, Authority, Common_name, Location, Country, All_countries, Region, Latitude, Longitude, Specific_location, System, T_realm, T_biome, FW_realm, FW_biome, M_realm, M_ocean, M_biome, Units, Method. Missing values are coded as the string `NULL`. In every row `Binomial` equals `Genus_Species`, and every Binomial has exactly one `_`.

**Counts (LPR2016 public file):** 11,067 populations (unique ID), 3,456 species (unique Binomial). By System: Terrestrial 4,085, Marine 3,781, Freshwater 3,201 populations.

| Class | populations | species |
|---|---|---|
| Aves | 4,833 | 1,367 |
| Actinopterygii | 2,854 | 1,101 |
| Mammalia | 2,228 | 529 |
| Reptilia | 540 | 193 |
| Amphibia | 429 | 174 |
| Elasmobranchii | 169 | 83 |
| Holocephali | 4 | 3 |
| Myxini | 4 | 2 |
| Sarcopterygii | 4 | 2 |
| Cephalaspidomorphi | 1 | 1 |
| Chondrichthyes | 1 | 1 |

There is one row labelled Chondrichthyes, which is separate from the Elasmobranchii rows. This is how the source labels it. The counts by System × Class were also computed (script: see §4); they are not reproduced here.

## 2. Body-mass sources

| Taxon | Source | Status | Local path | Version / DOI | Licence | Checksum |
|---|---|---|---|---|---|---|
| Mammals | COMBINE (already in project) | present | `data/raw/combine/trait_data_reported.csv` (`iucn2020_binomial`, `adult_mass_g`; 6,263 rows) | see existing provenance | see existing provenance | — |
| Birds | AVONET (already in project) | present | `data/raw/avonet/AVONET_Supplementary_dataset_1.xlsx`, sheet `AVONET1_BirdLife` (`Species1`, `Mass`; 11,009 rows) | see existing provenance | see existing provenance | — |
| Fishes | FishBase backend snapshot used by rfishbase (HuggingFace `cboettig/fishbase`) | **downloaded** | `data/raw/fishbase/v25.04/{species,synonyms,poplw,estimate}.parquet`, `data/raw/fishbase/HF_README.md` | snapshot v25.04; HF commit `9370f01070e0cc899f5526086c9ff364ddc6a8c0` | CC BY-NC 4.0 (HF card: "CC-BY-NC, FishBase.org Team"; "not licensed for commerical applications") | sha256 species `02bfae69…63e4`, synonyms `9b41035c…ab00`, poplw `26d9411b…fb20`, estimate `b4bafe0a…fcf7`. All four match the HF LFS oids. |
| Amphibians | AmphiBIO v1 (Oliveira et al. 2017 Sci Data, doi:10.1038/sdata.2017.123) | **downloaded** | `data/raw/amphibio/AmphiBIO_v1.zip`, unzipped copy in `extracted/` | figshare doi:10.6084/m9.figshare.4644424.v5 (published 2017-07-06) | CC BY 4.0 (figshare API) | md5 `3d2c8f3371516209f190fc842f26e32b` (matches figshare `computed_md5`); sha256 `15185ffe…4bc4626` |
| Squamates | SquamBase 1.0 (Meiri 2024 GEB, doi:10.1111/geb.13812) | **未確認 / blocked** | — | Dryad doi:10.5061/dryad.76hdr7t3b, version 5, 2024-01-31 | CC0 (Dryad API metadata) | Dryad lists S1 sha256 `e850eb80…12af` |
| Reptiles (all orders) | Slavenko et al. 2016 GEB "Late Quaternary reptile extinctions: size matters, insularity dominates" (doi:10.1111/geb.12491, from Crossref) | **未確認 / blocked** | — | Wiley SI | unknown | — |
| Squamates | Feldman et al. 2016 GEB "Body sizes and diversification rates of lizards, snakes, amphisbaenians and the tuatara" (doi:10.1111/geb.12398, Crossref issued 2015-12) | **未確認 / blocked** | — | Wiley SI | unknown | — |

Full checksums (sha256):
```
02bfae694deed266250e58ecebf4b10af595178944c431612e865cb37dc563e4  fishbase/v25.04/species.parquet
9b41035cd24897fdb87e150027744c6179612595a289fbdbad0f90d82315ab00  fishbase/v25.04/synonyms.parquet
26d9411b1fd8bec76d68a634bb8060b4301b1c02e7688681fcf707d8be46cfb1  fishbase/v25.04/poplw.parquet
b4bafe0a816631df4228e92e191b10289bd955b398c5b32c6205bebedb2396bc  fishbase/v25.04/estimate.parquet
ee1088efa629eb16a7305031f97856c2ea1a75796d7e8a42749ba4e3d5c2b7fe  fishbase/HF_README.md
15185ffec078423ff7b99d1f16d4daa351a5a8861dd27e5574d05f9a58bc4626  amphibio/AmphiBIO_v1.zip
```

What I tried for each source, and notes:
* **FishBase:** the rfishbase package is not installed, and I did not install it, per the instructions. `fishbase.ropensci.org` failed its SSL check (self-signed certificate), and I did not bypass that. `www.fishbase.se` returns HTTP 200. I downloaded the parquet tables that rfishbase reads directly from HuggingFace. The mass column is `Weight` in `species`. My understanding is that it holds a maximum reported weight rather than a typical adult mass, but I did not check the FishBase field definition (**未確認**). This needs settling before fish masses are compared with COMBINE or AVONET means. `poplw` holds length–weight parameters. Using it to fill in missing masses would create allometry-derived values, which must be flagged under CLAUDE.md §2-3.
* **AmphiBIO:** 591 of 6,776 species have a non-NA `Body_mass_g`. In 8 rows `Body_mass_g` equals `Body_size_mm` exactly (for example *Allophryne ruthveni*: 31 and 31). This may or may not be a data-entry artefact; I have not checked it against `Metadata.pdf` (**未確認**). Crossref also lists the "Amphibian traits database" (GEB, doi:10.1111/geb.13656). I did not check whether it has mass or how to download it (**未確認**).
* **SquamBase:** the Dryad API file download returns HTTP 401 ("Unauthorized, must have current bearer token"). The web `downloads/file_stream` link returns HTTP 403. I did not get a token or try any other way in. **Human:** download the 5 files by hand from https://doi.org/10.5061/dryad.76hdr7t3b into `data/raw/squambase/` and check them against the Dryad sha256 values. The README is `c4b57bb9…c6c6b` and S1 is `e850eb807240e1012d0af3e5f2c33a84dab406d50e86a8e3dc591f51a64912af`. Note that the dataset includes "Supplementary_Table_S4 - length_mass_allometric_equations", so some SquamBase masses may be allometry-derived. Check S3 (the trait metadata) for this.
* **Slavenko 2016 and Feldman 2016:** Wiley returns HTTP 403 for the article pages and for `downloadSupplement`. Europe PMC has no record of either article. I did not check Dryad for a deposited copy beyond a single search that returned no match. **Human:** download the SI by hand from Wiley. Slavenko 2016 is the source that covers turtles and crocodilians as well as squamates. Even with SquamBase, turtles and crocodiles stay uncovered without it.

## 3. Exact-name match rates: LPR2016 public file × mass sources

Method: take `Binomial`, replace `_` with a space, and require an exact string match to the source's name column. I did no synonym resolution and no case folding. FishBase name = `paste(Genus, Species)` from `species.parquet`. "Fish" covers Actinopterygii, Elasmobranchii, Holocephali, Myxini, Sarcopterygii, Cephalaspidomorphi and Chondrichthyes. "Name match" = the name exists in the source. "Mass match" = the name exists and the mass column is non-NA.

| Group | LPD species | name match | mass match (sp) | LPD pops | mass match (pops) |
|---|---|---|---|---|---|
| Mammalia (COMBINE reported) | 529 | 487 (92.1%) | 487 (92.1%) | 2,228 | 2,096 (94.1%) |
| Aves (AVONET BirdLife) | 1,367 | 1,270 (92.9%) | 1,270 (92.9%) | 4,833 | 4,671 (96.6%) |
| Fish (FishBase v25.04 `Weight`) | 1,193 | 1,110 (93.0%) | 500 (41.9%) | 3,037 | 1,703 (56.1%) |
| Amphibia (AmphiBIO `Body_mass_g`) | 174 | 172 (98.9%) | 75 (43.1%) | 429 | 240 (55.9%) |
| Reptilia | 193 | — no source obtained — | — | 540 | — |

Fish species by class (species / mass match / name match): Actinopterygii 1101/452/1025; Elasmobranchii 83/44/76; Holocephali 3/1/3; Myxini 2/0/2; Sarcopterygii 2/2/2; Cephalaspidomorphi 1/1/1; Chondrichthyes 1/0/1.

For fishes and amphibians, name matching is not the problem (93–99%). Coverage of the mass field is the bottleneck (about 42–43% of species). These rates are for the 2016 release. The rates for the 2026.1 release are **未確認** until the human downloads it.

## 4. Scripts

These were run from the project root with `Rscript`, using the renv packages readr, dplyr, readxl and arrow. The scripts are kept in the session scratchpad, not in the repo: `lpd_summary.R` (counts) and `lpd_match.R` (match rates). readxl gave "Expecting numeric in column A" warnings while reading the AVONET sheet. They concern column A only and do not affect `Species1` or `Mass`.
