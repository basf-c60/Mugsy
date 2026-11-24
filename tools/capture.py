"""Capture RNG results (RND ops) and native results from a Z80 simulation of one game."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import probe
from skoolkit.simutils import PC, A, F, SP, H, L

def capture(seed, maxframes=30000, yn='N'):
    out = {'rnd': [], 'nat': []}
    for stopaddr, kind in ((30486, 'rnd'), (30328, 'nat')):
        sim, f = run_collect(seed, stopaddr, kind, out[kind], maxframes, yn)
    return out, sim

def run_collect(seed, stopaddr, kind, lst, maxframes, yn):
    # reuse probe.run internals with a custom loop
    import types
    res = {}
    def hook(sim):
        r = sim.registers; m = sim.memory
        if kind == 'rnd':
            lst.append(r[A])
        else:
            sp = r[SP]; oldpc = m[sp] | m[sp + 1] << 8
            nat = m[oldpc] | m[oldpc + 1] << 8
            lst.append((nat, probe.var(m, 35), m[33896], bool(r[F] & 64), m[33892], probe.var(m, 6), probe.var(m, 11), bytes(m[33552:33552+4*37]) if nat == 26740 else None, bytes(m[33888:33898])))
    sim, f = probe.run_hook(seed, stopaddr, hook, maxframes, yn)
    return sim, f

if __name__ == '__main__':
    seed = int(sys.argv[1])
    out, sim = capture(seed)
    print(len(out['rnd']), len(out['nat']))
    print(out['nat'][:40])
