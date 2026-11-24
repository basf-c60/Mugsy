"""Build mugsy.skool from base.skool + notes.py + generated data blocks."""
import re, sys, os, json
sys.path.insert(0, os.path.dirname(__file__))
import mugsylib as M
import notes as N

ROOT = os.path.join(os.path.dirname(__file__), '..')
M.load(os.path.join(ROOT, 'work', 'mem.bin'))
MEM = M.MEM
M.VARNAMES.update(N.VARNAMES)

SYM = N.SYMBOLS
REG16 = {'BC', 'DE', 'HL', 'IX', 'IY', 'SP', 'AF'}

def symname(addr):
    if addr in SYM:
        return SYM[addr]
    for (lo, hi), name in N.RANGES.items():
        if lo <= addr <= hi:
            return '%s (+%d)' % (name, addr - lo) if addr != lo else name
    return None

def rname(r):
    return r

def auto_comment(addr, ins):
    """Produce a readable comment for an instruction without a manual one."""
    op, _, args = ins.partition(' ')
    a = args.split(',') if args else []
    def target(x):
        try:
            return int(x)
        except ValueError:
            return None
    def opnd(x):
        m = re.fullmatch(r'\((\d+)\)', x)
        if m:
            n = int(m.group(1))
            s = symname(n)
            return s if s else 'the contents of %d' % n
        if x == '(HL)':
            return 'the byte at HL'
        if re.fullmatch(r'\((I[XY])\+(\d+)\)', x) or re.fullmatch(r'\((I[XY])-(\d+)\)', x):
            return 'the byte at ' + x[1:-1]
        if x in ('(BC)', '(DE)'):
            return 'the byte at ' + x[1:-1]
        return x
    if op == 'LD':
        d, s = a[0], a[1]
        m = re.fullmatch(r'\((\d+)\)', d)
        if m:
            n = int(m.group(1)); nm = symname(n)
            return 'Store %s in %s' % (s, nm if nm else str(n) + ('-%d' % (n + 1) if s in REG16 else ''))
        if d.startswith('('):
            return 'Store %s at %s' % (s, d[1:-1])
        n = target(s)
        if n is not None and d in REG16:
            nm = symname(n)
            if nm and n >= 16384:
                return 'Point %s at %s' % (d, nm)
            if 16384 <= n < 22528 and d == 'HL':
                return '%s=%d (display file)' % (d, n)
            if 22528 <= n < 23296:
                return '%s=%d (attribute file)' % (d, n)
            return '%s=%d' % (d, n)
        if n is not None:
            return '%s=%d' % (d, n)
        return '%s=%s' % (d, opnd(s))
    if op in ('INC', 'DEC'):
        x = a[0]
        if x.startswith('('):
            return ('Increment ' if op == 'INC' else 'Decrement ') + opnd(x)
        return ('Increment ' if op == 'INC' else 'Decrement ') + x
    if op == 'ADD':
        return '%s=%s+%s' % (a[0], a[0], opnd(a[1]))
    if op == 'ADC':
        return '%s=%s+%s+carry' % (a[0], a[0], opnd(a[1]))
    if op == 'SUB':
        return 'A=A-%s' % opnd(a[0])
    if op == 'SBC':
        return '%s=%s-%s-carry' % (a[0], a[0], opnd(a[1]))
    if op == 'AND':
        if a[0] == 'A':
            return 'Set the zero flag if A=0 (and reset the carry flag)'
        return 'A=A AND %s' % opnd(a[0])
    if op == 'OR':
        if a[0] == 'A':
            return 'Set the zero flag if A=0 (and reset the carry flag)'
        return 'A=A OR %s' % opnd(a[0])
    if op == 'XOR':
        if a[0] == 'A':
            return 'A=0'
        return 'A=A XOR %s' % opnd(a[0])
    if op == 'CP':
        return 'Compare A with %s' % opnd(a[0])
    if op in ('JR', 'JP', 'CALL', 'DJNZ'):
        if a and a[0] in ('(HL)', '(IX)', '(IY)'):
            return 'Jump to the address in %s' % a[0][1:-1]
        cond = a[0] if len(a) == 2 else None
        tgt = target(a[-1])
        nm = N.ROUTINE_NAMES.get(tgt) if tgt is not None else None
        cname = {'Z': 'if the zero flag is set', 'NZ': 'if the zero flag is reset',
                 'C': 'if the carry flag is set', 'NC': 'if the carry flag is reset',
                 'P': 'if the sign flag is reset', 'M': 'if the sign flag is set',
                 'PE': 'if parity even', 'PO': 'if parity odd'}.get(cond, '')
        if op == 'DJNZ':
            return 'Loop back until B is zero'
        if op == 'CALL':
            return ('Call %s' % nm if nm else 'Call the routine at %s' % tgt) + (' ' + cname if cname else '')
        if tgt is not None and tgt < addr and not nm:
            return 'Jump back' + (' ' + cname if cname else '')
        return ('Jump to %s' % nm if nm else 'Jump forward') + (' ' + cname if cname else '')
    if op == 'RET':
        return 'Return' + ({'Z': ' if the zero flag is set', 'NZ': ' if the zero flag is reset',
                           'C': ' if the carry flag is set', 'NC': ' if the carry flag is reset',
                           'P': ' if positive', 'M': ' if negative', 'PO': ' if parity odd', 'PE': ' if parity even'}.get(args, ''))
    if op == 'PUSH':
        return 'Save %s' % a[0]
    if op == 'POP':
        return 'Restore %s' % a[0]
    if op == 'EX':
        if a[0] == '(SP)':
            return 'Exchange %s with the value on top of the stack' % a[1]
        if a[0] == 'AF':
            return "Exchange AF and AF'"
        return 'Exchange DE and HL'
    if op == 'EXX':
        return 'Switch register sets'
    if op == 'CPI':
        return 'Compare A with the byte at HL, increment HL and decrement BC'
    if op == 'LDI':
        return 'Copy the byte at HL to DE, increment HL and DE and decrement BC'
    if op == 'LDIR':
        return 'Copy BC bytes from HL to DE (forwards)'
    if op == 'LDDR':
        return 'Copy BC bytes from HL to DE (backwards)'
    if op in ('SRL', 'SRA', 'SLA', 'RR', 'RL', 'RRC', 'RLC'):
        nm = {'SRL': 'Shift %s right (bit 7 cleared)', 'SRA': 'Shift %s right (sign preserved)',
              'SLA': 'Shift %s left', 'RR': 'Rotate %s right through the carry flag',
              'RL': 'Rotate %s left through the carry flag', 'RRC': 'Rotate %s right',
              'RLC': 'Rotate %s left'}[op]
        return nm % opnd(a[0])
    if op in ('RRCA', 'RLCA', 'RRA', 'RLA'):
        return {'RRCA': 'Rotate A right', 'RLCA': 'Rotate A left', 'RRA': 'Rotate A right through the carry flag',
                'RLA': 'Rotate A left through the carry flag'}[op]
    if op == 'BIT':
        return 'Test bit %s of %s' % (a[0], opnd(a[1]))
    if op == 'SET':
        return 'Set bit %s of %s' % (a[0], opnd(a[1]))
    if op == 'RES':
        return 'Reset bit %s of %s' % (a[0], opnd(a[1]))
    if op == 'NEG':
        return 'A=-A'
    if op == 'CPL':
        return 'Invert all the bits of A'
    if op == 'SCF':
        return 'Set the carry flag'
    if op == 'CCF':
        return 'Complement the carry flag'
    if op == 'NOP':
        return 'Do nothing'
    if op == 'DI':
        return 'Disable interrupts'
    if op == 'EI':
        return 'Enable interrupts'
    if op == 'HALT':
        return 'Wait for the next interrupt'
    if op == 'OUT':
        return 'Set the border colour/speaker'
    if op == 'IN':
        return 'Read the keyboard'
    if op == 'IM':
        return 'Select interrupt mode %s' % a[0]
    if op == 'RETI':
        return 'Return from the interrupt'
    if op == 'RST':
        return 'Call the ROM routine at %s' % a[0]
    return ''

