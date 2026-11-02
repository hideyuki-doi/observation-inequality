# データ出典記録（Phase 1 センサス）

自動生成：scripts/build_provenance_doc.sh。各節の原本は docs/provenance_parts/<担当>.md、数値は同名 .csv → data/derived/census.csv。
逐語引用は原典の英語のまま。B_lo/B_hi が fold uncertainty から計算されたものは notes に明記。


---

## Provenance notes — id `milo` (Bar-On 2018; Greenspoon 2023; Greenspoon 2025)

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

---

## Phase 1 センサス調査：soil_arthropods（陸生節足動物・土壌動物）

担当 id: `soil_arthropods`。作成日 2026-11-03。対応する表: `soil_arthropods.csv`（18行）。

すべての数値は以下の原典本文・補足資料・データから直接読み取った。読めなかったものは空欄にして「未確認」とした。引用は英語原文のまま。

---

## 1. Rosenberg et al. 2023, Science Advances 9: eabq4049

- DOI: https://doi.org/10.1126/sciadv.abq4049
- 全文: Europe PMC REST の PMC9897674 fullTextXML → `data/raw/rosenberg2023/PMC9897674_fulltext.xml`
- 補足 PDF とデータ S1: Europe PMC supplementaryFiles → `data/raw/rosenberg2023/pmc_supp.zip`（`sciadv.abq4049_sm.pdf` と `sciadv.abq4049_data_s1.zip` を含む）
- データとコード: Zenodo doi:10.5281/zenodo.7502033（record 7565553）→ `data/raw/rosenberg2023/zenodo7565553.zip`。収録ノートブックには出力が保存されておらず、結果表は `average_ind_mass_full.csv` しかない。ノートブックは実行していない。

### 逐語引用

- 土壌の合計（Results 第4段落）："We estimate the total mass of soil arthropods to be ≈200 (uncertainty range, 100 to 400) million metric tons (Mt) of dry weight ... Termites contribute about 40% of the biomass in the soil; ants, springtails, and mites contribute about 10% each; and other soil arthropods contribute the remainder ... We estimate the total population of soil arthropods to be ≈1 × 10^19 (uncertainty range, 0.5 × 10^19 to 2 × 10^19) individuals. The microarthropods, mites and springtails, account for >95% of the total population of soil arthropods, with about two-thirds of these being mites."
- 地上部（Results）："We find that above-ground arthropods have a total of ≈50 Mt (uncertainty range, 20 to 100) of dry biomass, with our upper range potentially reaching ≈200 Mt when considering key biases ... Together, both habitats contain a global terrestrial arthropod biomass of ≈300 Mt (uncertainty range, 100 to 500)." 個体数については "... population densities of above-ground arthropods are typically much smaller than those of soil arthropods and contribute little to the global number of individual arthropods."
- 全陸生節足動物（Discussion 第1段落）："Dry weight of 300 Mt is roughly equivalent to 1000 Mt of fresh weight (16) or 150 Mt of carbon (20) ... we estimate the total number of terrestrial arthropods at about 1 × 10^19 individuals (uncertainty range, 0.5 × 10^19 to 2 × 10^19)"
- シロアリ（Discussion 第2段落）："Our estimated global biomass of termites (100 Mt; range, 50 to 170 Mt) agrees with previous estimates of 100 to 120 Mt (14, 24)"
- シロアリの補足推定（SM 第4節）："we estimate the total global termite biomass to be about 80 Mt dry weight, with an extended error range between 50 and 120 Mt. This is about 20% lower than the median of our main estimate for termites"
- トビムシ（Discussion 第3段落）："Our total population estimate for soil springtails (3 × 10^18 individuals; range, 1 × 10^18 to 6 × 10^18 individuals) agrees with the recent estimate of 2 × 10^18 individuals made in (25), but our total biomass estimate is about four times lower. This difference seems to originate from the large values of average body mass reported in (25), which are based on taxonomy and allometric evaluations."
- アリ（Discussion 第4段落）："Our estimated global population of nonarboreal ants, considered as part of the soil and plant litter habitat, is 5 × 10^16 (uncertainty range, 1 × 10^16 to 9 × 10^16) individuals ... Our separate estimate for soil ants' dry biomass is ≈25 Mt (uncertainty range, 10 to 50 Mt) ... Our dataset yields a global average dry weight of 0.84 mg per soil ant."
- その他の節足動物（SM、ref 17 との比較）："This analysis yields an estimate of ≈75 Mt, which is similar to our estimate of ≈50 Mt for the group 'others'."
- 不確実性の定義（Methods）："The uncertainty ranges reported in the main text and in Fig. 5 were calculated by taking the sum of the lower or upper bounds of the 95% confidence intervals for all such distributions ... This procedure increased the uncertainty range by up to a factor of 4 with respect to the random error."

### 推定方法と method_class の判定

方法は、文献から集めた約500サイトの絶対密度（個体数/m²、mg/m²）の合成。土壌は方形区コアを採り、Tullgren 漏斗や手選別で抽出したもの。地上部はキャノピーフォギングや trap-and-remove による。これをバイオーム × 分類群に層別し、ブートストラップで平均を求め、バイオーム面積を掛けてモンテカルロで合算している。GBIF などの出現記録は使っていない。体サイズから密度を予測するアロメトリーも使っていない。

湿重量しかない記録は分類群別の係数で乾重量に換算している。個体数しかない土壌の記録は、同時測定データから求めた分類群平均の個体重で生物量に換算している。どちらも経験値であり、密度を予測するアロメトリーではない。以上から **independent** と判定した。

### 迷った点・未確認

- **ダニ（Acari）**：全球の N も B も数値として記載がない。分かるのは「>95% のうち約2/3」「土壌生物量の約10%」という割合だけである。約 6e18 は私の計算になるので表には入れていない。バイオーム別の密度は SM Table S3/S4 にある。全球値が必要なら、Zenodo のノートブックを実行するか、Table S4 × バイオーム面積で再計算する必要がある。どちらにするか（あるいはどちらもしないか）は人間の判断が必要。
- **トビムシの B、シロアリの N、「others」の N**：記載なし。
- **甲虫など**："others" に含まれ、個別の推定はない。
- **地上部の推定**：約60サイトに基づく。著者自身が「highly uncertain」としている。

---

## 2. van den Hoogen et al. 2019, Nature 572: 194–198

- DOI: https://doi.org/10.1038/s41586-019-1418-6
- 本文は有料で、取得できたのは抄録のみ（`data/raw/vandenhoogen2019/s41586-019-1418-6.html`）。HAL の公開版はボット対策で取得できなかった。
- 補足表（springer static-content）：`data/raw/vandenhoogen2019/41586_2019_1418_MOESM{1..9}_ESM.*`。MOESM1 は Reporting Summary。

### 逐語引用

- 抄録："The resulting maps show that 4.4 ± 0.64 × 10^20 nematodes (with a total biomass of approximately 0.3 gigatonnes) inhabit surface soils across the world, with higher abundances in sub-Arctic regions (38% of total) than in temperate (24%) or tropical (21%) regions."
- Supplementary Table 5 の説明："Summing the predicted number of nematodes per 1 km^2 pixel across biomes we estimate a total of 4.4 × 10^20 nematodes are present in the top 15 cm of soil across the globe." Total 行は Bacterivores 1.92E+20、Fungivores 6.38E+19、Herbivores 1.25E+20、Omnivores 3.94E+19、Predators 1.97E+19、Total_Number 4.41E+20（MOESM6_ESM.csv）。
- Supplementary Table 7 の説明："Nematode biomass per trophic group, per biome. Note that values are presented in megatons (10^6 tons) carbon." Total 行は Bacterivores 7.131、Fungivores 0.994、Herbivores 8.675、Omnivores 10.244、Predators 4.395、Total biomass 31.439 Mt C（MOESM8_ESM.csv）。
- Reporting Summary（MOESM1）："Each sample consisted of a 15-cm deep soil core, from which soil nematodes were extracted." "In each sample we counted number of nematodes and assigned them to trophic groups based on morphology." "we performed a stratified bootstrapping procedure ... This protocol thus allowed us to generate per-pixel 95% confidence intervals."

### 判定

**independent**。土壌コア 6,759 点の実測個体数を、73 の環境共変量レイヤーによる地理空間モデルで外挿している。Potapov 2023 の Methods には、この手法を "Random Forest" と書いている。環境変数だけを使った機械学習外挿であり、出現記録は使っていない。

### 迷った点・未確認

