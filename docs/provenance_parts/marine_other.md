# marine_other — provenance notes (Phase 1)

担当: krill, mesozooplankton, fish (marine), mesopelagic fish, gelatinous zooplankton, Hatton et al. 2021 size spectrum, prokaryotes/cyanobacteria (as N).
All quotes below are copied verbatim from the source (PDF text extraction / XML / publisher abstract). Retrieval date: 2026-11-03.

---

## 1. Antarctic krill — Atkinson et al. 2009

- Citation: Atkinson A, Siegel V, Pakhomov EA, Jessopp MJ, Loeb V (2009) A re-appraisal of the total biomass and annual production of Antarctic krill. *Deep-Sea Research I* 56:727–740. doi:10.1016/j.dsr.2008.12.007
  - Note: the task brief named it "MEPS"; the paper is actually in Deep-Sea Research I.
- URL used: https://www.iced.ac.uk/documents/Atkinson%20et%20al,%20Deep%20Sea%20Research%20I,%202009.pdf (author copy of the journal version, "ARTICLE IN PRESS" header, same pagination)
- File: `data/raw/atkinson2009/Atkinson_et_al_DSR1_2009.pdf`

Quotes:
- Abstract: "Net-based databases of density and length frequency (KRILLBASE) yield a summer distributional range of 19 × 10^6 km2 and a mean total abundance of 8 × 10^14 post-larvae with biomass of 379 million tonnes (Mt). These values are based on a standardised net sampling method but they average over the period 1926–2004, during which krill abundance has fluctuated."
- Abstract: "Thus the CCAMLR 2000 survey area contains 28% of the total stock, with total biomass of 133 Mt in January–February 2000."
- Sect. 3.2: "Overall, we derive a total krill abundance of 7.8 × 10^14 krill, based on standardised densities (Table 3). ... By stratifying on a finer, 2° × 6° grid (Fig. 2b) density is slightly higher: 8 × 10^14 krill. ... If the densities in these are replaced with dummy values of 36 krill m−2 (the mean from all 4338 oceanic stations) the total abundance is reduced to 5.4 × 10^14 krill."
- Sect. 3.3: "We combined the total abundance value, Ntotal, of 7.8 × 10^14 krill with a mean wet mass of 0.486 g krill−1 using Eq. (11) to derive a total circumpolar biomass of 379 Mt."
- Table 4 (title): "A variety of methods for estimating total biomass (fresh mass) of krill in the Southern Ocean using a combination of acoustics and net-based methods." Rows: 117 Mt ("Unadjusted net sampling estimates yield an Ntotal of 2.4 × 10^14 krill"), 379 Mt (standardised, Ntotal 7.8 × 10^14), 133 Mt (CCAMLR 2000 acoustic 37.3 × 10^6 t divided by 0.28).

method_class: **independent**. Scientific net hauls (KRILLBASE) and an acoustic survey; mass from length–mass regressions of the krill themselves. Body size is used only to turn N into B, not to predict density. The N "range" (5.4–8 × 10^14) comes from sensitivity runs, not a statistical CI.
Newer CCAMLR-based estimates: only regional (Area 48) survey estimates seem to exist; I did not retrieve or verify any → 未確認.

## 2. Mesozooplankton — Moriarty & O'Brien 2013 (MAREDAT)

- Citation: Moriarty R, O'Brien TD (2013) Distribution of mesozooplankton biomass in the global ocean. *Earth Syst. Sci. Data* 5:45–55. doi:10.5194/essd-5-45-2013
- URL: https://essd.copernicus.org/articles/5/45/2013/essd-5-45-2013.pdf ; file `data/raw/moriarty2013/essd-5-45-2013.pdf`
- Abstract: "A total of 153 163 biomass values were collected, from a variety of sources, for mesozooplankton. ... Global epipelagic mesozooplankton biomass, to a depth of 200 m, had a mean of 5.9 µg C L−1, median of 2.7 µg C L−1 and a standard deviation of 10.6 µg C L−1. The global annual average estimate of mesozooplankton in the top 200 m, based on the median value, was 0.19 Pg C."
- Sect. 3.3: "calculated by multiplying the median mesozooplankton biomass value (2.7 µg C L−1 = 2700 µg C m−3) × the area of the global ocean (3.56 × 10^14 m2) × the upper 200 m surface layer (200 m) × 1 × 10−21 µg Pg−1, which gave a value of 0.19 Pg C."
- method_class: **independent** (net samples). No uncertainty on the total and no N. Copepods are not separated. The PANGAEA dataset (doi:10.1594/PANGAEA.785501) was not downloaded.