# ---------------------------------------------------------------------------
def read_base():
    """Parse base.skool into dict addr -> (instruction text, entry_marker)."""
    code = {}
    for line in open(os.path.join(ROOT, 'work', 'base.skool')):
        m = re.match(r'^([c* ])(\d+) (.*?)\s*;', line)
        if m:
            code[int(m.group(2))] = m.group(3).strip()
    return code

def wrap(text):
    return text

def block_header(out, title, desc=None, regs=None, notes=None, label=None):
    out.append('; ' + title)
    if desc:
        for p in (desc if isinstance(desc, list) else [desc]):
            out.append(';')
            out.append('; ' + p)
    if regs:
        out.append(';')
        for r in regs:
            out.append('; ' + r)

def defb_lines(start, data, comment=None, first_marker=' ', step=8, label=None):
    """Return DEFB lines; comment spans all lines (using braces if > 1 line)."""
    lines = []
    chunks = [data[i:i + step] for i in range(0, len(data), step)] or [[]]
    addr = start
    n = len(chunks)
    for i, ch in enumerate(chunks):
        mk = first_marker if i == 0 else ' '
        s = '%s%d DEFB %s' % (mk, addr, ','.join(str(x) for x in ch))
        if comment is not None:
            if n == 1:
                s += ' ; ' + comment
            elif i == 0:
                s += ' ; {' + comment
            elif i == n - 1:
                s += ' ; }'
            else:
                s += ' ;'
        lines.append(s)
        addr += len(ch)
    return lines

