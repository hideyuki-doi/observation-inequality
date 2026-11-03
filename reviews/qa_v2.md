# QA v2: numerical claims in the manuscript and response letter

**Scope.** Every numerical claim in `manuscript/main.md` (abstract, significance statement, introduction, results, discussion, methods, figure legends) and in `reviews/response_to_reviewers.md`. Each was checked against `sim/*.csv`, `models/*.csv`, `data/derived/*.csv`, the SI tables (`manuscript/si_tables.md`, `manuscript/make_si_tables.R`), the rendered figures (`figs/rev_main_*.png`), the reviewer reports and `manuscript/references.bib`.

**Checked at:** commit b4bda1d, 2026-11-03.

**How values were checked.** Some values were recomputed read-only:
- Python on the CSVs, for:
  - the correlation, the record totals and the log R ~ log S fit
  - the vertebrate premiums
  - the T_detect floors and thresholds
  - the medians
- `Rscript`, for:
  - `tar_read(p5_S)`, `tar_read(ta_mam_report_d)` and an OLS refit
  - an arrow sum of `gbif_dataset_year.parquet` by basis of record
- `pdftotext` on Chapman (2009)

No project file other than this one was modified.

**Verdicts.**
- **OK:** matches the source at the stated precision.
- **MISMATCH:** the stated value or scope disagrees with the source.
- **UNSUPPORTED:** the text asserts something that the manuscript or the source does not contain or show.
- **NOT FOUND:** no source could be located.

Notes on OK rows are given in the last column.

## 1. Abstract

| # | Location (quoted phrase) | Claim | Source checked | Verdict | Correct value / note |
|---|---|---|---|---|---|
| A1 | "I compared 3.89 billion GBIF records" | 3.89 × 10⁹ | references_check.md (GBIF API: 3,887,364,403) | OK | |
| A2 | "spanning six orders of magnitude in abundance" | ~6 orders | census_main.csv: log10(4.4e20/7.8e14) = 5.75 | OK | |
| A3 | "a preregistered body-size exponent ... (0.72)" | β = 0.72 | models/tierB_summary.csv main/all 0.719 | OK | |
| A4 | "could not be distinguished from this ratio artefact" | within the null | sim/rev_ratio_null.csv: permuted 0.88 [0.69, 1.08]; P(perm ≤ obs) = 0.074 | OK | |
| A5 | "Records were unrelated to the number of individuals or to body mass but rose with the number of described species" | γ ≈ 0, δ ≈ 0, η > 0 | sim/rev_free_exponent.csv | OK | η = 0.43 [−0.02, 0.84]. The 95% CrI includes 0 in the main fit and in 5 of 8 sensitivity rows (P > 0 = 0.97). |
| A6 | "Birds and mammals received 2,000 and 50 times more records" | 2,000×, 50× | Recomputed from sim/rev_species_rates.csv (OLS of log R on log S over 9 groups) | OK | 1,914× and 54×, rounded to one significant figure; consistent with Results "1,900 and 54". |
| A7 | "DNA metabarcoding records were less biased toward large animals" | negative ratio slope | sim/rev_h4_contrast.csv: −0.44 [−0.80, −0.08] | OK | |
| A8 | "took 16 years for the most frequently recorded birds" | 16 yr | sim/rev_tdetect_phi_lambda.csv: birds (eBird) minimum T_a = 16 | OK | Applies to the eBird-record curve. Non-eBird birds: 23 yr. |
| A9 | "51 years for the most frequently recorded nematodes" | 51 yr | same file: soil_nematodes minimum T_a = 51 | OK | Above 100 records/yr the nematode curve uses the 10–100 stratum φ (the ≥100 stratum has only 3 species). |
| A10 | "fewer than about 0.3 records per year were undetectable within a century" | threshold ~0.3 | same file: all sets undetectable at λ ≤ 0.251 | OK | Thresholds lie at 0.25–0.40 for 9 sets and at 0.40–0.63 for nematodes, ants and enchytraeids. |
| A11 | "detected 8 of 14 declines" | 8/14 | sim/rev_validation_ukbms_summary.csv (method a) | OK | |
| A12 | "falsely flagged 9 of 34 other species" | 9/34 | same | OK | |
| A13 | "93–96% of nematode, mite and copepod species" | 93–96% | sim/rev_detectability_totals.csv: 96.1, 93.8, 92.9% | OK | |
| A14 | "75% of ants" | 75% | same: 74.6% | OK | |
| A15 | "36% of mammals" | 36% | same: 36.4% (4,727 mass-matched species) | OK | |
| A16 | "under 1% of birds" | <1% | same: 0.44% | OK | |
| A17 | "In exploratory analyses of all described species" (only exploratory label in the abstract) | labelling | SI §5–8; Tables S12, S13, S16, S18 titles | MISMATCH (labelling) | The free-coefficient model, the vertebrate premium, φ net of trends and the butterfly validation are also exploratory revision analyses but are not labelled in the abstract. |

## 2. Significance statement

