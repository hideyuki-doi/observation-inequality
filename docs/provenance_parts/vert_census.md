# vert_census: species-level vertebrate N that does not depend on occurrence data (2026-11-03)

Outputs:
* `docs/provenance_parts/vert_census.csv` has 377 rows: 127 marine mammals, 8 terrestrial megafauna rows and 242 fish stock rows.
* `docs/provenance_parts/vert_census_iwc_populations.csv` has 57 IWC population rows. These are a cross-check only and are not added to the main table, because the populations overlap.
* Code is in `scripts/vert_census/` (`marine.R` → `marine_assemble.R` → `ram_fish.R` → `build.R`, run from the project directory). Intermediate files are in `data/derived/vert_census/`.
* All values were read from the original data or text. Nothing was filled in from memory.

## 0. Coverage summary

| Class | Rows | method_class | Scope |
|---|---|---|---|
| Mammalia, marine (Greenspoon 2025 primary, 121 spp.) | 121 | independent 43 / mixed 9 / unclear 69 | Source species totals. For 21 of the independent species, the source has only modelled populations. |
| Mammalia, marine (Greenspoon 2023 IUCN text; species missing from 2025) | 6 | independent 2 (Pusa caspica, P. sibirica) / unclear 4 | 3 of the 6 are partial |
| Mammalia, terrestrial megafauna | 8 rows, 7 spp. | independent 7 rows (incl. polar bear, verified=未確認) / unclear 1 (Sumatran rhino) | GEC elephant is partial (18 countries) |
| Actinopterygii + Elasmobranchii (RAM Legacy TN) | 242 stocks, 30 spp. | independent (stock assessment) | STOCK-LEVEL only. Never global. |
| Aves, seabirds | 0 | — | No open per-species table could be accessed (§5) |

Of the 45 independent marine mammal rows:
* 22 are labelled "global (source species total)".
* 21 are sums of the modelled populations only.
* 2 are IUCN global values (Caspian seal and Baikal seal).

Independent N spans 276 (*Eubalaena glacialis*) to 1.1×10^7 (*Pagophilus groenlandicus*).

## 1. Marine mammals

### 1.1 Source choice

The two Milo-lab compilations already in `data/raw` were used, and no new download was made:

* **Greenspoon et al. 2025, Nat Commun** (doi:10.1038/s41467-025-63888-z). Repo `gitlab.com/milo-lab-public/mammal_biomass_since_1850`, local commit `737cbbbeee8f564d823e2ee851c05132bc46670f`. **This is the primary source.** It is the most recent source and covers every marine mammal species in one framework.
* **Greenspoon et al. 2023, PNAS** (doi:10.1073/pnas.2204892120). Repo `gitlab.com/milo-lab-public/mammal_biomass`, local commit `7dc16868e5962a0c9ab583cc540c943b8f066ca0`. It is used for 6 species that are absent from the 2025 tables, and as a cross-check value in `notes`.

The repos publish biomass, not N. N was **recovered** in one of two ways.

**(a) 2025, exploited populations.**
* Each population's biomass file `results/marine_model_results/biomass/<Common>__<Region>.csv` (rows 0.025/0.5/0.975, column 2020) is divided by the mean mass the source used.
* That mass is `mean_weight_tonnes = male×ratio + female×(1−ratio)` from `data/wild_marine/species properties.xlsx`, merged on the scientific name in `model_input.xlsx`, exactly as in `Wild_marine.ipynb`.
* Source code, `marine_mammal_funcs.py` (`model_output_to_file`), verbatim: `biomass_df = model_output_[years_] * body_mass_`. So biomass ÷ body_mass returns the model's population quantiles exactly.
* The sperm whale file is the Whitehead & Shin 2022 trajectory (last year 2020).

**(b) 2025, unexploited populations.**
* Values are taken directly from `data/wild_marine/unexploited_populations.xlsx` (= Supplementary Data 1; columns mean/min/max; "Fraction of range" = entire/rest).
* The species N is the sum of all populations of that species. This is the same summation the source does in `sum_results`.

**(c) 2023.**
* `marine_mammal_biomass.ipynb` sections 2–4 were re-implemented on `data/marine_data/manually_curated_data.csv`, which is curated from IUCN Red List text.
* The reproduction matches the notebook's printed counts: "98 species with popualtion reports / 72 species with total popualtion reports / 26 species with partial popualtion reports".
* It also matches `results/top_10_marine.csv` exactly (max abs diff 3e-11).

