# Query ChecklistBank (Catalogue of Life release) for accepted species counts per taxon.
# Saves every raw JSON response unchanged under outdir; prints a TSV summary.
import json, sys, os, urllib.request, urllib.parse, time
K, outdir = sys.argv[1], sys.argv[2]
names = sys.argv[3:]
os.makedirs(outdir, exist_ok=True)
def get(url, fn):
    for i in range(4):
        try:
            with urllib.request.urlopen(url, timeout=120) as r: b = r.read()
            open(os.path.join(outdir, fn), 'wb').write(b); return json.loads(b)
        except Exception as e:
            err = e; time.sleep(5)
    raise err
print('query\tid\tscientificName\tauthorship\trank\tstatus\tparent_path\tspeciesExtantCount\tspecies_all\ttaxonCount\tsearch_url\tmetrics_url')
for q in names:
    su = f'https://api.checklistbank.org/dataset/{K}/nameusage/search?' + urllib.parse.urlencode({'q': q, 'type': 'EXACT', 'limit': 10, 'status': 'accepted'})
    d = get(su, f'search_{q.replace(" ","_")}.json')
    hits = [r for r in d.get('result', []) if r['usage']['name']['scientificName'] == q and r['usage']['status'] == 'accepted'
            and any(c['name'] == 'Animalia' for c in r.get('classification', []))]
    if not hits: print(f'{q}\tNOT_FOUND'); continue
    for r in hits:
        u = r['usage']; tid = u['id']
        mu = f'https://api.checklistbank.org/dataset/{K}/taxon/{tid}/metrics'
        m = get(mu, f'metrics_{q.replace(" ","_")}_{tid}.json')
        path = '>'.join(c['name'] for c in r.get('classification', [])[:-1])
        print('\t'.join(map(str, [q, tid, u['name']['scientificName'], u['name'].get('authorship', ''), u['name']['rank'], u['status'], path,
              m.get('speciesExtantCount', ''), m.get('taxaByRankCount', {}).get('species', ''), m.get('taxonCount', ''), su, mu])), flush=True)
