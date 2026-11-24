TXT = """
24596|Run the greeting script
24605|Count down: 1 (quit) becomes 0
24617|Remember that no layout is current
24622|A=a random number from 0 to 100
24642|Run the year's script
24648|Test the game status flag
24651|Return: the game is over
26752|Done: HL points at the rating word
26811|Done: HL points at the rating word
26876|Save AF...
26877|...and BC
26879|Select every keyboard half-row (high byte of the port = 0)
26895|Restore BC...
26896|...and AF
26897|Done: Z set if the time ran out, NZ if a key was pressed
26898|Save BC
26905|Restore BC
26906|Done
26907|A=0: select every keyboard half-row
26916|Is BC zero? Test B...
26917|...together with C
26921|Save DE
26923|HL=the character code
26926|DE=the character code
26927|HL=2*code
26928|HL=4*code
26930|Clear the carry flag
26936|HL=address of the glyph
26937|Restore DE
26938|Done
26980|Is it a dollar sign (36)?
27002|Restore DE
27003|Restore BC
27021|Save DE
27025|Save BC
27056|Restore BC
27057|Restore DE
27060|Save the cell address
27724|Save DE (the screen address)
27749|Restore BC
27750|Restore DE
27844|Done
27873|Test the first character
27893|A=the next character
27913|Store it: no minus sign yet
27960|D=0
27962|B=0
27963|C=0: BCDE=the digit
27988|Test the minus-sign flag
27994|Done: Z set if the entry was invalid, NZ if it was valid
28020|Done: NZ and carry set means a decimal point
28029|Done: Z means not a digit
28034|Repeat for the whole row of cells
28036|Done
28053|Eight cells in the row
28154|Keep the column number
28156|Has it reached column 30 (the right-hand end of the bubble)?
28184|Save BC...
28185|...and HL
28275|Wait for the next interrupt
28280|Is the ROM's new-key flag (bit 5 of FLAGS) set?
"""
