# references.bib — verification log

Built 2026-11-03 by agent `bib`. Nothing below was filled in from memory. Each entry was built from the source named in the table.

## How entries were built

* **DOI entries (47).** For each DOI I fetched `https://api.crossref.org/works/<DOI>` (JSON) and `https://doi.org/<DOI>` with `Accept: application/x-bibtex`. The entry fields come from the Crossref JSON: authors, title, container-title, volume, issue, page or article-number, and DOI. The year is `published-print` when Crossref has it, otherwise `issued`. Keys were replaced with the manuscript keys, and every entry type is `@article`. I compared each final entry with the doi.org BibTeX automatically. The only differences are the ones listed in the table, plus the article numbers (e.g. PNAS `e2110156119`, Nat Commun `674`). The doi.org BibTeX transform leaves those numbers out, but Crossref JSON `article-number` contains them.
* **Title handling.** Crossref markup was stripped: `<i>`, `<b>` and `<scp>`, `&amp;` became `\&`, and U+2010 hyphens became `-`. Proper nouns and acronyms are brace-protected (`{Earth}`, `{GBIF}`, `{Living Planet Index}`, `{R}`, …) because pandoc converts BibTeX titles to sentence case. Wording is otherwise unchanged.
* **Journal names.** Full names from Crossref. I did not add short-journal abbreviations because Crossref's `short-container-title` values are inconsistent (e.g. "Sci Rep" vs "Proc. Natl. Acad. Sci. U.S.A."). The PNAS CSL falls back to the full name.
* **Render test.** `pandoc 3.1.3 --citeproc --csl manuscript/pnas.csl` on all 55 keys (`nocite: @*`) gave no warnings.
* **`pnas.csl`.** Downloaded unchanged from https://raw.githubusercontent.com/citation-style-language/styles/master/pnas.csl on 2026-11-03. 8,390 bytes, sha256 `ab6da4e87c25d4c2fc49ac4dc6fa613215a9644d52b6d134845911e47e099afb`. The last upstream commit touching the file is `90d45fee1730d0047330a348245dde8b205e1fa6` (2024-03-27).

## Table

"Assumed" is the author/year/journal given in the task brief or implied by the key.

