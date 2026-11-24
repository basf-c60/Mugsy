# -*- coding: utf-8 -*-
"""Hand-written annotations for the Mugsy disassembly."""

# ---------------------------------------------------------------- VM variables
VARNAMES = {
    0: 'StartClients', 1: 'Squeezed', 2: 'Raided', 3: 'Hoods', 4: 'Killed',
    5: 'Price', 6: 'Year', 7: 'Dough', 8: 'Clients', 9: 'Recruits',
    10: 'TotalKilled', 11: 'Blunders', 12: 'TotalBlunders', 13: 'HoodYears',
    14: 'Loan', 15: 'Score', 16: 'TotalTakings', 17: 'TotalProfit',
    18: 'ClientYears', 19: 'Bought', 20: 'Sold', 21: 'Unsqueezed', 22: 'ClientsLeft',
    23: 'Ammo', 24: 'FedsKilled', 25: 'Takings', 26: 'Profit', 27: 'Interest',
    28: 'HoodGrowth', 29: 'ClientGrowth', 30: 'Handout', 31: 'Bribe',
    32: 'Kickback', 33: 'Tmp', 34: 'ClientCost', 35: 'Input', 36: 'Years',
    37: 'K800', 38: 'K1000', 39: 'Km005', 40: 'Km010', 41: 'K05', 42: 'K15',
    43: 'K2', 44: 'K3', 45: 'K35', 46: 'K4', 47: 'K5', 48: 'K6', 49: 'K7',
    50: 'K8', 51: 'K9', 52: 'K11', 53: 'K12', 54: 'K13', 55: 'K15b', 56: 'K17',
    57: 'K19', 58: 'K20', 59: 'K25', 60: 'K35b', 61: 'K50', 62: 'K60', 63: 'K99',
    64: 'K100', 68: 'K40', 69: 'K10', 70: 'K25c', 71: 'K1', 72: 'K0',
}

VARDESC = {
    0: 'Number of clients at the start of the game (400)',
    1: 'Number of clients squeezed this year',
    2: 'Amount (in grand) taken by the cops in a raid',
    3: 'Number of hoods in the mob (shown on the status line)',
    4: 'Number of hoods rubbed out last year',
    5: 'Average protection payment per client',
    6: 'Current year (starts at 1)',
    7: 'Dough in the safe, in thousands of dollars (shown on the status line)',
    8: 'Number of clients (shown on the status line as CUSTOMERS)',
    9: 'Number of hoods recruited last year',
    10: 'Total number of hoods killed during the game',
    11: 'Number of blunders (silly answers) made this year',
    12: 'Total number of blunders made during the game',
    13: 'Sum of the mob size over all years',
    14: 'Loan from Nick the Greek (in grand)',
    15: 'Final score (percentage)',
    16: 'Total protection takings',
    17: 'Total profit',
    18: 'Sum of the number of clients over all years',
    19: 'Number of clients bought from the syndicate this year',
    20: 'Number of clients sold to the syndicate this year',
    21: 'Number of clients available to be squeezed',
    22: 'Number of clients that would be left after a sale',
    23: 'Amount spent on artillery and ammo this year',
    24: 'Number of recruits killed in the shootout with the feds',
    25: 'Protection takings this year',
    26: 'Profit this year (after Rocco has taken his cut)',
    27: 'Interest rate on Nick the Greek\'s loan (percent)',
    28: 'Percentage growth of the mob over the game',
    29: 'Percentage growth of the client list over the game',
    30: 'Handout paid to keep the hoods loyal',
    31: 'Bribe paid to Rocco\'s mob',
    32: 'Annual kickback to the cops',
    33: 'Scratch variable',
    34: 'Price of a client this year (in grand)',
    35: 'Number entered by the player (x100 fixed point; see 27790)',
    36: 'Number of years the game will last (7-11, chosen at random by 33937)',
}
for _k, _v in [(37, 800), (38, 1000), (39, -0.05), (40, -0.1), (41, 0.5), (42, 1.5), (43, 2), (44, 3),
               (45, 3.5), (46, 4), (47, 5), (48, 6), (49, 7), (50, 8), (51, 9), (52, 11), (53, 12),
               (54, 13), (55, 15), (56, 17), (57, 19), (58, 20), (59, 25), (60, 35), (61, 50),
               (62, 60), (63, 99), (64, 100)]:
    VARDESC[_k] = 'Constant: %s' % _v
for _k in range(65, 84):
    VARDESC[_k] = 'Initial value of v%d (part of the table at 33812); ' % (_k - 65) + \
        {68: 'also used as the constant 40', 69: 'also used as the constant 10', 70: 'also used as the constant 2.5',
         71: 'also used as the constant 1', 72: 'also used as the constant 0'}.get(_k, 'not otherwise used')

# ---------------------------------------------------------------- symbols
SYMBOLS = {
    23560: 'LAST-K', 23611: 'FLAGS', 23808: 'the text buffer',
    26939: 'the current character', 27018: 'the glyph mask', 27019: 'the glyph mask (low byte)',
    27059: 'the attribute for the status line',
    27868: 'the minus-sign flag',
    28219: 'the cursor character', 28220: 'the cursor flash counter', 28548: 'the SAY flags',
    29027: 'the line start pointer', 29319: 'the first-character flag', 29629: 'the leading-zero flag',
    29808: 'the random-choice counter', 29809: 'the random choice',
    29926: 'the text buffer pointer', 30023: 'the random number pointer', 30025: 'the last random number',
    30090: 'the VM program counter', 31054: 'the sign flag', 31522: 'the fill attribute',
    31523: 'the fill flag (up)', 31524: 'the fill flag (down)', 32124: 'the end of the point list',
    32536: 'the bit-stream pointer', 32538: 'the bit-stream bit position', 32610: 'the line start point',
    32611: 'the line start point (y)', 32801: 'the saved stack pointer',
    33888: 'flag 0 (recruits/feds)', 33889: 'flag 1 (ammo spent)', 33890: 'flag 2 (mob walked out)',
    33891: 'flag 3 (Rocco)', 33892: 'flag 4 (contract on Mugsy)', 33893: 'flag 5 (handout message)',
    33894: 'flag 6 (ammo adequate)', 33895: 'flag 7 (first year)', 33896: 'flag 8 (input type)',
    33897: 'the game status flag', 33898: 'the default sub-message', 33900: 'the saved IY',
    33902: 'the bubble layout table pointer', 33904: 'the current bubble layout',
    33906: 'the layout-unchanged flag', 33907: 'the text width',
    33993: 'the sequence-finished flag', 34066: 'the interrupt countdown', 34067: 'the interrupt countdown reload value',
    34068: 'the tick flag', 53457: 'the interrupt routine address',
}
RANGES = {
    (31030, 31037): 'the 64-bit product/dividend', (31038, 31045): 'the multiplier/quotient',
    (31046, 31053): 'the divisor', (30500, 30503): 'the square root estimate', (30504, 30507): 'the square root argument',
    (33552, 33887): 'the VM variables',
}

# ---------------------------------------------------------------- routines
# addr: (title, [description paragraphs], [register notes])
R = {}
def r(addr, title, desc=None, regs=None):
    R[addr] = (title, desc if isinstance(desc, list) else ([desc] if desc else []), regs or [])

r(24576, 'Start the game',
  ['This is the entry point (from #R24576(PRINT USR 24576) in the BASIC loader). It disables interrupts, '
   'moves the stack down into the printer buffer, saves IY (which the ROM interrupt routine needs) and calls '
   'the main loop. When the player answers "nope" to "Hows about another game, Mugsy?" the main loop '
   'returns here and the machine locks up in an infinite loop (see #LINK(Bugs#noquit)(the bugs page)).'])
r(24589, 'Main loop: play one game',
  ['Initialises the variables, shows Louey\'s greeting and then plays years until the game status flag at 33897 '
   'is non-zero. A value of 2 means "another game"; 1 means "no more".'])
r(24614, 'Play one year',
  ['Picks one of the two speech bubble layout tables at random (33913 or 33925), runs the main VM script at 24652 '
   'and loops until the script sets the game status flag at 33897.'])
r(26740, 'VM native: choose the end-of-game rating',
  ['Called from the VM script at 26714. Uses the value in v33 (the score divided into bands) to pick one of the '
   'rating words ("lousy", "ghastly", "swell" and so on) from the table at 53301, and stores its address as the default '
   'sub-message (33898) for the "You were ..." message.'])
r(26753, 'Get the address of a rating word',
  ['Returns the address of rating word number A (1-11) in the table of words at 53301. Any other value, including 0, gives the twelfth word, "terrific", which has no end code (see #LINK(Bugs#terrific)(the bugs page)).'],
  ['Input|A Rating number', 'Output|HL Address of the word'])
r(26812, 'Draw the picture for a speech bubble layout',
  ['IY points at a 4-byte bubble layout entry: byte 0 is the bubble placement chance, bytes 1-2 are the '
   'address of the picture data and byte 3 is the border colour. If the same layout is still on screen (33906=0) '
   'the screen is left alone except that the speech bubbles are wiped (cells with attribute 120 cleared); '
   'otherwise the screen is cleared and the picture is redrawn by #R31247.'],
  ['Input|IY Layout entry'])
r(26876, 'Wait for a key to be pressed or for a timeout',
  ['First waits until all keys are released, then waits (up to A periods of about one second each) for a key to be '
   'pressed. Used after each speech bubble.'],
  ['Input|A Number of timeout periods'])
r(26898, 'Wait for a keypress with a timeout (one period)',
  ['Returns with the zero flag reset if a key was pressed.'])
r(26907, 'Wait for a keypress for up to BC iterations',
  ['Returns with the zero flag reset as soon as a key is pressed, or with the zero flag set after BC loops.'],
  ['Input|BC Loop count'])
r(26921, 'Get the address of a character in the font',
  ['The proportional font at #R27087 has 7 bytes per character (a width byte and six rows of pixels), starting '
   'with character 32. This routine computes 26863+7*A.'],
  ['Input|A Character code', 'Output|HL Address of the character\'s width byte'])
r(26940, 'Print a character in the proportional font',
  ['Prints character A at the pixel column given by C within the character cell at HL (display file address). '
   'Characters may straddle two cells, so each row is shifted into place by #R27021 and ORed onto the screen. The '
   'dollar sign is printed followed by an extra space; a comma gets a tail added (character 128).'],
  ['Input|A Character code', '|C Pixel offset (0-7) within the current cell', '|HL Display file address',
   'Output|C Updated pixel offset', '|L Updated column'])
r(27020, 'Print one pixel row of a glyph (from DE)',
  ['Fetches the row byte at DE and falls through to #R27021.'])
r(27021, 'Print one pixel row of a glyph',
  ['Shifts the pixel row in A right by C bits across a 16-bit word and ORs it into the two screen bytes at HL '
   'and HL+1, using the mask at #R27018.'],
  ['Input|A Pixel row', '|C Pixel offset', '|HL Display file address'])
r(27060, 'Clear a character cell and set its attribute',
  ['Clears the eight bytes of the character cell at HL and sets its attribute to the value at 27059.'],
  ['Input|HL Display file address'])
r(27724, 'Print a character using the ROM font',
  ['Used for the status line at the bottom of the screen. Copies the 8x8 glyph from the ROM character set '
   '(15360+8*A) to the cell at HL, then moves HL one cell right.'],
  ['Input|A Character code', '|HL Display file address'])
r(27753, 'VM native: get a yes/no answer',
  ['Reads a line of input and returns with the zero flag set for "Y" or "y" and reset for "N" or "n". Any other '
   'answer makes Louey say "Don\'t get smart wit\' me, Mugsy!..." (script at 27785) and asks again.'])
r(27790, 'VM native: get a number from the player',
  ['Reads a line of input and parses it into v35 (in hundredths, like all VM numbers). On an invalid entry Louey '
   'complains (script at 27807 or 27828 for fractions) and the blunder count v11 goes up. Flag 8 (33896) is set to '
   'the type of the answer: 1 = negative, 2 = zero, 3 = 0.01 (not possible from the keyboard), 4 = anything else.'])
r(27817, 'Complain about a fraction and try again',
  ['Entered with the carry flag reset when the number contained a decimal point.'])
r(27835, 'Classify the number entered',
  ['Sets flag 8 (33896) according to the value in BCDE: 1 if negative, 2 if zero, 3 if exactly 1 (0.01), 4 otherwise.'],
  ['Input|BCDE Number'])
r(27869, 'Parse the input buffer as a number',
  ['Checks the text at 23808 for an optional sign, digits and a decimal point, then runs the small VM scripts at '
   '27995, 28000 and 28006 to accumulate the value in v35 (each digit: v35=v35*10+digit*100). Returns with the zero '
   'flag reset if the entry was not a valid whole number, and with the carry flag reset if it contained a decimal '
   'point.'])
r(28017, 'Set the "decimal point" result', ['Returns with the zero flag reset and the carry flag set.'])
r(28021, 'Check whether A is a digit', ['Returns with the carry flag set if A is "0"-"9".'],
  ['Input|A Character code', 'Output|F Carry set if A is a digit'])
r(28030, 'Clear a row of character cells', ['Clears B cells starting at HL (via #R27060).'],
  ['Input|B Number of cells', '|HL Display file address'])
r(28037, 'Read a line of input in the answer bubble',
  ['Clears the answer bubble on the right of the screen, then reads keys (via #R28221) into the buffer at 23808, '
   'echoing them in the proportional font. DELETE (12) and LEFT (8) rub out the last character, ENTER (13) ends the '
   'line. The line is terminated with a zero byte.'])
r(28221, 'Wait for a key, flashing the cursor',
  ['Calls #R28266 to wait for a key while flashing an asterisk cursor (every fourth frame) in the answer bubble.'],
  ['Output|A Key code (from LAST-K)'])
r(28266, 'Wait one frame and read the keyboard',
  ['Enables interrupts long enough for one ROM interrupt (which scans the keyboard), then checks bit 5 of FLAGS '
   'to see if a new key has been pressed.'],
  ['Output|A Key code (if the zero flag is reset)'])
r(28297, 'VM native: Louey charges hush money for a blunder',
  ['Runs the VM script at 28304. Each blunder increments v11; if the safe holds enough, Louey asks for one grand '
   '(or a tenth of the safe, if it holds 19 grand or more) to keep quiet about it.'])
r(28358, 'VM native: shootout with the hit man from Detroit',
  ['Works out Mugsy\'s hit points from v33 (set by the script from the handout: (low byte of v33 AND 7)+1, '
   'or 8 if v33 is 2.56 or more) and plays the shootout at #R42112. On return flag 4 (33892) is set to the result: '
   '1 = the hit man was killed, 2 = the hit man was killed but bystanders were hit (the cops then want 20-60% of the '
   'safe), 3 = Mugsy was killed.'])
r(28468, 'Print the first status line',
  ['Prints "HOODS nn CUSTOMERS nnn" on the second-to-last line of the screen using the values of v3 and v8.'])
