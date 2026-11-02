# Builds docs/provenance_parts/harmonized.csv (agent id `harmonized`).
# All numbers are copied from:
#   data/derived/harmonized_baron_subgroups.txt   (scripts/harmonized/baron_subgroups.R, Bar-On repo inputs)
#   data/derived/harmonized_rosenberg_rerun_Nboot1e5_seed20261103.log (scripts/harmonized/run_rosenberg.py)
#   data/derived/harmonized_col_species_counts.tsv (scripts/harmonized/col_counts.py, raw JSON in data/raw/checklistbank_col26.10/)
# Run: python3 -I scripts/harmonized/build_harmonized_csv.py   (from the project root)
import csv

COLS = ["group", "tier", "realm", "N_est", "N_lo", "N_hi", "N_interval_type", "B_est", "B_lo", "B_hi", "B_unit",
        "B_interval_type", "n_described_species", "n_described_source", "method_class", "method_evidence", "citation",
        "doi", "location_in_source", "retrieved_file", "verified", "notes", "derived_formula", "inputs"]

BARON = "Bar-On YM, Phillips R, Milo R (2018) The biomass distribution on Earth. PNAS 115:6506-6511"
BARON_DOI = "10.1073/pnas.1711842115"
BARON_FILE = "data/raw/baron2018/biomass_distribution/ (git commit 36cf0a80); results.xlsx sheet 'Table S1'"
ROS = "Rosenberg Y, Bar-On YM, Fromm A, Ostikar M, Shoshany A, Giz O, Milo R (2023) The global biomass and number of terrestrial arthropods. Sci Adv 9:eabq4049"
ROS_DOI = "10.1126/sciadv.abq4049"
COLK = "316595"


def col(tid, extra=""):
    return (f"Catalogue of Life 2026-10-14 (ChecklistBank dataset {COLK}, doi:10.48580/dgzh4); "
            f"GET https://api.checklistbank.org/dataset/{COLK}/taxon/{tid}/metrics -> speciesExtantCount (accepted extant species){extra}")


rows = []

def add(**kw):
    r = {c: "" for c in COLS}
    r.update(kw)
    rows.append(r)

# ---------------- Task 1: Bar-On subgroups with matched scope ----------------
add(group="Copepods (mesozooplankton arthropods; Bar-On marine-arthropod N scope)", tier="B", realm="marine",
    N_est="1.41154e+20", N_interval_type="none",
    B_est="5.64617e-01", B_unit="Gt C", B_interval_type="none",
    n_described_species="15297", n_described_source=col("B8V3R", "; taxon Copepoda (class), all copepods incl. benthic/parasitic"),
    method_class="independent",
    method_evidence="B: MAREDAT mesozooplankton min/max (Buitenhuis et al.: 0.33/0.59 Gt C) geometric mean x arthropod fraction 0.792 (Tara 18S reads, Rhizaria excluded) / 0.619 (300->200 um net correction). N = B / 4 ug C per copepod.",
    citation=BARON, doi=BARON_DOI,
    location_in_source="animals/arthropods/marine_arthropods/marine_arthropods.py cells 2-6 (meso_arth_biomass) and cell 11 (copepod_carbon_content = 4e-6; marine_arth_num = meso_arth_biomass/copepod_carbon_content); ipynb output 'Our best estimate for the biomass of mesozooplankton arthropods is ≈0.56 Gt C'",
    retrieved_file=BARON_FILE + "; animals/arthropods/marine_arthropods/marine_arthropods_data.xlsx sheet 'de Vargas'",
    verified="yes",
    notes="Scope-matched subgroup (decision 3). B recomputed by me from repo inputs following the notebook; B/assumed-mass reproduces results.xlsx N exactly (1.41154e20). Assumed mass 4 ug C/individual = geometric mean of 0.15-100 ug C (Viñas et al. 2010 doi:10.1590/S1679-87592010000200008; Dai et al. 2016 doi:10.1016/j.jmarsys.2015.11.004 - neither read, 未確認 at origin). M = B/N = 4e-6 g C (= assumption). No separate uncertainty for this subgroup in the code (mul_CI = 10 is projected for total marine arthropods only). SI Table S14 says numbers come from meso- AND macrozooplankton, but code uses mesozooplankton only (code followed, since it generates the published N). B is mesozooplankton arthropods (mostly copepods), not strictly Copepoda.",
    derived_formula="B = gmean(0.33e15, 0.59e15) * frac_mean(c(f_DCM, f_surf)) / 0.619 [g C]; f = frac_mean(Arthropod/(1-Rhizaria)) per depth; check N = B / 4e-6",
    inputs="marine_arthropods.py cells 2-6, 11; marine_arthropods_data.xlsx 'de Vargas'; results.xlsx 'Table S1' row Marine arthropods")

