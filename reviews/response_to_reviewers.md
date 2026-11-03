# Response to reviewers

**Manuscript:** "Body size governs how often animals are recorded and how long their declines stay hidden" (first version), revised as "Biodiversity records follow species, not individuals, leaving declines of most small animals undetectable".

I thank the six reviewers for exceptionally careful reports. Several checked numbers against the code and outputs and found errors that I had missed. The central interpretation of the first version did not survive review, and the paper has been rebuilt around what the data do support. All analyses added in revision are labelled exploratory, and every deviation from the preregistration is listed in SI Section 11. Table and figure numbers below refer to the revised manuscript and SI.

## Summary of the main changes

1. **The records-per-individual scaling (β = 0.72, "optical 2/3") is withdrawn as an interpretation.**
   - Four reviewers (1, 3, 5 and 6) showed that it is a ratio artefact: records vary little across groups while abundance and body mass are collinear (r = −0.96).
   - I confirm this. Constant records give β = 0.89, and permuted records give 0.88 [0.69, 1.08] (Table S11).
   - In a free-coefficient errors-in-variables model, records are unrelated to abundance (γ = −0.07 [−0.87, 0.66]) and body mass (0.00 [−0.74, 0.72]) and rise with described species (0.43 [−0.01, 0.86]; P > 0 = 0.97). This holds after scope corrections (0.48 [0.05, 0.89]), with sampling events as the response (0.62 [0.15, 1.08]), without the three largest datasets (0.58 [0.29, 0.89]), and under all census and prior alternatives (Table S12).
   - The new first result is that **records follow species, not individuals** (Fig. 1).
2. **Vertebrate premium recast in species terms, without census extrapolation.** Birds and mammals receive 1,900 and 54 times more records than invertebrate groups of equal described richness (Fig. 1A). Within mammals, records do track abundance (N^0.64).
3. **The detection floor is now derived analytically and decomposed.**
   - The closed form T ≈ [12(z_α+z_β)²/(φd²)]^(1/3) reproduces the simulated 44 years (Table S15).
   - φ is re-estimated per species with an effort offset and species-specific trends, by group, data source and record rate. It rises with record rate, from 0.66 to 3.0 in mammals and 1.5 to 13.8 in eBird birds (Table S16).
   - Detection floors now range from 16 years (eBird birds) to 51 years (nematodes) (Fig. 2A).
   - Autocorrelation raises false declines to 17–21% (Table S17). IUCN-window metrics are added: 96% minimum detectable decline in 10 years, and 79% lost at detection.
4. **Validation against structured monitoring.** For 48 British butterflies (2000–2019), GBIF record trends correlate with UK Butterfly Monitoring Scheme trends at r = 0.42. They detect 8 of 14 monitored declines and flag 9 of 34 non-declining species (Fig. 2C, Table S18).
5. **Detectability of every described species.** This now uses the record-rate-dependent curves (Fig. 3A, Table S19). Never-recorded species are reported separately.
6. **DNA result re-specified.** In a ratio model in which abundance cancels, the size bias is lower for metabarcoding/eDNA (−0.44 [−0.80, −0.08]) but not for iBOL specimen barcodes (−0.11 [−0.32, 0.09]) (Fig. 3B, Table S14).
7. **Removed:** the Living Planet Database analysis and the H5 claim (Table S8 now reports H5 as unsupported). The extrapolation-based vertebrate comparison moved to SI.
8. **Corrections:**
   - the elephant entry was duplicated and the polar bear value was unverified (50 species)
   - several numerical statements did not match the SI (listed below)
   - the GBIF total is 3.89 × 10⁹ records, with DOI 10.15468/dl.jeesns
   - the references file was missing
9. **Transparency:**
   - English translation of the preregistration (`PREREG_en.md`)
   - an honest statement that record totals and census values were inspected before the plan was written
   - disclosure of the H3 mapping error, of the preregistered sensitivity analyses not run in the first version, of the failed Tier A consistency check, and of the history rewrite during review
   - an expanded AI-assistance statement in Methods
   - code, data and reviews in a repository to be made public on submission

---

## Reviewer 1

**1. Exponent set by the census denominator.** Agreed and confirmed (Tables S11–S12). The scaling interpretation is withdrawn; the preregistered numbers are reported as computed (Table S2), with the explanation that they are not identifiable from the records. The free-coefficient model you requested is now the main census-based analysis.

**2. Habitat confounding and non-independence.** Adding a soil-versus-marine term does not change the conclusions (γ = 0.18 [−1.10, 1.18], η_soil = 0.75 [−2.0, 3.6]; Table S12). With ten groups, I cannot model further structure; the census-free analyses (records per species, detectability) do not depend on it.

