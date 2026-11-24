import sys, os, random, statistics as st, json
sys.path.insert(0, os.path.dirname(__file__))
import pyvm, optimise as O, refine as RF, causes

BEST20 = [1.514424406823444, 41.743367170205254, 0.5828380079216375, 1.0, 0.440214017670775, 0.0, 0.37964617679294393, 0.0]
NAMES = [p[0] for p in O.PARAMS]

def run(x, H=20, n=200, p=1.0):
    sc = []; yrs = []; early = 0; hoods = []; clients = []
    for i in range(n):
        rng = random.Random(70000 + i)
        def hm(vm, lvl, rng=rng):
            return 1 if rng.random() < p else 3
        r = pyvm.play(O.Strat(x), rng=rng, maxyears=H, hitman_fn=hm, score_each_year=False)
        s = 0.0 if r.get('froze') else (r['score'] if r['ended'] else pyvm.score_now(r['vm']))
        sc.append(s); yrs.append(r['years'])
        if r['ended']:
            early += 1
        hoods.append(r['vm'].var(3) / 100); clients.append(r['vm'].var(8) / 100)
    return dict(score=round(st.mean(sc), 1), years=round(st.mean(yrs), 1), early=round(100 * early / n), hoods=round(st.median(hoods)), clients=round(st.median(clients)))

if __name__ == '__main__':
    out = {}
    grids = {'ammo': [0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0], 'ratio': [5, 10, 20, 40, 60], 'buyf': [0.0, 0.25, 0.58, 0.8, 1.0],
             'sq': [0.4, 0.6, 0.8, 1.0], 'kick': [0.0, 0.2, 0.44, 0.6, 0.8, 1.0], 'keep': [0, 50, 150, 300]}
    for nm, vals in grids.items():
        i = NAMES.index(nm)
        rows = []
        for v in vals:
            x = list(BEST20); x[i] = v
            rows.append((v, run(x)))
            print(nm, v, rows[-1][1], flush=True)
        out[nm] = rows
    out['p'] = []
    for p in (1.0, 0.9, 0.75, 0.5):
        out['p'].append((p, run(BEST20, p=p)))
        print('p', p, out['p'][-1][1], flush=True)
    out['loan'] = [(v, run([*BEST20[:6], v, BEST20[7]])) for v in (0.0, 1.0)]
    out['cap'] = [(v, run([*BEST20[:7], v])) for v in (0.0, 1.0)]
    print('loan', out['loan']); print('cap', out['cap'])
    json.dump(out, open(os.path.join(os.path.dirname(__file__), '..', 'opt', 'sensitivity.json'), 'w'))
