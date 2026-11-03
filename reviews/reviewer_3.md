# Reviewer 3 report

**Manuscript:** "Body size governs how often animals are recorded and how long their declines stay hidden" (H. Doi), PNAS submission; repository snapshot reviewed at commit 40d8e93 (see note under Major comment 9).
**Reviewer expertise:** Bayesian statistics and measurement-error models, simulation-based power analysis, preregistration practice.

---

## Summary

The author divides 2000–2024 GBIF record totals (R) by independent global census abundances (N) for ten small-bodied animal groups and fits an errors-in-variables (EIV) model in Stan to the result. The model is ln R_gk ~ Normal(ln N_g + a_k + b_k(ln M_g − c), √(τ_k² + 1/R_gk)), with latent ln N and ln M informed by two census observations per group. Four record types (all, human observation, specimen, DNA-derived) are fitted jointly. The headline estimate is β = 0.72 (95% CrI 0.49–0.94), which the author calls "indistinguishable from 2/3" (optical scaling). DNA-derived records give a shallower slope (P = 0.935).

A species-level Poisson–log-normal model for 388 mammals gives a within-mammal slope of 0.32. A negative-binomial (NB) model with species and year fixed effects, fitted to mammal species × year counts, gives φ = 0.69. Simulations with this φ show that a 30%-per-decade decline needs about 44 years to detect (power 0.8) "regardless of how often a species was recorded". The preregistered mapping of detection time onto body size (H3) failed every size class within 25 years, and the author reports H3 as "not substantively supported". Exploratory analyses add a size gradient in the share of described species whose declines are undetectable, a mammal excess over the extrapolated line, predictions of never-recorded species, and Living Planet Database size bias.

The project is unusually transparent. It has a preregistration with an append-only change log, a targets pipeline, code-generated tables and a parameter-recovery test, and I could reproduce every core number I checked. My concerns are about what the statistical models can and cannot identify, and about how far the conclusions go beyond the decision rules. In brief:

1. Most of the β ≈ 0.7 "scaling" follows from fixing the coefficient on ln N at 1 (the records-per-individual ratio) together with the strong abundance–mass correlation across groups. When that coefficient is freed, the data show no dependence of records on abundance.
2. The joint four-type EIV fit treats overlapping record counts as independent evidence about the latent censuses. This inflates R² and narrows the β interval enough to change the preregistered H1 label.
3. The 44-year detection "floor" is a closed-form consequence of the NB variance function. The φ that sets it mixes sampling noise with species-specific trends, and the residuals are autocorrelated, which the iid simulation ignores.
4. A known error in the preregistered H3 mapping (effort counted twice) is documented in the internal reports but not in the manuscript. It plausibly drives the "no size gradient" H3 result.

## Overall assessment

The question is important and the data assembly is impressive. The preregistered decision rules are, for the most part, applied honestly in the tables. The interpretive layer, however (title, abstract, section headings, Discussion), claims more than the rules allow:

- "Indistinguishable from 2/3" is the default outcome of a rule that, at the precision achieved, would have returned the same verdict for any exponent between about 0.28 and 1.06, isometry included.
- The title's claim that body size governs "how long declines stay hidden" is the preregistered hypothesis (H3) that the author reports as not supported. It rests on exploratory analyses whose size gradient comes mainly from the share of described species with zero records.
- The "four-decade floor" is presented as an empirical discovery, but it is determined analytically by one number (φ). That number comes from a model that cannot separate noise from signal.

None of these problems is fatal to a revised paper. Fixing them will, though, change the framing substantially. Several requested analyses take minutes to run; I ran crude versions of them, reported below.

---

## Major comments

### 1. The size scaling of records per individual is largely induced by the abundance offset (a ratio/shared-denominator problem)

The model fixes the coefficient on ln N at 1, so that ln r = ln R − ln N is the response. Across the ten groups, ln N and ln M are almost collinear (r = −0.96; slope of ln N̂ on ln M̂ = −0.89, 95% CI −1.10 to −0.67). By contrast, ln R varies little: SD 1.45 against 4.49 for ln N, a range of 1.6 orders of magnitude against 5.7. The consequences:

- **The no-abundance null already reproduces the estimate.** If records were the same in every group, the slope of records per individual on M would be 0.89 (0.67–1.10) automatically. The estimate β = 0.72 sits inside this null range.
- **Record totals barely change with body mass.** The slope of ln R on ln M̂ alone is −0.15 (−0.36 to 0.06).
- **Freeing the offset removes the abundance dependence.** OLS of ln R on ln N̂ + ln M̂ gives a coefficient on ln N of γ = 0.03 (95% CI −0.84 to 0.90). Monte Carlo propagation of the census errors plus OLS sampling gives γ = 0.02 (−0.77 to 0.70).
- **The same holds inside the author's own EIV model.** I replaced ln N_g by γ(ln N_g − mean) with γ ~ N(1, 2), using "all" records only. The result was γ = 0.03 (−0.95 to 0.83), P(γ < 1) = 0.987, and a size effect at fixed N of δ = −0.13 (−1.03 to 0.63). The posterior correlation between γ and δ is 0.96, so the two are weakly separated. Still, the optical hypothesis (records ∝ N × M^(2/3), i.e. γ = 1 and δ ≈ 2/3) gets no support from the unconstrained fit.
- **The constrained fit reaches γ ≈ 1 by moving the latent censuses.** Regressing ln R on the posterior-median latents from the constrained fit gives γ = 0.98. The latents have been moved toward the offset model (see comment 2), which is circular.

So the headline result is, to first order, a restatement of "abundance falls roughly as M^(−0.9) across these groups, while GBIF record totals per group are nearly constant". It is not evidence that detectability tracks projected area.

**Requested:**
- (a) Report the unconstrained EIV model (free γ) next to the preregistered one, with the joint posterior of (γ, δ), and compare the two by LOO or Bayes factor.
- (b) Report the constant-R null slope and its interval, and state explicitly that the observed β lies within it.
- (c) Add a null in which records are allocated to groups independently of N, for example in proportion to described species richness or to taxonomic-expert effort. Show whether it fits as well as the offset model.
- (d) Reword the abstract, the Results heading ("…as projected area predicts") and the first Discussion paragraph accordingly. At minimum, the mechanistic reading needs the untestable assumption γ = 1 stated up front.

### 2. Joint fitting of four overlapping record types violates the conditional-independence assumption and drives R², τ and the β interval

The four record types (PREREG §3 "K は同時に当てはめる") share the latent ln N_g and ln M_g but have independent residuals. "All" contains the other three types, and the group-level deviations are strongly shared. Using census point values with the posterior-median (a_k, b_k), the residuals of the four types correlate at 0.80–0.96. Even after the latents have absorbed part of the misfit, they correlate at 0.50–0.86.

The model therefore counts the same group-level anomaly four times as evidence about that group's latent census. The posterior latents move far from the census values where the assumed census error is loose:

| Group | Latent | Shift from census value |
|---|---|---|
| pteropods | ln N | −1.97 SD |
| copepods | ln N | −1.55 SD |
| soil nematodes | ln N | −1.01 SD |
| ants | ln N | +1.00 SD |
| krill | ln M | −0.99 SD (posterior median 0.15 g vs 0.49 g observed) |

Groups with tight reported errors (krill N, mites) do not move.

Refitting the preregistered model to the "all" record type alone, with the same priors, data and seed:

| Fit | β [95% CrI] | Width | R² | τ | P(β < 1) |
|---|---|---|---|---|---|
| Joint K = 4 (my refit; same as the manuscript) | 0.72 [0.49, 0.94] | 0.452 | 0.90 | 1.15 | 0.993 |
| "All" only, K = 1 | 0.73 [0.43, 1.03] | **0.600** | 0.79 | 1.82 | 0.96 |

Under the preregistered H1 rule (width < 0.6 for "limited precision"), the single-type fit falls on the "not confirmed" side by 0.0002.

The same mechanism explains a tell-tale pattern in Table S2:

| Default census fold | τ | R² |
|---|---|---|
| 5 | 1.49 | 0.85 |
| 10 (main) | 1.15 | 0.90 |
| 20 | 0.89 | 0.94 |

In my K = 1 refits, doubling every census SD raised R² from 0.79 to 0.88. **The less precise the censuses are assumed to be, the better the regression appears to fit**, because the latents are freer to move onto the line. R² as defined here (variance of the fitted latent line over that plus τ²) cannot be used as an H1 criterion.

**Requested:**
- (a) Use a multivariate-normal residual across record types, with an LKJ prior on the correlation, or use "all" alone for H1/H2.
- (b) Test H4 with a contrast model in which N cancels: ln(R_dna/R_human) = α + Δβ(ln M_g − c) + ε, with ln M_g latent. A crude OLS version on observed ln M gives Δβ = −0.245 (95% CI −0.42 to −0.07; one-sided p = 0.006, n = 10). This is stronger and cleaner than the current P = 0.935, because the census-N uncertainty and the shared group deviations drop out.
- (c) Report the posterior shift of every latent relative to its census value (z-scores), as above.
- (d) Report R² on an out-of-sample basis (LOO-R²), or drop it as a decision quantity.