add(group="Enchytraeidae (soil; Bar-On annelid N scope)", tier="B", realm="terrestrial",
    N_est="7.71435e+17", N_interval_type="none",
    B_est="1.92859e-02", B_unit="Gt C", B_interval_type="none",
    n_described_species="840", n_described_source=col("8KTLN", "; family Enchytraeidae (incl. aquatic/marine species)"),
    method_class="independent",
    method_evidence="Fierer et al. 2009 biome mean and median Enchytraeid biomass densities x Schlesinger & Bernhardt biome areas; geometric mean of mean- and median-based totals. Fierer densities are themselves abundance counts x per-individual C (SI Table S16/S19: conversion via Petersen & Luxton).",
    citation=BARON, doi=BARON_DOI,
    location_in_source="animals/annelids/annelids.py cell 12 (mean_ench_biomass, median_ench_biomass, ench_biomass = gmean; ench_carbon_content = 25e-6; tot_ench_num); ipynb output 'Our best estimate for the total number of Enchytraeids is ≈8e+17'",
    retrieved_file=BARON_FILE + "; animals/annelids/annelid_biomass_data.xlsx sheets 'Fierer','Biome area'",
    verified="yes",
    notes="Scope-matched subgroup. B recomputed (mean-based 2.20660e13 g C, median-based 1.68560e13 g C, gmean 1.92859e13 g C); B/25e-6 reproduces results.xlsx N exactly. Assumed mass 25 ug C/individual, notebook: 'the carbon content of Enchytraeids, which is ≈25 µg C (Fierer et al.)' (Fierer et al. 2009 Ecol Lett doi:10.1111/j.1461-0248.2009.01360.x, not read; SI says Fierer's conversions are from Petersen & Luxton 1982). Covers only Fierer's 7 biomes (savanna/pasture/crops not included for Enchytraeids). Annelid total B (0.199 Gt C) is mostly earthworms and is NOT matched to this N.",
    derived_formula="B = gmean(sum(mean_dens_ench * area), sum(median_dens_ench * area)) [g C]; check N = B / 25e-6",
    inputs="annelids.py cell 12; annelid_biomass_data.xlsx; results.xlsx 'Table S1' row Annelids")

add(group="Pteropods (Bar-On mollusc N scope)", tier="B", realm="marine",
    N_est="4.97231e+17", N_interval_type="none",
    B_est="1.31985e-01", B_unit="Gt C", B_interval_type="none",
    n_described_species="141", n_described_source=col("7NFFH", "; order Pteropoda; 409 species incl. fossil (taxaByRankCount.species)"),
    method_class="independent",
    method_evidence="MAREDAT pteropod biomass (Bednaršek et al. via Buitenhuis et al.): geometric mean of 'maximum' 0.67 and 'minimum' 0.026 Gt C. N = B / (mean biomass / mean abundance across Bednaršek samples).",
    citation=BARON, doi=BARON_DOI,
    location_in_source="animals/molluscs/molluscs.py cell 2 (pteropod_estimate = gmean([0.67e15, 0.026e15])) and cell 8 (best_cc = mean('Biomass (mg/m3)')/mean('Abundace (ind./m3)')*1e-3); also marine_arthropods_data.xlsx 'Other macrozooplankton' row 'Biomass of pteropods' = 1.319848e14 g C",
    retrieved_file=BARON_FILE + "; animals/molluscs/carbon_content_data.xlsx",
    verified="yes",
    notes="Scope-matched subgroup. B = 1.31985e14 g C (also stored in repo as 1.319848e14). Assumed mass recomputed = 2.6544e-4 g C (0.265 mg C) per pteropod from 8,814 rows of Bednaršek et al. 2012 ESSD (doi:10.5194/essd-4-167-2012) data in the repo (ratio of means, not mean of ratios). B/mass reproduces results.xlsx N exactly. Cephalopods (0.05 Gt C) excluded from both.",
    derived_formula="B = sqrt(0.67e15 * 0.026e15) [g C]; mass = mean(Biomass mg/m3)/mean(Abundance ind/m3) * 1e-3 [g C]; check N = B/mass",
    inputs="molluscs.py cells 2, 8; molluscs/carbon_content_data.xlsx (skip 4 rows); results.xlsx 'Table S1' row Molluscs")

