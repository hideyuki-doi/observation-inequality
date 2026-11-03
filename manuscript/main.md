---
title: "Body size governs how often animals are recorded and how long their declines stay hidden"
author: "Hideyuki Doi"
bibliography: references.bib
csl: pnas.csl
link-citations: false
---

**Author affiliation:** Kyoto University, Kyoto, Japan [department to be confirmed]

**Corresponding author:** Hideyuki Doi, doi.hideyuki.8j@kyoto-u.ac.jp

**Classification:** Biological Sciences, Ecology

**Keywords:** biodiversity monitoring, occurrence data, body size, scaling, detection power

## Abstract

Occurrence records underpin most assessments of how biodiversity is changing, yet how unevenly they sample life has not been measured against how much life there is. Here I divide 3.75 billion GBIF records by global census abundances to obtain records per individual across animal groups spanning seven orders of magnitude in body mass, from soil nematodes to mesopelagic fishes. Records per individual scaled with body mass to the power 0.72 (95% credible interval 0.49–0.94), indistinguishable from the 2/3 expected if detectability tracked projected area. Mammals whose abundances were estimated by surveys rather than from occurrence data lay four to five orders of magnitude above this relationship, an excess that body size cannot explain. Records from DNA-based datasets scaled less steeply with body size than human observations. Year-to-year record counts were strongly overdispersed, even for species recorded more than 1,000 times per year. As a result, detecting a 30% decline over ten years from records, even with effort correction, required about four decades regardless of how often a species was recorded, and species recorded less than once every three years were undetectable within a century. In exploratory analyses based on observed record rates, this applied to 92–97% of described nematode, mite, copepod and springtail species but to fewer than 1% of bird species. Simple analyses that are widely used produced false declines or false increases in up to a third of stable series. The species least visible to observers are thus also the species whose declines biodiversity records cannot reveal, a bias inherited by global indicators that are built mainly from large vertebrates.

## Significance Statement

Most of what we know about biodiversity change comes from occurrence records, but these records are not spread evenly over life. Comparing records with global counts of animals, I show that records per individual rise with body size roughly as an animal's visible area would predict, while mammals receive about 10,000 times more records than their size alone predicts. Because record counts fluctuate strongly from year to year, a 30% decline over a decade takes about 40 years to detect from records, and most small invertebrate species would show no detectable decline even over a century. Claims that biodiversity is stable, based on records, therefore say little about the small organisms that make up most animal life.

## Introduction

Assessments of biodiversity change increasingly rely on occurrence records: observations, specimens and DNA detections aggregated by infrastructures such as the Global Biodiversity Information Facility (GBIF). These records are known to be biased toward particular regions, periods and taxa [@troudet2017; @hughes2021; @bowler2022; @garciarosello2023], and within groups toward larger and more conspicuous species [@callaghan2021sr; @stoudt2022]. Such biases are usually expressed relative to species richness, which treats a species of nematode and a species of whale as equivalent sampling units. Whether records are disproportionate to the amount of life itself, and by how much, has not been quantified, because the necessary denominator, the number of individuals in each group, was until recently unavailable.

Global censuses now provide that denominator. Estimates of the abundance and biomass of soil nematodes [@vandenhoogen2019], terrestrial arthropods [@rosenberg2023], springtails [@potapov2023], ants [@schultheiss2022], marine animals [@baron2018] and wild mammals [@greenspoon2023; @greenspoon2025] allow records to be expressed per individual. This makes it possible to ask a mechanistic question: does the uneven recording of life follow a simple physical rule, or does it reflect where human attention is directed? If detection were governed by how large an organism appears to an observer, records per individual should scale with projected area, that is, with body mass to the power of about 2/3. A much steeper relationship, or large departures for particular groups, would point to human interest [@troudet2017].