- 「4.4 ± 0.64」の ± が SD、SE、CI のどれなのかは本文が読めず未確認。CSV の N_lo/N_hi（3.76e20, 5.04e20）は私が ± から計算した値であり、interval_type は「未確認」とした。
- 抄録の「approximately 0.3 gigatonnes」が湿重量か乾重量かは未確認。CSV の B には単位が明記されている補足表7の 31.439 Mt C を採用した。生物量の計算方法（栄養群ごとの体重の出典）も、本文が読めないため未確認。
- 「soil nematode（土壌の上部15 cm）」は、GBIF の Nematoda（海産や寄生性を含む）とは範囲が一致しない（CLAUDE.md の落とし穴を参照）。
- データとコードは gitlab.ethz.ch にあるが、ボット対策で取得できなかった。

---

## 3. Schultheiss et al. 2022, PNAS 119: e2201550119

- DOI: https://doi.org/10.1073/pnas.2201550119
- 全文: Europe PMC PMC9546634 → `data/raw/schultheiss2022/PMC9546634_fulltext.xml`。SI Appendix と Datasets は Europe PMC からのダウンロードが極端に遅く、途中で中止した（未取得）。数値はすべて本文から読んだ。

### 逐語引用

- Results："we estimate the global epigaeic ant abundance at 3 × 10^15 (±0.7 × 10^15) (mean ± SEM), i.e., ∼3 quadrillion, individuals ... This corresponds to a dry biomass of 1.9 (±0.5) Mt C ... we estimate the number of all ants on Earth at any given time to be 19.8 × 10^15 (±5 × 10^15), i.e., ∼20 quadrillion, individuals with a total dry biomass of 12.3 (±3.1) Mt C"
- Methods："The upper and lower limits were estimated by summing biome means +SEM or –SEM, respectively."
- Methods："Thus, to account for nonforaging ants, we calculate total global ant abundance as [1] Global abundance=(epigaeic abundance+arboreal abundance)×100/22."
- Methods："an average worker ant was considered to have a dry weight of 1.24 mg (Dataset S4), a value obtained from the body mass measurements of 534 species ranging from 0.004 to 57 mg ... Biomass [Mt C]=abundance×0.62×10−15."
- 樹上のアリ："With the limited data available on arboreal ant densities, these calculations were not intended to provide reliable numerical values but merely a general indication of the size of the global arboreal ant population."
- 記載種数（Introduction）："Ants are highly diverse, comprising more than 15,700 named species and subspecies (26)"

### 判定

- **地表性（epigaeic）の値は independent**。リターを抽出して得た面積あたりの密度を、バイオーム面積で外挿している。ピットフォールトラップは活動密度なので、全球の推定には使っていない。
- **全アリの値は mixed とし、人間の確認待ち**。実測値に、文献から取った「採餌個体の割合 22%」で補正（×100/22）している。この補正は出現記録由来でもアロメトリー由来でもないので、independent と扱ってもよいかもしれない。
- 生物量は N × 固定の個体重（534種の単純平均で、個体数の重みなし）である。Rosenberg は、この換算が群集全体の重み付けをしていないと批判している。

---

## 4. Potapov et al. 2023, Nature Communications 14: 674（トビムシ）

- DOI: https://doi.org/10.1038/s41467-023-36216-6
- 全文: Europe PMC PMC9905565 → `data/raw/potapov2023/PMC9905565_fulltext.xml`
- データ（未ダウンロード）：figshare doi:10.6084/m9.figshare.16850419（データとコード）、10.6084/m9.figshare.16850446（地図）

### 逐語引用

- Discussion："Our extrapolations suggest that there are c. 2 × 10^18 soil springtails globally, and their total biomass comprises c. 27.5 Mt C (16.2–28.8 Mt C minimum and maximum estimates), which corresponds to c. 190 Mt fresh weight ... Our biomass estimates are very similar to the global estimated biomass of nematodes (c. 31 Mt C10), but lower than that of earthworms (c. 200 Mt C11)"
- 生物量の計算方法："Body masses and metabolic rates were derived from taxon-specific body lengths using mean annual soil temperature and allometric regressions" と "Dry and fresh body masses were calculated from body length using a set of group-specific length-mass regressions"
- 不確実性："we also used maximum (average + standard error) and minimum coefficients (average—standard error ...) in all equations to calculate maximum and minimum estimations of biomass"
- 外挿："A Random Forest algorithm was applied to identify the spatial associations and extrapolate local observations to the global scale at the 30 arcsec resolution" と "Global biomass, abundance, and community metabolism of springtails were estimated by summing predicted values for each 30 arcsec pixel10."

### 判定

**N は independent**。2,470 サイト・43,601 の土壌サンプルから抽出した実測密度を、22 の環境レイヤーによる Random Forest で外挿している。

**B は、個体の体重を体長–体重アロメトリーで推定している**。これは「密度を体サイズから予測する」タイプではないので、CLAUDE.md が警戒する循環には当たらないと考える。ただし M = B/N を使う解析では、M がアロメトリーで作られた値になる。そこで CSV では independent とし、notes に注記した。人間の判断が必要。B の幅（16.2–28.8）は回帰係数の ±SE だけを反映した値であり、標本誤差は含まない。N の区間は記載されていない。

なお、Rosenberg 2023 は同じトビムシについて N = 3e18（1–6e18）とし、生物量は Potapov の約1/4と述べている（上の引用を参照）。

---

## 5. ミミズ：Phillips et al. 2019, Science 366: 480–485

- DOI: https://doi.org/10.1126/science.aax4851
- 著者原稿: PMC7335308（HTML）→ `data/raw/phillips2019/PMC7335308.html`。補足 PDF は PMC のボット対策と science.org の 403 で取得できなかった。

### 逐語引用（いずれも1 m² あたりの値で、全球の合計ではない）

- "The predicted total abundance of the local community of earthworms typically ranged between 5 and 150 individuals per m^2 across the globe ... (Fig. 1C; mean, 77.89 individuals per m^2; SD, 98.94)."
- "The predicted total biomass of the local earthworm community (adults and juveniles) across the globe showed extreme values (>2 kg) in 0.3% of pixels, but biomass typically ranged (97% of pixels) between 1 g and 150 g per m^2 [Fig. 1D; median, 6.69; mean, 2772.8; SD, 1,312,782 ...]"
- データ："Data and analysis code are available on the iDiv Data repository (DOI: 10.25829/idiv.1804-5-2593) and GitHub (https://github.com/helenphillips/GlobalEWDiversity; DOI: 10.5281/zenodo.3386456)."

### 判定

本文には全球の合計（N も B も）が記載されていない。補足資料は未確認。方法は 6,928 サイトの実測値を、12 の環境変数を使った GLMM で予測するもので、independent に相当する。

Potapov 2023 は "earthworms (c. 200 Mt C11)" と書き、出典として Phillips 2019 を挙げている。しかし Phillips の本文にはこの数値が見当たらず、二次情報なので未確認とした。外れ値が大きいピクセル（>2 kg/m²）があるため、地図を足し合わせて全球値を作ると不安定になる。

---

## 6. その他（シロアリ・ダニなど）

- **シロアリ**：Rosenberg 2023（100 Mt、50–170）と SM の 80 Mt（50–120）を採用した。Rosenberg が引用する先行推定（ref 14, 24: 100–120 Mt）は原典を確認していないので、表には入れていない。
- **ダニ**：全球推定を報告した独立の論文は、今回の調査では見つからなかった（深くは探していない）。
- **線虫・トビムシ以外の土壌メソファウナ**（ヒメミミズ類など）は未調査。

## 人間に判断してほしいこと

1. ダニの全球 N/B を、Rosenberg の Zenodo コードの実行か Table S4 × バイオーム面積の再計算で作るか（作れば「派生値」として記録する）。
2. Potapov のトビムシ B（体長–体重アロメトリーで個体重を推定）と、Schultheiss の全アリ（採餌個体の割合で補正）の method_class をどう扱うか。
3. トビムシは Rosenberg（3e18、乾重量）と Potapov（2e18、27.5 Mt C）のどちらを主に使うか。アリは Rosenberg（非樹上性、5e16）と Schultheiss（全体 2e16、地表性 3e15）のどれを使うか。範囲の定義が異なる点に注意（Rosenberg の値が Schultheiss の地表性推定より1桁大きい）。
4. ミミズは全球値なしとするか、Phillips の地図（iDiv/Zenodo）を自分たちで合計するか。

---

## marine_other — provenance notes (Phase 1)

担当: krill, mesozooplankton, fish (marine), mesopelagic fish, gelatinous zooplankton, Hatton et al. 2021 size spectrum, prokaryotes/cyanobacteria (as N).
All quotes below are copied verbatim from the source (PDF text extraction / XML / publisher abstract). Retrieval date: 2026-11-03.

---

## 1. Antarctic krill — Atkinson et al. 2009

- Citation: Atkinson A, Siegel V, Pakhomov EA, Jessopp MJ, Loeb V (2009) A re-appraisal of the total biomass and annual production of Antarctic krill. *Deep-Sea Research I* 56:727–740. doi:10.1016/j.dsr.2008.12.007
  - Note: the task brief named it "MEPS"; the paper is actually in Deep-Sea Research I.