add(group="Planktonic cnidarians (jellyfish; Bar-On cnidarian N scope)", tier="B", realm="marine",
    N_est="1.96567e+16", N_interval_type="none",
    B_est="4.0e-02", B_unit="Gt C", B_interval_type="none",
    n_described_species="244", n_described_source=col("B8V42", "; class Scyphozoa only. Other medusozoan classes: Cubozoa 53 (B8V3T), Staurozoa 51 (B8V43), Hydrozoa 3894 (B8V3X; mostly polyp-dominated)"),
    method_class="independent",
    method_evidence="Lucas et al. 2014 global gelatinous zooplankton biomass (JeDI abundance data x biometric equations), cnidarian part taken as ≈0.04 Gt C. N = 0.04 Gt C / geometric mean of mean and median mg C per individual over Lucas et al. biometric-equation species.",
    citation=BARON, doi=BARON_DOI,
    location_in_source="animals/cnidarians/cnidarians.py cell 2 (planktonic_cnidarian_biomass = 0.04e15) and cell 22 (best_cc = gmean([median_cc, mean_cc]); tot_cnidaria_num)",
    retrieved_file=BARON_FILE + "; animals/cnidarians/carbon_content_data.xls sheet 'Biometric equations'",
    verified="yes",
    notes="Scope-matched subgroup (corals excluded from both B and N). Notebook: 'Globally, they estimate ≈0.04 Gt C of gelatinous zooplankton, of which 92% are contributed by cnidarians. Therefore, we estimate ... ≈0.04 Gt C' (i.e. not multiplied by 0.92). Assumed mass recomputed = 2.03493e-3 g C (median 5.564e-4, mean 7.443e-3 g C over 122 species rows). Lucas et al. 2014 GEB doi:10.1111/geb.12169 (abstract only read by marine_other). Species count: which classes are 'jellyfish' is a judgment call; Scyphozoa given as primary.",
    derived_formula="mass = gmean(median(mgC_ind), mean(mgC_ind)) * 1e-3 [g C]; check N = 0.04e15 / mass",
    inputs="cnidarians.py cells 2, 22; carbon_content_data.xls; results.xlsx 'Table S1' row Cnidarians")