| # | Location | Claim | Source | Verdict | Correct value / note |
|---|---|---|---|---|---|
| SG1 | "records are allocated roughly by the number of known species" | | Table S12, Fig. 1A | OK | |
| SG2 | "vertebrates receive far more records than invertebrates with similar numbers of species" | | 1,914× / 54× | OK | |
| SG3 | "detecting a 30% decline over a decade takes decades even for well-recorded species" | ≥ decades | minimum 16 yr (eBird birds) | OK | 16 yr is "decades" only loosely. |
| SG4 | "record-based trends agreed poorly with structured monitoring" | | r = 0.42; 9/34 false declines | OK | |
| SG5 | "More than nine in ten described nematode, mite and copepod species" | >90% | 92.9–96.1% | OK | |

## 3. Introduction

| # | Location | Claim | Source | Verdict | Correct value / note |
|---|---|---|---|---|---|
| I1 | "census estimates for ten animal groups" | 10 | Table S1; census_main.csv role = main (10 rows) | OK | |
| I2 | "Analyses beyond the preregistration are labelled exploratory." | labelling promise | see L1–L3 | MISMATCH (labelling) | Several revision analyses in the Results are not labelled (L1). |

## 4. Results

### Records follow species, not individuals

| # | Location | Claim | Source | Verdict | Correct value / note |
|---|---|---|---|---|---|
| R1 | "The ten groups ... (Table S1)" | group list | Table S1 | OK | |
| R2 | "spanned 5.8 orders of magnitude (7.8 × 10¹⁴ to 4.4 × 10²⁰ individuals)" | 5.8; range | census_main.csv | OK | 5.75 |
| R3 | "spanned only 1.6 orders (6.4 × 10⁴ to 2.5 × 10⁶" | 1.6; range | Table S1 / tb_R: 63,888–2,509,986 | OK | 1.59 |
| R4 | "8.45 million records in total" | 8.45 M | sum of tb_R$all = 8,453,569 | OK | |
| R5 | "β = 0.72 (95% credible interval [CrI] 0.49–0.94)" | | tierB_summary.csv: 0.719 [0.492, 0.944] | OK | |
| R6 | "by the preregistered criteria indicated scaling with limited precision, indistinguishable from the 2/3" | H1/H2 labels | Table S2 main row | OK | |
| R7 | "(r = −0.96)" | r(ln N, ln M) | census_main.csv main rows: −0.958 | OK | |
| R8 | "the same analysis would return β = 0.89" | | rev_ratio_null.csv constant_records_beta 0.886 | OK | |
| R9 | "randomly reassigning records among groups gave 0.88 (0.69–1.08) (Table S11)" | | rev_ratio_null.csv: 0.884 [0.691, 1.078] | OK | |
| R10 | "unrelated to abundance (coefficient −0.06, 95% CrI −0.87 to 0.65" | | rev_free_exponent.csv: −0.058 [−0.865, 0.648] | OK | **Consistency issue (see X1).** This run uses jellyfish S = 244 (`p5_S`). The SI's own "main (priors N(0,2))" row, with S = 297, gives −0.06 [−0.85, 0.71]. |
| R11 | "posterior probability that it is below 1 ... 0.996" | | P_lt1 = 0.996 | OK | |
| R12 | "body mass (0.01, −0.74 to 0.72)" | | 0.012 [−0.739, 0.716] | OK | S = 297 run: 0.01 [−0.72, 0.77] |
| R13 | "described species (0.43, −0.02 to 0.84 ...)" | | 0.431 [−0.015, 0.840] | OK | S = 297 run: 0.43 [−0.00, 0.87] |
| R14 | "posterior probability of a positive effect 0.97" | | P_gt0 = 0.971 | OK | |
| R15 | "(Fig. 1B,C; Table S12)" | | Fig. 1B and C, Table S12 | OK | |
| R16 | "correcting the taxonomic scope ... (0.48, 0.05–0.89)" | | rev_scope_free_exponent.csv: 0.481 [0.055, 0.887] | OK | |
| R17 | "counting unique sampling events ... (0.61, 0.12–1.07)" | | rev_events_free_exponent.csv: 0.612 [0.120, 1.071] | OK | Uses jellyfish S = 244 |
| R18 | "removing the three largest datasets ... (0.58, 0.27–0.87)" | | same: 0.582 [0.273, 0.870] | OK | Uses jellyfish S = 244 |
| R19 | "steeper and more certain" | | all three > 0.43 with CrI excluding 0 | OK | |
| R20 | "records scaled with described species richness to the power 0.59 (R² = 0.78; Fig. 1A)" | 0.59; 0.78 | Recomputed from rev_species_rates.csv (S = 297): slope 0.593, R² 0.777 | MISMATCH (text vs figure) | The text is right, but **Fig. 1A prints "slope 0.58 (R² = 0.77)"** and plots jellyfish at log10(244). The figure is stale (pre-Cubozoa) and needs regenerating. |
| R21 | "a nematode species received 0.85 records per year ... an ant species 7.0" | | rev_species_rates.csv R_per_species: 0.846, 6.95 | OK | Table S13 shows 0.8 (1 dp). |
| R22 | "about 9,000 times more nematodes than ants (Table S13)" | ~9,000 | census_main.csv: 4.4e20/5e16 = 8,800 | OK | N is not in Table S13; cite Table S1. |

### Vertebrates receive far more records per species

