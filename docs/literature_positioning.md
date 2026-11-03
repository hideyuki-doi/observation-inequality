# Literature positioning (prior-work check, 2026-11-03)

Agent: `litcheck`. Scope: the claims in `reports/summary.md` (claims 1–14) and `reports/results_draft_en.md`, target journal PNAS.

**Rules followed.** Every paper listed under "Papers" was found by search. Its DOI was resolved (Crossref or Europe PMC), and its abstract was read (Europe PMC, Crossref or DOAJ), unless a note says otherwise. Paraphrases describe the abstracts only: full texts were **not** read. Exact numbers quoted below are copied from the abstracts. Papers that exist but whose abstract I could not read are listed separately at the end. They must not be cited until someone has checked them.

Search tools: Europe PMC REST, the Crossref API, DOAJ and web search. pnas.org, science.org, Wiley and GBIF pages returned 403.

---

## A. Taxonomic and body-size bias in occurrence data relative to richness or abundance

### Papers

1. **Troudet J, Grandcolas P, Blin A, Vignes-Lebbe R, Legendre F (2017).** Taxonomic bias in biodiversity data and societal preferences. *Scientific Reports* 7. doi:10.1038/s41598-017-09084-6
   They used 626 M GBIF occurrences across 24 classes and compared records with species counts. Societal preference (Bing web pages per species) correlated with taxonomic bias much more strongly than research activity (WoS papers) did. The baseline is *species richness*, not abundance or biomass, and body size is not modelled.
2. **Hughes AC, Orr MC, Ma K, Costello MJ et al. (2021).** Sampling biases shape our view of the natural world. *Ecography* 44. doi:10.1111/ecog.05926
   They analysed 742 M records of 374,900 species. "Over 50% of records in most groups account for under 2% of species", and citizen science "only exacerbates biases". The paper is mostly about spatial and ecotype bias, with a per-species taxonomic baseline.
3. **Callaghan CT, Poore AGB, Hofmann M, Roberts CJ, Pereira HM (2021).** Large-bodied birds are over-represented in unstructured citizen science data. *Scientific Reports* 11. doi:10.1038/s41598-021-98584-7
   They compared iNaturalist with eBird for US birds. Body size, commonness and flock size predict over-representation in iNaturalist, but colour does not. They describe detectability as two-fold: the bird must be detected *and* photographed. They recommend body size as a covariate for opportunistic records. This is within one class and relative to another citizen-science dataset, not to abundance.
4. **Stoudt S, Goldstein BR, de Valpine P (2022).** Identifying engaging bird species and traits with community science observations. *PNAS* 119. doi:10.1073/pnas.2110156119
   This is also iNaturalist against an eBird baseline (472 species). Body mass, colour contrast and range size predict over-reporting. **This is a PNAS precedent for "body size drives records", but within birds and relative to eBird.**
5. **Goldstein BR, Stoudt S, Lewthwaite JMM, Shirey V, Mendoza E, Guzman LM (2024).** Logistical and preference bias in participatory science butterfly data. *Frontiers in Ecology and the Environment* 22. doi:10.1002/fee.2783
   They compared iNaturalist with eButterfly for 194 species: 53 were over-reported and 34 under-reported. Ease of identification and "feature diversity" were associated with over-reporting. The abstract does not report a body-size effect.
6. **Forti LR, Szabo JK (2025).** Global community science data on mammals underreport small and diurnal species. *Environmental Monitoring and Assessment*. doi:10.1007/s10661-025-14654-7
   This used over 2 M iNaturalist mammal records. Large, crepuscular and widely distributed species are over-represented, while bats and rodents are under-represented. About 55% of mammal species are present. The baseline is species, not abundance.
7. **Titley MA, Snaddon JL, Turner EC (2017).** Scientific research on animal biodiversity is systematically biased towards vertebrates and temperate regions. *PLOS ONE* 12. doi:10.1371/journal.pone.0189577
   This covers *research* effort rather than occurrence records. I checked the bibliographic record only; the title states the finding. Cite only as background.
8. **Garcia-Rosello E, González-Dacosta J, Guisande C, Lobo JM (2023).** GBIF falls short of providing a representative picture of the global distribution of insects. *Systematic Entomology* 48. doi:10.1111/syen.12589
   This is about the spatial completeness of insect records: 34% of coarse cells have no data, and about 0.5% have completeness above 90%. It does not use an abundance baseline.

