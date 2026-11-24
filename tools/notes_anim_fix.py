"""Merges animation comment tables (getaway car, bar room, unrolled blitters)."""
import os
import notes_anim1, notes_anim2, notes_blit

def parse(txt):
    d = {}
    for line in txt.strip().splitlines():
        a, t = line.split('|', 1)
        d[int(a)] = t
    return d

FIXES = {
    33943: 'BC=76: nineteen four-byte variables',
    33946: 'Copy them into place',
    33951: 'B=10: nine VM flags plus the game status flag',
    33955: 'Next flag',
    33956: 'Loop for all ten',
    33961: 'BC=0: the high half of 1.00',
    33967: 'Switch to the alternate registers to hold the multiplier',
    33971: 'BC\'=0: the high half of 4.00',
    33977: 'Switch back',
    33981: 'BC=0: the high half of 7.00',
    33989: 'Store BCDE in v36: the length of the game, 7 + 4 x (a random number), an unrounded number of years',
    33992: 'Return',
    34003: 'Point the interrupt vector register at the table at 53504',
    34014: 'A=a random number from 0 to 100 (not evenly spread: below 50 about 60% of the time)',
    34021: 'Below 50?',
    34032: 'Interrupts off again',
    34035: 'Put I back as the ROM expects it',
    34039: 'Return',
}

def apply(N, skool_path):
    new = {}
    new.update(notes_blit.blit_comments(skool_path))
    new.update(parse(notes_anim1.TXT))
    new.update(parse(notes_anim2.TXT))
    new.pop(34218, None)
    new.update(FIXES)
    n = 0
    for a, t in new.items():
        if N.C.get(a) is None or a in FIXES:
            N.C[a] = t
            n += 1
    return n
