# richness — described vs. estimated total species (for Phase 6 H5)

担当: `richness`. Retrieval date: 2026-11-03. Schema differs from census parts on purpose (see `richness.csv`).
All quotes are copied verbatim from text extracted with `pdftotext -layout` (or from publisher/aggregator abstracts). For Chapman 2009 (an OCR'd PDF), the extracted text renders "~" as "-". I checked this against the rendered page image of PDF p29, so "~" is restored in the quotes below. "PDF pN" is the page index in the saved file; "printed pN" is the page number printed in the report (printed = PDF − 2).

**Derived values.** Where a source prints only "Described" and "Total Unknown" (Appeltans 2012 Table 2, sub-rows), the CSV's `estimated_*` holds my own arithmetic (described + unknown), flagged `derived_sum` with `verified = yes (components)`. The source does not print these sums. Ant totals (2–3 × ~14,000) are flagged the same way.

---

## 1. Chapman 2009 — candidate primary cross-taxon source

- Chapman AD (2009) *Numbers of Living Species in Australia and the World*, 2nd edn. Report for the Australian Biological Resources Study, Canberra, September 2009.
- URL used: https://www.vliz.be/imisdocs/publications/ocrd/234960.pdf (VLIZ copy of the government PDF; the original environment.gov.au / dcceew URL did not download).
- File: `data/raw/richness/chapman2009/vliz_234960.pdf` (84 pp.)
- Method: a compilation of literature and expert opinion. For each group Chapman gives "World Descr./Accepted min., max., Accepted, World Estimate". Estimates are mostly cited from other works, and for mammals the estimate is his own.

Quotes:
- **Mammalia** (PDF p15, printed p13): "For the purposes of this report, I have accepted the figure of 5,487 which accords well with the most recent figures from The IUCN Red List of Threatened Species ... Although I can find no estimate of the total estimated number of species of mammals, based on the recent rate of description of new species, I estimate that it would be a little over 5,500 species." Table: "4,300 | 5,487 | 5,487 | ~5,500".
- **Aves** (PDF p16, printed p14): "I have accepted the figure of 9,990 which is consistent with the most recent figures from BirdLife International (2008) and IUCN (2009b). Total number of species of birds on earth is estimated at around 10,000 (BirdLife International 2004, 2008), although if one accepts the figure of 9,990 already described, this figure would appear a little low." Table: "9,000 | 9,990 | 9,990 | >10,000".
- **Acarina** (PDF p28, printed p26): "Hickman et al. (2004) estimated 40,000 described species with a total of 500,000 to 1 million. Halliday et al. (2000) estimated that there were 48,200 described species of Acarina and a total fauna of about 0.5 million. Walter et al. (1996) on the Tree of Life website estimated 45,000 described species and suggested that that may only be about 5% of the total species alive today." Order table (PDF p29, printed p27, checked against the page image): "Acarina | 48,200 | ~100,000–500,000 | 2,851 | 20,000" (World Described | World Estimated | Australian Described | Australian Estimated).
- **Collembola** (PDF p35, printed p33): "Bellinger et al. (2009) state that there are about 7,900 described species in the world, however Greenslade (ABRS 2009a) suggests that this figure may include many synonyms. Janssens (pers. comm.), one of the managers of the Website Collembola.org (Bellinger et al. 2009), suggests a more conservative figure of c. 7,500. Hallan (2003) gives a figure of 6,000 species. Hopkin (1997) suggested the total number of species in the world is about 50,000." Table row: "Collembola ~7,500 50,000 279 ...".
- **Annelida** (PDF p37, printed p35): "The figures I have used are c. 8,432 polychaete species ...; 147 species of Pogonophora ...; 7,684 Oligochaeta from Blakemore (2008 and pers. comm.) and 500 Hirudinea ... making a total of 16,763." "An estimate for the total number of species is between 25,000 and 30,000 (Snelgrove et al. 1997 as reported by Ponder et al. 2002)." Table: "12,000 | 16,763 | 16,763 | 25,000-30,000".
- **Nematoda** (PDF p38, printed p36): "Estimates for the number of described species of Nematoda vary from around 12,000 (Myers 2001f, Hickman et al. 2004) through 20,000 (Hodda 2000), 20,000-25,000 (Groombridge and Jenkins 2002), fewer than 25,000 (Baldwin et al. 2000), 25,000 (Hawksworth and Kalin-Arroyo 1995, Brusca and Brusca 2003), over 80,000 of which over 15,000 are parasitic (Wikipedia). Bouchet (2006) accepted a figure of 12,000 for marine species based largely on Hugot et al. (2001). Estimates for the total numbers of species, however, are much larger, ranging from 400,000 (Hawksworth and Kalin-Arroyo 1995, Groombridge and Jenkins 2002) through about 500,000 (Myers 2001f, Hickman et al. 2004) to 500,000-1 million (Baldwin et al. 2000) and 'several times' their estimate of 25,000 (Brusca and Brusca 2003)." "They also provided references to estimates for the total number varying from 100,000 (Hawksworth and Kalin-Arroyo 1995) to as many as 10 million." Table: "12,000 | >80,000 | <25,000 | ~500,000".
- **Cnidaria** (PDF p41, printed p39): "I have accepted the figure of 9,795 as it appears to be the most thoroughly researched and reliable." Table: "9,000 | 11,000 | 9,795 | unknown".
- **Crustacea** (PDF p33, printed p31): "I have accepted a figure of approximately 47,000 described species based on the detailed breakdown given by Bouchet (2006) ... The estimated total number of world species is 150,000 (May 2000, Groombridge and Jenkins 2002) with a range of 75,000 to 200,000 (Hammond 1995, Hawksworth and Kalin-Arroyo 1995). Brusca and Brusca (2003) stated that there could be from 5-10 times the number of described species, giving a figure of 300,000-600,000 for their estimate." Copepoda is not separated.
- **Fishes** (PDF p19, printed p17): table "25,000 | 31,153 | 31,153 | ~40,000".
- **Formicidae**: Chapman's Hymenoptera table (PDF p26) gives Hymenoptera only ("115,000 ... >300,000"). It has no ant figure.

## 2. Appeltans et al. 2012 — marine groups (Copepoda, Scyphozoa, marine nematodes, oligochaetes, mites, fishes, mammals, birds)

- Appeltans W et al. (2012) The magnitude of global marine species diversity. *Curr Biol* 22:2189–2202. doi:10.1016/j.cub.2012.09.036
- File: `data/raw/richness/appeltans2012/worldfish_appeltans2012.pdf` (open copy in the WorldFish digital archive, journal pagination). cell.com and ScienceDirect returned 403, and the UHasselt and eScholarship copies returned HTML error pages.
- Method: expert opinion from 270 taxonomists (WoRMS editors), with a separate statistical model of the description time-series. Columns, verbatim from the legend: "number of currently described and taxonomically accepted species, percent of all nominal species names considered subjective synonyms (% Syn), undescribed species in specimen collections, unsampled and undiscovered morphospecies, undiscovered molecular cryptic species (only distinguishable by molecular methods), total species unknown (undescribed + undiscovered based on expert opinions), total species unknown based on the statistical model, total estimated number of species (expert-based), estimated percent of all existing species that are currently described (% known) ..." Symbols: "?, not estimated; -, no data; NB, no basis for judgment; **, rate of discovery still rising, so no meaningful estimate of total species numbers can be made using the statistical model."
- I checked the Table 2 rows below against the rendered page images (pp. 2194–2196). Column order: Total Known | Described | %Syn | Undescribed | Undiscovered (Morpho) | Undiscovered (Molecular Cryptic) | Total Unknown (Experts) | Total Unknown (Model) | Total Estimated | % Known | New spp. 1999–2008.
  - p2193 Oligochaeta: "910 | 30 | 300 | 5,000-15,000 | 600-1,600 | 5,900-16,900 | ** | [blank] | 5-13"
  - p2193 Acarina: "1,218 | - | 100 | 1,220-1,830 | 150-200 | 1,470-2,130 | - | [blank] | 36-45"
  - p2194 Copepoda: "10,000 | 17 | 1,500-2,000 | 28,500-48,000 | 125 | 30,125-50,125 | ** | [blank] | 17-25"
  - p2195 Pisces (incl. Agnatha): "16,733 | 16,733 | 49 | 500 | 4,200-4,300 | 200-300 | 4,900-5,100 | 6,700-10,700 | 21,633-21,833 | 77 | 1,577"
  - p2195 Mammalia: "135 | ... | 0-11 | 137-143 | 94-99 | 3"
  - p2195 Aves: "641 | 641 | - | 30-50 | 30-50 | 0 | 60-100 | 0-9 | 701-741 | 87-91 | 1"
  - p2195 Scyphozoa: "201 | 201 | 1 | 38-80 | 77 | 22-25 | 137-182 | - | 338-383 | 52-59"
  - p2196 Gastropoda: "32,000-40,000 | 69-75 | 35,000-45,000 | 50,000-60,000 | - | 85,000-105,000 | ** | [blank] | 23-32"
  - p2196 Nematoda: "11,400 | ... | - | 61,400 | 19 | 295"; "Nematoda, free-living | 6,900 | 9 | ? | 50,000 | NB | 50,000 | - | [blank] | 12"; "Nematoda, parasitic | 4,500 | - | ? | ? | - | - | - | [blank] | -"
- Caveat: these are marine-only values. For Copepoda this excludes freshwater species. For Oligochaeta and Acari the marine values are a small and unrepresentative part of the group. There is no Pteropoda row; Gastropoda is the nearest parent. There is no Myctophidae row.

## 3. Hodda 2022a,b — Nematoda, plus a compact multi-taxon table

- Hodda M (2022b) Phylum Nematoda: trends in species descriptions, the documentation of diversity, systematics, and the species concept. *Zootaxa* 5114:290–317. doi:10.11646/zootaxa.5114.1.2. File `data/raw/richness/hodda2022/zootaxa.5114.1.2.pdf`.
- Hodda M (2022a) Phylum Nematoda: a classification, catalogue and index of valid genera, with a census of valid species. *Zootaxa* 5114:1–289. doi:10.11646/zootaxa.5114.1.1. File `.../zootaxa.5114.1.1.pdf`.

Quotes:
- 2022b p290: "They are very diverse, with nearly 30,000 species described ... there are probably a much larger number undescribed: even the lowest estimates of total nematode species numbers start at half a million species, and the highest estimates are more than 10 million species (Hodda 2022a)."
- 2022b p292, Table 1 title: "Approximate numbers of new species described from 2011 to 2019 (inclusive) relative to numbers of described species and estimated total species numbers for selected animal groups. All numbers approximate and rounded to allow for uncertainty in any estimate of species numbers (Chapman 2009, May 1988)." Rows (Described spp | Estimated total number of spp):
  - "Annelida 20,000 30,000"
  - "Nematoda 29,000 500,000" (the footnote on the total says "Lowest estimate, see Hodda (2022a) and Hodda & Khudhir (2022) for discussion of higher estimates.")
  - "Acari 55,000 500,000"
  - "Mammalia 6,500 7,000"
  - Also in the table: Porifera 9,500/30,000; Araneae 44,000/100,000; Diptera 160,000/800,000; Amphibia 8,300/20,000.
- 2022b p292: "less than 0.1% of an estimated 500 000 to 1 million species (Hugot et al. 2001, Lambshead 1993)."
- 2022a p1: "The smallest estimate of total number of nematode species is half a million, while the largest is 20 times that—10 million species (Grassle 1989, Grassle & Maciolek 1992, Hodda 2022a, Hodda & Khudhir 2022, Hugot et al. 2001, Lambshead 1993, Lambshead & Boucher 2003, May 1988, Stork 1993)." Also: "Estimates of the proportion of nematode species known vary from much less than 1% to around 5%".
- 2022a p5: "The described species of Nematoda highly underestimates the estimated total number of species by a factor generally estimated at between 10 and 50, but which may be up to 3000, giving an estimated total number of species at between 500 000 and 10 000 000".
- 2022b p292 (text near Table 1, line ~310): free-living species are a minority of descriptions "but is vastly different to the estimated total number of species that really exist, where there are far more free-living species than other types (Hodda et al. 2009)". No number is given for this, so a soil or free-living total is 未確認.

## 4. Oberski et al. 2025 — Formicidae

- Oberski JT, Griebenow ZH, Adams RMM, Andersen AN, Andrade-Silva J, et al. (2025) Ant systematics: past, present, and future. *Insect Systematics and Diversity* 9(4). doi:10.1093/isd/ixaf025
- File: `data/raw/richness/oberski2025_ants/kit_1000185485.pdf` (KIT repository copy, https://publikationen.bibliothek.kit.edu/1000185485/167720847, 42 pp.)
- Abstract (PDF p2): "Since then, over 18,000 species-rank names have accumulated for the global myrmecofauna, of which ~14,260 living and ~810 fossil species are valid."
- Introduction (PDF p2): "They encompass over 14,000 valid species, although the actual diversity maybe 2 or 3 times higher (Ward 2014)".
- Concluding section (PDF p31): "More than 18,000 ant taxa have been described, of which >14,000 are valid (Bolton 2024), and it is inferred that 2 or 3 times more ant species inhabit the Earth (Ward 2014)."
- The CSV range of 28,000–42,000 is my arithmetic (2× and 3× of 14,000). The wording "2 or 3 times more" could also be read as 3–4×. The primary estimate (Ward 2014, *Annu Rev Ecol Evol Syst*) was not accessed.

## 5. Birds — Barrowclough et al. 2016

- Barrowclough GF, Cracraft J, Klicka J, Zink RM (2016) How many kinds of birds are there and why does it matter? *PLoS ONE* 11:e0166307. File `data/raw/richness/barrowclough2016/journal.pone.0166307.pdf`.
- Abstract (p1): "Using a sample of 200 species taken from a list of 9159 biological species determined primarily by morphological criteria, we applied a diagnostic, evolutionary species concept to a morphological and distributional data set that resulted in an estimate of 18,043 species of birds worldwide, with a 95% confidence interval of 15,845 to 20,470."
- Results (p4): "Given our sample of 200 exemplars from a universe of 9159 biological species, the ratio of 1.97 can be extrapolated to a total of 18043 phylogenetic species. ... Bootstrap re-sampling resulted in an empirical 95% confidence interval of 15845 to 20470 for the number of phylogenetic species of extant birds."
- Results (p6): "using the same number as for the morphology study (9159) yields an estimate of ca. 22,000 species. Bootstrap re-sampling resulted in an empirical 95% confidence interval of 20,452 to 24,216".
- Caveat for H5: this estimate comes from changing the species concept (phylogenetic vs. biological species), not from counting undiscovered species. It should not be mixed with the "undescribed" ratios for other groups without saying so.

## 6. Mammals — Burgin et al. 2018 (described only)

- Burgin CJ, Colella JP, Kahn PL, Upham NS (2018) How many species of mammals are there? *J Mammal* 99:1–14. doi:10.1093/jmammal/gyx147. The OUP PDF and full text were not accessible (WebFetch returned the abstract only), so the abstract was taken from OpenAlex: `data/raw/richness/burgin2018/openalex.json`.
- Abstract: "We found 6,495 species of currently recognized mammals (96 recently extinct, 6,399 extant), compared to 5,416 in MSW3 (75 extinct, 5,341 extant)—an increase of 1,079 species in about 13 years ... a long-term global rate of ~25 species recognized per year".
- No projected total appears in the abstract. A full-text projection, if one exists, is 未確認.

## 7. Pteropoda — Vidal-Miralles et al. 2024 (described only)

- *Mol Phylogenet Evol* 108183, doi:10.1016/j.ympev.2024.108183. The abstract comes from Europe PMC (`data/raw/richness/vidalmiralles2024_pteropoda/europepmc_core.json`). The UB repository PDF returned HTML.
- Abstract: "Through multilocus Sanger-based taxon sampling with 411 specimens (92 newly sequenced), representing nearly 100 species (out of 163 valid) from various oceans ... identifying cryptic species complexes across vast biogeographic areas".
- No estimate of the total number of pteropod species was found, so it is 未確認.

## 8. Context sources (no usable per-group values)

- **Mora et al. 2011** (*PLoS Biol* 9:e1001127; `data/raw/richness/mora2011/journal.pbio.1001127.pdf`). Table 2 (p5) gives kingdom level only: "Animalia 953,434 7,770,000 958,000 [Earth: Catalogued, Predicted, ±SE] 171,082 2,150,000 145,000 [Ocean]". The main text has no values for phyla or classes. Figure 2 validates the method on well-known taxa, but its values are not tabulated in the text. The supplementary files (s001–s004) were not opened.
- **Stork 2018** (*Annu Rev Entomol*; annualreviews.org returned 403; abstract only, via OpenAlex): "approximately 1.5 million, 5.5 million, and 7 million species of beetles, insects, and terrestrial arthropods, respectively ... With 1 million insect species named, this suggests that 80% remain to be discovered". Values for mites, springtails and ants are 未確認.
- **Larsen et al. 2017** (*Q Rev Biol*; closed access; abstract only): "Our estimates suggest that there are likely to be at least 1 to 6 billion species on Earth." Per-group values (mites, nematodes) are 未確認.

## 9. Not found / 未確認

- **Enchytraeidae**: the Schmelz & Collado checklists (2012; 2023 update in *Soil Organisms*) did not download (the server returned HTML). A web-search snippet said "676 species", but I did not verify it and it is not used. No estimate of total species was found.
- **Myctophidae / mesopelagic fishes**: no source giving described and estimated totals was accessed. Appeltans 2012 Pisces (marine) and Chapman 2009 Fishes are included only as proxies.
- **Soil-only or free-living Nematoda total**: not found. Hodda et al. 2009 and Hugot et al. 2001 were not accessed.
- **Not accessed**: Walter & Proctor; AntWiki/AntCat; Hortal; Bebber.

## 10. Notes for H5

- Primary proposal: **Chapman 2009** is the single consistent cross-taxon compilation. It covers Mammalia, Aves, Acari, Collembola, Nematoda, Annelida (proxy for Oligochaeta), Crustacea (proxy for Copepoda), Cnidaria (no estimate) and Fishes. It has no values for ants, pteropods, scyphozoans or myctophids.
- Sensitivity: use **Hodda 2022b Table 1**, which is newer and rounded (Nematoda, Acari, Annelida, Mammalia); **Appeltans 2012** for the marine groups (Copepoda, Scyphozoa, Pteropoda via Gastropoda, fishes); **Oberski 2025** for ants; and **Barrowclough 2016** for birds under a different species concept.
- Both Chapman and Hodda compile estimates from literature and expert judgement. They are not observation-independent statistical estimates, and several soil groups share the same root numbers. For example, Acari "~0.5 million" goes back to Halliday et al. 2000, and Nematoda "≥500,000" goes back to Hugot/Lambshead. Agreement between sources is therefore not independent confirmation.
