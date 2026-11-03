# Review — Reviewer 6

**Manuscript:** "Body size governs how often animals are recorded and how long their declines stay hidden" (H. Doi), PNAS submission, repository commit 40d8e93
**Reviewer expertise:** conservation science, global biodiversity indicators (Living Planet Index, Red List), science–policy interface, research integrity and preregistration norms. I am also reading as a broad-interest reader, close to the editor's view.
**Material examined:** `manuscript/main.md`, `manuscript/si.md`, `PREREG.md` (including the change log and its git history), `docs/literature_positioning.md`, `reports/summary.md`, `docs/provenance_parts/lpd.md`, `R/phase6_lpi.R`, `sim/lpd2016_mass_bias_*.csv`, and the CSV outputs behind Tables S2–S10 and Figs 1–3 (`models/tierB_*.csv`, `sim/*.csv`). I ran light, read-only checks (R scripts kept outside the repository; details are given where I use them). I modified no project files.

---

## Summary

The author divides GBIF record counts (2000–2024; 3.75 × 10⁹ records) by independent global census abundances for ten animal groups, from soil nematodes to myctophid fishes. This gives "records per individual" (r), which scales with group body mass as M^0.72 (95% CrI 0.49–0.94; R² = 0.90). The exponent cannot be distinguished from the 2/3 expected if detectability tracked projected area (preregistered H1/H2). DNA-derived records scale less steeply than human observations (P = 0.935; H4).

Mammal species with survey-based censuses lie about 3.8 orders of magnitude above the extrapolated line (exploratory). Year-to-year GBIF counts are strongly overdispersed (φ ≈ 0.69 in mammals). With that overdispersion, simulations put a floor of about 44 years on detecting a 30%-per-decade decline with an effort-offset negative-binomial model, and species recorded less than about 0.3 times a year are undetectable within a century (preregistered grid).

The preregistered test of a size-structured detection delay (H3) was formally met but substantively empty, because detection failed at every size. An exploratory analysis using observed record rates then shows that the share of "undetectable" described species falls from 92–97% in soil and planktonic invertebrates to under 1% in birds. Further exploratory analyses address never-recorded species and the body-size skew of the 2016 public Living Planet Database (LPD).

## Overall assessment

The question is important and suits PNAS: how unevenly does the biodiversity data infrastructure sample life, and what does that mean for our ability to detect decline? Several things are commendable:
- The provenance work is careful, and census estimates are classified by method so that circular occurrence- or allometry-derived abundances stay out of the main analysis.
- There are many preregistered sensitivity analyses.
- The PREREG change log really is append-only. I checked `git diff 01a2fe7 HEAD -- PREREG.md`: 27 insertions and 0 deletions.
- The main text reports H3 frankly as "not substantively supported".

My main concerns are interpretation, framing and verifiability rather than the competence of the computations:

1. **The headline claims outrun the preregistered evidence.** The title asserts precisely the hypothesis (H3) that the preregistered test failed to support. The abstract and Significance Statement mix preregistered and exploratory results, mostly without labels, and repeat point estimates without their very wide uncertainty.
2. **The core scaling relationship may mostly be a shared-denominator artefact.** Across the ten groups, record counts vary only about 40-fold, while abundance varies about 550,000-fold (Table S1). When records are regressed freely on abundance and mass, they are statistically unrelated to both. A null model in which record counts are randomly reassigned among groups reproduces the reported exponent and R² (Major comment 2). As currently argued, the "projected area" mechanism is not identified.
3. **The policy-facing parts are the weakest.** The Living Planet analysis uses a decade-old example file. It was obtained without accepting the data-use terms that the SI says govern it, and it reports as a finding that a vertebrate index contains only vertebrates. The causal link drawn in the abstract ("a bias inherited by global indicators") is a category error, because the LPI is not built from occurrence records. The paper's own multi-species simulation, which is the result most relevant to indicators, shows pooled declines detectable in 10–15 years. It is buried in one sentence.
4. **The preregistration cannot be verified by a third party.** It sits in a private git repository with no remote, every commit (Phase 0 to manuscript) carries the same date, and the SI misdescribes when one key amendment was made.

I think a substantially reframed paper could be valuable. In its current form, however, the main claims are not adequately supported for a broad PNAS readership.

---

## Major comments

### 1. Title, abstract and Significance Statement overclaim relative to the preregistered results, and do not separate preregistered from exploratory findings

- **The title is the failed hypothesis.** "...how long their declines stay hidden" is H3, the hypothesis the study set out to make its main result. The preregistered test of H3 (Results, para. 4; PREREG addendum of 2026-11-03; `sim/h3_summary.csv`) found no size gradient: with method (a) and σ = 1.5, the share undetectable within 100 years was 0.91, 0.76 and 0.90 in the lower, middle and upper size thirds, which is not monotonic. The paper's own preregistered result is also that the detection floor (43–44 yr) is the same in every group, i.e. *how long* is not governed by size. What varies with size in the exploratory analysis is *whether* a species clears a record-rate threshold. "Governs" is causal language that a ten-point cross-group correlation cannot carry (see also Comment 2).
- **Only one exploratory result is labelled.** The abstract labels the observed-rate shares as exploratory, but not three others:
  - the survey-based mammal excess (Table S7, exploratory);
  - the statement that overdispersion persists "even for species recorded more than 1,000 times per year" (Table S4b, exploratory, 32 species);
  - the Living Planet sentence (exploratory).