| key | verified | source of metadata | discrepancy vs assumed / notes |
|---|---|---|---|
| troudet2017 | yes | Crossref 10.1038/s41598-017-09084-6 | none (Sci Rep 7:9132) |
| hughes2021 | yes | Crossref 10.1111/ecog.05926 | none (Ecography 44:1259–1269) |
| callaghan2021sr | yes | Crossref 10.1038/s41598-021-98584-7 | none (Sci Rep 11:19073) |
| stoudt2022 | yes | Crossref 10.1073/pnas.2110156119 | none |
| pawar2012 | yes | Crossref 10.1038/nature11131; author fixed from PubMed 22722834 / Europe PMC | **Crossref (and the Nature meta tags) store the 3rd author as family = "Van M. Savage" with no given name.** Corrected to `Savage, Van M.` following PubMed ("Pawar S, Dell AI, Savage VM"). |
| yates2021 | yes | Crossref 10.1111/mec.15543 | Online 2020-08-02; issue Mol Ecol 30(13), 2021. Year = 2021 (print), which matches the key. doi.org BibTeX says 2020. |
| isaac2014 | yes | Crossref 10.1111/2041-210X.12254 | none |
| isaac2015 | yes | Crossref 10.1111/bij.12532 | none (Isaac & Pocock) |
| vanstrien2013 | yes | Crossref 10.1007/s10531-013-0436-1 | none; species name italicised in the title |
| outhwaite2020 | yes | Crossref 10.1038/s41559-020-1111-z | none |
| kamp2016 | yes | Crossref 10.1111/ddi.12463 | none |
| white2019 | yes | Crossref 10.1093/biosci/biy144 | Online 2018-12-05; BioScience 69(1), 2019. Year = 2019 (print), which matches the key. doi.org BibTeX says 2018. |
| linden2011 | yes | Crossref 10.1890/10-1831.1 | none |
| johnston2023 | yes | Crossref 10.1111/2041-210X.13834 | Online 2022-03-18; MEE 14(1), 2023. Year = 2023 (print), which matches the key. doi.org BibTeX says 2022. |
| bowler2022 | yes | Crossref 10.1111/ecog.06219 | none. The volume really is "2022" (Ecography's numbering); article e06219. |
| collen2004 | yes | Crossref 10.1111/j.1466-822X.2004.00121.x | none |
| costello2015 | yes | Crossref 10.1016/j.gecco.2015.07.001 | none |
| moura2021 | yes | Crossref 10.1038/s41559-021-01411-5 | none |
| callaghan2023 | yes | Crossref 10.1038/s41559-023-02173-y | none |
| anthony2023 | yes | Crossref 10.1073/pnas.2304663120 | none |
| mcrae2017 | yes | Crossref 10.1371/journal.pone.0169156 | none |
| currie2022 | yes | Crossref 10.1139/facets-2022-0063 | none |
| buschke2021 | yes | Crossref 10.1038/s41559-021-01494-0 | none |
| leung2020 | yes | Crossref 10.1038/s41586-020-2920-6 | none |
| moussy2022 | yes | Crossref 10.1111/cobi.13721 | Online 2021-06; Conserv Biol 36(1), 2022. Year = 2022 (print), which matches the key. doi.org BibTeX says 2021. |
| ledger2023 | yes | Crossref 10.1038/s44185-023-00017-3 | none (npj Biodiversity 2:12) |
| baron2018 | yes | Crossref 10.1073/pnas.1711842115 | none |
| greenspoon2023 | yes | Crossref 10.1073/pnas.2204892120 | none |
| callaghan2021pnas | yes | Crossref 10.1073/pnas.2023170118 | none |
| robinson2022 | yes | Crossref 10.1073/pnas.2113862119 | none (34 authors) |
| rosenberg2023 | yes | Crossref 10.1126/sciadv.abq4049 | none |
| schultheiss2022 | yes | Crossref 10.1073/pnas.2201550119 | none |
| vandenhoogen2019 | yes | Crossref 10.1038/s41586-019-1418-6 | none (70 authors) |
| garciarosello2023 | yes | Crossref 10.1111/syen.12589 | none. `<scp>` markup removed from the title. |
| potapov2023 | yes | DOI 10.1038/s41467-023-36216-6 (from docs/provenance_parts/soil_arthropods.md §4), checked with Crossref | none (Nat Commun 14:674; 101 authors) |
| atkinson2009 | yes | DOI 10.1016/j.dsr.2008.12.007 (docs/data_provenance.md), checked with Crossref | none (Deep-Sea Res I 56(5):727–740) |
| irigoien2014 | yes | DOI 10.1038/ncomms4271 (docs/data_provenance.md), checked with Crossref | none (Nat Commun 5:3271) |
| greenspoon2025 | yes | DOI 10.1038/s41467-025-63888-z (docs/data_provenance.md), checked with Crossref | none (Nat Commun 16:8338, published 2025-10-27) |
| tobias2022 | yes | DOI 10.1111/ele.13898 (docs/data_provenance.md), checked with Crossref | none (Ecol Lett 25(3):581–597; 115 authors) |
| soria2021 | yes | DOI 10.1002/ecy.3344 (docs/data_provenance.md), checked with Crossref | none (Ecology 102(6):e03344) |
| appeltans2012 | yes | DOI 10.1016/j.cub.2012.09.036 (docs/provenance_parts/richness.csv), checked with Crossref | none (Curr Biol 22(23):2189–2202; 121 authors) |
| oberski2025 | yes | DOI 10.1093/isd/ixaf025 (docs/data_provenance.md), checked with Crossref | none. ISD 9(4), article ixaf025. Crossref dates: print 2025-07-05, online 2025-09-06. |
| chase2016 | yes | DOI 10.7717/peerj.2354 (docs/provenance_parts/vert_census.csv), checked with Crossref | none (PeerJ 4:e2354) |
| bratbak1984 | yes | DOI 10.1128/aem.48.4.755-757.1984 (docs/conversion_factors.csv), checked with Crossref | none (Appl Environ Microbiol 48(4):755–757). doi.org content negotiation redirected to a Crossref URL that returned HTTP 405, so I fetched the BibTeX from `api.crossref.org/v1/works/<DOI>/transform/application/x-bibtex`. The JSON came back normally. |
| stan2017 | yes | Crossref 10.18637/jss.v076.i01; pages from jstatsoft.org/article/view/v076i01 (`citation_firstpage` 1, `citation_lastpage` 32) | none. Crossref has no page range, so pages were taken from the JSS landing page. |
| burkner2017 | yes | Crossref 10.18637/jss.v080.i01; pages from jstatsoft.org/article/view/v080i01 (1–28) | none. Pages from the JSS landing page, as for stan2017. |
| landau2021 | yes | Crossref 10.21105/joss.02959 | none (JOSS 6(57):2959) |
| chapman2009 | yes | Local PDF `data/raw/richness/chapman2009/vliz_234960.pdf` (from https://www.vliz.be/imisdocs/publications/ocrd/234960.pdf). Cover page and imprint page read. | none. The cover reads "Numbers of Living Species in Australia and the World, 2nd edition, Arthur D. Chapman … Report for the Australian Biological Resources Study, Canberra, Australia, September 2009". Imprint: "© Commonwealth of Australia 2009", "Publisher Australian Biological Resources Study (ABRS)", ISBN (printed) 978 0 642 56860 1 (used), ISBN (online) 978 0 642 56861 8. The PDF's internal metadata title says "Number of …" (singular), but the printed cover says "Numbers". Entered as `@book`. |
| cites2025rhino | yes (from the document itself; cites.org not reachable) | Local PDF `data/raw/rhino_cop20/2025-iucn-traffic-rhino-report.pdf` (sha256 c115c917…eab2d5), from https://rhinoresourcecenter.com/wp-content/uploads/2025/10/2025-iucn-traffic-rhino-report.pdf | Cover: "CoP20 Doc. 84 Annex 3 — African and Asian Rhinoceroses – Status, Conservation and Trade". Authors come from the Acknowledgments ("the authors of this report"): Sam M Ferreira, Sharon Baruch-Mordo, Graham Laidler, Rachele Stoppoloni, Louisa Sangalakula, Bibhab Talukdar, Dave Balfour. "© 2025 Secretariat of the Convention … (CITES)". The document does not state "Geneva" itself; the place comes from the same report's citation of its CoP19 predecessor ("CITES Secretariat, Geneva, Switzerland"). cites.org returns HTTP 403, so the URL is the Rhino Resource Center copy. Entered as `@techreport`. |
| lpd2016 | yes (repository/commit/file); the year is an inference | GitHub API: repo `Zoological-Society-of-London/rlpi`, commit `bfa317723cd2c5cf4ab36b27524535a11d50dd3f` (2026-05-04), file `inst/extdata/example_data/LPI_LPR2016data_public.csv` (8,148,031 bytes; git blob sha `c7c6f0ab…4a7d` = `git hash-object` of the local copy). Path and commit taken from docs/provenance_parts/lpd.md. | `year = 2016` is inferred from the file name (LPR2016) and from DataCite record 10.6084/m9.figshare.4300022.v1 (McRae, Deinet & Freeman 2016, "LPI_LPR2016data_public.csv … These data were used in the Living Planet Report 2016"). **That figshare file is not byte-identical to the rlpi copy** (8,037,351 bytes, md5 d6e8b334… vs local md5 12308be4…), so it was not used as the citation. The figshare record states CC BY 4.0, while docs/provenance_parts/lpd.md assumes the LPI Data Use Policy applies. The human should decide. Entered as `@misc` with author {ZSL/WWF}, url, and urldate 2026-11-03. |
| gbif2026 | yes | S3 listing `s3://gbif-open-data-us-east-1/occurrence/2026-11-01/` (anonymous HTTPS, 2026-11-03), file `citation.txt` in that folder; DataCite and GBIF API for the DOI | **The snapshot already has a GBIF DOI.** `citation.txt` reads verbatim: `GBIF.org (1 November 2026) GBIF Occurrence Download https://doi.org/10.15468/dl.jeesns`. GBIF API: download key 0020839-261023074918325, format SIMPLE_PARQUET, created 2026-11-01, **3,887,364,403 records** from 91,006 datasets, licence CC BY-NC 4.0, `eraseAfter` 2027-05-01. The title is GBIF's ("GBIF Occurrence Download"), and `doi = 10.15468/dl.jeesns` was added. The requested note "Derived dataset DOI to be registered before submission" is kept. (reports/methods_draft_en.md says 3.75 × 10⁹ records. That is presumably after the ABSENT/fossil exclusion, but it differs from GBIF's total.) |
| iucn2012 | yes | IUCN library record https://portals.iucn.org/library/node/10315 and PDF https://portals.iucn.org/library/sites/library/files/documents/RL-2001-001-2nd.pdf (sha256 b23a4458…0804, downloaded 2026-11-03) | No DOI (none on the library record or imprint; Crossref search found none). Imprint "Citation: IUCN. (2012). IUCN Red List Categories and Criteria: Version 3.1. Second edition. Gland, Switzerland and Cambridge, UK: IUCN. iv + 32pp." ISBN 978-2-8317-1435-6. Criterion-A wording: see below. |
| stan2017 / burkner2017 / landau2021 | yes | see rows above | |
| gabry_cmdstanr | yes | `Rscript -e 'citation("cmdstanr")'` run in the project dir (renv library; cmdstanr 0.9.0, matching renv.lock) | Year **2025** (from the package CITATION), not the analysis year. Authors: Gabry, Češnovar, Johnson, Bronder. |
| arrow_r | yes | `Rscript -e 'citation("arrow")'` run in the project dir (arrow 26.0.0, matching renv.lock) | Year 2026; 10 persons plus {Apache Arrow}. |
| rcore2026 | yes | `Rscript -e 'citation()'` run in the project dir; `R.version.string` = "R version 4.6.1 (2026-06-24)" (renv.lock R 4.6.1) | The CITATION includes doi 10.32614/R.manuals (Crossref resolves it as "R: A Language and Environment for Statistical Computing", R Core Team). The version note "R version 4.6.1" was added from `R.version.string`. |

**UNVERIFIED entries: none.**

## iucn2012 — criterion A text (quoted from the PDF)

Criterion A for **Vulnerable**, p. 21 (printed), sub-criterion A2:

> "2. An observed, estimated, inferred or suspected population size reduction of ≥30% over the last 10 years or three generations, whichever is the longer, where the reduction or its causes may not have ceased OR may not be understood OR may not be reversible, based on (and specifying) any of (a) to (e) under A1."

A3 (p. 21):

> "3. A population size reduction of ≥30% projected or suspected to be met within the next 10 years or three generations, whichever is the longer (up to a maximum of 100 years), based on (and specifying) any of (b) to (e) under A1."

Summary table, p. 28 (printed):

> "A. Population size reduction. Population reduction (measured over the longer of 10 years or 3 generations) based on any of A1 to A4" … "A2, A3 & A4 … Vulnerable ≥ 30%" (A1: Vulnerable ≥ 50%).

So "a 30% decline over 10 years or 3 generations" is the **Vulnerable threshold for A2–A4**, and the period is **whichever of the two is longer**. Under A1 (causes reversible, understood and ceased), Vulnerable needs ≥50%. The manuscript wording should say "≥30% over the longer of 10 years or three generations (IUCN criterion A2–A4, Vulnerable)" or similar.

## Rendering note (pandoc + pnas.csl)

* `@misc` becomes CSL `document`. The PNAS CSL then prints only author, title and year, and **drops the URL/DOI/howpublished of lpd2016 and gbif2026**. I tested the alternatives: `@online` (CSL webpage) prints "Available at: <url> [Accessed 3 November 2026]", and `@dataset` prints "… https://doi.org/10.15468/dl.jeesns. Deposited November 2026". The entries are left as `@misc`, as requested. Switch the type if the URL/DOI should appear.
* The PNAS CSL prints no DOI for journal articles that have a volume (by design).
