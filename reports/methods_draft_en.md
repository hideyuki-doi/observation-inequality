# Methods (draft, 2026-11-03)

*Draft for internal discussion. Citations are given as author–year; each is verified in `docs/data_provenance.md` or `docs/literature_positioning.md`. Items marked [check] must be verified before submission. Analyses not in the preregistration are labelled exploratory throughout.*

## Preregistration

Before any records-per-individual value was computed, we fixed the analysis plan in a preregistration (PREREG v1.0, 3 November 2026). It covers:
- the data versions, model equations and priors
- decision criteria for each hypothesis
- exclusion rules
- 15 sensitivity analyses

Later changes were only appended, each with its date and reason. These include:
- implementation changes to the species-level model and to the detection simulations (described below)
- an addendum on interpreting H3

All analyses outside the plan are reported as exploratory.

## Global census data

**Sources.** We compiled global estimates of abundance (N) and biomass (B) for animal groups from:
- Bar-On et al. 2018 (data repository, commit 36cf0a8)
- van den Hoogen et al. 2019
- Rosenberg et al. 2023
- Potapov et al. 2023
- Schultheiss et al. 2022
- Atkinson et al. 2009
- Irigoien et al. 2014
- Greenspoon et al. 2023 and 2025
- Callaghan et al. 2021

For each estimate we recorded the source location, uncertainty and estimation method.

**Method classes.** We classified each estimate as one of four types:
- **independent:** extrapolated from field samples such as soil cores, net hauls, acoustic or aerial surveys, or population models fitted to catch and survey data
- **occurrence-derived:** using citizen-science or other occurrence data
- **allometry-derived:** density predicted from body size or other traits
- **mixed**

Only independent estimates entered the main analysis, because occurrence- or allometry-derived abundances would build the tested relationship into the data.

Two classifications mattered most:
- **Birds:** the only species-level global bird abundances (Callaghan et al. 2021) predict every species' density from eBird data, so we classed them as occurrence-derived.
- **Land mammals:** for 92% of species, abundance in Greenspoon et al. 2023 comes from a support-vector regression with body mass among its predictors, so we classed those as allometry-derived.

**Main analysis groups.** Ten groups met the criterion and were analysed:
- soil nematodes (van den Hoogen et al. 2019)
- springtails (Potapov et al. 2023)
- soil mites, derived by rerunning the Rosenberg et al. 2023 code with a fixed seed
- non-arboreal ants (Rosenberg et al. 2023)
- Antarctic krill (Atkinson et al. 2009)
- five groups from Bar-On et al. 2018: enchytraeids, copepods, pteropods, planktonic cnidarians and mesopelagic fishes

For the five Bar-On groups, abundance is biomass divided by an assumed individual mass. We therefore realigned biomass to the subgroup the abundance refers to, and treated the assumed mass as an observation (see the model below).

**Units.** Biomass was converted to wet mass using each source's own factors where given: Rosenberg et al. dry-to-wet ratios, and the Potapov et al. carbon-to-fresh-mass equivalence. Otherwise we used the carbon-to-wet-mass ratio of 0.15 that Bar-On et al. 2018 applied to animals. Typical individual mass was M = B/N.

**Uncertainty.** We converted every census uncertainty to a log-normal standard deviation:
- 95% intervals and reported ranges: σ = (ln hi − ln lo)/3.92
- fold uncertainty f: σ = ln f / 1.96
- no reported uncertainty: a default fold of 10, with an assumed individual mass given fold 3, both varied in sensitivity analyses

## Occurrence records

**GBIF.** We aggregated all records from the GBIF public monthly snapshot of 1 November 2026: 10,346 Parquet files, 3.75 × 10⁹ records, read with the R package arrow from the AWS open-data buckets. Records were counted by taxon, year, basis of record and dataset class. We excluded records with occurrenceStatus = ABSENT and fossil specimens.

**Record types.** Dataset classes were taken from the GBIF API: eBird, iNaturalist research-grade, and datasets with the DNA-derived data extension. We defined four record types:
- human observation
- preserved specimen
- DNA-derived (records from datasets with the DNA-derived data extension)
- all records

We did not treat MATERIAL_SAMPLE as DNA-derived. Many such records are non-genetic net samples; 87% of Antarctic krill records, for example.

**Taxonomy.** The snapshot uses the Catalogue of Life eXtended Release taxonomy. Census groups were matched to GBIF taxa by explicit rules: phylum Nematoda, class Collembola, three mite orders, family Formicidae, family Enchytraeidae, class Copepoda, order Pteropoda, classes Scyphozoa and Cubozoa, family Myctophidae, and *Euphausia superba*. Species-level census names were resolved to accepted names with the GBIF species-matching service. The response R was the number of records from 2000 to 2024.

**BOLD.** We also obtained barcode record counts from the BOLD portal API.

## Scaling model (main analysis)

We fitted an errors-in-variables model in Stan (CmdStan 2.40 via cmdstanr). Each group g has latent abundance ln N_g and individual mass ln M_g. Census observations inform N, B = N·M, or the assumed mass M, each with the standard deviation above.

Records of type k were modelled as

ln R_gk ~ Normal(ln N_g + a_k + b_k (ln M_g − c), √(τ_k² + 1/R_gk)),

where c is the mean observed ln M and the 1/R_gk term approximates Poisson variance. A Poisson likelihood mixed poorly in parameter-recovery tests because counts are large (all R > 10³).