Checksums (sha256):
* `manually_curated_data.csv` 3c2a3053…37e1
* `unexploited_populations.xlsx` cacd5f1a…2805
* `model_input.xlsx` 389ddfe2…0850
* `species properties.xlsx` 7211eaa6…1490
* concatenated `biomass/*.csv` (alphabetical) 95d435ca…90e6
* SI PDF `41467_2025_63888_MOESM1_ESM.pdf` 4cbcad3b…39d2

### 1.2 Verbatim method text

Greenspoon 2025, `Wild_marine.ipynb`, first cell:
> "To estimate the population trajectories of wild marine mammals, we implemented a variant of a logistic model, Stochastic Stock Reduction Analysis (SSRA) following Christensen. ... we used data on the number of individuals caught every year since the onset of industrial hunting, along with observed population sizes, mainly from recent years."

`model_input.xlsx`, sheet "Data sources":
> "We manually collected population abundance estimates for  exploited marine mammal populations for the time period 2000-2020 from multiple data sources, including the International Whaling Commission and IUCN RedList. We added these to data from Christensen*, which curated catch and population abundance data for the same populations until the year 2000."

SI, Supplementary Note 6 (p. 11–12):
> "Due to lack of other available data, for populations that were not hunted commercially we use their current day biomass for the time period 1850-present. Supplementary Data 1 lists the unexploited marine mammal populations and populations of marine and fully aquatic marine mammals for which exploitation was not well-recorded. In cases where the species as a whole is found in this category, the “Fraction of range” column indicates “entire”. In cases where some populations were exploited and others were not, the “Fraction of range” column indicates “rest”. ... For crabeater seals, we used the best current abundance estimate of ≈8 million individuals ... Previous, more speculative, global population estimates ranged between 2-75 million individuals. We therefore set the confidence interval associated with this estimate at these values. For all other populations, we used values curated by Christensen."

(Ref. 44 = Christensen, L. B. *Reconstructing historical abundances of exploited marine mammals at the global scale*, UBC 2006.)

SI 6.1.1 (p. 12):
> "we used a total abundance estimate of ≈200,000 individuals (95%CI 1,000-2,000,000)" (New Zealand fur seal)

SI 6.1.2 (p. 12):
> "we used a total abundance estimate of ≈200,000 individuals (95%CI 100-1,000,000)" (northern elephant seal)

SI 6.2 (p. 12–13):
> "Global Dugong (Dugong dugon) population size is unknown. We used available estimates, arriving at a population of ≈160,000 individuals (≈155,000 individuals around Australia ... ≈6,000 in the Arabian Gulf, ≈1,000 in New Caledonia, ≈300 in East Africa, ≈200 around India, and >50 in Nansei)." ... "we used available global abundance estimates from the IUCN RedList. These include ≈30,000 Amazonian Manatees (Trichechus inunguis), ≈10,000 African Manatees (Trichechus senegalensis) and ≈4,000 West Indian Manatees (Trichechus manatus)."

Greenspoon 2023, `marine_mammal_biomass.ipynb`:
> "Here, we use population reports manually collected from the IUCN red list." ... "** We fixed minor errors in the data for 7 of the top 10 species, data for Balaenoptera acutorostrata was retrieved from IWC population records."

### 1.3 method_class rules (marine)

* **independent**: at least 50% of the species' N comes from SSRA-modelled populations. The model is fitted to catch records and survey abundance points (IWC, NOAA, IUCN, Christensen). It uses no occurrence data, and density is never predicted from body size. The r prior is set per superfamily (Cetaceans 0.04, Pinnipeds 0.12, ...) and is not a function of mass. The same class applies to the source's dedicated survey-based values: crabeater seal (Southwell et al. 2012 / IUCN), the NZ fur seal, the northern elephant seal and the sirenians.
* **mixed**: the species has modelled populations, but most of N comes from "rest" rows curated by Christensen 2006, whose underlying method is 未確認. 9 species.
* **unclear**: 69 species whose N comes only from Supplementary Data 1 "entire" rows (Christensen 2006 compilation; the Christensen thesis could not be fetched because UBC blocks the server).
  * This group includes 15 beaked whales and other data-deficient species. All of them carry the identical value 1500 (1000–3000), which looks like a default guess rather than a survey.
  * Two species, *Phocoena sinus* and *Monachus monachus*, are almost certainly survey-based (acoustic surveys and colony counts). They are kept as unclear because the compiled source does not state the method.
* **Greenspoon 2023-only rows** are marked independent only if the IUCN text contains survey/count wording and the report type is not partial. This applies to *Pusa caspica* and *P. sibirica*.

### 1.4 Corrections and source errors, all flagged in `notes`

