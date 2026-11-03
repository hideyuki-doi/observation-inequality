# Reviewer 4 report

**Manuscript:** "Body size governs how often animals are recorded and how long their declines stay hidden" (PNAS submission; repository commit 40d8e93)

**Reviewer expertise:** biodiversity monitoring, citizen-science trend estimation, occupancy-detection models, power analysis for monitoring schemes.

**Scope of this report.** I focus on the detection part of the paper: the Results sections "Overdispersion sets a floor on detecting declines" and "Common shortcuts produce spurious trends", Fig. 2, Tables S4–S6 and S10, and the corresponding Abstract, Significance and Discussion text. I checked these against `R/phase5.R`, `sim/explore_*.R`, the `sim/*.csv` outputs, `reports/phase5.md`, `phase6.md` and `phase7b.md`, and `PREREG.md`. I leave the scaling analysis (Fig. 1) to the other reviewers, except where it feeds the detection mapping. I ran a few light, read-only re-analyses on the frozen derived data (`data/derived/tierA_gbif_species_year.parquet`, `tierA_mammals.csv`), using the same filters as `estimate_phi()`. They are reported below as indicative checks, not as definitive estimates.

---

## Summary

The detection half of the paper estimates year-to-year overdispersion of GBIF record counts and asks how long a decline takes to become statistically detectable. The overdispersion is a negative-binomial shape φ, estimated from 382 mammal species with reported populations (2000–2024) using species and year fixed effects: φ = 0.69. Each species' annual record count is then simulated as NB(λ₀E_t e^(−dt), φ), with a sustained decline of 30% per decade. Three analyses are applied: an NB GLM with an effort offset, a binomial relative reporting rate and raw counts. T_detect is defined as the shortest series giving power ≥ 0.8 for a one-sided test at α = 0.05.

The main claims are as follows:

- **A floor.** Detection takes 43–44 years "regardless of how often a species is recorded", and about 28 years for a 50% per-decade decline.
- **A lower limit.** Species recorded fewer than about 0.3 times per year are undetectable within a century.
- **Most small invertebrates are undetectable.** Using observed record rates, 92–97% of described nematode, mite, copepod and springtail species would remain undetectable for a century, against fewer than 1% of birds.
- **Exploratory analyses help only partly.** An occupied-1°-cell index shortens detection for well-recorded species (44 to 26 years for mammals), and pooling 100 species gives 10–15 years.
- **Shortcuts mislead.** A binomial reporting-rate model gives 31–33% false declines, and raw counts give up to 33% false increases.

The Abstract and Significance turn these results into the general statement that "the species least visible to observers are also the species whose declines biodiversity records cannot reveal."

## Overall assessment

The paper has real strengths:

- The preregistration is careful.
- H3 is reported honestly as "not substantively supported". This is commendable and rarely seen.
- The code is transparent.
- An empirical, cross-taxon estimate of how variable record counts are is a useful quantity that the monitoring literature lacks.

The core intuition is probably right and worth stating: annual totals of opportunistic records for a single species are far too noisy to detect an IUCN-level decline within a decade.

However, the manuscript presents a modelling assumption as an empirical law, and then generalises it to "biodiversity records" as a whole. My main concerns are:

1. **The floor is fixed by the assumptions.** The ~44-year floor follows in closed form from three assumptions, and the simulations reproduce that number (comment 1).
2. **φ is not clean observation noise.** It mixes real population trends, dataset pulses and serial dependence, and the NB shape fits the data poorly (comment 2).
3. **The floor does shorten with more records.** Overdispersion falls with recording intensity, and birds have 3–9 times less overdispersion than the mammal value applied to them (comment 3).
4. **Best practice is not tested.** The analysis model is not what practitioners use, and the occupied-cell proxy cannot stand in for occupancy-detection models (comments 4–5).
5. **There is no validation.** Nothing is checked against structured monitoring, although suitable data exist (comment 6).
6. **The headline numbers rest on choices that are not decision-relevant.** These are a 100-year horizon, a sustained decline, and the convention of power 0.8 with α = 0.05. They also rest largely on species with zero records (comments 7–8).
7. **The multi-species result contradicts the framing.** The paper's own multi-species result shows that group-level declines in rarely recorded species could be detected within about 15 years under its own assumptions (comment 9).
8. **The false-trend comparison is mis-attributed.** The false-trend results arise from a different mechanism than in Isaac et al. 2014, and the summary statistics are diluted (comment 10).

These claims appear in the Abstract and Significance statement, so they must be correct as stated.

---

## Major comments

### 1. The ~44-year "floor" is a closed-form consequence of the noise model, not an emergent property of record data

