# Reviewer 5 report

**Manuscript:** "Body size governs how often animals are recorded and how long their declines stay hidden" (commit 40d8e93)
**Reviewer expertise:** global abundance and biomass censuses of soil and marine invertebrates (nematodes, microarthropods, zooplankton, krill, mesopelagic fish); invertebrate taxonomy; estimates of undescribed diversity.
**Scope of this report:** the census values, their uncertainties and unit conversions; matching census groups to GBIF taxa; the "independent" classification; described-species counts; the H5 (undescribed species) analysis; and the vertebrate census comparison. I read main.md, si.md, PREREG.md, docs/data_provenance.md, the provenance parts and CSVs, census_main_selection.csv, conversion_factors.csv, census_main.csv, richness_selection.csv and reports/phase1.md. I also ran read-only checks on the GBIF aggregate (`data/derived/gbif_taxon_year.parquet`), the Bar-On repository inputs, the Rosenberg re-run log, `sim/h5_unrecorded.csv` and `sim/explore_vertebrates_species.csv`. My own back-of-envelope regressions are OLS on the point estimates. The authors' S13 Monte Carlo OLS (β = 0.73) agrees with the main errors-in-variables (EIV) estimate (0.72), so I treat OLS as an adequate guide to direction and size. The authors should redo all of these checks in their full model.

---

## Summary

The author divides GBIF record counts for 2000–2024 by global census abundances for ten invertebrate and small marine groups. These are soil nematodes (van den Hoogen 2019), springtails (Potapov 2023), soil mites (a re-run of the Rosenberg 2023 code), non-arboreal ants (Rosenberg 2023), Antarctic krill (Atkinson 2009), and five Bar-On et al. 2018 subgroups whose abundance is biomass divided by an assumed individual mass: enchytraeids, copepods, pteropods, planktonic cnidarians and mesopelagic fish. The resulting records per individual (r) are regressed on typical mass M = B/N in an EIV model. The estimate is β = 0.72 (0.49–0.94), which the author reads as consistent with detectability scaling with projected area (M^2/3). Mammals with survey-based abundances lie 3.8–4.9 orders of magnitude above the extrapolated line. Simulations then show that year-to-year overdispersion of record counts sets a floor of about 40 years on detecting a 30% per decade decline. A further exploratory analysis predicts the share of never-recorded species from the scaling relationship and literature totals of species richness, and compares it with published undescribed shares.

The data compilation is unusually transparent. Verbatim quotes, re-computations from the source repositories and explicit method classes are recorded for every census value, and I could check most numbers back to source. I commend this. My concerns are with what the census values can support, not with how carefully they were transcribed.

## Overall assessment

The question is important, and the provenance work is exemplary. However, the headline result does not currently support its mechanistic reading, for one structural reason and several census-specific ones.

1. **Records hardly vary across groups.** R spans only 1.6 orders of magnitude (6.4 × 10⁴ to 2.5 × 10⁶), while N spans 5.8 orders. Across these groups the census N falls with M as about M^−0.89, because group biomasses are similar (B spans 1.8 orders). As a result, β is almost entirely the census N–M relationship. If every group had exactly the same number of records, β would be 0.89 with R² = 0.92. Randomly permuting R among groups gives β of 0.70–1.08 (median 0.885) and R² ≥ 0.73. The record counts themselves carry little information about body size. The comparison with 2/3 is therefore underpowered against the null that records are unrelated to the organisms' abundance and size (Major 1).
2. **For most groups, records do not come from optical detection.** For 8 of the 10 groups, records come from extraction, net hauls, metabarcoding and identification under the microscope, not from visual detection by observers in the field. The "projected area" interpretation has no clear mechanism for these groups (Major 2).
3. **Several census inputs are not independent measurements, or are converted with unsuitable factors.** Half of the N values are biomass divided by an assumed mass. The carbon-to-wet factor of 0.15 is wrong by one to two orders of magnitude for gelatinous zooplankton. Several group scopes do not match their GBIF taxa (nematodes, mites, mesopelagic fish, jellyfish), and preregistered scope sensitivity analyses were not run (Majors 3–6).
4. **H5 and the vertebrate comparison contain errors and overstatements.** Some can be checked directly from files in the repository: the elephant is counted twice; the text claims a ranking that the table does not show; and the predicted numbers of recorded species are 4–11 times the observed numbers (Majors 7–9).

