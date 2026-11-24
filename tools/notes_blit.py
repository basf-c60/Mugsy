"""Rule-based comments for the two unrolled clipped blitters of the getaway animation (35406-36345)."""
import re, os

def load_ins(path):
    ins = []
    for l in open(path, encoding='utf-8'):
        m = re.match(r'^[c ]\s*(\d{5}) (.*?) ;', l)
        if m:
            ins.append((int(m.group(1)), m.group(2)))
    return ins

def blit_comments(path):
    ins = load_ins(path)
    seg = [(a, t) for a, t in ins if 35406 <= a < 36366]
    c = {}
    n = len(seg)
    for i, (a, t) in enumerate(seg):
        p = seg[i - 1][1] if i else ''
        q = seg[i + 1][1] if i + 1 < n else ''
        q2 = seg[i + 2][1] if i + 2 < n else ''
        p2 = seg[i - 2][1] if i > 1 else ''
        txt = None
        if t == 'EXX':
            if q in ('OR (HL)', 'INC HL') and p != 'INC HL' and not p.startswith('OR'):
                txt = 'Switch to the car buffer pointer (HL\')'
            elif p == 'INC HL' or p.startswith('INC HL'):
                txt = 'Switch back to the first buffer and screen pointers'
            else:
                txt = 'Switch register sets'
        elif t == 'LD A,(DE)' and q == 'EXX':
            txt = 'A=the next byte of the buffer at 24119'
        elif t == 'LD A,(DE)' and q == 'LD (HL),A':
            txt = 'A=the next byte of the buffer at 24119'
        elif t == 'OR (HL)' and p == 'EXX':
            txt = 'OR in the matching byte of the car buffer'
        elif t == 'INC HL' and p == 'OR (HL)':
            txt = 'Next car buffer byte'
        elif t == 'INC HL' and p == 'EXX':
            txt = 'Skip a car buffer byte'
        elif t == 'LD (HL),A':
            txt = 'Draw it on the screen'
        elif t == 'INC DE' and q == 'INC L':
            txt = 'Next byte of the first buffer'
        elif t == 'INC L' and p == 'INC DE':
            txt = 'Next screen column'
        elif t == 'INC DE' and q == 'EXX' and q2 == 'INC HL':
            txt = 'Skip a byte of the first buffer'
        elif t == 'LD A,L' and q == 'AND 224':
            txt = 'A=the screen address, low byte'
        elif t == 'LD A,L' and q == 'CP B':
            txt = 'A=the screen column byte'
        elif t == 'CP B':
            txt = 'Reached the clip column (30)?'
        elif t.startswith('JR Z,') and p == 'CP B':
            txt = 'Yes: skip the rest of the row (the picture is clipped at column 30)'
        elif t == 'LD A,L' and q == 'AND 31':
            txt = 'A=the screen address, low byte'
        elif t == 'AND 31':
            txt = 'Isolate the column'
        elif t == 'CP 3' and p == 'AND 31':
            txt = 'Reached column 3, the left edge of the street scene?'
        elif t.startswith('JP Z,') and p == 'CP 3':
            txt = 'Yes: start drawing'
        elif t == 'INC L' and p.startswith('JP Z'):
            txt = 'No: skip this column (it is off the left of the scene)'
        elif t.startswith('CALL Z,35854'):
            txt = 'If L wrapped round, move down to the next third of the screen'
        elif t == 'INC DE' and p.startswith('CALL Z'):
            txt = 'Skip a byte of the first buffer'
        elif t == 'RES 7,H':
            txt = 'Clear the left-clip flag in H'
        elif t == 'BIT 7,H':
            txt = 'Is the left-clip flag (bit 7 of H) set for this row?'
        elif t.startswith('JP NZ,') and p == 'BIT 7,H':
            txt = 'Yes: skip the columns left of the street scene first'
        elif t == 'PUSH HL' and a in (35452, 35890):
            txt = 'Save the screen address of the start of this row'
        elif t == 'AND 224' and p == 'LD A,L':
            txt = 'Keep the row bits'
        elif t == 'OR 30':
            txt = 'Column 30: the right-hand clip position'
        elif t == 'LD B,A' and p == 'OR 30':
            txt = 'B=the low byte of the clip position on this row'
        elif t == 'POP HL':
            txt = 'Get the start of the row back'
        elif t == 'INC H' and p == 'POP HL':
            txt = 'Down one pixel row'
        elif t == 'LD A,H' and p == 'INC H':
            txt = 'A=the high byte'
        elif t == 'AND 7' and p == 'LD A,H':
            txt = 'Crossed into the next character row?'
        elif t.startswith('JR Z,') and p == 'AND 7':
            txt = 'Yes: move down to the next character row'
        elif t == 'DEC C':
            txt = 'One row less'
        elif t.startswith('JP NZ,') and p == 'DEC C':
            txt = 'Draw the next row'
        elif t == 'RET':
            txt = 'Return'
        elif t.startswith('JP ') and not t.startswith('JP Z') and not t.startswith('JP NZ') and not t.startswith('JP C'):
            txt = 'Carry on with the next row'
        elif t == 'LD A,L' and p.startswith('JR Z') :
            txt = 'Move down one character row: A=the low byte'
        elif t == 'ADD A,32':
            txt = 'Add one character row (32 bytes)'
        elif t == 'LD L,A' and p == 'ADD A,32':
            txt = 'L=the new low byte'
        elif t.startswith('JP C,') and p == 'LD L,A':
            txt = 'Carry: that was the last character row of its third, so H (already 8 higher) is right'
        elif t == 'LD A,H' and p.startswith('JP C'):
            txt = 'No carry: still in the same third, so A=the high byte'
        elif t == 'SUB 8':
            txt = 'Take back the 8 that the pixel row steps added'
        elif t == 'LD H,A' and p == 'SUB 8':
            txt = 'H=the new high byte'
        elif t == 'LD A,(HL)' and a in (36074,):
            txt = 'Final byte of the row'
        if txt:
            c[a] = txt
    # entry
    c.update({
        35406: 'DE=the first buffer (24119, 12 bytes per row)',
        35409: 'HL=the screen address where the picture starts (38792)',
        35412: 'Switch to the alternate registers',
        35413: 'HL\'=the car buffer (38794, 12 bytes by 38 rows)',
        35416: 'Switch back',
        35417: 'C=38 pixel rows to draw',
        35419: 'A=the shift flag (38791)',
        35422: 'Test it',
        35423: 'Zero: use the version that copies the first buffer (35890)',
        35426: 'Non-zero: use the version that ORs in the car buffer (35452)',
    })
    return c