## 3. Hatton et al. 2021 — global ocean size spectrum

- Citation: Hatton IA, Heneghan RF, Bar-On YM, Galbraith ED (2021) The global ocean size spectrum from bacteria to whales. *Sci. Adv.* 7:eabh3732. doi:10.1126/sciadv.abh3732 (PMC8580314)
- Full text: Europe PMC XML `data/raw/hatton2021/PMC8580314_fulltext.xml`. Table 1 is only an image in the XML, so I read the numbers from the authors' code/data archive on Zenodo (doi:10.5281/zenodo.5520055), file `data/raw/hatton2021/sheldon_revisited-master.zip` → `output/summary_output/summary_tables/summary_biomass_table.csv` (full depth) and `summary_biomass_table_top200.csv`.
- Table 1 caption: "Estimated pristine ocean biomass (wet weight; 1 Gt =10^15 g) are compared across major groups for the epipelagic (top 200 m) and full depth to the seafloor. ... Fold uncertainty is a multiplicative 95% CI on biomass."
- Data sources (Materials and Methods): "Bacteria abundance data were obtained from >47,000 sample measurements deriving from three sources ... Phytoplankton biomass across all groups were derived from sea surface temperature and satellite chlorophyll a measurements ... Zooplankton biomass across all groups except nanozooplankton derive from a total of >200,000 biomass samples aggregated from four sources, most notably COPEPOD and MAREDAT ... Fish biomass was estimated from two data-constrained global ecosystem models [BiOeconomic mArine Trophic Size-spectrum model (BOATS) (39) and FishErIes Size and functional TYpe model (FEISTY) (40)]."
- "For our estimates of fish (which includes true fish, cephalopods, and benthic invertebrates), we relied on two spatially resolved marine ecosystem models that predict fish biomass from environmental parameters ... the models were each run without fishing and forced with preindustrial environmental inputs from an Earth system model (CESM-BGC1) for the decade 1850–1860."
- Code comment (fish_mammals_other_biomass_estimate.R): "# Global mesopelagic fish biomass range from Proud et al., 2019 (doi:10.1093/icesjms/fsy037)" with `meso_fish_range <- c(1.8, 16) # Pg wet weight`. The point value 5.37 = √(1.8×16).
- Code comment (nano-microzoo script): "## Nanozoo biom estimate (from Bar-On and Milo, 2019)".

**Is Hatton allometry-based?** Each group's *biomass* comes from data or models (see below). *Abundance* (Fig. 1B) is made by spreading each group's biomass over its assumed body-size range and dividing by size-bin mass, so every N in Hatton depends on an assumed size distribution. The paper and code give N only as the total per size bin (`sensitivity_analysis/abundance_spectrum_ci/*.csv`, log10 values), not per group. So I left N blank for all Hatton rows. Per-group N could be computed from `summary_biomass_table_long.csv` (biomass per log10 size bin ÷ bin-midpoint mass), but that would be our own calculation and would bake in Hatton's size-range assumptions. If used, it should be classed as allometry-/assumption-derived.

method_class per group (for biomass):
- Heterotrophic bacteria; micro-, meso- and macrozooplankton: **independent** (GLMs fitted to field samples).
- Pico-, nano- and microphytoplankton: **independent** (satellite chlorophyll plus empirical conversions; no occurrence records). Model-heavy.
- Nanozooplankton: **unclear**. The value is taken from Bar-On & Milo 2019 and has not been traced to its origin.
- Mesopelagic fish: comes straight from Proud 2019 (acoustic) and **duplicates** the Proud row.
- Fish (+cephalopods + benthic invertebrates): **allometry-derived** (size-spectrum ecosystem models). It is also **pristine (c.1850), not present-day**.
- Marine mammals: left to the mammals agent and not entered here.

## 4. Mesopelagic fish — Irigoien et al. 2014

