"""Titles, descriptions and per-byte comments for the small data blocks that used to be listed as just 'Data'."""
# (start, 'seg', title, description list, [(nbytes, comment), ...])
DATA_NOTES = [
 (29897, 'seg', 'Control code 8 handler (broken backspace)', [
  'The handler for message control code 8, which was evidently meant to be a backspace: it steps the text buffer pointer (29926) back one character so that the next character overwrites the last. The jump table at #R29248 points here. These bytes are Z80 code; each comment gives the instruction.',
  'It is broken. The first instruction, PUSH HL, is never undone, and the dispatcher (#R29544) has just put the handler\'s own address in HL, so the final RET goes back to the start of the handler. The handler then runs a second time and this time returns to 23807, one byte before the start of the text buffer (23808), and executes whatever is there as code. Run in the simulator, the buffer pointer dropped by two and the call never returned. No message in the game uses code 8, so nobody ever sees it (see the #LINK(Bugs#backspace)(bugs page)).'],
  [(1, 'PUSH HL: the stray instruction (nothing ever pops it)'),
   (3, 'LD HL,(29926): HL=the text buffer pointer'),
   (1, 'DEC HL: step back one character'),
   (3, 'LD (29926),HL: store the new pointer'),
   (1, 'XOR A: set the zero flag (code done)'),
   (1, 'RET: return, but to the wrong place because of the PUSH HL')]),
 (30500, 'seg', 'Square root workspace', [
  'Used by the square root routine at #R30511. Both values are 32-bit numbers in hundredths.'],
  [(4, 'The current estimate x (30500-30503)'),
   (4, 'The argument n (30504-30507)')]),
 (31915, 'seg', 'Unused: a stray jump', [
  'Nothing refers to these two bytes. They are the Z80 instruction JR 31887, sitting just after the RET of the routine at #R31900 where it can never be executed. 31887 is the routine that moves the pixel mask right one pixel, so this is probably a leftover from an earlier version of the line routines.'],
  [(2, 'JR 31887: never executed')]),
 (36493, 'seg', 'Bar-room animation: pause counter', [
  'A 16-bit tick counter used by #R36495. It is set to 500 at 36481 for the first pause (before the door opens) and to 400 at 36582 for the final pause.'],
  [(2, 'Pause counter (word)')]),
 (36616, 'seg', 'Bar-room animation: walking hoods counter', [
  'Ticks left until the next frame of the hoods walking through the club (see #R36617). It starts at 1 so the first frame is drawn at once, and is then reloaded with the duration of each frame from the list at 39924.'],
  [(1, 'Ticks until the next frame')]),
 (36663, 'seg', 'Bar-room animation: route counter', [
  'Ticks left before #R36664 fetches the next entry from the hoods\' route table. Setting it to 1 (36389, 36523, 36542 and 36562) makes the routine fetch an entry at once.'],
  [(1, 'Ticks until the next route entry')]),
 (36701, 'seg', 'Bar-room animation: figure 1 counter and state', [
  'Used by #R36703. The counter counts down to the next frame; when it expires the state flips between 0 and 1, which chooses a long wait (60-100 ticks) or a short one (10-30 ticks), and the next frame is drawn.'],
  [(1, 'Counter'), (1, 'State (0 or 1)')]),
 (36751, 'seg', 'Bar-room animation: figure 2 counter', [
  'Ticks until figure 2 (at 16769) changes frame; used by #R36752. Starts at 1.'],
  [(1, 'Counter')]),
 (36787, 'seg', 'Bar-room animation: figure 3 counter', [
  'Ticks until figure 3 (at 16803) changes frame; used by #R36788. Starts at 1.'],
  [(1, 'Counter')]),
 (36823, 'seg', 'Bar-room animation: figure 4 counter', [
  'Ticks until figure 4 (at 17253) changes frame; used by #R36824. Starts at 1.'],
  [(1, 'Counter')]),
 (36859, 'seg', 'Bar-room animation: figure 5 counter and state', [
  'Used by #R36861 for figure 5 (at 19576). The counter counts down to the next change; the state starts at 0 (the first state).'],
  [(1, 'Counter'), (1, 'State')]),
 (36909, 'seg', 'Bar-room animation: figure 6 counter and state', [
  'Used by #R36911 for figure 6 (at 19087). The counter counts down to the next change; the state starts at 0 (the first state).'],
  [(1, 'Counter'), (1, 'State')]),
 (36959, 'seg', 'Bar-room animation: figure 7 counter and state', [
  'Used by #R36961 for figure 7 (at 18633). The counter counts down to the next change; the state starts at 0 (bit 7 clear: the figure may move).'],
  [(1, 'Counter'), (1, 'State')]),
 (37030, 'seg', 'Bar-room animation: figure 8 counter and state', [
  'Used by #R37032 for figure 8. The counter counts down to the next change; the state starts at 128 (bit 7 set: the figure is out of action until the script brings it in).'],
  [(1, 'Counter'), (1, 'State')]),
 (46639, 'seg', 'Unused: a stray byte', [
  'Nothing can reach this byte: the JR at 46637 jumps over it and the JR Z at 46633 lands just after it. It is 120, the instruction LD A,B, probably the remains of an earlier version of this routine.'],
  [(1, 'LD A,B: never executed')]),
 (48639, 'seg', 'Padding before the dictionary', [
  'A single zero byte (a NOP) after the interrupt routine. It brings the dictionary to 48640, which is 190 x 256, so that the dictionary starts on a page boundary; dictionary references are a page number plus an offset (see #R29928).'],
  [(1, 'Padding')]),
]

