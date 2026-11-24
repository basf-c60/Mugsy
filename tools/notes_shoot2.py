"""Hand-written comments for the shootout (part 2: dispatcher and the figure handlers)."""
TXT = r'''
42977|A=0
42978|Clear the "somebody is down" flag for this pass of the loop
42981|A=number of figure slots in use (7 while the furniture is drawn, then 6)
42984|B=the slot count
42985|C=0: the slot number
42987|HL=the slot timers (42250...)
42990|A=1: a timer of 1 means the figure is ready for new orders
42992|Is this slot's timer 1?
42993|No: leave this figure alone for now
42995|Save the loop counter and slot number
42996|Save the timer pointer
42997|B=0
42999|C=slot number*2: the offset into the handler table
43001|HL=handler table (42238)
43004|Point at this slot's entry
43005|E=low byte of the handler address
43006|Next byte
43007|D=high byte
43008|HL=handler address
43009|Run the handler (it ends with JP 43010)
43010|Restore the timer pointer
43011|Restore the loop counter and slot number
43012|Timer 1 becomes 0: the interrupt routine now counts this figure's next move down
43013|Next slot's timer
43014|Next slot number
43015|Loop for all slots
43017|Return
43018|Handler for slot 0 (bystander 1): A=has he already gone down or left?
43021|Test it
43022|No: carry on
43024|HL=his timer
43027|Park the timer at 3 so he is never serviced again
43029|Back to the dispatcher
43032|A=has a bullet hit him?
43035|Test it
43036|Yes: make him fall over
43038|HL=his script pointer
43041|A=the next script byte
43042|254: end of the script
43044|Handle that below
43047|255: hand over to the hit man
43049|Handle that below
43051|80: stand still for a long time
43053|Handle that below
43055|81: stand still for one tick
43057|Handle that below
43059|82: stand still for a very long time
43061|Handle that below
43063|0: a plain animation step
43065|Handle that with the moves
43067|Keep only the bits that are not 1 or 16
43069|A real direction code: make the move
43071|Anything else (1, 16 or 17) is ignored this time
43074|HL=the result byte (42334)
43077|Set bit 2: bystander 1 has been hit
43079|Remember that he is down (A is non-zero)
43082|A=30
43084|He lies there for 30 ticks before his countdown ends
43087|A=8: the falling animation length
43089|BC=48250: the falling-over graphic
43092|HL=his record (42375)
43095|Set up the falling animation
43098|Save the script pointer
43099|A=4
43101|Four animation frames in the cycle
43104|A=3
43105|The frame delay is 3
43108|A=2
43109|His countdown is 2 ticks
43112|HL=the walking frame table (42174)
43115|Use it
43118|HL=23575: the frame buffer for this figure
43121|Use it
43124|A=0
43125|Reset the left limit
43128|Get the script pointer back
43129|A=the direction code from the script
43130|Move the pointer on
43131|Store the new script pointer
43134|HL=his record
43137|Move him and redraw
43140|Back to the dispatcher
43143|80: swap pointer and frame table
43144|HL=standing frame table (42190)
43147|A=25: stand for 25 ticks
43149|Carry on
43152|81: swap pointer and frame table
43153|HL=walking frame table (42174)
43156|A=1: one tick
43158|Carry on
43161|82: swap pointer and frame table
43162|HL=walking frame table
43165|A=128: a long wait
43167|Carry on
43170|255: HL=his timer
43173|Park him at 3
43175|Move to the next timer
43176|And the next
43177|And the hit man's timer
43178|Make the hit man ready for orders
43180|Back to the dispatcher
43183|254: HL=his record
43186|Save it
43187|Copy it to the workspace
43190|Copy his coordinates
43193|HL=1000: off the screen
43196|Move him off the screen
43199|And his attribute address
43202|DE=the record
43203|Copy the workspace back
43206|A=1
43208|He is gone
43211|His countdown is 1
43214|Set the "shootout over" flag
43217|Back to the dispatcher
43220|Point past the script byte
43221|Store the new script pointer
43225|Set the countdown
43228|Set the frame table
43231|HL=frame buffer
43234|Use it
43237|HL=his record
43240|Redraw him
43243|Back to the dispatcher
43246|Handler for slot 1 (bystander 2): has he gone down?
43249|Test it
43250|No: carry on
43252|HL=his timer
43255|Park it
43257|Back to the dispatcher
43260|Has a bullet hit him?
43263|Test it
43264|Yes: make him fall over
43266|HL=his script pointer
43269|A=the next script byte
43270|254: end of script
43272|Handle that below
43275|255: hand over
43277|Handle that below
43279|80: stand still for a long time
43281|Handle that below
43283|81: stand still for one tick
43285|Handle that below
43287|82: stand still for a while
43289|Handle that below
43291|0: plain step
43293|Handle that with the moves
43295|Keep only the bits that are not 1 or 16
43297|A real direction code: move
43299|Ignore 1, 16 and 17
43302|HL=the result byte
43305|Set bit 3: bystander 2 has been hit
43307|Remember he is down
43310|A=30
43312|His countdown is 30
43315|A=16: the falling animation length
43317|BC=48154: the falling-over graphic
43320|HL=his record (42414)
43323|Set up the falling animation
43326|Save the script pointer
43327|A=2
43329|Two animation frames in the cycle
43332|Frame delay 2
43335|A=3
43336|Countdown 3
43339|HL=his walking frame table (42194)
43342|Use it
43345|HL=frame buffer (23675)
43348|Use it
43351|A=0
43352|Reset the left limit
43355|Get the script pointer back
43356|A=the direction code
43357|Advance the pointer
43358|Store it
43361|HL=his record
43364|Move him and redraw
43367|Back to the dispatcher
43370|80: swap
43371|HL=standing frame table (42202)
43374|A=25
43376|Carry on
43379|81: swap
43380|HL=walking frame table (42194)
43383|A=1
43385|Carry on
43388|82: swap
43389|HL=walking frame table
43392|A=100: wait
43394|Carry on
43397|255: HL=his timer
43400|Park it
43402|Next timer
43403|Make slot 2 (Mugsy) ready
43405|Back to the dispatcher
43408|254: HL=his record
43411|Save it
43412|Copy to workspace
43415|Copy coordinates
43418|HL=1000: off screen
43421|Move him off the screen
43424|And his attributes
43427|DE=the record
43428|Copy back
43431|A=1
43433|He is gone
43436|Countdown 1
43439|Set the "shootout over" flag
43442|Back to the dispatcher
43445|Point past the script byte
43446|Store the pointer
43450|Set the countdown
43453|Set the frame table
43456|HL=frame buffer
43459|Use it
43462|HL=his record
43465|Redraw him
43468|Back to the dispatcher
43471|Handler for slot 2 (Mugsy): is he dead?
43474|Test it
43475|No: carry on
43477|HL=his timer
43480|Park it at 3
43482|A=the "somebody is down" flag
43485|Test it
43486|Already set: skip
43488|A=1
43490|Tell the other figures that a gunfight has ended
43493|IX=his record (42453)
43497|HL=18576: where he lies
43500|Put him there (low byte)
43503|And the high byte
43506|Back to the dispatcher
43509|Has the hit man's bullet used up his hit points?
43512|Test it
43513|Yes: he dies
43515|A=is Mugsy's gun being fired (his fire state)?
43518|Test it
43519|Yes: continue the firing sequence
43522|A=the direction code from the keyboard
43525|B=the code
43526|10 means fire
43528|Start firing
43530|0 means no key pressed
43532|Stand still
43534|Keep only the bits that are not 1 or 16
43536|A real direction: move
43538|Otherwise do nothing
43541|HL=the result byte
43544|Set bit 0: Mugsy has been killed
43546|Remember he is dead
43549|A=30
43551|His countdown is 30
43554|A=16: the falling animation length
43556|BC=48106: the falling-over graphic
43559|HL=his record (42453)
43562|Set up the falling animation
43565|A=2
43567|Mugsy's animation has two frames
43570|Countdown 2
43573|A=4
43575|Frame delay 4
43578|HL=Mugsy's walking frame table (42206)
43581|Use it
43584|DE=frame buffer (23775)
43587|Use it
43591|IX=his record
43595|Work out the limits of his movement
43598|HL=his record
43601|A=the direction code
43602|Move him
43605|Back to the dispatcher
43608|He is firing: HL=his fire state
43611|Raise it to 1
43612|And to 2
43613|HL=Mugsy's firing frame table (42214)
43616|Use it
43619|HL=frame buffer (23775)
43622|Use it
43625|A=5
43627|Countdown 5
43630|HL=his record
43633|Draw the gun being raised
43636|Back to the dispatcher
43639|Is the fire state 2?
43641|No: end of the firing sequence
43644|IX=Mugsy's record
43648|A=his state byte
43651|Which way is he facing (bits 5-7)?
43653|Facing left: use that branch
43655|A=his screen address, low byte
43658|Column
43660|Is he at column 28, the right wall?
43662|Yes: no room for a bullet
43664|Fire the bullet
43666|Facing left: A=screen address low byte
43669|Column
43671|B=column
43672|A=the left limit
43675|Same column?
43676|Yes: no room for a bullet
43678|IY=the bullet's record (42531)
43682|B=11: the bullet starts 11 pixel rows down
43684|Position the bullet next to the gun
43687|A=10
43689|The bullet flies for 10 steps
43692|HL=the bullet's timer
43695|Make the bullet ready to move
43697|HL=fire state
43700|Raise it to 3
43701|A=5
43703|Countdown 5
43706|Back to the dispatcher
43709|A=the owner's state byte
43712|Give the bullet the same facing
43715|L=the owner's screen address, low byte
43718|H=high byte
43721|Move down one pixel row...
43722|(using this subroutine)
43725|...B times
43727|A=the bullet's state
43730|Which way?
43732|Left: handle that
43734|Facing right: move the bullet two cells right of the gun
43735|Another one
43736|A=4: right
43738|Set the bullet's direction
43741|Carry on
43743|Facing left: one cell to the left
43744|A=64: left
43746|Set the direction
43749|Set the bullet's screen address
43752|And high byte
43755|DE=screen address
43756|Convert to an attribute address
43759|Store it
43762|And high byte
43765|A=0
43766|Clear some counters
43769|And another
43772|And another
43775|And another
43778|Return
43779|HL=Mugsy's standing frame table (42218)
43782|Use it
43785|HL=frame buffer (23775)
43788|Use it
43791|A=6
43793|Countdown 6
43796|A=0
43797|Reset the fire state
43800|HL=his record
43803|Redraw him standing
43806|HL=42488
43809|Set the flag
43811|Back to the dispatcher
43814|Handler for slot 3 (the hit man): has Mugsy's bullet used up his hit points?
43817|Test it
43818|No: carry on
43820|HL=his timer
43823|Park it at 3
43825|A=the "somebody is down" flag
43828|Test it
43829|Already set: skip
43831|A=1
43833|Set it
43836|Back to the dispatcher
43839|Has Mugsy's bullet used up the hit man's hit points?
43842|Test it
43843|Yes: he dies
43845|A=the hit man's fire state
43848|Test it
43849|Yes: continue the firing sequence
43852|HL=his script pointer
43855|A=the next script byte
43856|255: end of the fragment
43858|Choose a new one
43860|10: fire
43862|Fire
43864|0: standing step
43866|Do that
43868|Keep only the bits that are not 1 or 16
43870|A real direction: move
43872|Ignore the rest
43875|HL=the result byte
43878|Set bit 1: the hit man has been killed
43880|Remember he is dead
43883|A=30
43885|His countdown is 30
43888|A=16: the falling animation length
43890|BC=48202: the falling-over graphic
43893|HL=his record (42492)
43896|Set up the falling animation
43899|Save the script pointer
43900|A=2
43902|Two frames in the cycle
43905|Frame delay 2
43908|Countdown 2
43911|HL=the hit man's walking frame table (42222)
43914|Use it
43917|HL=frame buffer (23875)
43920|Use it
43923|Get the pointer back
43924|A=the direction code
43925|Advance the pointer
43926|Store it
43929|HL=his record
43932|Move him
43935|Back to the dispatcher
43938|Fire: skip the script byte
43939|Store the pointer
43942|HL=his fire state
43945|Raise it to 1
43946|And to 2
43947|HL=the hit man's firing frame table (42230)
43950|Use it
43953|HL=frame buffer (23875)
43956|Use it
43959|IX=his record
43963|A=8
43965|Countdown 8
43968|HL=his record
43971|Draw the gun being raised
43974|Back to the dispatcher
43977|End of the fragment: work out where Mugsy is
43978|B=0
43979|C=0: the direction bits
43980|IX=Mugsy's record
43984|IY=the hit man's record
43988|A=Mugsy's column (low byte)
43991|Keep the column bits
43993|L=Mugsy's column
43994|A=the hit man's address low byte
43997|Column bits
43999|H=the hit man's column
44000|A=Mugsy's address high byte
44003|Which third of the screen?
44005|E=Mugsy's third
44006|A=the hit man's address high byte
44009|Which third?
44011|D=the hit man's third
44012|A=the hit man's column
44013|Compare with Mugsy's
44014|Hit man is to the left
44016|Bit 2: hit man at or right of Mugsy
44018|Carry on
44021|Bit 3: hit man left of Mugsy
44023|A=the hit man's third
44024|Compare with Mugsy's
44025|Same third
44027|Hit man is higher
44029|Bit 0: hit man is lower
44031|Choose a fragment
44034|Bit 1: hit man is higher
44036|Choose a fragment
44039|Same third: A=Mugsy's row bits
44042|Row within the third
44044|L=it
44045|A=the hit man's row bits
44048|Row within the third
44050|Compare
44051|Hit man is higher
44053|Bit 0: hit man is lower
44055|Carry on
44058|Bit 1: hit man is higher
44060|Difference in rows
44061|Different rows: choose a fragment
44063|Same row: is Mugsy already dead?
44066|Test it
44067|Yes: just move
44069|Same row and Mugsy alive: clear bit 0
44071|And bit 1
44073|B=10: fire
44075|Is there furniture beside the hit man?
44078|No: carry on
44080|A=12
44082|Flip the horizontal bits: go the other way
44083|C=the new direction bits
44084|B=0: do not fire
44086|A=the direction bits
44087|Right (4)?
44089|No
44091|Fragment 47042
44094|Use it
44097|Left (8)?
44099|No
44101|Fragment 47034
44104|Use it
44107|Right and lower (5)?
44109|No
44111|Fragment 47058
44114|Use it
44116|Left and higher (6)?
44118|No
44120|Fragment 47074
44123|Use it
44125|Left and lower (9)?
44127|No
44129|Fragment 47050
44132|Use it
44134|Otherwise fragment 47066
44137|Store the new script pointer
44140|Skip two bytes
44141|Poke B (fire or not) into the fragment
44142|Next byte
44143|Poke it again
44145|HL=his timer
44148|Wait two ticks
44150|Back to the dispatcher
44153|Save BC
44154|E=the figure's attribute address, low byte
44157|D=high byte
44160|A=the figure's state byte
44163|Which way is he facing?
44165|Left: use the left offset
44167|Facing right: look 96 bytes ahead
44170|Carry on
44172|Facing left: look 95 bytes ahead
44175|HL=the attribute cell to inspect
44176|A=58: the attribute of a piece of furniture
44178|BC=4: look at four cells
44181|Compare A with a cell
44183|Found: stop
44185|Keep looking
44188|Restore BC
44189|Return (zero flag set if there is furniture)
'''
