# Review of "Body size governs how often animals are recorded and how long their declines stay hidden"

**Reviewer 2.** Expertise: biodiversity informatics, GBIF data structure and data quality.

**Material reviewed:** `manuscript/main.md`, `manuscript/si.md`, `PREREG.md`, the GBIF aggregation and matching code (`R/gbif.R`, `R/gbif_summary.R`, `R/gbif_cells.R`, `R/tierA.R`, `R/phase4.R`, `R/phase5.R`, `scripts/phase2_*`, `_targets.R`), derived outputs (`data/derived/*.csv`, `gbif_taxon_year.parquet`, `gbif_dataset_year.parquet`, `tierA_gbif_species_year.parquet`, `data/raw/gbif_api/dataset_classes.csv`), `models/*.csv`, `sim/*.csv` and `reports/phase2.md`.

During the review the repository history was rewritten. Commit `40d8e93` no longer resolves; the same "Manuscript v1" commit now appears as `2803228`, and HEAD has moved to `c3cebbe` (README, LICENSE, bibliography). The preregistration commit `01a2fe7` still resolves. All reviewer checks below are read-only:
- aggregations of the project's parquet files
- GBIF API facet queries on 3 November 2026
- refits of the project's own Tier B Stan model in a temporary directory, with modified record counts

The GBIF API uses the default GBIF checklist, whereas the snapshot uses COL XR, so API counts differ slightly from snapshot counts. Numbers I derived this way are marked "approx.".

---

## Summary

The author aggregates the full GBIF monthly snapshot of 1 November 2026 by taxon, year, basis of record and dataset class. Records from 2000–2024 are then matched to ten animal groups that have census abundances independent of occurrence data. The study estimates how records per individual scale with body mass (β = 0.72), compares record types, and claims that DNA-derived records are less size-biased. It then uses species × year record counts to estimate overdispersion and simulate how long declines take to detect, finding a floor of about 40 years. Exploratory analyses extend the work to mammals with survey-based censuses, to all described species (Fig. 2B), to never-recorded species and to the Living Planet Database.

My review covers the GBIF side: what the record counts represent, how they were classified, and whether they are fit for the inferences drawn.

## Overall assessment

The data engineering is competent and in several respects exemplary:
- The whole snapshot was aggregated reproducibly from the AWS Parquet files.
- Absences were correctly excluded. For copepods alone, about 0.78 million absence records from 2000–2024 would otherwise have been counted.
- The author caught that MATERIAL_SAMPLE is not a DNA proxy (KRILLBASE).
- Matching rules are explicit.
- Tables are code-generated, and every group-level record count I checked reproduced exactly.

I also found, somewhat to my surprise, that the headline exponent is fairly robust to the GBIF-side problems I identify. In my approximate refits, β for all records stayed between 0.66 and 0.75 under each of these changes:
- dropping the top one or top three datasets per group
- collapsing KRILLBASE to net hauls
- removing non-soil mites
- removing marine and vertebrate-parasitic nematodes
- extending mesopelagic fishes to 15 families

That robustness is worth reporting.

However, several conclusions rest on readings of GBIF records that the data structure does not support:

1. **"Records" are not comparable units across groups or datasets.** Depending on the dataset, one record is:
   - one measured krill
   - one taxon in one plankton sample
   - one amplicon sequence variant (ASV) in one Malaise-trap sample, apparently duplicated across two lab protocols
   - one telemetry fix

   A few programmes generate most records in most groups.
2. **The DNA class is mainly specimen barcoding.** For the larger-bodied groups it is mostly BOLD/iBOL barcodes of physical specimens, and for the smaller groups it is mostly three or four metabarcoding datasets. The H4 contrast does not survive splitting these sources apart.
3. **The basis-of-record categories do not correspond to the detection mechanisms invoked.** For most groups, HUMAN_OBSERVATION means laboratory identification of bulk soil, benthos or plankton samples, not a field observer seeing an animal. The optical (projected-area) interpretation in the title, abstract and Discussion is therefore not supported by the data structure, however well the exponent matches 2/3.
4. **The effort trajectories and recent-year rates are shaped by publication lag and dataset ingestion.** Krill "effort" falls 270-fold because one compilation ends in 2016.
5. **Preregistered taxonomic-scope sensitivity analyses were not run, and this is not disclosed.** Several group definitions include large non-target components, such as honeybee *Varroa* in "soil mites".
6. **Data citation is unfinished.** The current aggregation cannot produce the required derived-dataset citation for six of the ten groups.