- **The Significance Statement mentions no preregistration and labels nothing.** Its two headline numbers are both exploratory: "about 10,000 times" (Table S7) and "most small invertebrate species would show no detectable decline even over a century" (Table S10a).
- **"About 10,000 times" hides four orders of magnitude of uncertainty.** The survey-based estimate is a median of 10^3.8, about 6,600-fold, with a 95% interval of 10^1.7 to 10^5.9, roughly 50-fold to 850,000-fold. "Four to five orders" in the abstract is also generous, since the central independent estimate is 3.8.
- **The pooling result is left out.** A pooled indicator of 100 species shortens detection to 10–15 years (`sim/explore_multispecies.csv`), and even 100 species each recorded only 0.3 times a year give 15 years. This qualifies "declines stay hidden" for exactly the indicator use the abstract invokes.
- **The abstract is 262 words,** above PNAS's 250-word limit.

**Requested changes.**
- **Title:** retitle so that it reflects the supported findings. For example: "Occurrence records per individual rise steeply with body size and impose a multi-decade floor on detecting declines". Remove "governs" and "how long their declines stay hidden".
- **Abstract:** state that the preregistered size-structured detection hypothesis was not supported. Mark every exploratory result explicitly, for example with "(exploratory)" or a consistent phrase. Report intervals for the vertebrate excess. Add the multi-species pooling result.
- **Significance Statement:** rewrite it so that it (i) distinguishes preregistered from exploratory findings, (ii) replaces "about 10,000 times" with a range, and (iii) does not imply that indicators are insensitive to declines of small taxa when the pooling simulation shows otherwise.
- **Claim–evidence table:** add a short table to the SI listing each headline claim with its status (preregistered / preregistered sensitivity / exploratory) and its source table. `reports/summary.md` already contains this; translate it and include it.

### 2. The records-per-individual scaling is largely determined by the shared denominator N; the "projected area" interpretation is not identified

Both axes of Fig. 1A share the census abundance: r = R/N and M = B/N. Across the ten groups (Table S1) the three quantities vary very differently:
- record counts span about 1.6 orders of magnitude (6.4 × 10⁴ to 2.5 × 10⁶);
- biomass spans about 1.8 orders;
- abundance spans about 5.8 orders.

This is the textbook setting for spurious correlation between ratios with a shared, highly variable term (Pearson 1897; Brett 2004, *Oikos* 105:647–656, who shows that the spurious correlation is largest when the shared term is the most variable). Using the Table S1 point estimates (OLS, ignoring census uncertainty, which reproduces the main estimate: β = 0.73, R² = 0.80), I found:

| Check | Result |
|---|---|
| ln R regressed on ln N and ln M with free coefficients | coefficient on ln N = 0.03 (SE 0.37); on ln M = −0.12 (SE 0.34). Record counts are unrelated to abundance and to mass across these groups. The model's offset assumes the coefficient on ln N is exactly 1. |
| ln R on ln N alone; ln R on ln B alone | slopes 0.16 (SE 0.10) and −0.18 (SE 0.36) |
| R set equal in every group (geometric mean) | β = 0.89, R² = 0.92 |
| R permuted randomly among groups (10,000 permutations) | median β = 0.89 (95% range 0.70–1.08); median R² = 0.84 (0.73–0.95). 69% of permutations give β inside the reported CrI 0.49–0.94. |
| Records per unit biomass (R/B) on M | slope = β − 1 = −0.27: per gram of animal, *small* organisms receive *more* records |

The reported β = 0.72 and R² = 0.90 are therefore what one would expect if GBIF record counts were completely unrelated to the organisms' size or abundance. In that case the "scaling" would merely restate that a roughly fixed number of records (10⁵–10⁶ per group) is divided by abundances that differ by six orders of magnitude.

- **H2 is not diagnostic.** The preregistered H2 only compares β with 2/3 ± 0.2, so it cannot separate "optical detectability" from, for example, "a roughly fixed recording effort per taxonomic group". Under fixed effort, β ≈ 1 − slope(ln B ~ ln M) ≈ 0.89, which also lies inside the CrI.
- **The optical mechanism is implausible for most of the ten groups.** Nematodes, mites, copepods, enchytraeids and springtails are essentially never "seen" by an observer. Their records come from extracted samples (soil cores, net hauls) processed under a microscope or by sequencing. Projected area of the organism plays no obvious role in that pipeline.
- **A preregistered result that cuts against the optical reading goes unmentioned.** Adding prokaryotes (S12) gives β = 1.01 [0.90–1.12] and flips H2 to "human interest dominant" (Table S2). Fig. 1A shows bacteria and archaea about three orders of magnitude below the extrapolated line, but the main text never mentions this.

The descriptive fact remains striking and worth reporting: per individual, a nematode is recorded about 10⁵ times less often than a myctophid. The *mechanistic* reading does not follow.

**Requested changes.**
- (a) Report the free-coefficient model (ln R on ln N and ln M) and a permutation or "constant-R" null for β and R², and state openly that the preregistered H2 test cannot separate projected-area scaling from effort that is independent of abundance.
- (b) Reframe the result descriptively ("records per individual differ by about 10⁶ across groups because record totals are nearly invariant while abundance is not"). Present projected area as one hypothesis among several consistent with β, alongside fixed taxon-level effort, sampling-unit effects and identification bottlenecks, unless a test can discriminate between them. One option is to use within-group species-level data where N_s is known independently.
- (c) Report records per unit biomass alongside records per individual. The policy message differs depending on the denominator.
- (d) Report S12 and the position of the prokaryotes in the main text.
- (e) Revise the Discussion claim that "much of the taxonomic bias in occurrence data, often attributed to societal preference [Troudet 2017], is the expected outcome of an observation process limited by what can be seen". By the paper's own estimate, the largest component of GBIF's taxonomic skew is the vertebrate premium, which the author attributes to interest, so the paper largely *supports* Troudet for the bulk of GBIF records.