### 3. Identifiability, default uncertainties, prior sensitivity, calibration and posterior predictive checks

**Identifiability and defaults.** Each group contributes two census observations for two latents, so the census alone just identifies the latents. The split between residual τ and census error is then identified only through the assumed census SDs. Of the 20 census observations:

- eight use the default fold 10: both observations for soil nematodes, springtail N, biomass for the five Bar-On groups, and krill B;
- five are assumed masses with the default fold 3;
- in total, 13 of 20 carry assumed rather than reported uncertainty.

Soil nematodes have the largest leverage (ln M̂ = −14.6, at the edge of the range) and default errors on both observations, giving a ln M SD of 1.66. Dropping them moves β from 0.72 to 0.59. In short, the β point estimate is robust to the defaults, but τ, R² and the interval width are not (comment 2).

**Prior sensitivity (n = 10), my K = 1 refits:**

| Prior changed | Result |
|---|---|
| τ ~ HN(0, 0.5) | width 0.43, R² 0.90 |
| τ ~ HN(0, 1) | width 0.52, R² 0.84 |
| τ ~ HN(0, 2) (preregistered) | width 0.60, R² 0.79 |
| τ ~ HN(0, 5) | width 0.635, R² 0.77 |
| b ~ N(0, 0.5) | median β 0.675 |
| b ~ N(1.5, 0.5) | median β 0.79 |

The H1 classification therefore depends on the τ prior. The preregistered latent priors ln N ~ N(40, 25) and ln M ~ N(−8, 25) are independent "functional" priors that ignore the −0.96 correlation between the latents. A structural (hierarchical) prior is the standard choice in EIV regression and should at least be reported as a sensitivity analysis.

**Calibration.** The recovery test has 12 fits, two per cell. That is not a calibration study. It fitted only K = 1, whereas the main analysis uses K = 4. Its simulated census SDs are known exactly and equal for every observation (fold 10, including the masses that the main analysis gives fold 3). Its own fits show up to 27 divergences and R-hat up to 1.039, which would have failed the preregistered convergence criterion. The R² recovered for β = 0.67 and τ = 2 ranged from 0.58 to 0.86 against a true value of about 0.73.

**Posterior predictive checks** are absent. PSIS-LOO on my refits gives Pareto k > 0.7 for 0–4 of the 10 groups depending on specification (2 in the default single-type fit) (soil nematodes, copepods, mesopelagic fish, pteropods, ants). In the joint model, ants have k = 1.04.

**Requested:**
- (a) Simulation-based calibration with at least 200 replicates for the model actually used (K = 4). Include (i) residuals correlated across types, (ii) census SDs misspecified by ×0.5 and ×2, and (iii) the real leverage pattern of ln M.
- (b) A prior-sensitivity table for β, its width and R² under alternative τ, b and latent priors, for example power-scaling with the priorsense package.
- (c) Posterior predictive and LOO-PIT checks, with Pareto-k diagnostics reported per group.
- (d) Leave-one-group-out predictive z-scores: does each left-out group fall inside its predictive interval?

### 4. H2 "indistinguishable from 2/3" is absence of evidence; the decision rule had essentially no power against isometry; the preregistered Tier A consistency check failed and is not reported

**The H2 rule could not have rejected isometry.** With the achieved posterior SD of about 0.115, the H2 rule returns "indistinguishable" for any posterior median between about 0.28 and 1.06. This includes β = 1, records proportional to biomass. At β = 1 the posterior probability of exceeding 2/3 + 0.2 would be about 0.88, below the 0.95 threshold.

**The posterior does not single out 2/3:**
- P(|β − 2/3| < 0.2) = 0.895, which does not reach 0.95 even under a generous region of practical equivalence;
- P(|β − 2/3| < 0.1) = 0.58, against P(|β − 3/4| < 0.1) = 0.63;
- the data support 3/4 (metabolic) at least as well as 2/3, as the Discussion concedes. Yet the Results heading, the abstract and Discussion paragraph 1 present the result as support for an optical mechanism ("followed a simple rule", "the expected outcome of an observation process limited by what can be seen").