The unevenness of records matters because records are increasingly used to detect population declines. Simple analyses of opportunistic data can produce biased trends [@isaac2014; @isaac2015], unstructured records can miss declines that structured monitoring detects [@kamp2016], and detecting trends in any time series requires long monitoring when variability is high [@white2019]. How these limits are distributed across the tree of life, and whether they can be overcome by accumulating more records, has not been examined.

Here I combine 3.75 billion GBIF records with census estimates for animal groups spanning seven orders of magnitude in body mass. Following a preregistered plan, I estimate how records per individual scale with body size, compare record types, and use simulations parameterised with observed record variability to determine how long declines take to become detectable. Exploratory analyses extend the comparison to vertebrates with survey-based censuses and to all described species in each group, and examine consequences for undescribed diversity and global indicators.

## Results

### Records per individual scale with body size as projected area predicts

I matched census estimates to GBIF records for ten animal groups whose global abundances were estimated independently of occurrence data or body-size allometry (Table S1): soil nematodes, soil mites, copepods, springtails, enchytraeid worms, ants, pteropods, planktonic cnidarians, Antarctic krill and mesopelagic fishes. Typical individual masses ranged from 4.8 × 10⁻⁷ g (nematodes) to 3.1 g (mesopelagic fishes), and records from 2000 to 2024 ranged from 6.4 × 10⁴ (pteropods) to 2.5 × 10⁶ (ants).

In a model that propagated census uncertainty into both abundance and body mass, records per individual scaled with body mass with an exponent β = 0.72 (95% credible interval [CrI] 0.49–0.94; Bayesian R² = 0.90; Fig. 1A). The interval was wider than the preregistered threshold for a precise scaling law (0.3), so I describe the relationship as scaling with limited precision. The exponent was indistinguishable from the optical expectation of 2/3: the posterior probability that β exceeded 2/3 by more than 0.2 was 0.09, and that it fell short by more than 0.2 was 0.02. The posterior probability of β < 1 was 0.99. The estimate was robust across 24 sensitivity analyses that varied census sources, taxonomic matching rules, default uncertainties, unit conversions, record periods and weighting, and excluded each group in turn or iNaturalist records (median β 0.60–0.84; Fig. S1, Table S2).

Within this size range, then, the familiar scarcity of records for small animals is close to what an observer limited by the visible size of organisms would produce.

### Vertebrates receive records far beyond their size

Adding birds and land mammals as two further groups steepened the relationship to β = 1.27 (1.07–1.48), and both lay far above the line fitted to the ten groups (Fig. 1A, red symbols). Their global abundances, however, were themselves estimated from occurrence data (birds [@callaghan2021pnas; @robinson2022]) or largely from allometric models (92% of land mammal species [@greenspoon2023]), so this comparison is partly circular.

I therefore examined, in an exploratory analysis, mammal species whose abundances came from surveys or population models fitted to survey and catch data: 45 marine mammals [@greenspoon2025], four rhinoceros species [@cites2025rhino], the African savanna elephant [@chase2016] and two seals (Table S7). These 52 species lay on average 3.8 orders of magnitude above the extrapolated relationship (95% interval over the uncertainty of the line, 1.7–5.9) and 4.3 orders above the optical expectation (Fig. 1A, blue). The 389 land mammals with reported population sizes in ref. [@greenspoon2023] lay 4.9 orders above it (3.2–6.7). Some of this excess reflects dedicated recording: humpback whales, for example, accumulated about seven records per individual between 2000 and 2024. Within mammals, records per individual rose only weakly with body mass (β = 0.32, 0.18–0.47; 388 species with reported populations; Table S3), so the excess attaches to vertebrates as a group more than to large species.

### DNA-derived records are less size-biased

Records from datasets carrying DNA-derived data scaled less steeply with body mass than human observations (β = 0.51 [0.24–0.79] vs 0.75 [0.48–1.01]; posterior probability that the DNA slope is lower, 0.935; Fig. 1B). Specimen records were intermediate (0.66 [0.38–0.95]). The difference was supported in 24 of 27 sensitivity analyses and inconclusive in the remaining three (Table S2).