### 3. The vertebrate "premium" rests on an extrapolation, a selected sample and a unit-of-analysis mismatch

- **Extrapolation.** The line is fitted over 3 × 10⁻⁷ to 3 g and extrapolated over 4–8 orders of magnitude (Fig. 1A shows a confidence band spanning about 22 orders). Given Comment 2, the extrapolated line embodies the near-constancy of group record totals, not a detectability law.
- **Selection on being surveyed.** The 52 "survey-based" species (45 marine mammals, rhinoceroses, the savanna elephant, two seals) are by construction the species with dedicated survey programmes, photo-ID catalogues and CITES reporting. The authors note that humpback whales have about 7 records per individual. Selecting species *because* they are intensively surveyed selects for high record counts. The same is likely true of the 389 "reported" land mammals.
- **Unit mismatch.** The vertebrate points are single species (N ~ 10³–10⁷). The fitted points are mostly phylum-, class- or order-level aggregates (N ~ 10¹⁵–10²⁰). Antarctic krill, the only single-species invertebrate point, lies on the line (residual +0.17), which is a useful but single control.
- **Internal inconsistency on the "group" interpretation.** The main text says the excess "attaches to vertebrates as a group more than to large species", citing β = 0.32 within 388 reported mammals. Yet Table S7 reports a within-set slope of 0.62 for the 52 census-independent species, close to 2/3.
- **Abstract wording.** "An excess that body size cannot explain" is true only conditional on a linear extrapolation that the data cannot test.

**Requested changes.**
- Add a like-for-like species-level comparison that includes *invertebrate* (and non-mammal vertebrate) species with independent, survey- or assessment-based abundances. Examples:
  - commercially assessed invertebrate and fish stocks in a stock-assessment compilation such as the RAM Legacy database (abundance from survey/catch models, the same standard the author accepts for marine mammals);
  - charismatic invertebrates with survey censuses (e.g. overwintering monarch counts);
  - additional krill-like single-species estimates.

  If charismatic invertebrates also sit far above the line, the premium is about attention, not "vertebrates as a group". If assessed but uncharismatic fish and invertebrate stocks sit on the line, that would support a selection or attention interpretation.
- State the selection-on-surveying caveat explicitly.
- Reconcile the 0.62 and 0.32 slopes.
- Give the excess as a range throughout.

### 4. The detection "floor" needs to be scoped, benchmarked and stated in policy-relevant terms

- **What the floor reflects.** The 43–44-year floor is a direct consequence of NB2 with a fixed φ: the CV tends to 1/√φ ≈ 1.2 however large the mean. φ was estimated from a species + year fixed-effects model of 25 years of GBIF counts *without species-specific temporal terms*. Any real species-specific trend in population or recording (new datasets, platform uptake differing among taxa, single-dataset pulses) is therefore absorbed as "overdispersion" and then re-imposed as white noise in the simulation. Part of φ is also genuine population fluctuation, which would limit structured monitoring too.
- **What it applies to.** The floor applies to *annual totals of aggregated GBIF records with a group-level effort offset*. The abstract generalises it to detecting declines "from records". The occupancy comparison (26 years for mammals) and the UK occupancy literature (Outhwaite et al. 2020) show the limit depends on the index.
- **Error rates are averaged over λ values with no power.** Table S5 averages over all 36 λ₀ values, including those at which no test has power, and this dilutes them. From `sim/control_false_trends.csv`, for λ₀ ≥ 1 record/yr:
  - the effort-offset model (a) gives false declines in 11–12% of 10-year series (nominal 5%; maximum 16%);
  - relative reporting rate (b) gives 26–50% false declines (maximum 58%);
  - raw counts (c) give false increases of 39–41% at 25 years, reaching 98–100% in some groups.

  The main-text statement that (a) "held its nominal error rate (5–9%)" is too favourable for exactly the 10-year windows used in IUCN criterion A. "Up to a third" understates (b) and (c) for well-recorded species.
- **"Most favourable method" needs a definition.** Method (a) is called "the most favourable of the three methods". Yet method (b) reaches power 0.8 in 22–27 years for most groups (`sim/tdetect_grid.csv`), because its Type I error is inflated. Say that (a) is the only method with near-nominal error, not the most powerful.
- **Policy translation.** At 30% per decade, a decline detected after 44 years means the population has already fallen by about 79%, which exceeds the A2 threshold for Critically Endangered. This is a more compelling way to communicate the floor than "four decades".
- **Precedent.** The argument that absence of a detected decline must not be read as stability was made explicitly for rare species by Taylor & Gerrodette (1993, *Conserv. Biol.* 7:489–500). Taylor et al. (2007, *Mar. Mamm. Sci.* 23:157–175) showed that precipitous marine-mammal declines went undetected under realistic survey effort. Neither is cited.