| # | Location | Claim | Source | Verdict | Correct value / note |
|---|---|---|---|---|---|
| R23 | "Birds and mammals received 1,900 and 54 times more records" | | recomputed residuals: 1,914×, 54.4× | OK | |
| R24 | "6,800 and 240 records per species per year" | | rev_species_rates.csv: 6,813, 240.8 | OK | Table S13 lists birds as 10,868 described species but 11,244 recorded species (recorded > described). With S = 11,244 the rate would be about 6,600. |
| R25 | "compared with 0.85–23 in the multi-species invertebrate and fish groups" | | 0.85 (nematodes) to 23.4 (jellyfish) | OK | |
| R26 | "across 388 species ... abundance to the power 0.64 (SE 0.05) and ... body mass to the power 0.20 (0.04) (Table S3)" | | OLS refit on tar_read(ta_mam_report_d): n = 388; 0.641 (0.047); 0.196 (0.044) | OK | Exploratory per Table S3, but unlabelled in text (L1). |

### DNA metabarcoding records are less size-biased

| # | Location | Claim | Source | Verdict | Correct value / note |
|---|---|---|---|---|---|
| R27 | "(posterior probability 0.935; Table S2)" | | models/tierB_h4.csv main 0.935 | OK | |
| R28 | "slope −0.24 per order of magnitude, 95% interval −0.42 to −0.06" | | rev_h4_contrast.csv: −0.236 [−0.416, −0.057] | OK | |
| R29 | "(−0.44, −0.80 to −0.08)" | | −0.436 [−0.798, −0.078] | OK | |
| R30 | "a single dataset contributing 45% of DNA-derived records" | 45% | Table S10: 931,748/(931,748 + 1,130,734) = 45.2% | OK | For the ten groups only (tb_R/rev_events_datasets): 45.5–46.0% |
| R31 | "(−0.11, −0.32 to 0.09; Fig. 3B; Table S14)" | | −0.112 [−0.322, 0.093] | OK | |

### How often a species must be recorded

| # | Location | Claim | Source | Verdict | Correct value / note |
|---|---|---|---|---|---|
| R32 | "φ = 0.69, 0.66–0.71" | | sim/phi_estimate.csv: 0.689 [0.664, 0.713] | OK | |
| R33 | "took 43–46 years however many records a species had" | 43–46 yr at any λ | sim/tdetect_grid.csv (E_flat, φ = 0.689) | MISMATCH (scope) | 43–46 yr holds only for λ ≥ ~100 records/yr in 9 groups. At λ = 10: 45–53 yr. At λ = 1: 49–76 yr. Krill: floor 51 yr, 51–83 yr at λ ≥ 100. Suggest "converged on 43–46 years for frequently recorded species (≥100 records/yr; krill excepted)". |
| R34 | "T ≈ [12(z_α + z_β)²/(φd²)]^(1/3), which gives 43.9 years (Table S15)" | 43.9 | rev_detection_analytic.csv φ = 0.69, λ = ∞: 43.89; hand check with z = 1.645 + 0.842 | OK | |
| R35 | "overdispersion was lower for rarely recorded species and higher for frequently recorded ones (Fig. 2B; Table S16)" | direction | rev_phi_species_summary.csv: φ (NB shape) rises with record rate | MISMATCH (direction) | A higher NB shape φ means *less* overdispersion. Correct: "φ was lower (overdispersion higher) for rarely recorded species and higher (overdispersion lower) for frequently recorded ones". This also contradicts the text's own usage in the butterfly paragraph ("overdispersion was much lower (median φ = 32)") and in the Discussion. Reviewer 4 c.3 and Response R4.3 likewise say overdispersion *falls* with record rate. |
| R36 | "φ rose from 0.66 to 3.0 in mammals" | | mammals linear: 0.656 → 3.002 | OK | |
| R37 | "from 1.5 to 13.8 in eBird bird records" | | 1.488 → 13.794 | OK | |
| R38 | "16 years for eBird bird records" | | rev_tdetect_phi_lambda.csv minimum 16 | OK | |
| R39 | "26 years for mammals and copepods" | | minimum 26 and 26 | OK | |
| R40 | "41 years for mites" | | minimum 41 | OK | |
| R41 | "51 years for nematodes (Fig. 2A)" | | minimum 51 | OK | |
| R42 | "fewer than 0.25–0.4 records per year could not be detected within 100 years" | threshold 0.25–0.4 | last undetectable grid λ: 0.251 (9 sets), 0.398 (nematodes, ants, enchytraeids) | OK | True as stated, but the threshold for those three groups lies at 0.40–0.63. |
| R43 | "median lag-1 correlation 0.07–0.50 across groups for species recorded more than 100 times per year" | 0.07–0.50 | Table S16 / rev_phi_species_summary.csv (ac1_linear is a median), ≥100 rows | MISMATCH | Table S16 ≥100 rows range from **0.02** (mesopelagic fish, 7 spp.) to 0.50. 0.07–0.50 holds only if strata with fewer than 10 species are dropped, which is not stated. |
| R44 | "with an autocorrelation of 0.44 the effort-offset method flagged false declines in 17–21% of stable series rather than 9–12% (Table S17)" | 17–21% vs 9–12% | rev_autocorrelation.csv | MISMATCH (scope) | True only at 10 and 100 records/yr: 16.9–21.1% vs 8.7–11.7%. At 1 record/yr: 9.2–11.7% vs 5.3–7.7%. Add "for species with ≥10 records per year". |
| R45 | "a decline would have to exceed 96% to be detected with power 0.8 at φ = 0.69" | 96% | rev_detection_analytic.csv: 0.963 (λ = ∞); 0.967 at λ = 10 | OK | |
| R46 | "detected after 44 years, 79% of the population has been lost (Table S15)" | | T = 43.9, lost 0.791 | OK | |