r(28504, 'Print the second status line', ['Prints "DOUGH IN DA SAFE $nnn" using the value of v7.'])
r(28530, 'Print a VM variable into a status line template',
  ['Formats variable D into the template at HL (A characters long) via #R29630.'],
  ['Input|A Field width', '|D Variable number', '|HL Template address'])
r(28549, 'Show a message in a speech bubble',
  ['The handler for VM op 1 (SAY, #R30225) jumps here. This is the heart of the comic strip display. HL holds the address of a message and A holds a flags byte:',
   '#TABLE(default,centre,:w) { =h Bits | =h Meaning } '
   '{ 0-1 | Non-zero: wait for a keypress (with timeout) afterwards } '
   '{ 2-3 | Bubble placement: 0 = random entry from the layout table at 33902; 4 (bit 2) = the fixed entry at 33909 (the answer bubble); 8 (bit 3) = keep the current entry } '
   '{ 4-6 | 16 = play the theme tune (#R32785) } TABLE#',
   'The message is rendered into the text buffer at 23808 (expanding dictionary words and any variables, which are '
   'taken from the VM byte stream after the SAY instruction), the picture is redrawn if the layout has changed, '
   'the status lines are printed and the text is word-wrapped into the bubble by #R28757.'],
  ['Input|A Flags', '|HL Message address'])
r(28652, 'Check whether the bubble layout has changed',
  ['Compares IY with the current layout (33904).'], ['Output|A 0 if unchanged, 1 if changed', '|F Zero flag set if unchanged'])
r(28671, 'Measure the words in the text buffer',
  ['Builds a list of word widths (in pixels) at 24192, terminated by 255.'], ['Input|IX Text'])
r(28698, 'Measure one word', ['Adds up the widths (+1 pixel spacing) of the characters at IX up to the next space.'],
  ['Input|IX Text', 'Output|A Width in pixels', '|IX Next word'])
r(28757, 'Print the text buffer into a speech bubble',
  ['Works out how many lines the text needs (#R29161), then prints it line by line, centring each line within the '
   'oval bubble shape described by the table of line widths at 28728 and left margins at 28746. The bubble outline '
   'itself is drawn first by #R28905.'],
  ['Input|IX Text', '|HL Display file address of the top of the bubble'])
r(28879, 'Add the bubble margin for the current line', ['L=L+(IY+0).'])
r(28885, 'Move HL down one character row', ['HL=HL+32, crossing display file thirds as needed.'])
r(28895, 'Move HL up one character row', ['HL=HL-32, crossing display file thirds as needed.'])
r(28905, 'Draw the outline of a speech bubble',
  ['Draws the rounded white bubble (paper 7) with one blank line above and below the text area.'])
r(29006, 'Fill part of a bubble line with white cells',
  ['Paints A+16 pixels of white bubble background (via #R27060) from the cell at HL.'])
r(29029, 'Print one line of text in a bubble',
  ['Prints as many words from IX as will fit in A pixels, centred.'], ['Input|A Line width in pixels', '|IX Text'])
r(29161, 'Work out the bubble shape for the text',
  ['Chooses the smallest bubble (number of lines, B) into which the measured words will fit, using the line widths '
   'at 28728.'], ['Output|B Number of lines'])
r(29236, 'Compare IX and IY', ['Returns with the carry flag set if IX<IY.'])
r(29294, 'Measure the width of the text buffer', ['Returns the total pixel width of the text at 23808 in HL.'])
r(29320, 'Render a message into the text buffer',
  ['Clears the buffer, renders the message at HL into it and then, if the text is too wide for one line, inserts a '
   'line break near the middle so that the bubble comes out roughly round.'], ['Input|HL Message address'])
r(29452, 'Render a message', ['Calls #R29458 for each item until the end of the message.'], ['Input|IX Message'])
r(29458, 'Render one message item',
  ['A message is a sequence of items:',
   '#TABLE(default,centre,:w) { =h Byte(s) | =h Meaning } '
   '{ 0-31 | Control code (see the table at #R29248) } '
   '{ 32-95 | Literal character (letters are converted to lower case) } '
   '{ 96-127 | Common word: index into the table at #R49710 } '
   '{ 128-255, n | Dictionary word at 48640+((b AND 15)*256)+n; bits 4-6 of b: 7 = capitalise, 2 or 6 = last word, 3 = last word plus a full stop } TABLE#',
   'Returns with the zero flag set at the end of the message.'], ['Input|IX Item', 'Output|IX Next item'])
r(29509, 'Put a character into the text buffer (converting to lower case)', ['Converts A-Z to a-z first.'])
r(29519, 'Put a character into the text buffer',
  ['Stores A at the buffer pointer (29926). A space as the very first character is suppressed.'])
r(29569, 'Jump to a control code handler', ['JP (HL).'])
r(29596, 'Control codes 1/4: fetch a variable from the VM stream',
  ['Reads a variable number from the VM byte stream (not the message!) and loads that variable into BCDE, then puts a space in the buffer.'])
r(29630, 'Print a number',
  ['Prints the signed fixed-point value in BCDE in decimal (without leading zeros), adding a decimal point and two '
   'decimal places only if the fractional part is non-zero.'], ['Input|BCDE Number (x100)'])
r(29752, 'Print one decimal digit',
  ['Subtracts the power of ten in BC/DE from the number in HL\'/HL repeatedly to work out the digit.'])
r(29790, 'Control code 11: repeat earlier text',
  ['The next byte is an offset back (n-256) to some text earlier in the message area, which is rendered up to its own end marker. This saves space where messages share phrases.'])
r(29810, 'Control code 10: random choice',
  ['The next byte is the number of alternatives n, followed by n single items (one or two bytes each). One item is '
   'chosen at random and rendered. This is how Louey varies his patter ("[What wuz dat, Boss? I missed it/It\'s okay, Boss - this line aint tapped...]").'])
r(29873, 'Control code 5: insert a sub-message',
  ['Takes a message address from the VM byte stream (or uses the default set by SETMSG/26740 if it is 0) and renders it.'])
r(29897, 'Control code 8: backspace', ['Moves the buffer pointer back one character (used to remove the space before punctuation).'])
r(29907, 'Expand a common word', ['Byte values 96-127 index the table of common words at #R49710 (values from 128 are two-byte dictionary references and never reach this routine).'])
r(29928, 'Expand a dictionary word',
  ['Words are stored one byte per letter, of which only the low 5 bits count (1=a ... 26=z, 27-31 punctuation), in the dictionary at 48640. Bit 7 marks '
   'the last letter, except on the second letter, or the third if the second also has bit 7 set; this lets short '
   'words overlap the starts of longer ones.'], ['Input|D Bits 0-3: dictionary page; bits 4-6: type', '|E Offset'])
r(30014, 'Get a random number between 0 and n', ['Calls #R30026 (which returns -n..n) and negates a negative result, so the result is always 0..n. Because of the way #R30026 folds large values, the result is not uniform: for n=100, the values 1-27 are twice as likely as the others (raw bytes above 200 are halved, which lands them just above n).'],
  ['Input|A n', 'Output|A Random number'])
r(30026, 'Get a random number',
  ['Steps a pointer through the code of the program itself (30023) and mixes the bytes it finds, ensuring that the '
   'same value never comes up twice in a row, halves it until it is no more than 2*A, and subtracts A, giving a '
   'number between -A and A.'],
  ['Input|A Upper limit', 'Output|A Random number'])
r(30092, 'Run a VM script',
  ['The game logic is written in a compact interpreted language. IY points at the first instruction; instructions '
   'are executed until op 0 (END). See the #LINK(VM)(VM reference) page for the full instruction set. The flags '
   'returned by each instruction are preserved (PUSH AF/POP AF) so that op 12 (JZ) can test the result of a '
   'native routine called by op 14.'], ['Input|IY Script address'])
r(30122, 'Jump to the address in HL')
r(30193, 'Compare two variables and fetch a jump address',
  ['Used by ops 3-8.'], ['Output|F Flags of (second variable - first variable)', '|HL Jump address'])
r(30196, 'Fetch a word from the VM stream', ['Flags are preserved.'], ['Output|HL Word'])
r(30211, 'Fetch a word and then a byte from the VM stream', None, ['Output|HL Word', '|A Byte'])
r(30214, 'Fetch a byte from the VM stream', None, ['Output|A Byte'])
r(30342, 'Compare BCDE with a variable',
  ['Compares the value in BCDE with the variable whose number is the next byte in the VM stream.'],
  ['Input|BCDE First value', 'Output|F Zero set if equal; carry set if the variable is less than BCDE'])
r(30424, 'Load two variables', ['Loads the variable named by the next VM byte into BCDE and the one after into BC\'DE\'.'])
r(30427, 'Load the second operand', ['Loads the variable named by the next VM byte into BC\'DE\'.'])
r(30441, 'VM op 16: ADD (BCDE=BCDE+BC\'DE\')')
r(30482, 'VM op 29: RND (replace E with a random number 0..E)', ['Only the low byte of the accumulator is changed, so RND behaves oddly on values of 2.56 or more. The script only ever uses RND v71 (1.00), giving a random number between 0 and 1.00.'])
r(30491, 'Halve BCDE (arithmetic shift right)')
r(30508, 'VM op 34: SQRT v (BCDE=square root of a variable)')
r(30634, 'VM op 31: NEG (BCDE=-BCDE)')
r(30657, 'VM op 22: MUL (BCDE=BCDE*BC\'DE\'/100)',
  ['Both values are fixed point with two decimal places, so the 64-bit product is divided by 100. The signs are '
   'handled separately by #R30993.'])
r(30715, 'Divide BCDE by BC\'DE\' (x100)',
  ['Returns 0 if the divisor is 0.'])
r(30782, 'Multiply BCDE by the value at 31038 (64-bit)', ['The product goes into 31030-31037.'])
r(30871, 'Shift an 8-byte number left one bit', ['HL points at the low byte.'])
r(30882, 'Shift an 8-byte number right one bit (arithmetic)', ['HL points at the high byte.'])
r(30893, 'Subtract the divisor from the dividend (64-bit)')
r(30945, 'Add the divisor to the dividend (64-bit)')
r(30993, 'Make BCDE and BC\'DE\' positive', ['Records in 31054 whether the result must be negated.'])
r(31055, 'Divide the 64-bit number at 31030 by BCDE', ['Shift-and-subtract long division. The quotient goes into 31038.'])
r(31179, 'Store BCDE in a variable', ['Used by VM op 15 (STORE, #R30335) and by native routines that leave results in VM variables.'], ['Input|L Variable number (from the VM stream)'])
r(31197, 'VM op 28: LOAD (load a variable into BCDE)')
r(31201, 'Load variable L into BCDE', None, ['Input|L Variable number'])
r(31218, 'Clear the screen', ['Clears the display file and sets every attribute to 56 (paper 7, ink 0).'])
r(31247, 'Draw a picture',
  ['Pictures are stored as a list of drawing commands at IY:',
   '#TABLE(default,centre,:w) { =h Command | =h Meaning } '
   '{ 0 | End of picture } '
   '{ 8, x, y | Move the pen to (x,y) } '
   '{ 16, lo, hi, w, h, data... | Copy a w x h block of bytes to the screen at hi*256+lo (ORed into the display file; written directly into the attributes) } '
   '{ 128-255 | Draw a line: bits 0-2 are the direction flags, and the length comes from bits 3-6 and the top 2 bits of the next byte } '
   '{ 64-127, x, y | Flood fill from (x,y); bits 0-2 = the ink colour of the filled cells } '
   '{ 32-63, hi, lo, runs..., 255 | Paint attribute paper colour (bits 0-2) along a path starting at hi*256+lo; each run byte gives a count (bits 2-7) and a direction (bits 0-1: up, right, down, left) } TABLE#'],
  ['Input|IY Picture data'])
r(31484, 'Move HL down one pixel row in the display file (or one row in the attributes)')
r(31511, 'Put a byte from a bitmap block on the screen', ['ORs the byte at IY into the display file, or writes it if HL is in the attribute file.'])
r(31525, 'Flood fill',
  ['Fills the area containing the pixel at (D,E) solidly with ink, scanning left and right along each row and '
   'remembering whether the rows above and below need filling. Every cell it touches also gets A as its ink colour (bits 3-5 of A, if any, are ORed in as paper: the compressed pictures pass 56, meaning ink 0 on paper 7).'],
  ['Input|A Attribute bits for the filled cells (ink in bits 0-2)', '|D x coordinate', '|E y coordinate'])
r(31755, 'Move up one attribute row (unless at the top)')
r(31772, 'Move down one attribute row (unless at the bottom of the picture area)')
r(31796, 'Move left one attribute cell')
r(31806, 'Move right one attribute cell')
r(31823, 'Move HL up one pixel row', ['Returns with the zero flag set if the top of the screen has been reached.'])
r(31851, 'Move HL down one pixel row', ['Returns with the zero flag set if the bottom of the picture area (row 160) has been reached.'])
r(31887, 'Move the pixel mask D one pixel right', ['Returns with the zero flag set at the right edge.'])
r(31900, 'Move the pixel mask D one pixel left', ['Returns with the zero flag set at the left edge.'])
r(31917, 'Draw a line segment',
  ['Plots B pixels from the current position, stepping in the directions given by the flags in C (bit 0: up/down, '
   'bit 1: right, bit 2: left).'])
r(32034, 'Plot the pixel at HL (mask D) and set its attribute')
r(32045, 'Set the ink of the attribute for display file address HL', ['Uses the ink colour in 31522.'])
r(32066, 'Get the display file address and mask for pixel (D,E)',
  ['Uses the ROM routine PIXEL-ADD (entered at 8880, just after its first instructions).'],
  ['Input|D x', '|E y', 'Output|HL Address', '|A Pixel mask'])
r(32084, 'Convert a display file address and mask back to coordinates', ['Inverse of #R32066.'])
r(32126, 'Draw a compressed picture',
  ['The larger full-screen pictures (the Partridge Club and the street outside Milton\'s) use a second, more compact format: a '
   '9-byte header (the offset of the end of the point bit-stream, the bit position where it ends, the offset of the attribute data and four bit widths for the coordinate deltas), a bit-stream of points in which '
   'each coordinate is stored as a variable-width delta read by #R32539, line segments drawn between the points '
   '(#R32612), and finally three run-length encoded passes over the attribute file (ink, then paper, then bright and flash).'],
  ['Input|HL Picture data'])
r(32294, 'Draw the next stroke of a compressed picture', ['Returns with the zero flag set at the end of the point list.'])
r(32365, 'Read the next point (x in C, y in B)')
r(32400, 'Read an x coordinate (absolute or delta)')
r(32434, 'Read a y coordinate (absolute or delta)')
r(32468, 'Read a long x delta')
r(32502, 'Read a long y delta')
r(32539, 'Read D bits from the picture bit-stream', ['The bits come back left-aligned: the value is in the top D bits of A and the callers shift it down.'], ['Input|D Number of bits', 'Output|A The bits, left-aligned'])
r(32596, 'Get the pixel address for (C,B)', ['Uses ROM PIXEL-ADD.'])
r(32612, 'Draw a line from the last point to (C,B)', ['A Bresenham line drawer.'])
r(32785, 'Play the theme tune (if A=16)',
  ['Plays the list of tune fragments at 32832 via #R32866. The stack pointer is temporarily moved to 53792.'],
  ['Input|A SAY flags bits 4-6'])