### Overdispersion sets a floor on detecting declines

Annual record counts of individual species were strongly overdispersed. For 382 mammal species with reported populations, a negative binomial model with species and year effects gave a shape parameter φ = 0.69 (0.66–0.71), implying a coefficient of variation above one. Overdispersion declined only modestly with recording intensity: φ was 0.46 for species with fewer than one record per year and 0.88 for species with more than 1,000 (Table S4). Invertebrate groups were more overdispersed still (φ = 0.06–0.8).

With this variability, the preregistered simulations showed that detecting a 30% decline over ten years (power 0.8, one-sided α = 0.05) using negative binomial regression with an effort offset, the most favourable of the three methods compared, took 43–44 years in every group once species were recorded more than about five times per year (Fig. 2A, Fig. S2). This floor did not shorten with more records. A 50% decline took about 28 years. Species with an expected record rate below 0.3 per year could not be detected as declining within 100 years.

The preregistered mapping of these results onto body size, which combined the scaling relationship with log-normal species abundance distributions, found that no species in any size class of the ten groups would be detectable within 25 years. This formally met the preregistered criterion for H3 but did not demonstrate a size gradient, because detection failed at all sizes; I report H3 as not substantively supported.

To reveal how detectability varies across all described species, I compared each species' observed record rate (2015–2024) with the detection thresholds, treating described species without records as having a rate of zero (exploratory). Using each group's own overdispersion, the share of described species whose decline would remain undetectable for a century fell steadily with body size (Fig. 2B): 95–97% of nematode, mite and copepod species, 92% of springtails, 76% of ants, 42–49% of jellyfish and mesopelagic fishes, from 54% of the smallest to 5% of the largest mammals, and fewer than 1% of birds.

Aggregating records into the number of occupied 1° grid cells per species and year, a coarse analogue of occupancy indices, reduced overdispersion 2.5- to 40-fold and shortened detection times for frequently recorded species (for mammals with ≥10 records per year, from 44 to 26 years; Fig. S3). Species with fewer than one record per year remained undetectable under either index. Pooling 100 species into a single indicator shortened detection to 10–15 years, although this assumes independent fluctuations among species.

### Common shortcuts produce spurious trends

In simulations without any decline, relative reporting rates analysed with binomial models flagged significant declines in 31–33% of series, because they ignore overdispersion; raw record counts flagged significant increases in up to 33% of series when recording effort grew. The effort-offset model held its nominal error rate (5–9%; Table S5).

### Consequences for undescribed species and global indicators

The same observation process predicts how many species should never have been recorded. Combining the scaling relationship with literature estimates of total species richness [@chapman2009; @appeltans2012; @oberski2025], the predicted share of species never recorded within 25 years was 91% for nematodes, 88% for mites, 75% for springtails and 43% for scyphozoan jellyfish (exploratory; Fig. 3A). These predictions ranked groups in the same order as published estimates of the undescribed share, but fell below them, as expected if being recorded is necessary but not sufficient for a species to be described.

Finally, all 11,067 populations in the public Living Planet Database [@lpd2016] belong to vertebrates, and the represented species are strongly skewed toward large body size. The median mass of mammal species with Living Planet populations was 105 times that of mammals overall (720 times when weighted by number of populations); for birds the factors were 3 and 12 (Fig. 3B).

## Discussion

Across small animals, from nematodes to small fishes, the unevenness of biodiversity records followed a simple rule: records per individual rose roughly with projected area. This suggests that much of the taxonomic bias in occurrence data, often attributed to societal preference [@troudet2017], is the expected outcome of an observation process limited by what can be seen. The precision of the exponent does not allow optical scaling to be distinguished from a 3/4 law or from exponents predicted by search geometry [@pawar2012], but it does exclude a steep dependence on size within this range.