# ---------------------------------------------------------------------------
def vm_block(out, start, end, title, desc, entry_targets):
    out.append('; ' + title)
    if desc:
        out.append(';'); out.append('; ' + desc)
    a = start
    first = True
    while a < end:
        r = M.vm_insn(a)
        mk = '*' if (a in entry_targets and not first) else ' '
        if first: mk = 'b'
        if r is None or a + r[2] > end:
            out.extend(defb_lines(a, list(MEM[a:end]), 'Unused', mk))
            break
        cmt = 'VM: ' + M.fmt_insn(a, r).replace('{', '(').replace('}', ')')
        if r[0] == 'CALL':
            tgt = r[1][0][1]
            ttl = N.R.get(tgt, (N.EXTRA.get(tgt),))[0]
            if ttl:
                ttl = ttl.replace('VM native: ', '')
                cmt = cmt.replace('CALL %d' % tgt, 'CALL #R%d (%s)' % (tgt, ttl if ttl.startswith(('Louey', '"')) else ttl[0].lower() + ttl[1:]))
        out.extend(defb_lines(a, list(MEM[a:a + r[2]]), cmt, mk, step=r[2] if r[2] <= 16 else 8))
        a += r[2]
        first = False

_REFS11 = {}

def _scan_refs11(start, end):
    """Map target -> owner message for every control code 11 reached through a random choice (code 10)."""
    def item_len(p):
        x = MEM[p]
        return 2 if (x & 128 or x in (2, 11)) else 1
    a = start
    while a < end:
        t = M.decode_text(a)
        p = a
        while p < t.end:
            x = MEM[p]
            if x == 10:
                n = MEM[p + 1]; q = p + 2
                for _ in range(n):
                    if MEM[q] == 11:
                        _REFS11.setdefault(q + MEM[q + 1] - 256, a)
                    q += item_len(q)
                p = q
            elif x == 11:
                p += 2
            elif x & 128 or x == 2:
                p += 2
            else:
                p += 1
        a = max(t.end, a + 1)

def _pick_one_targets(a):
    """If message a is only a random choice between back-references, return the target addresses."""
    if MEM[a] != 10:
        return None
    n = MEM[a + 1]; q = a + 2; tg = []
    for _ in range(n):
        if MEM[q] != 11:
            return None
        tg.append(q + MEM[q + 1] - 256); q += 2
    return tg if MEM[q] >= 20 else None

def msg_block(out, start, end, title, desc):
    out.append('; ' + title)
    if desc:
        out.append(';'); out.append('; ' + desc)
    _scan_refs11(start, end)
    a = start; first = True
    while a < end:
        t = M.decode_text(a)
        e = min(t.end, end)
        if e <= a:
            e = a + 1
        txt = t.text.replace('{', '(').replace('}', ')')
        if t.end > end:
            txt = txt[:30] + '... (runs on: see #LINK(Bugs#terrific)(the bugs page))'
        tg = _pick_one_targets(a)
        if tg:
            lens = [len(M.decode_text(x).text) for x in tg]
            com = 'Message: a random choice of the messages at %s (%s characters)' % (
                ' or '.join(str(x) for x in tg), ' or '.join(str(x) for x in lens))
        else:
            com = 'Message: "%s"' % txt
            if a in _REFS11:
                com += ' (only reached through the random choice at %d)' % _REFS11[a]
        out.extend(defb_lines(a, list(MEM[a:e]), com, 'b' if first else ' '))
        a = e; first = False

def seg_block(out, start, end, title, desc, segs):
    out.append('; ' + title)
    for k, p in enumerate(desc):
        out.append(';' if k == 0 else '; .'); out.append('; ' + p)
    a = start
    for i, (n, c) in enumerate(segs):
        out.append('%s%d DEFB %s ; %s' % ('b' if i == 0 else ' ', a, ','.join(str(x) for x in MEM[a:a + n]), c))
        a += n
    assert a == end, (start, a, end)

