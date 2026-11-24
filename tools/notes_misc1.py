"""Hand-written comments: bubble text layout, picture coordinate readers, line drawer."""
TXT = r'''
29029|Save BC
29030|Save DE
29031|B=the width of the line in pixels
29032|A=the first character of the text
29035|Test it
29036|End of the text: nothing to print
29038|Save the start of the line
29040|Remember the start of the line
29044|A=the next character
29047|Test it
29048|End of the text: the line ends here
29050|Measure the next word
29053|D=the width of the word
29054|A=the width left on the line
29055|Subtract the word's width
29056|It does not fit: the line ends before this word
29058|B=the width left
29059|Try the next word
29061|DE=the start of the line
29062|Save the width left
29063|Save the start of the line
29064|Save the screen position
29065|HL=the end of the words that fit (where the next word starts)
29068|Clear the carry flag
29069|Subtract the start: the number of characters on the line
29071|A=the character count
29072|Restore the screen position
29073|C=the character count
29074|E=250: a counter for the spaces at the end of the line
29076|D=254: a counter for the spaces at the start of the line
29078|IX=the end of the line
29082|B=the character count
29083|Back up one character
29085|Count it in D
29086|Count three pixels in E for each space...
29087|...
29088|...
29089|A=the character
29092|A space?
29094|No: stop looking
29096|Keep looking for spaces at the end
29098|IX=the start of the line
29100|Step back one
29102|B=the character count
29103|Count three pixels in E for each space at the start...
29104|...
29105|...
29106|Count it in D
29107|Move on one character
29109|A=the character
29112|A space?
29114|No: stop looking
29116|Keep looking for spaces at the start
29118|A=the pixels to be trimmed
29119|E=the character count
29120|Restore the width left
29121|Add it
29122|Halve it: this is the pixel offset that centres the line
29124|Add the character count
29125|At least 8 pixels?
29127|No: that is the pixel offset within the cell
29129|Take off a character cell's 8 pixels
29131|Move one cell right
29132|Repeat
29134|C=the pixel offset within the first cell
29135|A=the character count
29136|Take off the spaces to be skipped
29137|E=the number of characters to print
29138|None: nothing to print
29140|None: nothing to print
29142|A=the character
29145|Print it in the proportional font
29148|Next character
29150|One fewer to print
29151|Loop until the line is printed
29153|IX=the end of the line (the start of the next one)
29157|Restore DE
29158|Restore AF
29159|B=A
29160|Return
29161|Save IX
29163|Save IY
29165|IX=just before the list of word widths (24192)
29169|IY=the list of word widths
29173|A=a width
29176|Next one
29178|The end marker is 255
29179|Keep looking for it
29181|IY=the end marker
29183|B=0: no lines yet
29185|HL=the table of line widths (28728)
29188|C=0: nothing in this line yet
29190|Next word from the front of the text
29192|A=its width
29195|Add it to the line
29196|C=the line width so far
29197|A=the width allowed for this line
29198|Does the word fit?
29199|Yes: try another
29201|Back off the last word
29203|One more line
29204|Have the front and back met?
29207|Yes: finished
29209|C=0: nothing in the line from the back
29211|Back one word from the end
29213|A=its width
29216|Add it to the line
29217|C=the line width so far
29218|A=the width allowed for this line
29219|Does the word fit?
29220|Yes: try another
29222|One more line (the last one, filled from the back)
29223|Put the word back
29225|Next width in the table (the next pair of lines is wider)
29226|Have the front and back met?
29229|No: fill another line from the front
29231|Restore IY
29233|Restore IX
29235|Return
29236|Save HL
29237|Save IX...
29239|...in HL
29240|Save IY...
29242|...in DE
29243|Clear the carry flag
29244|Subtract: carry set if IX is less than IY
29246|Restore HL
29247|Return
29294|IX=the text buffer
29298|HL=0: the width so far
29301|A=the next character
29304|Test it
29305|End of the text: return
29306|DE=the width so far
29307|HL=the character's glyph address
29310|L=the glyph width
29311|H=0
29313|Add one pixel of spacing
29314|Add the width so far
29315|Next character
29317|Loop
32365|D=1: read one bit
32367|Read it
32370|Test it
32371|Zero: only one coordinate is given
32373|Read the x coordinate
32376|C=x
32377|Read the y coordinate
32380|B=y
32381|Return
32382|D=1: read one bit
32384|Read it
32387|Test it
32388|One: it is a y delta
32390|Read a long x delta
32393|C=the new x
32394|Return
32395|Read a long y delta
32398|B=the new y
32399|Return
32400|D=1: read one bit
32402|Read it
32405|Test it
32406|Zero: a short delta follows
32408|D=8: an absolute coordinate has eight bits
32410|Read it and return
32413|A=the number of bits in a short x delta (from the picture header)
32416|D=the number of bits
32417|Read the delta (left-aligned in A)
32420|D=the delta
32421|A=the number of bits
32424|Shift right, keeping the sign...
32426|...until the delta is right-aligned
32427|...(8 minus the number of bits times)
32429|Repeat
32431|A=the signed delta
32433|Add it to the old x
32434|Return
32434|D=1: read one bit
32436|Read it
32439|Test it
32440|Zero: a short delta follows
32442|D=8: an absolute coordinate has eight bits
32444|Read it and return
32447|A=the number of bits in a short y delta (from the picture header)
32450|D=the number of bits
32451|Read the delta (left-aligned in A)
32454|D=the delta
32455|A=the number of bits
32458|Shift right, keeping the sign...
32460|...until the delta is right-aligned
32461|...(8 minus the number of bits times)
32463|Repeat
32465|A=the signed delta
32466|Add it to the old y
32467|Return
32468|D=1: read one bit
32470|Read it
32473|Test it
32474|Zero: a long delta follows
32476|D=8: an absolute coordinate has eight bits
32478|Read it and return
32481|A=the number of bits in a long x delta (from the picture header)
32484|D=the number of bits
32485|Read the delta (left-aligned in A)
32488|D=the delta
32489|A=the number of bits
32492|Shift right, keeping the sign...
32494|...until the delta is right-aligned
32495|...(8 minus the number of bits times)
32497|Repeat
32499|A=the signed delta
32500|Add it to the old x
32501|Return
32502|D=1: read one bit
32504|Read it
32507|Test it
32508|Zero: a long delta follows
32510|D=8: an absolute coordinate has eight bits
32512|Read it and return
32515|A=the number of bits in a long y delta (from the picture header)
32518|D=the number of bits
32519|Read the delta (left-aligned in A)
32522|D=the delta
32523|A=the number of bits
32526|Shift right, keeping the sign...
32528|...until the delta is right-aligned
32529|...(8 minus the number of bits times)
32531|Repeat
32533|A=the signed delta
32534|Add it to the old y
32535|Return
32595|Return with the bits left-aligned in A (the top D bits of the byte)
32612|L=the target x
32613|H=0
32615|A=the start x (32610)
32618|E=it
32619|D=0
32620|Clear the carry flag
32621|HL=target x minus start x: the signed x distance
32623|A=the low byte of the distance
32624|D=1, E=1: the y step and the x step both start as +1
32627|Is the x distance negative?
32629|No
32631|A=its size
32633|E=255: the x step is -1
32635|C=the size of the x distance
32636|Save the steps
32637|L=the target y
32638|H=0
32640|A=the start y (32611)
32643|E=it
32644|D=0
32645|Clear the carry flag
32646|HL=target y minus start y: the signed y distance
32648|Get the steps back
32649|A=the low byte of the distance
32650|Is the y distance negative?
32652|No
32654|A=its size
32656|D=255: the y step is -1
32658|B=the size of the y distance
32659|A=the size of the x distance
32660|Compare it with the y distance
32661|x is the longer: that is the main direction
32663|y is the longer: L=the x distance (the shorter)
32664|Store the steps in the operand of the LD BC,0 at 32693 (self-modifying)
32668|A=0
32669|E=0: no x step on the main direction
32670|Carry on
32673|L=the y distance (the shorter)
32674|B=the x distance (the number of pixels to draw)
32675|Store the steps in the operand of the LD BC,0 at 32693 (self-modifying)
32679|D=0: no y step on the main direction
32681|H=the length of the main direction
32682|A=it
32683|Halve it: the error term starts half-way
32684|Add the shorter distance to the error term
32685|It overflowed a byte: step sideways
32687|Compare with the longer distance
32688|Smaller: no sideways step this time
32690|Take off the longer distance
32691|C=the new error term
32692|Switch to the alternate registers
32693|BC=the step for both directions (set above)
32696|Carry on
32699|C=the error term
32700|Save the main-direction step
32701|Switch to the alternate registers
32702|BC=the main-direction step only
32703|A=the vertical step
32704|Test it
32705|None: skip the vertical move
32707|Is it negative?
32709|No: move down
32711|Up one pixel row
32712|A=the high byte of the screen address
32713|Pixel row within the character cell
32715|Crossed a character boundary?
32717|Yes: adjust the address
32719|No
32722|Down one pixel row
32723|A=the high byte
32724|Pixel row within the character cell
32726|Crossed into the next character row: adjust
32728|A=the horizontal step
32729|Test it
32730|None: plot the pixel
32732|Is it negative?
32734|Yes: move left
32736|Rotate the pixel mask right
32738|Still in the same byte
32741|Next byte
32742|Plot the pixel
32745|Rotate the pixel mask left
32747|Still in the same byte
32750|Previous byte
32751|A=the pixel mask
32752|Combine it with the screen byte
32753|Plot the pixel
32754|Switch back to the main registers
32755|A=the error term
32756|Loop for every pixel of the line
32758|Return
32759|A=the low byte
32760|Down one character row
32762|L=it
32763|Carry: the next third (H is right)
32765|A=the high byte
32766|Take back the 8
32768|H=it
32769|Carry on
32772|A=the low byte
32773|Up one character row
32775|L=it
32776|Carry: the previous third was crossed (H is wrong only if no carry)
32778|A=the high byte
32779|Move up 8 in the high byte
32781|H=it
32782|Carry on
'''