r(32803, 'Play the tune fragments listed at 32832')
r(32866, 'Play a tune fragment',
  ['Each note is four bytes: pitch, duration (2 bytes) and a flags byte. Stops early if a key is pressed.'],
  ['Input|HL Note data'])
r(32982, 'Delay and toggle the speaker')
r(32995, 'Toggle the speaker with a pulse')
r(33032, 'Short delay')
r(33937, 'Initialise the game variables',
  ['Copies the initial values of v0-v18 from the table at 33812, sets the nine VM flags at 33888 to 1 and chooses '
   'the length of the game: v36 = 7 + 4 x (a random number from 0 to 1.00), which is not rounded (see #LINK(Bugs#years)(the bugs page)).'])
r(33994, 'VM native: "A year goes by ......" animation',
  ['Installs the IM2 interrupt routine at #R34069 (via the jump at 53456 and the vector table at 53504) and then '
   'plays one of two short animations chosen at random: the bar-room scene (step table at 36348) or the getaway '
   'car (step table at 34298).',
   'Nothing in the game chooses between them: not the year, the hoods, the cash or what happened in the year. '
   'The choice is one call of the random routine (#R30014, limit 100); a result below 50 gives the bar room. '
   'That is not an even split, because the routine is not uniform (see #R30026): counting the 256 raw values gives '
   '154 for the bar room and 102 for the car, about 60% to 40%.',
   '#HTML[<img src="../images/baranim.gif" alt="The bar-room animation" /> <img src="../images/caranim.gif" alt="The getaway car animation" />]'])
r(34040, 'Run the steps of an animation',
  ['IX points at a list of step routine addresses. Once per tick (set by the interrupt routine) the current step '
   'is called; while it returns with the zero flag reset it is called again on the next tick, otherwise IX moves on '
   'to the next step. The sequence ends when 33993 is set.'], ['Input|IX Step table'])
r(34065, 'Jump to the address in HL')
r(34069, 'Interrupt routine for the animations',
  ['Counts down 34066; when it reaches zero it reloads it from 34067 and sets the tick flag at 34068.'])
r(34093, 'Draw a 2-cell-wide sprite (no mask)', ['Copies B=2 bytes per pixel row from DE to the screen at HL; the first byte at DE is the height.'])
r(34097, 'Draw a 3-cell-wide sprite (no mask)', ['As #R34093 but 3 bytes wide.'])
r(34135, 'Prepare a pre-shifted masked sprite',
  ['Copies the 32x32 sprite whose address is at HL into the buffer at DE, giving each row of 4 graphic bytes a mask '
   'byte of 255 and a spare 0 byte, then shifts the whole buffer right A pixels.',
   'This routine has a serious bug: it leaves the buffer address on the stack (PUSH DE ... POP HL; PUSH HL) and so, '
   'when A is 0, the RET Z at 34164 "returns" into the sprite buffer and the CPU executes the graphic data. See the '
   '#LINK(Bugs#preshift)(bugs page).'],
  ['Input|A Shift (0-7)', '|DE Buffer (24192 or 24384)', '|HL Pointer to the sprite address'])
r(34318, 'Getaway car animation: step 1 (set up)',
  ['Draws the street picture at 55692 and initialises the positions and timers of the car and the hoods.'])
r(34440, 'Getaway car animation: last step',
  ['Sets 33993 to end the animation, then keeps scrolling the car off the screen.'])
r(34611, 'Getaway car animation: scroll the car and wait')
r(34643, 'Getaway car animation: move the hood running to the car')
r(34707, 'Getaway car animation: move the second hood')
r(34759, 'Restore the background behind the second hood')
r(34769, 'Restore the background behind the first hood')
r(34779, 'Draw the first hood (masked, pre-shifted)')
r(34798, 'Draw the second hood (masked, pre-shifted)')
r(34817, 'Draw the car door')
r(34862, 'Animate the flashing neon sign', ['Runs once per tick (34068).'])
r(34912, 'Draw the car\'s wheels (frame depends on 38791)')
r(34973, 'Draw a masked 2x4 tile')
r(35000, 'Scroll the car one pixel', ['Shifts the car image buffer right and moves the car when 8 pixels have been done.'])
r(35141, 'Draw part of the car (clipped)')
r(35192, 'Draw the exhaust smoke')
r(35251, 'Getaway car animation: animate the passenger')
r(35284, 'Getaway car animation: play the engine noise and draw the passenger')
r(35366, 'Getaway car animation: animate the driver')
r(35406, 'Draw the car (unrolled, clipped at the screen edge)',
  ['A long unrolled loop that ORs the car graphic into the screen, with clipping at column 30, for speed.'])
r(35854, 'Move H to the next third of the display file')
r(36366, 'Bar-room animation: step 1 (set up)',
  ['Draws the Partridge Club picture at 53793 and initialises the frame pointers and timers for the animated '
   'customers, waiters and hoods.'])
r(36486, 'Bar-room animation: last step (end the animation)')
r(36495, 'Bar-room animation: count down the delay')
r(36508, 'Bar-room animation: animate and wait for the door to open')
r(36527, 'Bar-room animation: the hoods walk in')
r(36546, 'Bar-room animation: the hoods cross the room')
r(36566, 'Bar-room animation: the hoods go out')
r(36572, 'Bar-room animation: final pause')
r(36586, 'Bar-room animation: update all the animated figures')
r(36610, 'Get a random delay', ['A=B+random(0..C).'], ['Input|B Minimum', '|C Range'])
r(36617, 'Animate the hoods walking through the club')
r(36664, 'Advance the hoods\' route table')
r(36703, 'Animate figure 1 (the doorman)')
r(36752, 'Animate figure 2')
r(36788, 'Animate figure 3')
r(36824, 'Animate figure 4')
r(36861, 'Animate figure 5')
r(36911, 'Animate figure 6')
r(36961, 'Animate figure 7')
r(37032, 'Animate figure 8')
r(37095, 'Draw a 3-cell-wide sprite at 18536')
r(41997, 'Delay for BC units, B times')
r(42014, 'Short delay (length at 41995)')
r(42026, 'Play the shootout sound effect', ['Plays the bit pattern at 42057 through the speaker.'])
r(42112, 'Shootout with the hit man from Detroit',
  ['An arcade sequence. Mugsy (controlled with Q/Z up/down, I/P left/right and B/N/M to fire) must shoot the hit man '
   'in a restaurant before the hit man shoots him. Installs its own IM2 interrupt routine (#R48539), sets '
   'Mugsy\'s hit points to (A AND 7)+1 (42301; the hit man always has 4, at 42302), runs the game and restores IM1 on exit.'],
  ['Input|A Value from the handout: Mugsy gets (A AND 7)+1 hit points (8 if A is 255)', 'Output|A Result: bit 0 set if Mugsy was killed; bits 2-3 set if bystanders were hit'])
r(42639, 'Shootout: set up the restaurant')
r(42931, 'Shootout: draw a table')
r(42940, 'Shootout: draw a chair')
r(42957, 'Shootout: draw a pair of chairs')
r(42970, 'Shootout: copy a sprite to the screen and set its attributes')
r(42977, 'Shootout: main loop')
r(43709, 'Shootout: move the hit man')
r(44153, 'Shootout: hit man AI - choose a direction')
r(44403, 'Shootout: check for a clear line of fire')
r(44525, 'Shootout: fire the hit man\'s gun')
r(44612, 'Shootout: move a bullet')
r(44726, 'Shootout: check for a bullet hitting a figure')
r(44766, 'Shootout: process Mugsy\'s move')
r(44884, 'Shootout: animate the death of a figure')
r(44953, 'Shootout: draw a figure')
r(45044, 'Shootout: erase a figure')
r(45079, 'Shootout: draw the walls')
r(45122, 'Shootout: compute the screen address of a figure')
r(45155, 'Shootout: check for collision with furniture')
r(45182, 'Shootout: check for collision with a wall')
r(45201, 'Shootout: draw the door')
r(45276, 'Shootout: animate the door')
r(45353, 'Shootout: check whether Mugsy has reached the door')
r(45423, 'Shootout: move a figure up')
r(45438, 'Shootout: move a figure down')
r(45458, 'Shootout: move a figure left')
r(45479, 'Shootout: move a figure right')
r(45515, 'Shootout: fire Mugsy\'s gun')
r(45626, 'Shootout: play the gunshot sound')
r(45636, 'Shootout: flash the border')
r(45651, 'Shootout: pause')
r(45665, 'Shootout: wait for the next tick')
r(45693, 'Shootout: print a message')
r(45702, 'Shootout: draw the score panel')
r(45965, 'Shootout: initialise the figures')
r(46305, 'Shootout: clear the screen and draw the room outline')
r(46428, 'Shootout: delay')
r(46454, 'Shootout: fill a buffer with 255')
r(46460, 'Shootout: read the controls',
  ['Reads Q (up), Z (down), I (left), P (right) and B/N/M (fire) and converts them to a direction code. Opposite '
   'directions pressed together cancel out.'], ['Output|A Direction code'])
r(46640, 'Shootout: no movement')
r(48539, 'Interrupt routine for the shootout')
r(53456, 'Interrupt jump',
  ['The IM2 vector table at 53504 is filled with 208, so every interrupt jumps here (53456=208*257). The address '
   'is set to #R34069 or #R48539 when interrupts are enabled. Note that these three bytes sit in the middle of '
   'leftover assembler source text (see the #LINK(Facts#source)(trivia page)).'])

# VM op handlers inside routines (extra entry points)
EXTRA = {
    30120: 'VM op 0: END', 30225: 'VM op 1: SAY', 30231: 'VM op 2: SETMSG', 30238: 'VM op 3: IFEQ',
    30246: 'VM op 4: IFNE', 30252: 'VM op 5: IFLE', 30258: 'VM op 6: IFLT', 30265: 'VM op 7: IFGT',
    30271: 'VM op 8: IFGE', 30279: 'VM op 9: IFPEEKEQ', 30289: 'VM op 10: IFPEEKNE', 30299: 'VM op 11: POKE',
    30307: 'VM op 12: JZ', 30313: 'VM op 13: GOTO', 30318: 'VM op 14: CALL', 30335: 'VM op 15: STORE',
    30433: 'VM op 17: ADD v', 30438: 'VM op 18: ADD v,v', 30456: 'VM op 20: SUB v', 30461: 'VM op 21: SUB v,v',
    30464: 'VM op 19: SUB', 30479: 'VM op 30: RND v', 30488: 'VM op 32: HALF v', 30511: 'VM op 33: SQRT (Newton\'s method; never terminates for some values; see #LINK(Bugs#sqrt)(the bugs page))',
    30580: 'VM op 27: INT', 30649: 'VM op 23: MUL v', 30654: 'VM op 24: MUL v,v', 30707: 'VM op 25: DIV v',
    30712: 'VM op 26: DIV v,v', 29570: 'Control codes 0, 2, 3, 6, 7, 9 and 12-20 (no-op)', 29574: 'Control code 21: full stop and end',
    29594: 'Control code 22: end', 29608: 'Control code 1: print " $" and a variable',
    29621: 'Control code 4: print " " and a variable',
    34455: 'Getaway step 2', 34481: 'Getaway step 3', 34513: 'Getaway step 5', 34537: 'Getaway step 6',
    34558: 'Getaway step 7', 34579: 'Getaway step 8', 34600: 'Getaway step 9',
}

ROUTINE_NAMES = {a: v[0][0].lower() + v[0][1:] for a, v in R.items()}
ROUTINE_NAMES.update({a: v for a, v in EXTRA.items()})

LABELS = {
    24576: 'START', 24589: 'MAINLOOP', 24614: 'PLAYYEAR', 26812: 'DRAWLAYOUT', 26876: 'WAITKEY',
    26921: 'CHARADDR', 26940: 'PRINTCHAR', 27724: 'ROMCHAR', 27753: 'YESNO', 27790: 'GETNUMBER',
    28037: 'READLINE', 28297: 'HUSHMONEY', 28358: 'HITMAN', 28549: 'SAY', 28757: 'PRINTBUBBLE',
    29320: 'RENDER', 29458: 'RENDERITEM', 29630: 'PRINTNUM', 29928: 'DICTWORD', 30014: 'RANDOMPM',
    30026: 'RANDOM', 30092: 'RUNVM', 30196: 'FETCHWORD', 30214: 'FETCHBYTE', 30342: 'COMPARE',
    31179: 'STOREVAR', 31201: 'LOADVAR', 31218: 'CLS', 31247: 'DRAWPIC', 31525: 'FILL', 32126: 'DRAWCPIC',
    32785: 'TUNE', 33937: 'INITVARS', 33994: 'YEARGOESBY', 34040: 'RUNSTEPS', 34069: 'ISR1',
    34135: 'PRESHIFT', 42112: 'SHOOTOUT', 46460: 'CONTROLS', 48539: 'ISR2', 53456: 'INTJUMP',
}

# ---- corrected titles (from inspecting each routine)
_fix = {
    42931: 'Shootout: wait for an interrupt', 42940: 'Shootout: store a figure\'s screen and attribute data',
    42957: 'Shootout: request a figure redraw (HL=screen address, DE=attribute address)',
    42970: 'Shootout: redraw a figure and wait for an interrupt', 42977: 'Shootout: main loop',
    43709: 'Shootout: draw the next animation frame of a figure', 44153: 'Shootout: check for furniture next to a figure',
    44403: 'Shootout: get the next byte of a figure\'s route', 44525: 'Shootout: look for a figure in the line of fire',
    44612: 'Shootout: move a bullet', 44726: 'Shootout: move and redraw the current figure',
    44766: 'Shootout: deal with Mugsy firing', 44884: 'Shootout: deal with a hit', 44953: 'Shootout: move a figure',
    45044: 'Shootout: remove the gun flash', 45079: 'Shootout: update a figure\'s position',
    45122: 'Shootout: move to the next figure slot', 45155: 'Shootout: copy the current figure\'s coordinates',
    45182: 'Shootout: compute a figure\'s pixel shift', 45201: 'Shootout: draw a figure (masked)',
    45276: 'Shootout: erase a figure', 45353: 'Shootout: get the next animation frame',
    45423: 'Shootout: step a figure in its current direction', 45438: 'Shootout: move right one cell (unless at column 28)',
    45458: 'Shootout: move left one cell (unless at the left limit)', 45479: 'Shootout: move up one pixel row (unless at the top limit)',
    45515: 'Shootout: move down one pixel row (unless at the bottom limit)',
    45626: 'Convert a display file address in DE into an attribute address', 45636: 'Move HL up one pixel row',
    45651: 'Move HL down one pixel row', 45665: 'Shootout: clear the screen',
    45693: 'Shootout: copy a figure\'s 39-byte record into the workspace at 42336',
    45702: 'Shootout: copy the workspace at 42336 back into a figure\'s record',
    45965: 'Shootout: XOR a sprite onto the screen', 46305: 'Shootout: draw the walls of the restaurant',
    46428: 'Shootout: plot a pixel', 46454: 'Shootout: draw a horizontal line',
    48539: 'Interrupt routine for the shootout: move the figures',
    34862: 'Getaway car animation: draw the next frame of the animation at 21260',
    34912: 'Getaway car animation: draw the car\'s moving parts (frame depends on 38791)',
    34817: 'Getaway car animation: draw the 5-byte-wide graphic at 18465',
    35192: 'Getaway car animation: draw the masked graphic at 19299',
    35251: 'Getaway car animation: draw the next frame of the figure at 18838',
    35284: 'Getaway car animation: play a delay sound and animate the figures',
    35366: 'Getaway car animation: draw the next frame of the figure at 17728',
    34643: 'Getaway car animation: move the first hood', 34707: 'Getaway car animation: move the second hood',
    36703: 'Bar-room animation: animate figure 1 (at 21584)', 36752: 'Bar-room animation: animate figure 2 (at 16769)',
    36788: 'Bar-room animation: animate figure 3 (at 16803)', 36824: 'Bar-room animation: animate figure 4 (at 17253)',
    36861: 'Bar-room animation: animate figure 5 (at 19576)', 36911: 'Bar-room animation: animate figure 6 (at 19087)',
    36961: 'Bar-room animation: animate figure 7 (at 18633)', 37032: 'Bar-room animation: animate figure 8',
    36617: 'Bar-room animation: animate the hoods walking through the club',
    36664: 'Bar-room animation: advance along the hoods\' route table',
}
for _a, _t in _fix.items():
    if _a in R:
        R[_a] = (_t, [] if _a not in (42977, 48539) else R[_a][1], R[_a][2])
    else:
        R[_a] = (_t, [], [])