For NB counts with large μ, the Fisher information for a log-linear slope tends to φ Σ(t − t̄)². The variance of the slope estimate is therefore about 12/(φT³), and the time to detection with power 1 − β is:

T_floor = [12 (z_α + z_β)² / (φ d²)]^(1/3)

With φ = 0.689, d = ln(1/0.7)/10, z_0.95 = 1.645 and z_0.8 = 0.842, this gives **T = 43.9 years**. For a 50% decline it gives **28.2 years**. The simulations reproduce these values to within a year:

- 43–44 years in 9 of the 10 groups in `tdetect_grid.csv`;
- 43 and 28 years in `explore_const_grid.csv`.

For K independent species with a common slope, the formula gives T_K = T₁·K^(−1/3), that is 20.4 and 9.5 years for K = 10 and 100. The simulated values in `explore_multispecies.csv` are 21 and 10.

So the ~10⁸ model fits compute a number that is fully determined by three inputs:

- (i) one index value per species and year;
- (ii) year-level, independent, gamma-multiplicative noise with variance 1/φ that does not shrink as records accumulate;
- (iii) the chosen α and power.

The statement "this floor did not shorten with more records" is therefore an **input** of the NB model, whose CV tends to φ^(−1/2) by construction. It is not a result.

This cuts both ways. The cube-root dependence makes "several decades" fairly robust: doubling φ shortens T by only 21%. The specific claims, however, depend entirely on assumption (ii). These are that the floor holds "regardless of how often a species was recorded", that it "cannot be removed by more records", and that it applies to "biodiversity records". Comments 2–3 examine assumption (ii).

**Requested:**

- **(a) Closed form in the main text.** State the closed form, with the simulation as a check for the low-count regime where the formula does not apply.
- **(b) T against residual variance.** Express T_detect as a function of the effective residual variance σ²_eff of whatever annual index is used, so that readers can insert values for their own monitoring data.
- **(c) Wording.** Describe the floor as a consequence of the stated assumptions, not as an empirical finding.

### 2. φ estimated from mammal records over 2000–2024 is not observation noise

With only species and year fixed effects, the residual absorbs several things that are not noise around a population signal:

- **(i) Real population change.** Species-specific changes over 25 years are absorbed, for example recovering whales and declining ungulates in the Greenspoon set.
- **(ii) Species-specific recording trends.** Examples are the uneven growth of iNaturalist among taxa and camera-trap programmes starting up; MACHINE_OBSERVATION makes up 9.7% of these species' records.
- **(iii) Dataset pulses.** One-off digitisations, uploads and surveys inflate single years.
- **(iv) Serial dependence.** Residuals are correlated from year to year.

The simulation then adds all of this as iid noise on top of the simulated decline. Real trend variance is therefore double-counted as noise, while autocorrelation is ignored.

My light checks used the same species, years and filters as `estimate_phi()`:

| Check | Result |
|---|---|
| ML refit, species + year (MASS::glm.nb) | φ = 0.72 (SE 0.013), which replicates 0.69 |
| 285 species with ≥10 non-zero years: species + year, then adding species-specific linear trends | φ = 0.79, rising to **1.16** (+47%; glm.nb convergence warnings, so indicative) |
| 120 species recorded in all 25 years: share of log-scale residual variance explained by species linear trends | **28%** |
| Lag-1 autocorrelation of residuals | median **0.38** (NB Pearson, the 285-species subset; 0.20 after adding species trends); 0.57 on log scale (120 spp.); 0.40 after removing linear trends |
| Pulses: 201 species with ≥250 records; share of a species' 2000–2024 records in its single largest year | median **0.18** (uniform = 0.04); 90th percentile 0.43 |
| Shape: 99 species with ≥100 records per year; log-scale residual SD and share of species-years >10-fold below expectation | observed **0.92 and 2.4%**; NB(φ = 0.69) data processed identically give **1.60 and 9.5%** |

The last row matters. With a gamma shape below 1, which upward pulses drive, the model implies frequent deep troughs that the data do not show. Under log-normal noise with the observed SD and independent years, the floor would be about 34–37 years, depending on the species set (SD 0.81 for the 120 always-recorded species; 0.92 for the 99 species with ≥100 records per year). After removing linear species trends (SD 0.63 in the 120-species set), it would be about 28 years. Positive autocorrelation pushes the other way. For AR(1) residuals with ρ ≈ 0.4, the slope variance is inflated by about (1 + ρ)/(1 − ρ) ≈ 2.3, giving a floor of about 58 years and making the Wald test in method (a) anticonservative.

