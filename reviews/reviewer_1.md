# Referee report: Reviewer 1

**Manuscript:** "Body size governs how often animals are recorded and how long their declines stay hidden" (H. Doi), submitted to PNAS. Reviewed at commit 40d8e93.
**Reviewer expertise:** macroecology, allometric scaling theory, detection geometry, cross-taxon comparative analysis.

All re-analyses mentioned below are my own light, read-only checks. I ran them from the project directory with `targets::tar_read()` objects, the archived CSV outputs and a modified copy of `models/tierB_eiv.stan` kept outside the repository. Each is labelled as a reviewer check. None of them is a substitute for the analyses I ask the author to do.

---

## Summary of the submission

The author divides GBIF record counts from 2000 to 2024 by global census abundances to get "records per individual" (r = R/N). This is done for ten animal groups whose abundance estimates are classed as independent of occurrence data: soil nematodes, springtails, soil mites, ants, enchytraeids, copepods, pteropods, planktonic cnidarians, Antarctic krill and mesopelagic fishes. r is then regressed on "typical mass" M = B/N in an errors-in-variables (EIV) Stan model.

The headline result is β = 0.72 (95% CrI 0.49–0.94), described as "indistinguishable from the 2/3 expected if detectability tracked projected area". Further claims are:

- Mammals with survey-based censuses lie 3.8 orders of magnitude (1.7–5.9) above the extrapolated invertebrate line.
- Within mammals the slope is shallow (0.32).
- DNA-derived records scale less steeply than human observations (0.51 vs 0.75).

The second half of the paper uses negative-binomial simulations with an empirically estimated overdispersion (φ ≈ 0.69). It argues that a 30% per decade decline needs about 44 years to detect from records whatever the record rate, and that most small-invertebrate species are effectively undetectable. Exploratory analyses deal with never-recorded species and the body-size skew of the Living Planet Database.

The study was preregistered, with a dated change log, and the pipeline is transparent and reproducible. Assembling census provenance (`docs/data_provenance.md`) and classifying estimates as independent, occurrence-derived or allometry-derived is careful work and a real contribution.

## Overall assessment

The question matters, and building a records-per-individual comparison across phyla is new. The preregistration and the openness about circularity (birds, allometric mammal abundances) are exemplary. However, the central scaling claim does not survive scrutiny in its current form. The claim is that records per individual scale as M^0.72, consistent with an optical projected-area mechanism.

1. **The exponent mostly reflects the denominator.** Across the ten groups, record counts R vary only 1.6 orders of magnitude, while N varies 5.8 orders and is almost collinear with M (r = −0.96). Records shuffled at random across groups give β ≈ 0.89 [0.70, 1.08] and R² ≈ 0.84. The preregistered H1 criterion (R² > 0.7) is therefore met by random records, and the observed β lies in the lower tail of that null.
2. **β is confounded with habitat.** Adding a soil-vs-marine indicator moves β to ≈ 0.97 [0.77, 1.19]. That excludes 2/3 and implies records proportional to biomass within habitats. In the same model, soil groups get roughly 40× more records per individual than marine groups of the same mass.
3. **Mass and taxonomic scope are mismatched for several groups,** and two preregistered scope sensitivity analyses at the leverage endpoints (nematodes, mesopelagic fishes) were not run.
4. **The 2/3 prediction is asserted rather than derived.** The data cannot separate it from 3/4, and a density-based (Damuth-type) mechanism with no detection component predicts a similar exponent.
5. **The vertebrate "excess" compares species-level points with group-level points 4–8 orders of magnitude away.** Within mammals, records scale clearly sublinearly with abundance (exponent on N ≈ 0.5), so r is mechanically inflated for small populations. Telemetry records also inflate it.

The detection-power half of the paper does not depend on the scaling result. As the author acknowledges, it does not support a size gradient in detection (H3). The title and abstract link body size to both halves causally, and the analyses do not support that link.

I have set out below the concrete analyses that could rescue a defensible (possibly different) scaling result. Without them I could not support publication.

---

## Major comments

### 1. The scaling exponent is largely set by the census denominator, not by the records

r = R/N is a ratio whose variance comes almost entirely from N. From `census_main.csv` and `models/tierB_points.csv` (log10 units):