* The *Arctocephalus forsteri* species appears twice as "entire": 200,000 (1,000–2,000,000) and 150,000 (135,000–200,000). I kept the first, which matches SI 6.1.1, and dropped the duplicate.
* For the sirenians, the Supplementary Data 1 columns are inconsistent (mean < min; for example, dugong mean 80,000, min 160,000, max 320,000).
  * I used the SI-text values (160,000 / 30,000 / 10,000 / 4,000) with no interval.
  * The source code uses the "mean" column, so its sirenian biomass is half the SI text.
* *Pontoporia blainvillei* has two "entire" rows (20,000 and 100,000). *Otaria flavescens* has an "entire" row plus a "rest" row plus a model row. The source sums all of them, which is possible double counting. Both are flagged with WARNING.
* In `model_input.xlsx`, the NWA bottlenose dolphin population is mapped to *Hyperoodon ampullatus*, a source error. I recovered its N with the mass the source used (the Hyperoodon mass) and assigned it to *Tursiops truncatus*.
* "Globicephaia melas" is a typo in the source and was corrected to *Globicephala melas*. *Otaria byronia* (2023) is a synonym of *O. flavescens* (2025), so it was not added twice.
* Mass synonyms used for the COMBINE match: *Otaria flavescens*→*O. byronia*, *Kogia simus*→*K. sima*, *Platanista minor*→*P. gangetica*, *Delphinus tropicalis*→*D. capensis*.

### 1.5 Cross-check, 2025 vs 2023 (91 species in both)

* Median log10(N2025/N2023) is −0.05, and the correlation of the logs is 0.92.
* **20 species differ by more than 3.2-fold** (flagged "DISCREPANCY"). For 11 of them, the 2025 total is below an IUCN *total*, which suggests the 2025 "species total" omits populations:
  * *Zalophus californianus*: 9.0×10^4 vs 6.32×10^5
  * *Eumetopias jubatus*: 5.7×10^4 vs 2.42×10^5
  * *Monodon monoceros*: 6.5×10^4 vs 2.93×10^5
  * *Histriophoca fasciata*: 1.35×10^5 vs 5.83×10^5
  * *Halichoerus grypus*: 2.96×10^5 vs 9.48×10^5
  * …
* So "global (source species total)" means what the source sums. It does not guarantee full range coverage.

### 1.6 Intervals and years

* For the 2025 exploited rows, N_lo/N_hi are the **sums of the per-population 2.5%/97.5% model quantiles**, plus min/max for the unexploited rows. This is the source's own aggregation (`sum_results`), not a joint CI.
* The model rows are for the year 2020. The latest abundance data point fitted is given in `notes`.
* For "entire" rows, the year of the underlying estimate is 未確認 (Christensen 2006 compilation).

### 1.7 Mass

* `mass_g` = COMBINE `trait_data_reported.csv` `adult_mass_g`, matched on `iucn2020_binomial`. All 127 species matched; 4 needed a synonym (see 1.4).
* The source's own mean mass, Trites & Pauly 1998 based and sex-ratio weighted, is in `notes`.

## 2. Terrestrial megafauna


## 1. African savanna elephant — Great Elephant Census (Chase et al. 2016, PeerJ 4:e2354)
* PeerJ PDF returned 403; full text taken from Europe PMC: `data/raw/chase2016_gec/PMC5012305_fulltext.xml` (sha256 58157e9e4374251e62228071b050e52c3c780195c54c042e5bd02174109e458f), source https://www.ebi.ac.uk/europepmc/webservices/rest/PMC5012305/fullTextXML.
* Abstract: "We estimated a population of 352,271 savannah elephants on study sites in 18 countries, representing approximately 93% of all savannah elephants in those countries."
* Results: "The total population estimate for the GEC was 352,271 ± SE of 9,085 elephants, with 95% confidence interval of 334,464–370,078 elephants ( Table 2 , Fig. S4 , see Table S2 for stratum and ecosystem estimates)."
* Timing: "GEC surveys were conducted in 18 countries in 2014–2015"; "Because most GEC surveys were conducted in 2014, we used 2014 for the end date for predicting population sizes."
* Coverage caveat: "Namibia was the only country with a large savannah elephant population that was not a part of the GEC. Large-scale surveys conducted in Namibia in 2015 produced an estimate of 22,711 elephants ( CITES, 2016 ). When added to the 352,271 elephants estimated on the GEC, this leads to a total estimate of 374,982 savannah elephants. Additional GEC surveys near completion in South Sudan and Central African Republic will increase this total somewhat in the coming months."
* Method: aerial sample counts (transects, "nominal strip widths of 150–200 m"), block counts in mountainous areas; "For total counts, the stratum estimate was simply the number of elephants observed, and the variance was assumed to be 0." → **independent**.