R[44766] = (R[44766][0], [], [])
ROUTINE_NAMES = {a: v[0][0].lower() + v[0][1:] for a, v in R.items()}
ROUTINE_NAMES.update({a: v for a, v in EXTRA.items()})

C = {
# 24576 START
24576: 'Disable interrupts', 24577: 'Put the stack in the printer buffer, just below the system variables',
24580: 'Save IY (the ROM interrupt routine needs it to point at the system variables)',
24584: 'Play games until the player has had enough', 24587: 'Then hang forever (see #LINK(Bugs#noquit)(the bugs page))',
# 24589 MAINLOOP
24589: 'Initialise the VM variables and flags', 24592: 'Run the script at 24609: Louey says "Hi Boss, it\'s Louey your sidekick here..."',
24596: None, 24599: 'Play years until the game ends', 24602: 'Pick up the game status flag (1=quit, 2=new game)',
24605: None, 24606: 'Return (and hang) if the player doesn\'t want another game', 24607: 'Otherwise start a new game',
# 24614 PLAYYEAR
24614: 'No bubble layout is current yet', 24617: None, 24620: 'Pick a random number between -100 and 100',
24622: None, 24625: 'Is it less than 50?', 24627: 'Use the first table of bubble layouts...', 24630: '...if so',
24632: 'Otherwise use the second table', 24635: 'Store the layout table pointer',
24638: 'Run the main script at 24652 for this year', 24642: None, 24645: 'Has the game finished?', 24648: None,
24649: 'Play another year if not', 24651: None,
# 26876 WAITKEY
26876: None, 26877: None, 26878: 'B=number of timeout periods', 26879: None, 26880: 'Read every half-row of the keyboard',
26882: 'Keep the key bits only', 26884: 'Are all keys released?', 26886: 'Wait until they are',
26888: 'Wait about a second for a keypress', 26891: 'Finish if a key was pressed', 26893: 'Otherwise try again for up to B periods',
# 27753 YESNO
27753: 'Read a line of input', 27756: 'Pick up the first character', 27759: '"Y"?', 27761: 'Return with the zero flag set if so',
27762: '"y"?', 27764: None, 27765: '"N"?', 27767: 'Jump if so', 27769: '"n"?', 27771: None,
27773: 'Otherwise Louey says "Don\'t get smart wit\' me, Mugsy!..."', 27777: None, 27780: 'And asks again',
27782: 'Reset the zero flag for "no"', 27784: None,
# 27790 GETNUMBER
27790: 'Read a line of input', 27793: 'Parse it as a number into v35', 27796: 'Jump unless it was invalid',
27798: 'Louey says "What wuz dat, Boss?..." (and the blunder count goes up)', 27802: None, 27805: 'Ask again',
# 30014 RANDOMPM
30014: 'Get a random number 0..A', 30017: 'Is bit 7 of the result set?', 30019: 'Return if not', 30020: 'Otherwise negate it', 30022: None,
# 30026 RANDOM
30026: None, 30028: None, 30029: 'C=upper limit', 30030: 'Double it for the mask comparison',
30032: None, 30034: 'Limit to 255', 30036: 'B=limit*2', 30037: 'Point IX at the random number pointer',
30041: 'Increment the low byte of the pointer...', 30044: None, 30046: '...and the high byte if necessary',
30049: 'IX=pointer (which wanders through the program code)', 30053: 'Pick up the last random number',
30056: 'Add the byte at the pointer', 30059: 'Step on by DE (whatever DE happens to hold)',
30061: 'Mix in another byte', 30064: None, 30065: 'Is the new number the same as the last one?', 30068: None, 30069: None,
30070: 'Try again if so', 30072: 'Store the new random number', 30075: 'Halve it until it is no greater than 2*limit',
30076: None, 30078: None, 30080: None, 30082: None, 30085: 'Subtract the limit (giving -limit..+limit)', 30086: None, 30087: None, 30089: None,
# 30092 RUNVM
30092: 'Set the VM program counter', 30096: 'Save the flags from the previous instruction',
30097: 'Fetch the opcode', 30100: 'Double it for the jump table at 30123', 30101: None,
30104: None, 30105: None, 30106: None, 30108: None, 30109: 'HL=entry in the jump table',
30110: 'Pick up the handler address', 30111: None, 30112: None, 30113: None,
30114: 'Restore the flags from the previous instruction', 30115: 'Execute the instruction', 30118: 'Back for the next one',
30120: 'Op 0 (END): drop the return address to 30118...', 30121: '...and return from the interpreter',
30122: 'Jump to the opcode handler',
# 30193..
30193: 'Compare the variable in the next byte with the one in the byte after', 30196: 'Save the flags',
30197: 'Pick up the VM program counter', 30200: 'Fetch the low byte', 30201: None, 30202: None,
30203: 'Advance the program counter by 2', 30206: None, 30207: 'Fetch the high byte', 30208: 'HL=word', 30209: 'Restore the flags', 30210: None,
30211: 'Fetch a word into HL first', 30214: None, 30215: 'Pick up the VM program counter', 30218: 'Fetch the byte',
30219: None, 30220: 'Advance the program counter', 30223: None, 30224: None,
30225: 'Op 1 (SAY): fetch the message address (HL) and the flags (A)', 30228: 'Show the speech bubble',
30231: 'Op 2 (SETMSG): fetch a message address', 30234: 'Make it the default sub-message for control code 5', 30237: None,
30238: 'Op 3 (IFEQ): compare the variables', 30241: 'Return unless they are equal',
30242: 'Jump: set the VM program counter to HL', 30245: None,
30246: 'Op 4 (IFNE)', 30249: 'Return if the variables are equal', 30250: 'Otherwise jump',
30252: 'Op 5 (IFLE)', 30255: 'Return if the second variable is less than the first', 30256: 'Otherwise jump',
30258: 'Op 6 (IFLT)', 30261: 'Return if the variables are equal...', 30262: '...or if the second is less than the first', 30263: 'Otherwise jump',
30265: 'Op 7 (IFGT)', 30268: 'Return unless the second variable is less than the first', 30269: 'Otherwise jump',
30271: 'Op 8 (IFGE)', 30274: 'Jump if the variables are equal', 30276: 'Return if the second variable is greater', 30277: 'Otherwise jump',
30279: 'Op 9 (IFPEEKEQ): fetch an address and a byte', 30282: 'Compare the byte at the address', 30283: 'Fetch the jump address',
30286: 'Return unless equal', 30287: 'Otherwise jump',
30289: 'Op 10 (IFPEEKNE): fetch an address and a byte', 30292: 'Compare the byte at the address', 30293: 'Fetch the jump address',
30296: 'Return if equal', 30297: 'Otherwise jump',
30299: 'Op 11 (POKE): fetch the byte', 30302: 'Fetch the address', 30305: 'POKE it', 30306: None,
30307: 'Op 12 (JZ): fetch the jump address (preserving the flags)', 30310: 'Return if the zero flag is reset', 30311: 'Otherwise jump',
30313: 'Op 13 (GOTO): fetch the jump address', 30316: 'And jump',
30318: 'Op 14 (CALL): save the address of the operand', 30321: None, 30322: 'Fetch the address of the native routine',
30325: 'Call it', 30328: 'Restore the address of the operand', 30329: None, 30330: 'Skip the operand',
30331: 'Set the VM program counter (anything the native routine fetched is ignored)', 30334: None,
30335: 'Op 15 (STORE): fetch the variable number', 30338: None, 30339: 'Store BCDE in it',
# 33937 INITVARS
33937: 'Copy the initial values of v0-v18...', 33940: '...from the table at 33812 (which doubles as variables v65-v83)',
33943: None, 33946: None, 33948: 'Set the nine VM flag bytes at 33888...', 33951: None, 33953: '...and the game status flag to 1',
33955: None, 33956: None, 33958: 'BCDE=1.00', 33961: None, 33964: 'Get a random number in BCDE (0..1.00)',
33967: None, 33968: "BC'DE'=4.00", 33971: None, 33974: 'Multiply', 33977: None, 33978: "BC'DE'=7.00", 33981: None,
33984: 'Add', 33987: 'Store the result in v36 (the length of the game in years)', 33989: None, 33992: None,
# 33994 YEARGOESBY
33994: None, 33995: 'Point the interrupt jump at 53456...', 33998: '...at the interrupt routine at 34069',
34001: 'Point I at the vector table at 53504', 34003: None, 34005: None, 34007: None,
34008: 'Clear the sequence-finished flag', 34009: None, 34012: 'Pick one of the two animations at random',
34014: None, 34017: 'Bar-room animation...', 34021: None, 34023: '...if the number is below 50',
34025: 'Otherwise the getaway car animation', 34029: 'Run the animation', 34032: None,
34033: 'Restore I (63 is its normal value)', 34035: None, 34037: 'Back to interrupt mode 1', 34039: None,
# 34040 RUNSTEPS
34040: 'Has the animation finished?', 34043: None, 34044: 'Return if so', 34045: None,
34046: 'Wait for an interrupt', 34047: None, 34048: 'Pick up the address of the current step routine', 34051: None,
34054: 'Call it', 34057: 'Keep calling it until it returns with the zero flag set', 34059: 'Then move to the next step',
34061: None, 34063: None, 34065: 'Jump to the step routine',
# 34069 ISR1
34069: None, 34070: 'Decrement the interrupt countdown', 34073: None, 34074: None, 34077: 'Jump unless it has reached zero',
34079: 'Reload the countdown', 34082: None, 34085: 'Set the tick flag', 34087: None, 34090: None, 34091: None,
# 34135 PRESHIFT (the bug)
34135: 'Push the buffer address (this is the problem)', 34136: 'Pick up the address of the sprite graphic', 34137: None, 34138: None,
34139: 'HL=buffer address', 34140: 'Leave it on the stack (above the return address)', 34141: 'HL=graphic, DE=buffer',
34142: 'Save the shift count', 34143: 'A=0', 34144: None, 34145: '32 pixel rows', 34147: None,
34148: 'Copy the 4 graphic bytes of this row', 34151: None, 34153: 'A=255', 34154: 'Add a mask byte of 255', 34155: None,
34156: 'A=0', 34157: 'Add a spare byte of 0', 34158: None, 34159: None, 34160: 'Next row',
34162: 'Restore the shift count', 34163: 'Is it zero?', 34164: 'BUG: return to the buffer address left on the stack if so',
34165: 'C=shift count', 34166: 'HL=buffer', 34167: None, 34168: '32 rows', 34170: 'Rotate a 1 into the mask...',
34171: None, 34173: None, 34174: None, 34175: None, 34177: None, 34178: None, 34179: None, 34181: None, 34182: None,
34183: None, 34184: '...and a 0 into the graphic', 34185: None, 34187: None, 34188: None, 34189: None, 34191: None,
34192: None, 34193: None, 34195: None, 34196: 'Next row', 34198: None, 34199: 'Repeat for each pixel of the shift',
34201: 'Drop the buffer address', 34202: 'Return properly',
}

