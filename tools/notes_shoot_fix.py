"""Corrections, titles, data blocks and symbols for the shootout; merges the TXT comment tables."""
import re
import notes_shoot1, notes_shoot2, notes_shoot3, notes_shoot4

def comments():
    c = {}
    for m in (notes_shoot1, notes_shoot2, notes_shoot3, notes_shoot4):
        for line in m.TXT.strip().splitlines():
            a, t = line.split('|', 1)
            c[int(a)] = t
    # corrections of addresses typed wrongly
    c.pop(46096, None)
    c[46115] = c.pop(46113, 'Down one row')
    c[44144] = 'Next byte of the fragment'
    # attribute colour comments
    for a in (46095, 46102, 46271, 46278, 46286):
        c[a] = 'Keep the paper, bright and flash bits and clear the ink'
    for a in (46097, 46104, 46273, 46280, 46288):
        c[a] = 'Set the ink colour from B'
    # unrolled bit reversal in 45353
    a = 45362
    for k in range(8):
        c[a] = 'Shift the next bit out of D'
        c[a + 2] = 'and into A (this reverses the bits)'
        a += 3
    a = 45389
    for k in range(8):
        c[a] = 'Shift the next bit out of D'
        c[a + 2] = 'and into A (this reverses the bits)'
        a += 3
    c[45353] = 'Save the record address'
    c[45354] = 'Skip the state and counters...'
    c[45355] = '...to the frame table pointer'
    c[45364] = 'and into A (this reverses the bits)'
    return c

R_SHOOT = {
    42940: ('Shootout: load a furniture descriptor into the furniture slot',
            'Copies the 10-byte descriptor at HL: 6 bytes (screen address and graphic data) and then 4 bytes (attribute address and colour) into the seventh figure record, which the interrupt routine draws.'),
    42957: ('Shootout: place a piece of furniture (HL=screen address, DE=attribute address)', None),
    42970: ('Shootout: draw a piece of furniture and wait for the interrupt', None),
    42977: ('Shootout: main loop (the figure dispatcher)',
            'The shootout is a small cooperative scheduler. Each of the six figures (bystander 1, bystander 2, Mugsy, the hit man, '
            'Mugsy\'s bullet and the hit man\'s bullet) has a timer byte at 42250+n and a handler address in the table at 42238. '
            'A timer of 0 means that the figure\'s countdown is running; the interrupt routine #R48539 ticks the countdown and, when it reaches zero, '
            'draws the figure\'s next frame and sets the timer to 1. A timer of 1 tells this routine that the figure is ready for new orders: it runs the handler, '
            'which reads the next byte of the figure\'s route script (or the keyboard, for Mugsy), moves it, and leaves the timer to be '
            'decremented back to 0. A timer of 3 parks a figure for good.'),
    43018: ('Shootout: handler for bystander 1',
            'Route script bytes are direction codes (4 right, 64 left, 2 up-right, 128 up-left, 8 down-right, 32 down-left), 0 for "stand still for a tick", '
            '80, 81 and 82 for standing for 25, 1 or 128 ticks, 255 to hand over to the next figure and 254 to leave the restaurant and end the shootout.'),
    43246: ('Shootout: handler for bystander 2', None),
    43471: ('Shootout: handler for Mugsy',
            'Takes the direction code from #R46460, handles firing (state 0 idle, 1 and 2 raising the gun, 3 firing a bullet) and Mugsy\'s death.'),
    43709: ('Shootout: place a bullet in front of its owner (B=rows down from the top of the figure)', None),
    43814: ('Shootout: handler for the hit man',
            'Follows short move fragments (47034-47081). At the end of each fragment he compares his position with Mugsy\'s and picks a new one '
            'that moves him towards Mugsy, firing when they are on the same row.'),
    44153: ('Shootout: check for furniture next to a figure', None),
    44294: ('Shootout: handler for Mugsy\'s bullet', None),
    44416: ('Shootout: handler for the hit man\'s bullet', None),
    44525: ('Shootout: look for a bullet touching a figure', 'Returns A=1 if any of the 4x3 attribute cells at the figure\'s attribute address has the bullet colour (57).'),
    44558: ('Shootout: start a falling-over animation', None),
    44612: ('Shootout: work out the left and upper limits for a figure', None),
    48539: ('Interrupt routine for the shootout: the sprite scheduler',
            'Runs fifty times a second. For each figure whose timer is 0 it counts down the figure\'s countdown; when that reaches zero it '
            'points SP at the figure\'s record and uses POP to load HL, DE, BC and IY from it, then jumps to IY: a sprite drawing routine '
            '(#R45965, #R46031, #R46119 or #R46196) that draws the figure with the registers already set up. The drawing routines pass control '
            'on through #R48601 and finish at #R48617, which restores the real stack and sets the timer to 1. The routine ends by reading the keyboard.'),
}