Each correction alone moves β by only ±0.03–0.09, and in my rough checks plausible combinations stay within about 0.67–0.77. The point estimate is therefore fairly robust. The interpretation, the precision claims and the derived exploratory results are not. The simulation results on overdispersion (H3 and the detection floor) are largely independent of the census and seem to me the paper's most solid contribution. Other reviewers are better placed to judge them.

---

## Major comments

### 1. The scaling exponent is set by the census N–M relationship, not by records

Writing ln r = ln R − ln N, the slope of ln r on ln M equals slope(ln R ~ ln M) − slope(ln N ~ ln M). For the ten main groups (Table S1 values), slope(log N ~ log M) = −0.886 and slope(log R ~ log M) = −0.152 (r = −0.51). The fitted β = 0.73 is therefore 0.89 contributed by the denominator and −0.15 by the records. Three further results point the same way:

- A joint regression gives log R = 4.6 + 0.03 (± 0.37) log N − 0.12 (± 0.34) log M. Across groups there is no detectable relationship between the number of records and the number of individuals.
- If R is permuted at random among groups (10,000 permutations), β has median 0.885 (95% range 0.70–1.08) and R² has median 0.84 (0.73–0.95). The observed β (0.73) lies at the 7th percentile of this null, and the observed OLS R² (0.80) is lower than the permutation median.
- The five groups with directly counted N show the same pattern: slope(N ~ M) = −0.94 and slope(R ~ M) = −0.10.

So the H1 criterion (R² > 0.7) is met for any set of record counts. H2 (β vs 2/3) is in effect a test of whether R falls with M at slope −0.22 (optical) or 0 (records unrelated to size). With ten points and a residual SD of about 0.5 log₁₀, the data cannot tell these apart.

*Requested:*
- (a) Fit ln R_g = a + γ ln N_g + δ ln M_g inside the EIV model and report γ. If γ is near 0, the "records per individual" framing is not appropriate.
- (b) Report β against a null reference β₀ = −slope(ln N ~ ln M), estimated in the same model with its own posterior. The meaningful quantity is β − β₀, equivalently the slope of ln(R/B) on ln M, which the PREREG §1 already lists as a secondary response. Make this the primary result.
- (c) Report the permutation (or simulation) null for β and R² in the SI, and either drop the R² part of the H1 criterion or apply it to ln R rather than ln r.
- (d) Revise the Abstract, Significance statement and Discussion. "Records per individual rise roughly with projected area" should be restated as "record counts vary little among groups whose abundances differ by six orders of magnitude".

### 2. The optical (projected-area) mechanism does not apply to how these groups are recorded

According to `data/derived/records_diagnostics.csv`, the HUMAN_OBSERVATION share of records is 0.16 for nematodes, 0.18 for springtails, 0.29 for mites, 0.19 for copepods, 0.19 for pteropods, 0.21 for enchytraeids, 0.12 for krill and 0.30 for Myctophidae. For these taxa, "human observations" are likely to include many counts made under the microscope on processed samples (survey and plankton time-series counts) rather than detections in the field. The author should check this per dataset. DNA-derived records are 42% of the Nematoda records for 2000–2024 (172,811 of 416,187) and about 51% of springtail records (all years). Material samples are 87% of krill records. A single dataset holds 29% of copepod records, and five datasets hold 52%.

For soil microfauna and plankton, the number of records is set by how many cores, hauls or metabarcoding runs were processed and published, and by whether specialists could identify the material. The projected area of the animal to a human eye plays no obvious part. A fit to 2/3 is therefore a numerical coincidence of the census structure (Major 1), not evidence of the mechanism. Only ants, jellyfish and the vertebrates are plausibly recorded mainly by sight.

*Requested:*
- (a) Provide a per-group table of records by basis of record, by DNA/non-DNA, and by top-1 and top-5 dataset share.
- (b) Repeat the analysis with the number of contributing datasets or sampling events per group as the response. This is a measure of effort that is independent of N.
- (c) Restrict the "optical" test to groups that are mostly recorded by sight, or remove the mechanistic claim.
- (d) Note in the Discussion that records of microfauna are limited by identification capacity (the taxonomic bottleneck) more than by detectability.

### 3. Half of the "independent" abundances are biomass divided by an assumed mass, and the assumed masses are weak

For copepods, enchytraeids, pteropods, planktonic cnidarians and mesopelagic fish, N = B / m_assumed (re-computed exactly in `harmonized_baron_subgroups.txt`). Density is not predicted from body size here, but N is still a body-size conversion of biomass. For these groups ln r = ln(R/B) + ln m, so m enters both axes, and β is informed only through the variation of R/B with m. Calling these values "independent ... of body-size allometry" (main text, Results paragraph 1) is misleading. I also have concerns about each assumed mass:

- **Copepods (4 µg C).** This is the geometric mean of the endpoints of a 0.15–100 µg C range, not an abundance-weighted mean. Numerically, copepod assemblages are dominated by small taxa (*Oithona*, *Oncaea*, *Microsetella*, copepodites and nauplii; e.g. Gallienne & Robins 2001; Turner 2004), which are also under-sampled by ≥200 µm nets. Bar-On's correction for 300 to 200 µm mesh does not address nets coarser than 200 µm. The numerical mean mass is therefore probably 1–2 µg C, and N is underestimated by perhaps 2–4×. The default fold of 3 on assumed masses (σ = 0.56) is also inconsistent with the stated range: treated as a 95% range, 0.15–100 µg C implies σ ≈ 1.66.
- **Enchytraeids (25 µg C).** The B comes from Fierer's seven biomes only; savanna, pasture and cropland are excluded (`harmonized.csv`). N is therefore an under-count. GBIF Enchytraeidae also include aquatic, marine and glacial taxa.
- **Planktonic cnidarians (2.03 mg C).** I recomputed this from `carbon_content_data.xls`. The geometric mean of the median and mean over all 122 rows of Lucas et al. Appendix S4 is 2.035 mg C, matching Bar-On exactly. Those rows include 21 Thaliacea and 16 Ctenophora, so the "jellyfish" mass is not a cnidarian mass. By class, the same statistic is 0.53 mg C for Hydrozoa and 10.35 mg C for Scyphozoa. The GBIF match (Scyphozoa + Cubozoa) therefore refers to animals about 5× heavier, in carbon, than the census mass. The 0.04 Gt C is also Lucas's total for gelatinous zooplankton in the mixed layer, which Bar-On did not multiply by 0.92.
- **Mesopelagic fish (3.09 g wet).** As the provenance notes, Bar-On's code uses one pooled mean length (66.4 mm) for all 32 myctophid species. With per-species mid-lengths I obtain a geometric-mean mass of 2.54 g (−18%). More importantly, a myctophid-only, unweighted mass ignores the numerically dominant small mesopelagic fishes (Gonostomatidae such as *Cyclothone*, Sternoptychidae, Phosichthyidae). The numerical mean mass is probably well below 1 g, and N is correspondingly larger.
- **Pteropods.** B is the geometric mean of MAREDAT's "maximum" and "minimum", which differ 26-fold. The default fold of 10 is acceptable, but the SI should state it.

*Requested:*
- (a) Reclassify these five groups as "biomass independent, abundance assumption-derived" (or "mixed") in Table S1, and correct the main-text sentence.
- (b) Add a sensitivity analysis restricted to the five groups whose N was counted directly (nematodes, springtails, mites, ants, krill). My OLS gives β = 0.84 for these, and 0.77 for the five Bar-On groups.
- (c) Set the uncertainty of each assumed mass from its documented range rather than a common fold of 3.
- (d) For the jellyfish point, use a mass for Scyphozoa and Cubozoa only, or match GBIF to the full gelatinous scope of the census (see Major 5).

### 4. Unit conversions: one carbon-to-wet factor of 0.15 is not appropriate for all groups

The ratio of 0.15 (30% dry matter × 50% carbon) is reasonable for fish and many arthropods, but not for these groups:

- **Gelatinous zooplankton.** Carbon in medusae, ctenophores and salps is typically well below 1% of wet mass (e.g. Lucas et al. 2011, *Ecology* 92:1704). Converting 2.03 mg C with 0.15 gives 13.6 mg wet. A ratio of about 0.5% gives about 0.4 g wet, and about 2 g wet for a Scyphozoa-specific mass. The jellyfish M is therefore too small by roughly 1.5–2 orders of magnitude. Wet volume is also the relevant currency for "visible size" under the optical hypothesis. S8a (multiplying B by 1.5) does not address this. In my OLS, moving jellyfish M up by 30× changes β from 0.73 to 0.68.
- **Nematodes.** Van den Hoogen's abstract gives "approximately 0.3 gigatonnes" against 31.44 Mt C in Supplementary Table 7. This implies a carbon-to-fresh ratio of about 0.105, consistent with the usual nematode conventions (about 20% dry matter, about 52% carbon in dry mass). The project rule is to use the source's own factor where one is given, and it was applied to Potapov (190/27.5). Applied to van den Hoogen, it gives M = 6.8 × 10⁻⁷ g rather than 4.8 × 10⁻⁷ g.
- **Pteropods, copepods and enchytraeids.** Shelled pteropods (aragonite shell), copepods and soft-bodied oligochaetes usually have carbon-to-wet ratios of about 0.05–0.10.
- **Dry-to-wet factors.** Rosenberg's ratios (Acari 0.4, Formicidae 0.228, Collembola 0.32) are cited from Petersen & Luxton 1982 but are not verified at origin (`conversion_factors.csv`). There is also an internal inconsistency for ants: B/N gives 0.50 mg dry per ant, while Rosenberg reports "0.84 mg per soil ant".