These biases point in opposite directions. My checks bracket the floor at roughly **28–58 years**. "Decades" survives. "About 44 years", "a floor" and "four decades in every group" do not have the precision the text implies.

**Requested:**

- **(a) Decompose the residual variance.** Separate:
  - species-specific smooth trends, using species-level splines or random slopes;
  - dataset pulses, by aggregating to species × dataset × year with dataset random effects, or by removing each species-year's dominant dataset;
  - residual year noise.

  Report φ, or σ²_eff, net of each component.
- **(b) Posterior predictive checks.** Check the NB noise model by recording stratum: the distribution of log residuals, the frequency of troughs and pulses, and the ACF.
- **(c) State-space model.** Fit and simulate from a model with process and observation error, such as Gompertz or AR(1) state-space models (Dennis et al. 2006; Humbert et al. 2009; Staples et al. 2004).
- **(d) Block bootstrap.** As a non-parametric alternative, re-run T_detect using a block bootstrap of detrended empirical residuals.
- **(e) Recovery test for φ.** Simulate with known φ under the fixed-effects design and check whether the estimator recovers it. NB dispersion estimates with many incidental species parameters, 25 observations each and low means can be biased. This matters most for the low-count invertebrate strata (φ = 0.06–0.25), which set the "never detectable" thresholds in Fig. 2B.

### 3. Overdispersion falls with recording intensity and depends on how records are generated; birds contradict "regardless of how often recorded"

- **Mammals.** φ rises from 0.46 to 0.93 with recording intensity (Table S4b). I fitted a Taylor power law to mammal record counts after normalising for year. Its slope is b = 1.86 (95% CI 1.80–1.91), which is below 2, so the CV falls slowly with the mean. This is a slow erosion, not a hard floor.
- **Invertebrates.** φ rises 4–10-fold from the <1 to the ≥10 stratum (`explore_phi_inverts.csv`):
  - nematodes 0.06 to 0.25;
  - enchytraeids 0.07 to 0.65;
  - jellyfish 0.23 to 1.19.

  A rise in φ roughly in proportion to the mean is what clustered records produce: one sampling event yields several records, so the variance is about the mean times the cluster size. That mechanism averages out as the number of events grows. It is a different mechanism from a multiplicative year shock, and it implies no floor.
- **Birds.** The manuscript applies the mammal φ to birds (Fig. 2B, Table S10b) without estimating it, although the Tier A bird series exist. I estimated it the same way, using glm.nb with species and year fixed effects and 150 random species per stratum:

  | Bird records per year | <10 | 10–100 | 100–1,000 | 1,000–10,000 | >10,000 |
  |---|---|---|---|---|---|
  | φ | 0.74 | 2.38 | 4.42 | 3.84 | 5.97 |
  | Implied floor, 30% per decade (yr) | 43 | 29 | 24 | 25 | 21 |

  eBird makes up 76% of bird records 2000–2024. eBird checklists are semi-structured and record effort.

This strongly suggests that the floor reflects **how records are generated**, comparing checklists that record effort with ad hoc digitisation. It is not a property of "records" as such, and in the best-recorded class it does shorten with more records. The following statements are therefore not supported as written:

- "This floor did not shorten with more records" (Results);
- "regardless of how often a species was recorded" (Abstract);
- "does not diminish for common species" (Discussion).

**Requested:**

- **(a) More φ estimates.** Estimate φ, or σ²_eff, for birds, for each class, and by record source (eBird, iNaturalist, specimens, survey or sampling-event datasets).
- **(b) Class-specific φ in figures.** Use class-specific φ in Fig. 2 and Table S10b.
- **(c) Revise the claims.** The contrast between eBird-dominated birds and ad hoc invertebrate records is itself an interesting and constructive result: protocols that record effort reduce noise. It would strengthen the "practical conclusions" paragraph.

### 4. The analysis model is not how practitioners estimate trends from records

The simulation analyses one global count per species and year, using a GLM with a global effort offset. Current practice for trends from biological records looks quite different:

- occupancy-detection models with visits defined as recorder × date × site and list length as a detection covariate (van Strien, van Swaay & Termaat 2013, *J. Appl. Ecol.*; Isaac et al. 2014; Outhwaite et al. 2018, 2019, 2020);
- reporting-rate mixed models with site random effects and list length (Szabo et al. 2010; Isaac et al. 2014);
- Telfer (2002) and Frescalo (Hill 2012) applied to multi-year atlas periods;
- semi-structured models with effort covariates (eBird: Johnston et al. 2021; Fink et al. 2023);
- state-space indices and integrated models (Isaac et al. 2020).

These approaches do two things the simulation excludes:

- **(i) They use within-year spatial replication.** Many sites each contribute at most one detection per visit, so a dataset pulse at one site counts once rather than hundreds of times.
- **(ii) They model detection per visit.** Effort is separated from occupancy at the site level, not through a single global offset.

Under these models, the sampling variance of the annual index shrinks with the number of sites and visits. What remains as a floor is real process variance in occupancy, which would limit structured monitoring too.

Isaac et al. (2014) evaluated exactly these method classes on simulated data. As I recall, the declines were of a magnitude comparable to those here and the series covered roughly a decade; the authors should verify this. They found that occupancy-detection and well-specified reporting-rate mixed models kept nominal Type I error and useful power, unlike naive methods. The manuscript cites Isaac et al. 2014 only for "biased or weak trends", which misses its main constructive conclusion. Outhwaite et al. (2020) and van Strien et al. (2013) are treated in one sentence and set aside because "neither approach can help species recorded less than once a year". That is true, but it does not address the 44-year claim for well-recorded species.

**Requested:**

- **(a) One best-practice pipeline.** Implement one on real GBIF records for a test set in a well-recorded region (UK, Netherlands, or a US state with dense eBird and iNaturalist coverage). For example, use a Bayesian occupancy-detection model with list length, with visits derived from eventDate × recordedBy × 1-km or 10-km cell. Report the annual index noise and the resulting T_detect.
- **(b) Cheaper complementary check.** Take the published annual occupancy estimates for more than 5,000 UK species, including many invertebrate groups, from 1970 to 2015 (Outhwaite et al. 2019, *Sci. Data*). Compute the empirical residual noise of the indices around a smooth trend, and the implied T_detect, by taxon group and recording intensity. This directly tests whether a floor of about 44 years applies under best practice.
- **(c) Benchmark.** Reproduce one Isaac et al. 2014 scenario within the present simulation framework.
- **(d) Narrow the claims if needed.** If (a)–(c) are not done, restrict the claims in the Abstract and Discussion to "species-level annual record counts analysed with count models".

### 5. The occupied-1°-cell analysis is not a fair proxy for occupancy-detection models

- **Grain.** A 1° cell covers about 8,700 km² at 45° latitude and about 12,000 km² at the equator. Atlas and occupancy work typically uses 1–10 km grids. At 1° grain, widespread species saturate, and a 30% fall in abundance moves the occupied-cell count far less than 30% (the abundance–occupancy relationship). The assumption that the index "declines in proportion to abundance" is therefore strongly optimistic, as the SI concedes.
- **No detection model.** There is no visit structure and no per-cell effort; effort enters only as a fixed year effect common to all species. A raw count of occupied cells is noisier than a modelled occupancy index, so this part is pessimistic.
- **Weak identification.** For strata dominated by 0s and 1s, the NB φ is poorly identified. Mammals in the <1 stratum, for example, have φ = 9.95 (Table S4c).

Because these biases run in opposite directions, the analysis cannot show how real occupancy-detection would perform. It is informative in one direction, though, and the text should say so explicitly. Simply changing the index from records to occupied cells cut φ 2.5–40-fold and cut T from 44 to 26 years for well-recorded mammals. **The floor therefore depends on the index; it is not a property of record data.**

**Requested:**

- **(a) Finer grain.** Repeat the analysis at 10 km and 1 km grain with cell-visit structure.
- **(b) Explicit mapping.** Replace proportionality with an explicit mapping from abundance to occupancy, for example random placement, ψ = 1 − exp(−density × area).
- **(c) Detection model.** Add a detection model, or replace this analysis with the work requested in comment 4.
- **(d) Naming.** Rename the "occupancy index" to "occupied-cell count" so it is not confused with occupancy-detection models.

### 6. Empirical validation against structured monitoring is needed; I would require at least one

All detection results come from simulation. The key noise parameter cannot separate observation noise from real dynamics using records alone. Species that have both GBIF records and independent structured trend estimates provide the missing ground truth, and several suitable systems exist:

- **UK butterflies:** UK Butterfly Monitoring Scheme collated indices for about 60 species since 1976, alongside opportunistic distribution records;
- **North American birds:** Breeding Bird Survey trend estimates against GBIF and eBird records;
- **European common birds:** PECBMS indices;
- **Dutch butterflies and dragonflies:** monitoring network trends against opportunistic data (van Strien et al. 2013, *J. Appl. Ecol.*, already reported good agreement when the opportunistic data were analysed with occupancy models);
- **Danish birds:** the setting of Kamp et al. 2016.

**Requested analyses for at least one system:**