def generic_block(out, start, end, title, desc=None, kind='b', step=8, comments=None):
    out.append('; ' + title)
    if desc:
        for p in (desc if isinstance(desc, list) else [desc]):
            out.append(';'); out.append('; ' + p)
    a = start; first = True
    if kind == 'w':
        while a < end:
            n = min(end - a, step * 2)
            n -= n % 2
            if n == 0:
                out.extend(defb_lines(a, list(MEM[a:end]), 'Unused', 'b' if first else ' ')); break
            ws = [M.w(a + i) for i in range(0, n, 2)]
            c = comments(a) if comments else None
            out.append('%s%d DEFW %s%s' % ('w' if first else ' ', a, ','.join(map(str, ws)), ' ; ' + c if c else ''))
            a += n; first = False
        return
    if kind == 't':
        while a < end:
            ch = MEM[a:min(end, a + 32)]
            s = ''.join(chr(x) if 32 <= x < 127 and x not in (34, 92) else None or '' for x in ch)
            # mixed text: fall back to DEFB with ascii comment
            out.append('%s%d DEFB %s ; "%s"' % ('t' if first else ' ', a, ','.join(map(str, ch)),
                       ''.join(chr(x) if 32 <= x < 127 else '.' for x in ch).replace('{', '(').replace('}', ')')))
            a += len(ch); first = False
        return
    while a < end:
        n = min(step, end - a)
        c = comments(a) if comments else None
        out.extend(defb_lines(a, list(MEM[a:a + n]), c, kind if first else ' ', step=step))
        a += n; first = False

def var_block(out):
    out.append('; VM variables')
    out.append(';')
    out.append('; The VM has 84 32-bit signed variables, each holding a fixed-point number with two decimal places '
               '(so 1.00 is stored as 100). Variables 37-64 are constants; variables 65-83 are the table of initial '
               'values for v0-v18 copied by #R33937, but the script also uses v68-v72 as the constants 40, 10, 2.5, 1 '
               'and 0. See the #LINK(Variables)(variables page).')
    for n in range(84):
        a = 33552 + 4 * n
        v = MEM[a] | MEM[a+1] << 8 | MEM[a+2] << 16 | MEM[a+3] << 24
        if v & 0x80000000: v -= 1 << 32
        name = N.VARNAMES.get(n, 'v%d' % n)
        desc = N.VARDESC.get(n, 'Unused')
        out.append('%s%d DEFB %s ; v%d (%s): %s [%s]' % ('b' if n == 0 else ' ', a, ','.join(str(x) for x in MEM[a:a+4]),
                   n, name, desc, ('%.2f' % (v / 100)).rstrip('0').rstrip('.')))

def _dict_words():
    """Split the dictionary at 48640 into its words, exactly as the expander at 29928 reads them."""
    D = 48640
    def word(o):
        hl = D + o
        out = [MEM[hl] & 31]; hl += 1; n = 1
        while True:
            a = MEM[hl]
            if a & 31 == 0: break
            n += 1; out.append(a & 31); bit7 = a & 128; hl += 1
            if not bit7: continue
            if n == 2: continue
            if n == 3 and MEM[hl - 2] & 128: continue
            break
        return ''.join(chr(96 + x) if 1 <= x <= 26 else {27: "'", 28: '-', 29: '!', 30: '?', 31: '"'}.get(x, '?') for x in out), hl - D
    o = 64; words = []
    while o < 1070:
        t, e = word(o)
        while e < 1070 and (MEM[D + e] & 31) == 0: e += 1
        words.append((o, t, e)); o = e
    assert o == 1070
    return words

