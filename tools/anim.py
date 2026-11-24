"""Record the two 'A year goes by' animations (bar room and getaway car) as GIFs.
usage: python3 -I anim.py OUTDIR"""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from skoolkit import CSimulator
from skoolkit.simutils import PC, ROM48
from sim import Tracer
from PIL import Image
ROOT = '/home/claude/mugsy'
RET = 23700
PAL = [(0,0,0),(0,0,205),(205,0,0),(205,0,205),(0,205,0),(0,205,205),(205,205,0),(205,205,205)]
BRI = [(0,0,0),(0,0,255),(255,0,0),(255,0,255),(0,255,0),(0,255,255),(255,255,0),(255,255,255)]
def to_image(scr):
    im = Image.new('RGB', (256, 192))
    px = im.load()
    for y in range(192):
        base = ((y & 0xC0) << 5) + ((y & 7) << 8) + ((y & 0x38) << 2)
        for cx in range(32):
            b = scr[base + cx]
            a = scr[6144 + (y >> 3) * 32 + cx]
            pal = BRI if a & 64 else PAL
            ink, paper = pal[a & 7], pal[(a >> 3) & 7]
            for k in range(8):
                px[cx * 8 + k, y] = ink if b & (128 >> k) else paper
    return im
def record(ix, path, step=3, maxframes=1500):
    mem = bytearray(65536); mem[:16384] = open(ROM48, 'rb').read()
    mem[16384:] = open(os.path.join(ROOT, 'work', 'mem.bin'), 'rb').read()[:49152]
    mem[RET:RET + 2] = bytes([0x18, 0xFE])
    mem[53457] = 34069 & 255; mem[53458] = 34069 >> 8   # interrupt jump -> ISR1
    mem[33993] = 0
    sp = 23552
    mem[sp - 2] = RET & 255; mem[sp - 1] = RET >> 8
    regs = {'PC': 34040, 'SP': sp - 2, 'IY': 23610, 'IX': ix, 'I': 209, 'A': 0, 'F': 0}
    sim = CSimulator(mem, regs, {'im': 2, 'iff': 1, 'tstates': 0})
    tr = Tracer(); sim.set_tracer(tr)
    frames = []
    def draw(scr, frame, border, kb):
        if frame % step == 0:
            frames.append(to_image(bytes(sim.memory[16384:16384 + 6912])))
        return frame < maxframes and sim.registers[PC] != RET
    sim.trace(34040, RET, 0, 0, 1, draw, set(), tr.keyboard, None, None)
    frames = frames[3:]
    frames = [f.resize((384, 288), Image.NEAREST).convert('P', palette=Image.ADAPTIVE) for f in frames]
    frames[0].save(path, save_all=True, append_images=frames[1:], duration=20 * step, loop=0)
    return len(frames)
if __name__ == '__main__':
    out = sys.argv[1]; os.makedirs(out, exist_ok=True)
    print('bar', record(36348, os.path.join(out, 'baranim.gif')))
    print('car', record(34298, os.path.join(out, 'caranim.gif')))