*Requested:*
- (a) Use taxon-specific wet-mass conversions with sources: the source's own factor for van den Hoogen; published gelatinous composition data for cnidarians; pteropod-specific factors (Bednaršek et al. 2012 provide conversions).
- (b) Report β with these factors. My OLS with combined corrections (nematode scope and conversion factor, jellyfish wet mass, pteropod ×3, Rosenberg springtails) gives β ≈ 0.67.
- (c) Consider using a linear dimension (body length) instead of M for the optical test, since projected area relates to length², not mass, for animals of very different shape and water content.

### 5. Mismatches between census scope and GBIF taxa: quantified, and preregistered checks not run

PREREG §7 S6 and `taxon_matching.md` promised variants excluding animal-parasitic nematode families, a land-only coordinate variant for nematodes, and an extended family list for mesopelagic fish. None appears in Table S2, and none is listed as a deviation (reports/phase4.md only says "not run; source not finalised"). From the GBIF aggregate (2000–2024, no fossils) I obtained the following.

| Group (GBIF rule) | Composition of records | Effect on r | Effect on β |
|---|---|---|---|
| Nematoda (416,187) | Marine-dominated orders (Enoplida, Chromadorida, Desmodorida, Araeolaimida, Desmoscolecida, Monhysterida) 21.8%; animal-parasitic orders and Rhabditida families (Trichostrongylidae, Onchocercidae, Anisakidae, etc.) 11.1%; records identified only to phylum 22.6% (mostly material samples and DNA). At most about 45–55% can be attributed to soil. | Overestimated | Biased low. Halving R gives β 0.76. |
| Sarcoptiformes + Mesostigmata + Trombidiformes (1,315,602) | About 49% from families that are not soil mites: Varroidae alone 16.0% (210,285; honey-bee parasite); water and marine mites 16.1%; plant-associated families (Eriophyidae, Tetranychidae, Phytoseiidae, etc.) 13.3%; other animal-associated and stored-product families about 4%. | Overestimated | Slightly low (R × 0.6 gives 0.745) |
| Copepoda (2,421,706) | Dominated by marine planktonic families (Calanidae, Acartiidae, Clausocalanidae, etc.). Freshwater Cyclopidae + Diaptomidae about 3.6%; parasitic families under 1%. Note that the `order` field is empty for 99.6% of Copepoda records in this snapshot, so any order-based rule would fail silently. | Small mismatch | Negligible |
| Myctophidae (127,567) | Other mesopelagic families (Sternoptychidae, Stomiidae, Bathylagidae, Paralepididae, Gonostomatidae, Melamphaidae, etc.) add 135,032 records, more than Myctophidae itself. The census B (acoustic) covers all mesopelagic fish. | Underestimated about 2× for the largest group | Biased low (β 0.76) |
| Formicidae (2,509,986) | Includes arboreal species and colonies that Rosenberg's non-arboreal N excludes | Overestimated | Slightly high |
| Scyphozoa + Cubozoa (173,734) | The census N covers all gelatinous zooplankton, including hydromedusae, siphonophores, ctenophores and thaliaceans, which are numerically dominant | Underestimated | Ambiguous once the M correction is included |

Most mismatches bias β downward, so they do not threaten the claim that β < 1. They do matter for the claim of agreement with 2/3, and greatly for the species-level exploratory analyses and the "share undetectable" figures, where Varroa-type cases dominate. The "+Hydrozoa" variant (S6b) adds benthic hydroid polyps and is not a sensible alternative scope.