add(group="Mesopelagic fish (Bar-On fish N scope)", tier="B", realm="marine",
    N_est="1.11569e+15", N_interval_type="none",
    B_est="5.17611e-01", B_lo="4.5677e-02", B_hi="5.8656e+00", B_unit="Gt C", B_interval_type="fold_uncertainty",
    n_described_species="252", n_described_source=col("KVH45", "; family Myctophidae only (the family used for the per-individual mass); 'mesopelagic fish' spans many families - not counted"),
    method_class="independent",
    method_evidence="Geometric mean of sonar-based (global backscatter Irigoien/Proud / target strength per kg, 50% swimbladder; x1000 x0.15 -> 1.78614e15 g C) and trawl-based (Lam & Pauly 1.5e14 g C) estimates. N = B / (geometric mean wet mass of Myctophidae species from Fock & Ehrich length-weight relations x 0.15).",
    citation=BARON, doi=BARON_DOI,
    location_in_source="animals/chordates/fish/fish_biomass_estimate.py cells 2-13 (best_mesopelagic_biomass), 29 (meso_inter_CI), 40-46 (fish_cc, tot_fish_num); ipynb outputs '≈0.5 Gt C', '≈0.46 g C', '≈11.3-fold'",
    retrieved_file=BARON_FILE + "; animals/chordates/fish/fish_biomass_data.xlsx sheets 'Total scatter','Target strength','Fock & Ehrich'",
    verified="yes",
    notes="Scope-matched subgroup. B recomputed = 5.17611e14 g C; per-fish mass recomputed = 0.463939 g C (= 3.09293 g wet x 0.15) from 32 Myctophidae species; B/mass reproduces results.xlsx N exactly. Code quirk: fe_mean_length = np.mean([max, min]) without axis returns ONE scalar (66.39 mm) applied to all species, not a per-species mean length. Fold uncertainty 11.33 = meso_CI = max(inter-method 11.33, sonar ~9.5); 11.33 recomputed by me with the repo's geo_CI_calc (ddof=1) on [1.78614e15, 1.5e14]; B_lo/B_hi = B/11.33, B x 11.33 (my calculation). Decision 4 makes Irigoien 2014 the main mesopelagic B; this Bar-On row is for the N and the assumed mass. Fock & Ehrich 2010 (doi:10.1111/j.1439-0426.2010.01450.x) not read.",
    derived_formula="B = gmean(sonar, 1.5e14); sonar = gmean(gmean(sA/(4*pi*1852^2)), 6.02e9) / (0.5*10^(TS_No/10)+0.5*10^(TS_Yes/10)) * 1000 * 0.15; mass = gmean(a_i*(L/10)^b_i)*0.15 with L = mean of all min & max SL (mm); fold = 10^(sd(log10(c(sonar,1.5e14)))/sqrt(2)*1.96)",
    inputs="fish_biomass_estimate.py; fish_biomass_data.xlsx; results.xlsx 'Table S1' row Fish")

add(group="Nematodes (all; Bar-On, N and B already same scope)", tier="B", realm="terrestrial+marine",
    N_est="3.92233e+20", N_interval_type="none",
    B_est="1.96117e-02", B_unit="Gt C", B_interval_type="none",
    n_described_species="19667", n_described_source=col("NM", "; phylum Nematoda (all, incl. marine, parasitic)"),
    method_class="independent",
    method_evidence="Soil: Fierer et al. biome mean/median biomass densities (gaps filled by geometric mean across biomes) x biome area, geometric mean of the two totals (5.61166e12 g C); marine: 0.014e15 g C assumed (Wei et al. benthic biomass x 13% meiofauna, assumed all nematodes). N = B / 0.05 ug C.",
    citation=BARON, doi=BARON_DOI,
    location_in_source="animals/nematodes/nematodes.py cells 2-10 (best_terrestrial_biomass, best_marine_biomass = 0.014e15, carbon_content = 0.05e-6); SI Table S19 ('Characteristic carbon content of nematode: ≈0.05 µg C based on Petersen & Luxton (146)')",
    retrieved_file=BARON_FILE + "; animals/nematodes/nematode_biomass_data.xlsx",
    verified="yes",
    notes="No realignment needed (N = total B / mass, both cover all nematodes); recomputation reproduces N and B exactly. Assumed mass 0.05 ug C (Fierer et al. 2009 / Petersen & Luxton 1982; neither read). Marine part (71% of B and N) is an assumption-heavy figure. For soil-only comparison with van den Hoogen 2019 see next row.",
    derived_formula="B = gmean(sum(mean_dens*area), sum(median_dens*area)) + 0.014e15; check N = B/0.05e-6",
    inputs="nematodes.py; nematode_biomass_data.xlsx; results.xlsx 'Table S1' row Nematodes")