These problems can all be fixed, and most fixes are re-aggregations the pipeline can already perform. Together they change what the paper can claim about mechanism (optical detectability), about DNA records, and about effort.

---

## Major comments

### 1. A "record" means very different things across the datasets that drive each group (records ≠ individuals ≠ events)

The response variable R is a count of GBIF occurrence rows. The paper interprets it as detection events, and in places as observations of individuals. Within the ten groups, the unit of a row varies by orders of magnitude.

- **Krill.** 84.8% of *Euphausia superba* records from 2000–2024 (81,213 of 95,798) come from one dataset, the KRILLBASE length-frequency database. It publishes **one record per individually measured krill**: 613,487 krill from 6,470 net hauls over 1926–2016, with individualCount = 1, sex and maturity stage on each row. A haul-level count would reduce krill R about 6-fold. This also bears on independence. The Atkinson et al. (2009) census was built from KRILLBASE net-haul densities, and the GBIF records come mainly from KRILLBASE's length-frequency companion. Records and census therefore derive from overlapping survey programmes.
- **Copepods, pteropods.** These are dominated by sampling-event plankton surveys with one record per taxon per sample: the CPR Survey, the ICES Zooplankton Community dataset and the Southern Ocean CPR (details in comment 2). The mean individualCount of copepod specimen records is 163.
- **Springtails and mites.** Insect Biome Atlas (IBA) datasets publish **ASVs × sample**, so one species in one Malaise-trap sample can produce several rows. The Swedish "mild lysis" dataset (f74fe28c…) and "homogenized" dataset (bdda4bec…) appear, from their titles and the IBA protocol, to be the same samples processed twice. Together they contribute about 305k springtail records.
- **Metabarcoding records of higher taxa.** Most DNA records in the soil groups are OTUs or ASVs assigned only to order or phylum:
  - Records identified to species: 23% of nematode records, 30% of enchytraeid, 52% of mite and springtail.
  - Among DNA records only: 13% for nematodes, 8% for enchytraeids, 17% for mites.
- **Mammals with survey-based censuses.** 62% of 2000–2024 records of the census-independent mammals are MACHINE_OBSERVATION, which here means telemetry fixes and acoustic detections (see comment 7).
- **individualCount.** Its meaning varies too:
  - mean per counted record of about 4,600 for ant human observations
  - about 1,000 for scyphozoan human observations
  - exactly 1 for KRILLBASE
  - an abundance per sample for CPR
  - about 2,450 for bacterial DNA records, which suggests sequence read counts

  S3, "individualCount weighting" (R² = 0.70), therefore cannot be read as a correction to individuals. organismQuantity and organismQuantityType are ignored.

**Requested:**
- (a) Add an SI table giving, for each group, the record unit of the top five datasets.
- (b) Add an event-based response: the number of distinct sampling events per group, using eventID or date × coordinates × dataset, and species × event for species-level analyses. Refit Tier B with it.
- (c) Collapse KRILLBASE to hauls, IBA to sample × species (with one lab protocol only), and telemetry to individual × day.
- (d) Audit individualCount and organismQuantity per dataset: drop read counts, cap extreme values, and either justify S3 or remove it.
- (e) Rephrase "records per individual" throughout as a property of the data-publication process, not of observation.

My approximate refits suggest β changes little, from 0.73 to 0.67 with haul-level krill. Much of the downstream interpretation does change, however, including φ, effort and the vertebrate exemplars.

### 2. A handful of datasets generate most records in most groups

The manuscript reports no dataset-concentration diagnostics. The code computes them only for groups defined at class rank or above, because `gbif_dataset_year.parquet` lacks order, family and species. My checks (2000–2024):