*Requested:*
- (a) Run the preregistered S6 variants: nematodes excluding animal-parasitic families; nematodes with land coordinates only (the gbif_cells aggregation already exists); and an extended mesopelagic family list. Add a soil-mite variant excluding aquatic, plant-associated and animal-associated families, and a jellyfish variant matched to the full gelatinous scope (Hydromedusae, Siphonophorae, Ctenophora, Thaliacea).
- (b) Report these in Table S2 with the direction of bias for each group, and list the unrun preregistered analyses as deviations.

### 6. Census uncertainties are heterogeneous, partly arbitrary, and sometimes miss structural error; one gate decision was silently reversed

- **Krill.** N_lo–N_hi (5.4–8.0 × 10¹⁴) comes from stratification sensitivity runs in Atkinson et al. 2009 §3.2, not from a confidence interval. It gives σ = 0.10, the tightest constraint of any group, and krill has high leverage (Δβ ≈ +0.07 per +1 log₁₀ r). The same paper gives 2.4 × 10¹⁴ for unadjusted net sampling (117 Mt, Table 4), and the acoustic-based 133 Mt implies about 2.7 × 10¹⁴. The estimate is also an average over 1926–2004, and trends since the 1970s are debated (Atkinson et al. 2019; Cox et al. 2018), while the records span 2000–2024. Setting N = 2.4 × 10¹⁴ moves β to 0.77.
- **Springtails.** N has no interval (default fold 10). The B interval (16.2–28.8 Mt C) reflects only the SE of the length–mass regression (σ = 0.15). Rosenberg et al. state that Potapov's biomass is about 4× too high. The authors' own re-run of Rosenberg's code gives springtail B = 17.69 Mt dry and N = 3.45 × 10¹⁸, so M ≈ 16 µg wet against Potapov's 95 µg, a six-fold difference. S5b (Rosenberg springtails) is preregistered but missing from Table S2, apparently because B was blank in the published paper. The re-run supplies it.
- **Nematodes.** The meaning of "4.4 ± 0.64" was never verified, and the code correctly falls back to fold 10. The SI should state this. Structural uncertainty is large: Bar-On's soil-only N is 1.1 × 10²⁰ against van den Hoogen's 4.4 × 10²⁰, and 38% of van den Hoogen's total comes from sparsely sampled sub-Arctic regions.
- **Ants.** Rosenberg's non-arboreal N (5 × 10¹⁶) is 2.5× Schultheiss's estimate for all ants and 17× Schultheiss's epigaeic estimate. In S5c, the ± SEM was treated as a 95% range (σ = 0.13), contrary to the PREREG §2 rule (SEM/mean = 0.25).
- **Mesopelagic fish.** Phase 1 gate decision 4 made Irigoien 2014 the primary mesopelagic estimate, with Proud 2019 as a sensitivity analysis. `census_main_selection.csv` instead uses Bar-On's B (0.52 Gt C, about 3.45 Gt wet), and neither Irigoien nor Proud appears in any analysis. The SI nevertheless lists Irigoien 2014 as a census source. With an Irigoien- or Proud-scale B (about 11.5 Gt wet), my OLS gives β 0.69, or 0.715 when combined with the full family list.

*Requested:*
- (a) Run S5b using the re-run Rosenberg springtail B.
- (b) Implement or explicitly revoke the mesopelagic gate decision, and add Irigoien and Proud sensitivity analyses.
- (c) Widen the krill σ to cover the unadjusted and acoustic estimates.
- (d) Add a "structural uncertainty" analysis in which each group's σ is set from the spread between independent sources (van den Hoogen vs Bar-On; Potapov vs Rosenberg; Rosenberg vs Schultheiss; standardised vs unadjusted krill; Bar-On vs Irigoien vs Proud), and an "equal-σ" analysis.
- (e) Report Bayesian R² on observed rather than latent values. The latent N and M can slide towards the line within fold-10 priors.

### 7. Vertebrate census comparison: data errors, partial coverage, selection, and a model-dependent "excess"

**Data integrity.** The 52 "census_independent" species in `sim/explore_vertebrates_species.csv` include:
- two rows for the African elephant: GEC 352,271 and "Loxodonta africana s.l." AESR 415,428. Both map to *Loxodonta africana* with the same R = 22,061 (`dup_target = TRUE`), so one species is counted twice;
- *Ursus maritimus*, whose N is marked verified = 未確認 (unverified; taken from a secondary statement).

The actual composition is 43 Greenspoon 2025 species, 2 seals from Greenspoon 2023 IUCN text, 4 rhinos, 2 elephant rows and the polar bear. The main text says "45 marine mammals [Greenspoon 2025], four rhinoceros species, the African savanna elephant and two seals".