### Novelty gap (A)

The bias literature measures over- and under-representation against one of three baselines: **species counts** (Troudet; Hughes), **another citizen-science platform** (Callaghan 2021; Stoudt 2022; Goldstein 2024) or **trait covariates within one class** (Forti & Szabo). None of these papers normalises records by the **number of living individuals**, none spans phyla from nematodes to fishes and vertebrates, and none estimates a **scaling exponent** with census uncertainty propagated. Our "records per individual ∝ M^0.72" is, as far as I found, new.

A reviewer could say three things:
- "Body-size bias in citizen-science data is known." This is true within birds and mammals (Callaghan 2021; Stoudt 2022, which was published in PNAS; Forti & Szabo 2025).
- "Taxonomic bias in GBIF is known" (Troudet 2017, cited 350+ times per Europe PMC).
- "Societal preference, not detectability, explains it" (Troudet). Our framing that vertebrates sit about 5 orders of magnitude above the line because of interest answers this directly. We should cite Troudet as the preference explanation and present the optical 2/3 baseline as what separates the two.

## B. Scaling of detectability with body size

### Papers

1. **Johnston A, Newson SE, Risely K, Musgrove AJ, Massimino D et al. (2014).** Species traits explain variation in detectability of UK birds. *Bird Study* 61. doi:10.1080/00063657.2014.941787
   This used distance sampling for 195 UK species. "Smaller species had lower detectability than larger species." Diet and habitat specialisation also mattered. I read the abstract via the St Andrews repository page.
2. **Sólymos P, Matsuoka SM, Stralberg D, Barker NKS, Bayne EM (2018).** Phylogeny and species traits predict bird detectability. *Ecography* 41. doi:10.1111/ecog.03415
   This covers 141 boreal species. Detection distance "was mostly determined by anatomy (i.e. body size) and thus the laws of physics", while singing rate was more labile. This is acoustic detectability, not visual.
3. **Kiltie RA (2000).** Scaling of visual acuity with body size in mammals and birds. *Functional Ecology* 14. doi:10.1046/j.1365-2435.2000.00404.x
   Acuity scales roughly linearly with body size. The paper argues that detection distance for prey should scale with predator size with an exponent above 1. This is the closest physiological-optics scaling argument I found, but it concerns the *observer's* size, not the target's.
4. **Pawar S, Dell AI, Savage VM (2012).** Dimensionality of consumer search space drives trophic interaction strengths. *Nature* 486. doi:10.1038/nature11131
   Encounter and consumption rates scale with body mass, with exponents of about 0.85 in 2D and about 1.06 in 3D. The paper builds its theory partly from detection and search geometry. It is a template for deriving an encounter exponent from first principles, and a reviewer may ask why our 2/3 does not include the search-dimension term.
5. **Yates MC, Glaser DM, Post JR, Cristescu ME et al. (2021, online 2020).** The relationship between eDNA particle concentration and organism abundance in nature is strengthened by allometric scaling. *Molecular Ecology*. doi:10.1111/mec.15543
   eDNA production scales sub-linearly with mass. Allometrically scaled mass (Σ M^0.73) predicted eDNA concentration better than density or biomass did (adj. R² 0.78 vs 0.59 and 0.63). This is relevant to claim 5: DNA records scale less steeply than human observations.
6. Callaghan et al. 2021 (A3) also gives the two-step detect-then-photograph mechanism for body size.

### Novelty gap (B)

Body size predicting detectability is well established **within birds** (Johnston 2014; Sólymos 2018), and in optics and foraging theory (Kiltie 2000; Pawar 2012). I found **no study that tests the projected-area (M^2/3) prediction against records per individual across phyla**, and none that contrasts the slope for human observation with the slope for DNA-derived records.

The eDNA allometry result (Yates 2021; exponent < 1) offers a mechanistic reason for our shallower DNA slope and should be cited. A reviewer could say that 2/3 is one of several plausible exponents: Kiltie gives more than 1 for observer-scaled distance, and Pawar's 2D/3D search geometry could also apply. The 95% CI (0.49–0.94) cannot separate 2/3 from 3/4 (metabolic) or from search-geometry values, so we should say the result is "consistent with" 2/3 rather than claiming it tests the mechanism.

## C. Power and time to detect declines from opportunistic data, overdispersion and false trends

### Papers