Vertebrates broke this rule. Mammals with survey-based abundance estimates received four to five orders of magnitude more records than their size predicts. Dedicated recording infrastructures, from bird atlases to photo-identification catalogues, and the much larger number of people who record charismatic animals, are likely causes. The weak size gradient within mammals, consistent with modest body-size effects within birds in citizen-science data [@callaghan2021sr; @stoudt2022], indicates that the premium is attached to vertebrates as a group. The comparison extrapolates the invertebrate relationship by four to eight orders of magnitude, and independent species-level censuses do not exist for birds or fishes; even at the lower end of the extrapolation interval, however, mammals receive more than ten times the expected number of records.

The second finding concerns what records can be used for. The year-to-year variability of record counts, which I quantified across groups for the first time, does not diminish for common species. It therefore sets a floor of about four decades on detecting a decline of 30% per decade, the magnitude used to list species as Vulnerable under IUCN criterion A [@iucn2012], no matter how many records accumulate. This extends earlier demonstrations that opportunistic data yield biased or weak trends [@isaac2014; @kamp2016] by showing how the limit is distributed across life: the small, rarely recorded species that make up most described animal diversity are, in practice, invisible to record-based trend detection.

Structured approaches can raise this floor for well-recorded species. Occupancy-detection models using repeat visits have recovered trends for many British invertebrates [@outhwaite2020; @vanstrien2013], and my coarse occupancy index shortened detection times for frequently recorded species. Neither approach can help species recorded less than once a year, which make up most described invertebrates in every group examined. For these, structured surveys or DNA-based monitoring, whose records were less size-biased here and whose signal scales with organism biomass [@yates2021], are likely the only route to information about trends.

The same bias propagates into what we know and how we summarise it. The predicted share of never-recorded species tracked the share of undescribed species, complementing evidence that the fraction of species observed in a group grows with the number of individuals sampled [@callaghan2023] and that range size and taxonomic effort shape description [@collen2004; @costello2015]. Global indicators such as the Living Planet Index are built from populations of large vertebrates [@mcrae2017; @ledger2023], a size skew also reported nationally [@currie2022]. Because declines are least detectable in exactly the organisms that indicators omit, an absence of detected decline in records should not be read as stability.

This study has limitations. The main analysis rests on ten groups because few global abundance estimates are independent of occurrence data or allometry. A record is not an individual, and weighting records by reported individual counts weakened the fit (R² = 0.70). The detection simulations use count models with one overdispersion value per stratum and do not implement full occupancy-detection models. The vertebrate comparison is restricted to mammals, and the Living Planet analysis used the 2016 public release.

These results suggest three practical conclusions. Trends inferred from opportunistic records should be reported together with the detection power they afford. Monitoring of small organisms needs structured or molecular designs rather than more unstructured records. And biodiversity indicators should state what share of species, individuals and biomass they represent, so that the absence of detected decline is not mistaken for evidence of stability.

## Materials and Methods

Full methods, data sources and all sensitivity analyses are given in the *SI Appendix*. Hypotheses, models, priors, decision criteria, exclusion rules and sensitivity analyses were preregistered in a version-controlled repository before any records-per-individual value was computed (PREREG v1.0, commit 01a2fe7, 3 November 2026); subsequent changes were only appended with dates and reasons. Analyses not in the plan are labelled exploratory.

**Census data.** I compiled global abundance (N) and biomass (B) estimates for animal groups and classified each estimate as independent (extrapolated from field samples or survey-based population models), occurrence-derived, allometry-derived or mixed. Only independent estimates entered the main analysis. Biomass was converted to wet mass using the factors of each source, or a carbon-to-wet-mass ratio of 0.15 [@baron2018], and typical individual mass was M = B/N. For groups whose abundance in ref. [@baron2018] is biomass divided by an assumed individual mass, biomass was realigned to the same subgroup and the assumed mass entered the model as an observation. Census uncertainties were converted to log-normal standard deviations; where none was reported, a fold uncertainty of 10 was assumed (varied in sensitivity analyses).