**The preregistered Tier A consistency check failed.** PREREG §4 says Tier A is "consistent" when the Tier A and Tier B 95% intervals overlap. Mammals give 0.32 [0.18, 0.47] and Tier B gives 0.72 [0.49, 0.94]. These do not overlap, and the internal Phase 4 report correctly labels the result "整合しない" (not consistent). The manuscript does not report this verdict. Instead it reinterprets the shallow within-mammal slope as "the premium is attached to vertebrates as a group". A within-clade slope of 0.32 is, on its face, evidence against a single size-driven detection law.

**Requested:**
- (a) Report H2 as "the data do not distinguish 2/3 from 3/4, from isometry-adjacent values up to about 0.9, or from the constant-R null (comment 1)".
- (b) Report posterior probabilities for named hypotheses, or Bayes factors for 2/3, 3/4 and 1, and the constant-R null.
- (c) Retitle the first Results section.
- (d) State the preregistered Tier A verdict ("not consistent") explicitly in the Results.

### 5. The ~44-year "floor" is an analytic consequence of the NB variance function and should be derived, not simulated

For large λ, the Fisher information for a log-linear trend under NB with shape φ tends to φ per year, because the CV floor is 1/√φ. The power-0.8, one-sided α = 0.05 detection time is therefore

**T\* = [12 (z₀.₉₅ + z₀.₈)² / (φ d²)]^(1/3).**

**The formula reproduces every simulated floor:**
- φ = 0.689 with d = −ln(0.7)/10 gives T\* = 43.9 years. For a 50% decline, T\* = 28.2. The manuscript reports 44 and 28.
- The group-specific floors in Table S10a are reproduced within 0–4 years: jellyfish 36.0 vs 36, copepods 47.3 vs 47, mites 55.6 vs 54, nematodes 65.2 vs 61.
- A full Fisher-information power calculation at low λ also matches the simulation closely: λ₀ = 1 gives 68 vs 65 years, λ₀ = 1.58 gives 60 vs 58, and λ₀ = 2.5 gives 54 vs 53. Analytic power at T = 100 is 0.78 for λ₀ = 0.4 and 0.62 for λ₀ = 0.25, which explains the "< 0.3 per year undetectable" threshold.

**Consequences the manuscript should state:**
- (i) The floor scales as φ^(−1/3) d^(−2/3). It is insensitive to φ, which is why the preregistered φ sensitivity runs (0.66–0.71) changed nothing.
- (ii) "This floor did not shorten with more records" holds by construction, because a single φ was used at every λ. The author's own stratified estimates (Table S4b: φ 0.46, 0.56, 0.73, 0.93, 0.87) imply floors of 50, 47, 43, 40 and 41 years. The floor does shorten modestly with recording intensity.
- (iii) "43–44 years in every group" is identical across groups only because every group was given the same φ. In the preregistered grid it is also not true: for λ₀ ≥ 5, krill needs 51 years to never (no detection within 100 years) and mesopelagic fish 44–58, because of their effort trajectories (comment 8).
- (iv) Any φ below about 3.7 implies that no species, however often recorded, is detectable within 25 years. The preregistered 25-year H3 summary ("no species in any size class") was therefore fixed in advance by φ and carries no information about the mapping.
- (v) What is simulated is a sustained 30%-per-decade exponential decline. When it is detected at 44 years, abundance has fallen by about 79% (about 86% for the 50% case at 28 years). The abstract's "detecting a 30% decline over ten years … required about four decades" misdescribes the scenario.

**Requested:**
- (a) Present the closed-form T\* in the main text, with the simulation as confirmation for the low-λ regime.
- (b) Propagate φ(λ) instead of a single φ.
- (c) Restate the scenario and report the cumulative decline at detection.

### 6. φ conflates sampling noise with species-specific trends, dataset pulses and autocorrelated deviations

The preregistered φ model is y_st ~ NB(exp(α_s + γ_t), φ). Everything that is not a species mean or a common year effect is attributed to iid NB noise. That includes genuine species-specific population trends, species-specific changes in recording (a new photo-ID catalogue, a single dataset uploaded in one year), and persistent multi-year deviations. These components have opposite consequences for detection:

- real trends inflate φ⁻¹, so the floor is too long;
- species-specific effort trends create bias (spurious trends), which more data cannot remove;
- autocorrelated deviations make the naive NB-GLM test anti-conservative and lengthen the true detection time.

My crude checks on the same 382 mammal species × 25 years used profile likelihood for a common φ, species-specific terms, and year effects fixed at the base-model estimates:

- Base model: φ̂ (MLE) = 0.72, matching the brms value of 0.69.
- Adding species-specific linear trends: φ̂ = 1.07 (Δ log-likelihood +1,485 for 382 parameters).
- Adding quadratic terms: φ̂ = 1.33 (a further +851).
- The implied floor falls from 44 to 38 and then 35 years.
- After removing species-specific trends, the lag-1 autocorrelation of Pearson residuals has a median of 0.12 overall. By recording stratum it is −0.08 (< 1 record/yr), 0.05 (1–10), 0.22 (10–100) and **0.44 (≥ 100 records/yr)**. The iid expectation for T = 25 is about −0.09. The iid assumption is thus violated most strongly for exactly the frequently recorded species that define the "floor".

I also simulated log-normal–Poisson year noise with the same CV as φ = 0.69 and a mean of 100 records per year. The one-sided NB-GLM Wald test at nominal α = 0.05 then gave false-decline rates of:

| Lag-1 autocorrelation ρ | T = 25 | T = 44 |
|---|---|---|
| 0 | 0.12 | 0.10 |
| 0.2 | 0.16 | 0.14 |
| 0.44 | 0.21 | 0.20 |

So "the effort-offset model held its nominal error rate" (Table S5) holds only because the simulation generates exactly the model being fitted. The tail shape of the mixing distribution also matters: NB with φ = 0.69 has a much heavier lower tail on the log scale (variance of the log of the gamma mixing variable, trigamma(0.69) ≈ 2.9) than a log-normal with the same CV (0.90).

The "effort" series E_t themselves show that pulses dominate. Springtail totals peak at 70.7× the 2000 level in 2019 and fall to 8.8× in 2024. Krill totals fall to 0.004×. Copepods drop from 1.50× in 2022 to 0.62× in 2024, and mesopelagic fish from 0.80× to 0.17×; this pattern is consistent with publication lag in the final years. The 2024 value is then used as the plateau for the next 75 simulated years.

**Requested:**
- (a) Decompose the year-to-year variation with a hierarchical state-space model: NB or log-normal observation error, species random slopes, and an AR(1) or random-walk latent term. If possible, add species × dataset structure, since much of the "noise" is probably dataset turnover.
- (b) Simulate detection from the fitted decomposition rather than from iid NB.
- (c) Use tests that remain calibrated under autocorrelation: likelihood-ratio tests with AR errors, or parametric bootstrap.
- (d) Report the floor as a range over these noise models, and state which components are treated as noise and which as signal.
- (e) Exclude the last one or two years, or correct for publication lag, when building E_t.

### 7. Further simulation-design issues

- **(a) Bisection.** Bisection on T assumes power is monotone in T. That is reasonable for method (a), but not for (b) and (c). Under (c), raw counts with effort growing then flat can mask and then reveal the decline. Under (b), the test does not hold its size (about 31% false declines), so "time to 80% power" for (b) is not meaningful and should not appear in Fig. S2 or be compared with (a). At minimum, verify monotonicity on a dense T grid for a few λ₀ values. Different seeds per T (seed + T) also add Monte Carlo noise to the bisection decisions. Common random numbers across T would be cleaner.
- **(b) Failed fits.** Failed fits were counted as non-detections. Failure rates are 74%, 64%, 49%, 34% and 16% for λ₀ = 0.01–0.063 (constant-effort grid). Most failures are all-zero series, so no detection is the right outcome. Please separate "no data" from "fit failed with data", and report the latter.
- **(c) Short series.** The one-sided Wald test with an estimated θ is anti-conservative at short T: 8.8% false declines on average at T = 10, and up to 15.9% in some group × λ₀ cells. "Held its nominal error rate (5–9%)" should read "was anti-conservative at short T". A likelihood-ratio test would be preferable.
- **(d) "Up to 33%".** "Raw record counts flagged significant increases in up to 33% of series" quotes the mean over groups and λ₀ at T = 25. Individual cells reach 97.5% (T = 25) and 100% (T = 50). Report the range.
- **(e) Known offset.** The offset E_t is known without error and is exactly the effort that generated the data. In practice the offset is a noisy proxy (group totals that include the focal species and its dataset pulses). Add a scenario with a noisy offset.
- **(f) Minimum length.** T_min = 3 is harmless, given that the floor is far above it.

### 8. The preregistered H3 mapping contains a known effort double-counting error that the manuscript does not disclose, and it plausibly explains the absence of a size gradient