| Group | Largest datasets (share of group R) |
|---|---|
| Krill | KRILLBASE-length frequency 84.8% |
| Copepods | The CPR Survey 22.3%; ICES Zooplankton Community 14.8%; SO-CPR 9.0%; Australian Microbiome 18S aquatic 7.1% (top 4 ≈ 53%) |
| Springtails | iBOL 24.1%; IBA Sweden mild-lysis 22.6%; IBA Madagascar 11.7% (top 3 = 58%) |
| Ants | AntWeb 22.6%; iNaturalist 17.2%; iBOL 14.0% (top 3 ≈ 54%) |
| Mites | AMU Poznań Natural History Collections ≥27% (322k of 448k Mesostigmata records, plus Sarcoptiformes); iBOL 15%; STOWA Limnodata Neerlandica 9% |
| Enchytraeids | "Global soil organisms" (metabarcoding) 36% |
| Myctophids | Myctobase 21%; CalCOFI larvae and egg tows 14% |
| Pteropods | SO-CPR 26% |
| Jellyfish | iNaturalist 24%; Observation.org 15% |
| Nematodes | Global soil organisms 17%; GUYASOILeDNA 6%; Australian Microbiome terrestrial 6% |

Single projects also create the annual "effort" structure. Springtail records jump from 23k in 2018 to 417k in 2019 because of IBA, and JEDI plankton imaging adds 77k copepod records in 2015.

My approximate refits of the all-records slope gave β = 0.68 [0.37, 0.99] after removing the largest dataset per group and 0.66 [0.38, 0.97] after removing the top three, against 0.73 [0.43, 1.03] for the same single-type refit with the full data. This reassures me about β. It also shows that, in practice, the cross-group "observation process" consists of perhaps 20–30 programmes.

**Requested:**
- (a) Re-aggregate with datasetkey at every rank used in the group rules, plus species for Tier A and Fig. 2B. This is also needed for the citation (comment 9).
- (b) Add an SI table of the top five datasets per group with title, dataset type (OCCURRENCE or SAMPLING_EVENT), share, temporal coverage and record unit.
- (c) Report leave-one-dataset-out and leave-top-three-out sensitivity analyses for β and the DNA contrast.
- (d) Discuss explicitly that for 5 of the 10 groups, three or fewer datasets supply ≥40% of R.

### 3. Basis of record does not identify the detection mechanism, so the optical interpretation is unsupported

The central mechanistic claim is that records per individual track projected area, "an observer limited by the visible size of organisms". The H1/H2 framing and the title depend on it. For most of the ten groups the records are not visual encounters:

- Records labelled HUMAN_OBSERVATION are mostly laboratory identifications of bulk samples:
  - Nematodes: the largest contributors are UK statutory marine benthic surveys (DASSH; the UK Archive for Marine Species and Habitats Data) and French freshwater hydrobiology (SEEE).
  - Copepods: plankton time series (MareChiara, Strait of Georgia, IMOS NRS).
  - Sarcoptiformes: soil-core surveys (Edaphobase, Alterra).
- Human observations are only 11–38% of R for the soil and plankton groups (springtails 12%, krill 11%, copepods 15%, nematodes 19%, pteropods 19%, enchytraeids 26%, myctophids 35%, mites 36%, ants 38%). Jellyfish (82%) are the exception.
- The remainder is museum digitisation, plankton nets, Malaise traps and metabarcoding. In each case the probability of a record depends on the sampling device and the digitisation backlog, not on visual size.
- The purest visual-encounter subset available, iNaturalist only (S11b), gave β = 0.66 [0.17, 1.18], R² = 0.49 and "H1 not confirmed". Where the optical mechanism should apply most directly, the scaling is weakest.

**Requested:**
- (a) Classify datasets, or records via samplingProtocol and dataset type, into visual encounter, bulk-sample identification, trap, specimen collection and DNA. Report β within each class, at least for visual encounter versus bulk sample.
- (b) Present the agreement with 2/3 as a descriptive coincidence unless (a) supports it. Revise the title, abstract ("as projected area predicts"), Significance Statement and the first Discussion paragraph accordingly.
- (c) In the Discussion, explain that much of R for small animals measures how many samples a few survey and collection programmes have digitised and published.

### 4. The DNA record type is mostly specimen barcoding plus a few metabarcoding datasets, and H4 does not survive separating them

DNA is assigned at dataset level: every record of a dataset with any DNA-derived extension record is DNA. In aggregate this misclassifies little: 289 datasets, of whose records 97% carry the extension; 19 datasets have <50%, totalling 2.1M records with 12.5k extension records. The real problem is what the class contains (2000–2024, approx.):

