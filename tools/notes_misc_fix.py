import notes_misc1 as M1
import notes_misc2 as M2
import notes_misc3 as M3
import notes_misc4 as M4
import notes_misc5 as M5
import notes_misc6 as M6
import notes_misc7 as M7
import notes_misc8 as M8
import notes_misc9 as M9
import notes_misc10 as M10
import notes_misc11 as M11
import notes_misc12 as M12
import notes_misc13 as M13
import notes_misc14 as M14
import notes_misc15 as M15
import notes_misc16 as M16
import notes_misc17 as M17
import notes_misc18 as M18
import notes_misc19 as M19
import notes_misc20 as M20
import notes_misc21 as M21
import notes_misc22 as M22
import notes_misc23 as M23
FIX = {30041: 'Step the pointer on by 256 bytes (increment its high byte)...',
       30044: 'No wrap-round: carry on',
       30046: '...and the low byte too if the high byte wrapped',
       30049: 'IX=the pointer (which wanders through the whole of memory)',
       32595: 'Return with the bits left-aligned in A (the callers shift them down)',
       24620: 'A=100: the upper limit (30014 takes the absolute value, giving 0..100)',
       32776: 'Carry: the borrow means H is already right',
       32715: 'Did the row wrap round to 7 (crossed a character boundary)?',
       32763: 'Carry: this was the last row of the third, so H is already right'}
def apply(N):
    for mod in (M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12, M13, M14, M15, M16, M17, M18, M19, M20, M21, M22, M23):
        for line in mod.TXT.strip().splitlines():
            if '|' not in line: continue
            a, t = line.split('|', 1)
            a = int(a)
            if N.C.get(a) is None:
                N.C[a] = t
    for a, t in list(FIX.items()) + list(M9.FIX.items()):
        N.C[a] = t

def _ratings(N):
    for a in range(26756, 26807, 5):
        if N.C.get(a) is None: N.C[a] = 'Count the rating down'
        if N.C.get(a + 1) is None: N.C[a + 1] = 'Return if this is the one'
_old_apply = apply
def apply(N):
    _old_apply(N); _ratings(N)

def _pushpop(N):
    import os, re
    path = os.path.join(os.path.dirname(__file__), '..', 'mugsy.skool')
    ins = []
    for l in open(path, encoding='utf-8'):
        m = re.match(r'^[c ]\s*(\d{5}) (.*?) ;', l)
        if m and not m.group(2).startswith('DEF'):
            ins.append((int(m.group(1)), m.group(2).strip()))
    n = 0
    for (a, x), (b, y) in zip(ins, ins[1:]):
        if x.startswith('PUSH ') and y.startswith('POP ') and N.C.get(a) is None and N.C.get(b) is None:
            r1, r2 = x[5:], y[4:]
            if r1 != r2:
                N.C[a] = 'Copy %s into %s...' % (r1, r2)
                N.C[b] = '...by way of the stack'
                n += 1
    return n
_old_apply2 = apply
def apply(N):
    _old_apply2(N); _pushpop(N)