**3. M = B/N versus recorded mass; scope mismatches; missing S6c/S6d/S15.**
- Body mass no longer carries the main conclusions (δ ≈ 0). Correcting jellyfish mass by ×50 changes nothing (Table S12).
- Scope corrections for nematodes, mites and mesopelagic fishes, including the preregistered S6c and S6d, were run (Table S20). They strengthen the dependence on described species and raise undetectable shares to 97–99%.
- S15 was not run and is listed as a deviation (SI §11).

**4. The 2/3 prediction is not derived.** Agreed; withdrawn.

**5. Vertebrate "excess" relies on extrapolation; telemetry.**
- The main comparison is now records per described species, which requires no census (Fig. 1A).
- The extrapolation is in SI (Table S7), corrected to 50 species.
- Machine observations are analysed separately in Table S16, where excluding them changes φ only modestly.

**6. Within-mammal slope.** Reported and reconciled: within mammals, records scale with abundance (N^0.64, SE 0.05) and weakly with mass (Table S3). Records track individuals within a class but not across groups. The failed preregistered consistency check is disclosed.

**7. EIV measurement structure, R², recovery tests, clustering.** The free model is fitted to all records only, without joint fitting of overlapping record types. Posterior predictive coverage is 10/10, and the model is robust to wider priors. The krill measurement issue is examined with the unadjusted-net abundance (Table S12).

**8. H4 confounded with habitat.** H4 is now presented through the ratio model in which abundance cancels, split by DNA type (Table S14). The soil/marine imbalance of metabarcoding datasets remains a caveat, stated in the Discussion.

**9. Framing.** Title, abstract and significance statement are rewritten. Exploratory results are marked.

**Minor comments and numbers.**
- The sensitivity range is now reported as 0.59–0.84 (Results and Table S2).
- The invertebrate φ range is replaced by Table S16.
- "43–44 years in every group" is replaced by the analytic floor and group-specific values.

## Reviewer 2

**1. Records are not comparable units.** I added a sampling-event response: unique species × dataset × 0.1° cell × date (Table S9). It reduces krill from 95,798 records to 8,447 events (KRILLBASE), and the conclusions are unchanged (Table S12). An audit of individualCount per dataset was not attempted beyond the preregistered S3.

**2. Dataset dominance.** Top-3 dataset shares range from 0.29 to 0.91 (Table S9). Removing the three largest datasets per group leaves the dependence on described species intact (0.58 [0.29, 0.89]).

**3. Basis of record does not identify detection.** Agreed; the optical interpretation is withdrawn.

**4. DNA type is mostly iBOL plus a few metabarcoding datasets.**
- Confirmed: iBOL is one dataset with 0.93 million records, against 147 metabarcoding/eDNA datasets with 1.13 million (Table S10). EUKARYOME (0.02 million) is classed as a reference database and excluded.
- The H4 result holds for metabarcoding/eDNA but not for iBOL barcodes (Table S14), and the text now says so.
- GenBank-derived records without the extension remain unclassified as DNA; this is stated.

**5. Taxonomic scope and missing preregistered variants.** Run as scope corrections (Table S20), using the family and order lists compiled during review (`docs/taxon_scope_variants.csv`). Jellyfish species now include Cubozoa (297).

**6. Effort trajectories reflect publication lag.** Agreed. Group-total trajectories are used only in the preregistered simulations (Fig. S2, Table S5); the revised detection analyses assume constant effort. As you found, the species record rates behind Fig. 3A are robust to the period used.

**7. Vertebrates: telemetry, photo-ID, duplicated elephant.** Corrected: the elephant duplicate and the unverified polar bear are removed (50 species). Machine observations are treated separately (Table S16). Photo-ID is discussed as part of the vertebrate premium.

**8. Duplicates across datasets.** Not addressed with GBIF clusters: the snapshot schema used does not carry cluster membership. The sampling-event response collapses same-day, same-cell duplicates within datasets. As you note, duplication of up to 14% changes ln R by at most about 0.15, which cannot affect the conclusions. This is stated as a limitation.

**9. Data citation and reproducibility.**
- The snapshot DOI (10.15468/dl.jeesns) is cited.
- The main census analysis uses 8.45 million records, and this is stated.
- A derived-dataset DOI will be registered before publication.
- Code, derived data, the dataset-level aggregates and the reviews are in the repository. The large parquet aggregates are reproducible with the scripts provided.

## Reviewer 3

**1. Ratio artefact.** Agreed. Your free-coefficient analysis and constant-records null are reproduced in Tables S11–S12 and are now central.