DATA_NOTES.append((33909, 'seg', 'Speech bubble layouts', [
  'Each entry is 4 bytes: a chance value (compared with a random number from 0 to 100), the address of the picture, and a byte that is always 0. 33909 is the fixed "answer" layout. 33913 and 33925 start the two tables, one of which #R24614 picks at random each year; the SAY routine (#R28549) then takes the first entry in that table whose chance value is above a new random number. See #LINK(Facts#backgrounds)(Which background you get) on the trivia page for the resulting odds.'],
  [(4, 'Fixed "answer" layout: picture #R64646 (close-up of a hood)'),
   (4, 'First table, below 30: picture #R58673 (a figure in a doorway)'),
   (4, 'First table, below 70: picture #R59397 (two hoods at a table)'),
   (4, 'First table, otherwise: picture #R57583 (a man in a hat at a table)'),
   (4, 'Second table, below 33: picture #R63601 (hoods and a car in the city)'),
   (4, 'Second table, below 66: picture #R60526 (the getaway car from above)'),
   (4, 'Second table, otherwise: picture #R61625 (two figures at the waterfront)')]))

DATA_NOTES.append((33888, 'seg', 'VM flags', [
  'Nine flag bytes that the script tests and sets with IFPEEKEQ, IFPEEKNE and POKE, followed by the game status flag and some workspace used by the speech bubble code. #R33937 sets the nine flags and the status flag to 1 at the start of each game; the values below are those in the saved game image.'],
  [(1, 'Flag 0: the feds flag. 1 normally, 2 when the feds have been tipped off (set at the end of the recruiting step, tested in the next report; see the #LINK(Economics)(economics page))'),
   (1, 'Flag 1: set to 2 when the ammo comes to 1 grand per hood or less (adequate or not), but never tested'),
   (1, 'Flag 2: set to 2 when the game ends early (the mob walks out, Nick the Greek, no money left for ammo, cousin Abe, an empty safe, or the hit man); the end of the game then skips the farewell from the hoods'),
   (1, 'Flag 3: Rocco. Set to 2 when Rocco gets uppity; next year\'s report then halves the takings (if they are 3 grand or more) and changes its wording. Reset to 1 after the report'),
   (1, 'Flag 4: the contract. 2 when the hit man is coming, 3 when he has won the shootout (set by #R28358); reset to 1 afterwards'),
   (1, 'Flag 5: chooses between two openings of the contract warning; never changed from 1, so the second opening is never used'),
   (1, 'Flag 6: the ammo flag. 2 when last year\'s ammo was inadequate and not forgiven (cousin Abe then takes over), 1 otherwise'),
   (1, 'Flag 7: 1 in the first year, set to 2 at the end of every year'),
   (1, 'Flag 8: the type of the last number entered, set by #R27835 (1 negative, 2 zero, 3 exactly 0.01, 4 anything else)'),
   (1, 'Game status flag: non-zero ends the main loop at #R24614'),
   (2, 'Default sub-message address'),
   (2, 'Saved IY'),
   (2, 'Pointer to this year\'s bubble layout table (#R33913 or #R33925)'),
   (2, 'The current bubble layout'),
   (1, 'Layout-unchanged flag'),
   (2, 'Text width')]))