**Requested changes.**
- (a) Re-estimate φ with species-specific linear or spline trends and with dataset effects, or from detrended residuals, and report how the floor changes.
- (b) Benchmark: for species that appear in both GBIF and the LPD (or in national structured schemes), compare interannual variability of GBIF counts with that of the structured abundance series. This would quantify the *excess* noise of opportunistic recording, and it would integrate the Living Planet analysis with the core of the paper.
- (c) Report Type I error and T_detect stratified by λ₀.
- (d) Estimate the between-species correlation of residuals from the species × year data, and report pooled-indicator detection times under that correlation rather than assuming independence.
- (e) Express the floor as "population lost before detection".
- (f) Scope every statement to aggregated annual GBIF counts, and cite Taylor & Gerrodette 1993 and Taylor et al. 2007, as well as Isaac et al. 2014 and Kamp et al. 2016 (already cited).

### 5. The Living Planet analysis is outdated, of uncertain legal standing, partly trivial, and not linked to the paper's mechanism

- **Outdated data.** The analysis uses `LPI_LPR2016data_public.csv`, an example file bundled with the rlpi package: 11,067 populations of 3,456 species. The 2024 Living Planet Report rests on 34,836 populations of 5,495 species (LPR 2024 Technical Supplement). The authors' own provenance notes record about 35,803 populations of 5,790 species for LPD 2026.1. The provenance file says explicitly of the 2016 file, "It is NOT the current release. Use it only for planning", and `R/phase6_lpi.R` still labels its output "PROVISIONAL". The release was nonetheless "accepted as final" (commit fda187b) because the current release sits behind a web form. That is a convenience decision, not a data constraint, and the analysis takes minutes to rerun.
- **Terms of use.** The SI states that "the data are used under the Living Planet Index data-use terms". The provenance file records that the author did *not* complete the data-use agreement, that the rlpi repository has no licence for the bundled data, and that treating it as covered by the LPI policy "is my assumption and is 未確認 [unconfirmed]". The LPI Data Use Policy (copy in `data/raw/lpd/`) states: "Potential users must agree to these terms of use prior to accessing the Data". It also requires (term 9) that a copy of all products be sent to the LPI team, and invites contact about co-authorship for substantial use. The SI statement is therefore not substantiated, and the terms' obligations are unaddressed.
- **A trivial result is presented as a finding.** "All 11,067 populations ... belong to vertebrates" is true by design: the LPI is a vertebrate index and does not aim to represent invertebrates. The informative result is the *within-class* size skew (105-fold for mammal species, 720-fold population-weighted; 3- and 12-fold for birds).
- **Prior work on this question.** The skew has been partly anticipated:
  - nationally by Currie et al. (2022, *FACETS*), for C-LPI fishes;
  - for class and regional representation by earlier LPI assessments (e.g. Collen et al. 2009, *Conserv. Biol.* 23:317–327, which reported the dominance of bird data and gaps for tropical species).

  The diversity-weighted LPI (McRae et al. 2017) corrects representation across classes and realms by species richness, but not within-class size. Citing McRae et al. 2017 for "Global indicators ... are built from populations of large vertebrates" looks like a mis-citation: by the authors' own literature notes, that paper does not address body size.
