import sys, os, statistics as st
sys.path.insert(0, os.path.dirname(__file__))
import pyvm, policy as P

def evaluate(pol, n=200, hitman_p=1.0, maxyears=25, seed0=0):
    best = []; surv = []; peak_year = []
    for i in range(n):
        r = pyvm.play(pol, seed=seed0 + i, hitman_p=hitman_p, maxyears=maxyears)
        h = r['history']
        m = max((x['score_if_died'] for x in h), default=r['score'])
        best.append(m); surv.append(r['years'])
        peak_year.append(max(h, key=lambda x: x['score_if_died'])['year'] if h else 0)
    return st.mean(best), st.mean(surv), st.median(peak_year)

if __name__ == '__main__':
    base = dict(kick_frac=0.3, ammo_mult=3.0, squeeze_frac=1.0, buy_frac=0.0)
    for k in ('ammo_mult', 'kick_frac', 'buy_frac', 'squeeze_frac'):
        vals = {'ammo_mult': [0.5, 1, 1.5, 2, 3, 4, 6, 10], 'kick_frac': [0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0],
                'buy_frac': [0, 0.1, 0.25, 0.5, 0.75, 0.9], 'squeeze_frac': [0.4, 0.6, 0.8, 1.0]}[k]
        for v in vals:
            p = dict(base); p[k] = v
            b, s, py = evaluate(P.Policy(**p), n=150)
            print('%-12s %5s  mean best score %6.2f  mean years %5.2f  median peak year %s' % (k, v, b, s, py))
        print()