### Record-based trends vs structured monitoring

| # | Location | Claim | Source | Verdict | Correct value / note |
|---|---|---|---|---|---|
| R47 | "48 British butterfly species from 2000 to 2019" | 48 | rev_validation_ukbms_species.csv (48 rows); summary n_species 48 | OK | |
| R48 | "(median φ = 32)" | 32 | rev_validation_ukbms_species.csv median phi_a = 32.25 | OK | Not shown in Table S18, which is cited for the paragraph; give its source. |
| R49 | "correlated only moderately with monitored trends (r = 0.42)" | | pearson 0.416 | OK | |
| R50 | "detected 8 of 14 ... flagged 9 of 34" | | method a: 8/14, 9/34 | OK | |
| R51 | "Relative reporting rates detected 11 declines but flagged 20 false declines and 11 trends of the wrong sign" | | method b: 11, 20, 11 | OK | |
| R52 | "raw record counts detected none" | | method c: 0/14 | OK | |

### Most small animal species are recorded too rarely

| # | Location | Claim | Source | Verdict | Correct value / note |
|---|---|---|---|---|---|
| R53 | "96% of nematode species" | | rev_detectability_totals.csv 96.1% | OK | |
| R54 | "94% of mite species" | | 93.8% | OK | |
| R55 | "93% of copepod species" | | 92.9% | OK | |
| R56 | "90% of springtails" | | 89.6% | OK | |
| R57 | "86% of enchytraeids" | 86% | 0.85476 → **85.5%** (Table S19) | MISMATCH (rounding) | **85%**. 85.48% rounds to 85; 86 comes from double rounding via 85.5. |
| R58 | "75% of ants" | | 74.6% | OK | |
| R59 | "56% of jellyfish" | | 55.9% | OK | |
| R60 | "39% of mesopelagic fishes" | | 39.3% | OK | |
| R61 | "36% of mammals" | | 36.4% | OK | |
| R62 | "0.4% of birds" | | 0.44% | OK | |
| R63 | "89% of nematodes, 87% of mites and 88% of copepods" (no records 2015–2024) | | rev_species_rates.csv share_zero 88.8, 87.0, 87.5% | OK | |
| R64 | "detectable within 25 years for 89% of bird species" | | within_25 = 89.2% | OK | |
| R65 | "for almost no invertebrate species" | | 0% in all invertebrate groups except jellyfish (5.7%) | OK | |
| R66 | "raised the undetectable share of these groups to 97–99% (Table S20)" | 97–99% | rev_scope_variants.csv: 96.6/97.3% (scope), 97.7/98.6% (alternative S) | OK (metric caveat) | Table S20 uses "< 0.32 records/yr", not the group detection curves behind the 96%/94% main values. Like-for-like main-rule shares below 0.32 are 94.3% (nematodes) and 93.8% (mites). |
| R67 | "using higher counts of described species [@chapman2009]" | source of 29,000 / 55,000 | docs/provenance_parts/richness.csv; sim/rev_scope_variants.R comment; Chapman 2009 PDF | MISMATCH (citation) | The 29,000 (Nematoda) and 55,000 (Acari) counts come from **Hodda 2022b (Zootaxa 5114:290–317)**. Chapman (2009) gives <25,000 nematodes and 48,200 Acarina. Hodda 2022b is not in references.bib. |

### Simple analyses produce spurious trends

| # | Location | Claim | Source | Verdict | Correct value / note |
|---|---|---|---|---|---|
| R68 | "In preregistered simulations without decline" | prereg label | PREREG_en.md §5 (control d = 0; by-products) | OK | The by-rate binning was added in revision. |
| R69 | "flagged significant declines in 45–48% of series for species recorded at least ten times per year" | | Table S5 (b) ≥10: 47.1, 47.5, 45.3% | OK | |
| R70 | "flagged significant increases in up to 41% of series" | | Table S5 (c) up, max 40.8% | OK | |
| R71 | "flagged false declines in 2–12% of series even with independent years (Table S5)" | | Table S5 (a): 1.8–11.8% | OK | |

## 5. Discussion

