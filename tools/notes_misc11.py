TXT = """
29929|Keep only the page number (low 4 bits of D)...
29931|...and combine it with the offset in E: zero means no word at all
29933|Save HL...
29934|...BC...
29935|...and DE
29937|A=the type and page byte
29940|D=page, so DE=256*page+offset
29944|HL=the address of the word's text
29945|DE=where the next character goes in the text buffer
29955|Step on to the second letter
29956|Keep the low 5 bits (1-26 = A-Z)
29962|Look at the type nibble only
29964|Is it type 7 (capitalised word)?
29970|A=the first letter, upper or lower case
29977|Keep the low 5 bits of the next letter
29989|Step on to the next byte
29993|Is this the second letter?
29995|Yes: its end bit is ignored, so carry on
30002|Step back two bytes to the second letter...
30003|...and pick it up
30004|Step forward again...
30005|...to the byte after the third letter
30006|Did the second letter have its end bit set?
30010|Restore DE...
30011|...BC...
30012|...and HL
30013|Done: the word is in the text buffer
28760|Save IX...
28762|...and IY
28774|A=number of lines again
28777|Remember the number of lines in each half
28780|B=lines in each half
28784|Add the odd-line flag: the index of the middle line
28785|C=index of the middle line
28786|BC=index, to look up the left offset
28791|HL=address of the offset for that line
28792|C=the left offset of the bubble
28811|B=the odd-line flag...
28812|...plus the lines in the top half...
28815|...gives the rows above the middle line...
28816|...B=row counter
28819|Keep the screen position of this row
28827|Back to the start of the row
28837|Back to the middle line's margin entry
28842|Test for an odd middle line
28846|...and its margin entry
28851|B=number of lines in the bottom half
28852|Test for none
28857|Keep the screen position of this row
28865|Back to the start of the row
28874|Restore IY...
28876|...and IX
28878|Done: the bubble and its text are drawn
"""
