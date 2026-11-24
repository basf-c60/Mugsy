"""Exact Python reimplementation of the Mugsy VM (game logic only).

The bytecode is executed from the memory image. Native routines are replaced
by Python callbacks: number input, yes/no, the hit man shootout and the
random number source are supplied by the caller.
"""
import os, sys, random
sys.path.insert(0, os.path.dirname(__file__))
import mugsylib as M

ROOT = os.path.join(os.path.dirname(__file__), '..')
_IMAGE = None

def image():
    global _IMAGE
    if _IMAGE is None:
        _IMAGE = bytes(M.load(os.path.join(ROOT, 'work', 'mem.bin')))
    return _IMAGE

MASK = 0xFFFFFFFF
def s32(v):
    v &= MASK
    return v - (1 << 32) if v & 0x80000000 else v

def rnd_byte_result(c, x):
    """Emulate 30026+30014 for limit c and raw byte x."""
    b = (c * 2) if c * 2 <= 255 else 255
    while x > b:
        x >>= 1
    a = (x - c) & 255
    if a & 128:
        a = (-a) & 255
    return a

class GameOver(Exception):
    pass

class VM:
    def __init__(self, rng=None, raw=None, strategy=None, hitman=None, log=None, maxsteps=200000):
        self.mem = bytearray(image())
        self.acc = 0
        self.alt = 0
        self.zf = False
        self.cf = False
        self.rng = rng or random.Random()
        self.raw = raw            # optional iterator of raw RNG results (already final A values)
        self.strategy = strategy  # callable(vm, kind, prompt_addr) -> value
        self.hitman = hitman      # callable(vm, level) -> True if Mugsy wins
        self.log = log
        self.last_say = None
        self.says = []
        self.steps = 0
        self.maxsteps = maxsteps
        self.inputs = []

    # ---------------------------------------------------------- memory
    def var(self, n):
        a = 33552 + 4 * n
        m = self.mem
        return s32(m[a] | m[a + 1] << 8 | m[a + 2] << 16 | m[a + 3] << 24)

    def setvar(self, n, v):
        a = 33552 + 4 * n
        v &= MASK
        for i in range(4):
            self.mem[a + i] = (v >> (8 * i)) & 255

    def w(self, a):
        return self.mem[a] | self.mem[a + 1] << 8

    # ---------------------------------------------------------- random
    def random_a(self, c):
        if self.raw is not None:
            return next(self.raw)
        return rnd_byte_result(c, self.rng.randrange(256))

    def op_rnd(self):
        e = self.acc & 255
        a = self.random_a(e)
        self.acc = s32((self.acc & ~255) | a)

    # ---------------------------------------------------------- arithmetic
    def signs(self):
        neg = 0
        if self.acc < 0:
            self.acc = s32(-self.acc); neg ^= 1
        if self.alt < 0:
            self.alt = s32(-self.alt); neg ^= 1
        return neg

    def mul(self):
        neg = self.signs()
        r = (self.acc * self.alt) // 100
        r = s32(r)
        self.acc = s32(-r) if neg else r

    def div(self):
        neg = self.signs()
        if self.alt == 0:
            self.acc = 0
            return
        r = s32((self.acc * 100) // self.alt)
        self.acc = s32(-r) if neg else r

    def int_(self):
        neg = self.signs()
        r = (self.acc // 100) * 100
        self.acc = s32(-r) if neg else r

    def sqrt(self):
        n = self.acc
        x = s32(n) >> 1
        seen = set()
        while True:
            # q = n*100/x via the divide routine (which also makes alt=|x|)
            self.acc, self.alt = n, x
            self.div()
            q = self.acc
            self.alt = q
            nx = s32(x + q) >> 1
            if nx == x:
                self.acc = nx
                return
            if (x, nx) in seen:
                raise RuntimeError('SQRT does not converge for %d' % n)
            seen.add((x, nx))
            x = nx

    def compare(self, v1, v2):
        """Flags of (v2 - v1) as computed by 30342."""
        a, b = self.var(v1), self.var(v2)
        self.acc = a
        self.zf = (a == b)
        self.cf = b < a

    # ---------------------------------------------------------- interpreter
    def fetch(self):
        b = self.mem[self.pc]; self.pc += 1; return b

    def fetchw(self):
        v = self.w(self.pc); self.pc += 2; return v

    def run(self, start):
        save = getattr(self, 'pc', None)
        self.pc = start
        while True:
            self.steps += 1
            if self.steps > self.maxsteps:
                raise RuntimeError('too many steps')
            a = self.pc
            op = self.fetch()
            if op == 0:
                break
            self.step(op, a)
        self.pc = save

    def jump_if(self, cond, addr):
        if cond:
            self.pc = addr

    def step(self, op, addr):
        if op == 1:
            msg = self.fetchw(); flags = self.fetch()
            t = M.decode_text(msg)
            extra = []
            for k in t.vmops:
                extra.append(self.fetchw() if k == 'msg' else self.fetch())
            self.last_say = msg
            self.says.append((msg, extra))
            if self.log:
                self.log(self, msg, t, extra)
        elif op == 2:
            self.mem[33898:33900] = self.fetchw().to_bytes(2, 'little')
        elif 3 <= op <= 8:
            v1 = self.fetch(); v2 = self.fetch(); tgt = self.fetchw()
            self.compare(v1, v2)
            z, c = self.zf, self.cf
            cond = {3: z, 4: not z, 5: not c, 6: (not z and not c), 7: c, 8: z or c}[op]
            self.jump_if(cond, tgt)
        elif op in (9, 10):
            ad = self.fetchw(); n = self.fetch(); tgt = self.fetchw()
            eq = self.mem[ad] == n
            self.zf = eq
            self.jump_if(eq if op == 9 else not eq, tgt)
        elif op == 11:
            n = self.fetch(); ad = self.fetchw(); self.mem[ad] = n
        elif op == 12:
            tgt = self.fetchw(); self.jump_if(self.zf, tgt)
        elif op == 13:
            self.pc = self.fetchw()
        elif op == 14:
            self.native(self.fetchw())
        elif op == 15:
            self.setvar(self.fetch(), self.acc)
        elif op in (16, 17, 18, 19, 20, 21, 22, 23, 24):
            base = (op - 16) // 3
            k = (op - 16) % 3
            if k == 1:
                self.alt = self.var(self.fetch())
            elif k == 2:
                self.acc = self.var(self.fetch()); self.alt = self.var(self.fetch())
            if base == 0:
                self.acc = s32(self.acc + self.alt)
            elif base == 1:
                self.acc = s32(self.acc - self.alt)
            else:
                self.mul()
        elif op == 25:
            self.alt = self.var(self.fetch()); self.div()
        elif op == 26:
            self.acc = self.var(self.fetch()); self.alt = self.var(self.fetch()); self.div()
        elif op == 27:
            self.int_()
        elif op == 28:
            self.acc = self.var(self.fetch())
        elif op == 29:
            self.op_rnd()
        elif op == 30:
            self.acc = self.var(self.fetch()); self.op_rnd()
        elif op == 31:
            self.acc = s32(-self.acc)
        elif op == 32:
            self.acc = s32(self.var(self.fetch())) >> 1
        elif op == 33:
            self.sqrt()
        elif op == 34:
            self.acc = self.var(self.fetch()); self.sqrt()
        else:
            raise RuntimeError('bad opcode %d at %d' % (op, addr))

    # ---------------------------------------------------------- natives
    def native(self, addr):
        if addr == 27790:     # get a number
            v = self.strategy(self, 'number', self.last_say)
            self.inputs.append((self.last_say, v))
            raw = int(round(v * 100))
            self.setvar(35, raw)
            if raw < 0: t = 1
            elif raw == 0: t = 2
            elif raw == 1: t = 3
            else: t = 4
            self.mem[33896] = t
            # flags on return come from the end of 27835 (not tested by the script)
        elif addr == 27753:   # yes/no
            v = self.strategy(self, 'yesno', self.last_say)
            self.inputs.append((self.last_say, v))
            self.zf = bool(v)
        elif addr == 28297:   # hush money
            self.run(28304)
        elif addr == 28358:   # hit man
            v = self.var(33)
            lvl = 8 if (v & ~255) else (v & 7) + 1
            # result: 1 = hit man killed, 2 = hit man killed but with bystanders, 3 = Mugsy killed
            res = self.hitman(self, lvl) if self.hitman else 1
            self.mem[33892] = res
        elif addr == 26740:   # rating word
            pass
        elif addr == 33994:   # "a year goes by" animation
            pass
        else:
            raise RuntimeError('unknown native %d' % addr)

    # ---------------------------------------------------------- game
    def init(self):
        """Emulate INITVARS (33937)."""
        self.mem[33552:33552 + 76] = self.mem[33812:33812 + 76]
        for a in range(33888, 33898):
            self.mem[a] = 1
        self.acc = 100
        self.op_rnd()
        self.alt = 400
        self.mul()
        self.alt = 700
        self.acc = s32(self.acc + self.alt)
        self.setvar(36, self.acc)

    def play(self, maxyears=60):
        """Play one game; returns the list of yearly variable snapshots."""
        self.init()
        self.run(24609)
        years = []
        while True:
            self.run(24652)
            years.append({n: self.var(n) / 100 for n in range(37)})
            if self.mem[33897] != 0 or self.ended():
                break
            if len(years) >= maxyears:
                break
        return years

    def ended(self):
        return False


class _Done(Exception):
    pass

def score_now(vm, died=True):
    """Score the game would get if it ended now (runs the scoring code at 26469 on a copy)."""
    c = VM(rng=vm.rng)
    c.mem = bytearray(vm.mem)
    c.acc, c.alt = vm.acc, vm.alt
    if died:
        c.mem[33890] = 2
    def nat(addr):
        if addr == 26740:
            raise _Done()
    c.native = nat
    try:
        c.run(26469 if died else 26513)
    except _Done:
        pass
    return c.var(15) / 100

def play(policy, seed=None, hitman_p=1.0, collateral=0.0, maxyears=40, quit_at=None, rng=None, trace=None, hitman_fn=None, score_each_year=True, fix_years=False):
    """Play one game with a policy.

    hitman_p: probability of winning a shootout (may be a function of level).
    quit_at: callable(vm, year, score_if_died) -> True to throw the game (lose the next shootout / walk out).
    Returns dict(score, years, cause, history).
    """
    import random as _r
    from policy import SAYQ
    rng = rng or _r.Random(seed)
    vm = VM(rng=rng)
    hist = []
    state = {'quit': False, 'last_q': None, 'asked': {}}
    def strategy(vm_, kind, prompt):
        q = SAYQ.get(prompt)
        if q is None:
            q = state['last_q']
        state['last_q'] = q
        V = {n: vm_.var(n) / 100 for n in range(37)}
        if q == 'again':
            return False
        key = (vm_.var(6), q)
        state['asked'][key] = state['asked'].get(key, 0) + 1
        if state['asked'][key] > 2:
            # the game rejected our answer twice: fall back to something always accepted
            fb = {'handout': 0, 'rocco': 0, 'buy': 0, 'sell': 0, 'kickback': 0,
                  'ammo': max(1, int(V[7] // 2)), 'squeeze': 0}
            if state['asked'][key] > 4:
                return 0
            return fb[q]
        if state['quit'] and q == 'ammo':
            return 0     # inadequate ammo: may lead to Cousin Abe
        return policy.answer(q, V, bytes(vm_.mem[33888:33898]))
    def hitman(vm_, lvl):
        if hitman_fn:
            return hitman_fn(vm_, lvl)
        p = hitman_p(lvl) if callable(hitman_p) else hitman_p
        if state['quit']:
            return 3
        if rng.random() < p:
            return 2 if rng.random() < collateral else 1
        return 3
    vm.strategy = strategy
    vm.hitman = hitman
    ended = {'cause': None}
    orig = vm.native
    def native(addr):
        if addr == 26740:
            raise _Done()
        orig(addr)
    vm.native = native
    vm.init()
    if fix_years:
        vm.setvar(36, (vm.var(36) // 100) * 100)   # what the author presumably intended
    vm.run(24609)
    year = 0
    try:
        while year < maxyears:
            vm.steps = 0
            vm.run(24652)
            year += 1
            s = score_now(vm) if score_each_year else None
            hist.append(dict(year=vm.var(6) / 100, hoods=vm.var(3) / 100, clients=vm.var(8) / 100,
                             dough=vm.var(7) / 100, score_if_died=s, blunders=vm.var(12) / 100))
            if trace:
                trace(vm, hist[-1])
            if quit_at and quit_at(vm, year, s):
                state['quit'] = True
    except _Done:
        pass
    except RuntimeError as e:
        if 'SQRT' not in str(e):
            raise
        return dict(score=0.0, years=vm.var(6) / 100, ended=True, froze=True, says=vm.says, history=hist, vm=vm)
    return dict(score=vm.var(15) / 100, years=vm.var(6) / 100, ended=year < maxyears or state['quit'],
                says=vm.says, history=hist, vm=vm)
