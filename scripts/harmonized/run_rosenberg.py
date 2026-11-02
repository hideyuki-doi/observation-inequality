# Runs selected cells of Rosenberg et al. 2023 notebook 01-Main-Estimate (Zenodo 10.5281/zenodo.7502033)
# unchanged except: magics removed, save_bool=False, Agg backend, seeded RNGs, N_boot/N_samps from argv.
import json, sys, os, re
nbdir, nboot, seed = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
os.chdir(nbdir)
import matplotlib; matplotlib.use('Agg')
nb = json.load(open('01-Main-Estimate_global_biomass_and_numbers.ipynb'))
cells = [0,1,3,5,7,9,10,12,13,15,16,17,18,19,21,23,34,44,45,46,47]
g = {}
for i in cells:
    src = ''.join(nb['cells'][i]['source'])
    src = '\n'.join(l for l in src.split('\n') if not l.strip().startswith('%'))
    src = src.replace('rng = np.random.default_rng()', f'rng = np.random.default_rng({seed}); np.random.seed({seed})')
    src = src.replace('save_bool=True', 'save_bool=False')
    src = re.sub(r'N_boot=100000', f'N_boot={nboot}', src)
    src = re.sub(r'N_samps = 100000', f'N_samps = {nboot}', src)
    if i == 47:
        src = "print(soil_pop_tots.groupby('aggregated taxon')[['Total','Total_low','Total_high']].sum())"
    if i == 23:
        src = "print(soil_tots.groupby('aggregated taxon')[['Total','Total_low','Total_high']].sum())"
    print(f'##### running cell {i}', flush=True)
    exec(compile(src, f'cell{i}', 'exec'), g)
import numpy as np, pandas as pd
pd.set_option('display.width', 200); pd.set_option('display.float_format', '{:.6g}'.format)
# Monte-Carlo per-taxon distributions (same machinery as the paper's totals)
tb = g['tot_biomass_taxon']            # columns = taxa, rows = MC samples, Mt dry
print('MC biomass per taxon (Mt dry): median, 2.5%, 97.5%, mean')
for t in tb.columns: print(t, np.median(tb[t]), np.percentile(tb[t],2.5), np.percentile(tb[t],97.5), tb[t].mean())
pdist = g['soil_pop_dist'].groupby('aggregated taxon').sum().T   # individuals
print('MC population per taxon (individuals): median, 2.5%, 97.5%, mean')
for t in pdist.columns: print(t, np.median(pdist[t]), np.percentile(pdist[t],2.5), np.percentile(pdist[t],97.5), pdist[t].mean())
print('per-biome Acari biomass Stats (mg/m2) and totals (Mt):')
st = g['soil_tots']; print(st[st['aggregated taxon']=='Acari'])
pt = g['soil_pop_tots']; print('per-biome Acari population totals:'); print(pt[pt['aggregated taxon']=='Acari'])
print('Acari mean ind mass (mg/ind):'); print(g['soil_ratio_filt_full'].loc['Acari'])