| Group | Composition of "DNA" records |
|---|---|
| Ants | 92% iBOL (BOLD specimen barcodes) |
| Krill | ≈100% iBOL (552 of 553) |
| Mesopelagic fish | 62% iBOL |
| Pteropods | 49% iBOL |
| Mites | 65% iBOL + 28% IBA Malaise-trap metabarcoding |
| Springtails | 38% iBOL + 60% IBA |
| Copepods | 67% one dataset (Australian Microbiome 18S, aquatic) |
| Nematodes | 40% Global soil organisms; 8% EUKARYOME (a reference sequence database); 8% iBOL |
| Enchytraeids | 82% Global soil organisms |

There are further inconsistencies:
- "INSDC Sequences" (GenBank-derived; e.g. 55k ant and 84k mite records) and "INSDC Host Organism Sequences" (17k nematode records representing hosts of other sequenced organisms) are classed as non-DNA and counted as specimen or other.
- EUKARYOME, a secondary reference compilation that probably overlaps INSDC, is classed as DNA.
- The same physical specimen can enter three types: a Centre for Biodiversity Genomics PRESERVED_SPECIMEN record, an iBOL MATERIAL_SAMPLE record with DNA, and an INSDC record.
- GBIF's record-level `isSequenced` share is higher than the dataset-level DNA share: springtails 70% vs 64%, nematodes 49% vs 42%, mites about 34% vs 23%.