**Coverage of N.** Greenspoon 2025 publishes biomass, and N was recovered as biomass ÷ mass. This recovery is exact for the SSRA-modelled populations, which I accept. However:
- For 21 of the 43 species, N is the sum of modelled populations only. For 11 species, the 2025 total is below an IUCN total (provenance §1.5). Humpback whale N is 58,000, while the non-overlapping IWC regional estimates (Southern Hemisphere breeding stocks plus the North Pacific) already exceed 70,000.
- Global R divided by partial N inflates r.
- The crabeater seal is classed independent at 8 million individuals, although the source itself calls earlier estimates of 2–75 million "speculative".

**Selection and shared data.** The species with survey-based N are, by construction, the most intensively monitored mammals. Their surveys (ship-based sightings, photo-identification catalogues) are themselves published as occurrence records. Humpback whales have 7 records per individual, so R and N partly share data. This supports the author's "dedicated recording" explanation, but it does not justify generalising to "vertebrates as a group".

**The size of the excess.** In records per gram, the 52-species aggregate has log₁₀ R/B = −7.1. The invertebrate groups range from −7.6 (ants) and −7.7 (mites) to −10.4 (mesopelagic fish). The mammal excess per unit biomass is therefore 0.5–3.3 orders of magnitude. The "4–5 orders" figure arises from extrapolating a weak R/B slope (about −0.27) over 5–6 orders of M.

*Requested:*
- (a) Remove the duplicate elephant row, and justify or exclude the polar bear.
- (b) Report results restricted to species whose census is a species total, with coverage stated.
- (c) Present the R/B comparison alongside the extrapolation.
- (d) Revise "about 10,000 times more records than their size alone predicts" in the Significance statement to reflect the model dependence.

### 8. Described-species counts are incomplete and their scope is inconsistent

Counts come from the COL base release 26.10, but GBIF names are resolved to COL XR, so numerators and denominators come from different checklists.
- **Mites.** 29,017 (Acariformes 22,635 + Parasitiformes 6,382) is far below the counts the authors themselves archived: Hodda 2022b Table 1 gives 55,000 for Acari, and Chapman 2009 gives 48,200. Parasitiformes also includes Ixodida, which the main GBIF match excludes.
- **Nematodes.** 19,667 is the whole phylum, against "nearly 30,000" (Hodda 2022a,b), and is used with a soil-only census mass in Fig. 2B.
- **Earthworms.** The count (1,994) is clearly incomplete; it is not used in the main analysis.

The consequences are twofold. The shares in Table S10a ("95–97% undetectable") are lower bounds, because the missing described species are mostly unrecorded. In H5, the "literature undescribed share" mixes CoL described counts with literature totals that were derived relative to other described counts:

| Group | Share with CoL described count | Share with the source's own described count |
|---|---|---|
| Mites | 1 − 29,017/223,607 = 0.87 | 1 − 48,200/223,607 = 0.78 |
| Copepods | 0.69 (CoL total includes freshwater and parasitic species) | 0.80 (Appeltans marine 10,000/50,125) |
| Scyphozoa | 0.32 (CoL 244) | 0.44 (Appeltans 201) |

*Requested:*
- (a) Use authoritative group catalogues (Zhang 2011/2013 for Acari; Hodda 2022a for Nematoda; WoRMS for marine Copepoda and Scyphozoa; AntCat for ants; Collembola.org).
- (b) Take numerator and denominator from the same source.
- (c) Match described-species scope to the GBIF rule (e.g. exclude Ixodida).
- (d) Report the sensitivity of Table S10a and Fig. 2B to these counts.

### 9. H5 (never-recorded species) is circular in construction, misreported, and fails a direct check

**Built-in correlation.** Both the predicted never-recorded share (mean N_s = N_g / S_total) and the "literature undescribed share" (1 − S_desc / S_total) increase with the same literature S_total. Agreement between them is partly guaranteed.

**Misreported ranking.** Table S8 (σ = 1.5, 25 years) gives predicted shares of nematodes 0.91 > mites 0.88 > ants 0.79 > springtails 0.75 > copepods 0.62 > jellyfish 0.43. The literature order is nematodes > mites > springtails > copepods > ants > jellyfish. The main text reports only four groups and states the predictions "ranked groups in the same order" and "fell below them". Both statements are false once ants and copepods are included: Spearman ρ = 0.83, and ants (0.79 vs 0.58) and jellyfish (0.43 vs 0.32) are above the literature value.

