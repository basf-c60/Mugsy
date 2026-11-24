"""Hand-written comments: line input and key wait."""
TXT = r'''
28040|DE=the next byte
28043|BC=19: copy the first space along
28046|Put a space in the first byte
28048|Fill the 20 bytes with spaces
28055|Clear the first row of the bubble (8 cells)
28058|HL=the second row
28061|B=10 cells
28063|Clear it
28066|HL=the third row
28069|B=12 cells
28071|Clear it
28074|HL=the fourth row
28077|B=10 cells
28079|Clear it
28082|HL=the fifth row
28085|B=8 cells
28087|Clear it
28090|HL=the tail of the bubble
28093|B=2 cells
28095|Clear it
28098|HL=the end of the tail
28101|B=1 cell
28103|Clear it
28106|HL=the last cell of the tail
28109|B=1 cell
28111|Clear it
28141|Control key: ignore it
28145|Graphics or keyword: ignore it
28152|Next byte of the buffer
28163|Rub out?
28165|Yes
28167|Delete?
28169|Yes
28171|ENTER?
28173|Not a wanted key: wait for another
28176|Store the terminator
28177|Return
28179|Test the count
28188|Print a space over the cursor
28191|And another to erase the character
28194|Restore the screen position
28195|Restore the count
28196|Save the screen position
28198|Get the glyph address of the character being rubbed out
28201|A=its width
28202|Restore the screen position
28205|Work out the pixel offset after moving back
28207|Is the offset negative?
28209|No: done
28212|Add a cell's 8 pixels
28214|Check again
28224|Save the key
28225|Save HL
28226|Save BC
28230|Add one
28231|Wrap round after 3
28233|Store the counter
28243|A=42: the asterisk cursor
28245|It was a space: switch to the asterisk
28247|A=32: a space
28249|Store the cursor character
28255|A=space: blank the next position
28257|Print it
28260|Restore BC
28261|Restore HL
28262|Restore the key
28265|Return
28266|Save IY
28268|Save HL
28269|Save BC
28276|Interrupts off again
28286|Store the flags
28292|Restore BC
28293|Restore HL
28294|Restore IY
28296|Return
'''