add(group="Nematodes, soil only (Bar-On; derived split)", tier="B", realm="terrestrial",
    N_est="1.12233e+20", N_interval_type="none",
    B_est="5.61166e-03", B_unit="Gt C", B_interval_type="none",
    n_described_source="see row 'Nematodes (all...)'; no soil-only species count",
    method_class="independent",
    method_evidence="As above, terrestrial component only.",
    citation=BARON, doi=BARON_DOI,
    location_in_source="animals/nematodes/nematodes.py cell 6 (best_terrestrial_biomass); results.xlsx sheet 'Fig2A' row Terrestrial/Nematodes",
    retrieved_file=BARON_FILE,
    verified="yes",
    notes="DERIVED N: Bar-On does not report a soil-only N; I divided the soil B by Bar-On's own 0.05 ug C. Sensitivity/comparison only; decision default for soil nematodes is van den Hoogen 2019.",
    derived_formula="N_soil = 5.61166e12 g C / 0.05e-6 g C",
    inputs="nematodes.py cell 6 and cell 10 (carbon_content)")

# ---------------- Task 2: mites (Rosenberg re-run) ----------------
add(group="Acari (soil mites)", tier="B", realm="terrestrial",
    N_est="6.545e+18", N_lo="3.472e+18", N_hi="1.066e+19", N_interval_type="range",
    B_est="26.11", B_lo="15.58", B_hi="38.70", B_unit="Mt dry weight", B_interval_type="range",
    n_described_species="29017", n_described_source=col("LK + LV", "; sum of superorders Acariformes (LK, 22635) + Parasitiformes (LV, 6382); 'Acari' is not an accepted name in COL 26.10. COL coverage of mites looks incomplete (see md) - 未確認 completeness"),
    method_class="independent",
    method_evidence="Rosenberg et al. site-level soil core densities (Tullgren/hand extraction), stratified by aggregated biome; bootstrap of site means (1e5 resamples, normal measurement error truncated at 0), x biome area; population data converted to mass with taxon mean individual mass from paired sites.",
    citation=ROS, doi=ROS_DOI,
    location_in_source="Zenodo 10.5281/zenodo.7502033, notebook 01-Main-Estimate_global_biomass_and_numbers.ipynb: cell 21 (soil_tots), cell 23 (totals_per_soil_taxa), cell 44 (soil_pop_tots), cell 47 (population per taxon). Paper Results: 'mites ... contribute about 10% each' and '>95% ... about two-thirds of these being mites'",
    retrieved_file="data/raw/rosenberg2023/zenodo7565553.zip (RawData.xlsx, aggregated biomes data.csv, results/tables/average_ind_mass_full.csv)",
    verified="yes",
    notes="DERIVED by re-running the authors' notebook unchanged except: magics removed, save_bool=False, RNG seeded (numpy default_rng(20261103), np.random.seed(20261103)); N_boot = N_samps = 1e5 as in the original; Python 3.9 / pandas 1.3.4 / numpy 1.20.3 (versions listed in the Zenodo README) in a scratch micromamba env. N_est/B_est = sum over biomes of bootstrap-mean density x area; ranges = sum of per-biome 2.5%/97.5% bounds (the paper's 'uncertainty range' definition, Methods). Validation: same run gives soil total 1.0e19 (5.0e18-1.8e19) individuals, 221 (105-380) Mt dry, termites 99.9 (48.8-168.5) Mt, ants 4.6e16 (1.7e16-9.2e16), springtails 3.4e18 (1.3e18-6.6e18) - matching the paper's rounded figures. Monte-Carlo 95% CI (independent-biome sampling, narrower): N 4.94e18-8.46e18, B 21.3-31.4 Mt dry. Implied M = B/N = 3.99e-3 mg dry; wet via Rosenberg's Acari dry/wet 0.4 = 65.3 (39.0-96.8) Mt wet (docs/conversion_factors.csv). Run-to-run Monte Carlo noise in 4th significant digit (seed 2000-resample run: N 6.546e18, B 26.08 Mt).",
    derived_formula="N = sum_b mean_boot(dens_Acari,b) * area_b; B likewise with mass densities (mg m-2 dry); ranges = sum_b 2.5%/97.5% bootstrap bounds * area_b",
    inputs="scripts/harmonized/run_rosenberg.py; data/derived/harmonized_rosenberg_rerun_Nboot1e5_seed20261103.log")