DATA_SHOOT = [
    (42174, 'b', 'Shootout: animation frame tables',
     'Four bytes per frame: a direction mask, the graphic height in pixel rows, and the address of the graphic. Mugsy, the hit man and the bystanders each use a table (42174, 42194, 42206, 42222 ...).'),
    (42238, 'w', 'Shootout: figure handlers', 'One handler per figure slot, called by #R42977.'),
    (42250, 'b', 'Shootout: figure timers', '0 = counting down, 1 = ready for orders, 2 and 3 = waiting/parked. One byte per figure slot (the seventh is the furniture slot).'),
    (42257, 'w', 'Shootout: countdown pointers', 'The address of each figure slot\'s countdown record, used by the interrupt routine #R48539.'),
    (42271, 'b', 'Shootout: figure countdowns',
     'Three bytes per figure slot: the number of interrupts left before the next frame is drawn, and the address of the figure\'s record plus 3 (where the drawing job begins).'),
    (42292, 'b', 'Shootout: variables',
     '#TABLE(default,centre,:w) { =h Address | =h Meaning } '
     '{ 42292-42297 | Route script pointers for bystander 1, bystander 2 and the hit man } '
     '{ 42298 | Upper limit on the screen for Mugsy and the hit man } '
     '{ 42300 | Set once the sprite graphics have been inverted } '
     '{ 42301 | Mugsy\'s remaining hit points (from the handout) } '
     '{ 42302 | The hit man\'s remaining hit points (4) } '
     '{ 42303-42306 | Saved stack pointer and temporary } '
     '{ 42307 | Frame buffer address } '
     '{ 42309 | Frame table address } '
     '{ 42311 | Number of figure slots in use } '
     '{ 42312-42313 | Number of frames in the current animation and delay between frames } '
     '{ 42314 | Left limit for the current figure } '
     '{ 42315 | Direction code from the keyboard } '
     '{ 42316-42317 | Firing state of Mugsy and the hit man } '
     '{ 42318-42321 | Steps left for the two bullets and bullet cancel flags } '
     '{ 42322 | Set when a figure could not move } '
     '{ 42323-42326 | Bystander 1, bystander 2, Mugsy and the hit man have gone down } '
     '{ 42327-42328 | A bullet touches bystander 1 or bystander 2 } '
     '{ 42329-42330 | Mugsy or the hit man has run out of hit points } '
     '{ 42331-42332 | Mugsy\'s or the hit man\'s bullet has landed } '
     '{ 42333 | Somebody has gone down in this pass of the main loop } '
     '{ 42334 | The result: bit 0 Mugsy killed, bit 1 hit man killed, bits 2-3 bystanders hit } '
     '{ 42335 | The shootout is over } '
     'TABLE#'),
    (42336, 'b', 'Shootout: figure workspace',
     'A 39-byte copy of the figure being worked on, made by #R45693 and copied back by #R45702.'),
    (42375, 'b', 'Shootout: figure records',
     'Six 39-byte records (bystander 1 at 42375, bystander 2 at 42414, Mugsy at 42453, the hit man at 42492, Mugsy\'s bullet at 42531 and the hit man\'s bullet at 42570) '
     'and a seventh, shorter one at 42609 for the furniture. Byte 0 is the state (4 facing right, 64 left, other values diagonals), 1 and 2 are counters, '
     '3-10 hold the registers for the drawing job (screen address, graphic address, routine address), 17-18 is the screen address and 29-30 the attribute address.'),
    (45711, 'b', 'Shootout: furniture descriptors', 'Two 10-byte descriptors loaded by #R42940.'),
    (45731, 'b', 'Shootout: initial figure records', 'Six 39-byte records copied to 42375 by #R42639.'),
    (46645, 'b', 'Shootout: bystander 1 route script',
     'One byte per step: a direction code, 0 to stand still, 80/81/82 for long pauses, 255 to wake the hit man and 254 to leave. See #R43018.'),
    (46825, 'b', 'Shootout: bystander 2 route script', 'Used by #R43246.'),
    (47034, 'b', 'Shootout: the hit man\'s move fragments',
     'Six fragments of eight bytes: a direction code, two bytes that #R43977 sets to 10 when the hit man should fire, a pause and the end marker 255.'),
    (47082, 'b', 'Shootout: graphics', 'Sprites for Mugsy, the hit man, the bystanders, the furniture and the bullets. Inverted in place the first time the shootout runs (#R42700). Each figure frame is 16 pixels wide and 32 rows tall (two bytes per row). Left to right: the woman at the bar (four walking frames and one standing), the second bystander (three frames), Mugsy (two walking, two kneeling) and the hit man (two walking, two kneeling): #HTML[<img src="../images/sprites.png" alt="The shootout figures" />]'),
]

SYMBOLS_SHOOT = {
    42238: 'SO_HANDLERS', 42250: 'SO_TIMERS', 42257: 'SO_CDPTRS', 42271: 'SO_CD0',
    42292: 'SO_SCRIPT0', 42294: 'SO_SCRIPT1', 42296: 'SO_SCRIPT3', 42298: 'SO_TOPLIM', 42300: 'SO_INVERTED',
    42301: "Mugsy's hit points", 42302: "the hit man's hit points", 42307: 'SO_BUFFER', 42309: 'SO_FRAMES',
    42311: 'SO_NSLOTS', 42312: 'SO_NFRAMES', 42313: 'SO_DELAY', 42314: 'SO_LEFTLIM', 42315: 'the direction code',
    42316: "Mugsy's firing state", 42317: "the hit man's firing state", 42322: 'SO_BLOCKED',
    42323: 'bystander 1 down flag', 42324: 'bystander 2 down flag', 42325: 'Mugsy down flag', 42326: 'hit man down flag',
    42327: 'bystander 1 hit flag', 42328: 'bystander 2 hit flag', 42329: 'Mugsy out of hit points flag',
    42330: 'hit man out of hit points flag', 42331: "Mugsy's bullet landed flag", 42332: "the hit man's bullet landed flag",
    42333: 'SO_SOMEONE_DOWN', 42334: 'the shootout result', 42335: 'the shootout over flag', 42336: 'SO_WORK',
}

def apply(N):
    c = comments()
    N.C.update(c)
    for a, (t, d) in R_SHOOT.items():
        old = N.R.get(a)
        desc = [d] if d else (old[1] if old else [])
        N.R[a] = (t, desc, old[2] if old else [])
    N.SYMBOLS.update(SYMBOLS_SHOOT)
    return DATA_SHOOT
