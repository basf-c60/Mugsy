"""Static recursive-descent code finder for Mugsy."""
import sys
from skoolkit.opcodes import decode

def insn(mem, a):
    return next(decode(mem, a, a + 1))[1]

def flow(mem, a, size):
    """Return (targets, falls_through)."""
    op = mem[a]
    tg = []
    if op in (0xC3,):
        return [mem[a+1] | mem[a+2] << 8], False
    if op == 0x18:
        return [(a + 2 + ((mem[a+1] ^ 128) - 128)) & 0xFFFF], False
    if op in (0xC9, 0xE9):
        return [], False
    if op in (0xDD, 0xFD) and mem[a+1] == 0xE9:
        return [], False
    if op == 0xED and mem[a+1] in (0x45, 0x4D, 0x55, 0x5D, 0x65, 0x6D, 0x75, 0x7D):
        return [], False
    if op in (0xC2, 0xCA, 0xD2, 0xDA, 0xE2, 0xEA, 0xF2, 0xFA, 0xCD, 0xC4, 0xCC, 0xD4, 0xDC, 0xE4, 0xEC, 0xF4, 0xFC):
        return [mem[a+1] | mem[a+2] << 8], True
    if op in (0x20, 0x28, 0x30, 0x38, 0x10):
        return [(a + 2 + ((mem[a+1] ^ 128) - 128)) & 0xFFFF], True
    return [], True

def trace(mem, seeds, lo=16384, hi=65536, stop=()):
    code = {}
    todo = list(seeds)
    while todo:
        a = todo.pop()
        while lo <= a < hi and a not in code and a not in stop:
            s = insn(mem, a)
            code[a] = s
            tg, ft = flow(mem, a, s)
            for t in tg:
                if lo <= t < hi:
                    todo.append(t)
            if not ft:
                break
            a += s
    return code