# ---------------- Task 3: earthworms ----------------
add(group="Earthworms (Crassiclitellata)", tier="B", realm="terrestrial",
    N_interval_type="", B_interval_type="",
    n_described_species="1994", n_described_source=col("84JRR", "; order Crassiclitellata. Likely incomplete coverage in COL (see md) - 未確認 completeness"),
    method_class="independent",
    method_evidence="Phillips et al. 2019: 6,928 sites, GLMM on environmental covariates, predicted 30 arcsec maps (per m2 values only).",
    citation="Phillips HRP et al. (2019) Global distribution of earthworm diversity. Science 366:480-485 (+ Erratum 2020)",
    doi="10.1126/science.aax4851",
    location_in_source="GitHub helenphillips/GlobalEWDiversity (commit 7149c8d, 2020-06-19) erratum_README.md; 11.1_ValuesFromMap.R",
    retrieved_file="data/raw/phillips2019/ (PMC7335308.html, idiv1804_v7_sWormModelData.zip, idiv1818_v15_sWormModelData_correction.zip, GlobalEWDiversity_erratum_README.md, GlobalEWDiversity_11.1_ValuesFromMap.R)",
    verified="yes",
    notes="全球値なし. Predicted maps are not public: iDiv 1804 (orig.) and 1818 (corrected) contain only site-level model data; GitHub/Zenodo 10.5281/zenodo.3386456 contain code only; science.org SM blocked (403). Reconstructing maps would mean re-fitting their models on global CHELSA/SoilGrids/ESA layers (not done). Erratum (authors' README) revises mean abundance to '20.59 individuals per m2 (SD = 24.84; previously 77.89 ...)' and biomass to '51.18 g per m2 (SD = 4881.2; median, 6.16; previously 2772.8 ...)' - these are unweighted pixel means, not area-weighted global totals; I did not multiply them by land area.",
    derived_formula="", inputs="")

# ---------------- Task 5: species counts for other candidate groups ----------------
spec = [
    ("Collembola (springtails)", "terrestrial", "8926", "KZS5W", "; class Collembola"),
    ("Formicidae (ants)", "terrestrial", "14438", "CLRKP", "; family Formicidae (15309 incl. fossil; AntCat-sourced)"),
    ("Termites (Termitoidae)", "terrestrial", "3000", "C3V76", "; infraorder Termitoidae (= Isoptera, synonym KVF8V); 3232 incl. fossil"),
    ("Euphausia superba (Antarctic krill)", "marine", "1", "3CMD5", "; single species by definition (COL accepted name Euphausia superba Dana, 1850)"),
    ("Mammalia", "terrestrial+marine", "6368", "6224G", "; class Mammalia (6467 incl. fossil)"),
    ("Aves", "terrestrial", "10868", "V2", "; class Aves (11044 incl. fossil)"),
]
for g, realm, n, tid, ex in spec:
    add(group=g + " - described species only", tier="", realm=realm, n_described_species=n,
        n_described_source=col(tid, ex), citation="Catalogue of Life Checklist, release 2026-10-14", doi="10.48580/dgzh4",
        location_in_source=f"taxon {tid} metrics", retrieved_file=f"data/raw/checklistbank_col26.10/ (search_*.json, metrics_*_{tid}.json)",
        verified="yes", notes="Species-count row only; N/B are in other agents' rows. Count = COL accepted extant species at query time (2026-11-03).")

add(group="Prokaryotes (Bacteria, Archaea) - described species", tier="B", realm="all",
    notes="Left blank on purpose: species counts are not meaningful for prokaryote census comparison (N counts all cells, most uncultured/undescribed).",
    verified="")

with open("docs/provenance_parts/harmonized.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=COLS, quoting=csv.QUOTE_ALL)
    w.writeheader()
    w.writerows(rows)
print(len(rows), "rows")