## 2. African elephants (both species combined) — AESR 2016 (Thouless et al. 2016, IUCN SSC OP 60)
* `data/raw/aesr2016/SSC-OP-060_A.pdf` (sha256 c2059b1f0692a40e0d3f5d2dc6fe79c39611c57acbd3c236fef8b7d61a9f56f1), from https://portals.iucn.org/library/sites/library/files/documents/SSC-OP-060_A.pdf.
* "In the AESR 2016, the estimated number of elephants in areas surveyed in the last ten years in Africa is 415,428 ± 20,111 at the time of the last survey for each area. There may be an additional 117,127 to 135,384 elephants in areas not systematically surveyed. Together, this estimate and guess apply to 1,932,732 km², which is 62% of the estimated known and possible elephant range. There remains an additional 38% of range for which no elephant population estimates are available, although it is likely that average elephant densities in this range are much lower than in the surveyed areas."
* "estimates from systematic surveys now accounting for 37% of total range"
* Continental data-category table (Estimate column): "Aerial Sample Counts 330,748"; "Ground Sample Counts 893"; "Reliable Dung Counts 20,555"; "Other Dung Counts 1"; "Informed Guesses 3,398"; "Totals 2015 415,428 20,111 117,127 135,384". Regional table header "ESTIMATE ± 95% CL".
* Does not split L. africana / L. cyclotis (the split was adopted by IUCN in 2021). Central Africa (mostly forest elephants, but also savanna populations in CAR/Chad): 24,119 ± 2,865, guesses 87,190–103,355 — NOT usable as a species total for L. cyclotis.
* **L. cyclotis species-level N: 未確認** (no compiled species total found in time; not pursued further).
* Method: **independent** (aerial/ground/dung counts) with a 0.8% informed-guess component in the estimate column; guesses (117k–135k) excluded from N_est.

## 3. Rhinos — CITES CoP20 Doc. 84 Annex 3 (IUCN SSC AfRSG + AsRSG + TRAFFIC, 2025)
* cites.org returns 403. Identical document (cover reads "CoP20 Doc. 84 Annex 3") downloaded from Rhino Resource Center: `data/raw/rhino_cop20/2025-iucn-traffic-rhino-report.pdf` (sha256 c115c917d68e96d0e2ac38ae6b0f82ed4306a45084d0acde4fe3bcd550eab2d5), https://rhinoresourcecenter.com/wp-content/uploads/2025/10/2025-iucn-traffic-rhino-report.pdf.
* "By the end of December 2024, Africa had an estimated 22,540 rhinoceroses (rhinos) comprising of 6,788 black rhinos (Diceros bicornis) and 15,752 white rhinos (Ceratotherium simum)."
* "There were a further 214 black rhinos (D. bicornis) and 1,299 white rhinos (C. simum) in zoos and other facilities in other continents."
* "Given that three localities make use of sample counts and report confidence intervals, an estimated 15,390 to 16,359 Southern white rhinos lived on the African continent at the end of 2024."
* "By the end of March 2025, the greater one-horned rhinos (Rhinoceros unicornis) had an estimated population of 4,075, with 3,323 in India and 752 in Nepal."
* "In 2023, Indonesian authorities reported a population of 76 Javan rhinoceroses ... as many as 26 Javan rhinoceroses were illegally killed in the period 2019 and 2023. The current minimum estimated number of Javan rhinoceroses is thus 50"; "Camera traps are the main tool used to monitor these rhinos."
* "The Sumatran rhino (Dicerorhinus sumatrensis) population is estimated at 34 to 47 individuals, as reported at CITES CoP19." and "No concerted effort to estimate Sumatran rhino in Indonesia is known." → method **unclear** (expert figure).
* Methods (Section 1.2/Table 1): "For smaller populations, individual identification and life-history tracking approaches provide the most accurate estimates. Medium-sized populations are commonly counted in their totality, either from the ground or using aerial surveys. Generally, it is only the large populations that are estimated using sampling techniques." "In this report, we assume exact precision for estimates based on individual identification or total counts - meaning the standard error (SE) was set to 0." → **independent** for African species, R. unicornis, R. sondaicus.

## 4. Polar bear
* Only a secondary statement accessed: Regehr et al. 2016 Biol Lett (Europe PMC `data/raw/regehr2016_polarbear/PMC5206583_fulltext.xml`, sha256 6ee7b02b36b977c6846c68ab42444c267efbd0586169fec665a4ff311b758b11): "The global population of approximately 26 000 polar bears [ 4 ] is divided into 19 subpopulations" ([4] = Wiig et al. 2015 IUCN Red List). Primary assessment and any CI (a web search snippet mentions 22,000–31,000 but attribution is conflicting) **未確認**; row marked verified=未確認.

