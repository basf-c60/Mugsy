TXT = """
27725|Save BC...
27726|...and HL
27728|HL=character code
27730|HL=2*code
27731|HL=4*code
27736|HL=address of the glyph in the ROM font
27738|Keep the screen address
27743|Store the glyph row on the screen
27744|Next glyph row
27746|Repeat for all 8 rows
27748|HL=screen address
27749|Restore BC
27750|Restore DE
27752|Done: the character is on screen and HL has moved right
27025|Save BC
27036|The bits that fall off go into E
27039|Shift a 1 into the mask (B)...
27041|...and on into C
27043|One fewer shift to go
27047|Keep the background pixels outside the glyph
27049|Store the combined byte
27052|Keep the background pixels in the second cell
27053|Add the overflow from the shifted row
27054|Store it
27056|Restore BC
27057|Restore DE
27058|Done
29643|Switch to the alternate registers...
29644|...HL'=high word of the number...
29645|...and back again
29648|Clear the leading-zero flag
29654|DE=low word of the divisor 1,000,000,000
29663|DE=low word of 100,000,000
29672|DE=low word of 10,000,000
29681|DE=low word of 1,000,000
29690|DE=low word of 100,000
29699|DE=10,000
29708|DE=1,000
29716|Set the leading-zero flag
29722|DE=100
29729|Combine with H to test the fraction
29739|DE=10
29751|Done
30722|Store the top word of the dividend
30726|HL=0...
30729|...clear the upper half...
30732|...of the 64-bit multiplier
30735|Switch to BC'DE', the divisor
30737|Combine C...
30738|...D...
30739|...E: the divisor is zero if all clear
30742|Switch back to the main registers
30746|DE=0
30749|Done: division by zero gives zero
30751|Save the divisor's low word
30755|BCDE=100
30762|Restore the divisor's high word
30770|BC=the high word of the quotient
30777|Test the result sign flag
"""