- Citation: Irigoien X, Klevjer TA, Røstad A, et al. (2014) Large mesopelagic fishes biomass and trophic efficiency in the open ocean. *Nat. Commun.* 5:3271. doi:10.1038/ncomms4271
- URL: https://www.nature.com/articles/ncomms4271.pdf ; file `data/raw/irigoien2014/ncomms4271.pdf`
- Abstract: "With a current estimate of ~1,000 million tons, mesopelagic fishes likely dominate the world total fishes biomass. ... the previous estimate needs to be revised to at least one order of magnitude higher."
- Results: "If we consider the range between 25 and 75% quartiles of the literature db/weight ratios as a reasonable representation of the mesopelagic fishes around the world, our estimates of mesopelagic fishes biomass would range from 6,000–200,000 million tons, with median values between 11,000 and 15,000 million tons (Table 1). These estimates of mesopelagic fishes biomass limited to 40° N and 40° S are one order of magnitude higher than the previous global estimate of 1,000 million tons."
- method_class: **independent** (ship acoustics; the conversion uses literature backscatter-to-weight ratios, not body-size-to-density allometry). There is no single point estimate, so B_est is blank. The estimate covers 40°N–40°S only.

## 5. Mesopelagic fish — Proud et al. 2019

- Citation: Proud R, Handegard NO, Kloser RJ, Cox MJ, Brierley AS (2019) *ICES J. Mar. Sci.* 76:718–733. doi:10.1093/icesjms/fsy037 (metadata checked via Crossref)
- URL: https://academic.oup.com/icesjms/article/76/3/718/5021437 (read via WebFetch; PDF not saved)
- Abstract: "Estimates of global mesopelagic fish biomass vary substantially (between 1 and 20 Gt)." ... "Our estimates of biomass ranged from 1.8 to 16 Gt (25–75% quartile ranges)" ... "median values of S1 to S3 were 3.8, 4.6, and 8.3 Gt, respectively."
- method_class: **independent** (global 38 kHz backscatter plus a modelled target strength from swimbladder size distributions). Uses body size inside the acoustic scattering model, but not a density-from-size allometry. Moderate confidence.

## 6. Marine fish — Bianchi et al. 2021

- Citation: Bianchi D, Carozza DA, Galbraith ED, Guiet J, DeVries T (2021) Estimating global biomass and biogeochemical cycling of marine fish with and without fishing. *Sci. Adv.* 7:eabd7554. doi:10.1126/sciadv.abd7554 (PMC8500507); file `data/raw/bianchi2021/PMC8500507_fulltext.xml`
- Abstract: "The pre-exploitation global biomass of exploited fish (10 g to 100 kg) was 3.3 ± 0.5 Gt ... By the 1990s, biomass and cycling rates had been reduced by nearly half".
- Intro: "the wide range of estimates of global fish biomass, mostly from numerical models, which range from less than 1 Gt to more than 50 Gt (Fig. 1A)."
- Results: "it suggests a preindustrial global biomass of consumers between 10 g and 100 kg of 3.3 ± 1.7 Gt over LME regions and 6.9 ± 3.6 Gt globally".
- Table 1 caption: "All values represent means from the optimized ensemble ..." Global Commercial preindustrial 3.3 ± 0.5; Total 6.9 ± 3.6; Peak catch Commercial 1.1 ± 0.2 (footnote: "Values determined at the time of the global peak catch integrated over LME regions in the model.").
- Units: the methods describe "units of wet biomass processed per unit area per unit time", so I read biomass as wet.
- The meaning of ± is not defined in what I read → interval type 未確認.
- method_class: **allometry-derived** (BOATS is a size-spectrum model, with parameters fitted to catch data).

## 7. Marine fish — Jennings et al. 2008

- Citation: Jennings S, Mélin F, Blanchard JL, Forster RM, Dulvy NK, Wilson RW (2008) *Proc. R. Soc. B* 275:1375–1383. doi:10.1098/rspb.2008.0192 (PMC2602712). Only the abstract was available (NCBI efetch).
- Abstract: "suggests that the global biomass of marine animals more than 10^−5 g wet weight is 2.62×10^9 t (=8.16 g m−2 ocean) ... Fish biomass and production, for example, are estimated as 8.99×10^8 t (2.80 g m−2) and 7.91×10^8 t yr−1".
- method_class: **allometry-derived** (macroecological size-spectrum theory driven by satellite primary production and temperature).