- **(i) Residual variance net of the true trend.** Compute the residual variance of GBIF annual counts after subtracting the structured-monitoring trajectory. This gives the actual observation noise, to compare with φ = 0.69.
- **(ii) Realised detection rate.** Among species declining by at least 30% per decade, or declining significantly, under structured monitoring, report the proportion that method (a) and an occupancy model detect within 10 and 20 years.
- **(iii) Realised false-alarm rate.** Report it among species that are stable under structured monitoring.
- **(iv) Agreement of trend estimates.** Report the correlation and sign agreement.

This would also give an important benchmark: structured monitoring's own T_detect, which is limited by process variance (White 2019; Wauchope et al. 2019). Readers could then see how much of the "44 years" is due to records and how much to population variability. For instance, butterfly indices with an interannual log-scale SD of about 0.3–0.6 imply about 17–28 years under the same formula. If that holds, records are worse than structured monitoring, but not categorically so.

Without such validation, the Abstract and Significance should describe the detection result as "in simulations calibrated with record-count variability". The phrase "declines biodiversity records cannot reveal" should be removed.

### 7. Decision framing: 30% per decade, power 0.8, and what "detect" means

- **The IUCN window.** A decline of 30% in 10 years is the Vulnerable threshold under criteria A2–A4. The assessment window is 10 years or three generations, whichever is longer. For criterion A, the question is whether a reduction can be detected **within that window**. Under the paper's own model (φ = 0.69, large λ):
  - power to detect a 30% per-decade decline within 10 years is **8%**, below method (a)'s own Type I rate of 12% at T = 10 (comment 10);
  - the **minimum detectable decline within 10 years** at 80% power is **96%**;
  - within 25 years, power is 28% and the minimum detectable decline is 56% per decade, or 88% cumulative.

  These numbers convey the practical message more directly than "44 years".
- **Cumulative decline at detection.** A T_detect of 44 years under a sustained decline means the population has fallen by **79%** by the time of detection, close to the A2 threshold for Critically Endangered (80%). The current wording invites the reading that a decline completed within one decade is detected 40 years later:
  - Abstract: "detecting a 30% decline over ten years … required about four decades";
  - Significance: "a 30% decline over a decade takes about 40 years to detect".

  Rephrase both, for example as "a sustained decline of 30% per decade".
- **Conventions.** A one-sided α of 0.05 with power 0.8 is arbitrary for monitoring, where missed declines are costly (Di Stefano 2003; Field et al. 2004; Legg & Nagy 2006). Under the same model, T is 28 years for α = 0.10 with power 0.5 (an early-warning setting) and 48 years for a two-sided test at 0.05 with power 0.8.
- **How trends are used.** Red-list and alert systems such as BoCC and the BTO alerts use trend magnitudes over 25 years, or the precision of the estimate, rather than significance at a fixed power.

**Requested:**

- **(a) Power within IUCN windows.** Report power within 10 years, and within three generations for vertebrates.
- **(b) Minimum detectable decline.** Report it over 10 and 25 years.
- **(c) Sensitivity to α and power.** Report T for other settings, or report the SE of the estimated 10-year change, or the probability that the estimated change falls in the correct IUCN band.
- **(d) Revised wording.** Rewrite the Abstract and Significance sentences accordingly.

### 8. "Undetectable within a century" mostly counts unrecorded species, and the 100-year horizon is not decision-relevant

- **Unrecorded species dominate.** Of described nematode, mite, copepod and springtail species, **82–89% had zero GBIF records in 2015–2024** (Table S10a) and were assigned λ = 0. Most of the headline "92–97% undetectable" is therefore "no records at all". Among species with at least one record, the share below threshold is:
  - 48% for ants;
  - 58% for copepods;
  - 66% for mites;
  - 68% for nematodes;
  - 56% for springtails;
  - 28% for jellyfish;
  - 18% for mesopelagic fishes.

  These shares are still meaningful, but they are not the headline.
- **The horizon decides the gradient.** Over 100 years, the criterion reduces to "λ below about 0.3–0.8 records per year", that is, fewer than about 10 expected records in a century. The preregistered mapping found **0% of species in any size class detectable within 25 years**, and by comment 3 even birds have a floor of at least 21 years. The body-size gradient in Fig. 2B is therefore the gradient in whether species are recorded at all, which is Fig. 1 restated through λ. It is not a gradient in decision-relevant detectability.
- **Inconsistent φ.** Fig. 2B uses each invertebrate group's own φ but the mammal φ for birds, although birds' own φ is 3–9 times higher. This confounds the comparison.
- **Framing.** The statement "most small invertebrate species would show no detectable decline even over a century" (Significance) is correct, but it is not informative. Nobody attempts species-level trend assessment for nematodes or mites from GBIF records. Where these taxa are tracked at all, it is through structured sampling: soil cores, suction and light traps, Malaise traps, metabarcoding. The sentence implies that record-based monitoring was ever a realistic option for them. Three questions would be more useful:
  - which share of species, individuals and biomass in each group could be assessed with best-practice record-based methods within a decision-relevant window of 10–25 years;
  - what increase in recording, or which structured or molecular design, would move a group across that threshold;
  - whether assemblage-level indicators could work (comment 9).