1. **Isaac NJB, van Strien AJ, August TA, de Zeeuw MP, Roy DB (2014).** Statistics for citizen science: extracting signals of change from noisy ecological data. *Methods in Ecology and Evolution* 5. doi:10.1111/2041-210X.12254
   They simulated recorder-activity scenarios and measured Type I error and power for candidate methods. "Simple methods produce biased trend estimates, and/or had low power." They warn against simple methods. **This is the direct precedent for claim 11** (false trends from reporting rates and raw counts). We must cite it and show what we add: a global GBIF calibration, φ estimated empirically, and the link to body size.
2. **Isaac NJB, Pocock MJO (2015).** Bias and information in biological records. *Biological Journal of the Linnean Society* 115. doi:10.1111/bij.12532
   This is the conceptual framework: uneven effort, uneven detectability, presence-only data and the "information content" of records.
3. **van Strien AJ, Termaat T, Kalkman V, Prins M, De Knijf G et al. (2013).** Occupancy modelling as a new approach to assess supranational trends using opportunistic data. *Biodiversity and Conservation* 22. doi:10.1007/s10531-013-0436-1
   This is the occupancy-detection approach for opportunistic data, with a pilot for one damselfly.
4. **Outhwaite CL, Gregory RD, Chandler RE, Collen B, Isaac NJB (2020).** Complex long-term biodiversity change among invertebrates, bryophytes and lichens. *Nature Ecology & Evolution* 4. doi:10.1038/s41559-020-1111-z
   This used occupancy trends for more than 5,000 UK species from biological records. It shows that trends *can* be extracted for invertebrates when there is dense national recording with visit or list structure. A reviewer may cite it against our "undetectable for a century" claim, so we must stress the difference: we work with global GBIF records-per-year, not UK visit-level occupancy.
5. **Kamp J, Oppel S, Heldbjerg H, Nyegaard T, Donald PF (2016).** Unstructured citizen science data fail to detect long-term population declines of common birds in Denmark. *Diversity and Distributions* 22. doi:10.1111/ddi.12463
   This compared 103 species over 28 years. Less than half of the declines found by structured monitoring were recovered from unstructured data, and mismatches were especially common for *common* species. **This is empirical support for our "floor regardless of abundance" (claim 7)** and should be cited prominently.
6. **White ER (2019; online 2018).** Minimum time required to detect population trends: the need for long-term monitoring programs. *BioScience* 69. doi:10.1093/biosci/biy144
   I read the abstract of the PeerJ preprint (doi:10.7287/peerj.preprints.3168v4). For 822 vertebrate populations, 72% of time series needed at least 10 years for high power, with large variability between populations. This is the closest "time to detect" framing, but it uses structured abundance series, not opportunistic records.
7. **Wauchope HS, Johnston A, Amano T, Sutherland WJ (2018 preprint).** When can we trust population trends? Quantifying the effects of sampling interval and duration. bioRxiv doi:10.1101/498170
   They degraded 27,930 waterbird time series. Many years are needed before a non-significant trend can be trusted. I did not verify the published version, so cite the preprint or check first.
8. **Bowler DE, Callaghan CT, Bhandari N, Henle K, Benjamin Barth M et al. (2022).** Temporal trends in the spatial bias of species occurrence records. *Ecography*. doi:10.1111/ecog.06219
   Spatial bias in occurrence records changes over time, and simulations show that this can bias trend estimates. This is relevant to the effort-change false trends in claim 11.
9. **Lindén A, Mäntyniemi S (2011).** Using the negative binomial distribution to model overdispersion in ecological count data. *Ecology* 92. doi:10.1890/10-1831.1
   This is the methods reference for the NB overdispersion parameterisation.
10. **Johnston A, Matechou E, Dennis EB (2023; online 2022).** Outstanding challenges and future directions for biodiversity monitoring using citizen science data. *Methods in Ecology and Evolution*. doi:10.1111/2041-210X.13834
    This is a review. I read the first part of the abstract only.

### Novelty gap (C)

The simulation-based finding that naive methods give false trends and have low power is **not new**: Isaac et al. 2014 is the canonical reference, and Kamp et al. 2016 shows empirically that unstructured data miss declines even for common species. Our claim 11 (relative reporting rate gives about 31% false declines; raw counts give up to 33% false increases) is a confirmation, not a discovery, and should be framed that way.