## 8. Gelatinous zooplankton — Lucas et al. 2014

- Citation: Lucas CH, Jones DOB, Hollyhead CJ, Condon RH, Duarte CM, Graham WM, Robinson KL, Pitt KA, Schildhauer M, Regetz J (2014) *Global Ecol. Biogeogr.* 23:701–714. doi:10.1111/geb.12169. Wiley full text returned 403; the abstract was read from the Crossref API (https://api.crossref.org/works/10.1111/geb.12169).
- Abstract: "a total of 91,765 quantitative abundance data items from 1934 to 2011 were converted to carbon biomass using published biometric equations and species-specific average sizes." ... "the global geometric mean and standard deviation of total gelatinous biomass is 0.53 ± 16.16 mg C m−3, corresponding to a global biomass of 38.3 Tg C in the mixed layer of the ocean".
- method_class: **independent** (survey abundance data; size is used only to turn N into C). Caveat: JeDI records may also be in OBIS/GBIF. No global N given.

## 9. Prokaryotes and cyanobacteria (N)

- Whitman WB, Coleman DC, Wiebe WJ (1998) *PNAS* 95:6578–6583. doi:10.1073/pnas.95.12.6578. Abstract (NCBI efetch, PMC33863): "The number of prokaryotes and the total amount of their cellular carbon on earth are estimated to be 4–6 × 10^30 cells and 350–550 Pg of C ... Most of the earth's prokaryotes occur in the open ocean, in soil, and in oceanic and terrestrial subsurfaces, where the numbers of cells are 1.2 × 10^29, 2.6 × 10^29, 3.5 × 10^30, and 0.25–2.5 × 10^30, respectively."
- Flemming HC, Wuertz S (2019) *Nat. Rev. Microbiol.* 17:247–260. doi:10.1038/s41579-019-0158-9. Abstract (nature.com): "Most bacteria and archaea on Earth (1.2 × 10^30 cells) exist in the 'big five' habitats: deep oceanic subsurface (4 × 10^29), upper oceanic sediment (5 × 10^28), deep continental subsurface (3 × 10^29), soil (3 × 10^29) and oceans (1 × 10^29)." The full text is paywalled, so its uncertainty ranges are 未確認.
- Flombaum P, Gallegos JL, Gordillo RA, et al. (2013) *PNAS* 110:9824–9829. doi:10.1073/pnas.1307701110. Abstract (PMC3683724): "These niche models ... rely on >35,000 discrete observations from all major ocean regions. ... The annual mean global abundances of Prochlorococcus and Synechococcus are 2.9 ± 0.1 × 10^27 and 7.0 ± 0.3 × 10^26 cells, respectively."
- method_class: **independent** for all three (extrapolated from field cell counts; no body-size allometry). Whitman's subsurface total is outdated.

## 10. Not found / 未確認

- Copepods as a separate group: no global N or B found. Moriarty & O'Brien and Hatton cover mesozooplankton as a whole.
- Global number of individual fish: no primary estimate found.
- Cephalopods: no primary global estimate found. A search hit attributes ~0.05 Gt C to Rodhouse & Nigmatullin via the Bar-On/Milo site; this was not verified, and Bar-On rows belong to the baron2018 agent. In Hatton, cephalopods are lumped into "fish".
- Marine nematodes / benthic meiofauna: no global N found in the search. The Bar-On 2018 supplement may have a marine nematode component; check with the baron2018 agent.
- Corals, other euphausiids, freshwater fish, amphibians: no global N or B found.
- Number of described species: not compiled. None of these sources states it (krill = 1 species by definition).

## Points for human decision

1. Hatton: should we derive per-group N from the size-bin biomass (assumption-derived), or leave Hatton as biomass only?
2. Hatton's fish and mammal values are pristine (1850). Should they be excluded from a present-day census?
3. Mesopelagic fish (Irigoien 6–200 Gt vs Proud 1.8–16 Gt): which one is primary? They are not independent of each other in Hatton.
4. Is Proud's acoustic target-strength modelling "independent" (my call) or "mixed"?
