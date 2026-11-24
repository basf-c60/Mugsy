"""Hand-written comments for the shootout (part 4: sprite jobs, walls, controls, scheduler)."""
TXT = r'''
45965|Fetch a byte of the graphic (the graphic is read backwards, from DE)
45966|Combine it with the screen byte
45967|Draw it
45968|Back one byte in the graphic
45969|Next screen byte to the right
45970|Fetch the next graphic byte
45971|Combine it with the screen
45972|Draw it
45973|Back one byte in the graphic
45974|Back to the left-hand column
45975|Down a pixel row (within the character)
45976|Loop for B pixel rows
45978|A=C: pixel rows left to do
45979|Test it
45980|None left: finish the job
45982|Subtract eight rows (one character row)
45984|B=8: a full character
45986|C=the rows left
45987|At least eight were left
45989|Add the eight back
45991|B=what is left
45992|C=0: that is the last block
45994|A=32
45996|Move down one character row
45997|L=the new low byte
45998|Still in the same third: draw the next block
46000|Crossed into the next third: A=the high byte
46001|Down 8 in the high byte
46003|H=it
46004|Draw the next block
46007|Restore the attribute address
46008|Restore the screen address
46009|Restore the attribute count
46010|BC=32: one row of attributes
46013|Save the row counter
46014|A=an attribute byte (the attributes are read backwards too)
46015|Set it
46016|Back one byte
46017|Next cell
46018|A=the next attribute
46019|Set it
46020|Back one byte
46021|Get the row counter
46022|One row less
46023|All done: go on to the second half of the job
46026|Back to the first column
46027|Down one attribute row
46028|Next row
46031|Use the alternate registers for the mask pointers
46032|A=a mask byte
46033|Combine with the screen byte
46034|Invert it (this gives the screen bits to keep)
46035|B=the bits that will be changed
46036|Combine with the screen byte again
46037|Put the byte back with the mask bits set to 1
46038|Next mask byte
46039|Next screen byte
46040|A=the next mask byte
46041|Combine with the screen byte
46042|Invert it
46043|C=the bits that will be changed
46044|Combine with the screen byte
46045|Set the mask bits
46046|Next mask byte
46047|Save the old screen bits on the stack
46048|Back to the first column
46049|Down a pixel row
46050|Back to the main registers
46051|Loop for B pixel rows
46053|A=C: pixel rows left
46054|Test it
46055|None left: restore the attributes
46057|Subtract eight rows
46059|B=8
46061|C=the rows left
46062|At least eight were left
46064|Add the eight back
46066|B=what is left
46067|C=0
46069|Alternate registers again
46070|A=32
46072|Down one character row
46073|L=the new low byte
46074|Same third: continue
46076|A=the high byte
46077|Down one third
46079|H=it
46080|Continue
46083|Restore the stack pointer used by the background buffer
46087|HL=where the saved screen bytes begin
46088|DE=the attribute address
46089|BC=the attribute colour and count
46090|SP=the saved-background pointer
46091|Step past the last byte saved
46092|HL=the attribute address
46093|A=an attribute byte
46094|D=it
46095|Clear its colour bits
46096|(the paper and bright bits)
46097|Add the new colour
46098|Store it
46099|Next cell
46100|A=the next attribute
46101|E=it
46102|Clear its colour bits
46104|Add the new colour
46105|Store it
46106|Save the old attributes on the stack
46107|One row less
46108|All done: finish the job
46111|Back a column
46112|DE=32
46113|Down one row
46116|Next row
46119|Fetch a byte of the graphic
46120|Combine with the screen
46121|Draw it
46122|Back a byte
46123|Next column
46124|Fetch the next byte
46125|Combine with the screen
46126|Draw it
46127|Back a byte
46128|Next column
46129|Fetch the third byte
46130|Combine with the screen
46131|Draw it
46132|Back a byte
46133|Back to the first column
46134|(two columns)
46135|Down a pixel row
46136|Loop for B pixel rows
46138|A=C: pixel rows left
46139|Test it
46140|None left: restore the attributes
46142|Subtract eight rows
46144|B=8
46146|C=the rows left
46147|At least eight were left
46149|Add the eight back
46151|B=what is left
46152|C=0
46154|A=32
46156|Down one character row
46157|L=the new low byte
46158|Same third: continue
46160|A=the high byte
46161|Down one third
46163|H=it
46164|Continue
46167|Restore the attribute address
46168|Restore the screen address
46169|Restore the attribute count
46170|BC=32
46173|Save the row counter
46174|A=an attribute byte
46175|Set it
46176|Back one byte
46177|Next cell
46178|A=the next attribute
46179|Set it
46180|Back one byte
46181|Next cell
46182|A=the third attribute
46183|Set it
46184|Back one byte
46185|Get the row counter
46186|One row less
46187|All done: go on to the second half of the job
46190|Back a cell
46191|Back another
46192|Down one attribute row
46193|Next row
46196|Alternate registers
46197|A=a mask byte
46198|Combine with the screen
46199|Invert it
46200|B=the bits that will change
46201|Combine with the screen
46202|Draw it
46203|Next mask byte
46204|Next column
46205|A=the next mask byte
46206|Combine with the screen
46207|Invert it
46208|C=the bits that will change
46209|Combine with the screen
46210|Draw it
46211|Next mask byte
46212|Next column
46213|Save the old bits on the stack
46214|A=the third mask byte
46215|Combine with the screen
46216|Invert it
46217|B=the bits that will change
46218|Combine with the screen
46219|Draw it
46220|Next mask byte
46221|Save the old bits on the stack
46222|Move the stack pointer back a byte
46223|Back a column
46224|And another
46225|Down a pixel row
46226|Main registers again
46227|Loop for B pixel rows
46229|A=C: pixel rows left
46230|Test it
46231|None left: restore the attributes
46233|Subtract eight rows
46235|B=8
46237|C=the rows left
46238|At least eight were left
46240|Add the eight back
46242|B=what is left
46243|C=0
46245|Alternate registers
46246|A=32
46248|Down one character row
46249|L=the new low byte
46250|Same third: continue
46252|A=the high byte
46253|Down one third
46255|H=it
46256|Continue
46259|Restore the stack pointer used by the background buffer
46263|HL=where the saved screen bytes begin
46264|DE=the attribute address
46265|BC=the attribute colour and count
46266|SP=the saved-background pointer
46267|Step past the last byte saved
46268|HL=the attribute address
46269|A=an attribute byte
46270|D=it
46271|Clear its colour bits
46273|Add the new colour
46274|Store it
46275|Next cell
46276|A=the next attribute
46277|E=it
46278|Clear its colour bits
46280|Add the new colour
46281|Store it
46282|Next cell
46283|Save the old attributes on the stack
46284|A=the third attribute
46285|D=it
46286|Clear its colour bits
46288|Add the new colour
46289|Store it
46290|Save the old attributes on the stack
46291|Move the stack pointer back a byte
46292|One row less
46293|All done: finish the job
46296|Back a column
46297|And another
46298|DE=32
46301|Down one row
46302|Next row
46305|Clear the screen to white paper
46308|A=95: the starting y coordinate
46310|C=0: the starting x coordinate
46312|D=255: y changes by -1 each step
46314|E=1: x changes by +1 each step
46316|B=41 points
46318|Plot a diagonal line (the left wall in perspective)
46321|B=27 bytes
46323|Draw a horizontal line (the back wall's base) along the row HL points at
46326|A=54: the starting y
46328|C=40: the starting x
46330|D=255: y changes by -1
46332|E=0: x does not change
46334|B=54 points
46336|Plot a vertical line (a wall edge)
46339|A=90: the starting y
46341|C=5: the starting x
46343|D=255: y -1
46345|E=0: x constant
46347|B=42 points
46349|Plot a vertical line
46352|A=80: the starting y
46354|C=15: the starting x
46356|D=255: y -1
46358|E=0: x constant
46360|B=42 points
46362|Plot a vertical line
46365|A=39: the starting y
46367|C=15: the starting x
46369|D=1: y +1
46371|E=255: x -1
46373|B=10 points
46375|Plot a short diagonal
46378|A=24: 24 pixel rows for the door
46380|DE=16435: the door's position on the screen
46383|Save it
46384|HL=the door graphic (48404)
46387|BC=5 bytes per row
46390|Save the row's address
46391|Copy a row of the door onto the screen
46393|Get the row's address back
46394|Next pixel row
46395|HL=the address
46396|Save the row counter
46397|Fix up the address across character boundaries
46400|Restore the row counter
46401|DE=the address
46402|One row less
46403|Loop for 24 rows
46405|DE=the door's screen address
46406|Convert it to an attribute address
46409|A=3: three attribute rows
46411|BC=5 cells per row
46414|Save the row's address
46415|Set the door's attributes
46417|Restore the address
46418|BC=32
46421|HL=the address
46422|Down one attribute row
46423|DE=the address
46424|One row less
46425|Loop for 3 rows
46427|Return
46428|Save the counter
46429|Save the coordinates
46430|Get the display address for the point from the ROM (the PIXEL-ADD routine, skipping its range check)
46433|B=the bit position
46434|One more than the bit position
46435|A=%11111110
46437|Rotate it to line up with the pixel...
46438|...for B steps
46440|Make it the single pixel mask
46441|Combine with the screen byte
46442|Plot the pixel
46443|Restore the coordinates
46444|Restore the counter
46445|Add the y step
46446|Save it
46447|A=x
46448|Add the x step
46449|C=the new x
46450|Restore y
46451|Plot B points
46453|Return
46454|Set a screen byte to 255
46456|Next byte
46457|Loop for B bytes
46459|Return
46460|HL=Mugsy's record (the figure the keys move)
46463|C=0: the direction bits
46465|Read the half-row Y U I O P
46467|Read the keyboard
46469|B=the key states
46470|Is P pressed?
46472|No
46474|Set bit 2: right
46476|A=the key states
46477|Is I pressed?
46479|No
46481|Set bit 6: left
46483|Read the half-row CAPS Z X C V
46485|Read the keyboard
46487|Is Z pressed?
46489|No
46491|Set bit 4: down
46493|Read the half-row Q W E R T
46495|Read the keyboard
46497|Is Q pressed?
46499|No
46501|Set bit 0: up
46503|Read the half-row SPACE SYM M N B
46505|Read the keyboard
46507|B=the key states
46508|Is M pressed?
46510|No
46512|Set bit 7: fire
46514|A=the key states
46515|Is N pressed?
46517|No
46519|Set bit 7: fire
46521|A=the key states
46522|Is B pressed?
46524|No
46526|Set bit 7: fire
46528|A=the combined bits
46529|Test them
46530|No key pressed: no movement
46532|B=the bits
46533|Up and down together?
46535|Compare
46537|Yes: they cancel
46539|A=the bits
46540|Left and right together?
46542|Compare
46544|Yes: they cancel
46546|A=the bits
46547|Is fire pressed?
46549|A=10: the code for fire
46551|Yes: use it
46553|A=the bits
46554|Drop the fire bit
46556|B=the direction bits
46557|Right?
46559|Use the code
46561|Left?
46563|Use the code
46565|Up and right?
46567|A=2
46569|Use the code
46571|A=the bits
46572|Down and right?
46574|A=8
46576|Use the code
46578|A=the bits
46579|Up and left?
46581|A=128
46583|Use the code
46585|A=the bits
46586|Down and left?
46588|A=32
46590|Use the code
46592|A=the bits
46593|Up only?
46595|No: try down
46597|A=Mugsy's state byte
46598|D=it
46599|Is he facing right?
46601|No
46603|A=2: up and right
46605|Use the code
46607|A=his state
46608|Is he facing left?
46610|No
46612|A=128: up and left
46614|Use the code
46616|A=the bits
46617|Down only?
46619|No: no movement
46621|A=Mugsy's state byte
46622|Is he facing right?
46624|No
46626|A=8: down and right
46628|Use the code
46630|A=his state
46631|Is he facing left?
46633|No: no movement
46635|A=32: down and left
46637|Use the code
46640|A=Mugsy's current state (no new direction)
46641|Store the direction code for the main loop
46644|Return
48539|Save AF
48540|Save BC
48541|Save DE
48542|Save HL
48543|Save IX
48545|Save IY
48547|HL=the figure timers
48550|A=the number of figures in use
48553|B=the count
48554|C=0: the figure number
48556|A=this figure's timer
48557|Test it
48558|Not zero: the figure is idle or waiting for orders
48560|Save the counters
48561|Save the timer pointer
48562|HL=the table of countdown pointers (42257)
48565|B=0
48567|C=the figure number*2
48569|HL=its entry
48570|E=the countdown address, low byte
48571|Next byte
48572|D=high byte
48573|HL=the countdown address
48574|One tick less
48575|Reached zero: draw the figure
48577|Restore the timer pointer
48578|Set the timer to 255 so that the INC below leaves it at 0
48580|Next figure
48582|Next byte: the sprite job pointer
48583|E=the low byte
48584|Next byte
48585|D=the high byte
48586|HL=the sprite job (a block of register values)
48587|IX=0
48591|IX=the stack pointer
48593|SP=the sprite job
48594|HL=the first register pair from the job
48595|DE=the second pair
48596|BC=the third pair
48597|IY=the address of the drawing routine
48599|Run the drawing routine (it finishes with a jump to 48601 or 48617)
48601|Switch to the alternate registers
48602|HL'=the next value from the job
48603|DE'=the next value
48604|Back to the main registers
48605|BC=the next value
48606|HL=the next value
48607|IY=the next routine
48609|Remember the stack pointer
48613|SP=the job's saved-background area
48614|Step past the last byte
48615|Run the second routine (it finishes with a jump to 48617)
48617|Restore the real stack pointer
48619|Restore the timer pointer
48620|Restore the counters
48621|Timer: 0 becomes 1 (the figure is ready for orders)
48622|Next timer
48623|Next figure
48624|Loop for all the figures
48626|Read the keyboard
48629|Restore IY
48631|Restore IX
48633|Restore HL
48634|Restore DE
48635|Restore BC
48636|Restore AF
48637|Enable interrupts
48638|Return from the interrupt
'''