What appears new:
- **(i)** An empirical, cross-taxon estimate of year-to-year overdispersion in GBIF record counts (φ ≈ 0.7 in mammals and 0.06–0.8 in invertebrates), and the fact that φ stays below 1 even above 1,000 records per year.
- **(ii)** The consequence: a **hard floor** on time to detection (about 44 years for −30% per decade) that more records cannot remove.
- **(iii)** Mapping undetectability onto body size across all of GBIF, from 94% of nematode species to under 1% of bird species.

A reviewer will say that occupancy and list-length methods with visit structure (van Strien 2013; Outhwaite 2020) do better than counts of records per year. We should state clearly that our floor applies to aggregated record counts with an effort offset. We should also either test an occupancy-type alternative or acknowledge it as an upper bound on pessimism. I found no paper that reports this floor.

## D. Predicting undescribed species from abundance, range or body size

### Papers

1. **Collen B, Purvis A, Gittleman JL (2004).** Biological correlates of description date in carnivores and primates. *Global Ecology and Biogeography* 13. doi:10.1111/j.1466-822X.2004.00121.x
   "Geographical range is by far the most important predictor." Body mass matters in carnivores once range is controlled, but not in primates.
2. **Diniz-Filho JAF, Bastos RP, Rangel TFLVB, Bini LM, Carvalho P et al. (2005).** Macroecological correlates and spatial patterns of anuran description dates in the Brazilian Cerrado. *Global Ecology and Biogeography* 14. doi:10.1111/j.1466-822X.2005.00165.x
   For 131 Cerrado anurans, description date correlated negatively with body size and range size (abstract truncated in the source).
3. **Costello MJ, Lane M, Wilson S, Houlding B (2015).** Factors influencing when species are first named and estimating global species richness. *Global Ecology and Conservation* 4. doi:10.1016/j.gecco.2015.07.001 (abstract read via DOAJ)
   This covers all fishes. 68% of the variation in year of description is explained by geography and depth, while "body size was a minor factor at just 6%". Undiscovered species will have small ranges "but will not necessarily be of smaller body size". **This is a counterpoint to any body-size story about description.**
4. **Moura MR, Jetz W (2021).** Shortfalls and opportunities in terrestrial vertebrate species discovery. *Nature Ecology & Evolution* 5. doi:10.1038/s41559-021-01411-5
   This is a time-to-event model of discovery for terrestrial vertebrates using biological, environmental and sociological predictors. It is the state-of-the-art species-level discovery model.
5. **Callaghan CT, Borda-de-Água L, van Klink R, Rozzi R, Pereira HM (2023).** Unveiling global species abundance distributions. *Nature Ecology & Evolution* 7. doi:10.1038/s41559-023-02173-y
   This used over 1 billion GBIF observations across 39 classes. "The fraction of species unveiled for each class decreases with the total number of species in that class and increases with the number of individuals sampled", and birds are fully unveiled. **This is conceptually the closest work to our claim 13.** It links the number of individuals sampled (records) to the fraction of species observed, per class, using GBIF.
6. **Anthony MA, Bender SF, van der Heijden MGA (2023).** Enumerating soil biodiversity. *PNAS* 120. doi:10.1073/pnas.2304663120
   They estimate that about 59% of species live in soil. This is a possible source for the literature values of total species counts in soil groups.

### Novelty gap (D)

Work on description date tests species-level traits (range, body size, abundance) *within* a clade. The robust finding is that range dominates and body size is weak (Collen 2004; Costello 2015). Our claim 13 works at a different level: it predicts the **fraction of a group never recorded** from an observation model (records per individual × abundance) and compares the ranking with the literature's undescribed fractions.

Callaghan et al. 2023 is the closest. They show that the fraction of each class's species abundance distribution that has been "unveiled" grows with individuals sampled in GBIF. A reviewer could say that "GBIF sampling depth predicts the unrecorded fraction by class" was already shown there. Our addition is mechanistic: the body-size observation law plus census abundance give an independent prediction that is then compared with taxonomic estimates. We should cite Callaghan 2023 explicitly and distinguish our work from it. Because claim 13 is exploratory and the literature totals are very uncertain, it is safer as a supporting result than a headline.

## E. Body-size and taxonomic bias in the Living Planet Index and similar indicators

### Papers

1. **McRae L, Deinet S, Freeman R (2017).** The Diversity-Weighted Living Planet Index: controlling for taxonomic bias in a global biodiversity indicator. *PLOS ONE* 12. doi:10.1371/journal.pone.0169156
   They reweighted by the estimated number of species per realm and taxon. The 1970–2012 decline was 58% weighted vs 20% unweighted. Taxonomic and geographic bias is acknowledged and corrected, but body size is not addressed.