## 5. Not pursued / 未確認
* Giraffe (GCF / IUCN; species taxonomy disputed) — not pursued.
* L. cyclotis separate total — 未確認.
* IUCN PBSG subpopulation status table — not accessed.

## Masses
COMBINE `data/raw/combine/trait_data_reported.csv` (sha256 14ace2dff03b71c20dc923a9eb293aaadc29934e21c6f11fa30d1b70e5abab92), `adult_mass_g` by `iucn2020_binomial`. L. cyclotis absent (IUCN 2020 taxonomy lumps it in L. africana).

## 3. IWC population estimates (cross-check file vert_census_iwc_populations.csv)


* Source page: https://iwc.int/about-whales/estimate — live site returns HTTP 403 (Cloudflare "Just a moment..." challenge) to curl and WebFetch.
* Accessed instead via Wayback Machine snapshot 2026-07-28 20:36:04 UTC: http://web.archive.org/web/20260728203604/https://iwc.int/about-whales/estimate (raw `id_` capture).
* Saved unchanged: `data/raw/iwc/iwc_estimate_wayback_20260728203604.html.gz` (as served, gzip; sha256 d2dbe3dce7e5fbfdc7454df252742440d20d834209f9cece21686ec81642e551) and decompressed `iwc_estimate_wayback_20260728203604.html` (sha256 03db33e16361f96300c947277864a1d1f9c8740f468147e8e717e5ef33b2cd9c).
* All 57 rows' estimate|lower–upper sequences were machine-checked against the extracted page text (all found).

## Verbatim method text (page intro)
> "Estimates of current population size, known as abundance estimates, are derived from a combination of fieldwork and computer modelling.  Vessel-based and aerial sighting surveys, acoustic monitoring, and analysis of individual animal markings are techniques used independently or in conjunction with each other to count whales.  The information gathered from this fieldwork is used as the basis for population modelling which produces an abundance estimate."

> "In 2017, the IWC Scientific Committee established a new expert group to review and agree all the Abundance Estimates submitted to the Scientific Committee."

> "The IWC presents a 'best estimate' accompanied by a 95% 'confidence Interval' showing a range of plausible values for the population's actual abundance."

> "At present the IWC has agreed estimates only for some species/areas."

## Method class
independent — sighting surveys (ship/aerial, distance sampling), photo-ID mark–recapture, acoustics; no occurrence/citizen-science data, no allometry.

## How rows were built
* One row per population/area, LATEST year only (earlier years of the same population are in the HTML; a few noted in `notes`). Rows are species-POPULATIONS, not species totals.
* Several rows overlap (e.g. minke NE+Central vs East Greenland; gray PCFG ⊂ ENP; humpback Antarctic feeding grounds vs breeding grounds; bowhead West Greenland feeding area ⊂ East Canada–West Greenland; right whale SH total vs sub-areas). They must NOT be summed into species totals without resolving overlaps.
* Only E. glacialis (NA West 2019: 370, 350–380; NA East "Sightings are extremely rare") and arguably the SH right whale total (12,000, 2009, no CI) and Antarctic blue/Antarctic minke (SH entries) approximate species-/subspecies-wide estimates.
* Species assignments made by me where the IWC heading is generic: SH minke → B. bonaerensis; NA/NP minke → B. acutorostrata; "PILOT WHALES Central & Eastern North Atlantic" → G. melas (to check); Bryde's → B. edeni s.l.; Maui dolphin → C. hectori (subspecies maui).
* Masses: COMBINE `adult_mass_g` (data/raw/combine/trait_data_reported.csv, sha256 14ace2df…abab92).

## 4. Fishes: RAM Legacy v4.66


## Source and files

