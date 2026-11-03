---
title: "Supplementary Information for: A ten-trillion-fold gap in how animals are recorded leaves declines of most small species undetectable"
author: "Hideyuki Doi"
bibliography: references.bib
csl: pnas.csl
---

## Supplementary Methods

### 1. Preregistration and its limitations

The analysis plan (PREREG v1.0, Japanese original with an English translation in `PREREG_en.md`) was finalised at commit 01a2fe7 on 3 November 2026. It fixed the data versions, models, priors, decision criteria, exclusion rules and 15 sensitivity analyses.

**What was already known when the plan was written.** Before the plan was written, I had already inspected:
- the census values for each group
- the total GBIF records per group and their breakdown by record type

Records per individual and all regressions had not been computed.

**Repository history.** All commits, from setup to the first manuscript, are dated the same day. During review, the repository history was rewritten to remove files derived from the Living Planet Database, whose terms do not allow redistribution. Commits before 01a2fe7 were unaffected, so the preregistration commit is unchanged.

**Changes after finalisation.** All were appended to the plan with dates and reasons (Section 11). Peer review identified two problems with the plan itself:
- records per individual on body mass is not identifiable when abundance and mass are collinear
- the H3 mapping double-counted effort declines

Both are reported, and every analysis added in revision is labelled exploratory.

### 2. Census data

**Sources and classification.** Global abundance (N) and biomass (B) estimates were compiled with their sources, uncertainties and estimation methods (`docs/data_provenance.md`, verbatim quotations). Each was classified into one of four classes:
- **independent:** extrapolated from field samples, or from survey- or catch-based population models
- **occurrence-derived:** using citizen-science or occurrence data
- **allometry-derived:** density predicted from body mass or traits
- **mixed**

Birds [@callaghan2021pnas] were classed occurrence-derived because eBird data inform every species' density. For 92% of land mammal species, abundances in ref. [@greenspoon2023] come from a model with body mass among its predictors, so these were classed allometry-derived.

**The ten groups analysed.** Ten groups had independent estimates (Table S1):
- soil nematodes [@vandenhoogen2019]
- springtails [@potapov2023]
- soil mites, obtained by rerunning the code of ref. [@rosenberg2023] with a fixed seed
- non-arboreal ants [@rosenberg2023]
- Antarctic krill [@atkinson2009]
- enchytraeids, copepods, pteropods, planktonic cnidarians and mesopelagic fishes [@baron2018]

For the five Bar-On groups, abundance is biomass divided by an assumed individual mass. Biomass was realigned to the same subgroup, and the assumed mass entered the model as an observation.

**Unit conversion.** Wet mass used each source's factors (Rosenberg dry-to-wet ratios; the Potapov carbon-to-fresh equivalence) or a carbon-to-wet-mass ratio of 0.15 [@baron2018].

**Uncertainty.** Census uncertainties were converted to log-normal standard deviations:
- 95% intervals and ranges: (ln hi − ln lo)/3.92
- fold f: ln f/1.96
- otherwise a default fold of 10 (assumed masses: fold 3)

### 3. Occurrence records

