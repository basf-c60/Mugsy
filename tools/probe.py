"""Run Mugsy until PC hits STOP, then report VM variables.

python3 -I probe.py SEED STOP [maxframes] [pokes]
pokes: 'addr=val,...' applied to memory before running (e.g. to force variables).
Env: YN (Y/N bias), SHOT=1 to save a screenshot of the next 400 frames after stop.
"""
import sys, os, random
sys.path.insert(0, os.path.dirname(__file__))
from skoolkit import CSimulator, read_bin_file
from skoolkit.snapshot import get_snapshot
from skoolkit.simutils import PC

ROWS = ['CAPS Z X C V', 'A S D F G', 'Q W E R T', '1 2 3 4 5', '0 9 8 7 6', 'P O I U Y', 'ENTER L K J H', 'SPACE SYM M N B']
KEYMAP = {n: (i, 1 << b) for i, r in enumerate(ROWS) for b, n in enumerate(r.split())}

class Tracer:
    def __init__(self):
        self.keyboard = [0] * 8
        self.border = 0
    def read_port(self, registers, port):
        if port % 2 == 0:
            h = (port // 256) ^ 0xFF
            v = 0x40; i = 0
            while h:
                if h % 2: v |= self.keyboard[i]
                h //= 2; i += 1
            return v ^ 0xFF
        return 0xFF

def run(seed, stop, maxframes=60000, pokes=None, yn='YN', script=None, after=None, framepokes=None, says=None):
    rom = os.path.join(os.path.dirname(__import__('skoolkit').__file__), 'resources', '48.rom')
    mem = bytearray(65536)
    mem[:16384] = read_bin_file(rom)
    s = get_snapshot(os.path.join(os.path.dirname(__file__), '..', 'work', 'mugsy_tzx.z80'))
    mem[16384:] = bytes(s[16384:65536])
    for a, v in (pokes or {}).items():
        mem[a] = v
    sim = CSimulator(mem, {'PC': 24576, 'SP': 23552, 'IY': 23610}, {'im': 1, 'iff': 0, 'tstates': 0})
    tr = Tracer(); sim.set_tracer(tr)
    rnd = random.Random(seed)
    cur = {'k': None, 'until': 0, 'q': [], 'frame': 0}
    def draw(scr, frame, border, keyboard):
        cur['frame'] = frame
        tr.keyboard[:] = [0] * 8
        if frame > 50:
            if frame >= cur['until']:
                if cur['k'] is None:
                    if not cur['q']:
                        if script:
                            cur['q'] = script(rnd)
                        else:
                            r = rnd.random()
                            if r < 0.15: toks = [rnd.choice(yn)]
                            elif r < 0.25: toks = []
                            else:
                                n = rnd.choice([0, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, rnd.randint(0, 3000)])
                                toks = list(str(n))
                            cur['q'] = toks + ['ENTER']
                    cur['k'] = cur['q'].pop(0); cur['until'] = frame + 3
                else:
                    cur['k'] = None; cur['until'] = frame + (rnd.randint(30, 120) if not cur['q'] else 4)
            if cur['k']:
                r_, b = KEYMAP[cur['k']]; tr.keyboard[r_] |= b
        if framepokes and frame >= 5 and not cur.get('poked'):
            cur['poked'] = 1
            for a_, v_ in framepokes.items():
                sim.memory[a_] = v_
        if after:
            after(scr, frame)
        return frame < maxframes
    if says is None:
        sim.trace(24576, stop, 0, 0, 1, draw, None, tr.keyboard, None, None)
        return sim, cur['frame']
    from skoolkit.simutils import H, L
    pc = 24576
    while cur['frame'] < maxframes:
        sim.trace(pc, 28549, 0, 0, 1, draw, None, tr.keyboard, None, None)
        r = sim.registers
        if r[PC] != 28549:
            break
        says.append((cur['frame'], r[H] * 256 + r[L], var(sim.memory, 6)))
        if r[H] * 256 + r[L] in stop if isinstance(stop, (set, list, tuple)) else False:
            break
        # step over the first instruction of SAY by running to the next instruction
        sim.trace(28549, 28552, 0, 0, 1, draw, None, tr.keyboard, None, None)
        pc = sim.registers[PC]
    return sim, cur['frame']

def var(mem, n):
    a = 33552 + 4 * n
    v = mem[a] | mem[a + 1] << 8 | mem[a + 2] << 16 | mem[a + 3] << 24
    if v & 0x80000000: v -= 1 << 32
    return v / 100

if __name__ == '__main__':
    seed, stop = int(sys.argv[1]), int(sys.argv[2])
    sim, f = run(seed, stop, int(sys.argv[3]) if len(sys.argv) > 3 else 60000, yn=os.environ.get('YN', 'YN'))
    m = sim.memory
    print(seed, 'frame', f, 'PC', sim.registers[PC], 'v36', var(m, 36), 'v6', var(m, 6), 'v15', var(m, 15),
          'v33', var(m, 33), 'v3', var(m, 3), 'v7', var(m, 7))


def run_hook(seed, stopaddr, hook, maxframes=30000, yn='YN', stop_on=26740):
    """Run one game, calling hook(sim) each time PC reaches stopaddr; stop at the rating routine."""
    rom = os.path.join(os.path.dirname(__import__('skoolkit').__file__), 'resources', '48.rom')
    mem = bytearray(65536)
    mem[:16384] = read_bin_file(rom)
    s = get_snapshot(os.path.join(os.path.dirname(__file__), '..', 'work', 'mugsy_tzx.z80'))
    mem[16384:] = bytes(s[16384:65536])
    sim = CSimulator(mem, {'PC': 24576, 'SP': 23552, 'IY': 23610}, {'im': 1, 'iff': 0, 'tstates': 0})
    tr = Tracer(); sim.set_tracer(tr)
    rnd = random.Random(seed)
    cur = {'k': None, 'until': 0, 'q': [], 'frame': 0, 'base': 0}
    def draw(scr, frame, border, keyboard):
        frame = sim.registers[25] // 69888 if False else frame
        cur['frame'] = frame
        tr.keyboard[:] = [0] * 8
        if frame > 50:
            if frame >= cur['until']:
                if cur['k'] is None:
                    if not cur['q']:
                        r = rnd.random()
                        if r < 0.15: toks = [rnd.choice(yn)]
                        elif r < 0.25: toks = []
                        else:
                            n = rnd.choice([0, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, rnd.randint(0, 3000)])
                            toks = list(str(n))
                        cur['q'] = toks + ['ENTER']
                    cur['k'] = cur['q'].pop(0); cur['until'] = frame + 3
                else:
                    cur['k'] = None; cur['until'] = frame + (rnd.randint(30, 120) if not cur['q'] else 4)
            if cur['k']:
                r_, b = KEYMAP[cur['k']]; tr.keyboard[r_] |= b
        return frame < maxframes
    pc = 24576
    from skoolkit.opcodes import decode
    while True:
        sim.trace(pc, stopaddr, 0, 0, 1, draw, None, tr.keyboard, None, None)
        if sim.registers[PC] != stopaddr:
            break
        hook(sim)
        nxt = stopaddr + next(decode(sim.memory, stopaddr, stopaddr + 1))[1]
        sim.trace(stopaddr, nxt, 0, 0, 1, draw, None, tr.keyboard, None, None)
        pc = sim.registers[PC]
        if pc != nxt:
            break
    return sim, cur['frame']


def run_policy(policy, stopaddr, hook, maxframes=80000, seed=1, hitkeys=True, stop_on_rating=True, pokes=None, after=None):
    """Drive the Z80 game with a policy; call hook(sim) at stopaddr."""
    import policy as P
    rom = os.path.join(os.path.dirname(__import__('skoolkit').__file__), 'resources', '48.rom')
    mem = bytearray(65536)
    mem[:16384] = read_bin_file(rom)
    s = get_snapshot(os.path.join(os.path.dirname(__file__), '..', 'work', 'mugsy_tzx.z80'))
    mem[16384:] = bytes(s[16384:65536])
    for a_, v_ in (pokes or {}).items():
        mem[a_] = v_
    sim = CSimulator(mem, {'PC': 24576, 'SP': 23552, 'IY': 23610}, {'im': 1, 'iff': 0, 'tstates': 0})
    tr = Tracer(); sim.set_tracer(tr)
    rnd = random.Random(seed)
    cur = {'k': None, 'until': 0, 'q': [], 'frame': 0, 'lastq': None, 'qframe': 0, 'done': False}
    def draw(scr, frame, border, keyboard):
        cur['frame'] = frame
        tr.keyboard[:] = [0] * 8
        m = sim.memory
        vpc = m[30090] | m[30091] << 8
        q = P.Q.get(vpc)
        if frame >= cur['until']:
            if cur['k'] is not None:
                cur['k'] = None
                cur['until'] = frame + (4 if cur['q'] else 40)
            elif cur['q']:
                cur['k'] = cur['q'].pop(0); cur['until'] = frame + 3
            elif q:
                if cur['lastq'] != (vpc, cur['qframe']) and frame - cur['qframe'] > 25:
                    V = {n: var(m, n) for n in range(37)}
                    ans = policy.answer(q, V, bytes(m[33888:33898]))
                    if q == 'again':
                        toks = ['Y' if ans else 'N']
                    else:
                        toks = list(str(int(ans)))
                    cur['q'] = toks + ['ENTER']
                    cur['lastq'] = (vpc, cur['qframe'])
                    cur['until'] = frame
            elif vpc == 26021 and hitkeys:
                cur['k'] = rnd.choice(['Q', 'Z', 'I', 'P', 'M', 'M', 'Q+M', 'Z+M', 'I+M', 'P+M'])
                cur['until'] = frame + rnd.randint(2, 10)
            else:
                cur['k'] = 'ENTER'; cur['until'] = frame + 3
        if not q:
            cur['qframe'] = frame
        if cur['k']:
            for kk in cur['k'].split('+'):
                r_, b = KEYMAP[kk]; tr.keyboard[r_] |= b
        if after:
            after(scr, frame, sim)
        return frame < maxframes
    pc = 24576
    from skoolkit.opcodes import decode
    while True:
        sim.trace(pc, stopaddr, 0, 0, 1, draw, None, tr.keyboard, None, None)
        if sim.registers[PC] != stopaddr:
            break
        if hook(sim) is False:
            break
        nxt = stopaddr + next(decode(sim.memory, stopaddr, stopaddr + 1))[1]
        sim.trace(stopaddr, nxt, 0, 0, 1, draw, None, tr.keyboard, None, None)
        pc = sim.registers[PC]
        if pc != nxt:
            break
    return sim, cur['frame']