- URL used: https://www.iced.ac.uk/documents/Atkinson%20et%20al,%20Deep%20Sea%20Research%20I,%202009.pdf (author copy of the journal version, "ARTICLE IN PRESS" header, same pagination)
- File: `data/raw/atkinson2009/Atkinson_et_al_DSR1_2009.pdf`

Quotes:
- Abstract: "Net-based databases of density and length frequency (KRILLBASE) yield a summer distributional range of 19 × 10^6 km2 and a mean total abundance of 8 × 10^14 post-larvae with biomass of 379 million tonnes (Mt). These values are based on a standardised net sampling method but they average over the period 1926–2004, during which krill abundance has fluctuated."
- Abstract: "Thus the CCAMLR 2000 survey area contains 28% of the total stock, with total biomass of 133 Mt in January–February 2000."
- Sect. 3.2: "Overall, we derive a total krill abundance of 7.8 × 10^14 krill, based on standardised densities (Table 3). ... By stratifying on a finer, 2° × 6° grid (Fig. 2b) density is slightly higher: 8 × 10^14 krill. ... If the densities in these are replaced with dummy values of 36 krill m−2 (the mean from all 4338 oceanic stations) the total abundance is reduced to 5.4 × 10^14 krill."
- Sect. 3.3: "We combined the total abundance value, Ntotal, of 7.8 × 10^14 krill with a mean wet mass of 0.486 g krill−1 using Eq. (11) to derive a total circumpolar biomass of 379 Mt."
- Table 4 (title): "A variety of methods for estimating total biomass (fresh mass) of krill in the Southern Ocean using a combination of acoustics and net-based methods." Rows: 117 Mt ("Unadjusted net sampling estimates yield an Ntotal of 2.4 × 10^14 krill"), 379 Mt (standardised, Ntotal 7.8 × 10^14), 133 Mt (CCAMLR 2000 acoustic 37.3 × 10^6 t divided by 0.28).

method_class: **independent**. Scientific net hauls (KRILLBASE) and an acoustic survey; mass from length–mass regressions of the krill themselves. Body size is used only to turn N into B, not to predict density. The N "range" (5.4–8 × 10^14) comes from sensitivity runs, not a statistical CI.
Newer CCAMLR-based estimates: only regional (Area 48) survey estimates seem to exist; I did not retrieve or verify any → 未確認.

## 2. Mesozooplankton — Moriarty & O'Brien 2013 (MAREDAT)

- Citation: Moriarty R, O'Brien TD (2013) Distribution of mesozooplankton biomass in the global ocean. *Earth Syst. Sci. Data* 5:45–55. doi:10.5194/essd-5-45-2013
- URL: https://essd.copernicus.org/articles/5/45/2013/essd-5-45-2013.pdf ; file `data/raw/moriarty2013/essd-5-45-2013.pdf`
- Abstract: "A total of 153 163 biomass values were collected, from a variety of sources, for mesozooplankton. ... Global epipelagic mesozooplankton biomass, to a depth of 200 m, had a mean of 5.9 µg C L−1, median of 2.7 µg C L−1 and a standard deviation of 10.6 µg C L−1. The global annual average estimate of mesozooplankton in the top 200 m, based on the median value, was 0.19 Pg C."
- Sect. 3.3: "calculated by multiplying the median mesozooplankton biomass value (2.7 µg C L−1 = 2700 µg C m−3) × the area of the global ocean (3.56 × 10^14 m2) × the upper 200 m surface layer (200 m) × 1 × 10−21 µg Pg−1, which gave a value of 0.19 Pg C."
- method_class: **independent** (net samples). No uncertainty on the total and no N. Copepods are not separated. The PANGAEA dataset (doi:10.1594/PANGAEA.785501) was not downloaded.

## 3. Hatton et al. 2021 — global ocean size spectrum

- Citation: Hatton IA, Heneghan RF, Bar-On YM, Galbraith ED (2021) The global ocean size spectrum from bacteria to whales. *Sci. Adv.* 7:eabh3732. doi:10.1126/sciadv.abh3732 (PMC8580314)
- Full text: Europe PMC XML `data/raw/hatton2021/PMC8580314_fulltext.xml`. Table 1 is only an image in the XML, so I read the numbers from the authors' code/data archive on Zenodo (doi:10.5281/zenodo.5520055), file `data/raw/hatton2021/sheldon_revisited-master.zip` → `output/summary_output/summary_tables/summary_biomass_table.csv` (full depth) and `summary_biomass_table_top200.csv`.
- Table 1 caption: "Estimated pristine ocean biomass (wet weight; 1 Gt =10^15 g) are compared across major groups for the epipelagic (top 200 m) and full depth to the seafloor. ... Fold uncertainty is a multiplicative 95% CI on biomass."
- Data sources (Materials and Methods): "Bacteria abundance data were obtained from >47,000 sample measurements deriving from three sources ... Phytoplankton biomass across all groups were derived from sea surface temperature and satellite chlorophyll a measurements ... Zooplankton biomass across all groups except nanozooplankton derive from a total of >200,000 biomass samples aggregated from four sources, most notably COPEPOD and MAREDAT ... Fish biomass was estimated from two data-constrained global ecosystem models [BiOeconomic mArine Trophic Size-spectrum model (BOATS) (39) and FishErIes Size and functional TYpe model (FEISTY) (40)]."
- "For our estimates of fish (which includes true fish, cephalopods, and benthic invertebrates), we relied on two spatially resolved marine ecosystem models that predict fish biomass from environmental parameters ... the models were each run without fishing and forced with preindustrial environmental inputs from an Earth system model (CESM-BGC1) for the decade 1850–1860."
- Code comment (fish_mammals_other_biomass_estimate.R): "# Global mesopelagic fish biomass range from Proud et al., 2019 (doi:10.1093/icesjms/fsy037)" with `meso_fish_range <- c(1.8, 16) # Pg wet weight`. The point value 5.37 = √(1.8×16).
- Code comment (nano-microzoo script): "## Nanozoo biom estimate (from Bar-On and Milo, 2019)".

**Is Hatton allometry-based?** Each group's *biomass* comes from data or models (see below). *Abundance* (Fig. 1B) is made by spreading each group's biomass over its assumed body-size range and dividing by size-bin mass, so every N in Hatton depends on an assumed size distribution. The paper and code give N only as the total per size bin (`sensitivity_analysis/abundance_spectrum_ci/*.csv`, log10 values), not per group. So I left N blank for all Hatton rows. Per-group N could be computed from `summary_biomass_table_long.csv` (biomass per log10 size bin ÷ bin-midpoint mass), but that would be our own calculation and would bake in Hatton's size-range assumptions. If used, it should be classed as allometry-/assumption-derived.

method_class per group (for biomass):
- Heterotrophic bacteria; micro-, meso- and macrozooplankton: **independent** (GLMs fitted to field samples).
- Pico-, nano- and microphytoplankton: **independent** (satellite chlorophyll plus empirical conversions; no occurrence records). Model-heavy.
- Nanozooplankton: **unclear**. The value is taken from Bar-On & Milo 2019 and has not been traced to its origin.
- Mesopelagic fish: comes straight from Proud 2019 (acoustic) and **duplicates** the Proud row.
- Fish (+cephalopods + benthic invertebrates): **allometry-derived** (size-spectrum ecosystem models). It is also **pristine (c.1850), not present-day**.
- Marine mammals: left to the mammals agent and not entered here.

## 4. Mesopelagic fish — Irigoien et al. 2014

- Citation: Irigoien X, Klevjer TA, Røstad A, et al. (2014) Large mesopelagic fishes biomass and trophic efficiency in the open ocean. *Nat. Commun.* 5:3271. doi:10.1038/ncomms4271
- URL: https://www.nature.com/articles/ncomms4271.pdf ; file `data/raw/irigoien2014/ncomms4271.pdf`
- Abstract: "With a current estimate of ~1,000 million tons, mesopelagic fishes likely dominate the world total fishes biomass. ... the previous estimate needs to be revised to at least one order of magnitude higher."
- Results: "If we consider the range between 25 and 75% quartiles of the literature db/weight ratios as a reasonable representation of the mesopelagic fishes around the world, our estimates of mesopelagic fishes biomass would range from 6,000–200,000 million tons, with median values between 11,000 and 15,000 million tons (Table 1). These estimates of mesopelagic fishes biomass limited to 40° N and 40° S are one order of magnitude higher than the previous global estimate of 1,000 million tons."
- method_class: **independent** (ship acoustics; the conversion uses literature backscatter-to-weight ratios, not body-size-to-density allometry). There is no single point estimate, so B_est is blank. The estimate covers 40°N–40°S only.