| Quantity | Range across the 10 groups |
|---|---|
| R (records) | 1.59 orders |
| N (individuals) | 5.75 orders |
| B (biomass) | 1.76 orders |
| M (mass) | 6.81 orders |

Simple OLS decompositions (reviewer check):

- log r on log M: slope 0.73 (SE 0.13), R² 0.80. This reproduces the EIV estimate.
- −log N on log M: slope **0.89** (SE 0.09), R² 0.92.
- log R on log M: slope **−0.15** (SE 0.09), R² 0.26. Groups of larger body size do not receive more records; if anything they receive fewer.
- log R on log N and log M jointly: γ_N = 0.03 (SE 0.37), β_M = −0.12 (SE 0.34). The data give no support for the premise that R ∝ N, which the model imposes as an offset with exponent 1.
- **Permutation null** (R shuffled across groups, 10,000 permutations): β median 0.89, 95% [0.70, 1.08]; R² median 0.84, 5th percentile 0.74. The observed β is lower than 93% of the permutations (P = 0.07).

So β = −slope(ln N ~ ln M) + slope(ln R ~ ln M) ≈ 0.89 − 0.15. The first term is a property of the censuses. The cross-group abundance–mass relationship is close to N ∝ M^−1 because B is nearly constant across these major groups (a Sheldon-spectrum-like pattern). For the five Bar-On groups it holds by construction, since N = B/m. The only information the records contribute is the −0.15 term.

The optical hypothesis predicts a log R ~ log M slope of 2/3 − 0.89 = −0.22. "Records unrelated to abundance or size" predicts 0, and "records ∝ biomass" predicts +0.11. The observed −0.15 ± 0.09 cannot separate the optical hypothesis from records that carry no information about abundance at all. The preregistered R² criterion for H1 is uninformative, because random records satisfy it.

The number of described species explains R much better than M does (log R ~ log S: R² = 0.61, slope 0.35 ± 0.10; adding log M gives 0.07 ± 0.11). This points to taxonomic and description effort, not individual detectability, as what drives record counts.

**Required:**

- (a) Report this decomposition and the permutation null (or an EIV analogue) in the main text.
- (b) Report R/B (records per unit biomass; preregistered secondary response, slope β − 1) and R/S (records per described species; preregistered but not reported) as primary descriptors.
- (c) Fit ln R = α + γ ln N + δ ln M (+ covariates) with a free exponent on N, and report the joint posterior of (γ, δ). In my EIV refit with γ free, the posterior settled on a ridge at γ ≈ −1.1 [−1.75, −0.50], which shows that γ and δ are not identifiable with these data.
- (d) Replace or supplement the R²-based H1 criterion with a test against the "records independent of N" null.
- (e) Simulation-based calibration of the decision rules under that null (see comment 7).

### 2. Habitat accessibility confounds body mass; groups are not independent

The five soil groups occupy the small end of the mass axis (log10 M from −6.3 to −2.7). The five marine groups are larger (−4.6 to +0.5) and far less accessible to recorders.

- **OLS (reviewer check):** with a soil indicator, the slope becomes 0.94 (SE 0.13), and soil groups lie 1.27 log10 units (SE 0.53) higher. The within-habitat slopes are 1.14 (soil, n = 5) and 0.84 (marine, n = 5).
- **EIV refit (reviewer check):** I used the author's model plus a type-specific habitat term (4 chains × 2,000 draws, adapt_delta 0.999, R̂ ≤ 1.007, 29 divergences out of 8,000, below the preregistered 0.5% rule). It gives β_all = **0.97 [0.77, 1.19]**, P(β > 2/3) = 0.997 and P(β < 1) = 0.60. The soil effect is +1.59 log10 [0.76, 2.41].
- **Human observations** in the same model: β = 1.02 [0.78, 1.26].

The pooled 0.72 is therefore consistent with a Simpson's-paradox structure: within each habitat, records track biomass (β ≈ 1). The flatter pooled slope arises because small soil animals are much more accessible than larger marine plankton.

With n = 10 and only partial mass overlap, I do not claim that 0.97 is right. The point is that the 2/3 conclusion does not survive the most obvious confounder.

The groups also share further structure, so the effective sample size is well below 10:

- **Estimation method:** five groups from Bar-On et al. use the same "B ÷ assumed mass" approach, the same carbon-to-wet conversion, and the default fold-10 B uncertainty.
- **Source:** mites and ants come from the same Rosenberg rerun.
- **Phylogeny:** five of the ten groups are arthropods.
- **Recording datasets:** a handful of datasets supply most records. In my check, three DNA-extension datasets supply 58% of springtail records, and the top five datasets supply 57% of copepod records. The dataset-concentration columns in `data/derived/records_diagnostics.csv` (`top1_dataset_share`, `top5_dataset_share`) are empty, although this diagnostic was planned.

**Required:**

- (a) A model with habitat (soil, marine; ideally an "accessibility" covariate such as the fraction of N lying within well-recorded regions), with results reported conditional on habitat.
- (b) Random or grouping effects for census source and record-generating dataset, or at minimum leave-one-source-out and leave-top-dataset-out analyses.
- (c) A spatially explicit version of the analysis, which would greatly increase effective sample size and allow effort to be controlled directly. Gridded census maps exist for several groups (van den Hoogen nematodes, Potapov springtails, Phillips et al. earthworms, KRILLBASE, MAREDAT/COPEPOD). Comparing these with the 1° GBIF cell aggregates the author has already built would give within-cell records-per-individual estimates with recorder effort as an offset.

### 3. M = B/N is often not the mass of what is recorded; N and R scopes differ; the EIV measurement model misrepresents known masses

"Typical mass" B/N is the arithmetic mean individual mass of whatever N counts. For five of ten groups it is an assumed constant: Bar-On divided B by an assumed per-individual mass, and that mass also defines N. Detection and recording, however, act on the recorded taxa and life stages. Several mismatches are large.

**Planktonic cnidarians.**
- M = 1.4 × 10⁻² g. This is the JeDI-based mean for all planktonic cnidarians, which numerically are mostly small hydromedusae and siphonophores.
- The GBIF rule counts Scyphozoa and Cubozoa. The most-recorded species are *Aurelia aurita* (24,293 records), *Rhizostoma pulmo* (21,249), *Chrysaora hysoscella* (14,397) and *Cyanea capillata* (11,450). These are medusae of roughly 10–10⁴ g.
- The recorded mass is therefore 3–6 orders of magnitude above the assigned M, and the point's x-position is essentially undefined.

**Soil mites.** At least about 30% of the 1.32 M records are not of soil mites:
- Varroidae (*Varroa*, honeybee parasite): 210,285 records (16%).
- Eriophyidae (gall mites, mostly records of plant galls): 131,562 (10%).
- Arrenuridae and Pionidae (freshwater water mites): about 80,000 (6%).

Gall and *Varroa* records do not arise from optical detection of an individual's projected area at all.

**Soil nematodes.**
- About 103,500 (25%) of Nematoda records fall in predominantly aquatic or marine orders (Enoplida, Desmodorida, Chromadorida, Monhysterida, Araeolaimida, Desmoscolecida, Plectida; approximate, since some of these have soil members).
- A further 94,000 (23%) have no order.
- N, by contrast, is soil-only.

**Mesopelagic fishes.** R counts Myctophidae only (127,567). Other mesopelagic families add about 90,000 records: Sternoptychidae 27,482; Stomiidae 20,164; Paralepididae 18,947; Gonostomatidae 14,313; Vinciguerriidae 6,607; Phosichthyidae 2,597. Meanwhile N (acoustic biomass ÷ myctophid mass) covers all mesopelagic fishes, including the numerically dominant *Cyclothone*.

**Copepods.**
- The assumed mass is the geometric mean of a 670-fold range (0.15–100 µg C) but is given a fold-3 uncertainty.
- R covers class Copepoda, including freshwater, benthic and parasitic taxa.

**Krill.**
- Atkinson et al.'s B is N × 0.486 g, so krill mass is known well. Yet the model treats ln B̂ as an observation independent of ln N̂, with a default fold-10 SD.
- The latent krill mass is consequently pulled toward the regression line: posterior log10 M = −0.82 [−1.63, 0.09] against the known −0.31. The krill point is plotted at the wrong mass in Fig. 1A.
- When I refit with krill mass observed at fold 1.5 (reviewer check), β = 0.68 [0.46, 0.90].
- The same structural issue (B derived from N in the same source, but errors treated as independent) affects nematodes (latent −6.52 vs observed −6.32) and probably springtails. It inflates M uncertainty and lets latent x-values move toward the line, which also inflates R² (see comment 7).