**Occurrence records.** All records in the GBIF snapshot of 1 November 2026 [@gbif2026] (3.75 × 10⁹ records) were aggregated by taxon, year, basis of record and dataset, excluding absences and fossils. Records were classed as human observations, preserved specimens, or DNA-derived (records from datasets carrying the GBIF DNA-derived data extension). Census groups were matched to GBIF taxa by explicit rules (Table S1), and species names were resolved to accepted names in the Catalogue of Life eXtended Release.

**Scaling model.** For each group g and record type k, ln R_gk ~ Normal(ln N_g + a_k + b_k(ln M_g − c), √(τ_k² + 1/R_gk)), with latent ln N_g and ln M_g informed by the census observations and their uncertainties. The model was fitted in Stan [@stan2017] via cmdstanr [@gabry_cmdstanr] with priors b ~ N(0, 2), a ~ N(−25, 10) and τ ~ Half-Normal(0, 2) (four chains, R̂ ≤ 1.01, ESS > 990). Species-level mammal models were Poisson–log-normal with order effects, with census uncertainty and residual variation combined into a single normal term.

**Detection simulations.** Annual counts were simulated as y_t ~ NegBin(λ₀E_te^(−dt), φ) for 36 values of λ₀ between 10⁻² and 10⁵, with E_t the observed effort trajectory of each group and d corresponding to a 30% decline per decade. Each series was analysed by negative binomial regression with an effort offset, a binomial model of relative reporting rate, and negative binomial regression on raw counts. The time to detection was the shortest monitoring period with power ≥ 0.8 over 1,000 replicates, located by bisection. φ was estimated with brms [@burkner2017] from species × year counts.

**Software and data.** Analyses used R [@rcore2026] with targets [@landau2021] and arrow [@arrow_r]; all figures and tables are produced by code. Code, the preregistration and derived data will be deposited in a public repository on acceptance; GBIF data will be cited through a derived-dataset DOI.

## Acknowledgments

Analyses and drafting were assisted by Claude (Anthropic), an AI system, under the author's direction; the author designed the study, made all analytical decisions and takes responsibility for the content.

## Author contributions

H.D. designed research, performed research, analyzed data and wrote the paper.

## Competing interests

The author declares no competing interest.

## Figure legends

**Fig. 1. Records per individual across animal groups.** (*A*) GBIF records (2000–2024) per individual against typical body mass. Black: ten groups with census abundances independent of occurrence data (posterior medians and 95% CrI); line and band, fitted relationship (β = 0.72); dashed, slope 2/3 through the fitted centre. Red open symbols (not fitted): birds and land mammals with occurrence- or allometry-derived censuses, and prokaryotes (DNA records only). Blue: individual mammal species with survey-based (dark) or reported (light) population sizes (exploratory). (*B*) Posterior distributions of the scaling exponent by record type; dashed line, 2/3.

**Fig. 2. Detecting declines from occurrence records.** (*A*) Years required to detect a 30% (black) or 50% (grey) decline per decade with power 0.8, against the expected number of records per species and year, for negative binomial regression with an effort offset (constant effort, φ = 0.69). Steps reaching the top denote declines undetectable within 100 years. (*B*) Share of described species whose 30% decline per decade would remain undetectable within 100 years, based on observed record rates (2015–2024; exploratory). Triangles, invertebrate and small marine groups, using each group's own overdispersion; circles, mammal and bird species binned by body mass (circle area, number of species).

**Fig. 3. Consequences of the observation bias (exploratory).** (*A*) Predicted share of species never recorded within 25 (black) or 250 (grey) years, against body mass, and literature estimates of the undescribed share (×). (*B*) Share of mammal and bird species with at least one population in the public Living Planet Database (2016 release), by body mass.

## References