## 5. Mesopelagic fish — Proud et al. 2019

- Citation: Proud R, Handegard NO, Kloser RJ, Cox MJ, Brierley AS (2019) *ICES J. Mar. Sci.* 76:718–733. doi:10.1093/icesjms/fsy037 (metadata checked via Crossref)
- URL: https://academic.oup.com/icesjms/article/76/3/718/5021437 (read via WebFetch; PDF not saved)
- Abstract: "Estimates of global mesopelagic fish biomass vary substantially (between 1 and 20 Gt)." ... "Our estimates of biomass ranged from 1.8 to 16 Gt (25–75% quartile ranges)" ... "median values of S1 to S3 were 3.8, 4.6, and 8.3 Gt, respectively."
- method_class: **independent** (global 38 kHz backscatter plus a modelled target strength from swimbladder size distributions). Uses body size inside the acoustic scattering model, but not a density-from-size allometry. Moderate confidence.

## 6. Marine fish — Bianchi et al. 2021

- Citation: Bianchi D, Carozza DA, Galbraith ED, Guiet J, DeVries T (2021) Estimating global biomass and biogeochemical cycling of marine fish with and without fishing. *Sci. Adv.* 7:eabd7554. doi:10.1126/sciadv.abd7554 (PMC8500507); file `data/raw/bianchi2021/PMC8500507_fulltext.xml`
- Abstract: "The pre-exploitation global biomass of exploited fish (10 g to 100 kg) was 3.3 ± 0.5 Gt ... By the 1990s, biomass and cycling rates had been reduced by nearly half".
- Intro: "the wide range of estimates of global fish biomass, mostly from numerical models, which range from less than 1 Gt to more than 50 Gt (Fig. 1A)."
- Results: "it suggests a preindustrial global biomass of consumers between 10 g and 100 kg of 3.3 ± 1.7 Gt over LME regions and 6.9 ± 3.6 Gt globally".
- Table 1 caption: "All values represent means from the optimized ensemble ..." Global Commercial preindustrial 3.3 ± 0.5; Total 6.9 ± 3.6; Peak catch Commercial 1.1 ± 0.2 (footnote: "Values determined at the time of the global peak catch integrated over LME regions in the model.").
- Units: the methods describe "units of wet biomass processed per unit area per unit time", so I read biomass as wet.
- The meaning of ± is not defined in what I read → interval type 未確認.
- method_class: **allometry-derived** (BOATS is a size-spectrum model, with parameters fitted to catch data).

## 7. Marine fish — Jennings et al. 2008

- Citation: Jennings S, Mélin F, Blanchard JL, Forster RM, Dulvy NK, Wilson RW (2008) *Proc. R. Soc. B* 275:1375–1383. doi:10.1098/rspb.2008.0192 (PMC2602712). Only the abstract was available (NCBI efetch).
- Abstract: "suggests that the global biomass of marine animals more than 10^−5 g wet weight is 2.62×10^9 t (=8.16 g m−2 ocean) ... Fish biomass and production, for example, are estimated as 8.99×10^8 t (2.80 g m−2) and 7.91×10^8 t yr−1".
- method_class: **allometry-derived** (macroecological size-spectrum theory driven by satellite primary production and temperature).

## 8. Gelatinous zooplankton — Lucas et al. 2014

