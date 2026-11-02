# Provenance notes — id `milo` (Bar-On 2018; Greenspoon 2023; Greenspoon 2025)

Written 2026-11-03. Every number in `milo.csv` was read from the files listed below. Nothing was filled in from memory. Items I could not check are marked **未確認**.

## Retrieved files (raw, unmodified, under `data/raw/`, gitignored)

| Source | Local path | Version |
|---|---|---|
| Bar-On et al. 2018 code/data | `data/raw/baron2018/biomass_distribution/` (git clone of github.com/milo-lab/biomass_distribution) | commit 36cf0a80ec94deb73cb560b66cbd9fa190f528ce (2018-05-16) |
| Bar-On 2018 SI Appendix | `data/raw/baron2018/supp/pnas.1711842115.sapp.pdf` (Europe PMC supplementaryFiles for PMC6016768) | — |
| Greenspoon 2023 code/data | `data/raw/greenspoon2023/mammal_biomass/` (git clone of gitlab.com/milo-lab-public/mammal_biomass, the URL given in the paper's Methods) | commit 7dc16868e5962a0c9ab583cc540c943b8f066ca0 (2023-10-25); 4.8 GB, mostly rasters |
| Greenspoon 2023 SI | `data/raw/greenspoon2023/supp/pnas.2204892120.sapp.pdf` (Europe PMC, PMC10013851) | — |
| Greenspoon 2025 code/data | `data/raw/greenspoon2025/mammal_biomass_since_1850/` (git clone of gitlab.com/milo-lab-public/mammal_biomass_since_1850) | commit 737cbbbeee8f564d823e2ee851c05132bc46670f (2025-08-17) |
| Greenspoon 2025 SI and Supplementary Data | `data/raw/greenspoon2025/supp/41467_2025_63888_MOESM1_ESM.pdf` (SI), `..._MOESM3_ESM.xlsx` (Suppl. Data 1 = unexploited marine populations), `..._MOESM4_ESM.xlsx` (Suppl. Data 2 = observation years) | static-content.springer.com |

The main texts were read as Europe PMC full-text XML: PMC6016768, PMC10013851 and PMC12559707. Working copies are in the scratchpad. They were not saved to the repo.

---

## 1. Bar-On, Phillips & Milo 2018, PNAS 115:6506 (doi:10.1073/pnas.1711842115)

### How the uncertainty is reported

The paper reports uncertainty as a fold factor, not as a confidence interval. Quote from Table 1 legend (PMC6016768):
> "We report an uncertainty projection for each kingdom as a fold-change factor from the mean, representing a range akin to a 95% confidence interval of the estimate."

How the code computes it (`statistics_helper/CI_helper.py`):
* `geo_CI_calc` returns `10**(std(log10 x)/sqrt(n)*1.96)`, which is a multiplicative 95% CI of a geometric mean.
* `CI_sum_prop` propagates uncertainty through sums by lognormal Monte Carlo.
* `CI_prod_prop` propagates uncertainty through products in quadrature, in log space.

In the CSV, `B_interval_type = fold_uncertainty`. `B_lo` and `B_hi` were computed by me as B/fold and B×fold, and the notes column says so. When `Table1 & Fig1` has a blank Uncertainty, I left it blank (`none`). This applies to annelids, cnidarians, molluscs, nematodes, livestock, humans and wild birds.

The `FigS2-S3` sheet shows error bars of "10" for annelids, molluscs, cnidarians, nematodes and wild birds, and "1.1" for humans and livestock. These values are typed into the sheet; `figures/figure_code/figS2S3_generate.py` does not derive them. They are figure-only, so I did **not** use them as uncertainties.

PNAS Table 1, verbatim:
> "Taxon Mass (Gt C) Uncertainty (-fold) Plants 450 1.2 Bacteria 70 10 Fungi 12 3 Archaea 7 13 Protists 4 4 Animals 2 5 Arthropods, terrestrial 0.2 Arthropods, marine 1 Chordates, fish 0.7 Chordates, livestock 0.1 Chordates, humans 0.06 Chordates, wild mammals 0.007 Chordates, wild birds 0.002 Annelids 0.2 Molluscs 0.2 Cnidarians 0.1 Nematodes 0.02 Viruses 0.2 20 Total 550 1.7"

The CSV uses the unrounded values in `results.xlsx` sheet `Table1 & Fig1`. Abundances come from sheet `Table S1`, column "Number of individuals".

### Conversion factors (wet weight → carbon)

* **Wet → C = 0.15**, from "assuming 70% water content and 50% carbon content out of dry weight". This factor is used in:
  * `animals/chordates/wild_mammals/wild_mammal.py` (`wet_to_c = 0.15`)
  * `wild_birds/wild_birds.py` (`wet_to_c = 0.15`)
  * `humans/humans.py` (`wet_to_c = 0.15`)
  * `fish/fish_biomass_estimate.py` (line 219, `wet_to_c = 0.15`; Costello section `0.3*0.5`)
  * `livestock/livestock_biomass.py` and `poultry.py` ("carbon is ≈15% of the wet weight")
  * terrestrial arthropods: dry = 0.3 × wet, C = 0.5 × dry (`terrestrial_arthropods.py`, cell 7)
  * termites ×0.15 (cell 25)
* Greenspoon 2023 Discussion uses the same factor: "converted to dry weight ... by dividing by a factor of 3 ... Dry mass can be further converted to carbon content ... by dividing by 2".

### Per-individual masses used to turn B into N

These are critical for the M = B/N step.

| Group | Assumed mass per individual | Location | Scope of N |
|---|---|---|---|
| Nematodes | 0.05 µg C | `animals/nematodes/nematodes.py` line 99 `carbon_content = 0.05e-6` (Fierer et al.) | all nematodes |
| Annelids | 25 µg C | `annelids.py` `ench_carbon_content = 25e-6` | **Enchytraeids only** |
| Marine arthropods | 4 µg C (geometric mean of 0.15–100 µg C) | `marine_arthropods.py` `copepod_carbon_content = 4e-6` | mesozooplankton copepods only |
| Molluscs | mean biomass ÷ mean abundance (Bednaršek et al.); SI says ≈0.3 mg C | `molluscs.py` cell 5 | pteropods only |
| Cnidarians | geometric mean of mean and median mg C ind⁻¹ (Lucas et al.) | `cnidarians.py` cell 12 | planktonic only, no corals |
| Fish | length–weight allometry W = a·L^b, Fock & Ehrich Myctophidae, ×0.15; SI ≈0.5 g C | `fish_biomass_estimate.py` cells 21–23 | mesopelagic only |
| Terrestrial arthropods | N is an input (1e18, Williams 1960); C per individual is fitted from field data (SI ≈0.1 mg C) | `terrestrial_arthropods.py` line 104 `tot_num_arthropods = 1e18` | all |
| Fungi | 15 pg C per cell | `fungi_biomass.py` line 78 | cells |
| Protists | Pernice et al. volume–C equation at 1 µm radius | `protist_biomass.py` | pico-nano cells |
| Humans | 50 kg wet | `humans.py` | — |
| Wild birds | N = 3e11 input (Gaston & Blackburn) | `wild_birds.py` | all |

SI p.61, verbatim:
> "For annelids and nematodes, we use our biomass estimates and divide them by the mean individual body mass that was used by Fierer et al. (144) to estimate their biomass densities."

SI p.62 on fish:
> "In order to estimate the mean mass of an individual mesopelagic fish, we use empirical allometric relations between fish length and mass ... This brings our estimate of the total number of mesopelagic fish to ≈10^15 fish."

SI p.63 on marine arthropods:
> "The values reported in the literature (302, 303), range from 0.15 µg C to 100 µg C ... We take the geometric mean of this range, which is ≈4 µg C per individual ... we get ~10^20 copepods"

**Consequence for H1 (needs a human decision).** For most Tier-B animal groups, Bar-On did not estimate N independently. N = B / (assumed mass per individual). So B/N gives back that assumed mass exactly, and M is an assumption rather than a measurement. N also often covers only a subgroup (Enchytraeids, copepods, pteropods, jellyfish, mesopelagic fish), while B covers the whole group. In those cases B/N is not the group's mean mass.

### Group-level method notes, with quotes

**Terrestrial arthropods** (`terrestrial_arthropods.py`; SI pp.39–40)
* Method: geometric mean of two estimates:
  1. litter + soil + canopy field biomass densities × 1.3e14 m²
  2. C per individual × 1e18 individuals
* Uncertainty: 14.88-fold, the "highest uncertainty among the collection".
* SI, verbatim: "Williams (195) put the total number of insects between 10^17-10^19 based on the density of insects in the soil of southeast England and extrapolated this density to the global terrestrial area of the world."
* My class: **independent**. Field cores and litter samples, no occurrence data or allometry. N is a single old regional extrapolation.

**Marine arthropods** (`marine_arthropods.py`)
* MAREDAT net biomass, from Buitenhuis min/max: mesozooplankton 0.33/0.59 Gt C and macrozooplankton 0.2/1.5 Gt C.
* Arthropod fraction of about 80%, taken from Tara 18S rDNA read fractions with Rhizaria excluded.
* Net-mesh correction ÷0.619.
* Uncertainty: code comment "We crudly project an uncertainty of about an order of magnitude" (`mul_CI = 10`).
* My class: **independent**. Net surveys, with a DNA read-share used only for composition.

**Fish** (`fish_biomass_estimate.py`; SI pp.34–35)
* Mesopelagic part: geometric mean of the acoustic and trawl estimates (0.15 Gt C).
* Non-mesopelagic part: 0.15 Gt C from Wilson et al. 2009. SI Table S15, verbatim: "Ecological modelling by Wilson et al. based on various parameters such as primary productivity, transfer efficiencies etc."
* Uncertainty: 8.25-fold. The non-mesopelagic part uses Jennings et al.'s 90% CI "0.05-4 Gt C". That figure is SI wording; the code uses 0.34–26.12 Gt wet.
* My class: **mixed**, because one half is surveys and the other half is a trophic model. **未確認**: I did not read Wilson et al. 2009 itself (science.org returns 403), so I could not check whether its model is size-spectrum or allometric.

**Wild birds** (`wild_birds.py`; SI pp.37–38)
* SI, verbatim: "Finally, Gaston & Blackburn use an allometric scaling of the density of individuals per species with body size."
* Estimate 2, verbatim: "log10(number of individuals) = 3.26-0.3×log10(body mass) + 0.63×log10(study area), (R2 = ≈0.3)."
* My class: **allometry-derived**. Both components depend at least partly on density–mass scaling.

**Wild land mammals** (`wild_mammal.py`)
* Geometric mean of three estimates:
  * Smil, from HYDE biome densities: 0.025 Gt wet
  * Barnosky Fig. 3: 10^10.72 t wet
  * Novosolov regression: "log10(number of individuals) = 1.65-0.53×log10(body mass) + 0.73×log10(study area)", 5.4547e12 g wet
* Fold 3.69.
* My class: **mixed** (one of three components is allometric). Superseded by Greenspoon 2023.

**Wild marine mammals**
* Christensen thesis, year-2000 mean, with fold 1.4375 (Max/Mean).
* SI, verbatim: "A caveat of our uncertainty analysis for wild marine mammals is that the estimates from the IUCN and Christensen might not be independent of each other."

**Nematodes**
* SI p.~30 (Nematodes), verbatim: "For some locations, there are direct biomass measurements and for other locations biomass is estimated based on conversion from number of individuals to biomass (based on size or mass)". The SI also says: "We get an estimate of ≈0.006 Gt C". Marine nematodes were set to 0.014 Gt C by assuming that meiofauna is mostly nematodes.
* My class: **independent** (soil cores). The N/M circularity described above still applies.

**Annelids, molluscs, cnidarians**
* My class: **independent** for annelids (Fierer et al. soil densities) and molluscs (MAREDAT pteropods plus a published cephalopod figure).
* Cnidarians: **mixed**. The jellyfish part comes from an abundance database, but the coral part is a geometric/physiological calculation from reef area, cover and tissue carbon per area.

**Microbes, plants, viruses**
* Classed **unclear**. I did not audit the sub-notebooks. They are outside the GBIF-per-individual scope, except plants.
* The plant N is the number of trees (3e12, Crowther et al.), not all plants.

**Number of species**
* Taken from `results.xlsx` sheet `FigS2-S3`, column "Number of species".
* These are pre-filled figure inputs, and the repo does not cite their source. SI Fig. S3 legend: "We note that even for fungi and protists the estimate for the number of species may not be robust."
* Use them only provisionally.

### Repo quirks (no effect on CSV values)

* `figS2S3_generate.py` line 37 sets the Protists biomass to the **Fungi** sum (a code bug). The cached xlsx still shows the protist value.
* `Table S1` rounds plants N (3e12) to "1E+13".
* The MS-data sheet rounds termites 0.067 to "0.05".

---

## 2. Greenspoon et al. 2023, PNAS 120:e2204892120 (doi:10.1073/pnas.2204892120)

**Data location.** The Methods say: "All of the data ... are open sourced and available at https://gitlab.com/milo-lab-public/mammal_biomass". The repo was cloned.

**Species-level data exist.**

`results/wild_land_mammal_biomass_inluding_populations.csv` has 4,795 land species, with these columns:
* binomial
* biomass_g, plus bounds
* estimated_population, plus bounds

One quirk: the column `biomass_g_97pt5` is smaller than `biomass_g_2pt5` in every row, so the labels are swapped. `results/wild_land_mammal_biomass.csv` labels the same values correctly as lower/upper.

`results/wild_marine_biomass.csv` has 121 marine species, with biomass_Mt only and no N.

**How populations were estimated.** This classification is critical.

Abstract:
> "we compiled estimates of the total abundance (i.e., the number of individuals) of several hundred mammal species from the available data, and used these to build a model that infers the total biomass of terrestrial mammal species for which the global abundance is unknown."

Results:
> "we were able to collect reports on the global population sizes of 392 land mammal species, representing ≈6% of all wild land mammal species ... we constructed a machine learning model that infers the global populations of the remaining ≈94% of species"

Methods:
> "Six parameters suspected to affect population density or sizes were analyzed and considered as predictors: range size, body mass, Red List category, taxonomic order, trophic level, and generation time ... All of those, except for generation time, were found relevant"

Methods:
> "We manually extracted population reports from the IUCN website (26), which, at the time of extraction (April 2019), contained total population reports for 382 species. In addition, we collected population reports from sources outside the IUCN database specifically for 10 mammalian species"

Methods:
> "The biomass of wild marine mammal species was calculated directly from global population reports"

**Counts (my tally from repo files).**
* Directly reported: 392 species (`data/species_w_pop_reports.csv`), which is 8.2% of the 4,795 species in the results file.
  * 382 IUCN species plus 10 species from outside IUCN.
  * These sum to 10.70 Mt in the species file.
* SVR-predicted: 4,403 species in the results file (91.8%).
  * `data/species_to_infer.csv` lists 4,413; 10 of these are missing from the results file.
  * These sum to 11.74 Mt.
* The repo's `results/results_by_method.csv` says "Population reports 12 Mt / 393" and "Inferred using SVR 10 Mt / 4413".
  * The difference is consistent with the feral-pig part of *Sus scrofa* (`data/feral_pig_.csv`, 20.5 million individuals) being counted on the "reports" side. The endemic *S. scrofa* is SVR-inferred (SI: "We estimated the wild boar population in Eurasia and North Africa ... using our models").
  * This reconciliation is my inference.
* Table 1 of the paper flags *S. scrofa* and *Phacochoerus africanus* with "* Species estimated using Support Vector Regression model".

**Extra-IUCN species are partly extrapolated.** SI p.3, white-tailed deer:
> "We, therefore, estimate the white-tailed deer population density in Latin America to be 1 individual/km2, arriving at an additional ≈5 million individuals."

Moose and mule deer were extrapolated by range fraction in the same way.

**Discrepancies within the repo (not resolved):**
* `data/high_mass_contributors_..._other_than_IUCN.csv` gives *Odocoileus virginianus* 41e6 and *Alces alces* 2.1e6.
* `species_w_pop_reports.csv` and the results file give 45e6 and 1.35e6.

**Uncertainty.** Methods:
> "for each of the species with reported population abundances, we set a 95% CI within an upper and lower bound of twofold above and below the estimated size ... For species lacking population reports, we used bootstrapping based on 1,000 runs of our model".

Totals are sums of per-species bounds. Abstract: land "≈20 Mt ... (95% CI 13-38 Mt)", marine "≈40 Mt (95% CI 20-80 Mt)".

**Total N.** The paper gives no total N. The CSV value 8.78e10 (5.80e10–1.26e11) is my column sum of `estimated_population` and its bounds. Bounds were summed the same way the paper sums biomass bounds.

**Classification**
* SVR-inferred species → **allometry-derived**, because the machine-learning model has body mass as a predictor. Exclude them from the main analysis.
* Species with reports → **unclear**, leaning independent (needs a human decision). They are IUCN expert totals. Some IUCN totals are themselves density × range extrapolations, and I did not audit them species by species.
* Marine → **independent** (population reports).
* The land total is therefore **mixed**.

**未確認.** The PNAS record lists a later letter, "Total population reports are ill-suited for global biomass estimation of wild animals" (vol. 121, e2308958121). I did not retrieve or read it. A human should read it before relying on the reported subset.

---

## 3. Greenspoon et al. 2025, Nat Commun (doi:10.1038/s41467-025-63888-z)

**Species-level data in the repo:**
* `data/wild_terr/wild_land_biomass_for_map.csv` holds 2020 biomass per species, in Mt, for 4,795 land species.
  * It is identical, value for value, to the Greenspoon 2023 map file for the 4,794 species they share. It adds one row, *Loxodonta cyclotis*.
  * The current-day land values are therefore the **2023 SVR + report values**, inheriting the 2023 classification.
* `data/wild_terr/Terrestrial species since 1850.xlsx` (sheet `expert_estimates`) holds historical and current population counts with sources for 36 species.
* `data/wild_terr/species_with_estimates/` holds time series for *Bison bison*, *Loxodonta africana* and *Odocoileus virginianus*.
* Marine data:
  * `results/marine_model_results/biomass/*.csv` holds 80 per-population trajectories, with 0.025/0.5/0.975 quantiles in tonnes. Per `marine_mammal_funcs.py` line 154, these are population × mean body mass in tonnes.
  * Model inputs are in `data/wild_marine/model_input.xlsx` (priors and abundance points) and `catch_data_all_tables.xlsx`.
  * `data/wild_marine/unexploited_populations.xlsx` (= Suppl. Data 1) holds mean/min/max abundances for 103 non-exploited populations.
* Not in the public repo, because they are gitignored: `data/wild_terr/results_Hyde_baseline_v3.mat` and `santini_pop_density.csv`. These were used only in a plausibility check (**未確認**).

**Methods quotes (PMC12559707):**
> "We were able to obtain historical population estimates for 37 of these 121 species ... Due to lack of data availability, we portray the biomass of all other wild land mammal species as constant."

> "Collected historical abundance estimates include census data and modeled estimates."

> "To estimate the biomass of wild marine mammals since 1850, we used a population dynamics model that relies on catch records and direct population estimates"

SI Note 3.4:
> "did not find a method to reliably quantify the uncertainty associated with this estimate."

SI Note 3.3:
> "We calculated the median estimate for the total biomass of wild marine mammals and the confidence intervals based on the sum of median, 5th percentile, and 95th percentile for each population. This process produced a total biomass estimate of ≈130 Mt (95%CI 105-180) for the year 1850, and a total biomass estimate of ≈40 Mt (95%CI 28-75 Mt) for the present."

The interval is labelled "95%CI" but is built from 5th and 95th percentiles. I coded it CI90; a human should check.

**Values used** (from the repo `results/`):
* Land 2020: 21.60 Mt
* Land 1850: 53.49 Mt. Both are 10-year centred rolling means (`Wild_land.ipynb` cell 10).
* Marine 2020: 44.14 Mt (28.36–75.14)
* Marine 1850: 132.57 Mt (106.04–179.04)

**Classification**
* Marine → **independent** (catch logs and survey abundances fitted by a logistic stock-reduction model, with no body-size predictor).
* Land → **mixed** (it inherits the 2023 SVR values).

**Suspicious entries in `Terrestrial species since 1850.xlsx`.** These are reported as I read them; I did not correct anything.
* *Ceratotherium simum cottoni* (Northern white rhino) shows a current population of 18064, and *C. s. simum* shows 2. These look swapped.
* *Rhinoceros unicornis* shows a current population of 10.
* The row "*Capreolus capreolus*" has the common name "Red kangaroo".

A human should check these before using any row as Tier-A data.

---

## Decisions needed from a human

1. **Bar-On group N.** Most of these N values are B ÷ an assumed mass per individual, and often cover only a subgroup. Should M = B/N from Bar-On be used at all, or should M come from an independent source?
2. **Wild birds.** Bar-On's bird biomass relies on allometric scaling, so I classed it allometry-derived. Should it be excluded from the main analysis?
3. **Greenspoon 2023 reported subset.** Should these 392 IUCN/expert totals count as "independent"? Check the PNAS 2024 letter first.
4. **Fish.** The non-mesopelagic half comes from Wilson et al.'s ecological model (**未確認** whether that model is allometric). Should fish be treated as mixed?
5. **Greenspoon 2025 marine interval.** It is labelled 95%CI but built from 5th–95th percentiles. Should it be treated as CI90 or CI95?