The PREREG §5 mapping sets λ_s0 = r̂ × w_g × N_s, with w_g = E_2024 / Σ E_t, which converts the 25-year total to a 2024-level annual rate. The simulation then multiplies λ_s0 by E_t starting from E_2000 = 1. In groups where effort declined, the decline is applied twice; in groups where it grew, the growth is applied twice. The author's internal report (reports/phase6.md, section (ii)) says exactly this ("減少が二重に効く"), but the manuscript and SI do not mention it.

The upper size tercile in the H3 test consists only of krill and mesopelagic fish. These are the two groups whose effort collapsed (E_2024/E_2000 = 0.004 and 0.17), and the upper tercile shows 90% undetectable within 100 years, against 76% for the middle tercile. The preregistered finding of "no size gradient" is therefore confounded by the error in exactly the tercile that decides H3. In addition, a log-normal species abundance distribution with σ = 1.5 log₁₀ units is applied to krill, a single species, so 96% of "krill species" are undetectable.

**Requested:**
- (a) Fix the mapping (use the 2000-level rate, or constant effort) as a documented deviation, rerun the preregistered H3, and report both versions.
- (b) Disclose the error in the SI.
- (c) Note that the 25-year criterion was uninformative (comment 5(iv)).

### 9. Preregistration transparency and framing

- **(a) Title and abstract versus the preregistered H3.** The title asserts the H3-type claim ("…how long their declines stay hidden") that the preregistered test did not substantively support. The size gradient in Fig. 2B comes from exploratory analyses, and most of it is the share of described species with no records at all in 2015–2024:

  | Group | Unrecorded | Classed undetectable |
  |---|---|---|
  | nematodes | 88.8% | 96.5% |
  | mites | 87.0% | 95.6% |
  | copepods | 87.5% | 94.7% |
  | springtails | 82.2% | 92.2% |
  | ants | 53.7% | 76.0% |

  The power analysis adds 8–22 percentage points. Please separate the two components and retitle, or label the claim clearly as exploratory. The abstract also includes exploratory results without labels (the 4–5 orders of magnitude mammal excess, and the 92–97%).
- **(b) Timing of deviations.** The SI states that "all changes were appended … before the corresponding results were interpreted". The git history shows otherwise:
  - the Tier A deviation was committed in the same commit as the Tier A results (94f0be2);
  - the §5 changes, including the φ estimate itself, were committed with the simulation results (6885b8b);
  - the H3 reinterpretation (17e717c) followed the H3 results, as it must.

  Please describe the deviations as "documented contemporaneously with the results" and identify the H3 addendum as post hoc.
- **(c) Preregistered sensitivity analyses that were never run.** Several sensitivity analyses in the plan were not run, and the manuscript does not list them as deviations:
  - S6 exclusion of parasitic nematode families;
  - S6 extended mesopelagic family list;
  - S15 undescribed-species correction;
  - apparently S5 (Rosenberg springtails) and S8 (prokaryote C/wet 0.15).

  The internal Phase 4 report acknowledges some of these as "未実施" (not run). List them in the SI deviation section.
- **(d) What the author knew before registration.** The preregistration states that R totals and N, B and M had been inspected before registration. r = R/N could therefore have been computed mentally. This is a pre-analysis plan registered after data collection, and it should be described that way.
- **(e) Verifiability of the timestamp.** The timestamp is a commit in a private repository. During this review the repository history was rewritten: the reviewed commit 40d8e93 no longer resolves and the branch was renamed. The PREREG v1.0 body is unchanged since 01a2fe7, which I verified with a diff, but a private git hash is not an independent timestamp. Please archive v1.0 publicly with a time-stamped registry entry or DOI (OSF or Zenodo), and provide an English translation; the PREREG is in Japanese.
- **(f) A preregistered quantity that is not reported.** The plan said "φ と年の揺らぎ" (φ and year-to-year fluctuation) would be estimated and used. The year-fluctuation estimate is not reported, and the simulations use only the group-total E_t.

### 10. Tier A deviation: "equivalent model" holds only under a flat prior on the latent abundance; τ is identified only conditional on sdN

Marginalising ln N_true out of the linear predictor gives η_s ~ N(ln N̂_s + …, √(sdN_s² + τ²)). This is exact only when ln N_true has a flat prior. brms `me()` places a hierarchical normal prior N(μ_x, σ_x) on the latent values, which shrinks the latent abundances toward the mean. Because ln N and ln M are correlated across species, that shrinkage can move β. The effect is probably small (sdN is typically much smaller than σ_x), but "equivalent" should read "equivalent under a flat prior on the latent abundance".

