"""Validate the Python VM on long policy-driven games."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import probe, pyvm, policy as P
from skoolkit.simutils import A, F, SP

def capture(pol, seed, maxframes):
    out = {'rnd': [], 'nat': []}
    def hrnd(sim):
        out['rnd'].append(sim.registers[A])
    def hnat(sim):
        r = sim.registers; m = sim.memory
        sp = r[SP]; oldpc = m[sp] | m[sp + 1] << 8
        nat = m[oldpc] | m[oldpc + 1] << 8
        out['nat'].append((nat, probe.var(m, 35), m[33896], bool(r[F] & 64), m[33892], probe.var(m, 6), probe.var(m, 11),
                           bytes(m[33552:33552 + 4 * 37]) if nat == 26740 else None, bytes(m[33888:33898])))
        if nat == 26740:
            return False
    WIN = {28371: 0xAF, 28372: 0, 28373: 0}
    probe.run_policy(pol, 30486, hrnd, maxframes, seed, pokes=WIN)
    sim, f = probe.run_policy(pol, 30328, hnat, maxframes, seed, pokes=WIN)
    return out, f

if __name__ == '__main__':
    import validate
    pol = P.Policy(kick_frac=float(os.environ.get('KICK','0.15')), ammo_mult=float(os.environ.get('AMMO','0.6')), squeeze_frac=0.9)
    for seed in [int(x) for x in sys.argv[1:]]:
        cap, f = capture(pol, seed, 120000)
        fin = [e for e in cap['nat'] if e[0] == 26740]
        print('seed', seed, 'frames', f, 'natives', len(cap['nat']), 'rnd', len(cap['rnd']),
              'hitman', [e[4] for e in cap['nat'] if e[0] == 28358], 'years', cap['nat'][-1][5])
        if not fin:
            print('  game did not finish'); continue
        vm = validate.replay(cap)
        z = bytes(vm.mem[33552:33552 + 4 * 37])
        diffs = [n for n in range(37) if z[4*n:4*n+4] != fin[0][7][4*n:4*n+4]]
        print('  score', vm.var(15) / 100, 'DIFF' if diffs else 'vars match', diffs,
              'flags match' if bytes(vm.mem[33888:33898]) == fin[0][8] else 'FLAGS DIFFER')