**Requested:**

- **(a) Split Fig. 2B** into "no records" and "recorded but below threshold".
- **(b) Use 10- and 25-year horizons.**
- **(c) Apply class-specific φ.**
- **(d) Reframe the Significance statement and the last sentence of the Abstract.**

### 9. The multi-species indicator result undercuts the species-level framing and needs a realistic implementation

`explore_multispecies.csv` follows T_K = T₁K^(−1/3) exactly. With K = 100, the time to detection is 10 years for λ ≥ 10, and **15 years even at λ = 0.3 records per species per year**. Taken at face value, the paper's own framework says that a common decline across 100 rarely recorded invertebrate species could be detected in about 15 years. That is the opposite of "invisible to record-based trend detection". The result currently sits in one sentence with a caveat, but it is central to how the paper should be framed.

Real multi-species indicators are built differently:

- geometric means of species indices (Gregory et al. 2005; Buckland et al. 2005);
- Monte Carlo propagation of species-index uncertainty (Soldaat et al. 2017);
- smoothed or Bayesian indicators (Freeman et al. 2021; Outhwaite et al. 2020).

They depart from the simulation in two key ways:

- **Heterogeneous trends.** Species trends differ, so between-species variance adds to the uncertainty of the mean trend.
- **Correlated noise.** Noise is correlated among species that share datasets, recorders and sites, beyond the common year effect.

Both can be estimated from the data at hand, for example as residual correlation among species pairs that share datasets.

**Requested:** implement a multi-species indicator with:

- (i) heterogeneous species trends drawn from an empirical distribution;
- (ii) residual correlation estimated from the records;
- (iii) each group's real species pool, meaning the number of recorded species and their λ.

Report the indicator's T_detect by body-size class, and bring this result into the main framing, for example "species-level trends are out of reach, but group-level indicators may not be".

### 10. False-trend results: the mechanism differs from Isaac et al. 2014, and the summary statistics are misleading

- **Method (b) is mis-specified.** Method (b) is a binomial GLM on annual counts, with the group total as trials and no overdispersion term. Its false-decline rate of 31–47% comes from ignoring extra-binomial variation, an error that a routine dispersion check would catch. It does not show that reporting-rate approaches are flawed. In Isaac et al. 2014, reporting rates were defined on visits or lists and sites, and their failures arose from changes in recording behaviour: effort, list length and site selection. Calling this "consistent with" or "extending" Isaac et al. conflates two mechanisms.

  **Requested:**
  - add a quasi-binomial, beta-binomial or observation-level random-effect version, which I expect to behave like (a);
  - remove "widely used", or cite studies that use exactly this specification.
- **Table S5 dilutes the rates.** Its rates are averages over 36 λ₀ values, many of which produce mostly-zero series where 65–83% of fits failed and were counted as non-detections. Stratifying `control_false_trends.csv` gives:

  | Method, condition | Reported in text | Stratified (λ₀ ≥ 10) |
  |---|---|---|
  | (b) false declines | 31–33% | **45–47%** at T = 10–50 |
  | (a) at T = 10 | "nominal (5–9%)" | **11.8%** |
  | (a) at T = 25 | | 7.1% |

  Method (a) is therefore anticonservative at short T. This is consistent with Wald tests on glm.nb fits with θ estimated from 10 points, and it also inflates power at short T.

  **Requested:**
  - report Type I error by λ₀ and T;
  - use likelihood-ratio or parametric-bootstrap tests;
  - report rates conditional on a successful fit as well.
- **Method (c) depends on effort.** The false-increase rate of method (c) is driven entirely by each group's effort trajectory, which runs from −20% per year (krill) to +12% per year (springtails). Averaging across groups is not meaningful. Report it as a function of effort growth.
- **Oracle effort.** Method (a) is given the true generating E_t as its offset. In practice, the bias in record-based trends comes from species-specific changes in recording, such as iNaturalist interest in particular taxa or new camera-trap and eDNA programmes. These are the scenarios studied in Isaac et al. 2014.

  **Requested:** add scenarios in which effort is mis-specified through species-specific effort drift. Under those, method (a) itself fails, which is the more realistic threat. This would turn the false-trend section from a confirmation into a contribution.

---

## Minor comments