- Citation: Lucas CH, Jones DOB, Hollyhead CJ, Condon RH, Duarte CM, Graham WM, Robinson KL, Pitt KA, Schildhauer M, Regetz J (2014) *Global Ecol. Biogeogr.* 23:701–714. doi:10.1111/geb.12169. Wiley full text returned 403; the abstract was read from the Crossref API (https://api.crossref.org/works/10.1111/geb.12169).
- Abstract: "a total of 91,765 quantitative abundance data items from 1934 to 2011 were converted to carbon biomass using published biometric equations and species-specific average sizes." ... "the global geometric mean and standard deviation of total gelatinous biomass is 0.53 ± 16.16 mg C m−3, corresponding to a global biomass of 38.3 Tg C in the mixed layer of the ocean".
- method_class: **independent** (survey abundance data; size is used only to turn N into C). Caveat: JeDI records may also be in OBIS/GBIF. No global N given.

## 9. Prokaryotes and cyanobacteria (N)

- Whitman WB, Coleman DC, Wiebe WJ (1998) *PNAS* 95:6578–6583. doi:10.1073/pnas.95.12.6578. Abstract (NCBI efetch, PMC33863): "The number of prokaryotes and the total amount of their cellular carbon on earth are estimated to be 4–6 × 10^30 cells and 350–550 Pg of C ... Most of the earth's prokaryotes occur in the open ocean, in soil, and in oceanic and terrestrial subsurfaces, where the numbers of cells are 1.2 × 10^29, 2.6 × 10^29, 3.5 × 10^30, and 0.25–2.5 × 10^30, respectively."
- Flemming HC, Wuertz S (2019) *Nat. Rev. Microbiol.* 17:247–260. doi:10.1038/s41579-019-0158-9. Abstract (nature.com): "Most bacteria and archaea on Earth (1.2 × 10^30 cells) exist in the 'big five' habitats: deep oceanic subsurface (4 × 10^29), upper oceanic sediment (5 × 10^28), deep continental subsurface (3 × 10^29), soil (3 × 10^29) and oceans (1 × 10^29)." The full text is paywalled, so its uncertainty ranges are 未確認.
- Flombaum P, Gallegos JL, Gordillo RA, et al. (2013) *PNAS* 110:9824–9829. doi:10.1073/pnas.1307701110. Abstract (PMC3683724): "These niche models ... rely on >35,000 discrete observations from all major ocean regions. ... The annual mean global abundances of Prochlorococcus and Synechococcus are 2.9 ± 0.1 × 10^27 and 7.0 ± 0.3 × 10^26 cells, respectively."
- method_class: **independent** for all three (extrapolated from field cell counts; no body-size allometry). Whitman's subsurface total is outdated.

## 10. Not found / 未確認

- Copepods as a separate group: no global N or B found. Moriarty & O'Brien and Hatton cover mesozooplankton as a whole.
- Global number of individual fish: no primary estimate found.
- Cephalopods: no primary global estimate found. A search hit attributes ~0.05 Gt C to Rodhouse & Nigmatullin via the Bar-On/Milo site; this was not verified, and Bar-On rows belong to the baron2018 agent. In Hatton, cephalopods are lumped into "fish".
- Marine nematodes / benthic meiofauna: no global N found in the search. The Bar-On 2018 supplement may have a marine nematode component; check with the baron2018 agent.
- Corals, other euphausiids, freshwater fish, amphibians: no global N or B found.
- Number of described species: not compiled. None of these sources states it (krill = 1 species by definition).

## Points for human decision

1. Hatton: should we derive per-group N from the size-bin biomass (assumption-derived), or leave Hatton as biomass only?
2. Hatton's fish and mammal values are pristine (1850). Should they be excluded from a present-day census?
3. Mesopelagic fish (Irigoien 6–200 Gt vs Proud 1.8–16 Gt): which one is primary? They are not independent of each other in Hatton.
4. Is Proud's acoustic target-strength modelling "independent" (my call) or "mixed"?

---

## tierA — 種レベルの N（Tier A）と体重データベース

担当: tierA ／ 作業日: 2026-11-03
ルール: 値はすべて原典・補足資料・データリポジトリから読んだもの。tierA が自分で計算した値はそのつど「tierA 計算」と書く。

---

## 1. 鳥類: Callaghan, Nakagawa & Cornwell 2021 PNAS

- 引用: Callaghan CT, Nakagawa S, Cornwell WK (2021) Global abundance estimates for 9,700 bird species. *PNAS* 118(21): e2023170118. doi:10.1073/pnas.2023170118（PMC8166167、CC BY 4.0）
- 本文: Europe PMC の全文 XML → `data/raw/callaghan2021/PMC8166167_fulltext.xml`
- 補足資料（Europe PMC 経由で取得、変更なし）: `data/raw/callaghan2021/PMC8166167_supplementary.zip`（md5 f36c02029cc2224bfb5c44a95f72e4eb）。中身は SI Appendix PDF（`pnas.2023170118.sapp.pdf`）、Dataset S1（`pnas.2023170118.sd01.xlsx`）、図
- データとコード（Zenodo）: doi:10.5281/zenodo.4723365（v1）。取得したのは `data/raw/callaghan2021/zenodo_4723365/` の `Tables.zip`（md5 d20c2d78…）、`R.zip`（md5 c1238666…）、`readme.docx`。取得していないのは `Data.zip`（248 MB）、`Intermediate data files.zip`（5.4 GB）、`eBird data.zip`（8.7 GB）、`Figures.zip`
- 種別の表: `Tables/all_species_summary_table.csv` が 9,700 行（全種で学名が異なる）。列は Common name, Scientific name, Order, Family, 95% Lower CI, Abundance estimate, 95% Upper CI, Range adjusted, Training species。PNAS の Dataset S1 xlsx と照合し、9,700 種すべてで Abundance estimate が一致した（tierA が確認）。
  - Range adjusted: TRUE 6,969 / FALSE 2,731
  - Training species: TRUE 684 / FALSE 9,016
  - Abundance estimate がゼロの種が 5 つ。欠損はない。
- **種ごとの 95% CI は 9,700 種すべてにある。**

### 数値

| 項目 | 値 | 出典・方法 |
|---|---|---|
| 種数 | 9,700（"∼92% of all extant bird species"） | 要旨 |
| 総個体数（中央値） | "∼50 billion" | 本文 |
| 総個体数（平均） | "∼428 billion" | 本文："Compared with the median estimate, the mean estimate of the aggregated distribution for all birds in the world was ∼428 billion individual birds" |
| 種の中央値の合計 | 50,516,171,834 | tierA 計算（Dataset S1）。順序をそろえた合計（下記）なら、これが論文の中央値に当たる |
| 種の 95% 下限の合計 / 上限の合計 | 3.91×10⁹ / 2.75×10¹² | tierA 計算。**本文には数値の記載がない** |
| 総数の区間（批判論文が図から読んだ値） | "3.9 billion to 2,080 billion; figure 2 of ref. 1" | Robinson et al. 2022 |
| 種あたりの平均 / 中央値 | 520万 / 45万 | 本文："The average of all 9,700 global population estimates was 5.2 million, whereas the median was 450,000"（tierA の再計算でも 5,207,853 / 450,954.5 で一致） |

区間について: 上限は、tierA の合計（2,749 billion）と Robinson が図から読んだ値（2,080 billion）で食い違う。区間の作り方が違う可能性がある（たとえば図 2 は HDI）。統合のときは、種別の CI を使うか、論文の図の値を使うかを人間が決めてほしい。
論文の合計の仕方（逐語）: "we summed the species-specific distributions as described above, ensuring the distributions were ordered before summing (i.e., the smallest values or largest values are summed as we combined distributions)."

### 推定方法（Methods の逐語引用）

5 つのステップ:
> "Step 1 (Training data): Model the relationship between known (i.e., externally validated best available data) density estimates and relative abundance from eBird to derive a species-specific training model, while incorporating known error in the relative abundance estimates.
> Step 2 (Imputation data): Calculate a measure of relative abundance for all species in 5° grid cells throughout the world. For the training species, calculate density using the results from Step 1 in each unique grid a species occupies.
> Step 3 (Life history traits): Collate life history traits (bird color, flock size, body size, and International Union for Conservation of Nature [IUCN] status) that are likely to influence the relationship between the true population of a species and the relative abundance of a species calculated through eBird.
> Step 4 (Multiple imputation): Perform multiple imputation by chained equations to predict the density of a species and its uncertainty per grid cell, based on the known relationship between estimated density and observed relative abundance for our training species and the traits collated at Step 3.
> Step 5 (Calculate abundance): Use the predicted densities and uncertainties to derive a mean global density estimate for each species and multiply this density estimate by the observed area of a species—with extrapolation where necessary and possible—to calculate a simulated global abundance distribution."

訓練データ:
> "We used published abundance estimates from three sources: 1) the Partners in Flight Population Estimates Database ( 62 ); 2) population estimates from the British Trust for Ornithology ( 63 ); and 3) from BirdLife International Data Zone datazone.birdlife.org/home . We collated a total of 724 species for which we had estimated population abundance."

eBird の相対個体数:
> "we used the mean abundance across all checklists (including checklists when a species was not identified; zeros) as our measure of relative abundance."
> "For our analysis, we used the eBird basic dataset (version ebd_relMay2019). We aggregated eBird data from January 2010 to May 2019."

全種がグリッド単位で eBird に依存していること:
> "Within each grid (N = 579), we calculated the relative abundance of each species as defined above ... If a species was not observed in a grid (i.e., a relative abundance of 0), then we assumed that the species does not exist in that grid."

補完データセット（全種で eBird の相対個体数が使われ、体重が補助変数として入っている）:
> "Our 'imputation' dataset included 192,702 rows (grid × species) with 11 variables: 1) species ID (0% missing), 2) the log-transformed number of eBird checklists (0% missing), 3) the number of months a species was observed in that grid (0% missing), 4) relative abundance as described in detail above (0% missing), 5) flock size (0% missing), 6) IUCN status (8% missing), 7) body size (16% missing), 8) color distance from brown (40% missing), 9) color brightness (40% missing), 10) estimated density (79% missing), and 11) the SE for the density (79% missing). ... Our targets for imputation were density (at the specific grid level) and its SE (10 and 11), mainly informed from relative abundance (0% missing values) but also helped by the five auxiliary variables (5 through 9)."

体重:
> "For body size, we used the adult body mass (in grams) as extracted from ref. 87 ." （ref. 87 = Myhrvold N. P., et al., An amniote life-history database …）
> "A species' intercept showed strong correlation with body mass ( r = −0.467)"
> "For flock size, we used eBird to calculate the overall mean flock size among all presences in the dataset for each species."

面積:
> "We then calculated the total area occupied by each species in our analysis by summing the area of the number of grid cells each species was found in. ... for a species whose estimated range was not fully sampled by our eBird analysis ... we used the area of the total range size ... Estimated species' ranges were provided by BirdLife International. ... our range adjustment was not done for 2,731 species, in which case we assumed that the total area of their sampled grid cells approximates the total species range size."

訓練種の推定値も eBird のモデルを通して作り直されている（Step 2 "For the training species, calculate density using the results from Step 1"）。外部の専門家推定値をそのまま使ってはいない。

訓練データ側の出典の方法（SI Appendix の逐語引用）:
- PIF: "It predominantly relies on data from the North American Breeding Bird Surveys scheme, based on the decade 2006—2015"
- BTO: "We extracted population estimates from Musgrove et al. 2013 ... had a reliability of '1' or '2'"
- BirdLife: "These data are compiled by global experts for each species ... usually presented in standard bands of estimated ranges ... Where a standard band estimate was provided, we used the midpoint"

分類体系: コードは `Data/clements_clean.csv` を読み込んでおり（`R/get_species_specific_abundance_distribution_estimates.R` ほか）、eBird/Clements 体系を使っている。ebd_relMay2019 に対応する Clements の版番号は原典で確認できなかった（**未確認**）。

### method_class の判定: **occurrence-derived**（体重による部分的なアロメトリー成分あり）

理由:
1. 問いの (a) か (b) か → **(a) 全種**。9,700 種すべてで、密度は eBird の相対個体数（欠損 0%）を主な予測子にして推定され、面積も eBird のグリッド（または BirdLife の分布域）から作られている。訓練種 684 種の推定値も eBird のモデルを通している。
2. 体重は補完の補助変数になっている（欠損 16%）。論文自身も切片との相関 r = −0.467 を報告しており、体重は eBird と密度の関係を補正する役割を持つ。つまり、推定値には体重の情報が部分的に入っている。H1 で N と M のスケーリングを調べると、この成分が人工的な相関を生みうる。
3. 群れサイズも eBird から計算されている。
4. したがって、本プロジェクトの主解析（independent のみ）には使えない。CSV では method_class = occurrence-derived とし、体重成分は notes に書いた。"mixed"（occurrence + allometry）とすべきかは人間の判断を仰ぎたい。

### 批判と反論（原文を Europe PMC で確認）

- Robinson OJ, Socolar JB, Stuber EF, … Johnston A (2022) Extreme uncertainty and unquantifiable bias do not inform population sizes. *PNAS* 119(10): e2113862119. doi:10.1073/pnas.2113862119（PMC8915789 → `data/raw/callaghan2021/PMC8915789_fulltext.xml`）
  > "Abundance estimates ( 1 ) fell outside minimum–maximum ranges provided by BirdLife International for 81% of the 2,423 species with available estimates (27% below the minimum, 54% above the maximum)"
  > "96% of individual species had posterior uncertainty spanning three or more orders of magnitude."
  > "San Andres Vireo ( Vireo caribaeus ), used in model training with a population size of 2,500 to 10,000 mature individuals ( 4 ), was estimated as extinct ( 1 )."
- Callaghan CT, Nakagawa S, Cornwell WK (2022) Reply to Robinson et al.: Data integration will form the basis of future abundance estimates. *PNAS* 119(10): e2117920119. doi:10.1073/pnas.2117920119（PMC8915984）
  > "our modeled estimates are strongly correlated with BirdLife abundance estimates ( r = 0.72; Fig. 2 )" （2,860 種）
- 全鳥類を対象にした、より新しい種別の全球個体数推定は、ウェブ検索（2026-11）では見つからなかった。見つからなかったことは「存在しない」という確認ではない。

### 鳥類の代替案（未確認）

BirdLife/IUCN の専門家による個体数推定（多くは幅で示された値）が、eBird に依存しない種別の N の候補になりうる。Robinson et al. は 2,423 種、Callaghan の反論は 2,860 種を対応づけている。ダウンロードはしていない（Data Zone と IUCN API の利用条件を確認する必要がある）。

---

## 2. 鳥類の体重: AVONET（Tobias et al. 2022 Ecology Letters）

- 引用: Tobias JA, et al. (2022) AVONET: morphological, ecological and geographical data for all birds. *Ecology Letters* 25(3): 581–597. doi:10.1111/ele.13898
- figshare: doi:10.6084/m9.figshare.16586228.v7（更新日 2022-12-05）
- 取得ファイル: `data/raw/avonet/AVONET_Supplementary_dataset_1.xlsx`（md5 1445afdcfb6df784010c2ca034544bc8、figshare の computed_md5 と一致）、`data/raw/avonet/Supplementary_dataset_2.xlsx`（md5 7aaddac5…、一致）
- シートと行数: AVONET1_BirdLife 11,009 / **AVONET2_eBird 10,661** / AVONET3_BirdTree 9,993 / AVONET_Raw_Data / Mass_Sources / 2 つの対応表（BirdLife–eBird、BirdLife–BirdTree）
- AVONET2_eBird の分類体系（Metadata シートの逐語引用）: "eBird/Clements v2021 (Aug 2021)"。体重: "Body mass given as species average (incorporating both male and female body mass)"（単位 gram）。出典は Dunning 2008、EltonTraits、更新文献などで、Mass.Source 列に記録されている。
- **Callaghan の学名との一致（tierA が完全一致で照合）**: AVONET2_eBird 9,302/9,700、AVONET1_BirdLife 8,944/9,700、AVONET3_BirdTree 7,724/9,700。
  → **eBird 版（AVONET2）が Callaghan に合う。** 一致しない 398 種は、2019 年から 2021 年の Clements 改訂による属名の変更が主な原因（例: Oreothlypis → Leiothlypis、Sylvia → Curruca、Phalacrocorax の分割、Oceanodroma）。eBird の分類体系の改訂履歴（taxonomy update）で対応づける必要がある（未実施）。
- 注意: AVONET の体重の一部は推定値（Mass.Source が EltonTraits_Model、Inferred、DataFromSplit）。Callaghan が補完に使った体重は Myhrvold et al. のもので、AVONET ではない。

---

## 3. 哺乳類の種別個体数

### Greenspoon et al. 2023 PNAS（利用可能性のみ。詳細は Milo 担当）
- doi:10.1073/pnas.2204892120（Europe PMC で確認）
- `data/raw/greenspoon2023/mammal_biomass/results/wild_land_mammal_biomass_inluding_populations.csv`（別の担当が取得）: 4,795 行。列は binomial, biomass_g, biomass_g_97pt5, biomass_g_2pt5, estimated_population_2pt5, estimated_population, estimated_population_97pt5。**陸生哺乳類の種別 N と 95% 区間がある。**
- `results/results_by_method.csv`: "Population reports" 393 種、"Inferred using SVR" 4,413 種（合計 4,806 で、4,795 行と合わない。理由は**未確認**）
- `results/all_included_features_RMSE_table.csv`: SVR の特徴量は range、body_mass、trophic_level、red_list_status、order → 推定された部分は **allometry/trait-derived**。報告値の部分は IUCN などの個体数報告。全体としては **mixed**。
- estimated_population の合計 8.78×10¹⁰ は tierA 計算で、論文に記載された値ではない。
- 海生哺乳類: `results/wild_marine_biomass.csv`（121 行、biomass_Mt）。N の列は見当たらない（詳細は Milo 担当）。

### その他
- TetraDENSITY（Santini, Isaac & Ficetola 2018 GEB 27:787–791、doi:10.1111/geb.12756）: 局所的な**密度**（個体/km²）の文献集成で、N ではない。ダウンロードしておらず、原典も読んでいない（**未確認**）。TetraDENSITY 2.0（GEB 33: e13929）はウェブ検索で見ただけ（**未確認**）。
- COMBINE には `density_n_km2` 列があり、1,263/6,263 種に値がある（tierA が数えた）。これも密度。
- IUCN Red List の個体数欄: API トークンが必要なため、アクセスしていない（**未確認**）。
- 全球の種別 N を持つ哺乳類データセットは、Greenspoon 2023 以外に見つからなかった。

---

## 4. 哺乳類の体重: COMBINE（Soria et al. 2021 Ecology）

- 引用: Soria CD, Pacifici M, Di Marco M, Stephen SM, Rondinini C (2021) COMBINE: a coalesced mammal database of intrinsic and extrinsic traits. *Ecology* 102(6): e03344. doi:10.1002/ecy.3344（著者・巻号・ページは Europe PMC のメタデータで確認した。本文は読んでいない）
- figshare: doi:10.6084/m9.figshare.13028255.v4（更新日 2021-04-23）
- 取得ファイル（`data/raw/combine/`、すべて figshare の md5 と一致）: `trait_data_reported.csv`（6,263 行）、`trait_data_imputed.csv`、`trait_data_sources.csv`、`taxonomy_crosswalk.csv`、`trait_databases.csv`
- 分類体系の列: `iucn2020_binomial`、`phylacine_binomial`
- `adult_mass_g` の値: 6,033/6,263 種。reported 版と imputed 版で体重の値は同じ（体重は補完されていない。tierA が確認）
- Greenspoon 2023 の 4,795 種のうち 4,793 種が COMBINE の iucn2020_binomial と一致した（tierA が確認）

---

## 5. その他の分類群（存在の確認のみ）

- RAM Legacy Stock Assessment Database v4.66（Zenodo、2024-11-06、doi:10.5281/zenodo.14043031。Extended 版は 10.5281/zenodo.14043038）: 漁獲対象の資源（stock）ごとの資源評価のバイオマス。種の全球値ではなく、ダウンロードもしていない。
- 両生類・爬虫類: 全球の種別 N のデータセットは見つからなかった（検索は限定的）。

---

## 人間に判断してほしいこと

1. Callaghan 2021 を occurrence-derived とするか、mixed（occurrence + allometry）とするか。どちらにしても主解析からは外れ、Tier A の鳥類で independent な種別 N は今のところない。
2. 鳥類で eBird に依存しない N の代替として、BirdLife/IUCN の個体数推定（幅で示された値）を入手するか。
3. Callaghan の総数の区間: 種別 CI の合計（3.9×10⁹–2.7×10¹²）を使うか、Robinson が図 2 から読んだ値（3.9–2,080 billion）を使うか。
4. Greenspoon 2023 の哺乳類種別 N は、SVR で推定した部分（4,413 種）が体重を予測子にしているため allometry-derived。報告値の 393 種だけを independent として扱う案を検討してほしい。
5. Clements 2019 と 2021 の名前の対応（398 種）を、eBird の分類体系改訂の対応表で解決すること。

---

## Provenance notes — id `harmonized`（Phase 1 ゲート判断 3・5・7 と記載種数）

作成日 2026-11-03。対応ファイル：`harmonized.csv`（16行、22列＋`derived_formula`・`inputs`）、`docs/conversion_factors.csv`。
CSV は `scripts/harmonized/build_harmonized_csv.py` が生成する。数値はすべて、下の再計算出力・生データからそのまま写した。自分で計算した値は notes に「DERIVED」または「recomputed」と書き、式と入力の場所を `derived_formula`・`inputs` 列に入れた。

再現用スクリプト（プロジェクト内）：

| スクリプト | 役割 | 出力 |
|---|---|---|
| `scripts/harmonized/baron_subgroups.R` | Bar-On リポジトリの入力 xlsx から、部分群の B と1個体あたり質量をノートブック通りに再計算する | `data/derived/harmonized_baron_subgroups.txt` |
| `scripts/harmonized/run_rosenberg.py` | Rosenberg の Zenodo ノートブックを、必要なセルだけ無改変で実行する | `data/derived/harmonized_rosenberg_rerun_Nboot1e5_seed20261103.log` |
| `scripts/harmonized/col_counts.py` | ChecklistBank API に問い合わせ、生 JSON を保存する | `data/raw/checklistbank_col26.10/*.json`、要約は `data/derived/harmonized_col_species_counts.tsv` |

---

## 1. Bar-On 2018：B と N の範囲をそろえ直す（ゲート判断 3）

### 方法

* 対象は `data/raw/baron2018/biomass_distribution/`（commit 36cf0a80）。
* 各ノートブックの「N を計算するセル」で、割られる側の B（部分群のバイオマス）と、割る側の仮定個体質量を特定した。
* そのうえで、リポジトリの入力 xlsx から R で同じ計算をやり直した。
* 確認として、どの部分群でも「B ÷ 仮定質量」が `results.xlsx` の `Table S1`「Number of individuals」と有効数字6桁で一致した。

| 部分群 | B（再計算、g C） | 仮定質量（g C/個体） | B/質量 | results.xlsx の N |
|---|---|---|---|---|
| カイアシ類（中型動物プランクトンの節足動物） | 5.64617e14 | 4e-6 | 1.41154e20 | 1.41154e20 |
| ヒメミミズ類 | 1.92859e13 | 25e-6 | 7.71435e17 | 7.71435e17 |
| 翼足類 | 1.31985e14 | 2.65440e-4 | 4.97231e17 | 4.97231e17 |
| 浮遊性刺胞動物（クラゲ） | 4.0e13 | 2.03493e-3 | 1.96567e16 | 1.96567e16 |
| 中深層魚 | 5.17611e14 | 0.463939 | 1.11569e15 | 1.11569e15 |
| 線虫（全体） | 1.96117e13 | 5e-8 | 3.92233e20 | 3.92233e20 |

### 根拠（ノートブック本文の逐語引用）

* **海産節足動物**（`marine_arthropods.py` セル11の直前の markdown）："We consider only the mesozooplankton as they are the smallest group of marine arthropods ... we divide our estimate for the total biomass of mesozooplankton by an estimate for the characteristic carbon content of an individual copepod ... which range from 0.15 µg C to 100 µg C per individual. We use the geometric mean of this range, which is ≈4 µg C per individual"
  * コード：`marine_arth_num = meso_arth_biomass/copepod_carbon_content`
  * 保存された出力："Our best estimate for the biomass of mesozooplankton arthropods is ≈0.56 Gt C"
  * 食い違い：SI Table S14 には "Based on dividing the total biomass of each size category (mesozooplankton/macrozooplankton) by the characteristic carbon content of each class" とある。しかしコードは中型動物プランクトンだけを割っている。公表された N を作っているのはコードなので、コードに従った。
* **環形動物**："We consider only the Enchytraeids as they are ≈200-fold smaller than earthworms (Fierer et al.). We calculate the total biomass of Enchytraeids and divide it by the carbon content of Enchytraeids, which is ≈25 µg C (Fierer et al.)"
  * 内訳：平均ベース 2.20660e13、中央値ベース 1.68560e13、両者の幾何平均 1.92859e13 g C。
  * SI Table S16/S19 によると、Fierer の密度はもともと「個体数 ×（Petersen & Luxton の個体あたり C）」で作られている。したがって、ここでの N は元の個体数密度を戻しているのに近い。
* **軟体動物**："we consider the total biomass of pteropods and divide it by the average carbon content of a single pteropod ... Bednaršek et al. measured biomass of population densities pteropods per cubic meter. We divide these two measurements by one another"
  * 計算は「平均の比」で、比の平均ではない（8,814 行）。
  * 結果は 0.265 mg C。SI の「≈0.3 mg C」と整合する。
* **刺胞動物**："we divide the total biomass of jellyfish by the characteristic carbon content of a single jellyfish. We do not consider corals as they are colonial organisms ... We calculate the mean and median carbon content of all the species considered in the study, and use the geometric mean"
  * 中央値 0.556 mg C、平均 7.44 mg C（122 種）、幾何平均 2.03 mg C。
  * B は "Globally, they estimate ≈0.04 Gt C of gelatinous zooplankton, of which 92% are contributed by cnidarians. Therefore, we estimate the total biomass of plaktonic cnidarians at ≈0.04 Gt C."（0.92 は掛けていない）。
* **魚類**："we divide our estimate of the total biomass of mesopelagic fish by an estimate for the characteristic carbon content of a single mesopelagic fish ... Fock & Ehrich for the family Myctophidae ... We use the geometric mean of the weights of all species ... We convert wet weight to carbon mass assuming 70% water content and 50% carbon"
  * B = gmean(ソナー推定 1.78614e15, トロール推定 1.5e14) = 5.17611e14 g C。
  * 1個体の質量 = 3.093 g 湿重 × 0.15 = 0.464 g C（32 種）。
  * **コードの癖**：`np.mean([max, min])` に axis を指定していないため、全種・全値の平均体長 66.39 mm という1つの値をすべての種に使っている。種ごとの平均体長ではない。
  * 不確実性：`meso_CI = max(meso_inter_CI, sonar_CI)`。inter-method 側を、リポジトリの `geo_CI_calc`（ddof=1）で私が再計算すると 11.33 倍になる（保存出力は "≈11.3-fold"）。sonar 側は乱数を使い、出力は "≈9.5-fold"。したがって 11.33 を採用した。
* **線虫**：もともと N も B も線虫全体を指しているので、そろえ直しは不要。
  * 参考として、土壌部分だけの N（1.12233e20）を派生値として別行に出した（土壌の B 5.61166e12 g C ÷ 0.05 µg C）。
  * 海産部分 0.014 Gt C は仮定が多く、N の 71% を占める。

### 仮定した1個体質量の出典

いずれも Bar-On が引用しているもので、原典そのものは読んでいない（**未確認**）。

| 仮定 | 出典 |
|---|---|
| カイアシ類 | Viñas et al. 2010（doi:10.1590/S1679-87592010000200008）、Dai et al. 2016（doi:10.1016/j.jmarsys.2015.11.004） |
| ヒメミミズ類・線虫 | Fierer et al. 2009 Ecol Lett（doi:10.1111/j.1461-0248.2009.01360.x）。SI はさらに Petersen & Luxton 1982 を挙げている |
| 翼足類 | Bednaršek et al. 2012 ESSD（doi:10.5194/essd-4-167-2012）。データはリポジトリ内にあり、再計算は済み |
| クラゲ | Lucas et al. 2014 GEB。データはリポジトリ内にあり、再計算は済み |
| 中深層魚 | Fock & Ehrich 2010 J Appl Ichthyol（doi:10.1111/j.1439-0426.2010.01450.x）。データはリポジトリ内にあり、再計算は済み |

### 判断した点

* B の区間は、部分群について原典が出していないものは空欄にした。例えば海産節足動物の 10 倍は総量に対する値で、部分群には当てはめていない。
* 中深層魚の主値はゲート判断4で Irigoien 2014 に決まっている。この Bar-On の行は、N と仮定質量のために置いた。
* M = B/N は、どの行でも仮定質量そのものになる。これは phase1.md の問題1のとおりで、変わらない。

---

## 2. ダニ：Rosenberg 2023 の派生値（ゲート判断 5）

* **入力**：`data/raw/rosenberg2023/zenodo7565553.zip`（Zenodo 10.5281/zenodo.7502033）の `RawData.xlsx`、`aggregated biomes data.csv`、`results/tables/average_ind_mass_full.csv`。
* **実行環境**：システムの Python には pandas が入っていない。そこで、Zenodo の README に書かれたバージョン（Python 3.9、pandas 1.3.4、numpy 1.20.3）で、scratchpad に micromamba 環境を作った。R/renv には触れていない。
* **実行内容**：ノートブック `01-Main-Estimate...` のセル 0,1,3,5,7,9,10,12,13,15–19,21,23,34,44–47 を実行した。
  * 変更点：`%` マジックを削除、`save_bool=False`、RNG を固定（`default_rng(20261103)`、`np.random.seed(20261103)`）。
  * `N_boot = N_samps = 1e5` は原著のまま。
* **再現の確認**（同じ実行で得た値と、論文本文の値の比較）：

| 項目 | 今回の再実行 | 論文本文 |
|---|---|---|
| 土壌節足動物の個体数 | 1.0e19（5.0e18–1.8e19） | "≈1 × 10^19 (uncertainty range, 0.5 × 10^19 to 2 × 10^19)" |
| 土壌節足動物のバイオマス | 221（105–380）Mt | "≈200 (uncertainty range, 100 to 400)" |
| シロアリ | 99.9（48.8–168.5）Mt | "100 Mt; range, 50 to 170 Mt" |
| 非樹上性アリ | 4.6e16（1.7–9.2e16） | "5 × 10^16 (uncertainty range, 1 × 10^16 to 9 × 10^16)" |
| アリのバイオマス | 23.3（9.1–46.1）Mt | "≈25 Mt (uncertainty range, 10 to 50 Mt)" |
| トビムシ | 3.4e18（1.3–6.6e18） | "3 × 10^18 individuals; range, 1 × 10^18 to 6 × 10^18" |

* **ダニの結果（派生値）**：
  * N = 6.545e18（範囲 3.47e18–1.07e19）
  * B = 26.11 Mt 乾重（範囲 15.58–38.70）
  * 範囲の定義は論文 Methods に従った："calculated by taking the sum of the lower or upper bounds of the 95% confidence intervals for all such distributions"
  * 同じコードの Monte Carlo による 95% CI は、N 4.94–8.46e18、B 21.3–31.4 Mt。バイオームが独立と仮定しているので、幅は狭くなる。
  * 本文の割合とも整合する。"two-thirds" に対し 6.5/10、"about 10%" に対し 26/221。
* **M と湿重換算**：
  * M = B/N = 3.99 µg 乾重。
  * 湿重は、Rosenberg 自身が使う Acari の乾/湿 = 0.4 で割ると 65.3（39.0–96.8）Mt 湿重になる。0.4 の場所は `conversion_factors.csv` に書いた。
* **注意点**：
  * 個体数のデータしかないサイトでは、バイオマスは「タクソン平均の個体質量（Acari 0.00515 mg 乾重/個体）× 個体数」で作られている。そのため B と N は独立ではない。
  * 乱数による揺れは有効数字4桁目に出る（2,000 回リサンプルの試行では N 6.546e18、B 26.08）。

---

## 3. ミミズ：Phillips 2019 → **全球値なし**（ゲート判断 5）

試したことと、その結果：

| 試したこと | 結果 |
|---|---|
| iDiv 1804 v7（論文の DOI 10.25829/idiv.1804-5-2593） | 取得できた。中身はサイトレベルのモデルデータ `sWormModelData.csv` だけで、地図はない。`data/raw/phillips2019/idiv1804_v7_sWormModelData.zip` に保存 |
| iDiv 1818 v15（正誤表版データ 10.25829/idiv.1818-13-3001） | 取得できた。こちらも訂正版のサイトデータだけ。`idiv1818_v15_sWormModelData_correction.zip` に保存 |
| GitHub helenphillips/GlobalEWDiversity（commit 7149c8d）、Zenodo 10.5281/zenodo.3386456 | コードしかない。予測地図はローカルパス（`D:\sWorm\Results\Biomass\...predictedValues.csv`）から読んでおり、公開されていない |
| science.org の補足資料 | 403（Phase 1 と同じ） |
| figshare・Zenodo の検索 | 該当する地図は見つからなかった |

正誤表（著者リポジトリの `erratum_README.md`、逐語）：

> "Incorporation of the zero-sites has reduced our global estimates considerably. The mean global estimates are now, for richness 0.95 species (SD = 0.96; previously 2.42 species; SD = 2.19), for abundance 20.59 individuals per m2 (SD = 24.84; previously 77.89 individuals per m2; SD = 98.94), and for biomass 51.18 g per m2 (SD = 4881.2; median, 6.16; previously 2772.8 g per m2; SD = 1,312,782; median, 6.69)."

* これらは画素の単純平均であり（`11.1_ValuesFromMap.R` で `mean(all$V1)`）、面積で重み付けした合計ではない。陸域面積を掛けて全球値にすることはしなかった。
* 正誤表は Phase 1 の記録（`soil_arthropods.md` は旧値 77.89 を引用）を更新する情報なので、統合時に反映が必要。
* Science 誌上の正誤表本体は読めていない（**未確認**）。読んだのは著者リポジトリの文面だけ。

---

## 4. 換算係数（ゲート判断 7）→ `docs/conversion_factors.csv`

* **動物の基準**：C/湿重 = 0.15（Bar-On）。乾/湿 = 0.3、C/乾 = 0.5 の積で、Rosenberg の Discussion にも "Dry weight of 300 Mt is roughly equivalent to 1000 Mt of fresh weight (16) or 150 Mt of carbon (20)" とある。
* **Rosenberg の分類群別の乾/湿**（コードのセル5、"fine-tune taxa-specific conversion rates from wet to dry mass (from Petersen & Luxton)"）：

| 分類群 | 乾/湿 |
|---|---|
| Isoptera | 0.27 |
| Acari | 0.4 |
| Collembola | 0.32 |
| Formicidae | 0.228 |
| Araneae | 0.43 |
| Pseudoscorpiones | 0.224 |
| その他（既定値） | 0.3 |

  * Methods の記述："using a default value of 70% water content for groups with missing estimates"
  * SM 4.1："We use a conversion ratio of 0.27 from wet to dry biomass weight (16)"
  * 大元の Petersen & Luxton 1982 は読んでいない（**未確認**）。
* **トビムシ（Potapov）**：原典自身の換算 "c. 27.5 Mt C ... corresponds to c. 190 Mt fresh weight" を記録した。湿/C = 6.91（派生値）。
* **原核生物**：
  * Bar-On は細胞あたりの C（fg C cell^-1）しか扱っておらず、湿重への換算の基準は示していない（`bacteria_archaea/*/carbon_content/*.py` と SI を grep して確認）。
  * 代わりの根拠は2つ：
    * Bratbak & Dundas 1984 の抄録（Europe PMC、`data/raw/bratbak1984/europepmc_core_6508285.json`）："To convert bacterial biovolume into biomass (carbon content), we suggest that 0.22 g of C cm-3 should be used as a conversion factor." 同じ抄録は乾物率について "ranging from 31 to 57%" とも述べている。
    * Hatton 2021 のコード `phytoplankton_biomass_estimate.R` 107 行目："assuming 1 g wet weight = 1cm3 biovolume"。
  * この2つを組み合わせると C/湿 = 0.22 になる（派生値）。
  * 本文は ASM と Europe PMC の PDF がボット対策で取れなかったので、抄録だけを確認した。
* **感度分析用の代替**：Hatton 2021 のプランクトンの C→湿 ×10（C/湿 = 0.10）。コード94行目 "multiply by 10 to convert from carbon to wet weight"。その元になった文献（同論文の ref 73）は **未確認**。

---

## 5. 記載種数

* **出典**：Catalogue of Life 2026-10-14 の基本リリース（ChecklistBank データセット 316595、doi:10.48580/dgzh4）。拡張版の XR リリースは使っていない。
* **取得方法**：
  * `GET /dataset/316595/nameusage/search?q=<name>&type=EXACT&status=accepted` で、動物界の受理名に絞って taxon ID を得た。
  * 次に `GET /dataset/316595/taxon/<id>/metrics` の `speciesExtantCount`（現生の受理種数）を記録した。化石を含む数（`taxaByRankCount.species`）は notes に書いた。
  * 応答の JSON はすべて `data/raw/checklistbank_col26.10/` に保存してある。

| 群 | COL taxon | 現生種数 |
|---|---|---|
| Nematoda（門全体。土壌だけの数はない） | NM | 19,667 |
| Collembola | KZS5W | 8,926 |
| Acari = Acariformes + Parasitiformes | LK + LV | 22,635 + 6,382 = 29,017 |
| Formicidae | CLRKP | 14,438 |
| Termitoidae（= Isoptera） | C3V76 | 3,000 |
| ミミズ = Crassiclitellata | 84JRR | 1,994 |
| Enchytraeidae | 8KTLN | 840 |
| Copepoda | B8V3R | 15,297 |
| Pteropoda | 7NFFH | 141（化石を含めると 409） |
| Scyphozoa / Cubozoa / Staurozoa / Hydrozoa | B8V42 / B8V3T / B8V43 / B8V3X | 244 / 53 / 51 / 3,894 |
| Euphausia superba | 3CMD5 | 1 |
| Myctophidae | KVH45 | 252 |
| Mammalia | 6224G | 6,368 |
| Aves | V2 | 10,868 |

注意点と判断：

1. **網羅性に疑いがある（未確認）群がある**：
   * ダニ：COL 26.10 では "Acari" が受理名として存在しない。上位分類の扱いの違いと、収録データの欠けがある可能性がある。
   * ミミズ（Crassiclitellata 1,994）：亜綱 Oligochaeta 全体でも 4,432 種しかない。もう1つの目 "Opisthopora"（3Q4）は種数 0 だった。
   * 私の知識では、文献上の記載種数はダニもミミズもこれよりかなり多い。ただし本作業では文献の値を確認していないので、表には入れていない。
   * Zhang 2013（Zootaxa 3703）は Crossref にリンクがなく、取得できなかった（**未確認**）。
   * ダニとミミズは別の出典（例：Zhang 2011/2013 の表）で照合することを提案する。
2. **「クラゲ」の範囲**：Scyphozoa を主値にした。Lucas の gelatinous zooplankton にはヒドロクラゲも含まれるので、範囲をどう取るかで値は大きく変わる。
3. **中深層魚**：Bar-On が質量の計算に使った Myctophidae だけを数えた。中深層魚全体の科リストは、原典（Irigoien 2014）に定義がない。
4. **原核生物**：意図的に空欄にした。
