TXT = """
28301|Run it: the script's own END returns to the caller
28652|Save HL...
28653|...and DE
28656|HL=IY, the layout being asked for
28661|Clear the carry flag
28666|Restore DE...
28667|...and HL
28670|Done: A=1 and NZ if the layout is different
28713|Add the character's width to the total
28724|Restore HL
28726|Restore BC
28727|Done: A=the width of the word in pixels
28883|L=the indented column
28884|Done
28886|Add 32 to move down one pixel row...
28888|L=the new low byte
28890|A=H
28893|H=the next third
28894|Done
28896|Subtract 32 to move up one pixel row...
28898|L=the new low byte
28900|A=H
28903|H=the previous third
28904|Done
28905|Save IY
28986|Keep the screen position
28990|A=the width of the line
29006|Save BC
29024|Restore HL
29025|Restore BC
29457|Done: the message has been rendered
29467|D=the type and page
29494|Done: NZ means the message goes on
29511|Below A: not a capital, store as it is
29513|Above Z?
29515|Yes: store as it is
29519|Save HL
29542|Restore HL
29592|Test bit 4 of D again
29595|Done
29620|Done
29628|Done
29722|DE=100
29739|DE=10
29795|D=255, so DE is a negative offset
29807|Done
29878|Combine with E: is the address zero?
29887|Keep the sub-message address
29896|Done
29909|E=the index
29910|DE=index
29915|Add the index once...
29918|Next byte of the table entry
29951|Put the space in the buffer
"""