**Missing preregistered analyses.** The two leverage endpoints are exactly where the preregistered scope analyses were not run: S6c (excluding parasitic nematode families) and S6d (extended mesopelagic family list). S15 (correction for undescribed species) was not run either. `reports/phase4.md` states these were "not done because sources were not finalised". The SI says 15 sensitivity analyses were preregistered, but Table S2 omits these without comment, and they are not listed among the deviations. Leave-one-out shows the endpoints are the most influential groups: dropping nematodes gives 0.59; dropping mesopelagic fish gives 0.84.

**Required:**

- (a) Scope-matched R: restrict GBIF taxa to those covered by N (soil orders and families for nematodes and mites, excluding *Varroa*, eriophyid gall records and water mites; mesozooplankton copepod orders; all mesopelagic families). Alternatively, rescale N to the GBIF scope.
- (b) A recorded-unit mass: the record-weighted mean of species-level (adult or recorded-stage) masses for the species actually in GBIF. Species-level mass databases exist for soil invertebrates (e.g., BETSI), ants, copepods (e.g., Brun et al. 2017 trait database), cnidarian medusae and myctophids. Report β under this definition alongside B/N.
- (c) A measurement model with correlated N–B errors, or observations {N, m} where B was derived from N × m, as for krill.
- (d) Run S6c, S6d and S15, or list them explicitly as unrun deviations.

Some checks passed. In my refits, giving the copepod mass an SD derived from the full 0.15–100 µg C range (β = 0.72 [0.49, 0.92]) and using a hierarchical (structural) prior on latent ln M (β = 0.72 [0.49, 0.96]) left the estimate unchanged. The fold-3 choice and the flat latent priors are therefore not the problem.

### 4. The 2/3 "optical" prediction is not derived, is not unique, and is not tested by these data

The manuscript states that detection "governed by how large an organism appears" implies r ∝ M^(2/3). This needs a derivation with explicit assumptions, because standard detection and search geometry gives other exponents:

- **Strip or line searching in 2D with a visual-angle detection threshold:** detection distance scales with linear size L ∝ M^(1/3), so detections per individual per unit effort scale as M^(1/3).
- **Searching a 3D volume** (divers, plankton observers): detection volume ∝ d² gives M^(2/3).
- **Pawar et al. (2012)** obtain about 0.85 (2D) and 1.06 (3D) for encounter-rate scaling.
- **Near the limit of human visual acuity** (most nematodes, mites and copepods are below or near it), detection is a threshold function. A sigmoid in log M, not a single power law over seven orders, is the natural expectation.

More fundamentally, records for nine of the ten groups are not produced by observers detecting individuals. Human observations are a minority of records for every group except jellyfish (12–32%; jellyfish 79%; `records_diagnostics.csv`). Most records are specimens, net samples (87% of krill records are MATERIAL_SAMPLE), soil extractions and DNA. Within a sample, the chance of detecting a species is close to 1 whatever its size, and one record is produced per species per sampling event. Records therefore scale with occupancy × sampling events, not with individuals.

Under that process, r ∝ 1/density. If density follows the Damuth relation (∝ M^−0.75), then r ∝ M^0.75 with no detection mechanism at all. This alternative fits the data as well as the optical model does and is the more parsimonious one.

The posterior does not discriminate between candidate exponents. From the main draws (`tar_read(tb_main)`):

| Quantity | Posterior probability |
|---|---|
| \|β − 2/3\| < 0.2 | 0.89 |
| \|β − 3/4\| < 0.2 | 0.91 |
| β closer to 2/3 than to 3/4 | 0.46 |
| \|β − 1/3\| < 0.2 | 0.05 |
| \|β − 1\| < 0.2 | 0.23 |

The preregistered H2 ROPE (±0.2) is wide enough that 3/4 would equally be called "indistinguishable". The one analysis that isolates actual opportunistic human observers (S11b, iNaturalist only) gives 0.66 [0.17, 1.18], which is uninformative. The author's own literature positioning note (`docs/literature_positioning.md`, l. 61) already advises "consistent with" rather than a mechanistic claim, but the title, the Results heading ("as projected area predicts") and the first Discussion paragraph ("followed a simple rule ... the expected outcome of an observation process limited by what can be seen") go well beyond it.

