import sys, os, random, collections
sys.path.insert(0, os.path.dirname(__file__))
import pyvm, optimise as O
CAUSE = {49984: 'mob walked out (9 or fewer hoods)', 50520: "Cousin Abe (not enough ammo)",
         50203: 'Nick the Greek takes over (loan)', 50289: "exactly 10 grand after paying Nick",
         51534: 'safe empty after buying', 50434: 'killed by the hit man', 52607: 'time limit (whole-number game length)'}
def cause(r):
    if r.get('froze'):
        return 'game froze (SQRT)'
    for msg, ex in reversed(r['says'][-8:]):
        if msg in CAUSE:
            return CAUSE[msg]
    return 'still playing at the year limit' if not r['ended'] else 'other'
def survey(x, n=300, p=1.0, ymax=40):
    c = collections.Counter(); yrs = []
    for i in range(n):
        rng = random.Random(20000 + i)
        def hm(vm, lvl, rng=rng):
            if vm.var(6) / 100 >= ymax: return 3
            return 1 if rng.random() < p else 3
        r = pyvm.play(O.Strat(x), rng=rng, maxyears=ymax + 3, hitman_fn=hm, score_each_year=False)
        c[cause(r) if not (r['vm'].var(6)/100 >= ymax and cause(r)=='killed by the hit man') else 'stopped at year limit'] += 1
    return c
if __name__ == '__main__':
    x = [1.814424406823444, 11.743367170205252, 0.43283800792163757, 1.0, 0.440214017670775, 0.0, 0.37964617679294393, 0.5629783522393407]
    for k, v in survey(x).most_common(): print('%4d %s' % (v, k))