**2. Joint fitting of overlapping record types.** The revised models fit all records only. The preregistered joint fit is reported as computed, and the problem is acknowledged.

**3. Identifiability, defaults, prior sensitivity, PPCs.** Free-model sensitivity analyses cover:
- priors N(0, 5)
- jellyfish mass, nematode carbon fraction, krill abundance and Rosenberg springtails (S5b)
- posterior predictive coverage (Table S12)

**4. H2 is absence of evidence; Tier A check failed.** Agreed on both. H2 is no longer interpreted, and the failed Tier A check is disclosed (SI §11).

**5. Analytic floor.** Derived and presented (SI §6, Table S15). The simulated floor agrees with it to within 0–2 years.

**6. φ conflates noise with trends, pulses and autocorrelation.**
- φ is now estimated per species with an effort offset and linear or quadratic trends (Table S16). It is larger net of trends, and detection floors are correspondingly shorter (Fig. 2A).
- Lag-1 autocorrelation is reported, and its effect on false declines is simulated (Table S17).

**7. Simulation-design issues.**
- (a) Monotonicity of power in T for method (a) was checked on a dense grid (`sim/rev_monotonicity_summary.csv`). Power is not strictly monotone: it drops by up to 0.16, mostly at short T where the Wald test is anti-conservative. The first T with power ≥ 0.8 on the dense grid (45, 46 and 63 years for 100, 10 and 1 records per year) agrees with the bisection results to within 1–3 years.
- (b) Failed fits are almost all all-zero series.
- (c) The short-series anti-conservatism of method (a) is now reported (2–12%) rather than called nominal.
- (d) False-increase rates are given by record rate (Table S5), and the autocorrelation result is reported by record rate (Results, Table S17).
- Method (b) T_detect values are no longer compared with method (a).

**8. H3 mapping double-counts effort declines.** Disclosed (SI §11). The revised detectability analysis does not use this mapping.

**9. Preregistration transparency.**
- The timing of inspection, the same-day commits, the history rewrite and the H3 addendum are stated (SI §1 and §11). The SI no longer says that amendments preceded interpretation.
- An English translation is provided.

**10. Tier A equivalence holds only under a flat prior.** Stated (SI §4, §11).

**11. Multiplicity.** Vote counts were removed; sensitivity results are given as ranges. H4 is presented through the contrast model, and the S13 interval issue is noted in Table S2 and SI.

## Reviewer 4

**1. Floor is closed-form.** Agreed; derived explicitly (Table S15). The claim that more records do not help now applies only within a fixed φ. With record-rate-dependent φ, detection times shorten for well-recorded species (Fig. 2A).

**2. φ includes real trends.** Re-estimated net of species trends (Table S16).

**3. φ depends on record rate and data source; birds.** Confirmed and incorporated (Fig. 2B), with eBird and non-eBird birds estimated separately. The abstract now gives the range from 16 to 51 years.

**4. Practitioners' models.** Full occupancy-detection, reporting-rate and state-space models were not implemented. The empirical butterfly validation (point 6) and the occupancy-cell analysis partly address the concern. The limitation is now explicit in the Discussion, and occupancy designs are recommended for well-recorded taxa.

**5. Occupied-cell proxy.** It is presented as a coarse analogue only (Fig. S3), not as a test of occupancy models.

**6. Validation against structured monitoring.** Implemented for UK butterflies against UKBMS (Fig. 2C, Table S18). Record trends correlate at r = 0.42. Method (a) detects 8/14 declines with 9/34 false declines, and relative reporting rates give 20/34 false declines and 11 opposite-sign trends. Butterfly φ is much higher than in global records (median 32), as your comment 3 anticipated.

**7. Decision framing.** IUCN-window metrics are added: 96% minimum detectable decline in 10 years and 79% lost at detection (Table S15).

**8. Unrecorded species dominate.**
- Never-recorded shares are reported separately (Table S19, Fig. 3A).
- Shares among recorded species are given (e.g. nematodes 65% of recorded species undetectable within 100 years).
- 25- and 50-year horizons are shown.

**9. Multi-species indicators.** A realistic implementation with heterogeneous trends and correlated noise was not attempted. The pooling result is now described as an optimistic simulation that assumes common trends and independent noise, and multi-species indicators are recommended for groups with records.

**10. False-trend summaries.** Rates are reported by record rate (Table S5). The overdispersion mechanism of the binomial reporting-rate failure is distinguished from Isaac et al. (2014).

## Reviewer 5

**1. Exponent set by N–M relationship.** Agreed (see Reviewers 1 and 3).