**Required:**

- (a) A short formal derivation (SI) of the expected exponent under explicitly stated observation processes: 2D strip search, 3D volume search, threshold detection, and the occupancy/one-record-per-sample process with Damuth density.
- (b) Posterior model probabilities or Bayes factors for the candidate exponents {1/3, 2/3, 3/4, 0.89 (records-independent null), 1}, under the habitat-adjusted model.
- (c) A segmented or threshold model in log M (or at least a quadratic term) to test for curvature. With only 10 points this needs strong priors, and it could be informed by within-group species-level data (comment 6).
- (d) Restrict any mechanistic optical claim to human observations from opportunistic platforms, where the observation process actually is visual search, and analyse records per species within groups against species body size there.

### 5. The vertebrate "excess" rests on a long extrapolation, a mismatch of level, sublinearity in N and telemetry records

The claim that mammals lie 3.8 (1.7–5.9) orders above the line and that "the excess attaches to vertebrates as a group" has four problems.

**(i) Extrapolation distance.** The line is fitted from log10 M = −6.3 to +0.5 and evaluated at 4.7–8.2, which is 4–8 orders beyond the data and roughly 8–11 orders from the centring point. No group with an independent census lies between 3 g and 3 kg. In the same figure, prokaryotes lie about 4–5 orders *below* the downward extrapolation. Adding them gives β = 1.01 (S12), and adding birds and mammals gives 1.27 (S9). A single, steeper relationship across the whole range (or curvature) is as consistent with the data as "2/3 plus a vertebrate premium". The data in hand cannot distinguish the two.

**(ii) Sublinearity in N.** Within the 388 mammals with reported populations, a negative-binomial GLM of R on ln N and ln M (reviewer check) gives an exponent on N of **0.52 (SE 0.04)**, or 0.48 (SE 0.04) with order effects. The reliability of ln N is 0.98, so this is not attenuation from measurement error. If R ∝ N^γ with γ < 1, then r is mechanically higher for smaller populations.

The cross-group N–M regression implies about 10^9.6 individuals at log10 M = 6. The 52 census-independent mammal species have 10^1.7–10^7.0 individuals (median 10^5.2), about 4.4 orders fewer. With γ = 0.5, this alone predicts about 2.2 orders of excess; with γ near 0 (as across groups, comment 1) it predicts about 4.4, i.e. the whole observed excess of 3.8. Aggregation alone is not the explanation: pooling the 52 census-independent species into one group-level point still gives a residual of 4.0 [1.9, 6.2]. The population-size scale is.

**(iii) Telemetry and acoustic records.** All records were used (`sim/explore_vi_vertebrates.R` keeps everything except fossils). Machine observations account for:
- 885,511 of the 999,375 records of *Mirounga leonina*;
- 182,501 of the 423,735 records of *Phocoena phocoena*;
- 69,133 of the 402,971 records of *Megaptera novaeangliae*.

These are tag and click-detector fixes, not recorder attention or detectability.

**(iv) No prediction interval.** The interval "over the uncertainty of the line" leaves out the residual SD τ (≈ 1.15 ln units, ≈ 0.5 log10). A new group would also deviate by τ.

**Required:**

- (a) Use human-observation (or non-machine) records for the vertebrate comparison.
- (b) Model the vertebrate comparison with a free N exponent (or compare at matched N), and report how much of the excess remains.
- (c) Use full posterior predictive intervals including τ.
- (d) Add intermediate-mass groups or species with independent abundance estimates to close the 3 g–3 kg gap and test for curvature. Candidates include:
  - fish stocks with survey- or catch-based numbers-at-age and individual mass (e.g., the RAM Legacy Stock Assessment Database; hundreds of species from 10 g to 100 kg);
  - earthworms (Phillips et al. 2019, sample-based);
  - seabird colony censuses;
  - aerial-survey ungulate counts.
- (e) Moderate the text: "an excess that body size cannot explain" and "attaches to vertebrates as a group" are not established.

### 6. The within-mammal slope (0.32) contradicts the proposed mechanism, and within-group and cross-group slopes are not reconciled