* RAM Legacy Stock Assessment Database v4.66, Zenodo record 14043031 (concept 14043030), published 2024-11-06, licence CC-BY-4.0. doi:10.5281/zenodo.14043031. URL: https://zenodo.org/records/14043031
* Latest version check (Zenodo API search on the title, 2026-11-03): the newest records are v4.66 (14043031) and "Extended RAM Legacy Stock Assessment Database version 4.66" (14043038), both dated 2024-11-06. Older versions: v4.65 (2024-06-17), v4.64, v4.63, v4.62, v4.61. **v4.66 is the latest.** The Extended version was not downloaded; it adds non-assessment (supplemented) data.
* Local copy: `data/raw/ramlegacy/RAMLDB v4.66.zip` (111,883,889 bytes).
  * md5 `ed6d7cd3f7da1fdcbc60015c3d65014b`, which matches the Zenodo checksum `md5:ed6d7cd3f7da1fdcbc60015c3d65014b`.
  * sha256 `6d491437f1c1126471bab5bb05eed16a843f90baba96d268c1fea98df2c378d7`, stored in `data/raw/ramlegacy/SHA256SUMS`.
  * Zenodo record JSON: `data/raw/ramlegacy/zenodo_record_14043031.json`.
  * Unzipped unchanged into `data/raw/ramlegacy/extracted/RAMLDB v4.66/`.
  * Data used: `R Data/DBdata[asmt][v4.66].RData` (sha256 `76e7373d854813425b8df3ffebc061a9ca872b14fe7d669511747fd1392cb3d3`).
* Script: `scripts/vert_census/ram_fish.R`, run with Rscript from the project directory. Output: `fish.csv` (242 rows) and `fish_species_stockcoverage.csv`.

## Verbatim definitions (from the database's own tables)

`tsmetrics` table, rows for TN. Columns are tscategory | tsshort | tslong | tsunitsshort | tsunitslong | tsunique:

```
TOTAL BIOMASS | TN | Total abundance. Use TN if TB is not available | E00 | Individuals | TN-E00
TOTAL BIOMASS | TN | Total abundance. Use TN if TB is not available | E03 | Thousands | TN-E03
TOTAL BIOMASS | TN | Total abundance. Use TN if TB is not available | E06 | Millions | TN-E06
TOTAL BIOMASS | TN | Total abundance. Use TN if TB is not available | index | index | TN-index
TOTAL BIOMASS | TN-A1 | Total abundance in subarea. Use TN if TB is not available | E00 | Individuals | TN-A1-E00
TOTAL BIOMASS | TN-1 | Total abundance. Use only when there is more than 1 'final' model. | E00 | Individuals | TN-1-E00
```

Other definitions:

* `DB Documents/Database Quick Guide (2024-11-2).docx`: "TN" — "Total abundance; in numbers".
* `DB Documents/Database Structure (2024-11-2).docx`:
  * "timeseries_values_views — Time series values by stock and year of the most common time series fields"
  * "Each data field draws from the most recent assessment for that stock that has that data type available"
* `Supplemental Data Info (2024-11-2).docx`: "... In other words, level of data manipulation takes precedence over recency in determining preference."

Other metrics with numbers units also exist: SSB-E00 / SSB-E03 ("Spawning Stock Biomass", in Individuals or Thousands), and R-E00…R-E09 ("Recruits"). These are partial life stages, so they were **not used** as N. Only TN is used.

In the raw `timeseries` table, every TN record is stored as `TN-E00` (10,446 stock-years, 255 stocks, 268 assessments). In `timeseries_units_views`, TN is `E00` for 253 stocks and `index` for 5 stocks. The 5 index stocks were excluded.

## What was extracted

For each of the 253 stocks with TN in E00, I took the latest year with a non-NA TN in `timeseries_values_views`. The assessment ID comes from `timeseries_assessments_views$TN`, and the method from `assessment$assessmethod`.

Counts:

* 253 stocks / 34 species in total. This includes 11 crustacean stocks (Malacostraca: *Callinectes sapidus*, *Homarus americanus*, *Pandalus borealis*, *Chionoecetes opilio*), which were dropped from fish.csv.
* **Fish: 242 stocks, 30 species** (Actinopterygii 23 species / 234 stocks; Elasmobranchii 7 species / 8 stocks).
* All 253 stocks have `state` = Current.
* **No value is species-global.** Every row is a stock (a regional population). No area name contains global/world/entire.

The data are dominated by Pacific salmon:

* 205 of the 242 fish stocks are *Oncorhynchus nerka* (71), *O. gorbuscha* (68) and *O. keta* (66).
* Their assessment IDs are from ADFG, DFO, TINRO, WDFW and FAFRFJ (mostly "...-HIVELY" entries).
* `assessmethod` = "Unknown", and there is no TN note.
* Whether TN for these stocks is total run (return) size or some other abundance is **未確認**.
* 3 salmon stocks have a latest TN of 0. They are flagged in notes.

The other 37 fish stocks (28 species) have latest years 2002–2022 (median 2012). They include:

* cod (5 stocks)
* herring, plaice, yellowtail, silver hake and winter flounder (2 each)
* menhaden
* anchovy (ANCHOSA, 9.94e11)
* coastal sharks
* spiny dogfish