**2. Optical mechanism does not apply.** Agreed; withdrawn.

**3. Assumed masses are weak.** Agreed. The revised conclusions do not depend on M (δ ≈ 0), and alternative masses do not change them (Table S12).

**4. Unit conversions.** Gelatinous carbon content (×50) and the nematode carbon-to-fresh ratio of 0.105 were tested (Table S12).

**5. Scope mismatches.** See Reviewer 2.5 and Table S20.

**6. Census uncertainties; krill; springtails; the Irigoien gate decision.**
- The unadjusted-net krill abundance and S5b, Rosenberg springtails from my own re-run (B = 17.69 Mt dry, N = 3.45 × 10¹⁸), were added (Table S12).
- The Phase 1 gate decision to use Irigoien et al. as the primary mesopelagic estimate was not implemented. Bar-On's subgroup biomass was used so that N and B share one scope. This is disclosed. The census-free results are unaffected.

**7. Vertebrate census errors.** Corrected (50 species). The comparison is moved to SI and labelled as extrapolation.

**8. Described-species counts.** Alternative counts (mites 55,000; nematodes 29,000) are used in sensitivity analyses (Table S20). They raise undetectable shares, so the main shares are lower bounds. A full move to group catalogues was not attempted.

**9. H5 circular and misreported.** Agreed. H5 is removed from the main text and reported in Table S8 as unsupported: predicted recorded species exceed observed by 4–11 times in four groups.

## Reviewer 6

**1. Overclaiming title, abstract and significance statement.** Rewritten. The title now reflects the supported results, and exploratory findings are marked in the Results.

**2. Shared denominator.** Agreed (see above). The preregistered S12 prokaryote analysis is reported in Table S2.

**3. Vertebrate premium.** Recast as records per described species (Fig. 1A). The extrapolation is in SI. The within-mammal slope is reconciled (Table S3).

**4. Detection floor scoped and in policy terms.**
- Floors are given by group, data source and record rate.
- Type I error is reported by record rate (Table S5) and under autocorrelation (Table S17).
- IUCN-window metrics and the share lost at detection are added (Table S15).

**5. Living Planet analysis.** Removed, for the reasons you give. The Discussion cites the literature on indicator coverage.

**6. Preregistration verifiability and SI misstatement.**
- The repository with full history will be public at submission and archived with a DOI.
- An English translation is provided.
- The SI now states the timing accurately, including the same-day commits, prior inspection of record totals, the H3 addendum after results, and the history rewrite.

**7. Novelty and positioning.** A paragraph now separates confirmatory results from new ones, citing Isaac et al. 2014, Kamp et al. 2016, Taylor & Gerrodette 1993, White 2019, Boyd et al. 2023 and Meyer et al. 2016. The phrase "for the first time" was removed.

**8. Statements unsupported by the SI.** Corrected: ranking claims in H5 (now removed), krill floor, φ range, the 0.59 lower bound, and "52 species".

**9. AI disclosure.** Expanded and moved to Methods, with the tasks performed and the verification steps.

**10. Readiness.**
- The references file is present (60 entries, verified against Crossref or the original documents).
- The GBIF DOI is cited.
- The repository is described in Data availability.
- The department in the affiliation is still to be confirmed by the author.

**11. Actionable recommendations.** Rewritten:
- a record-rate threshold for species-level trend claims
- reporting minimum detectable declines
- publishing effort and non-detections (Humboldt Extension)
- reporting coverage within the Kunming–Montreal monitoring framework
- metabarcoding for invertebrates

The new references Eisenhauer et al. 2019 and Boyd et al. 2023 were added.

---

## Corrections from a final numerical check

Before resubmission, an independent check of all 192 numerical statements against the output files found 29 discrepancies. All were corrected:
- The jellyfish species count (297, including Cubozoa) is now used in every model.
- The preregistered detection floor is stated by record rate.
- The direction of the overdispersion wording is corrected.
- The autocorrelation range is 0.02–0.50, with false-decline rates given by record rate.
- Enchytraeids are 85%.
- The source of the alternative species counts is Hodda 2022b.
- There are 147 metabarcoding datasets.
- The record total is 3.74 × 10⁹ after removing fossils.
- Exploratory results are labelled in the abstract, Results and figure legends.
- Statements this letter describes as added are now in the text.

The check is in `reviews/qa_v2.md`.

## Items not addressed

- GBIF cluster deduplication (R2.8)
- full occupancy-detection or state-space models (R4.4)
- realistic multi-species indicators (R4.9)
- moving to group-specific species catalogues (R5.8a)
- the S15 undescribed-species correction

Each is stated as a limitation or deviation.