# ---- text renderer (29320-29630)
C.update({
29320: 'Save the message address', 29321: None, 29322: 'Clear the first-character flag', 29325: 'Point the buffer pointer at the start of the text buffer',
29328: None, 29331: 'IX=message address', 29333: 'Render the message into the buffer', 29336: 'Terminate the buffer with a zero byte', 29337: None,
29340: 'Has the bubble layout changed since the last message?', 29343: None, 29344: 'Jump if so (the screen will be redrawn anyway)',
29346: 'HL=width of the new text in pixels', 29349: 'DE=width of the previous text', 29353: None, 29354: 'Is the new text at least as wide?',
29356: 'Jump if so (the new bubble will cover the old one)', 29358: 'Otherwise work out how many 3-pixel spaces are needed...', 29361: None,
29362: None, 29363: '...HL=old width-new width', 29365: 'Spaces are 3 pixels wide', 29368: 'BC will count the spaces', 29371: None, 29372: None,
29373: 'Divide by 3', 29375: None, 29377: 'Are any spaces needed?', 29378: None, 29379: 'Jump if not',
29381: 'Save the number of spaces', 29382: 'Half of them go in front of the text', 29384: None,
29386: 'HL=address of the terminator', 29389: 'HL=address of the last character', 29390: None, 29391: 'DE=HL', 29392: 'Move the end of the text along by BC',
29393: 'Update the buffer pointer', 29396: 'HL=last character, DE=its new position', 29397: 'BC=length of the text', 29400: None, 29401: None,
29403: None, 29404: None, 29405: None, 29406: 'Shift the text right to make room for the leading spaces', 29408: 'Restore the total number of spaces',
29409: 'HL=end of the text', 29412: 'DE=start of the buffer', 29415: 'Fill in pairs of spaces...', 29416: None, 29417: 'Jump if at least 256 left',
29419: None, 29420: None, 29421: 'Jump if none left', 29423: 'Just one left?', 29425: 'Jump if so',
29427: 'Put a space at the front...', 29429: None, 29430: '...and one at the end', 29431: None, 29432: None, 29433: None, 29434: 'Two fewer spaces to place', 29435: None,
29437: 'Put the odd space at the end', 29439: None, 29440: 'Terminate the text', 29442: 'Update the buffer pointer',
29445: 'Measure the final text...', 29448: '...and remember its width for next time', 29451: None,
29452: 'Render one item', 29455: 'Repeat until an item ends the message', 29457: None,
29458: 'Pick up the first byte of the item', 29461: 'Is it a two-byte dictionary reference?', 29463: 'Jump if not',
29465: 'D=first byte without bit 7 (bits 0-3: page; bits 4-6: type)', 29467: None, 29468: 'E=offset into the page', 29471: 'Point IX at the second byte',
29473: 'Keep the type bits', 29475: 'Type 3 (last word plus full stop)?', 29477: 'Jump if so', 29479: 'Type 2 (last word)?', 29481: 'Jump if so',
29483: 'Type 6 (last word)?', 29485: 'Jump if so', 29487: 'Print the dictionary word', 29490: 'Move IX to the next item',
29492: 'Reset the zero flag: the message continues', 29494: None,
29495: 'Is it a control code (0-31)?', 29497: 'Jump if so', 29499: 'Is it a common word (96-127)?', 29501: 'Jump if so',
29504: 'Otherwise it is a literal character: put it in the buffer', 29507: 'And move on',
29509: 'Is it an upper case letter?', 29511: None, 29513: None, 29515: None, 29517: 'Convert it to lower case (which the font draws as small capitals)',
29519: None, 29520: 'HL=buffer pointer', 29523: 'Store the character', 29524: 'Has anything been stored yet?', 29527: None,
29528: 'A=the character', 29529: 'Jump if so: advance the pointer', 29531: 'Note that something has been stored', 29534: 'Is the first character a space?',
29536: "Jump if so: do not advance, so the next character overwrites it", 29538: 'Advance the buffer pointer', 29539: None, 29542: None, 29543: None,
29544: 'Save DE', 29545: 'DE=control code', 29546: None, 29548: 'Point HL at the control code jump table', 29551: None, 29552: 'Add 2*code',
29553: 'Pick up the handler address', 29554: None, 29555: None, 29556: 'HL=handler address', 29557: 'Restore DE', 29558: 'Codes 20 and above...',
29560: '...are jumped to directly (they end the message)', 29562: 'Codes 0-19 are called', 29565: 'Zero flag set: the handler has done its work; move on',
29567: 'Otherwise print the dictionary word in DE', 29569: 'Jump to the handler',
29570: 'D=96 (as for a type 6 last word)', 29572: 'End the message without a full stop',
29574: 'D=48 (as for a type 3 last word)', 29576: 'End the message with a full stop',
29578: 'Print the last word', 29581: 'A=full stop', 29583: 'Type 6?', 29585: 'Jump if so: no full stop',
29587: 'Type 3?', 29589: 'Print the full stop if so', 29592: None, 29594: 'Set the zero flag: end of message', 29595: None,
29596: 'Fetch a variable number from the VM byte stream', 29599: 'L=variable number', 29600: 'Load the variable into BCDE', 29603: 'A=space',
29605: 'Put a space in the buffer', 29608: 'Fetch the variable and put a space in the buffer', 29611: 'A="$"', 29613: 'Put it in the buffer',
29616: 'Print the number', 29619: 'Set the zero flag: control code done', 29620: None,
29621: 'Fetch the variable and put a space in the buffer', 29624: 'Print the number', 29627: 'Set the zero flag: control code done', 29628: None,
})

# ---- number printing, control codes 10/11/5/8, dictionary words (29630-30013)
C.update({
29630: 'Is the number negative?', 29632: 'Jump if not', 29634: 'Make it positive', 29637: 'A="-"', 29639: 'Put the minus sign in the buffer',
29642: 'Copy the high word (BC) into HL\'', 29643: None, 29644: None, 29645: None, 29646: 'HL=low word', 29647: 'Leading zeros are not printed yet',
29648: None, 29651: 'BC/DE=1,000,000,000 (the number is in hundredths, so this is ten million)', 29654: None, 29657: 'Print that digit',
29660: 'BC/DE=100,000,000', 29663: None, 29666: None, 29669: 'BC/DE=10,000,000', 29672: None, 29675: None, 29678: 'BC/DE=1,000,000', 29681: None, 29684: None,
29687: 'BC/DE=100,000', 29690: None, 29693: None, 29696: 'BC/DE=10,000', 29699: None, 29702: None, 29705: 'BC/DE=1,000 (tens)', 29708: None, 29711: None,
29714: 'From now on zeros are printed (so 0 comes out as "0")', 29716: None, 29719: 'BC/DE=100 (units)', 29722: None, 29725: None,
29728: 'Is there a fractional part?', 29729: None, 29730: 'Return if not: whole numbers have no decimal point', 29731: 'A="."', 29733: 'Put the decimal point in the buffer',
29736: 'BC/DE=10 (tenths)', 29739: None, 29742: None, 29745: 'A=hundredths digit', 29746: 'Convert it to ASCII', 29748: 'Put it in the buffer', 29751: None,
29752: 'Copy the high word of the power of ten into DE\'', 29753: None, 29754: None, 29755: None, 29756: 'C will count from "0"',
29758: 'Next digit value', 29759: None, 29760: 'Subtract the power of ten (low word)...', 29762: None, 29763: '...and high word', 29765: None,
29766: 'Repeat until the number goes negative', 29768: 'Add the power of ten back on (low word)...', 29769: None, 29770: '...and high word', 29772: None,
29773: 'Has a non-zero digit been printed yet?', 29776: None, 29777: 'A=digit', 29778: 'Print it if so', 29781: 'Is it a leading zero?', 29783: 'Skip it if so',
29784: 'Otherwise leading zeros are over', 29787: 'Print the digit',
29790: 'Save the message pointer', 29792: 'E=offset (as a negative number: the text is earlier in memory)', 29795: None, 29797: 'IX=address of the earlier text',
29799: 'Render it until its own end marker', 29802: 'Restore the message pointer', 29804: 'Skip the offset byte', 29806: 'Set the zero flag: code done', 29807: None,
29810: 'Point at the number of alternatives', 29812: None, 29815: 'Store it as the counter', 29818: 'A=n-1', 29819: 'Pick a random number 0..n-1',
29822: 'A=1..n', 29823: 'Store the choice', 29826: 'Point at the first alternative',
29828: 'Is this the chosen alternative?', 29831: None, 29834: None, 29835: 'Jump if not', 29837: None, 29839: 'Render it', 29842: None,
29844: 'Get the first byte of this alternative', 29847: 'A dictionary word (2 bytes)?', 29849: 'Jump if so', 29851: 'Control code 2 (2 bytes)?', 29853: None,
29855: 'Control code 11 (2 bytes)?', 29857: 'Jump if not', 29859: 'Skip the second byte', 29861: 'Skip the first byte',
29863: 'Count down the alternatives', 29866: None, 29867: 'Jump back for the next one', 29869: 'Point at the last byte (the caller moves on)',
29871: 'Set the zero flag: code done', 29872: None,
29873: 'Fetch a message address from the VM byte stream', 29876: 'DE=address', 29877: 'Is it 0?', 29878: None, 29879: 'Jump if not',
29881: 'Otherwise use the default set by SETMSG', 29885: 'Save the message pointer', 29887: None, 29888: 'IX=sub-message', 29890: 'Render it',
29893: 'Restore the message pointer', 29895: 'Set the zero flag: code done', 29896: None,
29907: 'A=index (0-31)', 29909: None, 29910: None, 29912: 'Point HL at the table of common words', 29915: None, 29916: 'Add 2*index',
29917: 'E=offset', 29918: None, 29919: 'A=page', 29920: 'Add 80 (type 5: an ordinary word)', 29922: 'D=page and type', 29923: 'Print the word',
29928: 'Is the reference zero (no word)?', 29929: None, 29931: None, 29932: 'Return if so', 29933: None, 29934: None, 29935: None,
29936: 'C=type', 29937: None, 29938: 'D=page (0-15)', 29940: None, 29941: 'HL=48640+256*page+offset', 29944: None,
29945: None, 29949: 'Put a space before the word', 29951: None,
29954: 'First letter: low 5 bits', 29955: None, 29956: None, 29958: 'Convert to a lower case letter', 29960: 'B=letter',
29961: 'Is this a capitalised word (type 7)?', 29962: None, 29964: None, 29966: 'Jump if not', 29968: 'Make the letter upper case',
29970: None, 29971: 'Put the first letter in the buffer', 29974: 'B counts the letters',
29976: 'Next letter', 29977: None, 29979: 'A zero letter ends the word', 29981: 'Count it', 29982: 'Convert to a lower case letter',
29984: 'Put it in the buffer', 29987: 'Does bit 7 mark the end of the word?', 29989: None, 29990: 'Carry on if not',
29992: 'Bit 7 is ignored on the second letter...', 29993: None, 29995: None, 29997: '...and on the third...', 29999: 'Finished if this is the fourth letter or later',
30001: '...if the second letter also had bit 7 set', 30002: None, 30003: None, 30004: None, 30005: None, 30006: None, 30008: 'Carry on if so',
30010: None, 30011: None, 30012: None, 30013: None,
})

# ---- SAY and the speech bubble (28549-29028)
C.update({
28549: 'Save the SAY flags', 28552: 'Save the message address', 28553: 'Point IY at the fixed "answer" bubble layout', 28557: 'Keep bits 2 and 3 of the flags',
28559: 'Bit 2 set?', 28561: 'Use the fixed layout if so', 28563: 'Otherwise start with the current layout', 28567: 'Bit 3 set?', 28569: 'Keep the current layout if so',
28571: 'Otherwise pick a layout at random: point IY at this year\'s layout table', 28575: None, 28577: 'A=random number 0-100',
28580: 'Compare it with the entry\'s chance', 28583: 'Use this entry if the number is lower', 28585: 'Otherwise move on to the next entry', 28587: None, 28589: None, 28591: None, 28593: None,
28595: 'Is it the layout already on screen?', 28598: 'If so pick again (the bubble must move)',
28600: 'Set A=1 if the layout has changed', 28603: 'Store the layout-unchanged flag', 28606: 'Make this the current layout',
28610: 'Draw the picture (or just wipe the old bubble)', 28613: 'Print the status lines', 28616: None,
28619: 'Restore the message address', 28620: 'Render the message into the text buffer', 28623: 'Point IX at the text buffer', 28627: 'HL=top of the screen',
28630: 'Print the text in a bubble', 28633: 'Pick up the SAY flags', 28636: 'Keep bits 4-6', 28638: 'Play the theme tune if they are 16',
28641: 'Pick up the SAY flags again', 28644: 'Keep bits 0-1', 28646: 'Return unless they ask for a pause', 28647: 'Wait up to 8 periods...', 28649: '...or until a key is pressed',
28652: None, 28653: None, 28654: 'HL=IY', 28656: None, 28657: 'DE=current layout', 28661: None, 28662: 'Compare', 28664: 'A=0 (unchanged)', 28666: None, 28667: None,
28668: 'Return with A=0 and the zero flag set if they are the same', 28669: 'A=1 (changed)', 28670: None,
28671: 'Point DE at the word width list', 28674: None, 28676: None, 28677: 'Measure the next word', 28680: 'Was it empty (two spaces in a row)?',
28681: 'Skip it if so', 28683: 'Store its width', 28684: None, 28685: 'Reached the end of the text?', 28688: None, 28689: 'Back for the next word if not',
28691: 'Terminate the list with 255', 28693: None, 28694: None, 28695: None, 28697: None,
28698: None, 28699: None, 28700: 'C will accumulate the width', 28702: 'Pick up a character', 28705: 'End of the text?', 28706: 'Finish if so',
28708: 'Get the address of its glyph', 28711: 'A=width of the character', 28712: '+1 pixel of spacing', 28713: None, 28714: 'Add it to the total',
28715: 'Pick up the character again', 28718: 'Move on', 28720: 'Was it a space?', 28722: 'Carry on until the end of the word', 28724: None, 28725: 'A=width of the word', 28726: None, 28727: None,
28757: 'Measure the words of the text', 28760: None, 28762: None, 28764: 'Save the screen address', 28765: 'Work out the number of lines needed (B)',
28768: 'Is it odd?', 28769: None, 28771: 'Store the odd-line flag', 28774: None, 28775: 'B/2 lines in each half of the bubble', 28777: None, 28780: None,
28781: 'C=index of the widest line', 28784: None, 28785: None, 28786: None, 28788: 'Look up the left offset of the bubble', 28791: None, 28792: None,
28793: 'Restore the screen address', 28794: 'Add the left offset', 28795: 'Leave a blank row above the text', 28798: 'IY points at the margins for each line',
28802: 'DE points at the widths of the lines', 28805: 'Draw the bubble outline', 28808: 'B=number of lines in the top half (plus the middle line if odd)',
28811: None, 28812: None, 28815: None, 28816: None,
28817: 'C=pixel offset 0', 28819: None, 28820: 'Indent by the margin for this line', 28823: 'A=width of this line', 28824: 'Print as many words as fit', 28827: None,
28828: 'Next margin', 28830: 'Next width', 28831: 'Move down a row', 28834: 'Repeat for the top half',
28836: 'Step back to the middle line', 28837: None, 28839: 'Is there an odd middle line?', 28842: None, 28843: 'Jump if not', 28845: 'If so step back once more', 28846: None,
28848: 'B=number of lines in the bottom half', 28851: None, 28852: None, 28853: 'Jump if there are none',
28855: 'C=pixel offset 0', 28857: None, 28858: 'Indent by the margin for this line', 28861: 'A=width of this line', 28862: 'Print as many words as fit', 28865: None,
28866: 'Previous margin (the bottom half mirrors the top)', 28868: 'Previous width', 28869: 'Move down a row', 28872: 'Repeat for the bottom half',
28874: None, 28876: None, 28878: None,
28879: 'A=margin for this line', 28882: 'Add it to the column', 28883: None, 28884: None,
28885: 'Move down 32 bytes', 28886: None, 28888: None, 28889: 'Return unless this crossed into the next third of the screen', 28890: None, 28891: 'Move to the next third', 28893: None, 28894: None,
28895: 'Move up 32 bytes', 28896: None, 28898: None, 28899: 'Return unless this crossed into the previous third', 28900: None, 28901: 'Move to the previous third', 28903: None, 28904: None,
28905: None, 28907: None, 28908: None, 28909: None, 28910: 'Start one row above the text', 28913: 'B=number of lines in the top half', 28916: None, 28917: None, 28920: None, 28921: None,
28922: 'C=pixel offset 0', 28924: None, 28925: 'Indent by the margin', 28928: 'A=width of this line', 28929: 'Paint the white background for it', 28932: None,
28933: None, 28935: None, 28936: 'Move down a row', 28939: 'Repeat for the top half', 28941: None, 28942: 'Back to the widest line', 28943: None,
28945: 'Indent by the margin', 28948: None, 28949: 'Paint the blank row above the text (as wide as the line below it)', 28952: 'Is there an odd middle line?', 28955: None, 28956: None,
28958: None, 28959: None, 28961: None, 28962: 'Move down a row', 28965: None, 28966: None, 28969: None, 28970: 'Paint the middle row', 28973: None,
28974: 'B=number of lines in the bottom half', 28977: None, 28978: None, 28979: 'Jump if there are none',
28981: 'C=pixel offset 0', 28983: 'Move down a row', 28986: None, 28987: 'Indent by the margin', 28990: None, 28991: 'Paint the background for this line', 28994: None,
28995: 'Previous margin', 28997: 'Previous width', 28998: 'Repeat for the bottom half', 29000: None, 29001: None, 29002: None, 29003: None, 29005: None,
29006: None, 29007: None, 29008: 'Add 16 pixels of margin to the line width', 29010: 'B=pixels to paint', 29011: 'Start one cell to the left',
29012: 'Clear a cell and make it white', 29015: 'Next cell', 29016: None, 29017: '8 pixels done', 29019: None, 29020: 'Any more?', 29022: 'Jump back if so', 29024: None, 29025: None, 29026: None,
})

