"""Mugsy text decoder and VM bytecode disassembler."""
import os

MEM = None
BASE = 0

def load(path=os.path.join(os.path.dirname(__file__), '..', 'work', 'mem.bin')):
    global MEM
    MEM = bytearray(16384) + bytearray(open(path, 'rb').read())
    return MEM

def b(a):
    return MEM[a]

def w(a):
    return MEM[a] | MEM[a + 1] << 8

DICT = 48640      # packed 5-bit dictionary words
COMMON = 49710    # table of 2-byte dictionary refs for single-byte tokens 96-255

def dict_word(d, e):
    """Return the word printed by 29928 for D=d, E=e (with leading space)."""
    c = d
    hl = DICT + ((d & 15) << 8) + e
    if (d & 15) == 0 and e == 0:
        return ''
    out = []
    a = MEM[hl]; hl += 1
    ch = (a & 31) | 96
    if (c & 0xF0) == 0x70:
        ch &= 0xDF
    out.append(ch)
    bcount = 1
    while True:
        a = MEM[hl]
        if a & 31 == 0:
            break
        bcount += 1
        out.append((a & 31) + 96)
        bit7 = a & 128
        hl += 1
        if not bit7:
            continue
        if bcount == 2:
            continue
        if bcount == 3 and MEM[hl - 2] & 128:
            continue
        break
    return ' ' + ''.join(CHARMAP.get(x, chr(x)) for x in out)

MISMATCHES = []
CHARMAP = {123: "'", 124: '-', 125: '!', 126: '?', 127: '"'}

class Text:
    def __init__(self):
        self.out = []
        self.vmops = []   # ('var', ) or ('money',) or ('msg',)
        self.items = []   # (addr, length, description)

def decode_text(addr, t=None, depth=0, limit=400):
    """Decode a message at addr. Returns Text with .end address."""
    top = t is None
    if top:
        t = Text()
    ix = addr
    n = 0
    while n < limit:
        n += 1
        r, ix = decode_item(ix, t, depth)
        if not r:
            break
    t.end = ix
    if top:
        s = ''.join(t.out)
        if s.startswith(' '):
            s = s[1:]
        t.text = s
    return t

def decode_item(ix, t, depth):
    """Emulate 29458. Returns (continue?, next ix)."""
    a = MEM[ix]
    start = ix
    if a & 128:
        d = a & 127
        e = MEM[ix + 1]
        g = d & 0xF0
        t.out.append(dict_word(d, e))
        if g in (0x30, 0x20, 0x60):
            if g == 0x30:
                t.out.append('.')
            t.items.append((start, 2, 'last word' + (' + full stop' if g == 0x30 else '')))
            return False, ix + 2
        t.items.append((start, 2, 'capitalised word' if g == 0x70 else 'word'))
        return True, ix + 2
    if a >= 96:
        idx = a - 96
        p = COMMON + 2 * idx
        e = MEM[p]; d = MEM[p + 1] + 80
        t.out.append(dict_word(d, e))
        t.items.append((start, 1, 'common word #%d' % idx))
        return True, ix + 1
    if a >= 32:
        ch = a
        if 65 <= ch <= 90:
            ch |= 32
        t.out.append(chr(ch))
        t.items.append((start, 1, 'character'))
        return True, ix + 1
    # control codes
    if a == 1:
        t.out.append(' ${v%d}' % len(t.vmops)); t.vmops.append('money')
        t.items.append((start, 1, 'code 1: money variable'))
        return True, ix + 1
    if a == 4:
        t.out.append(' {v%d}' % len(t.vmops)); t.vmops.append('var')
        t.items.append((start, 1, 'code 4: number variable'))
        return True, ix + 1
    if a == 5:
        t.out.append(' {msg%d}' % len(t.vmops)); t.vmops.append('msg')
        t.items.append((start, 1, 'code 5: sub-message'))
        return True, ix + 1
    if a == 8:
        if t.out and t.out[-1]:
            t.out[-1] = t.out[-1][:-1]
        t.items.append((start, 1, 'code 8: backspace'))
        return True, ix + 1
    if a == 10:
        cnt = MEM[ix + 1]
        alts = []
        opsets = []
        p = ix + 2
        base = len(t.vmops)
        for i in range(cnt):
            sub = Text()
            sub.vmops = []
            decode_item(p, sub, depth + 1)
            s = ''.join(sub.out).strip()
            for j in range(len(sub.vmops)):
                s = s.replace('{v%d}' % j, '{v%d}' % (base + j)).replace('{msg%d}' % j, '{msg%d}' % (base + j))
            alts.append(s)
            opsets.append(sub.vmops)
            x = MEM[p]
            p += 2 if (x & 128 or x in (2, 11)) else 1
        if any(o != opsets[0] for o in opsets):
            t.mismatch = (ix, opsets)
            MISMATCHES.append((ix, opsets))
        t.vmops.extend(opsets[0])
        t.out.append(' [' + '/'.join(alts) + ']')
        t.items.append((start, p - start, 'code 10: random choice of %d' % cnt))
        return True, p
    if a == 11:
        e = MEM[ix + 1]
        target = ix + e - 256
        sub = Text(); sub.vmops = t.vmops
        if depth < 5:
            decode_text(target, sub, depth + 1)
        t.out.append(''.join(sub.out))
        t.items.append((start, 2, 'code 11: repeat text at %d' % target))
        return True, ix + 2
    if a == 21:
        t.out.append('.')
        t.items.append((start, 1, 'code 21: full stop and end'))
        return False, ix + 1
    if a >= 20:
        t.items.append((start, 1, 'code %d: end' % a))
        return False, ix + 1
    # other codes < 20: no-op (handler 29570 returns Z)
    t.items.append((start, 1, 'code %d: ignored' % a))
    return True, ix + 1

