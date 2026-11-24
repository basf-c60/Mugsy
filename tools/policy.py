"""Strategies for Mugsy. A strategy maps (question, variables) to an answer.

Questions are identified by the VM address just after the CALL instruction:
"""
import math

# whole numbers for which the game's SQRT routine never terminates
HANG = {156, 1407, 2499, 2501, 3905, 7658, 9998, 10002, 12654, 18909}

Q = {
    25072: 'handout', 25199: 'rocco', 25364: 'buy', 25442: 'sell',
    25537: 'ammo', 25733: 'squeeze', 25937: 'kickback', 26727: 'again',
}
# message address of the SAY before each CALL -> question (for the Python VM)
SAYQ = {50687: 'handout', 50806: 'handout', 51001: 'rocco', 51144: 'rocco', 51103: None,
        51292: 'buy', 51312: 'buy', 51317: 'buy', 51371: 'sell', 51382: 'sell', 51461: 'sell',
        51554: 'ammo', 51684: 'ammo', 51858: 'squeeze', 52217: 'kickback', 52262: 'kickback',
        52770: 'again'}

def ivar(V, n):
    return V[n]

class Policy:
    """A parameterised strategy. V is a dict of variable values (in real units)."""
    def __init__(self, **p):
        d = dict(handout=None, rocco=1, buy_frac=0.0, sell=0, ammo_mult=2.0, ammo_add=0,
                 squeeze_frac=1.0, kick_frac=0.1, kick_abs=0, keep=0, again=False, loan=0)
        d.update(p)
        self.p = d

    def answer(self, q, V, F):
        p = self.p
        hoods, clients, dough, price = V[3], V[8], V[7], V[34]
        if q == 'handout':
            if p['handout'] is not None:
                return p['handout'](V) if callable(p['handout']) else p['handout']
            return easiest_handout(hoods)
        if q == 'rocco':
            return p['rocco'] if dough - p['rocco'] > 5 else 0
        if q == 'buy':
            if callable(p['buy_frac']):
                return p['buy_frac'](V)
            n = int(max(0, (dough - p['keep']) * p['buy_frac']) // max(price, 1))
            return n
        if q == 'sell':
            return p['sell'](V) if callable(p['sell']) else p['sell']
        if q == 'ammo':
            if callable(p['ammo_mult']):
                a = p['ammo_mult'](V)
            else:
                a = int(math.ceil(hoods * p['ammo_mult'] + p['ammo_add']))
            a = max(1, min(a, int(dough) - 1)) if dough >= 2 else 1
            return a
        if q == 'squeeze':
            avail = V[21]
            if callable(p['squeeze_frac']):
                return p['squeeze_frac'](V)
            n = int(avail * p['squeeze_frac'])
            n = max(n, int(avail / 3) + 1)
            n = min(n, avail)
            if p['loan']:
                return min(avail, int(dough) + p['loan'])
            return int(min(n, max(dough, 0)))
        if q == 'kickback':
            if callable(p['kick_frac']):
                k = p['kick_frac'](V)
            else:
                k = int(max(0, min(dough, dough * p['kick_frac'] + p['kick_abs'])))
            # steer clear of the SQRT freeze (ammo + kickback in HANG)
            while k > 0 and (V[23] + k) in HANG:
                k -= 1
            return k
        if q == 'again':
            return p['again']
        raise ValueError(q)

def best_handout(hoods):
    """Smallest handout that gives Mugsy 8 hit points (see the Economics page).

    The handout sets Mugsy's own hit points: level = (low 3 bits of v33) + 1, or 8 if v33 >= 256."""
    h = int(round(hoods * 100))
    for x in range(0, 100000):
        if hitman_level(x, hoods) == 8:
            return x
    return 0

easiest_handout = best_handout      # old name (it used to aim for level 1, which was a mistake)

def hitman_level(handout, hoods):
    h = int(round(hoods * 100))
    a = (int(handout * 100) * 100) // h if h else 0
    a = (a * 100) // 300
    v = a + 100
    return 8 if v >= 256 else (v & 7) + 1
