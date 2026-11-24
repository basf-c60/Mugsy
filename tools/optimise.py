"""Search for good Mugsy strategies with the exact Python VM."""
import sys, os, math, random, statistics as st, json
sys.path.insert(0, os.path.dirname(__file__))
import pyvm, policy as P

PARAMS = [  # name, lo, hi
    ('ammo', 0.5, 6.0),        # ammo = ceil(ammo*hoods)
    ('ratio', 3.0, 80.0),      # target clients per hood when buying
    ('buyf', 0.0, 1.0),        # max fraction of spare dough to spend on clients
    ('sq', 0.34, 1.0),         # fraction of available clients to squeeze
    ('kick', 0.0, 1.0),        # fraction of remaining dough paid as kickback
    ('keep', 0.0, 400.0),      # dough kept back from the kickback
    ('loan', 0.0, 1.0),        # >0.5: borrow from Nick to squeeze everybody
    ('cap', 0.0, 1.0),         # >0.5: allow squeezing past 40*hoods (the 50*hoods rule)
]

class Strat(P.Policy):
    def __init__(self, x):
        super().__init__()
        self.x = dict(zip([p[0] for p in PARAMS], x))

    def answer(self, q, V, F):
        x = self.x
        h, c, d, price = V[3], V[8], V[7], V[34]
        if q == 'handout':
            return P.easiest_handout(h)
        if q == 'rocco':
            return 1 if d - 1 > 5 else 0
        if q == 'buy':
            want = max(0, int(x['ratio'] * h - c))
            # money needed this year after buying: ammo + squeeze
            need = math.ceil(x['ammo'] * h) + min(c - h, 40 * h) * x['sq'] + 5
            spare = max(0, d - need) * x['buyf']
            n = int(min(want, spare // max(price, 1)))
            if n * price >= d:
                n = int((d - 1) // price)
            return max(0, n)
        if q == 'sell':
            return 0
        if q == 'ammo':
            a = math.ceil(x['ammo'] * h)
            a = max(math.ceil(h / 2) if h > 0 else 1, a)
            if a >= d:
                a = int(d) - 1
            while a in P.HANG:
                a -= 1
            return max(a, 0)
        if q == 'squeeze':
            avail = V[21]
            n = int(avail * x['sq'])
            n = max(n, int(avail / 3) + 1)
            n = min(n, int(avail))
            if x['cap'] <= 0.5:
                n = min(n, int(40 * h) - 1)
            if n > d:
                if x['loan'] > 0.5 and 20 <= n - d < 800:
                    return n
                n = int(d)
                if n <= avail / 3:
                    return 0 if d < 1 else n
            return max(n, 0)
        if q == 'kickback':
            k = int(max(0, (d - x['keep']) * x['kick']))
            k = max(0, min(k, int(d)))
            while (V[23] + k) in P.HANG:
                k = k - 1 if k > 0 else k + 1
            return k
        if q == 'again':
            return False
        raise ValueError(q)

def run_game(strat, seed, p=1.0, ymax=40, target=100.0):
    rng = random.Random(seed)
    res = {}
    def hitman(vm, lvl):
        s = pyvm.score_now(vm)
        if s >= target or vm.var(6) / 100 >= ymax:
            return 3                     # throw the fight: game over with this score
        return 1 if rng.random() < p else 3
    r = pyvm.play(strat, rng=rng, hitman_p=1.0, maxyears=ymax + 3)
    return r

def evaluate(x, n=100, p=1.0, ymax=40, seed0=0, target=100.0, fixed=False):
    scores = []; years = []; froze = 0
    for i in range(n):
        rng = random.Random(seed0 + i)
        strat = Strat(x)
        def hm(vm, lvl, rng=rng):
            s = pyvm.score_now(vm)
            if s >= target or vm.var(6) / 100 >= ymax:
                return 3
            return 1 if rng.random() < p else 3
        r = play_with(strat, rng, hm, ymax + 3, fixed)
        if r.get('froze'):
            froze += 1
        scores.append(r['score']); years.append(r['years'])
    return st.mean(scores), st.mean(years), froze

def play_with(strat, rng, hitman, maxyears, fixed=False):
    r = pyvm.play(strat, rng=rng, hitman_p=1.0, maxyears=maxyears, hitman_fn=hitman, score_each_year=False, fix_years=fixed)
    if not r['ended']:
        r['score'] = pyvm.score_now(r['vm'])
    return r

def rand_x(rng):
    return [rng.uniform(lo, hi) for _, lo, hi in PARAMS]

def clip(x):
    return [min(hi, max(lo, v)) for v, (_, lo, hi) in zip(x, PARAMS)]

def search(iters=60, n=60, p=1.0, ymax=40, seed=1, start=None, log=None, fixed=False):
    rng = random.Random(seed)
    best = start or rand_x(rng)
    bs = evaluate(best, n, p, ymax, fixed=fixed)[0]
    # random restarts first
    for i in range(iters):
        if i < iters // 3:
            cand = rand_x(rng)
        else:
            scale = 0.25 * (1 - i / iters) + 0.03
            cand = clip([v + rng.gauss(0, scale * (hi - lo)) for v, (_, lo, hi) in zip(best, PARAMS)])
        s = evaluate(cand, n, p, ymax, fixed=fixed)[0]
        if s > bs:
            best, bs = cand, s
            if log:
                log(i, bs, best)
    return best, bs

if __name__ == '__main__':
    p = float(sys.argv[1]) if len(sys.argv) > 1 else 1.0
    ymax = int(sys.argv[2]) if len(sys.argv) > 2 else 40
    seed = int(sys.argv[3]) if len(sys.argv) > 3 else 1
    iters = int(sys.argv[4]) if len(sys.argv) > 4 else 60
    fixed = len(sys.argv) > 5 and sys.argv[5] == 'fixed'
    def log(i, s, x):
        print(i, round(s, 2), [round(v, 2) for v in x], flush=True)
    best, bs = search(iters=iters, n=60, p=p, ymax=ymax, seed=seed, log=log, fixed=fixed)
    full = evaluate(best, 400, p, ymax, seed0=10000, fixed=fixed)
    print('BEST', json.dumps({'fixed': fixed, 'p': p, 'ymax': ymax, 'x': best, 'score_train': bs, 'score_test': full[0], 'years': full[1], 'froze': full[2]}))