**GBIF snapshot.** All records in the GBIF snapshot of 1 November 2026 were read from the AWS open-data bucket with the R package arrow (GBIF.org, https://doi.org/10.15468/dl.jeesns; 3,887,364,403 records). Excluding absences left 3.75 × 10⁹ records, and excluding fossil specimens as well left 3.74 × 10⁹. The records were aggregated three ways:
1. taxon × year × basis of record × dataset class
2. for the analysed groups and mammals, species × year × dataset × basis of record
3. unique sampling events (species × dataset × 0.1° cell × date)

The event count was used as an alternative response because some datasets publish one record per individual or per sequence variant (e.g. KRILLBASE).

**Dataset classes.** These were obtained from the GBIF API: eBird, iNaturalist research-grade, and datasets with the DNA-derived data extension. DNA-extension datasets were further classified from their titles and descriptions into three types (`data/derived/dna_dataset_types.csv`):
- specimen barcodes (the International Barcode of Life dataset)
- reference sequence databases (EUKARYOME, excluded from DNA comparisons)
- metabarcoding and environmental DNA (147 datasets)

**Taxonomic matching.** Census groups were matched to GBIF taxa (COL eXtended Release taxonomy) by explicit rules (Table S1). In revision, scope-corrected variants were defined (`docs/taxon_scope_variants.csv`; lists compiled during review):
- **mites:** excluding water-mite, plant-associated, animal-associated and stored-product families
- **nematodes:** excluding marine-dominated orders and animal-parasitic families and orders
- **mesopelagic fishes:** 15 families instead of Myctophidae only

**Described species.** Counts came from the Catalogue of Life (ChecklistBank dataset 316595), with Scyphozoa plus Cubozoa (297) for jellyfish. Alternative counts for mites (55,000) and nematodes (29,000) come from ref. [@hodda2022b] (Table S20). For birds, more species are recorded in GBIF (COL eXtended Release) than are counted in the Catalogue of Life release used for described species, so the share of birds without records is truncated at zero (Table S13).

**Species-level names.** Census names were resolved to accepted names with the GBIF species-matching service.

### 4. Preregistered models

**Tier B (records per individual on body mass).** ln R_gk ~ Normal(ln N_g + a_k + b_k(ln M_g − c), √(τ_k² + 1/R_gk)). Latent ln N_g and ln M_g were informed by the census observations, four record types were fitted jointly, and the priors were b ~ N(0, 2), a ~ N(−25, 10) and τ ~ Half-Normal(0, 2). The 1/R term approximates Poisson variance; a Poisson likelihood mixed poorly in parameter-recovery tests at these counts.

**Tier A (mammals).** A Poisson–log-normal model with order effects for 388 species with reported population sizes. The measurement error on ln N and the residual were combined into one term with a centred parameterisation, after the planned brms implementation failed to converge. This is equivalent to the plan only with a flat prior on latent abundance.

**Detection simulations.** Annual counts were simulated as NegBin(λ₀E_te^(−dt), φ) with:
- φ estimated from report-based mammals using species and year fixed effects
- E_t, each group's observed record trajectory
- d, a 30% decline per decade

Three analysis methods were compared (effort-offset NB regression, binomial relative reporting rate, raw counts). T_detect was found by bisection.

### 5. Review-driven models of record allocation (exploratory)

**Free-coefficient model.** ln R_g ~ Normal(a + γ(ln N_g − c_N) + δ(ln M_g − c_M) + Xη, √(τ² + 1/R_g)), with latent N and M as above, fitted to all records only (no joint fitting of overlapping record types).
- **Covariates X:** log described species, and/or a soil-versus-marine indicator.
- **Priors:** N(0, 2) for γ, δ and η, with N(0, 5) in sensitivity.
- **Variants:**
  - responses: scope-corrected records; sampling events; records without the three largest datasets of each group
  - census alternatives: jellyfish mass ×50 for gelatinous carbon content; nematode carbon-to-fresh 0.105; krill abundance from unadjusted nets
- **Posterior predictive checks:** coverage of observed ln R by 95% prediction intervals.
- **Diagnostics:** R̂ ≤ 1.01 in all fits; the models with described species had 2 (log S only) and 9 (log S and habitat) divergent transitions out of 8,000, which were not removed by adapt_delta = 0.99.

**Ratio null.** Records were permuted among groups (5,000 times), and records-per-individual slopes were computed by OLS on point estimates.

**DNA contrast.** log(R_DNA/R_human) was regressed on log M, so that abundance cancels. Census uncertainty was propagated by Monte Carlo (4,000 draws) and the residual sampling uncertainty of the slope by t draws.

### 6. Detection: analytic results, overdispersion and simulations (exploratory unless stated)

**Analytic detection time.** For a log-linear decline at rate d observed for T years with residual variance σ² on the log scale, the slope's standard error is σ/√(T(T²−1)/12). For a negative binomial count with mean λ and shape φ, σ² ≈ 1/λ + 1/φ. Power 1 − β at one-sided α therefore requires

T(T² − 1)/12 = (1/λ + 1/φ)(z_α + z_β)²/d²,

which gives the floor T ≈ [12(z_α + z_β)²/(φd²)]^(1/3) as λ → ∞. Also reported (Table S15):
- the minimum decline per decade detectable within 10 years
- the share of the population lost by the time of detection

**Overdispersion net of trends.** For each species recorded at least once per year on average, three negative binomial regressions were fitted to annual records 2000–2024, all with an offset for the group's total records:
- intercept only
- linear trend
- quadratic trend

φ and the lag-1 autocorrelation of Pearson residuals were summarised by group, data source and record-rate stratum, with up to 200 species per stratum. Groups included eBird and non-eBird bird records, and mammal records with and without machine observations.

**Simulations with record-rate-dependent φ.** T_detect for a 30% decline per decade under constant effort was recomputed for each group, using the trend-removed φ of the record-rate stratum corresponding to λ₀ (31 values from 10⁻² to 10⁴, 500 replicates).

**Autocorrelation.** Latent log-normal year effects followed AR(1) with ρ = 0.44, with variance chosen so that the marginal overdispersion equalled φ = 0.69. These were analysed with the effort-offset method for stable and declining series.

### 7. Validation against structured monitoring (exploratory)

For 48 British butterfly species, two trend estimates for 2000–2019 were compared:
- **From GBIF:** unstructured records (UKBMS and the Wider Countryside Butterfly Survey removed; GBIF download https://doi.org/10.15468/dl.u8s7s5), analysed with the three methods.
- **From UKBMS:** site indices (2024 release; values of −2, which denote insufficient monitoring, treated as missing), using a quasi-Poisson GLM with site fixed effects and a linear year term.

2019 was the last year before the largest unstructured dataset ends. A trend was classed as significant at two-sided α = 0.05.

### 8. Detectability of described species (exploratory)

For every described species in each group, λ was the mean annual records 2015–2024, with λ = 0 for species without records. The time to detect a 30% decline per decade was read from the group's curve in Section 6 (taking the lower adjacent grid point, which is conservative). For mammals and birds, species with body masses (COMBINE [@soria2021]; AVONET [@tobias2022]) were binned by order of magnitude; birds used the eBird curve.

### 9. Other exploratory analyses retained from the first version

- **Vertebrates with survey-based censuses.** 50 mammal species, after removing a duplicated elephant entry and an unverified polar bear value. Compared with the extrapolated preregistered relationship (Table S7).
- **Occupancy index.** Occupied 1° cells per species and year, compared with record counts (Table S6, Fig. S3).
- **Multi-species indicators.** Pooled NB regressions of K species with independent noise.
- **Never-recorded species (H5).** Predicted from the observation model with literature totals of species richness. It shares those totals with the benchmark and over-predicts the number of recorded species by 4–11 times in four groups (Table S8), so it is reported as unsupported.

The Living Planet Database analysis of the first version was removed. It used an outdated public release, its data-use terms were uncertain, and indicators are not built from occurrence records.

### 10. Software, reproducibility and AI assistance

R 4.6.1 with renv, targets, cmdstanr (CmdStan 2.40), brms, arrow and tidyverse; seed 20261103. All figures and tables are generated by code in the public repository (https://github.com/hideyuki-doi/observation-inequality), which also contains the review reports and the response.

The work was carried out with Claude (Anthropic), an AI system, under the author's direction. The system wrote and ran code, retrieved and summarised literature and data documentation, and drafted text. The author approved each analysis stage at predefined gates and checked the results. Bibliographic entries were verified against Crossref or original documents. Census values were checked against source files, with verbatim quotations recorded.

### 11. Deviations from the preregistration

1. **Likelihood (implementation, before finalisation).** A Gaussian likelihood on ln R with variance τ² + 1/R was used instead of a Poisson likelihood.
2. **Species-level model (implementation).** The single combined error term described in Section 4 replaced brms with me(); it is equivalent only under a flat prior on latent abundance.
3. **Detection simulations (implementation).** T_detect was found by bisection, with a minimum T of 3. The denominator of the relative reporting rate was the group's other records. Failed fits counted as non-detections.
4. **H3 mapping (error disclosed in review).** λ₀ was scaled to the 2024 record rate while the effort trajectory started in 2000, which double-counts effort declines. This affects krill and mesopelagic fishes in the upper size third.
5. **H3 interpretation (addendum after results).** The criterion was met formally because detection failed in every size third, not because of a size gradient. H3 is reported as not substantively supported.
6. **Preregistered sensitivity analyses not run in the first version.** S5b (Rosenberg springtails), S6c (nematodes without parasitic families), S6d (extended mesopelagic families) and S15 (undescribed-species correction). S6c and S6d were run in revision as scope corrections (Table S20). S5b and S15 were not run.
7. **H1/H2 interpretation (review).** The records-per-individual exponent is not identifiable from the records (ratio artefact; Tables S11–S12). The preregistered decisions are reported but not interpreted as evidence about detection.
8. **Tier A consistency (preregistered check).** The within-mammal exponent (0.32) did not overlap the Tier B exponent (0.72). This was not reported in the first version.
9. **All revision analyses** are exploratory (Sections 5–8).

### Supplementary figures

![**Fig. S1.** Preregistered scaling exponents β (posterior median and 95% CrI) of records per individual on body mass in the main and sensitivity analyses (dashed line, 2/3). The exponent is not identifiable from the records (Table S11).](../figs/phase4_sensitivity_beta.png){width=100%}

![**Fig. S2.** Preregistered simulations: years to detect a 30% decline per decade against initial expected records per species-year by group and method, using mammal overdispersion (φ = 0.69) and each group's effort trajectory.](../figs/phase5_tdetect_vs_lambda.png){width=100%}

![**Fig. S3.** Years to detect a 30% decline per decade using record counts or the number of occupied 1° cells, by group and recording stratum (exploratory).](../figs/supp_occupancy_vs_records.png){width=100%}

![**Fig. S4.** Annual GBIF records by group and record type, 1950–2025 (shaded: 2000–2024).](../figs/phase2_records_by_year.png){width=100%}

![**Fig. S5.** Preregistered analysis of records per individual against body mass (first version's Fig. 1), with mammal species with census abundances (exploratory). Records per individual largely mirror abundance (main text).](../figs/supp_prereg_scaling.png){width=100%}

## Supplementary tables

### Table S1. Census estimates and GBIF matching for the ten groups with independent censuses

|Group            |N (individuals) |B (g wet) |M (g wet) |Census source                                                                                                                                                        |GBIF rule                                           |Records 2000–2024 |
|:----------------|:---------------|:---------|:---------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------------------------|:-----------------|
|soil_nematodes   |4.40e+20        |2.10e+14  |4.76e-07  |van den Hoogen J, Geisen S, Routh D, et al. (2019) Soil nematode abundance and functional group composition at a global scale. Nature 572:194-198                    |phylum: Nematoda                                    |416,187           |
|springtails      |2.00e+18        |1.90e+14  |9.50e-05  |Potapov AM, Guerra CA, van den Hoogen J, et al. (2023) Globally invariant metabolism but density-diversity mismatch in springtails. Nat Commun 14:674                |class: Collembola                                   |1,241,382         |
|mites            |6.54e+18        |6.53e+13  |9.97e-06  |Rosenberg Y, Bar-On YM, Fromm A, Ostikar M, Shoshany A, Giz O, Milo R (2023) The global biomass and number of terrestrial arthropods. Sci Adv 9:eabq4049             |order: Sarcoptiformes, Mesostigmata, Trombidiformes |1,315,602         |
|ants             |5.00e+16        |1.10e+14  |2.19e-03  |Rosenberg Y, Bar-On YM, Fromm A, Ostikar M, Shoshany A, Giz O, Milo R (2023) The global biomass and number of terrestrial arthropods. Sci Adv 9:eabq4049             |family: Formicidae                                  |2,509,986         |
|enchytraeids     |7.71e+17        |1.29e+14  |1.67e-04  |Bar-On YM, Phillips R, Milo R (2018) The biomass distribution on Earth. PNAS 115:6506-6511                                                                           |family: Enchytraeidae                               |87,719            |
|copepods         |1.41e+20        |3.76e+15  |2.67e-05  |Bar-On YM, Phillips R, Milo R (2018) The biomass distribution on Earth. PNAS 115:6506-6511                                                                           |class: Copepoda                                     |2,421,706         |
|pteropods        |4.97e+17        |8.80e+14  |1.77e-03  |Bar-On YM, Phillips R, Milo R (2018) The biomass distribution on Earth. PNAS 115:6506-6511                                                                           |order: Pteropoda                                    |63,888            |
|jellyfish        |1.97e+16        |2.67e+14  |1.36e-02  |Bar-On YM, Phillips R, Milo R (2018) The biomass distribution on Earth. PNAS 115:6506-6511                                                                           |class: Scyphozoa, Cubozoa                           |173,734           |
|mesopelagic_fish |1.12e+15        |3.45e+15  |3.09e+00  |Bar-On YM, Phillips R, Milo R (2018) The biomass distribution on Earth. PNAS 115:6506-6511                                                                           |family: Myctophidae                                 |127,567           |
|krill            |7.80e+14        |3.79e+14  |4.86e-01  |Atkinson A, Siegel V, Pakhomov EA, Jessopp MJ, Loeb V (2009) A re-appraisal of the total biomass and annual production of Antarctic krill. Deep-Sea Res I 56:727-740 |species: Euphausia superba                          |95,798            |

*All ten abundances classified independent. Provenance, verbatim quotations and uncertainty conversions: docs/data_provenance.md.*


### Table S2. Preregistered analysis: exponents of records per individual on body mass (main and sensitivity analyses)

|Analysis                  |β all             |β human obs.      |β specimen        |β DNA             |R² (all) |H1                          |H2                             |P(β_DNA<β_human) |H4           |
|:-------------------------|:-----------------|:-----------------|:-----------------|:-----------------|:--------|:---------------------------|:------------------------------|:----------------|:------------|
|main                      |0.72 [0.49, 0.94] |0.75 [0.48, 1.01] |0.66 [0.38, 0.95] |0.51 [0.24, 0.79] |0.90     |scaling (limited precision) |indistinguishable from optical |0.935            |supported    |
|S1_cumulative             |0.78 [0.57, 1.00] |0.80 [0.58, 1.02] |0.66 [0.37, 0.93] |0.53 [0.27, 0.79] |0.93     |scaling (limited precision) |indistinguishable from optical |0.972            |supported    |
|S2_S9_no_ebird            |1.22 [1.04, 1.43] |1.29 [1.10, 1.53] |1.06 [0.90, 1.24] |0.89 [0.73, 1.06] |0.96     |scaling (limited precision) |human interest dominant        |0.999            |supported    |
|S3_individualcount        |0.83 [0.41, 1.24] |0.89 [0.43, 1.36] |0.59 [0.27, 0.90] |0.51 [0.18, 0.87] |0.70     |not confirmed               |indistinguishable from optical |0.917            |supported    |
|S4_species_level          |0.80 [0.56, 1.02] |0.82 [0.53, 1.11] |0.71 [0.44, 0.99] |0.63 [0.36, 0.88] |0.90     |scaling (limited precision) |indistinguishable from optical |0.872            |inconclusive |
|S5a_nematodes_baron       |0.63 [0.42, 0.84] |0.66 [0.42, 0.91] |0.57 [0.32, 0.84] |0.42 [0.17, 0.67] |0.91     |scaling (limited precision) |indistinguishable from optical |0.962            |supported    |
|S5c_ants_schultheiss      |0.76 [0.50, 1.01] |0.79 [0.49, 1.07] |0.70 [0.38, 1.01] |0.55 [0.23, 0.85] |0.86     |scaling (limited precision) |indistinguishable from optical |0.905            |supported    |
|S6a_acari_all             |0.72 [0.48, 0.95] |0.74 [0.48, 1.02] |0.66 [0.38, 0.93] |0.50 [0.22, 0.78] |0.90     |scaling (limited precision) |indistinguishable from optical |0.932            |supported    |
|S6b_plus_hydrozoa         |0.75 [0.54, 0.95] |0.77 [0.52, 1.01] |0.71 [0.46, 0.96] |0.56 [0.28, 0.82] |0.93     |scaling (limited precision) |indistinguishable from optical |0.931            |supported    |
|S7a_fold5                 |0.73 [0.48, 0.97] |0.76 [0.48, 1.05] |0.66 [0.37, 0.96] |0.51 [0.22, 0.81] |0.85     |scaling (limited precision) |indistinguishable from optical |0.905            |supported    |
|S7b_fold20                |0.73 [0.50, 0.92] |0.76 [0.50, 0.99] |0.67 [0.39, 0.93] |0.51 [0.25, 0.77] |0.94     |scaling (limited precision) |indistinguishable from optical |0.957            |supported    |
|S7c_mfold10               |0.71 [0.48, 0.93] |0.74 [0.49, 1.00] |0.66 [0.38, 0.93] |0.51 [0.23, 0.77] |0.90     |scaling (limited precision) |indistinguishable from optical |0.946            |supported    |
|S8a_plankton_Cx10         |0.71 [0.47, 0.93] |0.74 [0.48, 0.99] |0.65 [0.36, 0.93] |0.49 [0.22, 0.77] |0.89     |scaling (limited precision) |indistinguishable from optical |0.935            |supported    |
|S9_add_birds_mammals      |1.27 [1.07, 1.48] |1.33 [1.12, 1.58] |1.07 [0.89, 1.24] |0.89 [0.73, 1.07] |0.96     |scaling (limited precision) |human interest dominant        |0.998            |supported    |
|S10_drop_soil_nematodes   |0.59 [0.34, 0.84] |0.61 [0.32, 0.91] |0.50 [0.18, 0.83] |0.35 [0.04, 0.66] |0.84     |scaling (limited precision) |indistinguishable from optical |0.925            |supported    |
|S10_drop_springtails      |0.73 [0.48, 0.99] |0.75 [0.45, 1.05] |0.67 [0.36, 0.97] |0.53 [0.24, 0.81] |0.88     |scaling (limited precision) |indistinguishable from optical |0.904            |supported    |
|S10_drop_mites            |0.79 [0.53, 1.06] |0.84 [0.55, 1.14] |0.75 [0.42, 1.07] |0.57 [0.24, 0.89] |0.90     |scaling (limited precision) |indistinguishable from optical |0.926            |supported    |
|S10_drop_ants             |0.62 [0.46, 0.79] |0.64 [0.44, 0.85] |0.54 [0.32, 0.77] |0.39 [0.18, 0.60] |0.95     |scaling (limited precision) |indistinguishable from optical |0.980            |supported    |
|S10_drop_enchytraeids     |0.72 [0.49, 0.95] |0.75 [0.47, 1.02] |0.66 [0.37, 0.97] |0.51 [0.22, 0.80] |0.90     |scaling (limited precision) |indistinguishable from optical |0.921            |supported    |
|S10_drop_copepods         |0.70 [0.44, 0.94] |0.72 [0.45, 0.99] |0.65 [0.34, 0.95] |0.47 [0.17, 0.76] |0.89     |scaling (limited precision) |indistinguishable from optical |0.935            |supported    |
|S10_drop_pteropods        |0.75 [0.52, 0.96] |0.78 [0.52, 1.02] |0.68 [0.38, 0.97] |0.53 [0.26, 0.80] |0.93     |scaling (limited precision) |indistinguishable from optical |0.947            |supported    |
|S10_drop_jellyfish        |0.73 [0.48, 0.96] |0.74 [0.47, 0.99] |0.71 [0.43, 0.97] |0.53 [0.23, 0.82] |0.90     |scaling (limited precision) |indistinguishable from optical |0.893            |inconclusive |
|S10_drop_mesopelagic_fish |0.84 [0.55, 1.11] |0.86 [0.51, 1.20] |0.67 [0.31, 1.05] |0.55 [0.20, 0.92] |0.90     |scaling (limited precision) |indistinguishable from optical |0.928            |supported    |
|S10_drop_krill            |0.77 [0.51, 0.99] |0.82 [0.52, 1.09] |0.76 [0.44, 1.04] |0.62 [0.33, 0.88] |0.92     |scaling (limited precision) |indistinguishable from optical |0.898            |inconclusive |
|S11a_no_inat              |0.72 [0.51, 0.92] |0.75 [0.52, 0.98] |0.67 [0.39, 0.94] |0.51 [0.24, 0.78] |0.92     |scaling (limited precision) |indistinguishable from optical |0.947            |supported    |
|S11b_inat_only            |0.66 [0.17, 1.18] |0.66 [0.16, 1.18] |NA                |NA                |0.49     |not confirmed               |indistinguishable from optical |NA               |NA           |
|S12_add_prokaryotes       |1.01 [0.90, 1.12] |1.22 [1.07, 1.37] |1.26 [1.09, 1.43] |0.91 [0.77, 1.04] |0.98     |clean scaling               |human interest dominant        |1.000            |supported    |
|S14_dna_strict            |0.73 [0.51, 0.95] |0.75 [0.50, 1.01] |0.66 [0.38, 0.95] |0.50 [0.24, 0.76] |0.90     |scaling (limited precision) |indistinguishable from optical |0.949            |supported    |
|S13_mc_ols                |0.73 [0.61, 0.88] |0.75 [0.62, 0.90] |0.67 [0.53, 0.79] |0.51 [0.38, 0.64] |NA       |NA                          |NA                             |NA               |NA           |

*Preregistered decision labels are reported as computed; they are not interpretable as evidence about detection because the exponent is not identifiable (Tables S11–S12). The S13 interval propagates census uncertainty only (not the regression sampling uncertainty) and is therefore narrower than the credible intervals. Sensitivity results are a robustness range, not independent replications.*


### Table S3. Species-level models within mammals and birds

|Model                                                                   | Species|Exponent [95% CrI]                   |Note                                            |
|:-----------------------------------------------------------------------|-------:|:------------------------------------|:-----------------------------------------------|
|Preregistered PLN, mammals_report (main)                                |     388|0.32 [0.18, 0.47]                    |exponent of records per individual on body mass |
|Preregistered PLN, mammals_all (sens; SVR allometry-derived)            |    4726|0.48 [0.41, 0.55]                    |exponent of records per individual on body mass |
|Preregistered PLN, birds_callaghan (sens; occurrence-derived)           |    9263|0.11 [0.06, 0.16]                    |exponent of records per individual on body mass |
|OLS log10(R+0.5) ~ log10 N + log10 M, mammals with reported populations |     388|N: 0.64 (SE 0.05); M: 0.20 (SE 0.04) |exploratory                                     |

### Table S4. Overdispersion of annual record counts: preregistered estimate and by recording intensity (mammals, species + year effects)

|Set                                |φ                 |
|:----------------------------------|:-----------------|
|Preregistered (382 species)        |0.69 [0.66, 0.71] |
|Mean records/yr <1 (85 spp.)       |0.46 (SE 0.054)   |
|Mean records/yr 1-10 (96 spp.)     |0.56 (SE 0.023)   |
|Mean records/yr 10-100 (102 spp.)  |0.73 (SE 0.020)   |
|Mean records/yr 100-1000 (67 spp.) |0.93 (SE 0.030)   |
|Mean records/yr >1000 (32 spp.)    |0.87 (SE 0.039)   |

### Table S5. Spurious significant trends in preregistered simulations without decline, by record rate

| Years|Records/species-yr |(a) false decline |(b) false decline |(c) false decline |(c) false increase |
|-----:|:------------------|:-----------------|:-----------------|:-----------------|:------------------|
|    10|<1                 |1.8%              |2.4%              |1.4%              |2.5%               |
|    10|1–10               |10.0%             |22.3%             |9.7%              |14.8%              |
|    10|≥10                |11.8%             |47.1%             |13.0%             |16.5%              |
|    25|<1                 |3.7%              |6.6%              |1.6%              |15.3%              |
|    25|1–10               |6.7%              |27.3%             |11.6%             |37.5%              |
|    25|≥10                |7.1%              |47.5%             |13.9%             |40.8%              |
|    50|<1                 |3.2%              |6.1%              |8.7%              |12.2%              |
|    50|1–10               |5.6%              |24.9%             |36.9%             |20.9%              |
|    50|≥10                |6.1%              |45.3%             |37.9%             |21.6%              |

*Ten groups, 1,000 replicates each; independent years. (a) NB regression with effort offset; (b) binomial relative reporting rate; (c) NB regression on raw counts.*


### Table S6. Record counts versus occupied 1° cells: overdispersion and years to detect a 30% decline per decade (exploratory)

|Group            |Stratum | Species|φ records |φ cells |Years, records |Years, cells |
|:----------------|:-------|-------:|:---------|:-------|:--------------|:------------|
|ants             |<1      |     300|0.09      |1.11    |>100           |>100         |
|ants             |1-10    |     300|0.21      |1.40    |72             |64           |
|ants             |>=10    |     300|0.43      |2.29    |51             |35           |
|copepods         |<1      |     300|0.08      |0.44    |>100           |>100         |
|copepods         |1-10    |     300|0.14      |0.59    |82             |70           |
|copepods         |>=10    |     300|0.55      |1.45    |49             |36           |
|enchytraeids     |<1      |     166|0.08      |0.62    |>100           |>100         |
|enchytraeids     |1-10    |      91|0.25      |1.21    |67             |62           |
|enchytraeids     |>=10    |      31|0.63      |2.63    |47             |37           |
|jellyfish        |<1      |     106|0.23      |1.55    |>100           |>100         |
|jellyfish        |1-10    |      49|0.62      |3.45    |51             |46           |
|jellyfish        |>=10    |      35|1.25      |7.23    |37             |23           |
|mammals          |<1      |     300|0.24      |9.95    |>100           |>100         |
|mammals          |1-10    |     300|0.33      |3.72    |62             |52           |
|mammals          |>=10    |     300|0.68      |4.51    |44             |26           |
|mesopelagic_fish |<1      |      51|0.18      |0.49    |>100           |>100         |
|mesopelagic_fish |1-10    |      98|0.37      |0.97    |59             |52           |
|mesopelagic_fish |>=10    |      58|0.54      |1.36    |49             |37           |
|mites            |<1      |     300|0.12      |0.61    |>100           |>100         |
|mites            |1-10    |     300|0.20      |0.87    |72             |63           |
|mites            |>=10    |     300|0.34      |1.17    |57             |41           |
|pteropods        |<1      |      38|0.20      |0.51    |>100           |>100         |
|pteropods        |1-10    |      26|0.33      |0.88    |63             |60           |
|pteropods        |>=10    |      19|0.72      |1.77    |44             |35           |
|soil_nematodes   |<1      |     300|0.06      |0.30    |>100           |>100         |
|soil_nematodes   |1-10    |     300|0.10      |0.42    |90             |91           |
|soil_nematodes   |>=10    |      27|0.21      |0.67    |67             |53           |
|springtails      |<1      |     300|0.09      |0.95    |>100           |>100         |
|springtails      |1-10    |     300|0.16      |0.91    |77             |68           |
|springtails      |>=10    |     206|0.40      |1.84    |53             |36           |

### Table S7. Mammal species with census abundances relative to the extrapolated preregistered relationship (exploratory)

|Set                | Species|log10 M range |Median residual (log10) |95% interval over line uncertainty |Within-set slope |
|:------------------|-------:|:-------------|:-----------------------|:----------------------------------|:----------------|
|census_independent |      50|4.7–8.2       |3.82                    |1.73 to 5.93                       |0.63             |
|census_mixed       |       9|5–6.1         |4.50                    |2.51 to 6.51                       |0.08             |
|census_unclear     |      72|4.5–6.8       |4.41                    |2.46 to 6.38                       |-0.05            |
|report_land        |     389|0.5–6.7       |4.87                    |3.20 to 6.67                       |0.11             |

*census_independent: survey- or survey/catch-model-based abundances (duplicated elephant entry and unverified polar bear removed).*


### Table S8. Never-recorded species predicted by the observation model (H5; exploratory, not supported)

|Group          |Estimated total species |Literature undescribed share |Predicted never recorded (25 yr) |Predicted recorded species |Observed recorded 2000–2024 |Ratio predicted/observed |
|:--------------|:-----------------------|:----------------------------|:--------------------------------|:--------------------------|:---------------------------|:------------------------|
|ants           |34,293                  |0.58                         |0.79 [0.68, 0.89]                |7,136                      |9,503                       |0.8                      |
|copepods       |50,125                  |0.69                         |0.62 [0.43, 0.74]                |18,929                     |3,435                       |5.5                      |
|jellyfish      |360                     |0.32                         |0.43 [0.28, 0.59]                |207                        |194                         |1.1                      |
|mites          |223,607                 |0.87                         |0.88 [0.81, 0.94]                |26,207                     |6,767                       |3.9                      |
|soil_nematodes |500,000                 |0.96                         |0.91 [0.77, 0.96]                |46,468                     |4,203                       |11.1                     |
|springtails    |50,000                  |0.82                         |0.75 [0.64, 0.85]                |12,657                     |2,530                       |5.0                      |

*The prediction and the benchmark share the literature richness totals; predicted recorded species exceed observed by 4–11 times in four groups.*


### Table S9. Records, sampling events and dataset concentration, 2000–2024 (exploratory)

|Group            |Records   |Sampling events | Datasets|Top-1 share |Top-3 share |Human obs. |Specimens |DNA barcodes (iBOL) |DNA metabarcoding/eDNA |
|:----------------|:---------|:---------------|--------:|:-----------|:-----------|:----------|:---------|:-------------------|:----------------------|
|ants             |2,509,986 |916,499         |     2150|0.23        |0.54        |956,418    |1,138,904 |351,240             |28,059                 |
|copepods         |2,421,706 |681,129         |     1281|0.22        |0.46        |370,836    |996,952   |23,075              |229,643                |
|enchytraeids     |87,719    |11,739          |      308|0.36        |0.51        |22,532     |17,253    |3,061               |35,373                 |
|jellyfish        |173,734   |105,392         |      646|0.24        |0.46        |142,976    |4,148     |2,060               |4,062                  |
|krill            |95,798    |8,447           |       47|0.85        |0.91        |10,599     |2,807     |552                 |1                      |
|mesopelagic_fish |127,567   |46,525          |      270|0.21        |0.42        |44,674     |62,948    |4,095               |2,493                  |
|mites            |1,315,602 |256,657         |     1527|0.27        |0.51        |469,382    |504,560   |193,093             |104,065                |
|pteropods        |63,888    |16,098          |      317|0.25        |0.33        |12,265     |30,507    |2,548               |2,667                  |
|soil_nematodes   |416,187   |34,621          |     1110|0.17        |0.29        |79,717     |80,978    |13,505              |145,054                |
|springtails      |1,241,382 |134,716         |      962|0.24        |0.58        |146,621    |233,306   |299,298             |497,056                |

*Sampling event = unique species × dataset × 0.1° cell × date.*


### Table S10. DNA-derived records by dataset type (all analysed groups and mammals, 2000–2024)

|Type                | Datasets|Records   |Largest dataset                                                                                                                                  |
|:-------------------|--------:|:---------|:------------------------------------------------------------------------------------------------------------------------------------------------|
|barcode_specimen    |        1|931,748   |International Barcode of Life project (iBOL)                                                                                                     |
|metabarcoding_other |      147|1,130,734 |CO1 Amplicon Sequence Variants of bulk arthropod samples (mild lysis) collected with Malaise traps from the Insect Biome Atlas project in Sweden |
|reference_db        |        1|20,701    |EUKARYOME: the rRNA gene reference database for identification of eukaryotes                                                                     |

### Table S11. Ratio artefact: exponent of records per individual on body mass under null record allocations

|Allocation                                |Exponent          |
|:-----------------------------------------|:-----------------|
|Observed records (OLS on point estimates) |0.73              |
|Identical records in every group          |0.89              |
|Records permuted among groups (5,000)     |0.88 [0.69, 1.08] |
|Preregistered EIV estimate                |0.72 [0.49, 0.94] |

### Table S12. Errors-in-variables models of log records with free coefficients (exploratory)

|Analysis                                             |Parameter   |Estimate [95% CrI]  |P(>0) |
|:----------------------------------------------------|:-----------|:-------------------|:-----|
|free: N + M                                          |gamma (lnN) |-0.01 [-1.03, 0.80] |0.49  |
|free: N + M                                          |delta (lnM) |-0.17 [-1.09, 0.59] |0.32  |
|free: N + M + log S                                  |gamma (lnN) |-0.07 [-0.87, 0.66] |0.42  |
|free: N + M + log S                                  |delta (lnM) |0.00 [-0.74, 0.72]  |0.50  |
|free: N + M + log S                                  |lnS         |0.43 [-0.01, 0.86]  |0.97  |
|free: N + M + soil                                   |gamma (lnN) |0.18 [-1.10, 1.18]  |0.65  |
|free: N + M + soil                                   |delta (lnM) |0.06 [-1.20, 1.08]  |0.55  |
|free: N + M + soil                                   |soil        |0.75 [-2.00, 3.59]  |0.70  |
|free: N + M + log S + soil                           |gamma (lnN) |-0.18 [-1.14, 0.92] |0.37  |
|free: N + M + log S + soil                           |delta (lnM) |-0.12 [-1.02, 1.02] |0.41  |
|free: N + M + log S + soil                           |lnS         |0.47 [-0.03, 0.94]  |0.97  |
|free: N + M + log S + soil                           |soil        |-0.41 [-2.97, 2.64] |0.39  |
|scope-corrected records, N + M + log S               |gamma (lnN) |0.06 [-0.74, 0.76]  |0.57  |
|scope-corrected records, N + M + log S               |delta (lnM) |0.20 [-0.56, 0.88]  |0.74  |
|scope-corrected records, N + M + log S               |lnS         |0.48 [0.05, 0.89]   |0.98  |
|species-events, N + M + log S                        |gamma (lnN) |-0.00 [-0.93, 0.79] |0.50  |
|species-events, N + M + log S                        |delta (lnM) |0.20 [-0.64, 0.96]  |0.71  |
|species-events, N + M + log S                        |lnS         |0.62 [0.15, 1.08]   |0.99  |
|records without top-3 datasets, N + M + log S        |gamma (lnN) |0.10 [-0.46, 0.57]  |0.67  |
|records without top-3 datasets, N + M + log S        |delta (lnM) |0.18 [-0.35, 0.65]  |0.78  |
|records without top-3 datasets, N + M + log S        |lnS         |0.58 [0.29, 0.89]   |1.00  |
|main (priors N(0,2)), N + M + log S                  |gamma (lnN) |-0.06 [-0.85, 0.71] |0.43  |
|main (priors N(0,2)), N + M + log S                  |delta (lnM) |0.01 [-0.72, 0.77]  |0.51  |
|main (priors N(0,2)), N + M + log S                  |lnS         |0.43 [-0.00, 0.87]  |0.97  |
|wider priors N(0,5), N + M + log S                   |gamma (lnN) |-0.07 [-0.97, 0.71] |0.42  |
|wider priors N(0,5), N + M + log S                   |delta (lnM) |0.00 [-0.82, 0.77]  |0.51  |
|wider priors N(0,5), N + M + log S                   |lnS         |0.44 [-0.01, 0.91]  |0.97  |
|jellyfish mass ×50 (gelatinous C/wet), N + M + log S |gamma (lnN) |-0.14 [-0.86, 0.49] |0.32  |
|jellyfish mass ×50 (gelatinous C/wet), N + M + log S |delta (lnM) |-0.06 [-0.65, 0.48] |0.39  |
|jellyfish mass ×50 (gelatinous C/wet), N + M + log S |lnS         |0.42 [-0.00, 0.83]  |0.97  |
|nematode C/fresh 0.105, N + M + log S                |gamma (lnN) |-0.08 [-0.86, 0.66] |0.41  |
|nematode C/fresh 0.105, N + M + log S                |delta (lnM) |-0.01 [-0.73, 0.74] |0.49  |
|nematode C/fresh 0.105, N + M + log S                |lnS         |0.43 [0.01, 0.89]   |0.98  |
|krill N, unadjusted nets, N + M + log S              |gamma (lnN) |-0.07 [-0.90, 0.66] |0.41  |
|krill N, unadjusted nets, N + M + log S              |delta (lnM) |0.02 [-0.77, 0.78]  |0.53  |
|krill N, unadjusted nets, N + M + log S              |lnS         |0.46 [0.02, 0.92]   |0.98  |
|S5b springtails from Rosenberg re-run, N + M + log S |gamma (lnN) |-0.11 [-0.93, 0.58] |0.37  |
|S5b springtails from Rosenberg re-run, N + M + log S |delta (lnM) |-0.04 [-0.75, 0.60] |0.44  |
|S5b springtails from Rosenberg re-run, N + M + log S |lnS         |0.42 [-0.02, 0.86]  |0.97  |

*γ = 1 would mean records proportional to individuals. Posterior predictive coverage of observed records by 95% intervals was 10/10 in all variants (sim/rev_free_sensitivity.csv). R̂ ≤ 1.01 throughout; 2–9 divergent transitions of 8,000 in models with described species.*


### Table S13. Records per described species and share of species without records

|Group            |log10 M |Described species |Recorded 2015–2024 |No records 2015–2024 |Records/species/yr (2000–2024) |Median λ, recorded species |
|:----------------|:-------|:-----------------|:------------------|:--------------------|:------------------------------|:--------------------------|
|soil_nematodes   |-6.32   |19,667            |2,196              |88.8%                |0.8                            |0.40                       |
|mites            |-5.00   |29,017            |3,758              |87.0%                |1.8                            |0.30                       |
|copepods         |-4.57   |15,297            |1,910              |87.5%                |6.3                            |0.50                       |
|springtails      |-4.02   |8,926             |1,586              |82.2%                |5.6                            |0.50                       |
|enchytraeids     |-3.78   |840               |217                |74.2%                |4.2                            |0.90                       |
|pteropods        |-2.75   |141               |70                 |50.4%                |18.1                           |1.45                       |
|ants             |-2.66   |14,438            |6,683              |53.7%                |7.0                            |0.80                       |
|jellyfish        |-1.87   |297               |171                |42.4%                |23.4                           |2.00                       |
|krill            |-0.31   |1                 |1                  |0.0%                 |3831.9                         |357.60                     |
|mesopelagic_fish |0.49    |252               |180                |28.6%                |20.2                           |2.65                       |
|birds            |1.56    |10,868            |11,244             |0.0%                 |6813.4                         |289.90                     |
|mammals          |1.81    |6,368             |4,844              |23.9%                |240.8                          |3.40                       |

*For birds, GBIF (COL eXtended Release) recognises more species than the Catalogue of Life count of described species used here, so the share without records is truncated at zero.*


### Table S14. DNA-derived relative to human-observation records against body mass (abundance cancels; exploratory)

|Contrast                      |Slope per log10 g [95%] |P(<0) |
|:-----------------------------|:-----------------------|:-----|
|dna_all / human_obs           |-0.24 [-0.42, -0.06]    |0.993 |
|dna_barcode / human_obs       |-0.11 [-0.32, 0.09]     |0.879 |
|dna_metabarcoding / human_obs |-0.44 [-0.80, -0.08]    |0.989 |
|specimen / human_obs          |-0.09 [-0.29, 0.13]     |0.810 |

### Table S15. Analytic detection metrics (power 0.8, one-sided α = 0.05)

|    φ|Records/species-yr |Years, 30%/decade |Years, 50%/decade |Min. decline detectable in 10 yr |Lost at detection (30%/decade) |
|----:|:------------------|:-----------------|:-----------------|:--------------------------------|:------------------------------|
| 0.06|10                 |99.3              |63.7              |100%                             |97%                            |
| 0.06|∞                  |99.1              |63.6              |100%                             |97%                            |
| 0.12|10                 |78.9              |50.7              |100%                             |94%                            |
| 0.12|∞                  |78.6              |50.5              |100%                             |94%                            |
| 0.25|10                 |62.1              |39.9              |100%                             |89%                            |
| 0.25|∞                  |61.6              |39.5              |100%                             |89%                            |
| 0.50|10                 |49.7              |31.9              |98%                              |83%                            |
| 0.50|∞                  |48.9              |31.4              |98%                              |82%                            |
| 0.69|10                 |44.9              |28.8              |97%                              |80%                            |
| 0.69|∞                  |43.9              |28.2              |96%                              |79%                            |
| 1.00|10                 |40.0              |25.7              |94%                              |76%                            |
| 1.00|∞                  |38.8              |24.9              |94%                              |75%                            |
| 1.33|10                 |36.8              |23.6              |92%                              |73%                            |
| 1.33|∞                  |35.3              |22.7              |91%                              |72%                            |
| 2.00|10                 |32.7              |21.0              |88%                              |69%                            |
| 2.00|∞                  |30.8              |19.8              |86%                              |67%                            |
| 4.00|10                 |27.3              |17.6              |80%                              |62%                            |
| 4.00|∞                  |24.4              |15.7              |75%                              |58%                            |
| 6.00|10                 |25.0              |16.0              |76%                              |59%                            |
| 6.00|∞                  |21.4              |13.7              |67%                              |53%                            |

### Table S16. Overdispersion and residual autocorrelation estimated per species with an effort offset (exploratory)

|Set                       |Records/yr | Species|φ, no trend |φ, linear trend |φ, quadratic trend |Lag-1 autocorrelation |
|:-------------------------|:----------|-------:|:-----------|:---------------|:------------------|:---------------------|
|ants                      |1-10       |     200|0.27        |0.40            |0.55               |-0.02                 |
|ants                      |10-100     |     200|0.65        |0.83            |0.96               |0.12                  |
|ants                      |>=100      |     124|1.29        |2.01            |2.55               |0.22                  |
|birds (eBird)             |1-10       |     200|1.03        |1.49            |1.69               |0.02                  |
|birds (eBird)             |10-100     |     200|3.05        |4.67            |5.79               |0.16                  |
|birds (eBird)             |>=100      |     200|8.10        |13.79           |20.09              |0.50                  |
|birds (excluding eBird)   |1-10       |     200|0.83        |1.10            |1.40               |0.03                  |
|birds (excluding eBird)   |10-100     |     200|1.37        |2.76            |3.40               |0.20                  |
|birds (excluding eBird)   |>=100      |     200|1.81        |4.27            |6.11               |0.50                  |
|copepods                  |1-10       |     200|0.20        |0.37            |0.48               |0.03                  |
|copepods                  |10-100     |     200|0.69        |1.09            |1.31               |0.19                  |
|copepods                  |>=100      |      83|1.62        |3.08            |3.20               |0.39                  |
|enchytraeids              |1-10       |      91|0.28        |0.40            |0.48               |0.01                  |
|enchytraeids              |10-100     |      30|0.76        |1.01            |1.01               |0.13                  |
|jellyfish                 |1-10       |      49|0.83        |1.14            |1.40               |-0.02                 |
|jellyfish                 |10-100     |      23|1.14        |2.40            |2.49               |0.03                  |
|jellyfish                 |>=100      |      12|3.94        |5.63            |5.84               |0.37                  |
|mammals                   |1-10       |     200|0.41        |0.66            |0.88               |0.03                  |
|mammals                   |10-100     |     200|0.76        |1.25            |1.48               |0.19                  |
|mammals                   |>=100      |     200|1.54        |3.00            |4.26               |0.38                  |
|mammals (no machine obs.) |1-10       |     200|0.39        |0.62            |0.76               |0.04                  |
|mammals (no machine obs.) |10-100     |     200|0.83        |1.30            |1.90               |0.18                  |
|mammals (no machine obs.) |>=100      |     200|1.69        |3.79            |5.66               |0.43                  |
|mesopelagic_fish          |1-10       |      98|0.40        |0.44            |0.52               |-0.08                 |
|mesopelagic_fish          |10-100     |      51|0.77        |0.81            |0.81               |-0.07                 |
|mesopelagic_fish          |>=100      |       7|1.65        |1.90            |1.07               |0.02                  |
|mites                     |1-10       |     200|0.29        |0.56            |0.69               |0.01                  |
|mites                     |10-100     |     200|0.43        |0.80            |0.89               |0.17                  |
|mites                     |>=100      |      37|0.43        |0.78            |1.59               |0.32                  |
|pteropods                 |1-10       |      26|0.25        |0.46            |0.61               |-0.06                 |
|pteropods                 |10-100     |      17|0.77        |0.93            |1.08               |0.05                  |
|soil_nematodes            |1-10       |     200|0.14        |0.25            |0.49               |-0.05                 |
|soil_nematodes            |10-100     |      24|0.30        |0.44            |0.50               |0.16                  |
|springtails               |1-10       |     200|0.17        |0.34            |0.48               |0.01                  |
|springtails               |10-100     |     175|0.45        |0.64            |0.76               |0.07                  |
|springtails               |>=100      |      31|0.83        |1.64            |2.04               |0.07                  |

### Table S17. Effect of year-to-year autocorrelation on the effort-offset method (φ = 0.69; exploratory)

|Scenario                   | Records/species-yr| Years|ρ = 0 |ρ = 0.44 |
|:--------------------------|------------------:|-----:|:-----|:--------|
|no decline: false declines |                  1|    10|7.5%  |9.2%     |
|30%/10yr: power            |                  1|    10|8.9%  |11.5%    |
|no decline: false declines |                  1|    25|7.7%  |11.6%    |
|30%/10yr: power            |                  1|    25|22.2% |25.4%    |
|no decline: false declines |                  1|    50|5.3%  |11.7%    |
|30%/10yr: power            |                  1|    50|59.2% |58.9%    |
|no decline: false declines |                 10|    10|11.7% |18.0%    |
|30%/10yr: power            |                 10|    10|17.1% |25.5%    |
|no decline: false declines |                 10|    25|8.7%  |17.4%    |
|30%/10yr: power            |                 10|    25|38.9% |44.0%    |
|no decline: false declines |                 10|    50|9.3%  |16.9%    |
|30%/10yr: power            |                 10|    50|92.0% |87.1%    |
|no decline: false declines |                100|    10|11.4% |21.1%    |
|30%/10yr: power            |                100|    10|22.1% |29.1%    |
|no decline: false declines |                100|    25|11.7% |18.1%    |
|30%/10yr: power            |                100|    25|46.1% |50.1%    |
|no decline: false declines |                100|    50|9.4%  |17.5%    |
|30%/10yr: power            |                100|    50|97.0% |91.1%    |

*Share of 1,000 series flagged as significantly declining (one-sided α = 0.05).*


### Table S18. British butterflies 2000–2019: GBIF record-based trends versus UK Butterfly Monitoring Scheme trends (48 species; exploratory)

|Method                      |Pearson r |Spearman ρ |UKBMS declines detected |False declines | Opposite significant sign|
|:---------------------------|:---------|:----------|:-----------------------|:--------------|-------------------------:|
|(a) effort offset           |0.42      |0.45       |8/14                    |9/34           |                         2|
|(b) relative reporting rate |0.40      |0.38       |11/14                   |20/34          |                        11|
|(c) raw counts              |0.42      |0.43       |0/14                    |1/34           |                        12|

### Table S19. Share of described species by time to detect a 30% decline per decade (exploratory)

|Group            | Species|Never recorded 2015–2024 |Undetectable within 100 yr |Among recorded species |Detectable within 50 yr |Detectable within 25 yr |
|:----------------|-------:|:------------------------|:--------------------------|:----------------------|:-----------------------|:-----------------------|
|ants             |   14438|53.7%                    |74.6%                      |45.2%                  |6.3%                    |0.0%                    |
|birds            |    9269|0.2%                     |0.4%                       |0.3%                   |98.8%                   |89.2%                   |
|copepods         |   15297|87.5%                    |92.9%                      |43.1%                  |1.9%                    |0.0%                    |
|enchytraeids     |     840|74.2%                    |85.5%                      |43.8%                  |3.9%                    |0.0%                    |
|jellyfish        |     297|42.4%                    |55.9%                      |23.4%                  |26.3%                   |5.7%                    |
|mammals          |    4727|24.3%                    |36.4%                      |16.0%                  |33.7%                   |0.0%                    |
|mesopelagic_fish |     252|28.6%                    |39.3%                      |15.0%                  |17.5%                   |0.0%                    |
|mites            |   29017|87.0%                    |93.8%                      |52.0%                  |1.0%                    |0.0%                    |
|pteropods        |     141|50.4%                    |64.5%                      |28.6%                  |11.3%                   |0.0%                    |
|soil_nematodes   |   19667|88.8%                    |96.1%                      |65.3%                  |0.0%                    |0.0%                    |
|springtails      |    8926|82.2%                    |89.6%                      |41.3%                  |2.7%                    |0.0%                    |

### Table S20. Taxonomic scope corrections (exploratory)

|Group            |Records, main rule |Records, corrected |Described species used |Below 0.32 records/yr |Same, alternative species count |
|:----------------|:------------------|:------------------|:----------------------|:---------------------|:-------------------------------|
|mesopelagic_fish |127,567            |246,448            |968                    |62.1%                 |                                |
|mites            |1,315,602          |670,906            |29,017                 |97.3%                 |98.6% (55,000)                  |
|soil_nematodes   |416,187            |207,898            |19,667                 |96.6%                 |97.7% (29,000)                  |

*Mites: water-mite, plant-, animal-associated and stored-product families excluded; nematodes: marine-dominated orders and animal-parasitic taxa excluded; mesopelagic fishes: 15 families (species count = species ever recorded). Alternative counts from literature compilations.*



## SI References
