import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import probe, policy as P
from sim import screen_png
out = sys.argv[1]
os.makedirs(out, exist_ok=True)
pol = P.Policy(kick_frac=0.15, ammo_mult=1.5, squeeze_frac=0.9)
state = {'poked': False, 'rating': None}
def hook(sim):
    m = sim.memory
    if not state['poked']:
        v = 25000
        for i in range(4): m[33552 + 4 * 12 + i] = (v >> (8 * i)) & 255   # v12 (total blunders) = 250
        state['poked'] = True
    return True
def after(scr, frame, sim):
    m = sim.memory
    vpc = m[30090] | m[30091] << 8
    if vpc == 26727 and state['rating'] is None:
        state['rating'] = frame
    if state['rating'] is not None and frame in (state['rating'] + 30, state['rating'] + 120):
        screen_png(scr, os.path.join(out, 'rating_%d.png' % frame))
sim, f = probe.run_policy(pol, 33994, hook, maxframes=60000, seed=3, after=after)
print('frames', f, 'rating shown at', state['rating'], 'score', probe.var(sim.memory, 15), 'v33', probe.var(sim.memory, 33))
