# Results (draft, 2026-11-03)

*Status: draft for internal discussion. Preregistered analyses are marked [P]; exploratory analyses [E]; provisional data [prov.]. All numbers trace to files listed in `reports/summary.md`.*

## Records per individual scale with body size across small animals

We matched global census estimates for ten animal groups to 3.75 billion GBIF occurrence records (snapshot 2026-11-01). The groups span seven orders of magnitude in body mass, from soil nematodes (~5 × 10⁻⁷ g) to mesopelagic fishes (~3 g). We kept only groups whose abundance estimates do not draw on occurrence data or body-size allometry.

In an errors-in-variables model propagating census uncertainty [P], records per individual (2000–2024) increased with body mass with an exponent of β = 0.72 (95% credible interval 0.49–0.94; Bayesian R² = 0.90; Fig. 1a). The interval was wider than our preregistered threshold for "clean" scaling (0.3), so we describe the relationship as scaling with limited precision.

The exponent could not be distinguished from the value of 2/3 expected if detectability tracked projected area alone: the posterior probability that β exceeds 2/3 by more than 0.2 was 0.09. The estimate was robust to the choice among alternative census values, taxonomic matching rules, default uncertainties, exclusion of any single group, and exclusion of iNaturalist records (β = 0.60–0.84 across 13 sensitivity analyses).

By contrast, birds and land mammals lay about five orders of magnitude above the extrapolated relationship (Fig. 1a, open symbols). Including them raised the exponent to 1.27 (1.07–1.48). Because the available global abundance estimates for both groups are themselves derived from occurrence data or allometric models, we tested this vertebrate excess with species whose abundance comes from surveys [E].
- 52 marine mammals and megafauna with survey- or model-based censuses lay 3.8 orders of magnitude above the extrapolated relationship (95% interval over line uncertainty, 1.7–5.9) and 4.3 orders above the optical expectation.
- 389 land mammals with reported population sizes lay 4.9 orders above it (3.2–6.7).

Records from DNA-derived datasets scaled less steeply with body mass than human observations (β = 0.51 vs 0.75; posterior probability 0.935; Fig. 1b) [P]. This held in 24 of 27 sensitivity analyses.

Within mammals with independently reported population sizes (n = 388 species), the among-species exponent was shallower (β = 0.32, 0.18–0.47) than the cross-taxon exponent.

## An overdispersion floor on detecting declines from occurrence records

Year-to-year variation in species-level record counts was strongly overdispersed. For 382 mammal species, the negative-binomial shape was φ = 0.69 (0.66–0.71), so the coefficient of variation exceeds one even for common species [P]. This did not disappear with abundance: φ remained below one for species with more than 1,000 records per year [E]. It was lower still in invertebrate groups (0.06–0.8) [E]. Aggregating records into the number of occupied 1° cells per species and year reduced overdispersion by a factor of 2–10. For frequently recorded species this shortened detection time (e.g. mammals: 44 to 26 years), but species with fewer than one record per year remained undetectable [E].

As a result, the time needed to detect a 30% decline over ten years (power 0.8, α = 0.05, effort-offset negative-binomial regression) reached a floor of about 44 years however many records a species accumulated. The floor was about 28 years for a 50% decline (Fig. 2a). Species with fewer than about 0.3 records per year could not be detected as declining within a century.

Our preregistered mapping of detection time onto body mass therefore did not reveal a size gradient within the census range. Detection within 25 years failed in every size tercile (100% of species), formally satisfying, but not substantively supporting, the preregistered criterion.

Using observed per-species record rates instead of census-derived ones [E], the share of described species whose decline would remain undetectable for a century fell steadily with body size (Fig. 2b):
- 95–96% in nematodes, mites and copepods
- 92% in springtails
- 76% in ants
- 42–49% in jellyfish and mesopelagic fishes
- 54% to 5% across the mammal body-size range
- under 1% in birds

These shares use each invertebrate group's own overdispersion. With the mammal value they are 2–7 percentage points lower.

Commonly used analysis shortcuts performed poorly in simulations without decline [P]:
- Relative reporting rates tested with binomial models flagged false declines in about 31% of series.
- Raw record counts produced false increases in up to 33% of series when effort grew.

Pooling 100 species into a single indicator shortened detection to 10–15 years. This assumes independent species-level noise and is therefore optimistic [E].

## Consequences for undescribed diversity and biodiversity indicators

The same observation model predicted that most species in small-bodied groups would never be recorded within 25 years:
- 91% of nematodes
- 88% of mites
- 75% of springtails
- 43% of scyphozoan jellyfish

The ranking of these predictions followed published estimates of the undescribed share of each group [E] (Fig. 3a). The predictions sit below the literature values, consistent with being recorded as a necessary but not sufficient condition for description.

Finally, populations in the Living Planet Database are exclusively vertebrate and strongly biased toward large species [E, prov.]. The median body mass of mammal species represented is 105 times that of all mammals, and 720 times when weighted by number of populations. For birds the factors are 3 and 12 (Fig. 3b).