Year of the latest value across all 242 fish rows: 1962–2022, median 1999. 116 stocks are from 1991–2000 (the salmon series mostly end around 1998–2005).

Some TN notes say the series covers part of the stock. Example: AMPL4T "Figure 12. Ages 4 to 5." These notes are copied into `notes`. Other TN notes say the values were digitised from figures ("grabbed ... using GraphClick").

## Can stocks be summed to the species?

For 10 species, every Current RAM stock of the species has TN:

* *Balistes capriscus*
* *Brevoortia patronus*
* *Brevoortia tyrannus*
* *Carcharhinus acronotus*
* *C. isodon*
* *C. limbatus* (2 stocks)
* *C. plumbeus*
* *Morone saxatilis*
* *Paralichthys dentatus*
* *Sphyrna tiburo*

This means only "all stocks that RAM holds". **How much of each species' range the RAM stocks cover is unknown** (not assessed here). Most of these are US Atlantic/Gulf stocks of species whose ranges are wider. For the other 20 species, some RAM stocks lack TN (for example, cod has many stocks without TN). Years also differ between stocks. Summing stocks is therefore not recommended without a range-coverage check.

## Mass

RAM has no mean-weight time series in the views. The `biometrics` table has LW-a/LW-b (length–weight parameters) and MAX-WGT, but no mean weight-at-age table was found in the views.

Mass was taken as follows:

1. **Stock mean mass = TB/TN.** Used when TB (units MT) and TN come from the same assessment and the same year: 9 fish stocks. TB is defined as "Total biomass (or total exploitable biomass). Denoted on biometrics page", so TB/TN may be a biased mean mass. This is flagged.
2. Otherwise, **FishBase v25.04 `species.Weight`**, which is the maximum published weight in g, **not a mean**: 228 stocks. The FishBase max weight is also given in notes for every row.
3. No mass: 5 rows (*Brevoortia tyrannus*, *Engraulis encrasicolus*, *Limanda ferruginea* ×2, *Carcharhinus isodon*). These species have no FishBase Weight value or did not match by binomial name.

Caution: across all RAM TN stocks that have both values (crustaceans included; 12 stocks have TB/TN), TB/TN ÷ FishBase max ranges from 0.006 to 0.066 (median 0.025). Max weight overstates typical mass by about 1.5 orders of magnitude.

## Method classification

`independent (stock assessment)`. The values are model estimates (VPA, SCA, ASPM, etc.) fitted to catch and fishery-independent survey or index data. They do not use citizen-science or occurrence data, and density is not predicted from body size.

* The Pacific salmon series have method "Unknown". They are probably catch + escapement run reconstructions (counts), but this is 未確認.
* Some values were digitised from assessment figures by the RAM curators (stated in the TN notes).

## 5. Seabirds


Checked 2026-11-03. **Result: I found no accessible, open, citable per-species global seabird population table. `seabirds.csv` has the header only (0 rows).** No numbers were filled in from memory.

## Sources tried