| # | Location | Claim | Source | Verdict | Correct value / note |
|---|---|---|---|---|---|
| D1 | "Across ten animal groups ... unrelated to how many individuals exist" | | Table S12 | OK | |
| D2 | "the size scaling that I preregistered, which matched the optical expectation of 2/3" | | Table S2 H2 label | OK | |
| D3 | "Within mammals ... records did track abundance, while body size had a weak effect" | | Table S3 (0.64; 0.20) | OK | |
| D4 | "from about 16 years for the best-recorded birds to about 50 years for the best-recorded nematodes" | 16; ~50 | 16; 51 | OK | |
| D5 | "unbounded for species recorded less than once every three years" | <0.33/yr | all curves undetectable at λ ≤ 0.251 | OK | Same caveat as R42. |
| D6 | "More than nine in ten ... against fewer than one in a hundred bird species" | | 92.9–96.1%; 0.44% | OK | |
| D7 | "Within the ten-year window of IUCN criterion A, record-based detection is possible only for catastrophic declines" | | ≥96% (φ = 0.69); ≥67% even at φ = 6 (Table S15) | OK | |
| D8 | "overdispersion fell several-fold" (occupied cells) | | Table S6: φ_cells/φ_records = 1.3–41× | OK | Uses the correct semantics, which contradicts R35. |
| D9 | "detection times shortened for frequently recorded species (Fig. S3)" | | Table S6 ≥10 stratum: 3–18 yr shorter | OK | |
| D10 | "(to 10–15 years for 100 species)" | | sim/explore_multispecies.csv K = 100, 30%: 15, 12, 10, 10 | OK | |
| D11 | "the assumed individual masses of five groups are crude" | 5 | five Bar-On groups (SI §2) | OK | |
| D12 | "counting sampling events gave the same conclusion" | | Table S12 events row | OK | |
| D13 | "species recorded less than about once a year" (recommendation) | | | OK | A recommendation, deliberately above the 0.25–0.4 detection threshold. |
| D14 | "(Table S15 gives the conversion)" | | Table S15 | OK | |
| D15 | Discussion on metabarcoding [@yates2021] | soil/marine caveat promised in response R1.8 | main.md lines 90–100 | UNSUPPORTED | See RL22. |

## 6. Materials and Methods

| # | Location | Claim | Source | Verdict | Correct value / note |
|---|---|---|---|---|---|
| M1 | "PREREG v1.0, commit 01a2fe7, 3 November 2026" | | `git log`: 01a2fe7 2026-11-03 07:28 "PREREG v1.0 finalized" | OK | |
| M2 | "only independent estimates entered the census analyses (Table S1)" | | census_main.csv role = main: all independent | OK | |
| M3 | "carbon-to-wet-mass ratio of 0.15" | | census_main.csv conversion notes | OK | |
| M4 | "3.89 × 10⁹ records" | | GBIF API 3,887,364,403 | OK | |
| M5 | "3.75 × 10⁹ after excluding absences and fossils" | 3.75 × 10⁹ | arrow sum of data/derived/gbif_dataset_year.parquet = 3,750,353,035, which still includes FOSSIL_SPECIMEN = 10,256,649 (R/gbif.R filters only ABSENT) | MISMATCH | 3.75 × 10⁹ is the count **after excluding absences only**. Excluding fossils as well gives **3.74 × 10⁹** (3,740,096,386). Same error in SI §3. |
| M6 | "500–1,000 replicates" | | rev_tdetect_phi_lambda.R n_rep = 500; Table S5/S17 1,000 | OK | |
| M7 | "ln R_g ~ Normal(a + γ ln N_g + δ ln M_g + η ln S_g, √(τ² + 1/R_g))" | | SI §5; sim/rev_free_exponent.R | OK | |
| M8 | "British butterfly trends ... (2000–2019) ... site fixed effects" | | SI §7; rev_validation_ukbms.R | OK | |
| M9 | "R [@rcore2026]" | | references.bib; SI §10 R 4.6.1 | OK | |

## 7. Figure legends and figures

| # | Location | Claim | Source | Verdict | Correct value / note |
|---|---|---|---|---|---|
| F1 | Fig. 1A "line, slope 0.59" | 0.59 | figs/rev_main_1_records.png annotation: "slope 0.58 (R² = 0.77)"; jellyfish plotted at log10 S = 2.39 (244) | MISMATCH | The figure is stale. Regenerating with S = 297 gives 0.59 (R² 0.78). |
| F2 | Fig. 1B "the ten groups with independent censuses" | 10 points | PNG | OK | |
| F3 | Fig. 1C "Coefficients ... of an errors-in-variables model" | | PNG matches rev_free_exponent.csv | OK | Built from the S = 244 run (X1). |
| F4 | Fig. 2A "Lines at the top denote no detection within 100 years" | | PNG (plotted at 105) | OK | Floors visible: nematodes ~51, mites ~41, ants ~30, mammals ~26, eBird 16. |
| F5 | Fig. 2B "Overdispersion of annual record counts by record rate" | axis | PNG y-axis "overdispersion φ" | OK (wording) | φ is the inverse of overdispersion; label it "NB shape φ (higher = less overdispersed)". See R35. |
| F6 | Fig. 2C "48 British butterfly species" | | PNG; r = 0.42, 8/14, 9/34 annotated | OK | |
| F7 | Fig. 3A/B (exploratory) | | PNG; B top = metabarcoding/eDNA, bottom = iBOL; slopes −0.44 and −0.11 | OK | |
| F8 | Fig. 1 and Fig. 2 legends | labelling | both show only revision analyses | MISMATCH (labelling) | Only Fig. 3 is labelled exploratory. Figs. 1 and 2 (free EIV, φ net of trends, UKBMS) are exploratory too. |

