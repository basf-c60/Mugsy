import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import capture, pyvm

class Stop(Exception): pass

def replay(cap):
    nat = list(cap['nat'])
    raw = iter(cap['rnd'])
    vm = pyvm.VM(raw=raw)
    q = [n for n in nat]
    def strategy(vm_, kind, prompt):
        while q and q[0][0] not in (27790, 27753):
            q.pop(0)
        e = q.pop(0)
        if kind == 'number':
            vm_._fix11 = e[6]
            return e[1]
        return e[3]
    vm.strategy = strategy
    vm.hitman = lambda vm_, lvl: next(e[4] for e in nat if e[0] == 28358)
    orig = vm.native
    def native(addr):
        orig(addr)
        if addr == 27790:
            vm.setvar(11, int(round(vm._fix11 * 100)))
        if addr == 26740:
            raise Stop()
    vm.native = native
    try:
        vm.init(); vm.run(24609)
        while True:
            vm.run(24652)
    except Stop:
        pass
    return vm

if __name__ == '__main__':
    bad = 0
    for seed in [int(x) for x in sys.argv[1:]]:
        cap, sim = capture.capture(seed)
        final = next(e for e in cap['nat'] if e[0] == 26740)
        vm = replay(cap)
        z = bytes(vm.mem[33552:33552 + 4 * 37])
        diffs = [n for n in range(37) if z[4*n:4*n+4] != final[7][4*n:4*n+4]]
        fl = bytes(vm.mem[33888:33898]) == final[8]
        print('seed', seed, 'years', vm.var(6) / 100, 'score', vm.var(15) / 100, 'natives', len(cap['nat']), 'rnd', len(cap['rnd']),
              'DIFF vars' if diffs else 'vars match', diffs, 'flags match' if fl else 'FLAGS DIFFER')
