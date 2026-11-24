TXT = """
28907|Save the registers this routine uses...
28908|...(HL=screen position, DE=width table)...
28909|...and BC, which will count rows
28916|B=lines in the top half...
28917|...plus the lines in the bottom half (28756)...
28920|...to give the number of rows above the middle line
28921|B=the row counter
28924|Keep the screen position for the next row
28932|Back to the start of this row
28933|Next margin entry
28935|Next line width
28941|Keep the screen position of the middle row
28943|Back to the widest line's margin entry
28948|A=the width of the widest line
28955|Test for no odd middle line
28956|Skip the extra step if there is none
28958|Odd middle line: step back one more width...
28959|...and one more margin entry
28961|Restore the screen position
28965|Keep the screen position of the middle row
28966|Indent by the margin of the middle line
28969|A=width of the middle line
28973|Restore the screen position
28977|B=lines in the bottom half
28978|Test for none
28994|Restore the screen position
29000|Restore BC...
29001|...DE...
29002|...HL...
29003|...and IY
29005|Done: the whole bubble background is painted
29321|A=0, to clear the first-character flag
29328|Start the text buffer pointer at 23808
29337|Store the zero terminator in the buffer
29343|Test the layout-changed flag
29353|Clear the carry flag for the subtraction
29361|DE=0 (the new width), HL=old width
29362|Clear the carry flag
29371|Count one more space
29372|Clear the carry flag
29375|Loop while the width remaining is at least 3
29378|Combine B and C to test BC for zero
29384|Half the count in BC (carry out of B into C)
29390|DE=HL: the address of the last character...
29400|Clear the carry flag
29401|HL=length of the text in the buffer (counted down from the end)
29403|Keep the length
29404|HL=address of the last character again
29405|BC=length, ready for LDDR
29416|Test the high byte of the count
29419|A=low byte of the count
29420|Test it for zero
29429|Space at the start of the buffer
29431|Next position at the front
29432|Next position at the end
29433|One fewer space to place...
29435|Loop back for the next pair
29439|Step over the odd space
29451|Return with HL=the final width
"""
