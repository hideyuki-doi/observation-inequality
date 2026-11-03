# Discussion (draft, 2026-11-03)

*Draft for internal discussion. Prior work is cited as summarised in `docs/literature_positioning.md`; claims about other papers must be checked against their full text before submission.*

## Most observation bias in small animals is about visibility

Across ten animal groups whose global abundance was estimated independently of occurrence data, records per individual rose with body mass with an exponent of about 0.7. That is indistinguishable from the 2/3 expected if detectability tracked projected area.

Within this range, from nematodes to small fishes, the familiar under-recording of small organisms therefore needs no appeal to human preference. Being small is enough.

This reframes the taxonomic bias in GBIF that has usually been read as societal preference (Troudet et al. 2017). Part of that bias is the expected outcome of an optical sampling process. The interval on our exponent (0.49–0.94) cannot exclude a 3/4 law or exponents arising from search geometry (Pawar et al. 2012). The distinction between such mechanisms is less important here than the conclusion that a smooth size law, not taxon-specific neglect, describes most of the variation.

## Vertebrates carry an "interest premium"

The picture changes for vertebrates. Mammals with survey-based or reported population sizes sat 4–5 orders of magnitude above the extrapolated invertebrate relationship, and birds lay similarly high. The size law alone cannot produce an excess of this magnitude.

Two mechanisms likely contribute:
- dedicated recording infrastructure, from bird atlases to photo-identification catalogues of whales; humpback whales accumulate about seven records per individual in 25 years
- the larger pool of observers and recording tools that charismatic species attract

Within mammals the size gradient was much shallower (β ≈ 0.3), so the premium attaches to taxonomic group more than to individual species. This is consistent with within-class body-size effects in bird citizen science (Callaghan et al. 2021; Stoudt et al. 2022) being modest compared with the gap between classes.

The vertebrate comparison is exploratory and extrapolates the main relationship by four to eight orders of magnitude. No independent global abundance estimates exist for birds or fishes at the species level. Even at the lower bound of the extrapolation interval, however, mammals remain more than an order of magnitude above it.

## A floor on what occurrence records can reveal about declines

Our second result concerns what these records can be used for. Year-to-year record counts were overdispersed (φ ≈ 0.7 in mammals, lower in invertebrates), and this did not shrink for common species. As a result, the time needed to detect a 30% decline per decade has a floor near four decades, even with effort correction, and adding records does not lower it.

That opportunistic data detect declines poorly has been shown before:
- simple methods yield biased trends and low power (Isaac et al. 2014)
- unstructured records miss many declines that structured monitoring finds (Kamp et al. 2016)

What our analysis adds is the cross-taxon estimate of the noise floor, and its mapping onto body size: 95–96% of described nematode, mite and copepod species, but under 1% of birds, record so rarely that no decline would become detectable within a century.

Commonly used shortcuts are not just weak but misleading:
- relative reporting rates tested with binomial models produced false declines in about a third of stable series
- raw counts produced false increases when effort grew

## Are occupancy models enough?

Occupancy-detection models using visit structure have recovered trends for many invertebrate taxa in Britain (Outhwaite et al. 2020). Our coarse occupancy index, based on occupied 1° cells, reduced overdispersion several-fold and shortened detection times for frequently recorded species. It did not help species with fewer than one record per year, which are the majority of described invertebrates.

Occupancy models also depend on repeat visits and on recording schemes concentrated in a few countries. We therefore see them as a remedy for the well-recorded fraction of biodiversity, not for the rarely recorded majority that our analysis identifies.

Pooling species into multi-species indicators shortened detection to 10–15 years in our simulations. This assumes independent species-level noise, so it is an optimistic bound.

## Consequences for undescribed diversity and biodiversity indicators

The same observation process predicts which species remain unrecorded. Its predictions followed the ranking of published undescribed fractions across groups, while falling short of them.

This is consistent with being recorded as a necessary but not sufficient condition for description. It is also consistent with evidence that range size and taxonomic effort, beyond body size, shape description (Collen et al. 2004; Costello et al. 2015). It complements the finding that the share of species observed in each class grows with the number of individuals sampled (Callaghan et al. 2023).

Global indicators inherit the same skew. Populations in the Living Planet Database are all vertebrates, and the represented mammal species are two orders of magnitude heavier than mammals overall. National analyses have reported similar size bias (Currie et al. 2022). Since declines are least detectable in the small, rarely recorded majority, indicators built from available records describe the part of biodiversity that is easiest to see.

## Limitations

- **Narrow census set.** The main analysis rests on ten groups because few global abundance estimates are independent of occurrence data or allometry.
- **No independent census for birds and fishes.** Species-level birds and fishes lack such estimates, and the vertebrate premium is exploratory.
- **Records are not individuals.** A record can represent many individuals or one sample. Weighting by individual counts weakened the fit (R² = 0.70).
- **Simple simulation model.** The detection simulations use negative-binomial count models with a single overdispersion per stratum, and do not implement full occupancy-detection models.
- **Older LPI release.** We used the 2016 public release of the Living Planet Database, and reptiles were not analysed for body size.

## Implications

1. **Interpret trends from opportunistic data at the right resolution.** For most small organisms, a lack of detected decline carries almost no information.
2. **Add structured or DNA-based monitoring where records are rare.** DNA-derived records were less size-biased (exponent 0.51 vs 0.75), suggesting that molecular monitoring can partly fill the gap.
3. **Make indicators state their coverage.** Biodiversity indicators should report what share of species, individuals and biomass they represent, so that "no detected decline" is not read as stability.