If detection followed projected area, it should hold most clearly within a clade of visually detected animals. Instead, β is 0.32 [0.18, 0.47] within mammals and 0.11 within birds (Table S3), and 2/3 is excluded in both. The manuscript reads this as "the premium attaches to vertebrates as a group". It is equally a failure of the optical model at the level where it is most plausible.

In addition, the within-mammal β is estimated with the N exponent fixed at 1 (offset). Within mammals, ln N and ln M are positively correlated (r = 0.27 among species with reported populations, presumably a selection effect). With γ ≈ 0.5 (comment 5), freeing γ reduces the mass coefficient to 0.13–0.24 in my GLMs. In the macroecological literature on allometry, within-taxon and among-taxon exponents routinely differ: e.g., Damuth's within- vs across-clade density scaling, and the metabolic-scaling debate. A difference between them is not, on its own, evidence of a group-level "premium".

**Required:**

- (a) A hierarchical model with separate within-group and between-group slopes (e.g., centring species mass within group means), using all groups for which species-level masses and records exist.
- (b) For the invertebrate groups, where species-level N is unavailable, a within-group analysis of records per species against species body size, with range size or occupancy as a covariate. This directly tests whether larger species within the same group, sampled by the same methods, are recorded more.
- (c) Discussion of what the 0.32 / 0.72 discrepancy implies for the mechanism.

### 7. Errors-in-variables model: measurement structure, R², recovery tests and clustering

**(a) Independent N and B errors.** Treating N̂ and B̂ as independent when B was computed from N (krill, and probably nematodes and springtails) inflates M uncertainty to roughly fold 10–26. Combined with nearly flat priors on the latent values (ln M ~ N(−8, 25)), this lets latent x-values migrate toward the line (krill moved by 0.5 dex). This mechanically improves fit and R².

**(b) R² on latent values.** The Bayesian R² is computed on latent ln M, after it has been informed by the regression, and it includes the shared-ln N ratio component. It should be reported together with the permutation R² (comment 1). The priors on latent N and M should be stated numerically in the SI; it currently says only "weakly informative".

**(c) Recovery test design.** The parameter-recovery test (`sim/test_tierB_recovery.R`) simulated ln N independent of ln M, but in the real data cor(ln N, ln M) = −0.96. It also only tested recovery when the model is correctly specified, and 2 of 12 runs had R̂ > 1.03 with up to 27 divergences (`models/recovery_test_tierB.csv`). The SI statement that simulated data "recovered true slopes" is too generous.

Simulation-based calibration is needed with:
- realistic N–M collinearity and Bar-On-type structure;
- misspecified generative processes: records independent of N; records ∝ occupancy with Damuth density; a habitat offset.

This would show what β and the H1/H2 labels look like when there is no optical effect.

**(d) Clustering.** The Gaussian likelihood with variance τ² + 1/R treats records as Poisson-independent. Records are heavily clustered by dataset (comment 2), so dataset-level random effects, or at minimum leave-top-k-datasets-out sensitivity analyses, are needed.

### 8. H4 (DNA vs human slopes) is the cleanest test but is partly confounded with habitat

The DNA–human contrast deserves credit. Because both record types share the same N_g, the contrast amounts to a regression of ln(R_dna/R_human) on ln M, which is free of the census-denominator problem. In OLS (reviewer check) that slope is −0.25 (SE 0.07). It is robust to removing the three largest springtail DNA datasets: in my EIV refit, P(b_dna < b_human) = 0.92.

However, DNA records are concentrated in soil metabarcoding. With a soil indicator, the OLS slope falls to −0.16 (SE 0.09), and DNA/human ratios are 3.5× higher in soil groups. In the habitat-adjusted EIV model, b_dna = 0.88 vs b_human = 1.02, with P = 0.90, right at the preregistered threshold.

**Required:**
- (a) Present H4 as the ratio model.
- (b) Report it with and without habitat adjustment.
- (c) Temper "DNA-derived records are less size-biased" accordingly. The mechanistic link to the eDNA allometry of Yates et al. (exponent about 0.73 on mass for eDNA production) is not straightforward, because GBIF DNA records are presence records from metabarcoding, not eDNA concentrations.

### 9. The conclusions and framing outrun the evidence