**A direct check is available.** The model predicts the share of species never recorded in 25 years, and `sim/h5_unrecorded.csv` already contains the observed number recorded in 2000–2024. The predicted numbers of recorded species (S_total × (1 − predicted share)) are:

| Group | Predicted recorded species | Observed recorded species |
|---|---|---|
| Nematodes | about 46,500 (more than the 19,667 described) | 4,203 |
| Mites | about 26,200 | 6,767 |
| Copepods | about 18,950 | 3,435 |
| Springtails | about 12,660 | 2,530 |
| Ants | about 7,140 | 9,503 |
| Jellyfish | about 206 | 194 |

The model overpredicts recorded richness 4–11-fold for exactly the small groups the paper is about. A group-level r applied to a log-normal SAD does not reproduce how recording is spread across species, which is concentrated in a few species and projects (Varroa alone is 16% of mite records). The results are also very sensitive to the SAD width (nematodes 0.73, 0.91 and 0.98 for σ = 1, 1.5 and 2; at σ = 2 the predictions exceed the literature shares for all six groups) and to S_total, where the nematode range runs from 0.5 to 10 million (Hodda 2022a).

*Requested:*
- (a) Report the direct comparison between predicted and observed recorded species.
- (b) Propagate the full S_total ranges and the SAD width.
- (c) Correct the ranking and "fell below" statements.
- (d) Either move H5 to the SI as a clearly caveated exploration or remove it. In its present form it does not support "the same observation process predicts how many species should never have been recorded".

---

## Minor comments

1. **Preregistered analyses missing from Table S2.** The SI says 15 preregistered sensitivity analyses were run. Table S2 lacks S5b (Rosenberg springtails), the S6 nematode and mesopelagic variants, the S8 prokaryote factor (0.15 vs 0.22) and S15 (correction for undescribed species). List all of them in the deviations section.
2. **Van den Hoogen uncertainty.** State in the SI that the nematode N uncertainty defaulted to fold 10 because the reported ± is narrower and of unknown meaning. The N_lo and N_hi in census_main.csv are not used.
3. **"Independent" N built from statistical extrapolation.** Van den Hoogen and Potapov N are random-forest extrapolations from about 6,800 and 2,470 sites respectively, with strong geographic clustering. Classing them as independent is defensible because neither uses occurrence data or density allometry. The SI should still say that this excludes structural extrapolation error, which is much larger than the bootstrap intervals.
4. **Census data that may also be GBIF records.** Several census sources (KRILLBASE, JeDI, MAREDAT/COPEPOD, continuous plankton recorder time series, IWC/NOAA sighting surveys) may themselves be published to OBIS/GBIF. Identify and quantify the overlap between census source data and the GBIF datasets contributing R.
5. **Year-to-year overdispersion in small groups.** For small groups, species-by-year record counts are dominated by whether a single survey or metabarcoding project published in that year. The φ values of 0.06–0.25 therefore largely measure project turnover. A dataset-level random effect, or counting distinct dataset-years, would separate this from population variability. This bears on the interpretation of the 40-year detection floor.
6. **Fig. 2B.** Nematode species are plotted at the soil-nematode census mass, but the described-species set includes large vertebrate parasites. Either restrict the set or note this in the legend.
7. **Enchytraeids.** State that the census covers seven biomes, and that GBIF Enchytraeidae include aquatic and marine taxa.
8. **Table S1 source column.** For mesopelagic fish it says Bar-On while the SI lists Irigoien. Make the source of each of N, B and M explicit per group, with the role of the assumed mass shown as a separate column.
9. **Temporal mismatch.** Krill (1926–2004 average), mammal model year 2020, the GEC (2014) and MAREDAT (decades) are compared with records from 2000–2024. Discuss briefly.
10. **Records are not individuals at the top end either.** Photo-identification catalogues (humpback whales) and repeat sightings make R a count of encounters. A sensitivity analysis excluding photo-ID and repeat-encounter datasets for mammals would be informative.
11. **Language of the provenance files.** Much of the provenance documentation, including the gate decisions, is in Japanese. For the public repository, provide English versions of `docs/provenance_parts/*.md` and `reports/phase1.md`, at least for the census selection decisions.
12. **Main text, Results paragraph 1.** "estimated independently of occurrence data or body-size allometry" should acknowledge the B ÷ m construction (Major 3).
13. **Significance statement.** "records per individual rise with body size roughly as an animal's visible area would predict" should be softened in line with Majors 1 and 2.

---

## Numbers checked

