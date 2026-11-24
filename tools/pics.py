"""Render the game's pictures by running its own picture routines in the simulator.
usage: python3 -I pics.py OUTDIR"""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from skoolkit import CSimulator
from skoolkit.simutils import PC, ROM48
from sim import Tracer, screen_png
ROOT = '/home/claude/mugsy'
RET = 23700
def render(entry, reg, val, path, maxframes=400):
    mem = bytearray(65536); mem[:16384] = open(ROM48, 'rb').read()
    mem[16384:] = open(os.path.join(ROOT, 'work', 'mem.bin'), 'rb').read()[:49152]
    mem[RET:RET + 2] = bytes([0x18, 0xFE])
    sp = 23552
    mem[sp - 2] = RET & 255; mem[sp - 1] = RET >> 8
    # clear the screen first (the game does this before each picture)
    mem[16384:16384 + 6144] = bytes(6144); mem[22528:22528 + 768] = bytes([56]) * 768
    regs = {'PC': entry, 'SP': sp - 2, 'IY': 23610, 'A': 0, 'F': 0, reg: val}
    sim = CSimulator(mem, regs, {'im': 1, 'iff': 0, 'tstates': 0})
    tr = Tracer(); sim.set_tracer(tr)
    n = [0]
    def draw(scr, frame, border, kb):
        n[0] = frame
        return frame < maxframes and sim.registers[PC] != RET
    sim.trace(entry, RET, 0, 0, 1, draw, set(), tr.keyboard, None, None)
    screen_png(bytes(sim.memory[16384:16384 + 6912]), path)
    return n[0], sim.registers[PC]
if __name__ == '__main__':
    out = sys.argv[1]; os.makedirs(out, exist_ok=True)
    for a in (53793, 55692):
        print(a, render(32126, 'HL', a, os.path.join(out, 'pic%d.png' % a)))
    for a in (57583, 58673, 59397, 60526, 61625, 63601, 64646):
        print(a, render(31247, 'IY', a, os.path.join(out, 'pic%d.png' % a)))
