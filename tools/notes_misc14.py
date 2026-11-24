TXT = """
26815|Set the border to the layout's colour
26817|Keep the caller's HL
26821|H=high byte of the picture address (HL=picture address)
26824|HL=the caller's HL again; the picture address is on the stack
26830|Test the layout-changed flag
26835|Save DE...
26836|...and BC
26844|Is this the end of the attribute file (high byte 91)?
26849|Is the cell bright white paper (a bubble cell)?
26853|Keep the cell's address
26856|Clear one pixel row of the cell
26858|Down to the next pixel row
26861|Back to the top of the cell
26866|A=H: the current screen third...
26867|...plus 8 gives the next third
26869|H=the next third
26872|Restore BC...
26873|...DE...
26874|...and HL
26875|Done: all speech bubbles are wiped
31485|Is the high byte 88 or more (attribute file)?
31490|Add 32 to move down one row of cells...
31492|...L=the new low byte
31493|Done unless the add carried into the high byte
31494|Carry: the next page
31495|Done
31497|A=the new high byte
31498|The low 3 bits count the pixel row in the cell
31501|Crossed into the next cell row: add 32 to L
31502|(next row of cells)
31504|L=the new low byte
31505|Carry: in the next third, H is already right
31506|Otherwise H must go back 8...
31507|...to stay in the same third
31509|H=the corrected high byte
31510|Done
26943|Save the character...
26944|...and the registers
26945|(DE)
26946|(HL, the screen address)
26952|Keep the screen address
26958|One more bit of mask than the width
26959|Start from a full byte
26961|Shift in a zero from the left
26973|Step on to the next row of the glyph
27001|Restore the screen address
27002|Restore DE
27003|Restore BC
27010|Subtract the 8 pixels already passed
27016|Restore the character
27017|Done: HL, C updated to the next print position
27061|Keep the attribute value
27066|Next pixel row
27067|One fewer row to clear
27068|Repeat for all eight rows
27071|H-1: the display file third is now 0-2 in bits 3-4
27072|Move the third number...
27073|...down into the low bits...
27074|...(three rotates)
27075|Keep the two bits of the third
27077|Add the high byte of the attribute file
27079|H=attribute address high byte
27083|Set the cell's attribute
27084|Restore the attribute value
27085|Restore the screen address
27086|Done: the cell is blank with the new attribute
"""