More importantly, there is one count per species. The shared τ is therefore separated from measurement error only because sdN is treated as known. The estimate τ = 2.48 (a factor of 12) absorbs any misstatement of the Greenspoon intervals. The same applies to the floor of 0.01 on sdN, and to lumped species, where sums of 2.5% and 97.5% quantiles are used as interval bounds. The switch to a centred parameterisation is purely computational and does not change the model; I have no concern there.

**Requested:**
- (a) Refit with the hierarchical latent prior, written in Stan with a centred η, and show that β is unchanged.
- (b) Report β and τ with sdN scaled by ×0.5 and ×2.
- (c) Note that the prior α ~ N(−15, 10) was specified for the uncentred intercept, while the implemented model centres ln M.

### 11. Multiplicity and evidential standards

The paper evaluates H1, H2 and H4 across four record types and 28 sensitivity fits, plus Tier A and many exploratory analyses.

- **H4 threshold.** The 0.9 threshold for H4 is lenient (roughly a one-sided p of 0.10). "DNA-derived records are less size-biased" as a section heading overstates P = 0.935.
- **"Supported in 24 of 27".** These are not independent replications, since they share nine of the ten groups and the same records. The count also includes S2, S9 and S12, which add groups that the preregistration said should be reported separately.
- **S13.** The "Monte Carlo + OLS" interval [0.61, 0.88] contains only census-error propagation. The code keeps `coef(lm(...))[2]` and discards the OLS sampling uncertainty, so the interval is not comparable with the CrIs it sits beside in Fig. S1 and Table S2.

**Requested:**
- (a) Present H4 through the contrast model (comment 2b), which may in fact strengthen it.
- (b) Report the sensitivity analyses as a robustness range, not as vote counts.
- (c) Fix S13 to include the regression sampling uncertainty, or remove it from Fig. S1.

---

## Minor comments

1. **β range.** The main text gives the sensitivity range of median β as "0.60–0.84". S10_drop_soil_nematodes gives 0.5949, so the range is 0.59–0.84.
2. **φ in the top stratum.** The main text gives φ = 0.88 for species with more than 1,000 records per year; Table S4b (and sim/explore_phi_by_mean.csv) gives 0.8745, i.e. 0.87. Also, the non-monotone pattern (0.93 for 100–1,000 records per year, then 0.87) deserves a sentence.
3. **Invertebrate φ.** "Invertebrate groups were more overdispersed still (φ = 0.06–0.8)" does not match the outputs. Table S4c gives 0.06–1.25 (jellyfish ≥ 10 records per year: 1.25; pteropods 0.72). Jellyfish records are less overdispersed than those of mammals.
4. **"In every group".** "43–44 years in every group once species were recorded more than about five times per year" is not true in the preregistered grid for krill (51 years to undetectable) or mesopelagic fish (44–58).
5. **Recovery-test widths.** PREREG §3 gives widths of 0.29–0.93; models/recovery_test_tierB.csv gives 0.30–0.93.
6. **Likelihood listed as a deviation.** SI deviation 1 lists the Gaussian likelihood on ln R as a deviation, but it is the preregistered model. Also, the 1/R term is irrelevant at these counts (≤ 1.6 × 10⁻⁵ against τ² ≈ 1.3), so the model is in effect a Gaussian regression on ln R. Records are clustered (by sample and dataset), not Poisson, and saying so is more accurate than calling the approximation "essentially exact".
7. **R² definition.** The Bayesian R² uses the latent ln M. Say so, and give an observed-scale or LOO version.
8. **Which grid underlies which statement.** Fig. 2A uses constant effort, while the Results text cites "preregistered simulations" with observed effort trajectories. State which grid underlies each sentence.
9. **Mammals in the < 1 record/yr stratum.** φ for occupied cells is 9.95 there (Table S4c). These counts are nearly binary, φ is poorly defined, and the corresponding occupancy T_detect should be flagged.
10. **λ window.** The observed-rate analysis takes λ from 2015–2024, which includes years affected by publication lag. Check the sensitivity to using 2013–2022.
11. **Summed quantiles.** For lumped Tier A species and for the S9 group rows, sums of 2.5% and 97.5% quantiles are used as interval bounds. This overstates the uncertainty of the total. It is a minor point, but should be stated.
12. **Rounding.** "P = 0.02" (main text) is 0.016. Report two significant figures consistently.
13. **Seeds.** The power simulations use seed + T per evaluated T. Document this, and consider common random numbers across T.
14. **Prokaryote analyses.** S12 adds prokaryotes and yields "clean scaling", β = 1.01. Together with S9 (β = 1.27), this suggests that a single power law does not describe the extended range. A short note on curvature, or on clade-specific intercepts, would help readers.