- **Title.** "Body size governs how often animals are recorded" is contradicted by comment 1. R does not increase with M across groups (slope −0.15 ± 0.09) and is better predicted by described richness. r rises with M mainly because N falls with M.
- **Link between the two halves.** The detection results depend on φ and λ, not on β. H3 (a size gradient in detection) was not supported. The causal link between body size and "how long their declines stay hidden" therefore runs through the empirical distribution of record rates (λ), not through the scaling law. The paper should say so explicitly.
- **Discussion.** The first Discussion paragraph argues that taxonomic bias "often attributed to societal preference ... is the expected outcome of an observation process limited by what can be seen". This should be removed, or rewritten as one of several hypotheses consistent with the data.
- **Abstract.** It should state the ±0.2 equivalence band and that 3/4 is equally supported.

**Required:** retitle and reframe after the re-analyses above. If β ≈ 1 within habitats is confirmed, the honest headline is about habitat and accessibility (records roughly proportional to biomass within habitat, with an order-of-magnitude soil-vs-marine difference), not about projected area.

---

## Minor comments

1. **Fig. 1A.**
   - Krill is plotted at its latent posterior mass (log10 M ≈ −0.8) rather than the known 0.486 g (comment 3).
   - Horizontal (M) uncertainty is not shown.
   - Labels overlap (mites, springtails, enchytraeids, copepods; archaea and bacteria; krill and mesopelagic fish).
   - Species-level and group-level points share axes without a clear visual distinction of level.
   - The dotted line is not defined in the legend.
2. **Records diagnostics.** The dataset-concentration fields (`top1_dataset_share`, `top5_dataset_share`, `n_datasets`) in `data/derived/records_diagnostics.csv` are empty.
3. **Record-count discrepancies.** R_2000_2024 in `records_diagnostics.csv` differs slightly from the modelled R (ants 2,510,740 vs 2,509,986; nematodes 416,210 vs 416,187; probably fossils). Please reconcile, or state what differs.
4. **Van den Hoogen uncertainty.** For van den Hoogen's N, the meaning of "±" is unverified (`N_interval_type = 未確認`), and fold 10 is used for both N and B. Please state this in Table S1.
5. **Default B uncertainties.** For the Bar-On groups, the B uncertainties are defaults (fold 10), not reported values. Say so in Table S1, since these SDs drive the latent-M behaviour.
6. **Krill census period.** The krill census averages 1926–2004, while records cover 2000–2024. The temporal mismatch between census and records deserves a sentence for all groups.
7. **Geographic overlap.** Global N is dominated by regions (open ocean; boreal and tropical soils) where GBIF effort is low. Records per individual therefore mixes detectability with geographic overlap of recorders and organisms. This is a further reason for a gridded analysis (comment 2c).
8. **Two φ tables.** Two different invertebrate φ tables exist. Table S4c (from `sim/explore_occupancy_phi.csv`; e.g., nematodes ≥10: φ = 0.21, 27 species) and `sim/explore_phi_inverts.csv` (nematodes ≥10: 0.25, 45 species; jellyfish ≥10: 1.19) disagree. State which one feeds Fig. 2B.
9. **Data and code availability.** "Code ... will be deposited ... on acceptance" and "[to register before submission]" (GBIF derived-dataset DOI) need resolving. PNAS expects the data and code to be available to reviewers. The affiliation "[department to be confirmed]" is still a placeholder.
10. **Overdispersion floor.** The ~44-year floor follows directly from the NB variance (μ + μ²/φ) with a single φ. That φ is estimated from species × year residuals, which combine true population fluctuation, effort pulses and dataset publication pulses. The paper should say that the floor depends on attributing all of this variance to observation noise. A dataset-level decomposition of the year-to-year variance would help. (This is outside my main expertise; I defer to the other referees on the simulation design.)
11. **Mass definition.** "Typical mass" should be defined as the arithmetic mean individual mass. For log-normal within-group size distributions it exceeds the median by exp(σ²/2), and juvenile-dominated groups (nematodes, copepods with nauplii) will have B/N well below the recorded adult stage.

## Numbers checked