R[26940] = ('Print a character in the proportional font',
  ['Prints character A at pixel offset C within the cell at HL. The glyph is six pixels high and starts one pixel row down. Characters may straddle two cells, so each row is shifted into place by #R27021, which also clears the pixels behind the glyph. The dollar sign and the comma get a seventh row (a tail below the line). On exit C and L have been moved past the character plus one pixel of spacing.'],
  ['Input|A Character code', '|C Pixel offset (0-7) within the current cell', '|HL Display file address', 'Output|C Updated pixel offset', '|L Updated column'])
C.update({
26740: 'L=33 (v33: the rating number worked out by the script)', 26742: 'Load it into BCDE', 26745: 'A=low byte', 26746: 'Get the address of the rating word',
26749: 'Make it the default sub-message for the "You were ..." message', 26752: None,
26753: 'Rating 1: "lousy"', 26756: None, 26757: None, 26758: 'Rating 2: "real bad"', 26761: None, 26762: None, 26763: 'Rating 3: "terrible"', 26766: None, 26767: None,
26768: 'Rating 4: "ghastly"', 26771: None, 26772: None, 26773: 'Rating 5: "poor"', 26776: None, 26777: None, 26778: 'Rating 6: "so-so"', 26781: None, 26782: None,
26783: 'Rating 7: "fair"', 26786: None, 26787: None, 26788: 'Rating 8: "good"', 26791: None, 26792: None, 26793: 'Rating 9: "okay"', 26796: None, 26797: None,
26798: 'Rating 10: "great"', 26801: None, 26802: None, 26803: 'Rating 11: "swell"', 26806: None, 26807: None,
26808: 'Anything else (including 0): "terrific" (see #LINK(Bugs#terrific)(the bugs page))', 26811: None,
26812: 'Set the border colour for this layout', 26815: None, 26817: None, 26818: 'Pick up the address of the layout\'s picture', 26821: None,
26824: None, 26825: 'IY=picture data', 26827: 'Has the layout changed?', 26830: None, 26831: 'If so, draw the whole picture',
26834: 'Otherwise just wipe the speech bubbles: they are the cells with attribute 120', 26835: None, 26836: None, 26837: 'HL=display file', 26840: 'DE=attribute file',
26843: 'Reached the end of the attribute file?', 26844: None, 26846: 'Finish if so', 26848: 'Is this cell part of a bubble (bright white)?', 26849: None, 26851: 'Jump if not',
26853: None, 26854: 'Clear the 8 pixel rows of the cell', 26856: None, 26858: None, 26859: None, 26861: None,
26862: 'Next attribute', 26863: 'Next cell', 26864: 'Jump back unless a third of the screen is done', 26866: None, 26867: 'Move to the next third', 26869: None, 26870: None,
26872: None, 26873: None, 26874: None, 26875: None,
26898: None, 26899: 'BC=loop count (about one second)', 26902: 'Wait for a key or the timeout', 26905: None, 26906: None,
26907: None, 26908: 'Read every half-row of the keyboard', 26910: 'Keep the key bits', 26912: 'Is any key pressed?', 26914: 'Return (zero flag reset) if so',
26915: 'Count down', 26916: None, 26917: None, 26918: 'Keep waiting until BC is zero', 26920: 'Return with the zero flag set (timeout)',
26921: None, 26922: 'HL=A', 26923: None, 26925: 'DE=A', 26926: None, 26927: None, 26928: None, 26929: 'HL=8*A', 26930: None, 26931: 'HL=7*A',
26933: 'Add 26863 (the font minus 7*32)', 26936: None, 26937: None, 26938: None,
26940: 'Remember the character', 26943: None, 26944: None, 26945: None, 26946: None, 26947: 'Get the address of its glyph', 26950: 'DE=glyph',
26951: 'Restore the screen address', 26952: None, 26953: 'Start one pixel row down', 26954: 'A=width', 26955: 'Point at the first row', 26956: 'Save the width',
26957: 'Build a mask of width+1 zero bits...', 26958: None, 26959: None, 26961: None, 26963: None, 26965: '...and store it',
26968: 'Six rows', 26970: 'Print a row', 26973: None, 26974: 'Next pixel row', 26975: None,
26977: 'Was it a dollar sign?', 26980: None, 26982: 'Jump if not', 26984: 'Add the tail of the dollar sign below the line', 26986: None, 26989: None,
26991: 'A comma?', 26993: 'Jump if not', 26995: 'Add the tail of the comma below the line', 26997: None,
27000: 'A=width', 27001: None, 27002: None, 27003: None, 27004: 'Add the old pixel offset', 27005: '+1 pixel of spacing',
27006: 'Into the next cell?', 27008: 'Jump if not', 27010: None, 27012: 'Move to the next cell', 27013: None, 27015: 'C=new pixel offset', 27016: None, 27017: None,
27020: 'Pick up the pixel row', 27021: None, 27022: 'D=pixel row', 27023: 'E=0 (the overflow into the next cell)', 27025: None, 27026: 'A=pixel offset',
27027: 'BC=glyph mask', 27031: 'Is the offset 0?', 27032: 'Jump if so',
27034: 'Shift the row right one pixel...', 27036: None, 27038: '...and the mask, bringing in a 1', 27039: None, 27041: None, 27043: None, 27044: 'Repeat for each pixel of the offset',
27046: 'Clear the pixels behind the glyph in the first cell...', 27047: None, 27048: '...and draw the left part of the row', 27049: None,
27050: 'Next cell', 27051: 'Do the same for the second cell', 27052: None, 27053: None, 27054: None, 27055: 'Back to the first cell', 27056: None, 27057: None, 27058: None,
27060: None, 27061: None, 27062: '8 pixel rows', 27064: 'Clear one', 27066: None, 27067: None, 27068: None,
27070: 'Work out the attribute address from the display file address', 27071: None, 27072: None, 27073: None, 27074: None, 27075: None, 27077: None, 27079: None,
27080: 'Set the attribute', 27083: None, 27084: None, 27085: None, 27086: None,
})

# ---- ROM-font printing, yes/no, number input, line input (27724-28296)
C.update({
27724: None, 27725: None, 27726: None, 27727: 'HL=character code', 27728: None, 27730: None, 27731: None, 27732: 'HL=8*code',
27733: 'Add 15360 (the ROM character set minus 256)', 27736: None, 27737: 'DE=screen address', 27738: None, 27739: 'HL=screen, DE=glyph', 27740: '8 pixel rows',
27742: 'Copy a row', 27743: None, 27744: None, 27745: 'Next pixel row', 27746: None, 27748: None, 27749: None, 27750: None, 27751: 'Move one cell right', 27752: None,
27790: 'Read a line of input', 27793: 'Parse it as a number into v35', 27796: 'Jump unless it was invalid',
27798: 'Louey says "What wuz dat, Boss?..." (and the blunder count goes up)', 27802: None, 27805: 'Ask again',
27817: 'Jump if there was no decimal point', 27819: 'Louey complains about fractions (another blunder)', 27823: None, 27826: 'Ask again',
27835: 'Is the number negative?', 27837: 'Jump if not', 27839: 'Type 1: negative', 27841: 'Store the type in flag 8', 27844: None,
27845: 'Is it at least 2.56?', 27846: None, 27847: None, 27848: 'Jump if so', 27850: 'Is the low byte zero?', 27851: None, 27852: 'Jump if not',
27854: 'Type 2: zero', 27856: None, 27858: 'Is it exactly 0.01?', 27860: 'Type 3 if so', 27862: None, 27864: 'Type 4: anything else', 27866: None,
27869: 'Point HL at the input', 27872: 'Pick up the first character', 27873: None, 27874: 'Return (zero flag set: invalid) if the line is empty',
27875: 'A minus sign?', 27877: 'Jump if so', 27879: 'A plus sign?', 27881: 'Jump if so', 27883: 'A decimal point?', 27885: 'Jump if so', 27888: 'Is it a digit?',
27891: 'Return (zero flag set: invalid) if not', 27892: 'Next character', 27893: None, 27894: 'End of the line?', 27895: 'Jump if so: the entry is valid',
27897: 'A decimal point?', 27899: 'Jump if so', 27902: 'A digit?', 27905: 'Return (invalid) if not', 27906: None,
27908: 'Now convert the number', 27912: 'Clear the minus flag', 27913: None, 27916: 'Pick up the first character', 27919: 'A minus sign?', 27921: 'Jump if not',
27923: 'Set the minus flag', 27926: None, 27928: 'A plus sign?', 27930: 'Jump if not', 27932: 'Skip the sign', 27934: 'Run the VM script that sets v35 to 0', 27938: None,
27941: 'Next character', 27944: 'End of the line?', 27945: 'Jump if so', 27947: 'Run the VM script that multiplies v35 by 10', 27951: None,
27954: 'A=the digit', 27957: 'Convert it from ASCII', 27959: 'BCDE=digit', 27960: None, 27962: None, 27963: None, 27964: 'Store it in v33', 27966: None,
27969: 'Run the VM script that adds 100*v33 to v35', 27973: None, 27976: 'Next character', 27978: None,
27980: 'Load v35 into BCDE', 27982: None, 27985: 'Was there a minus sign?', 27988: None, 27989: 'Negate the number if so', 27992: 'Reset the zero flag: the entry was valid', 27994: None,
28017: 'Reset the zero flag...', 28019: '...and set the carry flag: a decimal point was found', 28020: None,
28021: 'Below "0"?', 28023: 'Jump if so', 28025: 'Below ":" (i.e. "0"-"9")?', 28027: 'Return with the carry flag set if so', 28028: 'Set the zero flag (and reset the carry flag): not a digit', 28029: None,
28030: 'Clear a cell and set its attribute', 28033: 'Next cell', 28034: None, 28036: None,
28037: 'Fill the input buffer with 20 spaces', 28040: None, 28043: None, 28046: None, 28048: None,
28050: 'Clear the answer bubble, line by line', 28053: None, 28055: None, 28058: None, 28061: None, 28063: None, 28066: None, 28069: None, 28071: None,
28074: None, 28077: None, 28079: None, 28082: None, 28085: None, 28087: None, 28090: None, 28093: None, 28095: None, 28098: None, 28101: None, 28103: None,
28106: None, 28109: None, 28111: None, 28114: 'HL=start of the answer line', 28117: 'C=pixel offset 0', 28119: 'DE=input buffer', 28122: 'B counts the characters typed',
28124: 'Wait for a key (flashing the cursor)', 28127: 'ENTER?', 28129: 'Finish if so', 28131: 'LEFT (CAPS SHIFT+5)?', 28133: 'Rub out if so', 28135: 'DELETE (CAPS SHIFT+0)?', 28137: 'Rub out if so',
28139: 'Ignore other control keys', 28141: None, 28143: 'Ignore graphics and keyword codes', 28145: None,
28147: 'Echo the character', 28150: 'Count it', 28151: 'Store it in the buffer', 28152: None, 28153: 'Has the line reached column 30?', 28154: None, 28156: None, 28158: 'Get another key if not',
28160: 'The line is full: only ENTER or rubbing out will do', 28163: None, 28165: None, 28167: None, 28169: None, 28171: None, 28173: None,
28175: 'Terminate the input with a zero byte', 28176: None, 28177: None,
28178: 'Anything to rub out?', 28179: None, 28180: 'Ignore the key if not', 28182: 'One character fewer', 28183: 'Back up in the buffer', 28184: None, 28185: None,
28186: 'Print two spaces over the cursor', 28188: None, 28191: None, 28194: None, 28195: None, 28196: None, 28197: 'Get the width of the character being rubbed out', 28198: None,
28201: None, 28202: None, 28203: '+1 pixel of spacing', 28204: 'Move the print position back by that many pixels', 28205: None, 28207: None, 28209: None,
28211: 'Back one cell', 28212: None, 28214: None, 28216: 'C=new pixel offset', 28217: 'Wait for the next key',
28221: 'Wait one frame and check for a key', 28224: None, 28225: None, 28226: None, 28227: 'Advance the flash counter (0-3)', 28230: None, 28231: None, 28233: None,
28236: 'Pick up the cursor character', 28239: 'Jump unless it is time to flash', 28241: 'Swap between "*" and a space', 28243: None, 28245: None, 28247: None, 28249: None,
28252: 'Print the cursor', 28255: None, 28257: None, 28260: None, 28261: None, 28262: None, 28263: 'Back for another frame if no key was pressed', 28265: None,
28266: None, 28268: None, 28269: None, 28270: 'Restore IY for the ROM interrupt routine', 28274: 'Let one interrupt happen (the ROM scans the keyboard)', 28275: None, 28276: None,
28277: 'Has a new key been pressed?', 28280: None, 28282: 'Jump if not', 28284: 'Acknowledge it', 28286: None, 28289: 'A=the key code', 28292: None, 28293: None, 28294: None, 28296: None,
})

