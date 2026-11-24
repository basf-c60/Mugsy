"""Hand-written comments for the shootout (part 3: firing, bullets, hits, movement)."""
TXT = r'''
44190|Is the hit man's fire state 2?
44192|No: finish the firing sequence below
44194|IX=the hit man's record
44198|A=his state byte
44201|Which way is he facing?
44203|Left: use that branch
44205|Facing right: A=screen address low byte
44208|Column
44210|At column 28, the right wall?
44212|Yes: no bullet
44214|Fire the bullet
44216|Facing left: A=screen address low byte
44219|Column
44221|B=column
44222|A=the left limit
44225|Same column?
44226|Yes: no bullet
44228|IY=the hit man's bullet record (42570)
44232|B=13: the bullet starts 13 pixel rows down
44234|Position the bullet next to the gun
44237|A=15
44239|The bullet flies for 15 steps
44242|HL=the bullet's timer
44245|Make the bullet ready to move
44247|HL=the hit man's fire state
44250|Raise it to 3
44251|A=4
44253|Countdown 4
44256|Back to the dispatcher
44259|HL=the hit man's standing frame table (42234)
44262|Use it
44265|HL=frame buffer (23875)
44268|Use it
44271|A=8
44273|Countdown 8
44276|A=0
44277|Reset the fire state
44280|HL=his record
44283|Redraw him standing
44286|HL=42527
44289|Set the flag
44291|Back to the dispatcher
44294|Handler for slot 4 (Mugsy's bullet): was a bullet just cancelled?
44297|Test it
44298|No: carry on
44300|A=0
44301|Clear the flag
44304|HL=the bullet's timer
44307|Park it at 3
44309|Back to the dispatcher
44312|HL=the bullet's record (42531)
44315|Save it
44316|Copy it to the workspace
44319|HL=the bullet's remaining flight
44322|One step less
44323|Used up: remove it
44326|A=9
44328|Is this the first step?
44329|Yes: it has only just been drawn
44331|Copy its coordinates
44334|HL=screen address
44335|Move it a cell in its direction
44338|DE=new screen address
44339|Get the next route byte
44342|Test it
44343|Nothing in the way
44345|A=1
44347|The bullet has hit something: stop it next time
44350|Tell the hit tests that Mugsy's bullet has landed
44353|Store the new position
44357|Convert to an attribute address
44360|Store it
44364|DE=the record
44365|Copy the workspace back
44368|A=1
44370|Redraw the bullet at the next tick
44373|Back to the dispatcher
44376|Copy the coordinates
44379|HL=1000: off the screen
44382|Move the bullet off the screen
44385|And its attributes
44388|DE=the record
44389|Copy back
44392|A=1
44394|Redraw
44397|Flag the bullet as cancelled
44400|Back to the dispatcher
44403|A=the figure's state byte
44406|Which way is it moving?
44408|Left
44410|Moving right: A=the byte at DE
44411|Return
44412|Moving left: next byte
44413|A=the byte there
44414|Back to DE
44415|Return
44416|Handler for slot 5 (the hit man's bullet): was a bullet just cancelled?
44419|Test it
44420|No: carry on
44422|A=0
44423|Clear the flag
44426|HL=the bullet's timer
44429|Park it at 3
44431|Back to the dispatcher
44434|HL=the bullet's record (42570)
44437|Save it
44438|Copy it to the workspace
44441|HL=the bullet's remaining flight
44444|One step less
44445|Used up: remove it
44448|A=14
44450|Is this the first step?
44451|Yes
44453|Copy its coordinates
44456|HL=screen address
44457|Move it a cell
44460|DE=new address
44461|Get the next route byte
44464|Test it
44465|Nothing in the way
44467|A=1
44469|The bullet has hit something
44472|Tell the hit tests that the hit man's bullet has landed
44475|Store the new position
44479|Convert to an attribute address
44482|Store it
44486|DE=the record
44487|Copy back
44490|A=1
44492|Redraw at the next tick
44495|Back to the dispatcher
44498|Copy the coordinates
44501|HL=1000: off the screen
44504|Move the bullet off the screen
44507|And its attributes
44510|DE=the record
44511|Copy back
44514|A=1
44516|Redraw
44519|Flag the bullet as cancelled
44522|Back to the dispatcher
44525|L=the target's attribute address, low byte
44528|H=high byte
44531|DE=32: one row of attributes
44534|C=3: three rows to examine
44536|Save the row start
44537|B=4: four cells per row
44539|A=57: the attribute of a bullet
44541|Is this cell a bullet?
44542|Yes: it is in the target
44544|Next cell
44545|Loop for four cells
44547|Restore the row start
44548|Move down one row
44549|Count the rows
44550|Loop for three rows
44552|A=0: no bullet near the target
44553|Return
44554|A=1: a bullet is touching the target
44556|Tidy the stack
44557|Return
44558|Save the record address
44559|Save the animation length
44560|Save the graphic address
44561|Copy the record to the workspace
44564|Get the graphic address back
44565|Store it as the figure's frame pointer
44569|Copy the coordinates
44572|Get the animation length
44573|Store it
44576|Divide by 8...
44577|...by shifting right...
44578|...three times
44579|Store the number of cells
44582|HL=the screen address
44583|B=20: drop the figure 20 pixel rows
44585|Down one row
44586|Fix up the address across character boundaries
44589|Repeat 20 times
44591|Store the new screen address
44594|DE=the screen address
44595|Compute the pixel shift
44598|Convert to an attribute address
44601|Store it
44605|DE=the record
44606|Copy the workspace back
44609|Back to the dispatcher
44612|A=the figure's screen address, high byte
44615|Is it in the top part of the screen?
44617|No: use the default limit
44619|A=the screen address, low byte
44622|C=it
44623|Column bits
44625|D=column
44626|A=the full byte
44627|Row bits
44629|C=row bits
44630|Row 4 (128)?
44632|No
44634|A=column
44635|Column 4?
44637|No: default
44639|A=4: left limit
44641|HL=16512
44644|Store it
44646|A=row bits
44647|Row 5 (160)?
44649|No
44651|A=column
44652|Column below 3?
44654|Yes: default
44656|A=3: left limit
44658|HL=16544
44661|Store it
44663|A=row bits
44664|Row 6 (192)?
44666|No
44668|A=column
44669|Column below 2?
44671|Yes: default
44673|A=2: left limit
44675|HL=16576
44678|Store it
44680|A=row bits
44681|Row 7 (224)?
44683|No
44685|A=column
44686|Low two bits of the column
44688|Zero: default
44690|A=1: left limit
44692|HL=16608
44695|Store it
44697|A=row bits
44698|Row 0?
44700|No: default
44702|A=column
44703|Column 0?
44705|No: default
44707|A=0: left limit
44709|HL=18432
44712|Store it
44714|A=0: no left limit
44716|HL=16512: the top of the playing area
44719|Store the upper limit
44722|Store the left limit
44725|Return
44726|Save the record address
44727|Copy it to the workspace
44730|Copy the coordinates
44733|HL=the frame table
44736|Store it in the workspace
44739|Update the figure's position and animation
44742|Store the new screen address
44746|A=the state byte
44749|Facing left?
44751|Yes: erase and redraw leftwards
44753|Draw facing right
44756|Done
44758|Draw facing left
44761|DE=the record
44762|Copy the workspace back
44765|Return
44766|A=has Mugsy's bullet landed?
44769|Test it
44770|No: check the hit man's
44772|A=0
44773|Clear the flag
44776|IX=the hit man's record
44780|Is the bullet touching him?
44783|Test it
44784|No
44786|A=0
44787|HL=the hit man's hit points (42302)
44790|One hit
44791|Still alive
44793|Reset the counter (he has taken 4 hits)
44795|A=1: he is dead
44797|Record whether he is dead
44800|Carry on
44802|A=has the hit man's bullet landed?
44805|Test it
44806|No: finished
44808|A=0
44809|Clear the flag
44812|IX=Mugsy's record
44816|Is the bullet touching him?
44819|Test it
44820|No
44822|A=0
44823|HL=Mugsy's hit points (42301)
44826|One hit
44827|Still alive
44829|A=1: Mugsy is dead
44831|Record whether Mugsy is dead
44834|IX=bystander 1's record
44838|Is a bullet touching him?
44841|Record it
44844|IX=bystander 2's record
44848|Is a bullet touching him?
44851|Record it
44854|Test it
44855|No
44857|HL=bystander 2's timer
44860|A=his timer
44861|Is it 2?
44863|No
44865|Make him ready
44867|A=is bystander 1 hit?
44870|Test it
44871|No
44873|HL=his timer
44876|A=his timer
44877|Is it 2?
44879|No
44881|Make him ready
44883|Return
44884|A=has bystander 1 gone down?
44887|Test it
44888|Yes: look at bystander 2
44891|A=the "somebody is down" flag
44894|Test it
44895|Return if not
44896|HL=his script pointer
44899|Skip a byte
44900|Store it
44903|HL=his timer
44906|Make him ready
44908|Return
44909|A=has bystander 2 gone down?
44912|Test it
44913|Yes: look at the main figures
44916|A=the "somebody is down" flag
44919|Test it
44920|Return if not
44921|HL=his script pointer
44924|Skip a byte
44925|Store it
44928|HL=his timer
44931|Make him ready
44933|Return
44934|A=has Mugsy been killed?
44937|Test it
44938|No
44940|Set the "shootout over" flag
44943|Return
44944|A=has the hit man been killed?
44947|Test it
44948|No: return
44949|Set the "shootout over" flag
44952|Return
44953|Save the record address
44954|Save the direction code
44955|Copy the record to the workspace
44958|Copy the coordinates
44961|HL=the workspace
44964|Get the direction code back
44965|B=it
44966|Zero?
44967|Then keep the old direction
44969|Store the new one
44970|Next workspace byte (the animation delay)
44971|One tick less
44972|Not time to change frame
44974|A=the frame delay
44977|Reload it
44978|Move to the next frame of the animation
44981|Next workspace byte (the step counter)
44982|One tick less
44983|Not time to step
44985|A=the step delay
44988|Reload it
44989|Is there a gun flash to remove?
44992|Yes
44994|A=1
44996|Mark the figure as standing
44999|Carry on
45002|DE=screen address
45003|Step the figure
45006|Back
45007|Update the position
45010|Store the screen address
45014|Compute the pixel shift
45017|Convert to an attribute address
45020|Store it
45024|A=the state byte
45027|Facing left?
45029|Yes
45031|Draw it facing right
45034|Done
45036|Draw it facing left
45039|DE=the record
45040|Copy back
45043|Return
45044|Save DE
45045|Convert to an attribute address
45048|A=the state byte
45051|Facing left?
45053|Yes
45055|HL=96
45058|Carry on
45061|HL=95
45064|HL=the cell ahead
45065|A=58: furniture
45067|BC=4
45070|Look for it
45072|Found
45074|Keep looking
45077|Restore DE
45078|Return
45079|Save DE
45080|HL=the frame table position
45083|A=the state byte
45086|B=it
45087|Facing left?
45089|Yes
45091|A=the old state byte
45092|Facing left?
45094|Store the new state
45095|It was facing left
45097|Carry on
45099|A=the old state
45100|Facing left?
45102|Store the new state
45103|Same direction
45105|Next byte
45106|A=the frame count
45107|Back to the first byte
45108|Move to the next frame
45111|Skip a byte
45112|And another
45113|E=graphic address, low byte
45114|Next byte
45115|D=high byte
45116|Store the graphic address
45120|Restore DE
45121|Return
45122|Save HL
45123|A=frame counter
45126|HL=the frame table pointer
45129|One frame less
45130|None left: wrap round
45132|Next frame (4 bytes)
45133|...
45134|...
45135|...
45136|Store the pointer
45139|Carry on
45141|HL=the start of the table
45144|Store the pointer
45147|A=the number of frames
45150|Store the counter
45153|Restore HL
45154|Return
45155|HL=the figure's attribute address
45158|Store it
45161|DE=the figure's screen address
45165|Store it
45169|A=the pixel shift
45172|Store it
45175|A=the pixel width
45178|Store it
45181|Return
45182|A=the high byte of the screen address
45183|Pixel row within a character (0-7)
45185|B=it
45186|A=8
45188|A=8 minus the row
45189|Store the pixel shift
45192|B=it
45193|A=the figure's height in pixels
45196|A=height minus the shift
45197|Store it
45200|Return
45201|B=0
45203|A=255
45205|Keep it in A'
45206|A=32: 32 rows to copy
45208|HL=the figure's graphic
45211|DE=the frame buffer
45215|Get the row counter
45216|C=2: two bytes per row
45218|Copy a row of two bytes
45220|Loop for each byte
45223|Add a blank byte
45224|Next byte in the buffer
45225|Save the counter
45226|One row less
45227|Loop for 32 rows
45229|HL=the frame buffer
45232|The buffer is the graphic now
45235|A=the number of cells
45238|E=it
45239|A=the width in bytes
45242|C=it
45243|A=the pixel shift
45246|B=it
45247|A=4
45249|4 minus the shift
45250|Double it
45251|Nothing to shift
45253|Set the carry flag
45254|D=the shift count
45255|B=the width
45256|Save the row start
45257|Shift a byte right
45259|Next byte
45260|Repeat for the whole row
45262|Remember the position reached
45265|Restore the row start
45266|One shift less
45267|Repeat
45269|HL=the position reached
45272|One row less
45273|Repeat
45275|Return
45276|B=0
45278|A=255
45280|Keep it in A'
45281|A=32: 32 rows to copy
45283|HL=the figure's graphic
45286|DE=the frame buffer
45290|Get the row counter
45291|Start with a blank byte
45292|Next byte
45293|C=2: two bytes per row
45295|Copy a row of two bytes
45297|Loop for each byte
45300|Save the counter
45301|One row less
45302|Loop for 32 rows
45304|HL=the frame buffer
45307|The buffer is the graphic now
45310|Back one byte
45311|HL=the end of the buffer
45312|A=the number of cells
45315|E=it
45316|A=the width in bytes
45319|C=it
45320|A=the pixel shift
45323|B=it
45324|A=4
45326|4 minus the shift
45327|Double it
45328|Nothing to shift
45330|Set the carry flag
45331|D=the shift count
45332|B=the width
45333|Save the row end
45334|Shift a byte left
45336|Previous byte
45337|Repeat for the whole row
45339|Remember the position reached
45342|Restore the row end
45343|One shift less
45344|Repeat
45346|HL=the position reached
45349|One row less
45350|Repeat
45352|Return
45353|Save the record address
45354|Skip two bytes
45355|...
45356|E=the frame table address, low byte
45357|Next byte
45358|D=high byte
45359|HL=the frame table address
45360|C=the number of frames
45361|D=a byte of the frame table
45362|Rotate it right...
45364|...into A, bit by bit (reversing the bits)
45365|...
45367|...
45368|...
45370|...
45371|...
45373|...
45374|...
45376|...
45377|...
45379|...
45380|...
45382|...
45383|...
45385|...
45386|B=the reversed byte
45387|Next byte
45388|D=the next byte
45389|Rotate it right...
45391|...into A
45392|...
45394|...
45395|...
45397|...
45398|...
45400|...
45401|...
45403|...
45404|...
45406|...
45407|...
45409|...
45410|...
45412|...
45413|Store the second byte
45414|Back one byte
45415|Store the first
45416|Forward
45417|And on to the next pair
45418|One frame less
45419|Loop for every frame
45421|Restore the record address
45422|Return
45423|A=the figure's screen address, low byte
45424|Column bits
45426|E=the column
45427|A=the low byte again
45428|Row bits
45430|D=the row
45431|A=the direction code
45434|Right?
45436|No
45438|A=28: the right-hand column limit
45440|Is the figure there?
45441|No
45443|A=1
45445|Stop the figure
45448|Report that it could not move
45451|Return
45452|Move one column right
45453|Return
45454|Left?
45456|No
45458|A=the left limit
45461|Is the figure there?
45462|No
45464|A=1
45466|Stop the figure
45469|Report that it could not move
45472|Return
45473|Move one column left
45474|Return
45475|Up?
45477|No
45479|Save the address
45480|Save the row
45481|L=the row
45482|DE=the upper limit
45486|Clear the carry flag
45487|Compare with the limit
45489|Restore the row
45490|Restore the address
45491|Not at the limit
45493|At the top: no move
45494|Up a pixel row
45495|Fix up across character boundaries
45498|Up another
45499|Fix up
45502|Up another
45503|Fix up
45506|Up another
45507|Fix up
45510|Return
45511|Down?
45513|No
45515|Save the address
45516|Save the row
45517|L=the row
45518|DE=the row
45519|HL=the lower limit (20576)
45522|Clear the carry flag
45523|Compare
45525|Restore the row
45526|Restore the address
45527|Not at the limit
45529|At the bottom: no move
45530|Down a pixel row
45531|Fix up across character boundaries
45534|Down another
45535|Fix up
45538|Down another
45539|Fix up
45542|Down another
45543|Fix up
45546|Return
45547|Up and left?
45549|No
45551|A=0
45552|Clear the "could not move" flag
45555|Move left
45558|A=the flag
45561|Test it
45562|Could not move: return
45563|Move up
45566|Return
45567|Up and right?
45569|No
45571|A=0
45572|Clear the flag
45575|Move right
45578|A=the flag
45581|Test it
45582|Could not move: return
45583|Move up
45586|Return
45587|Down and left?
45589|No
45591|A=0
45592|Clear the flag
45595|Move left
45598|A=the flag
45601|Test it
45602|Could not move: return
45603|Move down
45606|Return
45607|Down and right?
45609|No: return
45610|A=0
45611|Clear the flag
45614|Move right
45617|A=the flag
45620|Test it
45621|Could not move: return
45622|Move down
45625|Return
45626|A=the high byte of the display address
45627|Which third of the screen (0-2)?
45629|Divide by 8...
45630|...to...
45631|...get it into bits 0-1
45632|Add the base of the attribute file (88*256=22528)
45634|D=the high byte of the attribute address
45635|Return
45636|A=the high byte
45637|Invert it
45638|Pixel row within a character (inverted)
45640|Return if not at the top of a character
45641|A=the low byte
45642|Up one character row
45644|L=it
45645|Return if that did not cross a third
45646|A=the high byte
45647|Up one third
45649|H=it
45650|Return
45651|A=the high byte
45652|Pixel row within a character
45654|Return if still inside a character
45655|A=32
45657|Down one character row
45658|L=it
45659|Return if that did not cross a third
45660|A=the high byte
45661|Down one third
45663|H=it
45664|Return
45665|HL=the start of the display file
45668|DE=the next byte
45671|BC=6143
45674|A=0
45675|Clear the first byte
45676|Clear the rest of the pixels
45678|HL=the start of the attributes
45681|DE=the next byte
45684|BC=767
45687|A=56: white paper, black ink
45689|Set the first attribute
45690|Set the rest of the attributes
45692|Return
45693|DE=the workspace (42336)
45696|BC=39 bytes
45699|Copy the record into the workspace
45701|Return
45702|HL=the workspace (42336)
45705|BC=39 bytes
45708|Copy it back into the record
45710|Return
'''
