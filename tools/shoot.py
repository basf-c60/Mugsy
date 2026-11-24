"""Run the shootout routine (42112) directly in the Z80 simulator.
usage: python3 -I shoot.py A_INPUT FRAMES [keyscript]  -> prints HP vars per frame change"""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from skoolkit import CSimulator
from skoolkit.simutils import PC, SP, ROM48
from sim import Tracer, KEYMAP, screen_png
ROOT = '/home/claude/mugsy'

def run(a_in, frames, keys=None, shots=(), outdir='/tmp/shoot', quiet=False):
    mem = bytearray(65536); mem[:16384] = open(ROM48, "rb").read()
    mem[16384:] = open(os.path.join(ROOT, 'work', 'mem.bin'), 'rb').read()[:49152]
    mem[23700:23702] = bytes([0x18, 0xFE])           # JR $ : return address
    sp = 23552
    mem[sp - 2] = 23700 & 255; mem[sp - 1] = 23700 >> 8
    regs = {'PC': 42112, 'SP': sp - 2, 'IY': 23610, 'A': a_in, 'F': 0}
    sim = CSimulator(mem, regs, {'im': 1, 'iff': 0, 'tstates': 0})
    tr = Tracer(); sim.set_tracer(tr)
    log = []
    last = {}
    st = {'n': 0}
    os.makedirs(outdir, exist_ok=True)
    def draw(scr, frame, border, keyboard):
        st['n'] = frame
        m = sim.memory
        cur = (m[42301], m[42302], m[42334], m[42335])
        if cur != last.get('v'):
            log.append((frame,) + cur); last['v'] = cur
        tr.keyboard[:] = [0] * 8
        if keys:
            for f, k, d in keys:
                if f <= frame < f + d:
                    for kk in k.split('+'):
                        r, b = KEYMAP[kk]; tr.keyboard[r] |= b
        if frame in shots:
            screen_png(scr, os.path.join(outdir, 'f%05d.png' % frame))
        return frame < frames and sim.registers[PC] != 23700
    sim.trace(42112, 23700, 0, 0, 1, draw, set(), tr.keyboard, None, None)
    return log, sim.registers[0] if False else None, st['n']

if __name__ == '__main__':
    a = int(sys.argv[1]); fr = int(sys.argv[2])
    log, _, n = run(a, fr)
    print('frames', n)
    for l in log: print(l)