# ---- VM comparison and fixed-point arithmetic (30342-31217)
C.update({
30342: 'BCDE=first variable', 30345: 'Fetch the number of the second variable', 30348: None, 30349: None, 30351: None, 30352: 'HL=4*variable number',
30353: None, 30354: 'Point IY at the second variable', 30357: None, 30358: None, 30359: None, 30360: None,
30362: 'Is the first value zero?', 30363: None, 30364: None, 30365: None, 30366: 'Jump if so',
30368: 'Do the signs differ?', 30371: None, 30372: None, 30374: 'Jump if so',
30376: 'Same sign: compare the high bytes', 30379: None, 30380: 'Return if they differ (carry set if the second is lower)',
30381: 'Compare the next bytes', 30384: None, 30385: None, 30386: None, 30389: None, 30390: None, 30391: 'Compare the low bytes', 30394: None, 30395: None,
30396: 'First value is zero: is the second negative?', 30400: 'Jump if not', 30402: 'Carry set: second < first', 30403: None,
30404: 'Set the zero flag if the second is also zero', 30407: None, 30410: None, 30413: None, 30416: 'Return (the carry flag is reset by OR)',
30417: 'Signs differ: is the first value negative?', 30419: 'Return (zero and carry reset: second > first) if so',
30420: 'Otherwise reset the zero flag...', 30422: '...and set the carry flag: second < first', 30423: None,
30424: 'BCDE=first operand', 30427: 'Switch to the second register set', 30428: "BC'DE'=second operand", 30431: None, 30432: None,
30433: "Load the operand into BC'DE'", 30436: 'Add', 30438: "Load the two operands into BCDE and BC'DE'",
30441: 'Add the low words...', 30442: None, 30443: None, 30444: None, 30445: None, 30446: None, 30448: None, 30449: '...and the high words with carry',
30451: None, 30452: None, 30453: 'BC=high word of the sum', 30454: 'DE=low word', 30455: None,
30456: "Load the operand into BC'DE'", 30459: 'Subtract', 30461: "Load the two operands into BCDE and BC'DE'",
30464: 'Subtract the low words...', 30465: None, 30466: None, 30467: None, 30468: None, 30469: None, 30471: None, 30472: '...and the high words with borrow',
30474: None, 30475: None, 30476: 'BC=high word of the difference', 30477: 'DE=low word', 30478: None,
30479: 'Load the operand', 30482: 'A=low byte', 30483: 'Replace it with a random number 0..A', 30486: None, 30487: None,
30488: 'Load the operand', 30491: 'Halve BCDE', 30493: None, 30495: None, 30497: None, 30499: None,
30508: 'Load the operand', 30511: 'Store the argument n', 30515: None, 30519: 'First estimate: x=n/2',
30522: 'Store the estimate x', 30526: None, 30530: None, 30531: 'BCDE=n', 30535: None, 30539: "BCDE=n/x (BC'DE' holds x)", 30542: None,
30543: 'BCDE=x', 30547: None, 30551: 'Add n/x', 30554: 'Halve: the new estimate is (x+n/x)/2',
30557: 'Compare it with the previous estimate', 30560: None, 30561: None, 30562: 'Try again if different', 30564: None, 30565: None, 30566: None, 30567: None,
30569: None, 30570: None, 30571: None, 30572: None, 30574: None, 30575: None, 30576: None,
30577: 'Try again if different (for some arguments the estimates alternate for ever)', 30579: 'Return with the square root in BCDE',
30580: 'Make the operands positive, noting the sign of the result (from BCDE and, wrongly, BC\'DE\')', 30583: 'Copy BCDE into the 64-bit dividend', 30587: None,
30591: None, 30594: None, 30597: None, 30600: 'Divide by 100', 30603: None, 30606: None, 30609: 'Multiply by 100 (dropping the fractional part)', 30612: None, 30615: None,
30618: 'BCDE=result', 30622: None, 30626: 'Should it be negative?', 30629: None, 30630: 'Return if not', 30631: 'Negate it',
30634: 'Negate the low word...', 30637: None, 30638: None, 30640: None, 30641: '...and the high word', 30644: None, 30646: None, 30647: None, 30648: None,
30649: "Load the operand into BC'DE'", 30652: 'Multiply', 30654: "Load the two operands into BCDE and BC'DE'",
30657: 'Make both operands positive, noting the sign of the result', 30660: None, 30661: "Store BC'DE' as the multiplier", 30665: None, 30669: None,
30670: 'Clear the top half of the multiplier', 30673: None, 30676: None, 30679: '64-bit product=BCDE*multiplier', 30682: 'Divide by 100 (the fixed-point scale)', 30685: None, 30688: None,
30691: 'BCDE=result', 30695: None, 30699: 'Should it be negative?', 30702: None, 30703: 'Return if not', 30704: 'Negate it',
30707: "Load the operand into BC'DE'", 30710: 'Divide', 30712: "Load the two operands into BCDE and BC'DE'",
30715: 'Make both operands positive, noting the sign of the result', 30718: 'Store BCDE (the dividend) as the multiplier', 30722: None, 30726: None, 30729: None, 30732: None,
30735: None, 30736: 'Is the divisor zero?', 30737: None, 30738: None, 30739: None, 30740: 'Jump if not', 30742: None, 30743: 'Return 0 for division by zero', 30746: None, 30749: None,
30750: 'Save the divisor', 30751: None, 30752: 'BCDE=100', 30755: None, 30758: '64-bit product=dividend*100', 30761: 'Restore the divisor', 30762: None, 30763: 'Divide the product by it',
30766: 'BCDE=quotient', 30770: None, 30774: 'Should it be negative?', 30777: None, 30778: 'Return if not', 30779: 'Negate it',
30782: 'Clear the 64-bit product', 30785: None, 30788: None, 30791: None, 30794: None,
30797: 'Any bits of BCDE left?', 30798: None, 30799: None, 30800: None, 30801: 'Return if not', 30802: 'Is the lowest bit set?', 30804: 'Jump if not',
30806: 'Add the multiplier to the product (64 bits)', 30807: None, 30810: None, 30814: None, 30815: None, 30818: None, 30821: None, 30825: None, 30827: None,
30830: None, 30833: None, 30837: None, 30839: None, 30842: None, 30845: None, 30849: None, 30851: None, 30854: None,
30855: 'Double the multiplier', 30858: None, 30861: 'Shift BCDE right one bit', 30863: None, 30865: None, 30867: None, 30869: 'Next bit',
30871: 'Shift the low byte left', 30873: '7 more bytes', 30875: None, 30876: 'Shift the next byte left, bringing in the carry', 30878: None, 30879: None, 30881: None,
30882: 'Shift the high byte right (keeping the sign)', 30884: '7 more bytes', 30886: None, 30887: 'Shift the next byte right, bringing in the carry', 30889: None, 30890: None, 30892: None,
30893: 'Subtract the divisor from the dividend, 16 bits at a time', 30896: None, 30900: None, 30901: None, 30903: None, 30906: None, 30909: None, 30913: None, 30915: None,
30918: None, 30921: None, 30925: None, 30927: None, 30930: None, 30933: None, 30937: None, 30939: None, 30942: 'Set the zero flag if the result is not negative', 30944: None,
30945: 'Add the divisor to the dividend, 16 bits at a time', 30948: None, 30952: None, 30953: None, 30956: None, 30959: None, 30963: None, 30965: None,
30968: None, 30971: None, 30975: None, 30977: None, 30980: None, 30983: None, 30987: None, 30989: None, 30992: None,
30993: 'Clear the sign flag', 30994: None, 30997: 'Is BCDE negative?', 30999: 'Jump if not', 31001: 'Make it positive', 31004: 'Flip the sign flag', 31007: None, 31009: None,
31012: "Now look at BC'DE'", 31013: 'Is it negative?', 31015: 'Jump if not', 31017: 'Make it positive', 31020: 'Flip the sign flag', 31023: None, 31025: None, 31028: None, 31029: None,
31055: 'Clear the quotient', 31058: None, 31061: None, 31064: None, 31067: None, 31070: 'Store BCDE as the divisor (64 bits)', 31074: None, 31078: None, 31081: None,
31084: 'Is the dividend smaller than the divisor?', 31087: None, 31088: 'Undo the trial subtraction', 31091: None, 31092: 'Return with a quotient of 0 if so',
31093: 'Find the highest non-zero byte of the dividend', 31096: None, 31098: None, 31099: None, 31100: None, 31102: None, 31103: None, 31105: None,
31106: 'Find its highest set bit', 31108: None, 31109: None, 31110: None, 31112: None, 31114: None,
31116: 'Point DE at the corresponding byte of the divisor', 31119: None, 31120: None, 31121: 'B counts the shifts needed',
31123: 'Shift the divisor left until its top bit lines up with the dividend\'s', 31124: None, 31125: None, 31127: None, 31128: None, 31131: None, 31134: None,
31136: 'Save the shift count', 31137: 'Shift the quotient left', 31140: None, 31143: 'Subtract the divisor', 31146: 'Jump if the result was not negative',
31148: 'Otherwise add it back', 31151: None, 31153: 'Set the lowest bit of the quotient', 31156: None, 31158: None,
31161: 'Shift the dividend left', 31164: None, 31167: 'Repeat for each bit position', 31169: 'Restore the shift count', 31170: 'Shift the remainder back', 31173: None, 31176: None, 31178: None,
31179: 'HL=4*variable number', 31181: None, 31182: None, 31183: None, 31184: 'Point HL at the variable', 31187: None, 31188: None,
31189: 'Store BCDE (low byte first)', 31190: None, 31191: None, 31192: None, 31193: None, 31194: None, 31195: None, 31196: None,
31197: 'Fetch the variable number from the VM stream', 31200: None, 31201: 'HL=4*variable number', 31203: None, 31204: None, 31205: 'Point HL at the variable', 31208: None,
31209: 'Load it into BCDE (low byte first)', 31210: None, 31211: None, 31212: None, 31213: None, 31214: None, 31215: None, 31216: None, 31217: None,
})

R[31917] = ('Draw a line segment',
  ['Draws a line of L pixels from the pen position (D,E). Bit 0 of C chooses a mostly horizontal (0) or mostly vertical (1) line; bit 1 means down rather than up and bit 2 means left rather than right. B is the number of pixels drawn along the main direction before each step in the other direction, so it sets the slope. Each pixel also sets the ink of its attribute. Drawing stops early at the edge of the picture area, and the pen is left at the end of the line.'],
  ['Input|B Pixels per minor step', '|C Direction flags', '|D Pen x', '|E Pen y', '|L Length', 'Output|D,E New pen position'])