1. **Main text vs Table S4b.** The main text gives φ = 0.88 for species with more than 1,000 records per year. `explore_phi_by_mean.csv` gives 0.8745, which Table S4b rounds to 0.87.
2. **Invertebrate φ range.** "Invertebrate groups were more overdispersed still (φ = 0.06–0.8)" is not accurate. Jellyfish in the ≥10 stratum have φ = 1.19 (`explore_phi_inverts.csv`), or 1.25 in Table S4c, which is higher than the mammal value.
3. **Two inconsistent invertebrate φ tables.** `explore_phi_inverts.csv`, used for Fig. 2B, and Table S4c, from the cell pipeline, are both stratified invertebrate φ tables but give different species counts and values: for example, nematodes ≥10 have 45 species and φ = 0.246 in one and 27 species and φ = 0.21 in the other. State which one feeds which result, and why they differ (only records with coordinates?).
4. **"More than about five times per year".** The text says detection took 43–44 years "once species were recorded more than about five times per year". Under constant effort, T is 48–49 years at λ₀ ≈ 4–6. The 43–44-year floor is reached only at λ₀ ≳ 50–100 (`explore_const_grid.csv`).
5. **"Fell steadily with body size".** The decline is not monotonic:
   - ants (log₁₀M −2.66, 76%) sit above pteropods (−2.75, 68%) and below enchytraeids (86%);
   - mammal bins in the middle of the range are 39–50%;
   - the smallest mammal bin (54%) holds only 24 species.

   Phase 6 calls the mammal trend "monotonic", which it is not.
6. **Fig. 2A vs the cited numbers.** Fig. 2A uses constant effort, while the text cites the preregistered grid with observed effort trajectories. Say which is shown and why.
7. **Krill mapping.** The preregistered mapping anchors λ₀ to 2024 but applies effort from 2000. For krill, with effort falling 20% per year, this counts the decline twice (noted in `reports/phase6.md`). State this in the SI as a known flaw of the preregistered mapping.
8. **Bisection noise.** The bisection uses a separate seed for each T and 1,000 replicates, which gives a Monte Carlo SE of power near 0.8 of about 0.013. T_detect therefore carries roughly ±1–2 years of Monte Carlo noise. Report it, and check that power is monotonic in T, at least for a subset.
9. **Minimum series length.** With T_min = 3, a Wald test with θ estimated from 3 points is unreliable. Use T_min ≥ 5, or a fixed θ, for short series.
10. **Failed fits.** Counting failed fits as non-detections is conservative for power but deflates false-positive rates. Report both ways.
11. **Global aggregation.** Using global annual counts mixes regions with different trends and effort histories. Most real assessments are national or regional. Note this, and ideally repeat the analysis for one region.
12. **Wrong van Strien 2013.** The citation is to the 2013 *Biodiversity and Conservation* pilot for a single damselfly. The more relevant paper is van Strien, van Swaay & Termaat 2013, *J. Appl. Ecol.* 50: 1450–1458, which validated trends from opportunistic data against monitoring.
13. **Missing literature.** Also consider citing:
    - Szabo et al. 2010; Telfer et al. 2002; Hill 2012 (Frescalo);
    - Outhwaite et al. 2018 (*Ecol. Indic.*) and 2019 (*Sci. Data*);
    - Kéry et al. 2009 (*J. Appl. Ecol.*);
    - Johnston et al. 2021 (*Divers. Distrib.*); Fink et al. 2023 (*MEE*);
    - Humbert et al. 2009 (*Oikos*); Dennis et al. 2006 (*Ecol. Monogr.*);
    - Gerrodette 1987; Di Stefano 2003; Field et al. 2004; Wauchope et al. 2019;
    - Gregory et al. 2005; Buckland et al. 2005; Soldaat et al. 2017;
    - Boyd et al. 2023 (*TREE*, non-probability samples).
14. **Inconsistent φ estimators.** Mammal φ comes from brms, but invertebrate and occupancy φ come from MASS::glm.nb. My ML refit of the mammal model gives 0.72 against 0.69 in brms, which is close, but use one estimator throughout or show that they agree.
15. **"For the first time".** The Discussion says record-count variability was "quantified across groups for the first time". Soften this, or support it with a targeted search; dispersion of record counts is routinely estimated within reporting-rate and occupancy studies, although not cross-taxonomically.
16. **Fig. 2B legend.** State that birds and mammals use the mammal φ, or better, replace it with class-specific φ (major comment 3).
17. **Acknowledgments.** The disclosure of AI assistance is appropriate. Make sure the deposited code includes the `sim/explore_*.R` scripts and their seeds, since several main-text numbers come from them.