def dict_block(out, start, end):
    assert (start, end) == (48640, 49710)
    words = _dict_words()
    used = {}
    orig = M.dict_word
    cur = [0]
    def rec(d, e):
        used.setdefault((d & 15) * 256 + e, set()).add(cur[0]); return orig(d, e)
    M.dict_word = rec
    try:
        a = 49774
        while a < 53351:
            cur[0] = a; t = M.decode_text(a)
            if t.end <= a: break
            a = t.end
        for i in range(32):
            p = 49710 + 2 * i
            used.setdefault(((MEM[p + 1] + 80) & 15) * 256 + MEM[p], set()).add('common')
    finally:
        M.dict_word = orig
    tokens = {}
    for i in range(32):
        p = 49710 + 2 * i
        tokens[((MEM[p + 1] + 80) & 15) * 256 + MEM[p]] = 96 + i
    unused = [t for o, t, e in words if o not in used]
    out.append('; Dictionary')
    out.append(';')
    out.append('; The %d words that Louey\'s messages are built from, %d bytes in all, in alphabetical order. A message refers to a word by a page number (0-4) and an offset (#R29928 adds them to 48640), or, for the 32 commonest, by a single byte (the table at #R49710). The block starts with a letter index of 32 two-byte entries (64 bytes); the words follow.' % (len(words), end - start - 64))
    out.append('; .')
    out.append('; Each letter takes one byte: the low five bits are the letter (1 = a to 26 = z; 27 to 31 are the punctuation marks \' - ! ? and ") and the top bits are mostly ignored. Bit 7 marks the last letter of a word, but only from the third letter on, so no word is cut short at two letters. A short word is closed by a byte whose letter is 0. Each line below is one word, with its offset from 48640 (the number a message uses; the page is the offset divided by 256).')
    out.append('; .')
    out.append('; The game never reads the letter index: it finds words only through the references. It looks like a by-product of the tool that built the dictionary. %d words are never referred to by any message: %s.' % (len(unused), ', '.join('"%s"' % u for u in unused)))
    a = start
    for i in range(32):
        v = MEM[a] | MEM[a + 1] << 8
        if 1 <= i <= 26:
            if v:
                w = [t for o, t, e in words if o == v]
                assert w and w[0][0] == chr(96 + i), (i, v, w)
                c = 'Index: offset %d, the first word beginning with "%s" ("%s")' % (v, chr(96 + i), w[0])
            else:
                c = 'Index: no words begin with "%s"' % chr(96 + i)
                assert not v
        else:
            c = 'Index: unused'
            assert not v
        out.append('%s%d DEFB %d,%d ; %s' % ('b' if i == 0 else ' ', a, MEM[a], MEM[a + 1], c))
        a += 2
    for o, t, e in words:
        assert a == 48640 + o
        c = '%d: "%s"' % (o, t)
        if o in tokens: c += ' (also the single-byte token %d)' % tokens[o]
        if o not in used: c += ' (not used by any message)'
        out.append(' %d DEFB %s ; %s' % (a, ','.join(str(x) for x in MEM[a:48640 + e]), c))
        a = 48640 + e
    assert a == end

def common_block(out, start, end):
    assert (start, end) == (49710, 49774)
    words = {o: t for o, t, e in _dict_words()}
    uses = {}
    a = 49774
    while a < 53351:
        t = M.decode_text(a)
        if t.end <= a: break
        for _, _, d in t.items:
            if d.startswith('common word #'):
                k = int(d.split('#')[1]); uses[k] = uses.get(k, 0) + 1
        a = t.end
    ent = []
    for i in range(32):
        p = start + 2 * i
        off = ((MEM[p + 1] + 80) & 15) * 256 + MEM[p]
        ent.append((i, off, words[off]))
    top = sorted(ent, key=lambda x: -uses.get(x[0], 0))[:5]
    out.append('; Common words')
    out.append(';')
    out.append('; The 32 words that the game uses most, each reachable through a single byte in a message (96-127) instead of the two bytes of an ordinary dictionary reference. #R29907 takes the byte minus 96 as an index into this table; each entry is two bytes, the offset of the word in the dictionary at #R48640 (which also gives the page), and the page number in the low four bits of the second byte (the routine adds 80 to it to make the word type 5, an ordinary word). The table is in order of use, commonest first, which is why the low token numbers are the busiest. The counts below are the number of times each token appears in the messages.')
    out.append('; .')
    out.append('; The commonest are %s.' % ', '.join('"%s" (%d)' % (w, uses.get(i, 0)) for i, o, w in top))
    for i, off, w in ent:
        p = start + 2 * i
        out.append('%s%d DEFB %d,%d ; Token %d: "%s" (dictionary offset %d), used %d time%s' % ('b' if i == 0 else ' ', p, MEM[p], MEM[p + 1], 96 + i, w, off, uses.get(i, 0), '' if uses.get(i, 0) == 1 else 's'))

def font_block(out, start, end):
    out.append('; Proportional font')
    out.append(';')
    out.append('; Used by #R26940 for the text in the speech bubbles. Each character has 7 bytes: the width in pixels '
               'followed by six pixel rows (the font is only six pixels high). Characters 32-122 are present; lower case '
               'letters are drawn as small capitals. #HTML[<img src="../images/font.png" alt="The proportional font" />]')
    a = start; ch = 32; first = True
    while a + 7 <= end:
        c = chr(ch)
        nm = {32: 'space', 34: 'double quote', 92: 'backslash'}.get(ch, c)
        out.append('%s%d DEFB %s ; Character %d (%s): width %d' % ('b' if first else ' ', a, ','.join(str(x) for x in MEM[a:a+7]), ch, nm.replace('{', '(').replace('}', ')'), MEM[a]))
        a += 7; ch += 1; first = False
    if a < end:
        out.extend(defb_lines(a, list(MEM[a:end]), 'Unused', ' '))