**Priors:**
- b ~ N(0, 2)
- a ~ N(−25, 10)
- τ ~ Half-Normal(0, 2)
- weakly informative priors on latent N and M

**Sampling and diagnostics.** We ran four chains of 1,000 warm-up and 1,000 sampling iterations with adapt_delta = 0.99. Convergence required R̂ < 1.01 and bulk and tail ESS > 400. Simulated datasets mimicking the census structure recovered true slopes of 0.67, 1 and 1.5.

**Decision criteria (preregistered):**
- **H1:** "clean scaling" if the 95% interval of β = b_all is narrower than 0.3 and the Bayesian R² exceeds 0.7, with a secondary description of "scaling with limited precision" for widths below 0.6.
- **H2:** "human interest dominant" if P(β − 2/3 > 0.2) > 0.95, and "flatter than optical" for the mirror case.
- **H4:** supported if P(b_DNA < b_human) > 0.9.

**Sensitivity analyses (preregistered):**
- cumulative records
- individualCount weighting
- species-level records only
- alternative census sources
- alternative taxon matching
- default uncertainty folds of 5 and 20
- alternative carbon-to-wet conversion
- adding occurrence- or allometry-derived groups (birds, mammals)
- leave-one-group-out
- excluding iNaturalist, or using iNaturalist only
- adding prokaryotes
- Monte Carlo propagation with ordinary regression instead of the errors-in-variables model
- a strict DNA definition

## Species-level models

**Data.** For mammals with reported population sizes in Greenspoon et al. 2023 (388 species after merging names that resolve to the same accepted species), we modelled species record counts R_s (2000–2024). Body masses came from COMBINE (Soria et al. 2021).

**Model.** The model was Poisson–log-normal:

log λ_s = ln N̂_s + α + β ln M_s + u_order + ε_s.

**Deviation from the plan.** The plan specified a brms model with measurement error on ln N. It mixed poorly because each species contributes one count. The measurement error on ln N and the residual ε are independent Gaussian terms entering the linear predictor additively, so we combined them into a single term with SD √(sdN² + τ²). We fitted this equivalent model directly in Stan with a centred parameterisation.

**Sensitivity analyses** used all 4,795 Greenspoon species, and the Callaghan et al. 2021 birds with AVONET masses (Tobias et al. 2022).

## Detection simulations

**Overdispersion.** We estimated the negative-binomial shape φ from yearly record counts of the report-based mammals, using a model with species and year fixed effects (brms).

**Simulated series.** Species series were simulated as y_t ~ NegBin(λ₀ E_t e^{−dt}, φ), with a 30% decline per decade (d = −ln 0.7/10) or no decline. E_t was the observed effort trajectory of each group from 2000 to 2024, held constant thereafter.

**Analysis methods compared:**
- (a) negative-binomial regression with log effort as offset
- (b) relative reporting rate tested with a binomial model, the denominator being the group's other records
- (c) negative-binomial regression on raw counts

Tests were one-sided at α = 0.05.

**Time to detection.** T_detect was the shortest monitoring period with power ≥ 0.8 over 1,000 replicates. It was found by bisection over 3–100 years, assuming power increases with T, and evaluated for 36 values of λ₀ between 10⁻² and 10⁵. Bisection replaced the planned evaluation of every T because evaluating every T would have required about 10⁸ model fits.

**Mapping to body mass.** We combined the scaling model's posterior with log-normal species abundance distributions (log₁₀ SD = 1.5; 1 and 2 in sensitivity analyses) and the described species richness of each group.

## Exploratory analyses

**Observed record rates.** For every described species in each group, we took λ as the mean annual GBIF records from 2015 to 2024, setting λ = 0 for described species without records. These values were compared with detection thresholds under constant effort (Fig. 2b).

Overdispersion for invertebrate groups was estimated by the same species-plus-year model in three record-rate strata. Up to 300 species were sampled per stratum.

**Occupancy-based index.** We re-aggregated the snapshot with coordinates into species × 1° cell × year. We then compared φ, and the resulting T_detect, between record counts and the number of occupied cells, assuming the occupancy index declines in proportion to abundance.

**Multi-species indicators.** We simulated pooled indicators of K = 10 and 100 species with independent species-level noise.

**Vertebrates with survey-based censuses.** The 45 marine mammals come from Greenspoon et al. 2025 (abundance recovered as biomass ÷ the source's mass). The remaining species are rhinoceroses (CITES CoP20 report), the African savanna elephant (Great Elephant Census, 18 countries) and two seals from IUCN text, 52 species in total. Each species was compared with the extrapolated main relationship across its posterior draws.

**Never-recorded species.** We predicted the share of species never recorded as E[exp(−r N_s T/25)] over the species abundance distribution. Predictions were compared with literature estimates of the undescribed share:
- nematodes, mites and springtails: Chapman 2009
- marine copepods and scyphozoans: Appeltans et al. 2012
- ants: Oberski et al. 2025

**Living Planet Database.** Body-size representation used the 2016 public release distributed with the rlpi package [check licence wording]. Species were matched by name to COMBINE (mammals) and AVONET (birds).

## Software and reproducibility

All analyses used R 4.6 with renv, targets, cmdstanr, brms, arrow and tidyverse; the random seed was 20261103. All figures and tables are generated by code. The GBIF snapshot will be cited through a GBIF derived-dataset DOI [to register before submission].