2. **Currie J, Burant J, Marconi V, Blain S, Emry S et al. (2022).** Assessing the representation of species included within the Canadian Living Planet Index. *FACETS* 7. doi:10.1139/facets-2022-0063
   They compared body size, trophic level and lifespan between C-LPI species and Canadian vertebrates lacking data. Overlap was generally considerable, but **fishes in the C-LPI were larger-bodied and longer-lived**. **This is the direct precedent for claim 14, at national scale.** We need to cite it. Our claim is global, gives fold-differences by class and weights by population.
3. **Barnes MD, Craigie ID, Harrison LB, Geldmann J, Collen B et al. (2016).** Wildlife population trends in protected areas predicted by national socio-economic metrics and body size. *Nature Communications* 7. doi:10.1038/ncomms12747
   This used 1,902 LPD bird and mammal populations in protected areas. Trends were more positive for larger-bodied species. Together with our size bias, this implies that a large-biased index could be optimistic. This is an important interaction to note.
4. **Buschke FT, Hagan JG, Santini L, Coetzee BWT (2021).** Random population fluctuations bias the Living Planet Index. *Nature Ecology & Evolution* 5. doi:10.1038/s41559-021-01494-0
   Random fluctuations alone exaggerate the global LPI decline by 9.6%. This links to our overdispersion theme.
5. **Toszogyova A, Smyčka J, Storch D (2024).** Mathematical biases in the calculation of the Living Planet Index lead to overestimation of vertebrate population decline. *Nature Communications* 15. doi:10.1038/s41467-024-49070-x
6. **Leung B, Hargreaves AL, Greenberg DA, McGill B, Dornelas M, Freeman R (2020).** Clustered versus catastrophic global vertebrate declines. *Nature* 588. doi:10.1038/s41586-020-2920-6
   Bibliographic record checked; abstract not read in this session.
7. **Moussy C, Burfield IJ, Stephenson PJ, Newton AFE, Butchart SHM et al. (2022; online 2021).** A quantitative global review of species population monitoring. *Conservation Biology*. doi:10.1111/cobi.13721
   This reviews about 1,200 monitoring schemes. The number of schemes correlates with GDP, and 37% of schemes are volunteer-based.
8. **Ledger SEH, Loh J, Almond R, Böhm M, Clements CF et al. (2023).** Past, present, and future of the Living Planet Index. *npj Biodiversity* 2. doi:10.1038/s44185-023-00017-3

### Novelty gap (E)

The taxonomic bias of the LPI is known and partly corrected (McRae 2017). Statistical biases of the LPI are a hot topic (Buschke 2021; Toszogyova 2024), and a national, trait-based representativeness check exists (Currie 2022, which found larger-bodied fishes in the C-LPI). I did **not** find a global quantification of body-mass bias by class in the LPD, such as our 105× and 720× for mammals.

Linking this to a single observation law (records per individual ∝ M^0.7, giving size-biased data at every level) is the integrative contribution. A reviewer could say that size bias in monitoring "is expected and was shown nationally (Currie 2022)". Barnes 2016 should be used to argue why the bias matters for trend direction.

## F. Global biomass and abundance censuses used jointly with occurrence data

### Papers

1. **Bar-On YM, Phillips R, Milo R (2018).** The biomass distribution on Earth. *PNAS* 115. doi:10.1073/pnas.1711842115
2. **Greenspoon L, Krieger E, Sender R, Rosenberg Y, Bar-On YM et al. (2023).** The global biomass of wild mammals. *PNAS* 120. doi:10.1073/pnas.2204892120
   They compiled the abundance of several hundred species and built a model to infer the rest. This is the allometry-derived mammal census, which is the circularity noted in claim 4.
3. **Callaghan CT, Nakagawa S, Cornwell WK (2021).** Global abundance estimates for 9,700 bird species. *PNAS* 118. doi:10.1073/pnas.2023170118
   They integrated well-studied species with *global occurrence data* to estimate abundances, giving about 50 billion birds. **This is the occurrence-derived bird census, so using it to test records per individual is circular** (as our summary already notes).