**My approximate refits** (the project's `tierB_eiv.stan`, types all/human/DNA; iBOL and IBA counts from the API subtracted from snapshot DNA counts):

| DNA definition | β_DNA | P(β_DNA < β_human) |
|---|---|---|
| Original, 10 groups | 0.50 [0.20, 0.80] | 0.92 |
| Original, krill dropped | 0.59 [0.25, 0.89] | 0.88 |
| iBOL specimen barcodes only, krill dropped | 0.70 [0.29, 1.11] | 0.68 |
| DNA excluding iBOL, krill dropped | 0.53 [0.28, 0.77] | 0.95 |
| Original minus 2 eDNA datasets (Australian Microbiome aquatic; Global soil organisms), krill dropped | 0.63 [0.27, 0.98] | 0.80 |

Krill had to be dropped because without iBOL it has one DNA record. Its leave-one-out result (0.898) is already "inconclusive" in Table S2.

Specimen barcodes therefore scale like specimens (0.66) and human observations (0.75). The flatter DNA slope comes from a few 18S and CO1 metabarcoding datasets targeting soil and plankton, and it disappears when two of them are removed. The Discussion's appeal to eDNA concentration scaling with biomass (Yates et al. 2021) does not apply to barcode counts. S14 ("strict DNA" = MATERIAL_SAMPLE ∧ extension) cannot detect this, because iBOL records are MATERIAL_SAMPLE.

**Requested:**
- (a) Classify DNA at record level, using the DNA-derived extension per record or `isSequenced` in a SQL or simple download.
- (b) Split DNA into specimen barcoding (BOLD/iBOL, institutional barcode datasets), bulk or eDNA metabarcoding, and sequence-repository mirrors (INSDC, EUKARYOME), and exclude or separately report the mirrors.
- (c) Deduplicate specimen and sequence pairs using GBIF clusters.
- (d) Refit H4 per subtype with leave-one-DNA-dataset-out analyses.
- (e) Report H4 as conditional on a handful of metabarcoding datasets, and remove or qualify "DNA-based monitoring … less size-biased" in the Abstract, Results and Discussion.

### 5. Taxonomic scope: group rules include large non-target components, and preregistered scope sensitivity analyses were not run

PREREG §7 S6 specified two scope variants: a nematode variant "excluding parasitic families" and an extended mesopelagic family list. S5 also listed Rosenberg springtails and S15 an undescribed-species correction. `reports/phase4.md` states these were not run "because sources were not finalised". The manuscript does not disclose this. Instead it states that robustness held across 24 analyses that "varied … taxonomic matching rules", and the SI's list of deviations omits it.

My checks (2000–2024 records):

- **Nematoda (whole phylum) as soil nematodes.**
  - 14% of records are in marine-dominated orders: Enoplida, Chromadorida, Desmodorida, Araeolaimida, Desmoscolecida.
  - 11% are in vertebrate-parasitic families: Trichostrongylidae, Onchocercidae, Anisakidae, Heteroxynematidae and others.
  - 23.5% are placed only at phylum rank, mostly metabarcoding and sequence records.
  - 15.7k come from an aquatic eDNA dataset (Australian Microbiome 18S, aquatic).
  - The human-observation nematode records come largely from marine and freshwater benthic surveys.
- **"Soil mites" (Sarcoptiformes, Mesostigmata, Trombidiformes).** About 40% of R is non-soil:
  - *Varroa destructor* alone has 175,018 records (13.3% of mite R), 99.4% from a single dataset (AMU Poznań). *V. jacobsoni* adds 35,225.
  - Water-mite families (Arrenuridae, Pionidae, Hydrachnidae, Hygrobatidae, Limnesiidae, Unionicolidae, Lebertiidae) contribute ≥165k, including 114k from Dutch freshwater monitoring (STOWA Limnodata).
  - The plant gall mites Eriophyidae contribute 132k.
  - The plant-inhabiting Tetranychidae and Phytoseiidae contribute about 31k.
  - In addition, the described-species denominator for mites (29,017; Acariformes + Parasitiformes) includes ticks, which the record rule excludes.
- **Mesopelagic fishes = Myctophidae only.** The Irigoien et al. acoustic estimate covers all mesopelagic fishes. Records of 15 mesopelagic families total 246k, against 128k for Myctophidae alone; this list includes Sternoptychidae, Stomiidae, Bathylagidae, Paralepididae and Gonostomatidae (the latter with *Cyclothone*, numerically the dominant genus). In addition, 14% of myctophid records are CalCOFI egg and larva tows.
- **Jellyfish.** Records include Scyphozoa and Cubozoa, but the described-species denominator in Table S10a and Table S8 is 244 (Scyphozoa only). The numerator includes 28 recorded cubozoan species. With S = 297, the "undetectable" share rises from 49% to about 58% (approx.).
- **Copepods.** For copepods the scope problem is small: by genus, about 4% of records are freshwater and 0.5% parasitic. COL XR, however, assigns no order to 99.6% of copepod records in the snapshot, so order-based filters are impossible without an external classification such as WoRMS.

In approximate refits, removing non-soil mites gave β = 0.74, removing marine and vertebrate-parasitic nematodes 0.74, and adding the 15 mesopelagic families 0.75. These problems therefore probably do not overturn β. They do affect group-level statements: Fig. 2B shares, Table S8, the mite and nematode DNA points, and the claims about "soil nematodes" and "soil mites".

**Requested:**
- (a) Run and report the preregistered S6 variants and S5b, or list them as unperformed deviations.
- (b) Use habitat attributes (WoRMS isMarine, isFreshwater, isTerrestrial) and coordinates. The 1° aggregation already has coordinates, so restricting nematodes, enchytraeids and mites to terrestrial points is a small step.
- (c) Exclude *Varroa*, water mites, Eriophyoidea and other plant-inhabiting families from "soil mites", or report the sensitivity.
- (d) Align described-species denominators with the record rules (Scyphozoa + Cubozoa; Acari without Ixodida).
- (e) Give COL XR taxon identifiers and the checklist key (7ddf754f-…) in Table S1.

### 6. Effort trajectories and recent record rates reflect publication lag and dataset coverage, not effort

The effort trajectory is E_t = (group total records in year t)/(records in 2000), held at its 2024 value after year 25. The H3 mapping weight is w_g = E_2024/ΣE_t. Ratios of 2024 records to the 2015–2019 mean:

| Group | 2024 / 2015–19 mean |
|---|---|
| Krill | 0.13 |
| Mesopelagic fish | 0.15 |
| Copepods | 0.22 |
| Enchytraeids | 0.28 |
| Pteropods | 0.28 |
| Nematodes | 0.38 |
| Springtails | 0.47 |
| Mites | 0.49 |
| Ants | 1.57 |
| Jellyfish | 3.46 |

The declines follow publication schedules, not effort:
- The CPR Survey has no records after 2020.
- The ICES zooplankton dataset has none after 2023.
- Global soil organisms has none after 2020.
- KRILLBASE ends in 2016, so krill "effort" in 2024 is 0.4% of its 2000 level and w_krill is about 60 times smaller than 1/25.

Groups fed by citizen science (ants, jellyfish) instead grow. Consequences:
- (i) Fig. S2 and Table S5 use these E_t. In particular the method (c) false-decline rate of 29.7% at 50 years is partly a lag artefact.
- (ii) The H3 mapping underestimates λ for survey-fed groups (copepods about 3-fold, krill about 60-fold). This pushes towards the "nothing detectable" null that was reported.
- (iii) Using the group total as the effort offset absorbs any group-wide change, which is unrealistic as a "known effort" benchmark.

The 2015–2024 species record rates used in Fig. 2B are less affected than I expected. Using 2010–2019 instead changes the undetectable shares by at most 1.8 points (ants 76.0 → 74.2%, copepods 94.7 → 93.3%, mites 95.6 → 94.9%, springtails 92.2 → 91.0%, nematodes 96.5 → 96.1%), because never-recorded species dominate the denominators. This robustness should be stated.

**Requested:**
- (a) Quantify lag per group, for example by comparing year totals between earlier snapshots and this one, or using dataset publication and modification dates. Truncate or flag incomplete years.
- (b) Build effort from proxies less tied to single datasets: the number of sampling events, datasets or recorders, or records of a broad reference taxon set in the same datasets.
- (c) Rerun Fig. S2, Table S5 and the H3 mapping with lag-corrected E_t, and with E_t at the 2015–2019 mean.
- (d) Describe E_t in the text as a publication trajectory.

### 7. Vertebrate comparison: telemetry, photo-identification and a duplicated species

Of the 2000–2024 records of the census-independent mammals, 62% are MACHINE_OBSERVATION. For 12 of the 51 species the share exceeds 50%. Examples:

| Species | Records | MACHINE_OBSERVATION share |
|---|---|---|
| *Mirounga leonina* | 999k | 89% |
| *Balaenoptera acutorostrata* | — | 92% |
| *B. physalus* | — | 85% |
| *Arctocephalus gazella* | — | 93% |
| *Trichechus manatus* | — | 81% |

The humpback example ("seven records per individual") is 40% Happywhale North Pacific photo-identification and 14% a Southern Ocean tracking compilation. The median species residual changes only by about 0.03 log10 when machine observations are removed, so the "3.8 orders of magnitude" result is robust. The text should still say this, and the exemplars should be chosen accordingly.

Two further problems:
- *Loxodonta africana* appears twice in the 52 "census_independent" rows: once as the Great Elephant Census and once as the AED estimate of *L. africana* s.l. Both map to the same GBIF name, so the set contains 51 species, not "52 species", in the main text and Table S7. The two censuses also have partial spatial coverage (18 countries; 62% of range), while R is continent-wide.
- LIVING_SPECIMEN records (captive animals; 124k mammal records in 2000–2024) are not excluded.

**Overdispersion.** Excluding MACHINE_OBSERVATION raises the mammal φ from 0.72 to 0.83 (my negative-binomial GLM fit with species and year fixed effects; brms gave 0.69 for all records). The 1° cell index raises φ 2.5- to 40-fold. Both results indicate that much of the year-to-year overdispersion comes from clumped publication: a tagging study, a single project-year, or one dataset's first upload. It does not reflect variability in "recording" as such.

**Requested:**
- (a) Exclude telemetry and acoustic datasets, or collapse them to individual × day.
- (b) Exclude LIVING_SPECIMEN records and captive establishmentMeans.
- (c) Correct the species count.
- (d) Estimate φ with a dataset (or dataset × year) random effect, or from counts of datasets or events per species-year, and show how T_detect responds.

### 8. Duplicates across datasets

GBIF's isInCluster flag (2000–2024, API) gives an upper bound on cross-dataset duplication:

| Taxon | isInCluster share |
|---|---|
| Ants | 14.3% |
| Copepods | 8.2% |
| Pteropods | 7.8% |
| Myctophids | 6.7% |
| Springtails | 6.3% |
| Enchytraeids | 5.3% |
| Sarcoptiformes | 5.2% |
| Krill | 3.2% |
| Nematodes | 1.9% |
| Scyphozoa | 1.7% |
| Humpback | 0.6% |

Clusters also link specimens to their sequences. Such duplication changes ln R by at most about 0.15 and so barely moves β. It matters for the type split (comment 4). Duplication outside GBIF clustering also exists: IBA protocol duplicates, EUKARYOME versus INSDC, and potentially iBOL versus BOLD-derived INSDC records.

**Requested:** deduplicate using GBIF clusters, keeping a primary record per cluster with a stated preference order (specimen > material sample > sequence). Remove the identified protocol duplicates and secondary compilations, and report the effect on R by group and type.

### 9. Data citation, scale claims and reproducibility

- **Scale of the analysis.** The Abstract and Introduction say the author "divide[s] 3.75 billion GBIF records by global census abundances". The main analysis uses 8.45 million records (0.23% of the snapshot), and the Tier A analyses add mammal and bird records. 3.75 × 10⁹ is the snapshot after excluding about 137 million absence records. The DOI 10.15468/dl.jeesns resolves to 3,887,364,403 records from 91,006 datasets (COL XR checklist, CC BY-NC 4.0). The Phase 2 report attributes the 3.89 vs 3.75 × 10⁹ difference to timing, but it is the absence exclusion. Please state both numbers and say how many records enter each analysis.
- **Derived-dataset citation.** It is still "[to register before submission]". GBIF requires a derived dataset that lists each contributing dataset with the number of records used. The current dataset-level aggregate has only kingdom to class, so contributing datasets cannot be determined for mites, ants, enchytraeids, pteropods, myctophids, krill or the Tier A species. Re-aggregate with datasetkey at the needed ranks (comment 2) and register before resubmission. Given their influence, cite the dominant datasets individually in the SI: KRILLBASE, CPR, ICES, IBA, Global soil organisms, AntWeb, AMU, iBOL, Myctobase, Happywhale and the tracking compilations.
- **Reproducibility.**
  - `gbif_taxon_year.parquet` (739 MB), `gbif_dataset_year.parquet` and `tierA_gbif_species_year.parquet` (16 MB) are git-ignored. Tier A, φ, Fig. 2B and Table S10 therefore cannot be reproduced without re-reading the snapshot. Deposit species × year × dataset × basis-of-record counts for the analysed taxa, a few tens of MB, in a persistent archive such as Zenodo.
  - The dataset classes come from the live API (91,008 datasets, retrieved 3 November), not from the snapshot (91,006). Archive the file and state the date.
  - Tag a release with a DOI, since commit hashes cited in the manuscript have already changed once.
- **BOLD counts.** They were obtained (SI "BOLD") but are not used in any reported result. Either report the preregistered BOLD secondary analysis or remove the statement.

---

## Minor comments

1. **Overdispersion range.** The main text gives invertebrate φ as "0.06–0.8". Table S4c reaches 1.25 (jellyfish, ≥10 records/yr). "Invertebrate groups were more overdispersed still" is also not true for that stratum.
2. **Name resolution accepts EXACT matches only.** Gender-agreement variants are therefore lost, although they carry many records in the snapshot (2000–2024 counts):

   | Census name | COL XR name in snapshot | Records |
   |---|---|---|
   | *Blarina brevicauda* | *B. brevicaudus* | 22,863 |
   | *Leopardus jacobita* | *L. jacobitus* | — |
   | *Zaglossus bruijnii* | *Z. bruijni* | — |

   Exact matches can also capture only part of a census concept when COL XR splits taxa: *Leopardus colocola* vs *L. pajeros*, *braccatus*, *garleppi* and *munoai*; *L. tigrinus* vs *L. guttulus* and *pardinoides*. Accept VARIANT matches after review, and map split concepts to their segregates. This affects Table S10b (zero-λ species) more than Table S3.
3. **Checklist dependence.** Group totals differ between the snapshot (COL XR) and API queries on the GBIF checklist (copepods 2.42 vs 2.58 million, +6.6%). State that group membership is checklist-specific.
4. **Fossil exclusion.** The text says the 3.75 × 10⁹ figure excludes "absences and fossils". It excludes absences only; the 10.3 million fossil specimens are dropped later.
5. **Krill MATERIAL_SAMPLE share.** "87% of Antarctic krill records" is the all-years share; within 2000–2024 it is 85%. Add that these are records of individual measured animals.
6. **Records without a year.** 266,787 nematode records (27% of all-time) and 151,039 copepod records lack a year. They enter only S1; mention this.
7. **Basis-of-record categories in "all".** OCCURRENCE, OBSERVATION, MATERIAL_CITATION and LIVING_SPECIMEN enter "all" but no type. Say so; for mammals OCCURRENCE alone is 2.5 million records.
8. **Low species-level identification.** Fig. 2B relies on species-level records only. For nematodes (23% identified to species) and enchytraeids (30%), most records, including most DNA records, cannot contribute to λ. Note this, and that DNA records assigned to species by reference matching may carry misidentifications.
9. **Occupancy index.** The 1° cell index uses raw coordinates. Apply GBIF geospatial issue flags (zero coordinates, country or centroid mismatches) and a coordinate-uncertainty cap. Note that the many taxa of one metabarcoding sample share a single coordinate.
10. **Life stages.** Records include eggs and larvae (CalCOFI ichthyoplankton) and juvenile stages. State whether census N refers to the same stages.
11. **Krill row in Table S10a.** With S = 1 this row adds no information; consider dropping it.
12. **Positive point.** Absence handling is correct: for copepods, 0.78 million absence records were excluded. Conflicts between individualCount and occurrenceStatus are negligible (≤8 records per group). This deserves a sentence in the SI, because naive counts from sampling-event data are a common error.
13. **iNaturalist records with DNA extension.** 78k iNaturalist records carry the DNA-derived extension but are classed as human observations. This is fine, but state it.

---

## Numbers checked

| Manuscript statement | Source checked | Result |
|---|---|---|
| Table S1 R 2000–2024: nematodes 416,187; springtails 1,241,382; mites 1,315,602; ants 2,509,986; enchytraeids 87,719; copepods 2,421,706; pteropods 63,888; jellyfish 173,734; myctophids 127,567; krill 95,798 | `gbif_taxon_year.parquet`, `gbif_dataset_year.parquet`, `tar_read(tb_R)` | All reproduced exactly (fossils excluded) |
| "records … ranged from 6.4 × 10⁴ (pteropods) to 2.5 × 10⁶ (ants)" | as above | Correct |
| "3.75 × 10⁹ records" in snapshot | sum of `gbif_dataset_year.parquet`; GBIF download metadata | 3,750,353,035 after excluding absences; the snapshot itself has 3,887,364,403 records. The main analysis uses 8,453,569 |
| β = 0.72 [0.49, 0.94], R² = 0.90; β_DNA 0.51 [0.24, 0.79] vs β_human 0.75 [0.48, 1.01]; P = 0.935 | `models/tierB_summary.csv`, `tierB_h4.csv`; reviewer refit | Match outputs; my refit with three types gives β_DNA 0.50 [0.20, 0.80], P = 0.924 |
| Table S10a undetectable shares (ants 76.0%, copepods 94.7%, mites 95.6%, nematodes 96.5%, springtails 92.2%) and recorded 2015–2024 counts | recomputed from parquet with λ threshold 0.79 | Reproduced exactly |
| Table S10a jellyfish 49.2% | recomputed | Reproduced with S = 244, but the denominator omits Cubozoa (≈58% with S = 297) |
| Table S8 recorded 2000–2024 (ants 9,503; springtails 2,530; mites 6,767; nematodes 4,203; copepods 3,435; jellyfish 194) | recomputed | Reproduced exactly |
| Humpback "about seven records per individual" | `sim/explore_vertebrates_species.csv` | 402,971 / 57,969 = 6.95, correct (40% photo-ID, 17% machine observation) |
| "52 species" with survey-based censuses | same file | 52 rows but 51 species (*L. africana* entered twice) |
| φ = 0.69 (mammals) | reviewer negative-binomial GLM fit | 0.72 (consistent, given brms priors); 0.83 without MACHINE_OBSERVATION |
| "87% of krill records" MATERIAL_SAMPLE | `records_diagnostics.csv` | 87.1% all years (85.2% in 2000–2024) |
| Invertebrate φ "0.06–0.8" | Table S4c | Inconsistent: up to 1.25 (jellyfish ≥10) |

---

## Recommendation

**Major revision.**

The headline scaling exponent appears robust to the GBIF-specific problems I examined, and the code base makes the required re-analyses feasible. Four elements need substantial rework before the conclusions are supported:
- the mechanistic (optical) interpretation
- the DNA contrast (H4)
- the effort trajectories
- several group-level statements (scope, denominators, vertebrate exemplars, species count)

The unreported preregistered sensitivity analyses must be run or disclosed, and the GBIF derived-dataset citation must be completed.