C.update({
31218: None, 31219: 'Clear the display file', 31222: None, 31225: None, 31228: None, 31230: None,
31232: 'Set every attribute to paper 7, ink 0', 31235: None, 31238: None, 31241: None, 31243: None, 31245: None, 31246: None,
31247: None, 31248: None, 31249: None, 31250: 'Clear the screen', 31253: 'Pen x=127', 31255: 'Pen y=63', 31257: 'Default slope', 31259: 'Default direction', 31261: 'Default length',
31263: 'Pick up the next command', 31266: 'Is it 0 (end of picture)?', 31267: 'Finish if so', 31270: 'Point at its operands',
31272: 'Command 8 (move the pen)?', 31274: 'Jump if not', 31276: 'D=new x', 31279: None, 31281: 'E=new y', 31284: None, 31286: 'Next command',
31288: 'Command 16 (bitmap block)?', 31290: 'Jump if not', 31292: 'HL=screen address', 31295: None, 31298: 'B=width in bytes', 31301: 'C=height in rows',
31304: None, 31306: None, 31308: None, 31310: 'Point at the bitmap data', 31312: 'Save the start of the row', 31313: None,
31314: 'Put a byte on the screen', 31317: 'Next column', 31318: 'Next byte of data', 31320: 'Repeat for the width of the block', 31322: None, 31323: 'Back to the start of the row',
31324: 'Move down a pixel row (or an attribute row)', 31327: None, 31328: 'Repeat for each row', 31330: 'Next command',
31332: 'Bit 7 set (line)?', 31334: 'Jump if not', 31336: None, 31337: 'C=direction flags (bits 0-2)', 31339: None, 31340: None, 31341: None,
31342: 'B=bits 3-6 (high bits of the slope)...', 31344: None, 31345: 'Pick up the second byte', 31348: 'Bits 0-5: length-1', 31350: None, 31351: 'L=length',
31352: None, 31355: None, 31357: '...plus bits 6-7 of the second byte', 31358: None, 31359: None, 31361: None, 31362: None, 31363: 'B=slope', 31364: 'Draw the line', 31367: 'Next command',
31369: 'Bit 6 set (flood fill)?', 31371: 'Jump if not', 31373: 'A=the ink colour', 31375: None, 31376: 'D=x of the seed point', 31379: None, 31381: 'E=y', 31384: None,
31386: 'Fill the area', 31389: None, 31390: 'Next command',
31393: 'Bit 5 set (paint attributes)?', 31395: 'Ignore the command if not', 31398: 'Bits 0-2: paper colour', 31400: None, 31401: None, 31402: 'C=paper colour*8',
31403: None, 31404: None, 31405: None, 31406: None, 31407: 'HL=attribute address', 31410: None, 31412: None, 31415: None,
31417: 'Pick up the next run', 31420: None, 31422: 'End of the runs?', 31424: 'Finish if so', 31426: None, 31427: 'E=direction (0 up, 1 right, 2 down, 3 left)', 31429: None,
31430: 'B=length of the run (bits 2-7, plus 1)', 31431: None, 31432: None, 31433: None, 31435: None, 31436: None,
31437: 'Take the ink of this cell', 31438: None, 31440: None, 31441: None, 31442: None, 31443: 'Is it the same as the new paper?', 31444: 'Jump if not',
31446: 'If so use paper 7 instead, so the ink stays visible', 31448: 'Move the ink back to bits 0-2', 31449: None, 31450: None, 31451: 'Combine it with the paper', 31452: 'Set the attribute',
31453: 'Move in the run\'s direction', 31454: None, 31455: 'Up', 31458: None, 31459: 'Right', 31462: None, 31463: 'Down', 31466: None, 31467: 'Left',
31470: 'Repeat for the length of the run', 31472: 'Next run', 31474: None, 31475: None, 31476: None, 31477: 'Next command',
31480: None, 31481: None, 31482: None, 31483: None,
31484: 'Is HL in the attribute file?', 31485: None, 31487: 'Jump if not', 31489: 'Move down one attribute row', 31490: None, 31492: None, 31493: None, 31494: None, 31495: None,
31496: 'Move down one pixel row', 31497: None, 31498: None, 31500: 'Return unless that crossed a character row', 31501: None, 31502: None, 31504: None, 31505: None, 31506: None, 31507: None, 31509: None, 31510: None,
31511: 'Is HL in the attribute file?', 31512: None, 31514: 'Pick up the data byte', 31517: 'Jump if so: store it as it is', 31519: 'Otherwise merge it with the picture', 31520: None, 31521: None,
31525: 'Store the attribute bits for the filled cells', 31528: None, 31529: None, 31530: None, 31531: None, 31534: 'Push a zero marker (the end of the stack of seeds)', 31535: None, 31538: None,
31539: 'Get the address and mask of the seed point', 31542: None,
31543: 'Is this pixel set?', 31544: None, 31545: 'Jump if so: the left edge has been reached', 31547: 'Otherwise move left', 31550: 'And keep going', 31552: None,
31555: 'Plot the edge pixel', 31558: 'Move right', 31561: 'Clear the up/down flags', 31564: None,
31568: 'Reached a full byte boundary?', 31569: None, 31571: None, 31573: 'Is the whole byte empty?', 31574: None, 31575: 'Jump if so (fill it in one go)',
31577: None, 31578: 'Look at the pixel above', 31581: None, 31583: 'Jump if at the top', 31585: None, 31586: None, 31587: None, 31589: 'Jump if it is set',
31591: 'Was the pixel above already being filled?', 31594: None, 31595: 'Jump if so', 31597: 'Otherwise push it as a new seed', 31598: None, 31599: None, 31600: None,
31601: None, 31604: None, 31605: None, 31606: 'Look at the pixel below', 31609: None, 31611: 'Jump if at the bottom', 31613: None, 31614: None, 31615: None, 31617: 'Jump if it is set',
31619: 'Was the pixel below already being filled?', 31622: None, 31623: 'Jump if so', 31625: 'Otherwise push it as a new seed', 31626: None, 31627: None, 31628: None, 31630: None,
31633: None, 31634: 'Plot this pixel', 31637: 'Move right', 31640: None,
31643: 'Fill a whole byte at once: check the bytes above and below', 31646: None, 31647: None, 31650: None, 31651: None, 31652: None, 31654: None, 31656: None, 31658: None, 31659: None, 31661: None,
31662: None, 31663: None, 31666: None, 31667: None, 31668: None, 31670: None, 31672: None, 31674: None, 31675: None, 31677: None,
31678: None, 31681: None, 31682: None, 31683: None, 31685: None, 31686: None, 31688: None, 31691: None, 31692: None, 31695: None, 31696: None,
31697: None, 31700: None, 31703: None, 31704: None, 31705: None, 31707: None, 31708: None, 31710: None, 31713: None, 31714: None, 31717: None, 31718: None,
31719: 'Fill the whole byte', 31721: 'Set its ink', 31724: 'Next byte', 31725: 'Reached the right edge of the screen?', 31726: None, 31728: None,
31730: None, 31731: None, 31732: None, 31735: 'Plot the pixel', 31738: 'Pick up the next seed', 31739: None, 31740: 'Is it the zero marker?', 31741: None, 31743: 'Fill from it if not',
31746: 'A=0', 31748: None, 31751: None, 31752: None, 31753: None, 31754: None,
31755: None, 31756: None, 31757: 'Move up one attribute row', 31760: None, 31761: None, 31763: 'Above the top?', 31764: None, 31766: None, 31768: 'Undo the move if so', 31769: None, 31770: None, 31771: None,
31772: None, 31773: None, 31774: 'Move down one attribute row', 31777: None, 31778: 'Into the status lines (row 22)?', 31779: None, 31781: None, 31783: None, 31784: None, 31786: None, 31788: None, 31790: None, 31791: 'Undo the move if so', 31793: None, 31794: None, 31795: None,
31796: None, 31797: 'Move left one cell', 31798: 'Before the start of the attribute file?', 31799: None, 31801: None, 31803: 'Undo the move if so', 31804: None, 31805: None,
31806: None, 31807: 'Move right one cell', 31808: 'Past the end of the picture area?', 31809: None, 31811: None, 31813: None, 31814: None, 31816: None, 31818: None, 31820: 'Undo the move if so', 31821: None, 31822: None,
31823: 'Move up one pixel row', 31824: None, 31825: None, 31827: 'Did that cross a character row?', 31829: 'Return (zero flag reset) if not', 31830: None, 31831: None, 31833: None,
31834: None, 31836: None, 31837: None, 31839: None, 31840: 'Above the top of the screen?', 31841: None, 31843: 'Return (zero flag reset) if not', 31844: 'Undo the move', 31845: None, 31846: None, 31848: None, 31849: 'Set the zero flag', 31850: None,
31851: 'Move down one pixel row', 31852: None, 31853: None, 31855: 'Return (zero flag reset) unless that crossed a character row', 31856: None, 31857: None, 31859: None,
31860: None, 31862: None, 31863: None, 31865: None, 31866: 'Reached row 160 (the bottom of the picture area)?', 31867: None, 31869: None, 31870: None, 31871: None, 31873: None, 31875: 'Return (zero flag reset) if not',
31876: 'Undo the move', 31877: None, 31878: None, 31880: None, 31881: None, 31882: None, 31884: None, 31885: 'Set the zero flag', 31886: None,
31887: 'Move the mask right one pixel', 31889: 'Return unless it wrapped round', 31890: 'Next cell', 31891: 'At the right edge?', 31892: None, 31894: 'Return (zero flag reset) if not',
31895: 'Undo the move', 31897: None, 31898: 'Set the zero flag', 31899: None,
31900: 'Move the mask left one pixel', 31902: 'Return unless it wrapped round', 31903: 'Previous cell', 31904: 'Wrapped round the left edge?', 31905: None, 31907: None, 31909: 'Return (zero flag reset) if not',
31910: 'Undo the move', 31912: None, 31913: 'Set the zero flag', 31914: None,
31917: None, 31918: None, 31919: "A'=length", 31920: None, 31921: 'Get the screen address and mask of the pen', 31924: 'D=mask', 31925: None, 31926: None, 31927: None,
31928: 'Mostly vertical?', 31930: 'Jump if so',
31932: None, 31933: 'Plot the pixel', 31936: 'Moving left?', 31938: 'Jump if not', 31940: 'Move left', 31943: 'Stop at the edge', 31945: None, 31947: 'Move right', 31950: 'Stop at the edge',
31952: 'Time for a vertical step?', 31953: 'Jump if not', 31955: 'Down?', 31957: None, 31959: 'Move down', 31962: 'Stop at the edge', 31964: None, 31966: 'Move up', 31969: 'Stop at the edge',
31971: 'Reset the step counter', 31972: None, 31973: None, 31974: 'Count the pixels', 31975: 'Repeat for the length of the line',
31977: 'Work out the new pen position', 31980: None, 31981: None, 31982: None,
31983: None, 31984: 'Plot the pixel', 31987: 'Down?', 31989: None, 31991: 'Move down', 31994: 'Stop at the edge', 31996: None, 31998: 'Move up', 32001: 'Stop at the edge',
32003: 'Time for a horizontal step?', 32004: 'Jump if not', 32006: 'Left?', 32008: None, 32010: 'Move left', 32013: 'Stop at the edge', 32015: None, 32017: 'Move right', 32020: 'Stop at the edge',
32022: 'Reset the step counter', 32023: None, 32024: None, 32025: 'Count the pixels', 32026: 'Repeat for the length of the line',
32028: 'Work out the new pen position', 32031: None, 32032: None, 32033: None,
32034: None, 32035: None, 32036: None, 32037: 'Set the ink of the cell', 32040: None, 32041: 'Set the pixel', 32042: None, 32043: None, 32044: None,
32045: None, 32046: 'Work out the attribute address', 32047: None, 32049: None, 32050: None, 32051: None, 32052: None, 32054: None,
32055: 'Clear the old ink', 32056: None, 32058: None, 32059: 'Put in the new one', 32062: None, 32063: None, 32064: None, 32065: None,
32066: None, 32067: 'C=x', 32068: 'B=175-y (the ROM counts from the bottom)', 32070: None, 32071: 'Use the ROM\'s PIXEL-ADD (skipping its first instructions)', 32074: 'A=bit position', 32075: None,
32076: 'Turn it into a mask', 32078: None, 32080: None, 32082: None, 32083: None,
32084: 'Turn the mask back into a bit position', 32086: None, 32087: None, 32089: None, 32091: None, 32092: 'x=8*column+bit', 32093: None, 32095: None, 32096: None, 32097: None, 32098: None, 32099: None,
32100: 'y=row within the character...', 32101: None, 32103: None, 32104: '...plus 8*character row...', 32105: None, 32107: None, 32108: None, 32109: None, 32110: None,
32111: '...plus 64*third', 32112: None, 32114: None, 32115: None, 32116: None, 32117: None, 32118: None, 32119: 'Convert to the ROM\'s coordinates', 32121: None, 32122: None, 32123: None,
})

# ---- compressed pictures and the theme tune (32126-33050)
C.update({
32126: None, 32127: 'IY=picture header', 32129: 'Clear the screen', 32132: 'The bit-stream starts after the 9-byte header', 32135: None, 32136: 'Set the bit-stream pointer',
32139: 'Start at bit 0', 32140: None, 32143: 'Start at (0,0)', 32146: 'Draw the strokes...', 32149: '...until the end of the point list',
32151: 'HL=offset of the list of fill points (header bytes 3-4)', 32154: None, 32157: None, 32159: None, 32160: 'Add the address of the header', 32161: 'Store the end address',
32164: 'HL=offset of the point list (header bytes 0-1)', 32167: None, 32170: None, 32171: 'Is header byte 2 non-zero?', 32174: None, 32175: None, 32177: 'Skip a padding byte if so',
32178: None, 32179: 'IY=list of fill seed points',
32181: 'D=x', 32184: 'E=175-y', 32186: None, 32189: None, 32190: None, 32192: 'Next seed point', 32194: 'Fill with ink 0 on paper 7', 32196: None,
32199: 'Reached the end of the seed points?', 32201: None, 32202: None, 32206: None, 32207: None, 32209: 'Jump back if not',
32211: 'DE=run-length attribute data', 32215: 'First pass over the attribute file: paper colours',
32218: 'Reached the end of the attribute file?', 32219: None, 32221: 'Jump if so', 32223: 'Bits 0-4: run length-1', 32224: None, 32226: None, 32227: None,
32228: 'Bits 5-7: paper colour', 32229: None, 32230: None, 32232: None, 32233: None, 32234: None, 32235: 'Set the paper for the run', 32236: None, 32237: None, 32239: None,
32241: 'Second pass: ink and bright', 32244: 'Reached the end of the attribute file?', 32245: None, 32247: 'Jump if so', 32249: 'Bits 0-4: run length-1', 32250: None, 32252: None, 32253: None,
32254: 'Bits 5-7: ink', 32255: None, 32256: None, 32258: None, 32259: None, 32260: None, 32261: 'Add the ink to each cell in the run', 32262: None, 32263: None, 32264: None, 32265: None, 32267: None,
32269: 'Third pass: bright and flash', 32272: 'Reached the end of the attribute file?', 32273: None, 32275: 'Return if so', 32276: 'Bits 0-5: run length-1', 32277: None, 32279: None, 32280: None,
32281: 'Bits 6-7: bright and flash', 32282: None, 32283: None, 32285: None, 32286: 'Add them to each cell in the run', 32287: None, 32288: None, 32289: None, 32290: None, 32292: None,
32294: 'Reached the end of the point list?', 32297: None, 32299: None, 32300: None, 32301: None, 32303: None, 32306: None, 32309: None, 32310: None, 32312: 'Jump if not',
32314: 'Check the bit position too', 32317: None, 32320: 'Return with the zero flag set at the end',
32321: 'Read one bit: 1 = start a new stroke, 0 = continue the current one', 32323: None, 32326: None, 32327: 'Jump to continue the stroke',
32329: 'Read the starting point', 32332: 'Plot it', 32335: None, 32336: None, 32337: 'Reset the zero flag: more to come', 32339: None,
32340: 'Remember the start of the line', 32344: 'Get its screen address', 32347: None, 32348: None, 32349: None, 32353: 'Read the next point', 32356: None,
32357: 'Draw a line to it', 32360: None, 32361: None, 32362: 'Reset the zero flag: more to come', 32364: None,
32365: 'Read one bit: absolute or relative coordinates?', 32367: None, 32370: None, 32371: None, 32373: 'Read x', 32376: None, 32377: 'Read y', 32380: None, 32381: None,
32382: 'Read one bit: short or long deltas?', 32384: None, 32387: None, 32388: None, 32390: 'Read a long x delta', 32393: None, 32394: None, 32395: 'Read a long y delta', 32398: None, 32399: None,
32539: None, 32540: None, 32541: 'Pick up the next two bytes of the bit-stream', 32544: None, 32545: None, 32546: None, 32547: None, 32548: 'Shift them left by the bit position',
32551: None, 32552: None, 32553: None, 32555: None, 32556: None, 32558: 'D=number of bits wanted', 32559: None, 32560: 'Build a mask of D bits', 32562: None, 32563: None, 32565: None, 32566: None,
32568: None, 32569: 'Extract the bits', 32570: None, 32571: 'Advance the bit position by D', 32574: None, 32575: None, 32578: None, 32580: None, 32582: None, 32584: 'Moving on a byte for each 8 bits', 32585: None,
32587: None, 32590: None, 32593: None, 32594: None, 32595: 'Return with the bits right-aligned in A',
32596: None, 32597: 'B=y', 32598: 'Use the ROM\'s PIXEL-ADD', 32601: None, 32602: None, 32603: 'Turn the bit position into a mask', 32605: None, 32606: None, 32608: None, 32609: None,
32785: 'Save the stack pointer', 32789: 'Use a stack up at 53792', 32792: 'Is the tune wanted?', 32794: 'Play it if so', 32796: 'Restore the stack pointer', 32800: None,
32803: None, 32805: 'Point IX at the list of tune fragments', 32809: 'Pick up the next fragment address', 32812: None, 32815: 'End of the list?', 32816: None, 32817: 'Finish if so',
32819: 'Play the fragment', 32822: None, 32824: None, 32826: None, 32828: None, 32830: None,
32866: 'Stop if a key is pressed', 32867: None, 32869: None, 32871: None, 32873: None, 32875: 'D=pitch', 32876: 'A pitch of 0 ends the fragment', 32877: None, 32878: None,
32881: None, 32882: 'E=duration', 32883: None, 32884: 'C=flags', 32885: None, 32886: 'B=repeat count', 32887: None,
32888: 'Default border/speaker value', 32890: 'Modify the OUT value at 33000', 32893: 'Bits 4-7 of the flags...', 32894: None, 32895: None, 32896: None, 32897: None, 32898: None, 32900: None,
32902: '...override it if non-zero', 32905: None, 32906: 'Modify the delay at 32930', 32909: 'C=pitch slide (bits 0-3)', 32910: None, 32912: None, 32913: None, 32914: None,
32917: None, 32918: 'Short pause between repeats', 32920: None, 32922: None, 32925: None, 32926: None, 32927: None, 32928: None, 32929: 'Delay (modified above)', 32931: None, 32932: None, 32933: None,
32934: 'Play the note', 32937: None, 32939: None, 32941: None, 32942: 'Slide the pitch', 32943: None, 32944: None, 32945: None, 32946: 'Up or down?', 32948: None,
32951: None, 32952: 'Stop if the pitch wrapped round', 32955: None, 32958: None, 32959: 'Stop if the pitch wrapped round', 32962: None,
32965: 'Shorten the duration', 32966: None, 32967: None, 32968: 'A=refresh register (adds a little noise)', 32970: 'Repeat', 32972: None, 32973: 'Next note',
32976: None, 32977: None, 32978: None, 32979: None,
32982: None, 32983: None, 32986: None, 32988: None, 32990: None, 32991: 'Toggle the speaker', 32994: None,
32995: None, 32997: None, 32999: 'A=speaker bit (this operand is modified by 32890)', 33001: 'Pad the timing', 33004: None, 33007: 'Speaker on', 33009: None, 33010: None, 33012: None, 33013: 'D=pitch',
33014: 'Delay for half a cycle', 33015: None, 33018: None, 33020: None, 33022: 'Speaker off', 33024: 'Delay for the other half', 33025: None, 33028: None, 33030: None, 33031: None,
33032: None, 33033: 'Timing padding', 33037: None, 33038: None, 33043: None, 33044: None, 33049: None, 33050: None,
})

import sys as _sys
import notes_shoot_fix as _ns
DATA_SHOOT = _ns.apply(_sys.modules[__name__])
import notes_anim_fix as _na
_na.apply(_sys.modules[__name__], __import__('os').path.join(__import__('os').path.dirname(__file__), '..', 'mugsy.skool'))
ROUTINE_NAMES = {a: v[0][0].lower() + v[0][1:] for a, v in R.items()}
ROUTINE_NAMES.update({a: v for a, v in EXTRA.items()})

import notes_misc_fix as _nm
_nm.apply(_sys.modules[__name__])