# ---------------------------------------------------------------------------
DATA = [
    # (start, kind, title, description)
    (24609, 'vm', 'VM script: Louey\'s greeting', 'Run by #R24589 at the start of each game.'),
    (24652, 'vm', 'VM script: one year of the game', 'Run by #R24614. This is the whole game: the report on last year, Rocco, the contract, buying and selling clients, ammo, the squeeze, the kickback, the hit man, the year\'s results and finally the end-of-game rating. See the #LINK(VM)(VM reference) for the instruction set.'),
    (27087, 'font', None, None),
    (27785, 'vm', 'VM script: complain about a yes/no answer', None),
    (27807, 'vm', 'VM script: complain about an invalid number', 'Also counts a blunder (v11).'),
    (27828, 'vm', 'VM script: complain about a fraction', None),
    (27995, 'vm', 'VM script: set the input value to zero', None),
    (28000, 'vm', 'VM script: multiply the input value by 10', None),
    (28006, 'vm', 'VM script: add a digit to the input value', 'v33 holds the digit; it is multiplied by 100 (the fixed-point scale) and added to v35.'),
    (28304, 'vm', 'VM script: Louey\'s hush money', 'Run by #R28297 after a blunder.'),
    (28404, 't', 'Status line templates', '"HOODS ... CUSTOMERS ..." and "DOUGH IN DA SAFE $..." (32 characters each), filled in by #R28468 and #R28504.'),
    (28728, 'b', 'Speech bubble shape', 'Line widths (28728-28736), left offsets (28737-28746) and margins (28747-28756) for the oval speech bubble; used by #R28757 and #R29161. #R29161 fills lines from the top and the bottom of the bubble at the same time, so each of the nine widths serves a pair of lines (the outermost pair first), and the table covers bubbles of up to 18 lines.'),
    (29248, 'w', 'Message control code jump table', 'Addresses of the handlers for control codes 0-22 (used by #R29458).'),
    (30123, 'w', 'VM opcode jump table', 'Addresses of the handlers for VM opcodes 0-34 (used by #R30092).'),
    (31030, 'b', 'Arithmetic workspace', '64-bit product/dividend (31030-31037), multiplier/quotient (31038-31045), divisor (31046-31053) and the sign flag (31054).'),
    (32832, 'w', 'Theme tune: list of fragments', 'Addresses of the note lists played by #R32803 (terminated by 0).'),
    (33051, 'b', 'Theme tune: note data', 'Used by #R32866.'),
    (33552, 'vars', None, None),
    (33888, 'b', 'VM flags', 'Nine flag bytes tested and set with IFPEEKEQ/IFPEEKNE/POKE, followed by the game status flag (33897), the default sub-message (33898-33899), the saved IY (33900-33901), the bubble layout pointers (33902-33905), the layout-unchanged flag (33906) and the text width (33907-33908).'),
    (33909, 'b', 'Speech bubble layouts', 'Each entry is 4 bytes: chance (compared with a random number), address of the picture, border colour. 33909 is the fixed "answer" layout; 33913 and 33925 are the two tables from which #R24614 chooses one at random each year. #TABLE(default,centre) { =h Entry | =h Picture } { 33909 | 64646 } { 33913 | 58673 } { 33917 | 59397 } { 33921 | 57583 } { 33925 | 63601 } { 33929 | 60526 } { 33933 | 61625 } TABLE#'),
    (34291, 'b', 'Getaway car animation: counters', None),
    (34298, 'w', 'Getaway car animation: step table', 'Used by #R34040.'),
    (36348, 'w', 'Bar-room animation: step table', 'Used by #R34040.'),
    (37101, 'b', 'Animation data and graphics', 'Positions, frame lists and sprite graphics for the getaway car and bar-room animations.'),
    (42057, 'b', 'Shootout: sound effect data', 'Played by #R42026.'),
    (48639, 'b', 'Unused', None),
    (48640, 'dict', 'Dictionary', None),
    (49710, 'common', 'Common words', None),
    (49774, 'msg', 'Messages', 'All of Louey\'s lines. Placeholders in parentheses are filled in from VM variables given after the SAY instruction; [a/b/c] marks a random choice.'),
    (53353, 't', 'Leftover assembler source', 'Fragments of the original Z80 source code, left in memory by the assembler. See the #LINK(Facts#source)(trivia page).'),
    (53459, 't', 'Leftover assembler source', None),
    (53504, 'b', 'Interrupt vector table', '257 bytes of 208 (only 256 are needed), so that an IM2 interrupt with I=209 always jumps to 53456. The table is placed over more leftover source code.'),
    (53761, 't', 'Leftover assembler source', None),
    (53793, 'b', 'Picture: the Partridge Club (compressed)', 'Drawn by #R32126 for the bar-room animation. #HTML[<img src="../images/pic53793.png" width="256" alt="The Partridge Club" />]'),
    (55692, 'b', 'Picture: the street (compressed)', 'Drawn by #R32126 for the getaway car animation. #HTML[<img src="../images/pic55692.png" width="256" alt="The street" />]'),
    (57583, 'b', 'Picture: a man in a hat at a table', 'Command list drawn by #R31247; used by the bubble layout at #R33921 (first table). #HTML[<img src="../images/pic57583.png" width="256" alt="A man in a hat at a table" />]'),
    (58673, 'b', 'Picture: a figure in a doorway between headlights', 'Command list drawn by #R31247; used by the bubble layout at #R33913 (first table). #HTML[<img src="../images/pic58673.png" width="256" alt="A figure in a doorway" />]'),
    (59397, 'b', 'Picture: two hoods at a table', 'Command list drawn by #R31247; used by the bubble layout at #R33917 (first table). #HTML[<img src="../images/pic59397.png" width="256" alt="Two hoods at a table" />]'),
    (60526, 'b', 'Picture: the getaway car from above', 'Command list drawn by #R31247; used by the bubble layout at #R33929 (second table). #HTML[<img src="../images/pic60526.png" width="256" alt="The getaway car from above" />]'),
    (61625, 'b', 'Picture: two figures at the waterfront', 'Command list drawn by #R31247; used by the bubble layout at #R33933 (second table). #HTML[<img src="../images/pic61625.png" width="256" alt="Two figures at the waterfront" />]'),
    (63601, 'b', 'Picture: hoods and a car in the city', 'Command list drawn by #R31247; used by the bubble layout at #R33925 (second table). #HTML[<img src="../images/pic63601.png" width="256" alt="Hoods and a car in the city" />]'),
    (64646, 'b', 'Picture: close-up of a hood', 'Command list drawn by #R31247; used by the fixed "answer" bubble layout at #R33909. #HTML[<img src="../images/pic64646.png" width="256" alt="Close-up of a hood" />]'),
]