## 8. Cross-references, citations and labels

| # | Item | Source | Verdict | Note |
|---|---|---|---|---|
| C1 | Table S1, S2, S3, S5, S11, S12, S13, S14, S15, S16, S17, S18, S19, S20 cited in main text | si_tables.md | OK | All exist and contain the cited quantity, except: R22 (N ratio is in Table S1, not S13) and R48 (φ = 32 is not in Table S18). |
| C2 | Fig. S3 cited in main text; Figs. S1–S5 | si_methods.md; figs/*.png all present | OK | |
| C3 | Tables S7–S10, Fig. S2, SI §1/§4/§6/§11, `docs/taxon_scope_variants.csv`, `sim/rev_monotonicity_summary.csv`, `PREREG_en.md` cited in response | files exist | OK | |
| C4 | All [@key] in main.md (37 keys) and si_methods.md (9) exist in references.bib | grep vs bib keys | OK | 40 unique keys; none missing. `@kyoto-u` in the e-mail address is not parsed as a citation (checked in main_v2.docx). |
| C5 | [@chapman2009] for alternative species counts | | MISMATCH | See R67. Should be Hodda 2022b (not in the bib). |
| L1 | Exploratory revision analyses reported without an "exploratory" label in the Results: ratio null (S11), free-coefficient EIV (S12), records ∝ S^0.59 and vertebrate premium (S13), within-mammal OLS (S3, labelled exploratory in the table), autocorrelation (S17, labelled in the table), IUCN-window metrics (S15) | SI §1 "every analysis added in revision is labelled exploratory"; SI §5–6 headings | MISMATCH (labelling) | The labels exist in the SI but not in the main text. |
| L2 | "In the preregistered analysis" (H4), "In the preregistered simulations" (φ = 0.69), "In preregistered simulations without decline" (Table S5) | PREREG_en.md §3, §5 | OK | |
| L3 | "(exploratory)" on DNA ratio, φ per species, UKBMS validation, described-species detectability, Fig. 3 | SI §5–8 | OK | |

## 9. Internal-consistency problems in SI and outputs that affect quoted numbers

| # | Issue | Evidence | Verdict | Correct value / note |
|---|---|---|---|---|
| X1 | Different runs use different jellyfish species counts. The main free-coefficient model (main text R10–R14, Fig. 1C), the events model and the top-3 model use S = 244 (Scyphozoa only). SI §3, Table S13/S19, the scope model and the sensitivity "main" row use 297. | `tar_read(p5_S)` jellyfish = 244; sim/rev_free_exponent.R and rev_events_datasets.R do not override; rev_free_sensitivity.R and rev_scope_variants.R set 297 | MISMATCH | With S = 297: γ −0.06 [−0.85, 0.71], δ 0.01 [−0.72, 0.77], η 0.43 [−0.00, 0.87], P > 0 0.97. Table S12 shows both "main" rows without explanation. The conclusions are unchanged, but text and figure should be rerun or footnoted. |
| X2 | Number of metabarcoding/eDNA datasets | Table S10: 147 (1,130,734 records). SI §3: "148 datasets". dna_dataset_types.csv: 147 metabarcoding + 1 reference. | MISMATCH | 147 |
| X3 | Birds: Table S13 described 10,868 < recorded 11,244 | rev_species_rates.csv | MISMATCH (data) | The denominator is inconsistent with the recorded set (names outside COL). It affects "6,800 records/species/yr" (~6,600 with 11,244). |
| X4 | Table S19 species counts (birds 9,269; mammals 4,727) differ from Table S13 (10,868; 6,368) | SI §8 explains mass-matched subsets | OK (needs caption) | Add "species with body masses" to the Table S19 caption. |
| X5 | Divergent transitions not reported | rev_free_exponent.csv: "N + M + log S + soil" 28 divergences; "N + M + soil" 2 (the latter quoted in response R1.2) | UNSUPPORTED (diagnostics) | Report or refit. |
| X6 | Table S16 shows strata with ≥5 species; the T_detect curves use only strata with ≥10 (rev_tdetect_phi_lambda.R) | | OK (needs note) | Explains R43. State the n ≥ 10 rule in SI §6. |

## 10. Response to reviewers

| # | Location (quoted phrase) | Claim | Source | Verdict | Correct value / note |
|---|---|---|---|---|---|
| RL1 | Summary 1: "Five reviewers showed that it is a ratio artefact" | 5 reviewers | reviewer_1–6.md | MISMATCH | **Four**: R1 (comment 1), R3 (comment 1), R5 (summary point 1) and R6 (comment 2). R2 found β robust ("reassures me about β") and R4 deferred on scaling. |
| RL2 | "collinear (r = −0.96)" | | census_main.csv −0.958 | OK | |
| RL3 | "Constant records give β = 0.89, and permuted records give 0.88 [0.69, 1.08]" | | rev_ratio_null.csv | OK | |
| RL4 | "(γ = −0.06 [−0.87, 0.65]) and body mass (0.01 [−0.74, 0.72]) ... (0.43; P > 0 = 0.97)" | | rev_free_exponent.csv | OK | S = 244 run (X1) |
| RL5 | "scope corrections (0.48 [0.05, 0.89]) ... sampling events (0.61 [0.12, 1.07]) ... three largest datasets (0.58 [0.27, 0.87])" | | rev_scope/events CSVs | OK | |
| RL6 | "and under all census and prior alternatives (Table S12)" | | rev_free_sensitivity.csv: η 0.42–0.46, P > 0 0.97–0.98 | OK | |
| RL7 | Summary 2: "1,900 and 54 times ... (N^0.64)" | | recomputed; Table S3 | OK | |
| RL8 | Summary 3: "reproduces the simulated 44 years" | | analytic 43.9; constant-effort sim 44 at λ = 100 | OK | |
| RL9 | "from 0.66 to 3.0 in mammals and 1.5 to 13.8 in eBird birds" | | rev_phi_species_summary.csv | OK | |
| RL10 | "range from 16 years (eBird birds) to 51 years (nematodes)" | | rev_tdetect_phi_lambda.csv | OK | |
| RL11 | "Autocorrelation raises false declines to 17–21%" | | rev_autocorrelation.csv | MISMATCH (scope) | Only at ≥10 records/yr. At 1 record/yr: 9–12%. See R44. |
| RL12 | "96% minimum detectable decline in 10 years, and 79% lost at detection" | | Table S15 | OK | |
| RL13 | Summary 4: "r = 0.42 ... 8 of 14 ... 9 of 34" | | UKBMS summary | OK | |
| RL14 | Summary 6: "(−0.44 [−0.80, −0.08]) ... (−0.11 [−0.32, 0.09])" | | rev_h4_contrast.csv | OK | |
| RL15 | Summary 8: "(50 species)" | | Table S7 census_independent n = 50 | OK | |
| RL16 | Summary 8: "the GBIF total is 3.89 × 10⁹ records" | | GBIF API | OK | See M5 for the 3.75 × 10⁹ qualifier. |
| RL17 | R1.2: "γ = 0.18 [−1.10, 1.18], η_soil = 0.75 [−2.0, 3.6]" | | rev_free_exponent.csv "N + M + soil" | OK | That fit had 2 divergent transitions (X5). |
| RL18 | R1.3: "Correcting jellyfish mass by ×50 changes nothing" | | η 0.42 [−0.00, 0.83] | OK | |
| RL19 | R1.3: "raise undetectable shares to 97–99%" | | Table S20 | OK | Metric caveat as R66. |
| RL20 | R1.5: "excluding them changes φ only modestly" | | Table S16 mammals vs no machine obs.: 0.66/1.25/3.00 vs 0.62/1.30/3.79 | OK | +26% in the ≥100 stratum |
| RL21 | R1.6: "N^0.64, SE 0.05" | | OLS refit 0.641 (0.047) | OK | |
| RL22 | R1.8: "The soil/marine imbalance of metabarcoding datasets remains a caveat, stated in the Discussion." | | main.md Discussion (lines 88–102): no such caveat | UNSUPPORTED | Add the caveat to the Discussion or amend the response. |
| RL23 | R1 minor: "The sensitivity range is now reported as 0.59–0.84 (Table S2)." | | main.md, si_methods.md: no such range stated. Table S2 β(all) spans 0.59–1.27 | NOT FOUND | 0.59–0.84 is the range only after excluding S2/S9 (adding vertebrates/removing eBird) and S12 (prokaryotes). State the range and its scope in SI, or amend the response. |
| RL24 | R1.7: "Posterior predictive coverage is 10/10" | | rev_free_sensitivity.csv ppc_95_coverage = 1 for all variants | OK | |
| RL25 | R2.1: "reduces krill from 95,798 records to 8,447 events" | | rev_events_datasets.csv | OK | |
| RL26 | R2.2: "Top-3 dataset shares range from 0.29 to 0.91" | | 0.288–0.909 | OK | |
| RL27 | R2.2: "(0.58 [0.27, 0.87])" | | rev_events_free_exponent.csv | OK | |
| RL28 | R2.4: "iBOL is one dataset with 0.93 million records" | | Table S10 931,748 | OK | |
| RL29 | R2.4: "against 148 metabarcoding/eDNA datasets with 1.15 million (Table S10)" | 148; 1.15 M | Table S10: metabarcoding 147 datasets, 1,130,734 records | MISMATCH | **147 datasets, 1.13 million records.** The 148 / 1.15 M figures include the EUKARYOME reference database (1 dataset, 20,701 records), which the same sentence says is excluded. |
| RL30 | R2.4: "GenBank-derived records without the extension remain unclassified as DNA; this is stated." | | main.md and si_methods.md: no mention of GenBank | UNSUPPORTED | Add it to SI §3, or amend the response. |
| RL31 | R2.5: "Jellyfish species now include Cubozoa (297)" | | Table S13/S19 | OK | Not yet propagated to the main free model, events/top-3 models or Fig. 1 (X1, F1). |
| RL32 | R2.6: "species record rates behind Fig. 3A are robust to the period used" | | reviewer_2.md l.236 (±1.8 points) | OK | |
| RL33 | R2.8: "duplication of up to 14% changes ln R by at most about 0.15" | | reviewer_2.md isInCluster max 14.3% (ants); −ln(1 − 0.143) = 0.154 | OK | |
| RL34 | R2.8: "This is stated as a limitation." | | main.md limitations paragraph: no mention of duplicates/clusters | UNSUPPORTED | Add it or amend the response. |
| RL35 | R2.9: "The main census analysis uses 8.45 million records, and this is stated." | | main.md l.39 | OK | |
| RL36 | R3.5: "The simulated floor agrees with it to within 0–2 years." | | analytic 43.9 vs simulated 43–46 (9 groups, λ ≥ 100) and 44 (constant effort) | OK | Krill floor 51 (H3 effort-mapping artefact) excepted. |
| RL37 | R3.7(a): "drops by up to 0.16 ... (45, 46 and 63 years for 100, 10 and 1 records per year) agrees with the bisection results to within 1–3 years" | | rev_monotonicity_summary.csv max_drop 0.155; first T 45/46/63. explore_const_grid.csv bisection 44/46/65 | OK | The differences are 1, 0 and 2 years ("0–2 years"). Largest drops occur at T = 9–14. |
| RL38 | R3.7(c): "(2–12%)" | | Table S5 (a) 1.8–11.8% | OK | |
| RL39 | R3.11: "the S13 interval issue is noted in Table S2 and SI" | | Table S2 note and si_methods.md: no mention of S13 intervals | UNSUPPORTED | Add a note to Table S2 on the S13 Monte Carlo OLS intervals, or amend the response. |
| RL40 | R4.1/R4.3: "detection times shorten for well-recorded species ... abstract now gives the range from 16 to 51 years" | | Fig. 2A; abstract | OK | |
| RL41 | R4.6: "8/14 declines with 9/34 false declines ... 20/34 false declines and 11 opposite-sign trends ... (median 32)" | | UKBMS CSVs | OK | |
| RL42 | R4.8: "nematodes 65% of recorded species undetectable within 100 years" | | rev_detectability_totals.csv 65.3% | OK | |
| RL43 | R4.9: "multi-species indicators are recommended for groups with records" | | main.md Discussion (l.98, l.102): pooling described with caveats, not recommended | UNSUPPORTED | Add the recommendation or amend the response. |
| RL44 | R5.6: "(B = 17.69 Mt dry, N = 3.45 × 10¹⁸)" | | harmonized_rosenberg_rerun log: 17.691 Mt; 3.446e18 | OK | |
| RL45 | R5.8: "Alternative counts (mites 55,000; nematodes 29,000)" | | rev_scope_variants.csv | OK | Source is Hodda 2022b, but the main text cites Chapman 2009 (R67). |
| RL46 | R5.9: "predicted recorded species exceed observed by 4–11 times in four groups" | | Table S8 / h5_unrecorded.csv σ = 1.5: 3.9, 5.0, 5.5, 11.1 | OK | |
| RL47 | R6.7: "citing Isaac et al. 2014, Kamp et al. 2016, Taylor & Gerrodette 1993, White 2019, Boyd et al. 2023 and Meyer et al. 2016" | | main.md l.96 (Meyer 2016 is cited in l.90, not the novelty paragraph); bib entries verified | OK | |
| RL48 | R6.7: "The phrase 'for the first time' was removed." | | grep main.md: absent | OK | |
| RL49 | R6.10: "The references file is present (60 entries ...)" | | references.bib: 60 entries | OK | 40 are cited. |
| RL50 | R6.10: "department ... still to be confirmed" | | main.md l.9 | OK | |
| RL51 | Items not addressed: "Each is stated as a limitation or deviation." | | main.md / SI | UNSUPPORTED (partly) | Full occupancy models, multi-species indicators and S15 are stated. GBIF cluster deduplication (R2.8) and group-specific species catalogues (R5.8a) are not stated anywhere in the manuscript or SI. |

## Summary

- **Rows checked:** 192 in total:
  - 17 abstract, 5 significance, 2 introduction
  - 71 results, 15 discussion, 9 methods
  - 8 figures, 8 cross-reference/label, 6 consistency
  - 51 response letter
- **Verdicts:**
  - OK: 163, of which several carry notes
  - MISMATCH: 20, including 5 labelling or scope rows
  - UNSUPPORTED: 8 (D15 = RL22, RL30, RL34, RL39, RL43, RL51, X5)
  - NOT FOUND: 1 (RL23)
- **Substantive numerical mismatches:**
  - R33: 43–46 yr scope
  - R35: overdispersion direction reversed
  - R43: autocorrelation 0.02, not 0.07
  - R44 / RL11: 17–21% only at ≥10 records/yr
  - R57: enchytraeids 85%, not 86%
  - M5: 3.75 × 10⁹ excludes absences only; 3.74 × 10⁹ without fossils
  - F1 / R20: Fig. 1A shows 0.58 / R² 0.77
  - R67 / C5: Chapman 2009 is the wrong source for 29,000 / 55,000
  - X1: jellyfish S = 244 vs 297 across runs
  - X2 / RL29: 147 datasets, 1.13 M records
  - X3: bird S < recorded species
  - RL1: four reviewers, not five
- **Labelling:** A17, I2, L1, F8. Exploratory revision analyses in the abstract, Results and Figs. 1–2 are not labelled exploratory.
