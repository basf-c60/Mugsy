"""Hand-written comments for the animation helpers and the getaway car (33937-35405)."""
TXT = r'''
33943|BC=76 bytes
33946|Copy the initial values of the animation variables into place
33951|B=10
33955|Next byte
33956|Loop
33961|BC=0: a 32-bit zero
33967|Switch to the alternate registers
33971|BC'=0
33977|Switch back
33981|BC=0: the high half of the value to store
33989|Store the 32-bit value in a variable
33992|Return
33994|Interrupts off while the animation interrupt routine is installed
34003|Set the interrupt vector register
34005|Select interrupt mode 2
34007|Enable interrupts: #R34069 now runs fifty times a second
34009|Clear the "animation finished" flag
34014|Get a random number
34021|Is it 50 or more?
34032|Interrupts off
34035|Put the interrupt vector register back for the ROM
34039|Return
34043|Test the flag
34045|Enable interrupts
34047|And again, to be sure they are on
34051|H=the high byte of the step routine's address
34061|Next step
34063|Loop back to wait for the interrupt and run the step
34069|Save AF
34073|One tick less
34074|Store it
34082|Store it
34087|Set the tick flag
34090|Restore AF
34091|Return from the interrupt
34093|B=2: two bytes per pixel row
34095|Carry on with the common code
34097|B=3: three bytes per pixel row
34099|A=the height of the sprite (the first byte of the sprite data)
34100|Move to the graphic data
34101|C=the number of pixel rows
34102|Save the row counter and width
34103|Save the screen address
34104|A=a byte of the graphic
34105|Put it on the screen
34106|Next graphic byte
34107|Next screen column
34108|Loop for every byte of the row
34110|Restore the screen address
34111|Restore the row counter
34112|Down one pixel row
34113|A=the high byte
34114|Crossed into a new character row?
34116|Yes: adjust the address
34118|One row less
34119|Loop for every pixel row
34121|Return
34122|A=the low byte
34123|Down one character row
34125|L=the new low byte
34126|Carry: the next third of the screen (H is already right)
34128|A=the high byte
34129|Take back the 8 added by the pixel row steps
34131|H=it
34132|Carry on
34137|Next byte
34138|D=the high byte of the sprite's graphic address
34144|Switch to the alternate registers
34147|Switch back
34151|Copy the four graphic bytes of the row
34155|Next buffer byte
34158|Next buffer byte
34159|Switch to the alternate registers (for the row counter)
34167|Save the buffer address
34171|Shift the mask byte right (the carry brings in a 1)
34173|Skip to the next mask byte
34174|(rows are 6 bytes long)
34175|Shift the second mask byte
34177|Skip on
34178|...
34179|Shift the third mask byte
34181|Back to the first graphic byte
34182|...
34183|...
34185|Shift the first graphic byte (a 0 comes in)
34187|Next graphic byte
34188|...
34189|Shift the second graphic byte
34191|Next graphic byte
34192|...
34193|Shift the third graphic byte
34195|Next row
34198|One pixel of shift less
34203|C=32 pixel rows
34205|B=3 bytes per row
34207|A=the screen byte
34208|Switch to the alternate registers
34209|Save it in the background store
34210|Next store byte
34211|Switch back
34212|AND with the mask
34213|Next byte of the sprite buffer
34214|OR in the graphic
34215|Save the result in A'
34216|A=the screen column
34217|Column bits
34218|Is it column 30 or more?
34219|Is it column 30 or more?
34221|Yes: do not draw (off the right of the scene)
34223|Get the result back
34224|Draw it
34225|Next sprite buffer byte
34226|Next column
34227|Loop for three bytes
34229|Back to the first column
34230|...
34231|...
34232|Down one pixel row
34233|A=the high byte
34234|Crossed into the next character row?
34236|Yes: adjust
34238|One row less
34239|Loop for every row
34241|Return
34242|A=the low byte
34243|Down one character row
34245|E=the new low byte
34246|Carry: next third (D is right)
34248|A=the high byte
34249|Take back the 8
34251|D=it
34252|Carry on
34255|C=32 pixel rows
34257|B=3 bytes per row
34259|A=a saved background byte
34260|Put it back on the screen
34261|Next column
34262|Next saved byte
34263|Loop for three bytes
34265|Back to the first column
34266|...
34267|...
34268|Down one pixel row
34269|A=the high byte
34270|Crossed into the next character row?
34272|Yes: adjust
34274|One row less
34275|Loop for every row
34277|Return
34278|A=the low byte
34279|Down one character row
34281|E=the new low byte
34282|Carry: next third
34284|A=the high byte
34285|Take back the 8
34287|D=it
34288|Carry on
34318|A=0
34319|Black border
34321|HL=the compressed picture of the street
34324|Draw it
34327|HL=the screen address of the first hood's start position
34330|Store it
34333|HL=the screen address of the second hood's start position
34336|Store it
34339|HL=the first hood's frame list (37109)
34342|Store it
34345|HL=the second hood's frame list (37941)
34348|Store it
34351|HL=the screen address where the car starts (52311, with the left-clip flag in bit 7 of H)
34354|Store it as the car's position
34357|A=0
34358|The first hood's pixel shift is 0
34361|The second hood's pixel shift is 0
34364|The car's pixel shift is 0
34367|A=10
34369|The first hood waits 10 steps before moving
34372|Set the reload value of the interrupt countdown (one tick every 10 interrupts)
34375|Set the countdown
34378|Figure counter 34295 starts at 10
34381|A=9
34383|The first hood moves every 9 ticks
34386|A=13
34388|The second hood moves every 13 ticks
34391|A=8
34393|Counter for the figure at 17728
34396|Counter for the figure's delay
34399|A=3
34401|Step counter
34404|HL=the first hood's frame list
34407|Skip the first entry
34408|...
34409|A=the first hood's pixel shift
34412|DE=the first hood's sprite buffer (24384)
34415|Prepare the shifted sprite
34418|Draw the first hood
34421|HL=the second hood's frame list
34424|Skip the first entry
34425|...
34426|A=the second hood's pixel shift
34429|DE=the second hood's sprite buffer (24192)
34432|Prepare the shifted sprite
34435|Draw the second hood
34438|A=0: this step is complete
34439|Return
34440|A=1
34442|Mark the animation as finished
34445|A=the car's pixel shift
34448|Test it
34449|Done if it is at a byte boundary
34450|Otherwise keep scrolling the car
34453|Check again
34455|Draw the next frame of the street animation
34458|Restore the background behind the second hood
34461|Draw the second hood
34464|Draw the five-byte-wide graphic
34467|Move the second hood on
34470|A=the second hood's screen address
34473|Column
34475|Column 18?
34477|Yes: this step is not finished (Z set)
34478|Column 30?
34480|Return (Z set when the hood has reached column 30)
34481|Draw the next frame of the street animation
34484|Restore the background behind the first hood
34487|Draw the first hood
34490|Restore the background behind the second hood
34493|Draw the second hood
34496|Draw the five-byte-wide graphic
34499|Move the first hood on
34502|Move the second hood on
34505|A=the first hood's screen address
34508|Column
34510|Column 30?
34512|Return (Z set when the first hood has reached column 30)
34513|Draw the next frame of the street animation
34516|Scroll the car and redraw it
34519|HL=the car's screen address
34522|A=the low byte
34523|Column
34525|Column 20?
34527|No: keep going
34528|Is the left-clip flag set?
34530|Yes: keep going
34531|A=the car's pixel shift
34534|Shift 4?
34536|Return (Z set when the car is in position)
34537|Draw the next frame of the street animation
34540|Draw the next frame of the figure at 18838
34543|Return if the figure's frame did not change
34544|A=the step counter
34547|One less
34548|Store it
34551|Return if not zero
34552|A=5
34554|Reload the step counter
34557|Return (Z set when the counter ran out)
34558|Draw the next frame of the street animation
34561|Draw the next frame of the figure at 17728
34564|Play the delay sound and animate the figures
34567|Draw the next frame of the figure at 18838
34570|Return if the figure's frame did not change
34571|A=the step counter
34574|One less
34575|Store it
34578|Return (Z set when the counter ran out)
34579|Draw the next frame of the street animation
34582|Scroll the car and redraw it
34585|Draw the next frame of the figure at 17728
34588|HL=the car's screen address
34591|A=the low byte
34592|Column
34594|Column 30?
34596|No: keep going
34597|Is the left-clip flag set?
34599|Return (Z set when the car has gone)
34600|Draw the next frame of the street animation
34603|Draw the next frame of the figure at 17728
34606|A=the figure counter
34609|Test it
34610|Return (Z set when it has run out)
34611|Scroll the car two pixels
34614|Draw the car's moving parts
34617|BC=440: a long delay when the car is at a byte boundary
34620|A=the car's pixel shift
34623|Test it
34624|At a boundary: use the long delay
34626|BC=60: a short delay between pixels
34629|Count BC down
34630|A=B
34631|Combine with C
34632|Loop until it reaches zero
34634|Draw the car, clipped to the scene
34637|Draw the masked graphic at 19299
34640|Draw the car's lower parts
34643|A=the first hood's counter
34646|One tick less
34647|Store it
34650|Not time to move yet
34651|A=9
34653|Reload the counter
34656|HL=the first hood's screen address
34659|A=the number of steps to wait first
34662|Test it
34663|None: move the hood
34665|One less
34666|Store it
34669|Skip the move this time
34671|A=the pixel shift
34674|Add 4 (the hood moves 4 pixels per step)
34676|Keep it within a byte
34678|Store it
34681|Still inside the byte
34683|Next screen column
34684|Store the new address
34687|HL=the hood's frame list
34690|E=the next frame address, low byte
34691|Next byte
34692|D=high byte
34693|Next byte
34694|Store the new list position
34698|A=the pixel shift
34701|DE=the hood's sprite buffer
34704|Prepare the shifted sprite
34707|A=the second hood's counter
34710|One tick less
34711|Store it
34714|Not time to move yet
34715|A=5
34717|Reload the counter
34720|HL=the second hood's screen address
34723|A=the pixel shift
34726|Add 2
34728|Keep it within a byte
34730|Store it
34733|Still inside the byte
34735|Next screen column
34736|Store the new address
34739|HL=the second hood's frame list
34742|E=the next frame address, low byte
34743|Next byte
34744|D=high byte
34745|Next byte
34746|Store the new list position
34750|A=the pixel shift
34753|DE=the second hood's sprite buffer
34756|Prepare the shifted sprite
34759|DE=where the second hood was drawn
34763|HL=its saved background (24000)
34766|Put the background back
34769|DE=where the first hood was drawn
34773|HL=its saved background (24096)
34776|Put the background back
34779|HL=the first hood's sprite buffer (24384)
34782|DE=its screen address
34786|Remember where it is drawn
34790|Switch to the alternate registers
34791|HL'=the first hood's background save area
34794|Switch back
34795|Draw it, saving the background
34798|HL=the second hood's sprite buffer (24192)
34801|DE=its screen address
34805|Remember where it is drawn
34809|Switch to the alternate registers
34810|HL'=the second hood's background save area
34813|Switch back
34814|Draw it, saving the background
34817|HL=a 5-byte-wide mask/graphic pair buffer (38469)
34820|DE=its screen address
34823|C=32 pixel rows
34825|B=5 bytes per row
34827|Save the row's address
34828|A=the screen byte
34829|Mask it
34830|Next buffer byte
34831|OR in the graphic
34832|Next buffer byte
34833|Put it on the screen
34834|Next column
34835|Loop for five bytes
34837|Restore the row's address
34838|Down one pixel row
34839|A=the high byte
34840|Crossed into the next character row?
34842|Yes: adjust
34844|One row less
34845|Loop for every row
34847|Return
34848|A=the low byte
34849|Down one character row
34851|E=the new low byte
34852|Carry: next third
34855|A=the high byte
34856|Take back the 8
34858|D=it
34859|Carry on
34862|A=the tick flag
34865|Test it
34866|Return if no tick has happened
34867|A=0
34868|Clear the flag
34871|HL=the frame list position
34874|E=the next frame's address, low byte
34875|Next byte
34876|D=high byte
34877|Next byte
34878|Store the new position
34882|DE=the screen address (21260)
34885|B=13 pixel rows
34887|A=a byte of the frame
34888|Put it on the screen
34889|Next byte
34890|Down a pixel row
34891|A=the high byte
34892|Crossed into the next character row?
34894|Yes: adjust
34896|Loop for 13 rows
34898|Return
34899|A=the low byte
34900|Down one character row
34902|E=the new low byte
34903|Carry: next third
34905|A=the high byte
34906|Take back the 8
34908|D=it
34909|Carry on
34912|DE=where the first moving part is drawn (39143)
34915|HL=its first frame (39325)
34918|A=the car's pixel shift
34921|Test it
34922|Zero: use the first frame
34924|HL=the second frame (39341)
34927|Shift 2?
34929|Yes: use it
34931|HL=the third frame (39357)
34934|Shift 4?
34936|Yes: use it
34938|HL=the fourth frame (39373)
34941|Draw the first part
34944|DE=where the second moving part is drawn (39151)
34947|HL=its first frame (39389)
34950|A=the car's pixel shift
34953|Test it
34954|Zero: draw the first frame
34956|HL=the second frame (39405)
34959|Shift 2?
34961|Yes: draw it
34963|HL=the third frame (39421)
34966|Shift 4?
34968|Yes: draw it
34970|HL=the fourth frame (39437)
34973|BC=11: the distance to the next row
34976|A=4 rows
34978|Save the row counter
34979|A=a byte of the car buffer
34980|OR in the next graphic byte
34981|Next byte
34982|AND with the mask byte
34983|Store it
34984|Next byte
34985|Next buffer byte
34986|A=the next byte of the car buffer
34987|OR in the graphic
34988|Next byte
34989|AND with the mask
34990|Store it
34991|Next byte
34992|HL=the buffer address
34993|Move to the start of the next row
34994|DE=the buffer address
34995|Get the row counter
34996|One row less
34997|Loop for four rows
34999|Return
35000|HL=the car's screen address
35003|Remember it for the drawing routine
35006|HL=the car buffer (38794)
35009|Save it
35010|C=38 rows
35012|Clear the carry flag
35013|Save the start of the row
35014|B=12 bytes
35016|Rotate a byte right (carry passes along the row)
35018|Next byte
35019|Loop for 12 bytes
35021|Restore the start of the row
35022|B=12 bytes
35024|Rotate it right again: that is two pixels in all
35026|Next byte
35027|Loop for 12 bytes
35029|One row less
35030|Loop for 38 rows
35032|C=3: three more rows
35034|Set the carry flag: these rows (the mask) shift in 1s
35035|Save the start of the row
35036|B=12 bytes
35038|Rotate a byte right
35040|Next byte
35041|Loop for 12 bytes
35043|Restore the start of the row
35044|B=12 bytes
35046|Rotate right a second time
35048|Next byte
35049|Loop for 12 bytes
35051|One row less
35052|Loop for three rows
35054|Restore the buffer address
35055|A=the car's pixel shift
35058|Add 2 pixels
35060|Keep it within a byte
35062|Store it
35065|Return if the car has not completed a byte
35066|DE=the car's screen address
35070|Move on one column
35071|No carry from the low byte
35073|A=the high byte
35074|Move on to the next third of the screen
35076|D=it
35077|A=the low byte
35078|Column
35080|Column 3?
35082|No
35084|Clear the left-clip flag: the car has come into view
35086|Store the new position
35090|BC=455 bytes
35093|DE=the buffer
35094|...
35095|HL=the next byte
35096|Shift the buffer down by one byte
35098|A=0
35099|Clear a byte
35100|Next byte
35101|Next source byte
35102|BC=36
35105|Shift 36 more bytes (the mask area)
35107|A=255
35109|Store a final mask byte
35110|Return
35111|HL=the car's screen address
35114|A=252: offset for the first part
35116|DE=the car's lower graphic (39250)
35119|Draw part of the car
35122|HL=the car's screen address
35125|A=253: offset for the second part
35127|DE=the next graphic (39262)
35130|Draw part of the car
35133|HL=the car's screen address
35136|A=0: no offset for the third part
35138|DE=the third graphic (39274)
35141|Add the offset to the high byte
35142|H=it
35143|A=the low byte
35144|Add 96: three character rows down
35146|L=it
35147|B=12 bytes
35149|Is the left-clip flag set?
35151|Yes: clip on the left
35153|A=the low byte
35154|Column
35156|Column 30?
35158|Yes: clipped on the right, return
35159|A=a graphic byte
35160|Mask the screen byte
35161|Store it
35162|Next column
35163|Next graphic byte
35164|Loop for 12 bytes
35166|Return
35167|A=the low byte
35168|Column
35170|Column 3?
35172|Yes: start drawing
35174|Next column
35175|Wrapped to column 0: adjust the third
35177|Skip a graphic byte
35178|Loop
35180|Return
35181|Clear the left-clip flag
35183|Start drawing
35185|A=the high byte
35186|Next third of the screen
35188|H=it
35189|Carry on
35192|HL=the screen address (19299)
35195|DE=the masked graphic (39286)
35198|B=5 pixel rows
35200|A=a graphic byte
35201|Mask the screen
35202|Store it
35203|Next graphic byte
35204|Next column
35205|A=the next graphic byte
35206|Mask the screen
35207|Store it
35208|Next graphic byte
35209|Next column
35210|A=the next graphic byte
35211|Mask the screen
35212|Store it
35213|Next graphic byte
35214|Back a column
35215|And another
35216|Down a pixel row
35217|Loop for 5 rows
35219|A=the low byte
35220|Down one character row
35222|L=it
35223|A=the high byte
35224|Take back the 8
35226|H=it
35227|C=3 character rows
35229|B=8 pixel rows
35231|A=a graphic byte
35232|Mask the screen
35233|Store it
35234|Next graphic byte
35235|Down a pixel row
35236|Loop for 8 rows
35238|A=the low byte
35239|Down one character row
35241|L=it
35242|A=the high byte
35243|Take back the 8
35245|H=it
35246|One character row less
35247|Loop
35250|Return
35251|A=the figure's frame counter
35254|One tick less
35255|Store it
35258|Not time for a new frame
35259|A=6
35261|Reload the counter
35264|HL=the frame list position
35267|E=the next frame's address, low byte
35268|Next byte
35269|D=high byte
35270|Next byte
35271|Store the new position
35275|DE=the screen address (18838)
35278|HL=the frame, DE=the screen address
35279|Draw the frame
35282|A=0
35283|Return
35284|A=the frame counter
35287|Is it 6?
35289|B=2
35291|Yes: pause
35294|A=the frame counter
35297|Is it 3?
35299|B=2
35301|Yes: pause
35304|A=the frame counter
35307|Is it 5?
35309|Yes: draw a gun flash
35311|Is it 2?
35313|No: return
35314|HL=the flash list position
35317|E=the next flash address, low byte
35318|Next byte
35319|D=high byte
35320|Next byte
35321|Store the new position
35325|E=the screen address, low byte
35326|Next byte
35327|D=high byte
35328|HL=the flash graphic (39892)
35331|B=16 pixel rows
35333|A=a screen byte
35334|OR in the flash
35335|Draw it
35336|Next flash byte
35337|Next column
35338|A=the next screen byte
35339|OR in the flash
35340|Draw it
35341|Next flash byte
35342|Back a column
35343|Down a pixel row
35344|A=the high byte
35345|Crossed into the next character row?
35347|Yes: adjust
35349|Loop for 16 rows
35351|Return
35352|A=the low byte
35353|Down one character row
35355|E=the new low byte
35356|Carry: next third
35359|A=the high byte
35360|Take back the 8
35362|D=it
35363|Carry on
35366|A=the figure's counter
35369|One tick less
35370|Store it
35373|Not time for a new frame
35374|A=8
35376|Reload the counter
35379|A=the step counter
35382|One less
35383|Store it
35386|HL=the frame list position
35389|E=the next frame's address, low byte
35390|Next byte
35391|D=high byte
35392|Next byte
35393|Store the new position
35397|E=the frame's graphic address, low byte
35398|Next byte
35399|D=high byte
35400|HL=the screen address (17728)
35403|Draw the sprite (two cells wide)
'''
