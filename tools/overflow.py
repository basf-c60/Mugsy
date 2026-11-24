"""Check on the real Z80 code that buying ~3 million clients overflows the cost and pays the player.
usage: python3 -I overflow.py [clients|-GRAND] [frames] [seed]
(a negative first argument -M means: choose the number of clients that makes the game pay M grand)"""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import probe, policy as P
n = int(sys.argv[1]) if len(sys.argv) > 1 else 3000000
seed = int(sys.argv[3]) if len(sys.argv) > 3 else 1
frames = int(sys.argv[2]) if len(sys.argv) > 2 else 4000
calls = {'n': 0}
def buy(V):
    calls['n'] += 1
    if calls['n'] != 1: return 0
    if n < 0:
        print('price', V[34], 'clients bought', round((42949672.96 + n) / V[34]))
        return round((42949672.96 + n) / V[34])
    return n
pol = P.Policy(buy_frac=buy)
log = []
last = {}
def after(scr, frame, sim):
    m = sim.memory
    cur = (probe.var(m, 6), probe.var(m, 7), probe.var(m, 8), probe.var(m, 34))
    if cur != last.get('v'):
        log.append((frame,) + cur); last['v'] = cur
sim, f = probe.run_policy(pol, 33994, lambda s: True, maxframes=frames, seed=seed, after=after)
print('frames', f)
for l in log[:30]:
    print('frame %5d  year %g  safe %g  clients %g  price %g' % l)