| # | Quantity | Source checked | Result |
|---|---|---|---|
| 1 | Soil nematodes N = 4.4 × 10²⁰; B = 31.439 Mt C | provenance (abstract; Suppl. Tables 5 and 7 total rows 4.41E+20 and 31.439) | 31.439 × 10¹² / 0.15 = 2.0959 × 10¹⁴ g wet = census_main ✓; M = 4.76 × 10⁻⁷ g = Table S1 ✓. The abstract's "approximately 0.3 Gt" implies carbon-to-fresh ≈ 0.105, not 0.15 (Major 4). |
| 2 | Mites N and B (derived) | `harmonized_rosenberg_rerun_Nboot1e5_seed20261103.log`, cells 23 and 47 | N = 6.545062 × 10¹⁸ (3.47–10.66 × 10¹⁸) ✓; B = 26.109 (15.58–38.70) Mt dry ✓; ÷ 0.4 = 6.527 × 10¹³ g wet ✓; M = 9.97 × 10⁻⁶ g ✓. The same log gives Collembola 17.69 Mt dry and 3.446 × 10¹⁸, so M ≈ 16 µg wet against Potapov's 95 µg (Major 6). |
| 3 | Copepods | harmonized.csv; harmonized_baron_subgroups.txt | 5.64617 × 10¹⁴ g C / 4 × 10⁻⁶ = 1.41154 × 10²⁰ ✓; /0.15 = 3.764 × 10¹⁵ g wet ✓. |
| 4 | Jellyfish assumed mass | Recomputed from `baron2018/.../cnidarians/carbon_content_data.xls` and `cnidarians.py` lines 130–140 | Geometric mean of median and mean over 122 rows = 2.0349 mg C ✓ (Bar-On 2.03493). Rows include 21 Thaliacea and 16 Ctenophora. Scyphozoa only: 10.35 mg C; Hydrozoa: 0.53 mg C. |
| 5 | Mesopelagic fish mass | Recomputed from `fish_biomass_data.xlsx`, Fock & Ehrich sheet | Single pooled length 66.39 mm gives 3.093 g ✓. Per-species mid-lengths give 2.54 g (1.22× lower). |
| 6 | Krill | marine_other.md quotes of Atkinson 2009 | 7.8 × 10¹⁴, 0.486 g, 379 Mt ✓. The 5.4–8.0 × 10¹⁴ "range" is from sensitivity runs; the unadjusted estimate is 2.4 × 10¹⁴ (Table 4). |
| 7 | Springtails (Potapov) | conversion_factors.csv, census_main.csv | 27.5 × 6.909 × 10¹² = 1.8999 × 10¹⁴ g ✓; interval 1.119–1.990 × 10¹⁴ ✓. |
| 8 | GBIF R, 2000–2024 | Re-aggregated from `gbif_taxon_year.parquet` | Nematoda 416,187 ✓; Copepoda 2,421,706 ✓; three mite orders 1,315,602 ✓; Myctophidae 127,567 ✓ (all match Table S1). |
| 9 | Mite described species | harmonized_col_species_counts / harmonized.md | 22,635 + 6,382 = 29,017 ✓ arithmetically, but incomplete (Major 8). |
| 10 | H5 values | `sim/h5_unrecorded.csv` | Table S8 values ✓; ranking claim in the main text ✗ (Major 9). |
| 11 | Vertebrate set (n = 52) | `sim/explore_vertebrates_species.csv` | Elephant appears twice with identical R; polar bear N unverified; composition differs from the text (Major 7). |
| 12 | Selected main-text figures | Table S1 / S10a | Mass range 4.8 × 10⁻⁷ to 3.1 g ✓; R range 6.4 × 10⁴ to 2.5 × 10⁶ ✓; "92–97%" (96.5, 95.6, 94.7, 92.2) ✓. |

---

## Recommendation

**Major revision.** The census compilation is careful and largely reproducible, and the overdispersion and detection-power results may stand on their own. However, the central "optical scaling" claim is not identified by the data: the exponent is set by the census N–M relationship, and record counts carry almost no size signal (Major 1). The mechanism does not fit how 8 of the 10 groups are recorded (Major 2). Several census inputs, conversions and scopes need correcting or re-running as preregistered (Majors 3–6). The vertebrate and H5 exploratory claims contain verifiable errors and overstatements (Majors 7–9). I would be glad to see a revised version that reframes the scaling result around R/B and γ, implements the requested sensitivity analyses, and corrects the exploratory sections.