- **Representation skew is not the same as index bias.** Over-representation of large species biases the index only if trends covary with size. Barnes et al. (2016, *Nat. Commun.*, listed in the authors' literature notes) found more positive trends for larger-bodied birds and mammals in protected areas. The original project plan (CLAUDE.md, Phase 6) included reweighting the index by body-size representation, but this was not done.
- **The causal link is a category error.** "A bias inherited by global indicators" and "the organisms that indicators omit" imply that the observation process estimated from GBIF records is what makes the LPI size-skewed. The LPI is built from structured population time series, not occurrence records. The two skews may share a cause (human attention), but the paper does not show this.

**Requested changes.**
- (a) Obtain the current LPD release through the portal, accepting the terms. Cite it as the policy prescribes, comply with terms 2, 6 and 9, and correct the SI statement.
- (b) Drop "all populations belong to vertebrates" as a finding.
- (c) Make the analysis decision-relevant: estimate the population-trend ~ body-mass relationship within classes, and compute a size-stratified (post-stratified) LPI in which each mass bin within a class is weighted by its share of species. This is feasible with rlpi and directly answers whether the skew matters for the index.
- (d) Fix the McRae citation and position the analysis against Collen et al. 2009, Currie et al. 2022, Barnes et al. 2016, Buschke et al. 2021 and Toszogyova et al. 2024.
- (e) Remove the "inherited" language unless a shared mechanism is demonstrated.

If (c) is not done, the LPD result should move to the SI.

### 6. The preregistration is not externally verifiable, and the SI misstates the timing of one amendment

- **Where the plan lives.** The plan is "preregistered in a version-controlled repository" (Methods). The repository is private and has no remote configured (`git remote -v` is empty).
- **Timeline.** Every commit is dated 2026-11-03, from Phase 0 (00:26) through PREREG v1.0 (07:28), the main Phase 4 results (09:28) and Manuscript v1 (19:26). Git author dates are set by the local machine and can be rewritten, so no third party can verify the order of events. I credit the author for an append-only log, which I verified. Nevertheless, by the standards a PNAS reader associates with "preregistered", this is an internally time-stamped analysis plan, not a registration.
- **Prior knowledge of the data.** PREREG §0 discloses that record totals R and census N, B and M for all groups had been compiled and viewed before the plan was fixed. Since r = R/N, and Comment 2 shows that the result is largely determined by those already-viewed quantities, the protection offered by "before any records-per-individual value was computed" (Methods; SI) is thin. This should be disclosed in the paper, as templates for preregistering secondary-data analyses recommend (Van den Akker et al. 2021, *Meta-Psychology* 5).
- **SI misstatement.** The SI states: "All changes were appended to PREREG.md with dates and reasons before the corresponding results were interpreted." This cannot be true of the H3 addendum, which by its own text responds to the observed outcome that detection failed in every size third. Nor can it be true of the decision to add the exploratory analyses that now carry the title.
- **Language.** The plan is written in Japanese. International readers and reviewers cannot evaluate it without a translation.

**Requested changes.**
- (a) Deposit the complete git history (not just the final files) now in an archive with independent time-stamping and a DOI (e.g. Zenodo or Software Heritage), and give reviewers access.
- (b) In the abstract and Methods, describe the plan accurately, e.g. "a pre-specified analysis plan, time-stamped in private version control before the main analysis; not registered in a public registry". Reserve "preregistered" for what the evidence supports, or let the editor decide on wording.
- (c) Disclose what data had been seen before the plan was fixed.
- (d) Correct the SI sentence. State that the H3 addendum and the exploratory analyses were added *after* the H3 result was seen.
- (e) Provide an English translation of PREREG.md, keeping the Japanese original authoritative.
- (f) Consider an OSF registration or a Registered Report format for the planned follow-ups (the current LPD release, and the analyses requested here).

### 7. Novelty and positioning should be stated more precisely for a broad readership

| Aspect | Status |
|---|---|
| Records-per-individual across phyla | New. I also found no prior paper doing this. Its interpretation depends on Comment 2. |
| Detection floor and false trends | Largely confirmatory: Isaac et al. 2014 (simple methods biased / low power); Kamp et al. 2016 (unstructured data miss declines even in common birds); Taylor & Gerrodette 1993 and Taylor et al. 2007 (power and undetected declines); White 2019 (time to detect trends). Table S5 is a confirmation of Isaac et al. 2014 and should say so in the Results. |
| Within-mammal body-size effect | Meyer et al. (2016, *Glob. Ecol. Biogeogr.* 25:1181–1193) found body size and diurnality to be weak predictors of record counts across 3,625 mammals, compared with range geometry and socio-economics. This matches the within-mammal β = 0.32 and should be cited. |
| Never-recorded species | Closest prior work is Callaghan et al. 2023 (*Nat. Ecol. Evol.*), which links GBIF sampling depth to the fraction of each class's abundance distribution observed. It is mentioned only in passing; the distinction (an independent census-based prediction) should be explicit. |
| Non-probability samples | Boyd, Powney & Pescott (2023, *TREE* 38:521–531) give the conceptual frame ("a sample that looks large may contain little real information"). It should be cited. |

**Requested changes.**
- Add a short paragraph stating which findings are new and which are confirmatory.
- Remove or soften "which I quantified across groups for the first time".
- Cite the works above.

### 8. Several main-text statements are not supported by the SI tables or output files

These affect claims a reader will repeat:

- **Never-recorded species (Results, final subsection).** The text says that "these predictions ranked groups in the same order as published estimates of the undescribed share, but fell below them". Table S8 (25-yr window) contradicts both parts:
  - Predicted order: nematodes 0.91 > mites 0.88 > *ants 0.79* > springtails 0.75 > copepods 0.62 > jellyfish 0.43.
  - Literature order: nematodes 0.96 > mites 0.87 > springtails 0.82 > copepods 0.69 > *ants 0.58* > jellyfish 0.32. Spearman ρ ≈ 0.83, not identical order.
  - Predictions are *above* the literature values for ants (0.79 vs 0.58), jellyfish (0.43 vs 0.32) and mites (0.88 vs 0.87). Fig. 3A shows this.
  - The main text lists only the four groups that fit the narrative and omits ants and copepods.
- **"Took 43–44 years in every group once species were recorded more than about five times per year".** This does not hold for krill: T_a = ∞ at λ₀ = 10, 60–62 yr at λ₀ = 10³ and 51–52 yr at λ₀ = 10⁵. It also does not hold for mesopelagic fishes at λ₀ = 10 (53–54 yr) (`sim/tdetect_grid.csv`, constant effort).
- **"Invertebrate groups were more overdispersed still (φ = 0.06–0.8)".** In `sim/explore_phi_inverts.csv`, which feeds Fig. 2B, jellyfish at ≥10 records/yr have φ = 1.19. Table S4c reports 1.25 for the same cell. In the like-for-like comparison of Table S4c, mammals (0.24 / 0.33 / 0.68) are not consistently less overdispersed than invertebrates (jellyfish 0.23 / 0.62 / 1.25; pteropods 0.20 / 0.33 / 0.72).
- **Two φ tables that disagree.** Table S4c comes from `explore_occupancy_phi.csv`, while the Fig. 2B shares use `explore_phi_inverts.csv`. These are two different estimation runs with different values and sample sizes (e.g. enchytraeids <1: n = 166, φ = 0.079 vs n = 184, φ = 0.073). Report the φ actually used for Fig. 2B and Table S10a.
- **Mammal shares in Fig. 2B.** "From 54% of the smallest to 5% of the largest mammals" uses a 24-species bin for "smallest". The mammal shares are roughly flat at 39–50% from about 3 g to about 300 g (`explore_empirical_vert_bins.csv`), so "fell steadily with body size" does not describe the mammals.
- **Birds use the mammal φ** (0.69) in Fig. 2B and Table S10b, whereas the invertebrates use their own φ.
- **Krill in Fig. 2B.** Krill (one species) is plotted at 0% next to groups of 10⁴ species.
- **Mammals in Fig. 1A.** The in-figure caption calls all blue points "census independent of occurrence data". The light-blue points are the 389 "reported" land mammals, which Table S7 treats as a separate category (report_land), not as census_independent.

**Requested change.** Correct each statement, report all groups, and use one φ estimate consistently, or justify the use of two.

### 9. The AI-assistance disclosure is too thin for the extent of use, and should move to Methods

The Acknowledgments say: "Analyses and drafting were assisted by Claude (Anthropic) ... the author designed the study, made all analytical decisions". The repository shows more extensive use:
- AI agents drafted the preregistration;
- they retrieved and classified the census data and wrote the provenance records;
- they wrote all code;
- they ran the literature-positioning check, whose rules state that only abstracts were read ("full texts were not read");
- they drafted the text.

The author approved these at gates; the PREREG change log records approval of the full plan as "すべておk 進めて" ("all OK, proceed"). The full pipeline, from scaffold to manuscript, ran within one calendar day. None of this is improper in itself. But "made all analytical decisions" overstates the division of labour, and readers and editors need to know how AI-generated outputs were verified. I could not retrieve the PNAS policy page directly (HTTP 403). Common practice, and in my understanding PNAS policy, is that AI use in conducting the research is disclosed in Materials and Methods, not only in the Acknowledgments. The editor should confirm the current requirement.

**Requested changes.**
- Add a Methods paragraph naming the tool and version and the tasks performed: code, data retrieval and classification, preregistration draft, literature screening, text drafting.
- Describe what the author verified independently (e.g. which census extractions were checked against the sources, whether any analysis was re-run or code-reviewed independently of the AI).
- Rephrase the responsibility statement to something like "approved all analytical decisions at predefined checkpoints and takes full responsibility".
- Confirm that every cited paper has been read in full by the author. Several citations rest on abstract-only screening, e.g. White 2019 (screened via a preprint abstract) and Leung et al. 2020 (abstract not read).

### 10. Data and code availability, and readiness for submission

- **Availability.** "Code, the preregistration and derived data will be deposited in a public repository on acceptance" is not sufficient for review. This is especially true when the preregistration's credibility rests on a git history that only the author can see.
- **Citations.** The GBIF derived-dataset DOI is still "[to register before submission]" (SI), which GBIF's citation requirements need.
- **LPD restrictions.** The LPD terms (4–6) restrict redistribution of raw and derived data. The data statement must explain how readers can reproduce the LPD analysis without the authors redistributing the data.
- **Missing bibliography.** `manuscript/references.bib`, named in the YAML header of both files, does not exist in the repository, so the reference lists of main text and SI are empty.
- **Placeholders.** The affiliation reads "[department to be confirmed]".

**Requested changes.**
- Give reviewers access now (e.g. a private Zenodo or OSF link containing the code, derived data and git history).
- Register the GBIF derived dataset.
- Write a Data Availability statement that covers LPD restrictions and GBIF citation.
- Supply the bibliography.

### 11. Make the policy recommendations specific and actionable

The three closing recommendations are sensible but generic, and each is already a common refrain. For example, Eisenhauer, Bonn & Guerra (2019, *Nat. Commun.* 10:50) on neglect of soil invertebrates in databases and assessments. The paper's quantitative results could support much sharper guidance:

- **(i) A reporting rule.** For example: no species-level trend claim from aggregated GBIF counts below about 1 record/yr, and every such claim accompanied by its minimum detectable decline over the window used. The paper's λ thresholds and T_detect grid make this concrete.
- **(ii) Multi-species indicators.** The pooling result implies that multi-species, occupancy-type indicators of poorly recorded taxa can detect shared declines within one to two decades. That is a positive, actionable message currently missing from the abstract.
- **(iii) Data infrastructure.** Recommend that structured effort and non-detection information be published with records. For example, GBIF now provides guidance for survey and monitoring data using the TDWG Humboldt Extension for Ecological Inventories. This is the cheapest way to move records from the "count" regime analysed here to the occupancy regime.
- **(iv) Policy hooks.** Link the indicator recommendation to the Kunming–Montreal Global Biodiversity Framework monitoring framework: Goal A on the abundance of wild species, where the LPI is used as an optional indicator. Say what "state the share of species, individuals and biomass represented" would mean in practice for that framework.
- **(v) Straw man.** Replace "Claims that biodiversity is stable, based on records ..." (Significance) with a cited example of such a claim, or rephrase it as a caution.

---

## Minor comments

1. **Fig. 1A.**
   - Labels overlap (mites / copepods / springtails / enchytraeids; ants / jellyfish / krill; archaea / bacteria).
   - The dotted line is not explained in the legend.
   - Panel letters are lowercase in the figures but "(A)/(B)" in the legends.
   - Each figure carries its own long caption that duplicates, and sometimes contradicts, the legend in main.md.
   - The confidence band is drawn over about 22 orders of magnitude of extrapolation; consider truncating it or greying the extrapolated part.
2. **Fig. 1B.** Show the posterior of the *difference* b_DNA − b_human (the quantity tested in H4), not only overlapping violins.
3. **Fig. 2A.** Only the constant-effort, φ = 0.69 case is shown. Add the λ threshold, the uncertainty from φ (2.5% and 97.5%; already run), and a note that methods (b) and (c) are in Fig. S2.
4. **Fig. 2B.** "Soil nematodes" is clipped ("il nematodes"), and the mites and copepods labels overlap. Remove krill or mark it as n = 1. Use a separate panel or symbol scale for the within-class bins, which are a different unit from the group-level triangles.
5. **Fig. 3A.** Add a 1:1 panel (predicted vs literature undescribed share) so readers can see where the predictions fall above or below.
6. **Fig. 3B.** Give the number of species per bin, and update it to the current LPD (Major 5).
7. **Mammal sample sizes.** Reconcile 392 (PREREG §4), 389 (Table S7 "report_land"), 388 (Table S3) and 382 (Table S4a) in one footnote.
8. **β range.** "Median β 0.60–0.84" should read 0.59–0.84 (S10 without soil nematodes: 0.595). State which 24 of the 28 sensitivity rows are included; S2/S9, S9 and S12 are excluded without comment.
9. **H4 count.** "Supported in 24 of 27 sensitivity analyses" counts the main analysis among the 27. It is 23 of 26 sensitivity analyses plus the main analysis (`reports/summary.md` says 23 of 27).
10. **φ for the >1,000 records/yr stratum.** The main text gives 0.88; Table S4b gives 0.87 (`explore_phi_by_mean.csv`: 0.8745).
11. **"Seven orders of magnitude".** The span 4.8 × 10⁻⁷ to 3.1 g is 6.8 orders; "nearly seven" is more accurate.
12. **IUCN criterion A.** The 30% Vulnerable threshold applies to A2–A4, over 10 years or three generations, whichever is longer. A1 requires 50%. Specify this.
13. **"Regardless of how often a species was recorded" (abstract).** This contradicts the next clause (species recorded less than once every three years are undetectable). Use "however often, above about five records per year".
14. **Discrepancy between the preregistered and exploratory mappings.** The preregistered mapping (`sim/h3_summary.csv`; upper size third about 90% undetectable within 100 yr) and the exploratory observed-rate analysis (mesopelagic fishes 42%) disagree sharply for the same groups. Explain this, presumably as the effect of the assumed log-normal SAD with σ_log10 = 1.5, so readers know which assumption drives which conclusion.
15. **λ thresholds in Table S10a.** The thresholds (0.32, 0.50, 0.79) are points on a discrete grid (0.2 log₁₀ spacing). Note this, since the undetectable shares are sensitive to it.
16. **Fit failures.** NB-GLM fit failures counted as non-detections reach 7–11% near the threshold (λ₀ ≈ 0.1–0.25; `tdetect_grid.csv`). Report this in the SI.
17. **"Simple analyses that are widely used" (abstract).** Give evidence of use, e.g. which published trend assessments use binomial reporting-rate GLMs without overdispersion.
18. **Humpback records.** Photo-ID re-sightings of known individuals make "records per individual" a different quantity for these species; say so where the humpback example is given.
19. **Keywords and classification.** Consider adding "Living Planet Index" and "biodiversity indicators" to the keywords, and a dual classification (Environmental Sciences or Sustainability Science) for the policy readership.
20. **Projected area.** The 2/3 expectation assumes isometry. Nematodes and enchytraeids are strongly elongate; state the shape assumption.
21. **"Department to be confirmed".** Complete the affiliation.

---

## Numbers and consistency checked

| Item | Source(s) checked | Status |
|---|---|---|
| β = 0.72 [0.49, 0.94], R² = 0.90, P(β − 2/3 > 0.2) = 0.09, P(< −0.2) = 0.02 | `models/tierB_summary.csv` (0.719 [0.492, 0.944], R² 0.902, 0.089, 0.016) | Consistent |
| β with birds and mammals added = 1.27 [1.07, 1.48] | Table S2 (S9) | Consistent |
| Robustness "median β 0.60–0.84" over 24 sensitivity analyses | Table S2 / tierB_summary (min 0.595, S10 without nematodes) | Minor inconsistency (0.59); S12 = 1.01 not mentioned |
| DNA vs human: 0.51 vs 0.75, P = 0.935; "24 of 27" | `tierB_h4.csv`, Table S2 | Values consistent; count is 23 of 26 sensitivity analyses + main |
| Group masses 4.8 × 10⁻⁷–3.1 g; R 6.4 × 10⁴–2.5 × 10⁶ | Table S1 | Consistent ("seven orders" = 6.8) |
| Survey-based mammals +3.8 [1.7, 5.9] orders; +4.3 vs optical; land mammals +4.9 [3.2, 6.7] | Table S7 | Consistent; abstract's "four to five" and Significance's "about 10,000×" round up and omit the interval |
| Within-mammal β = 0.32 [0.18, 0.47], 388 species | Table S3 | Consistent; conflicts in interpretation with Table S7 within-set slope 0.62 |
| Humpback about 7 records per individual | `explore_vertebrates_species.csv` (R 402,971 / N 57,969 = 6.95) | Consistent |
| φ = 0.69 [0.66, 0.71]; 0.46 (<1/yr); 0.88 (>1,000/yr) | Table S4a/b; `explore_phi_by_mean.csv` | 0.88 vs 0.87 (0.8745) |
| Invertebrate φ = 0.06–0.8 | `explore_phi_inverts.csv` (0.057–1.19); Table S4c (0.06–1.25) | Inconsistent; two different φ runs |
| Floor 43–44 yr "in every group" above about 5 records/yr; 50% decline about 28 yr; threshold about 0.3/yr | `tdetect_grid.csv`, `explore_const_grid.csv` | Holds for 9 groups; not for krill (∞ / 51–62 yr) or for mesopelagic fishes at λ₀ = 10 (53 yr); 28 yr and 0.32 consistent |
| (a) "held its nominal error rate (5–9%)"; (b)/(c) "up to a third" | Table S5; `control_false_trends.csv` | Averages hide 11–12% for (a) at 10 yr when λ₀ ≥ 1; (b) up to about 50–58%; (c) false increases up to 98–100% |
| Undetectable shares: nematodes, mites, copepods 95–97%, springtails 92%, ants 76%, jellyfish / mesopelagic 42–49%, birds < 1% | Table S10a/b; `explore_empirical_groupphi.csv` | Consistent (copepods 94.7%) |
| Mammals 54% → 5% | `explore_empirical_vert_bins.csv` | Endpoints consistent; smallest bin n = 24; not monotonic ("steadily" inaccurate) |
| Occupancy: φ reduced 2.5–40×; mammals ≥10/yr 44 → 26 yr | Table S4c, S6 | Consistent (about 2.5–41×) |
| Pooling 100 species: 10–15 yr | `explore_multispecies.csv` | Consistent (15 yr even at λ₀ = 0.3) |
| Never-recorded 91 / 88 / 75 / 43%; "same order"; "fell below" | Table S8 | Values consistent; ranking and "below" claims **not** supported |
| LPD: 11,067 populations; mammals 105× (720× population-weighted); birds 3× and 12× | `lpd2016_mass_bias_summary.csv` (104.8; 50,000 / 69.6 = 718; 3.04; 416 / 35.5 = 11.7) | Consistent |
| PREREG append-only after v1.0 | `git diff 01a2fe7 HEAD -- PREREG.md` (+27 / −0) | Verified |
| "Changes appended ... before the corresponding results were interpreted" (SI) | PREREG change log (H3 addendum responds to observed results) | Inaccurate for the H3 addendum and the exploratory additions |
| Abstract ≤ 250 words; Significance ≤ 120 words | word count | Abstract 262 (over); Significance 117 (OK) |
| Bibliography | `manuscript/references.bib` | Missing |
| Ratio/shared-denominator check (my own) | Table S1 point estimates; OLS; 10,000 permutations (seed 1) | Free ln N coefficient 0.03 ± 0.37; permutation null β median 0.89 (0.70–1.08), R² 0.84 (0.73–0.95) |

---

## Recommendation

**Major revision.** Without it, the paper is not suitable for PNAS in its current form.

The question is of broad interest, and the data assembly and provenance work are of high quality. However:
- the title and summary statements assert a hypothesis (H3) that the preregistered test did not support, and they mix exploratory and preregistered results without labels;
- the central scaling relationship has not been shown to differ from what a shared-denominator null produces;
- the Living Planet analysis rests on an outdated example file used without the stated terms, and makes an unsupported causal link;
- the preregistration claims are not externally verifiable, and the SI misdescribes the timing of one amendment.

**Conditions for acceptance:**
- Comments 1, 2, 5 and 6 are essential.
- Comments 3, 4 and 8 are needed to support the claims as stated.
- Comments 9–11 are needed before publication.

If the shared-denominator null in Comment 2 cannot be rejected, the paper's mechanistic headline does not stand. A reframed, descriptive version centred on the detection floor and the pooling result might then suit a more specialist venue better.

---

### References I located and cite in this report (beyond those already in the manuscript)

- Brett MT (2004) When is a correlation between non-independent variables "spurious"? *Oikos* 105:647–656.
- Meyer C, Jetz W, Guralnick RP, Fritz SA, Kreft H (2016) Range geometry and socio-economics dominate species-level biases in occurrence information. *Global Ecology and Biogeography* 25:1181–1193. doi:10.1111/geb.12483
- Taylor BL, Gerrodette T (1993) The uses of statistical power in conservation biology: the vaquita and northern spotted owl. *Conservation Biology* 7:489–500.
- Taylor BL, Martinez M, Gerrodette T, Barlow J (2007) Lessons from monitoring trends in abundance of marine mammals. *Marine Mammal Science* 23:157–175.
- Boyd RJ, Powney GD, Pescott OL (2023) We need to talk about nonprobability samples. *Trends in Ecology & Evolution* 38:521–531. doi:10.1016/j.tree.2023.01.001
- Van den Akker OR et al. (2021) Preregistration of secondary data analysis: a template and tutorial. *Meta-Psychology* 5.
- Collen B, Loh J, et al. (2009) Monitoring change in vertebrate abundance: the Living Planet Index. *Conservation Biology* 23:317–327.
- Eisenhauer N, Bonn A, Guerra CA (2019) Recognizing the quiet extinction of invertebrates. *Nature Communications* 10:50. doi:10.1038/s41467-018-07916-1
- WWF/ZSL (2024) Living Planet Report 2024, Technical Supplement (34,836 populations of 5,495 species).
- Currie J et al. (2022) *FACETS* 7; Barnes MD et al. (2016) *Nature Communications* 7; Buschke FT et al. (2021) *Nature Ecology & Evolution* 5; Toszogyova A et al. (2024) *Nature Communications* 15. All are already identified, with DOIs, in the authors' `docs/literature_positioning.md`.