# ---------------------------------------------------------------- VM
OPS = {
    0: ('END', ''), 1: ('SAY', 'wb'), 2: ('SETMSG', 'w'),
    3: ('IFEQ', 'vvw'), 4: ('IFNE', 'vvw'), 5: ('IFLE', 'vvw'),
    6: ('IFLT', 'vvw'), 7: ('IFGT', 'vvw'), 8: ('IFGE', 'vvw'),
    9: ('IFPEEKEQ', 'wbw'), 10: ('IFPEEKNE', 'wbw'), 11: ('POKE', 'bw'),
    12: ('JZ', 'w'), 13: ('GOTO', 'w'), 14: ('CALL', 'w'), 15: ('STORE', 'v'),
    16: ('ADD', ''), 17: ('ADD', 'v'), 18: ('ADD', 'vv'),
    19: ('SUB', ''), 20: ('SUB', 'v'), 21: ('SUB', 'vv'),
    22: ('MUL', ''), 23: ('MUL', 'v'), 24: ('MUL', 'vv'),
    25: ('DIV', 'v'), 26: ('DIV', 'vv'), 27: ('INT', ''),
    28: ('LOAD', 'v'), 29: ('RND', ''), 30: ('RND', 'v'), 31: ('NEG', ''),
    32: ('HALF', 'v'), 33: ('SQRT', ''), 34: ('SQRT', 'v'),
}

def vm_insn(a):
    """Return (mnemonic, operands list, length, extra info)."""
    op = MEM[a]
    if op not in OPS:
        return None
    name, fmt = OPS[op]
    p = a + 1
    ops = []
    for f in fmt:
        if f == 'w':
            ops.append(('w', w(p))); p += 2
        else:
            ops.append((f, MEM[p])); p += 1
    info = {}
    if op == 1:
        txt = decode_text(ops[0][1])
        info['text'] = txt
        extra = []
        for k in txt.vmops:
            if k == 'msg':
                extra.append(('msg', w(p))); p += 2
            else:
                extra.append((k, MEM[p])); p += 1
        info['extra'] = extra
    return name, ops, p - a, info

def vm_targets(a):
    r = vm_insn(a)
    name, ops, ln, info = r
    op = MEM[a]
    tg = []
    if op in (3, 4, 5, 6, 7, 8, 9, 10, 12, 13):
        tg.append(ops[-1][1])
    return tg

def vm_trace(roots):
    seen = {}
    todo = list(roots)
    while todo:
        a = todo.pop()
        while a not in seen:
            r = vm_insn(a)
            if r is None:
                seen[a] = None
                break
            seen[a] = r
            for t in vm_targets(a):
                todo.append(t)
            op = MEM[a]
            if op in (0, 13):
                break
            a += r[2]
    return seen

VARNAMES = {}

def vname(n):
    return VARNAMES.get(n, 'v%d' % n)

def fmt_insn(a, r, labels=None):
    name, ops, ln, info = r
    labels = labels or {}
    def opstr(k, v):
        if k == 'v':
            return vname(v)
        if k == 'w':
            return labels.get(v, str(v))
        return str(v)
    op = MEM[a]
    if op == 1:
        t = info['text']
        import re
        ex = info['extra']
        def rep(mo):
            i = int(mo.group(2))
            k, v = ex[i]
            if mo.group(1) == 'msg':
                return '<msg %d>' % v
            return '{%s}' % vname(v)
        s = re.sub(r'\{(msg|v)(\d+)\}', rep, t.text)
        return 'SAY %d,%d "%s"' % (ops[0][1], ops[1][1], s)
    return name + (' ' + ','.join(opstr(k, v) for k, v in ops) if ops else '')