| Reported value (location) | Source checked | Result |
|---|---|---|
| β = 0.72 (0.49–0.94), Bayesian R² = 0.90 (Results; Table S2) | `models/tierB_summary.csv`, main/all | 0.719 [0.492, 0.944], R² 0.902. **Matches** |
| P(β − 2/3 > 0.2) = 0.09; P(< −0.2) = 0.02; P(β < 1) = 0.99 | `tierB_summary.csv`; draws from `tar_read(tb_main)` | 0.089; 0.016; 0.9925. **Matches** |
| DNA 0.51 [0.24, 0.79] vs human 0.75 [0.48, 1.01]; specimen 0.66 [0.38, 0.95]; P = 0.935; "24 of 27 supported, 3 inconclusive" | `tierB_summary.csv`, `models/tierB_h4.csv`, Table S2 | 0.509 [0.239, 0.791]; 0.752 [0.484, 1.010]; 0.663 [0.383, 0.949]; 0.935; 24/3. **Matches** |
| Within-mammal β = 0.32 (0.18–0.47), 388 species | `models/tierA_summary.csv` | 0.318 [0.180, 0.467], n = 388. **Matches** |
| Vertebrate excess 3.8 (1.7–5.9), 4.3 vs optical; land mammals 4.9 (3.2–6.7); humpback about 7 records per individual | `sim/explore_vertebrates_summary.csv`, `explore_vertebrates_species.csv` | 3.83 (1.73–5.93), 4.30; 4.87 (3.20–6.67); log10 r = 0.84 → 6.95. **Matches** |
| M range 4.8 × 10⁻⁷ to 3.1 g; R range 6.4 × 10⁴ (pteropods) to 2.5 × 10⁶ (ants) | `data/derived/census_main.csv`, `tierB_points.csv` | 4.76 × 10⁻⁷ to 3.09 g; 63,888 to 2,509,986. **Matches** |
| φ = 0.69 (0.66–0.71), 382 species | `sim/phi_estimate.csv` | 0.689 [0.664, 0.713], 382 species, 9,550 observations. **Matches** |
| Sensitivity medians "β 0.60–0.84" (Results) | `tierB_summary.csv` | Minimum is 0.595 (S10_drop_soil_nematodes; shown as 0.59 in Table S2). **Minor mismatch**: should read 0.59–0.84 |
| "Invertebrate groups were more overdispersed still (φ = 0.06–0.8)" | `sim/explore_phi_inverts.csv`; Table S4c | Range 0.057–1.19 (jellyfish ≥10: 1.19; 1.25 in Table S4c). Pteropods ≥10 (0.79) and jellyfish ≥10 are not more overdispersed than mammals (0.69). **Does not match** |
| "43–44 years in every group once species were recorded more than about five times per year" | `sim/tdetect_grid.csv` (E_flat, φ = 0.689), `sim/explore_const_grid.csv` | At λ0 = 6.3–16: 45–58 years. Krill is undetectable up to λ0 ≈ 40 and needs 51–93 years above that. 43–45 years only for λ0 > 100 in 9 of 10 groups. Under constant effort: 44–48 years at λ0 6–16. **Partially matches**; rephrase |
| LPD: mammals ×105 (×720 by populations); birds ×3 and ×12 | Table S9 | 104.8; 50,000 / 69.6 = 718; 108.1 / 35.5 = 3.0; 416 / 35.5 = 11.7. **Matches** |
| 92–97% of nematode, mite, copepod and springtail species undetectable | Table S10a | 96.5, 95.6, 94.7, 92.2%. **Matches** |

## Recommendation

**Major revision.** In my view this sits at the boundary of rejection.

The data compilation, preregistration and transparency are of high quality, and the questions are important. However, the central claim is not supported as stated: records per individual scale as M^0.72, consistent with an optical projected-area mechanism.

- The exponent is mostly a property of the census denominator; random records reproduce it, and the R² criterion.
- It moves to about 1 (excluding 2/3) once the soil-vs-marine difference is modelled.
- It rests on mass and scope definitions that do not match the recorded organisms at several key points.
- It cannot be distinguished from 3/4 or from a density-only (Damuth) mechanism.

The vertebrate-excess and within-mammal results are confounded by extrapolation, sublinear scaling with abundance and telemetry records.

I would want to see comments 1–5 addressed in full before reconsidering. The outcome is likely to be a substantially reframed paper, possibly centred on habitat accessibility, records per biomass and detection power, rather than on optical scaling.
