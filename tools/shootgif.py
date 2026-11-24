"""Record the restaurant shootout (42112) as an animated GIF, with scripted keys.
usage: python3 -I shootgif.py OUT.gif [frames] [handout]"""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from skoolkit import CSimulator
from skoolkit.simutils import PC, ROM48
from sim import Tracer, KEYMAP
from anim import to_image
ROOT = '/home/claude/mugsy'
RET = 23700
def record(path, maxframes=700, a_in=7, step=2):
    mem = bytearray(65536); mem[:16384] = open(ROM48, 'rb').read()
    mem[16384:] = open(os.path.join(ROOT, 'work', 'mem.bin'), 'rb').read()[:49152]
    mem[RET:RET + 2] = bytes([0x18, 0xFE])
    sp = 23552
    mem[sp - 2] = RET & 255; mem[sp - 1] = RET >> 8
    regs = {'PC': 42112, 'SP': sp - 2, 'IY': 23610, 'A': a_in, 'F': 0}
    sim = CSimulator(mem, regs, {'im': 1, 'iff': 0, 'tstates': 0})
    tr = Tracer(); sim.set_tracer(tr)
    # a simple script: shuffle left and right and keep firing
    script = []
    f = 20
    for k in ['P', 'P', 'Q', 'I', 'I', 'Z', 'P', 'Q', 'I', 'Z', 'P', 'P']:
        script.append((f, k, 25)); f += 45
    fire = [(g, 'M', 6) for g in range(30, 900, 24)]
    frames = []
    def draw(scr, frame, border, kb):
        tr.keyboard[:] = [0] * 8
        for s, k, d in script + fire:
            if s <= frame < s + d:
                r, b = KEYMAP[k]; tr.keyboard[r] |= b
        if frame % step == 0:
            frames.append(to_image(bytes(sim.memory[16384:16384 + 6912])))
        return frame < maxframes and sim.registers[PC] != RET
    sim.trace(42112, RET, 0, 0, 1, draw, set(), tr.keyboard, None, None)
    res = sim.registers[0] >> 8
    from PIL import Image
    fr = [x.resize((384, 288), Image.NEAREST).convert('P', palette=Image.ADAPTIVE) for x in frames]
    fr[0].save(path, save_all=True, append_images=fr[1:], duration=20 * step, loop=0)
    return len(fr), res
if __name__ == '__main__':
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 700
    h = int(sys.argv[3]) if len(sys.argv) > 3 else 7
    print(record(sys.argv[1], n, h))