---

## Numbers checked

| # | Claim (location) | Source checked | Result |
|---|---|---|---|
| 1 | φ = 0.69 (0.66–0.71), 382 species, 9,550 obs (Results, Table S4a) | `sim/phi_estimate.csv`; my ML refit (MASS::glm.nb, same filters) | **Confirmed**: 0.689 [0.664, 0.713]; ML refit gives 0.72 (SE 0.013) |
| 2 | Floor of 43–44 years for 30% per decade; 28 years for 50% (Results) | `sim/tdetect_grid.csv` (E_flat, φ = 0.689); `sim/explore_const_grid.csv`; closed form | **Confirmed**: 43–44 in 9 of 10 groups (krill 51); constant effort 43 and 28; closed form 43.9 and 28.2 |
| 3 | Table S5 false-trend rates (8.8/31.3/9.3/12.4; 6.1/33.3/10.2/33.3; 5.2/31.6/29.7/18.9%) | `sim/control_false_trends.csv` | **Reproduced exactly** as averages. Stratified at λ₀ ≥ 10: (b) 45–47%; (a) 11.8% at T = 10 (comment 10) |
| 4 | Occupied cells shorten detection from 44 to 26 years for mammals ≥10 records per year | `sim/explore_occupancy_tdetect.csv` | **Confirmed** (records 44, cells 26; φ 0.68 vs 4.51) |
| 5 | Pooling 100 species gives 10–15 years | `sim/explore_multispecies.csv` | **Confirmed** (K = 100: 15, 12, 10, 10 years for λ₀ = 0.3, 1, 10, 100); equals T₁K^(−1/3) |
| 6 | 92–97% of nematode, mite, copepod and springtail species undetectable within 100 years | `sim/explore_empirical_groupphi.csv`; Table S10a | **Confirmed** (92.2, 94.7, 95.6, 96.5%), but 82–89% of described species have zero records; among recorded species 56–68% |
| 7 | Birds below 1%; mammals 54% to 5% | `sim/explore_empirical_vert_all.csv`, `_vert_bins.csv` | **Confirmed** (birds 0.49%; mammal bins 54% with n = 24 to 5.3% with n = 57; not monotonic) |
| 8 | φ = 0.46 (<1 record/yr) and 0.88 (>1,000) | `sim/explore_phi_by_mean.csv` | 0.456 confirmed; >1,000 is **0.8745 (0.87)**, not 0.88 |
| 9 | Invertebrate φ = 0.06–0.8 | `sim/explore_phi_inverts.csv` | **Not accurate**: range 0.057–1.19 (jellyfish ≥10) |
| 10 | Undetectable below about 0.3 records per year | `sim/explore_const_grid.csv` | Confirmed (threshold between 0.25 and 0.40) |
| 11 | Floor reached "once species were recorded more than about five times per year" | `sim/explore_const_grid.csv` | **Imprecise**: T = 48–49 years at λ₀ ≈ 4–6; 43–44 only at λ₀ ≳ 50–100 |

The additional diagnostics I computed are reported in comments 2, 3 and 7, and are indicative:

- φ with species trends: 0.79 rising to 1.16;
- residual autocorrelation: 0.38–0.57;
- largest single-year share of a species' records: 0.18;
- NB shape mismatch: log-scale SD 0.92 observed vs 1.60 simulated;
- Taylor power-law slope: 1.86;
- bird φ by stratum: 0.74–5.97;
- minimum detectable decline within 10 years: 96%.

---

## Recommendation

**Major revision.**

The scaling result may well merit publication in PNAS; I defer to the other reviewers on that. The detection half, however, currently presents a closed-form consequence of one noise assumption as an empirical "floor". It applies that floor to "biodiversity records" in general without testing best-practice methods or validating against structured monitoring. It also builds its headline body-size gradient mainly from species that have no records and from a 100-year horizon.

Before I could support publication, I would need:

1. the closed form and a decomposition of φ, separating real trends, dataset pulses and autocorrelation, with a check of the NB shape against the data (comments 1–2);
2. class- and source-specific φ, including birds, and the corresponding revision of "regardless of how often recorded" (comment 3);
3. at least one empirical validation against structured monitoring, or against published occupancy-detection indices (comments 4 and 6);
4. reframing to decision-relevant windows and metrics, with "no records" separated from "below threshold" (comments 7–8);
5. a realistic multi-species indicator analysis, with its implication carried into the framing (comment 9).

If the validation shows that the floor holds for best-practice record analyses, the paper would make a strong and important point. If it does not, the detection section should be shortened to a statement about species-level annual record counts, and the Abstract and Significance should be rewritten accordingly.
