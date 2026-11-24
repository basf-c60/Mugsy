"""Coordinate-wise refinement of a strategy with common random numbers.

Objective: mean score if the player plays H years and then ends the game
(or the score at death if Mugsy dies earlier). With 'fixed', the game length
is rounded to a whole number as the author intended, and the game ends by itself.
"""
import sys, os, random, statistics as st, json
sys.path.insert(0, os.path.dirname(__file__))
import pyvm, optimise as O

def game(x, seed, H, p=1.0, fixed=False):
    rng = random.Random(seed)
    def hm(vm, lvl):
        return 1 if rng.random() < p else 3
    r = pyvm.play(O.Strat(x), rng=rng, maxyears=H, hitman_fn=hm, score_each_year=False, fix_years=fixed)
    if r.get('froze'):
        return 0.0, r['years']
    if r['ended']:
        return r['score'], r['years']
    return pyvm.score_now(r['vm']), r['years']

def evaluate(x, H, n=200, p=1.0, fixed=False, seed0=0):
    s = [game(x, seed0 + i, H, p, fixed) for i in range(n)]
    return st.mean(a for a, _ in s), st.mean(b for _, b in s)

STEPS = {'ammo': [-0.6, -0.3, -0.15, 0.15, 0.3, 0.6], 'ratio': [-15, -6, -3, 3, 6, 15], 'buyf': [-0.3, -0.15, 0.15, 0.3],
         'sq': [-0.2, -0.1, 0.1], 'kick': [-0.3, -0.15, -0.07, 0.07, 0.15, 0.3], 'keep': [-100, -40, 40, 100],
         'loan': [-1, 1], 'cap': [-1, 1]}

def refine(x, H, n=200, p=1.0, fixed=False, rounds=3, log=print):
    names = [q[0] for q in O.PARAMS]
    best = list(x); bs = evaluate(best, H, n, p, fixed)[0]
    log('start', round(bs, 2))
    for rd in range(rounds):
        improved = False
        for i, nm in enumerate(names):
            for dv in STEPS[nm]:
                c = list(best); c[i] += dv
                c = O.clip(c)
                if c == best:
                    continue
                s = evaluate(c, H, n, p, fixed)[0]
                if s > bs + 0.05:
                    best, bs = c, s; improved = True
                    log(rd, nm, round(bs, 2), [round(v, 2) for v in best])
        if not improved:
            break
    return best, bs

if __name__ == '__main__':
    H = int(sys.argv[1]); fixed = len(sys.argv) > 2 and sys.argv[2] == 'fixed'
    p = float(sys.argv[3]) if len(sys.argv) > 3 else 1.0
    import os as _o
    if _o.environ.get('START'):
        start = json.loads(_o.environ['START'])
    else:
      start = [1.814424406823444, 11.743367170205252, 0.43283800792163757, 1.0, 0.440214017670775, 0.0, 0.37964617679294393, 0.5629783522393407]
    if fixed and not _o.environ.get('START'):
        start = [1.8355557914907574, 22.31817714463693, 0.7930891644211768, 0.9717343222310626, 0.7878409483104426, 0.0, 0.10342657261852613, 0.49134032880092876]
    best, bs = refine(start, H, 150, p, fixed, log=lambda *a: print(*a, flush=True))
    test = evaluate(best, H, 400, p, fixed, seed0=50000)
    base = evaluate(start, H, 400, p, fixed, seed0=50000)
    print('BEST', json.dumps({'H': H, 'fixed': fixed, 'p': p, 'x': best, 'train': bs, 'test': test[0], 'years': test[1], 'start_test': base[0]}), flush=True)