DATA.extend(N.DATA_SHOOT)
import data_notes
DATA = [d for d in DATA if d[0] not in [x[0] for x in data_notes.DATA_NOTES]]
DATA.extend(data_notes.DATA_NOTES)
DATA.sort(key=lambda d: d[0])

def build():
    code = read_base()
    starts = set(json.load(open(os.path.join(ROOT, 'work', 'starts.json'))))
    starts |= set(N.EXTRA) | set(N.R)
    codeset = set(code)
    roots = [24609, 24652, 27785, 27807, 27828, 27995, 28000, 28006, 28304]
    seen = M.vm_trace(roots)
    vm_targets = set()
    for a, r in seen.items():
        if r: vm_targets |= set(M.vm_targets(a))
    dstarts = {d[0]: d for d in DATA}
    allstarts = sorted((starts & codeset) | set(dstarts))
    # small gaps inside code regions become their own data blocks
    addrs = sorted(codeset)
    out = ['@start', '@org=24576', '@set-handle-unsupported-macros=1']
    # walk memory
    a = 24576
    blocks = []
    cur = 24576
    while cur < 65536:
        if cur in codeset:
            # code block: until next start or non-code
            e = cur
            while e in codeset and (e == cur or e not in allstarts):
                ins = code[e]
                from skoolkit.opcodes import decode
                e += next(decode(MEM, e, e + 1))[1]
            blocks.append(('c', cur, e))
            cur = e
        else:
            e = cur + 1
            while e < 65536 and e not in codeset and e not in dstarts:
                e += 1
            blocks.append(('d', cur, e))
            cur = e
    for kind, s, e in blocks:
        out.append('')
        if kind == 'c':
            lab = N.LABELS.get(s)
            title, desc, regs = N.R.get(s, (N.EXTRA.get(s, 'Routine at %d' % s), [], []))
            out.append('; ' + title)
            for p in desc:
                out.append(';'); out.append('; ' + p)
            if regs:
                out.append(';')
                for rr in regs:
                    out.append('; ' + rr)
            x = s; first = True
            from skoolkit.opcodes import decode
            while x < e:
                ins = code[x]
                c = N.C.get(x)
                if c is None:
                    c = auto_comment(x, ins)
                if x in N.LABELS and not first:
                    out.append('@label=' + N.LABELS[x])
                if first and lab:
                    out.append('@label=' + lab)
                mk = 'c' if first else ('*' if x in vm_targets else ' ')
                out.append('%s%d %s ; %s' % (mk, x, ins, c.replace('{', '(').replace('}', ')')))
                x += next(decode(MEM, x, x + 1))[1]
                first = False
        else:
            d = dstarts.get(s)
            if d:
                k = d[1]
                if k == 'vm':
                    vm_block(out, s, e, d[2], d[3], vm_targets)
                elif k == 'msg':
                    msg_block(out, s, e, d[2], d[3])
                elif k == 'seg':
                    seg_block(out, s, e, d[2], d[3], d[4])
                elif k == 'dict':
                    dict_block(out, s, e)
                elif k == 'common':
                    common_block(out, s, e)
                elif k == 'font':
                    font_block(out, s, e)
                elif k == 'vars':
                    var_block(out)
                elif k == 'w':
                    generic_block(out, s, e, d[2], d[3], 'w', 4)
                elif k == 't':
                    generic_block(out, s, e, d[2], d[3], 't')
                else:
                    generic_block(out, s, e, d[2], d[3], 'b')
            else:
                nm = SYM.get(s)
                title = (nm[0].upper() + nm[1:]) if nm else 'Data'
                generic_block(out, s, e, title, None, 'b')
    txt = '\n'.join(out) + '\n'
    txt = txt.replace('@set-handle-unsupported-macros=1\n\n', '@set-handle-unsupported-macros=1\n', 1)  # directives must touch the first entry
    # SkoolKit register lines are "Input:A desc" with one register per line (no "|" markers)
    txt = re.sub(r'(?m)^; (Input|Output)\|', r'; \1:', txt)
    txt = re.sub(r'(?m)^; \|', '; ', txt)
    # a one-line #TABLE that follows a second blank comment line would be read as register lines: keep it in the description
    ls = txt.split('\n'); nb = 0
    for i, l in enumerate(ls):
        if not l.startswith(';'):
            nb = 0; continue
        if l == ';':
            nb += 1
        elif l.startswith('; #TABLE(') and nb >= 2 and ls[i-1] == ';':
            ls[i-1] = '; .'
    # link bare addresses in block descriptions (not in instruction comments)
    import linkify
    addrs = linkify.line_addresses('\n'.join(ls))
    nlink = [0]
    ls = [linkify.linkify(l, addrs, nlink) if l.startswith('; ') else l for l in ls]
    # and in instruction comments: VM operands (jump targets, message and variable addresses) and prose addresses
    insn = re.compile(r'^([bcgistuw* ]\d{5} .*? ; )(.*)$')
    def vm_ops(c):
        q = c.find('"')
        head, tail = (c, '') if q < 0 else (c[:q], c[q:])
        def r(m):
            if int(m.group(2)) in addrs:
                nlink[0] += 1
                return m.group(1) + '#R' + m.group(2)
            return m.group(0)
        return re.sub(r'(^|[ ,(])(\d{5})(?=$|[ ,)])', r, head) + tail
    for i, l in enumerate(ls):
        m = insn.match(l)
        if not m:
            continue
        c = m.group(2)
        if c.startswith('VM: '):
            c = vm_ops(c)
        elif not c.startswith(('Message', '{Message')):
            c = linkify.linkify(c, addrs, nlink)
        ls[i] = m.group(1) + c
    print('linked', nlink[0])
    txt = '\n'.join(ls)
    open(os.path.join(ROOT, 'mugsy.skool'), 'w').write(txt)
    # keep the front-page figures in step with the files
    nb = sum(1 for l in ls if re.match(r'^[bcgistuw]\d{5} ', l))
    nc = sum(1 for l in ls if re.match(r'^[bcgistuw* ]\d{5} ', l) and ' ; ' in l)
    rp = os.path.join(ROOT, 'mugsy.ref'); ref = open(rp).read()
    nbug = len(re.findall(r'(?m)^\[Bug:', ref)); nfact = len(re.findall(r'(?m)^\[Fact:', ref))
    new = ref
    for n, lab in ((nb, 'blocks titled and described'), (nc, 'line comments'), (nfact, 'trivia entries'), (nbug, 'bugs in the original')):
        new = re.sub(r'<li><b>[\d,]+</b><span>%s</span></li>' % lab, '<li><b>{:,}</b><span>%s</span></li>'.format(n) % lab, new)
    new = re.sub(r'<span>\d+ odd facts', '<span>%d odd facts' % nfact, new)
    new = re.sub(r'<span>\d+ faults in the original', '<span>%d faults in the original' % nbug, new)
    if new != ref:
        open(rp, 'w').write(new)
    print('blocks', len(blocks))

if __name__ == '__main__':
    build()