---

## Numbers checked

Checked against `targets::tar_read()` objects, project CSVs, and my own read-only refits (scripts kept in my scratchpad; no project files modified).

| # | Claim | Check | Result |
|---|---|---|---|
| 1 | β = 0.72 (0.49–0.94), R² = 0.90; P(β − 2/3 > 0.2) = 0.09; P(< −0.2) = 0.02; P(β < 1) = 0.99 | tb_main draws: 0.719 [0.492, 0.944], R² 0.902, 0.089, 0.016, 0.9925. Independent refit with same data, seed and priors: 0.719, width 0.452, R² 0.902 | ✓ reproduced (0.016 rounds to 0.02) |
| 2 | H4: P(b_DNA < b_human) = 0.935; DNA 0.51 [0.24, 0.79], human 0.75 [0.48, 1.01], specimen 0.66 [0.38, 0.95] | tb_main draws and tierB_summary.csv: 0.935; difference −0.24 [−0.58, 0.08] | ✓ |
| 3 | φ = 0.69 (0.66–0.71), 382 species, 9,550 observations | p5_phi: 0.689 [0.664, 0.713], 382, 9,550; MASS::glm.nb MLE 0.723 | ✓ |
| 4 | Floor about 44 years (30%/decade) and 28 years (50%) | Closed form T\* = 43.9 and 28.2; group floors in Table S10a reproduced within 0–4 years | ✓ (analytic) |
| 5 | Recovery test: 11 of 12 intervals cover the true value; widths 0.29–0.93 | recovery_test_tierB.csv: 11/12 (β = 1.5 replicate [0.986, 1.481] misses); widths 0.30–0.93 | ✓ / trivial discrepancy |
| 6 | Table S5 false-trend rates | control_false_trends.csv means match exactly (8.8/31.3/9.3/12.4; 6.1/33.3/10.2/33.3; 5.2/31.6/29.7/18.9); per-cell maxima 15.9% for (a) at T = 10 and 97.5–100% for (c, up) | ✓ means; "up to" wording ✗ |
| 7 | 24 sensitivity analyses with median β 0.60–0.84 | 24 analyses ✓; range 0.59–0.84 | ✗ minor |
| 8 | φ = 0.88 for > 1,000 records/yr | 0.8745 | ✗ minor |
| 9 | Invertebrate φ = 0.06–0.8 | 0.056–1.25 (explore_occupancy_phi.csv; 1.19 in explore_phi_inverts.csv) | ✗ |
| 10 | "43–44 years in every group" at λ₀ ≥ 5 | tdetect_grid.csv: krill 51 years to undetectable, mesopelagic fish 44–58 | ✗ |
| 11 | Mammal excess 3.8 (1.7–5.9); land mammals 4.9 (3.2–6.7) | Table S7: 3.82 [1.73, 5.93]; 4.87 [3.20, 6.67] | ✓ |
| 12 | H4 supported in 24 of 27 sensitivity analyses | Table S2: 24 supported; 3 inconclusive (S4, drop jellyfish, drop krill); S11b NA | ✓ (but see comment 11) |
| 13 | PREREG v1.0 body unchanged after 01a2fe7 | `git show 01a2fe7:PREREG.md` against the current file: only appended change-log entries | ✓ |

---

## Recommendation

**Major revision.** The data compilation, transparency and reproducibility are strengths, and the detection-power message has practical value. As written, however:

- the central scaling claim cannot be separated from a ratio artefact (comment 1);
- the H1 label and R² depend on a model that double-counts overlapping data (comment 2);
- the "floor" is an analytic function of a φ that conflates noise with signal and ignores autocorrelation (comments 5–6);
- the preregistered H3 result is confounded by a known but undisclosed error (comment 8);
- the title asserts what the preregistered test did not support (comment 9).

I would be glad to see a revised version that reports the unconstrained offset model, a residual-correlated or contrast-based EIV model with calibration and predictive checks, an analytic and noise-decomposed treatment of detection time, a corrected H3 mapping, and framing aligned with the preregistered outcomes.
