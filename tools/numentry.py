"""Type a number into the game's number-entry routine (27790) and show what it makes of it.
usage: python3 -I numentry.py TEXT ..."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from skoolkit import CSimulator
from skoolkit.simutils import PC, ROM48
from sim import Tracer, KEYMAP
ROOT = '/home/claude/mugsy'
RET = 23700
def run(text, maxframes=900):
    mem = bytearray(65536); mem[:16384] = open(ROM48, 'rb').read()
    mem[16384:] = open(os.path.join(ROOT, 'work', 'mem.bin'), 'rb').read()[:49152]
    mem[RET:RET + 2] = bytes([0x18, 0xFE])
    mem[23552:23560] = b'\xff' * 8
    mem[23561] = 35; mem[23562] = 5
    mem[33900] = 23610 & 255; mem[33901] = 23610 >> 8
    sp = 23500
    mem[sp - 2] = RET & 255; mem[sp - 1] = RET >> 8
    regs = {'PC': 27790, 'SP': sp - 2, 'IY': 23610, 'A': 0, 'F': 0}
    sim = CSimulator(mem, regs, {'im': 1, 'iff': 1, 'tstates': 0})
    tr = Tracer(); sim.set_tracer(tr)
    SPECIAL = {'.': 'SYM+M', '-': 'SYM+J', '+': 'SYM+K', ' ': 'SPACE'}
    keys = [SPECIAL.get(c, c.upper()) for c in text] + ['ENTER']
    st = {'n': 0}
    def draw(scr, frame, border, kb):
        st['n'] = frame
        tr.keyboard[:] = [0] * 8
        k = (frame - 20) // 8
        if frame >= 20 and (frame - 20) % 8 < 4 and k < len(keys):
            for kk in keys[k].split('+'):
                r, b = KEYMAP[kk]; tr.keyboard[r] |= b
        return frame < maxframes and sim.registers[PC] != RET
    sim.trace(27790, RET, 0, 0, 1, draw, set(), tr.keyboard, None, None)
    m = sim.memory
    v = lambda i: int.from_bytes(bytes(m[33552 + 4 * i:33556 + 4 * i]), 'little', signed=True)
    return sim.registers[PC] == RET, m[33896], v(35), st['n']
if __name__ == '__main__':
    for t in sys.argv[1:]:
        print(t, run(t))
