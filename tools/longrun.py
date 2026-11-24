import sys, os, random, statistics as st, json
sys.path.insert(0, os.path.dirname(__file__))
import pyvm, optimise as O
x = [1.51, 29.74, 0.28, 1.0, 0.44, 0.0, 0.38, 0.0]
n = 150
best = {}
paths = []
for i in range(n):
    rng = random.Random(110000 + i)
    traj = {}
    def tr(vm, h):
        traj[int(h['year']) - 1] = h['score_if_died']
    r = pyvm.play(O.Strat(x), rng=rng, maxyears=100, hitman_fn=lambda vm, l: 1, trace=tr)
    paths.append((traj, r['years'], r['ended']))
rows = []
for Y in (10, 15, 20, 30, 40, 50, 60, 80, 100):
    vals = []; alive = 0; hit = 0
    for traj, yrs, ended in paths:
        ks = [k for k in traj if k <= Y]
        if not ks: continue
        last = traj[max(ks)]
        vals.append(last)
        if max(ks) == Y: alive += 1
        if any(v >= 100 for k, v in traj.items() if k <= Y): hit += 1
    rows.append((Y, round(st.mean(vals), 1), round(100 * alive / n), round(100 * hit / n)))
    print(Y, rows[-1])
first100 = [min(k for k, v in t.items() if v >= 100) for t, _, _ in paths if any(v >= 100 for v in t.values())]
print('reached 100:', len(first100), 'of', n, 'median year', st.median(first100) if first100 else None, 'min', min(first100) if first100 else None)
json.dump({'rows': rows, 'first100': first100}, open(os.path.join(os.path.dirname(__file__), '..', 'opt', 'longrun.json'), 'w'))
