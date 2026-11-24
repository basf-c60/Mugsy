"""Run Mugsy in SkoolKit's simulator with scripted keypresses.

Usage: python3 -I sim.py SNAPSHOT OUTDIR FRAMES [keyscript]
keyscript: comma separated items 'frame:KEY:dur' e.g. 100:ENTER:5,200:1:5
Writes execmap (set of executed addresses) as text and periodic screenshots.
"""
import sys, os, random, json
from skoolkit import CSimulator, read_bin_file
from skoolkit.snapshot import get_snapshot
from skoolkit.pngwriter import PngWriter
from skoolkit.graphics import Frame, Udg
from skoolkit.image import ImageWriter

ROWS = ['CAPS SHIFT Z X C V', 'A S D F G', 'Q W E R T', '1 2 3 4 5',
        '0 9 8 7 6', 'P O I U Y', 'ENTER L K J H', 'SPACE SYM M N B']
KEYMAP = {}
for i, r in enumerate(ROWS):
    names = r.replace('CAPS SHIFT', 'CAPS').replace('SYM', 'SYM').split()
    for b, n in enumerate(names):
        KEYMAP[n] = (i, 1 << b)

class Tracer:
    def __init__(self):
        self.keyboard = [0] * 8
        self.border = 0
    def read_port(self, registers, port):
        if port % 2 == 0:
            h = (port // 256) ^ 0xFF
            v = 0x40
            i = 0
            while h:
                if h % 2:
                    v |= self.keyboard[i]
                h //= 2
                i += 1
            return v ^ 0xFF
        return 0xFF

def screen_png(scr, path):
    iw = ImageWriter()
    udgs = []
    for y in range(24):
        row = []
        for x in range(32):
            attr = scr[6144 + 32 * y + x]
            data = [scr[((y & 24) << 8) + ((y & 7) << 5) + (k << 8) + x] for k in range(8)]
            row.append(Udg(attr, data))
        udgs.append(row)
    with open(path, 'wb') as f:
        iw.write_image([Frame(udgs, 1)], f)

def main():
    snap, outdir, frames = sys.argv[1], sys.argv[2], int(sys.argv[3])
    script = sys.argv[4] if len(sys.argv) > 4 else ''
    shots = set(int(x) for x in sys.argv[5].split(',')) if len(sys.argv) > 5 else set()
    os.makedirs(outdir, exist_ok=True)
    s = get_snapshot(snap)
    mem = bytearray(65536)
    mem[:16384] = read_bin_file('/usr/local/lib/python3.13/site-packages/skoolkit/resources/48.rom') if os.path.exists('/usr/local/lib/python3.13/site-packages/skoolkit/resources/48.rom') else bytes(16384)
    mem[16384:] = bytes(s[16384:65536])
    from skoolkit.snapshot import Snapshot
    sn = Snapshot.get(snap)
    regs = {'PC': 24576, 'SP': 23552, 'IY': 23610, 'A': 0, 'F': 0}
    sim = CSimulator(mem, regs, {'im': 1, 'iff': 0, 'tstates': 0})
    tr = Tracer()
    sim.set_tracer(tr)
    events = []
    for item in filter(None, script.split(',')):
        f, k, d = item.split(':')
        events.append((int(f), k, int(d)))
    execmap = set()
    state = {'n': 0}
    rnd = random.Random(int(os.environ.get('SEED','1')))

    rmode = os.environ.get('RANDKEYS')
    keyset = (os.environ.get('KEYSET') or '0 1 2 3 4 5 6 7 8 9 ENTER Y N SPACE').split()
    cur = {'k': None, 'until': 0}
    def draw(scr, frame, border, keyboard):
        state['n'] = frame
        tr.keyboard[:] = [0] * 8
        if rmode == '2' and frame > 50:
            if frame >= cur['until']:
                if cur['k'] is None:
                    if not cur.get('q'):
                        r = rnd.random()
                        if r < 0.15: toks = [rnd.choice(os.environ.get('YN','YN'))]
                        elif r < 0.25: toks = []
                        else:
                            n = rnd.choice([0, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, rnd.randint(0, 3000)])
                            toks = list(str(n))
                        cur['q'] = toks + ['ENTER']
                    cur['k'] = cur['q'].pop(0); cur['until'] = frame + 3
                else:
                    cur['k'] = None; cur['until'] = frame + (rnd.randint(30, 120) if not cur.get('q') else 4)
            if cur['k']:
                r, b = KEYMAP[cur['k']]; tr.keyboard[r] |= b
        elif rmode and frame > 50:
            if frame >= cur['until']:
                if cur['k'] is None:
                    cur['k'] = rnd.choice(keyset); cur['until'] = frame + 4
                else:
                    cur['k'] = None; cur['until'] = frame + rnd.randint(3, 25)
            if cur['k']:
                r, b = KEYMAP[cur['k']]; tr.keyboard[r] |= b
        for f, k, d in events:
            if f <= frame < f + d:
                for kk in k.split('+'):
                    r, b = KEYMAP[kk]
                    tr.keyboard[r] |= b
        if frame in shots or (not shots and frame % 250 == 0):
            screen_png(scr, os.path.join(outdir, f'f{frame:06d}.png'))
        return frame < frames

    sim.trace(24576, 65536, 0, 0, 1, draw, execmap, tr.keyboard, None, None)
    with open(os.path.join(outdir, 'execmap.txt'), 'w') as f:
        f.write('\n'.join(str(a) for a in sorted(execmap)))
    open(os.path.join(outdir, 'mem.bin'), 'wb').write(bytes(sim.memory[0:65536]))
    print('executed', len(execmap), 'PC', sim.registers[24])

if __name__ == '__main__':
    main()