4. **Rosenberg Y, Bar-On YM, Fromm A, Ostikar M, Shoshany A, Giz O, Milo R (2023).** The global biomass and number of terrestrial arthropods. *Science Advances* 9. doi:10.1126/sciadv.abq4049
   About 1 × 10^19 soil arthropods, about 95% of which are mites and springtails.
5. **Schultheiss P, Nooten SS, Wang R, Wong MKL, Brassard F, Guénard B (2022).** The abundance, biomass, and distribution of ants on Earth. *PNAS* 119. doi:10.1073/pnas.2201550119
   About 2 × 10^16 ants.
6. **van den Hoogen J, Geisen S, Routh D, Ferris H, Traunspurger W et al. (2019).** Soil nematode abundance and functional group composition at a global scale. *Nature* 572. doi:10.1038/s41586-019-1418-6
   About 4.4 × 10^20 nematodes.
7. **Callaghan et al. (2023)**, listed as D5, also uses GBIF observation counts as relative abundance.

### Novelty gap (F)

The censuses exist, and several were published in PNAS (Bar-On, Greenspoon, Schultheiss, Callaghan 2021). Callaghan 2021 goes the *other* way: it uses occurrences to estimate abundance, and so implicitly assumes that records scale with abundance within birds. I found **no paper that divides GBIF records by census abundance across groups** to obtain records per individual. This is the core novelty.

A PNAS-specific opportunity is to frame the work as the "observation counterpart" of the Bar-On and Milo census series. The circularity of the bird and mammal censuses (Callaghan 2021; Greenspoon 2023) will be the first reviewer objection to claim 4, which is already flagged in the summary.

---

## Highest-priority papers (closest prior work and possible threats)

| Priority | Paper | Why it matters |
|---|---|---|
| High | Callaghan et al. 2023 *Nat Ecol Evol* (D5) | GBIF individuals-sampled vs fraction of species observed, by class. Overlaps conceptually with claim 13 and touches records-vs-abundance. It does **not** estimate records per individual or a body-size exponent. |
| High | Isaac et al. 2014 *MEE* (C1) | Has already shown false trends and low power of simple methods on opportunistic data. Claim 11 is a confirmation of it. |
| High | Kamp et al. 2016 *Divers Distrib* (C5) | Unstructured data miss declines, even for common species. This supports the floor in claim 7 but means the qualitative point is not new. |
| Medium | Stoudt et al. 2022 *PNAS* (A4); Callaghan et al. 2021 *Sci Rep* (A3) | Body size drives over-representation in citizen-science birds. Our within-mammal β = 0.32 should be discussed against these. |
| Medium | Currie et al. 2022 *FACETS* (E2) | Body-size representativeness of a national LPI (larger fishes). This is a precedent for claim 14. |
| Medium | Troudet et al. 2017 *Sci Rep* (A1) | The canonical GBIF taxonomic-bias paper. Its preference explanation competes with the detectability explanation. |

**No paper I found does what we do**: normalising GBIF records by independent global census abundance across phyla, estimating a size-scaling exponent and testing it against an optical prediction.

## Exists, but abstract not read: check before citing

- Gaston KJ (1991). Body size and probability of description: the beetle fauna of Britain. *Ecological Entomology* 16. doi:10.1111/j.1365-2311.1991.tb00242.x
- Gaston KJ, Blackburn TM (1994). Are newly described bird species small-bodied? *Biodiversity Letters* 2. doi:10.2307/2999696
- Blackburn TM, Gaston KJ (1995). What determines the probability of discovering a species? A study of South American oscine passerine birds. *Journal of Biogeography* 22. doi:10.2307/2846069
  A web-search summary says range was the best predictor and that abundance effects disappeared once range was controlled. I have not verified this from the abstract.
- Gaston KJ, Blackburn TM, Loder N (1995). Which species are described first? The case of North American butterflies. *Biodiversity and Conservation* 4. doi:10.1007/BF00137780
- Telfer MG, Preston CD, Rothery P (2002). A general method for measuring relative change in range size from biological atlas data. *Biological Conservation* 107. doi:10.1016/S0006-3207(02)00050-2
- Szabo JK, Vesk PA, Baxter PWJ, Possingham HP (2010). Regional avian species declines estimated from volunteer-collected long-term data using List Length Analysis. *Ecological Applications* 20. doi:10.1890/09-0877
- Gerrodette T (1987). A power analysis for detecting trends. *Ecology* 68. doi:10.2307/1939220
  The abstract was read. This is the classic trend-power reference and is safe to cite.