| Source | What was needed | Outcome |
|---|---|---|
| Brooke 2004, Proc R Soc B 271 Suppl 4: S246–S248, doi:10.1098/rsbl.2003.0153 (PMC1810044) | Electronic appendix with species populations (breeding pairs) | **未確認.** Europe PMC fullTextXML returns HTTP 500. The PMC HTML has the abstract only (scanned article). The PMC PDF sits behind a JS proof-of-work page. The Europe PMC render returns HTML. royalsocietypublishing.org returns 403 to both curl and WebFetch. The appendix was not obtained. |
| Paleczny et al. 2015, PLoS ONE, doi:10.1371/journal.pone.0129342 (PMC4461279) | Population database | Not in the published files. S1 = species list, S2 = coastal stretches. S3 is only an "Example of contents of the population size database for the Blue Petrel (Halobaena caerulea)". The full database is not published. |
| Karpouzi, Watson & Pauly 2007, MEPS 343: 87–99, doi:10.3354/meps06860 (PDF from vliz.be, sha256 `1f684edc…4899`, kept in scratchpad only) | Per-species population (351 species) | The paper has no per-species table; the data are in the Karpouzi 2005 MSc thesis (UBC, doi:10.14288/1.0074880). **The thesis is 未確認**: UBC open.library returns a bot-block page to both curl and WebFetch, and the aoml.noaa.gov copy is HTML, not a PDF. |
| Grémillet et al. 2018, Curr Biol 28: 4009, doi:10.1016/j.cub.2018.10.051 (mmc1 from ars.els-cdn.com, sha256 `cb38a6ef…b901`) | Species population table | Not present. mmc1 holds Figs S1–S3 and Tables S1–S2 (FAO areas, % change by family). cell.com returns 403. |
| Dias et al. 2019, Biol Conserv, doi:10.1016/j.biocon.2019.06.033 (mmc1–3 via ars.els-cdn.com) | Population sizes | Not present. Appendix 1 is a species list with the 2018 Red List category, pelagic/coastal and group (about 359 species, BirdLife 2018 taxonomy). Appendices 2–3 cover threats and figures. **Saved Appendix 1 as a seabird species denominator:** `data/raw/dias2019/1-s2.0-S0006320719307499-mmc1.pdf`, sha256 `94b3e83489f202c66888f29272b3e458f0b431c1d3a35eea1e0f78ab2b991400`. |
| Richards et al. 2021 GEB, Dryad doi:10.5061/dryad.x69p8czhd (CC0) | Population size | No population column (traits only: clutch, body_mass_median, GL, …; 341 species). |
| Croxall et al. 2012 Bird Conserv Int | Per-species N | Not in Europe PMC. From what is known of the paper it gives status and threat summaries rather than a per-species N table, but **I did not read the paper, so this is 未確認**. |
| Dryad / Zenodo / figshare keyword searches | Open global per-species dataset | Only regional or colony-level datasets turned up (e.g. Beringian Seabird Colony Catalog, Zenodo 10.5281/zenodo.23507340; JNCC Seabirds Count for Britain and Ireland). None is global. |
| BirdLife Data Zone factsheets (e.g. northern-gannet-morus-bassanus) | "Number of mature individuals" | The page is reachable (HTTP 200), but its values load client-side, so the static HTML shows only labels. BirdLife values are expert compilations; I would classify them **unclear**, not independent. Bulk use needs a Data Zone request. Not pursued. |
| Wetlands International Waterbird Population Estimates (wpe.wetlands.org) | Population estimates | JS app with no visible bulk download. Coverage is flyway populations of waterbirds and excludes most pelagic seabirds. Not pursued. |

## Verbatim method evidence relevant to classification (for when the data are obtained)

* Brooke 2004 abstract (PMC1810044 HTML): "Improving knowledge of the population sizes of all the world's seabirds allows this provisional estimate of their annual food consumption. … assuming that, at the least, there are three individuals alive for every recorded breeding pair, the annual food consumption of all the world's seabirds is 70 million tonnes (Mt: 95% CI 55.9-83.7 Mt)."
  → Brooke works in **breeding pairs**. "Three individuals per pair" is a conversion assumption.
* Karpouzi et al. 2007, Methods (p. 89), data sources: "(1) … avibase); (2) the United Nations Environment Programme—World Conservation Monitoring Centre Species Database …; (3) BirdLife International (www.birdlife.net); (4) the National Audubon Society Christmas Bird Count (www.audubon.org/bird/cbc/); (5) Birds of North America Online …; and (6) Wetlands International (www.wetlands.org)."
  → The Karpouzi database partly uses the **Christmas Bird Count (citizen-science occurrence data)**. Even if the thesis is obtained, it would be **mixed**, not independent.
* Karpouzi et al. 2007, same section: "Each breeding location was assigned a population size for each breeding species and original census year. Population sizes are usually expressed in the literature as breeding pairs (bp)." Also: "for 97% of seabird populations, population size estimates used before 1970 were based on backward extrapolation … the percentage of interpolated population estimates decreased to 86%."
* Paleczny 2015 Methods: "We obtained population sizes as breeding pairs or total population; for comparison between the two, we converted records reported in breeding pairs to total population assuming that the population includes 30% non-breeders".

## Coverage

0 species with a verified independent global N, out of about 341–361 seabird species. The denominator depends on the definition: Richards 2021 has 341, which excludes sea ducks; Dias 2019 Appendix 1 lists about 359 (my line count of the PDF table was 361).

## Mass join

Not done, because there are no rows. AVONET (`AVONET1_BirdLife`, `Species1`, `Mass`) is ready for when rows exist.

## Leads, if the parent or a human wants to pursue this

1. Get the Brooke 2004 electronic appendix through a browser or institutional access (royalsocietypublishing.org blocks the server). Units are breeding pairs. The method is a literature compilation of colony counts, so it is likely independent, but this must be confirmed from the appendix text.
2. Download the Karpouzi 2005 thesis from UBC cIRcle with a browser. It is likely to be mixed (Christmas Bird Count).
3. Request a BirdLife Data Zone export of population size with "Derivation" and "Data quality" fields. Those fields might let a colony-count subset be marked independent.
