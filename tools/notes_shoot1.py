"""Hand-written comments for the shootout (part 1: entry, setup, dispatcher, figure handlers)."""
TXT = r'''
42112|Interrupts off while the IM2 handler is installed
42113|Save the strength value passed in A (it is needed again below)
42114|HL=address of the shootout's interrupt routine
42117|Patch it into the JP at 53457 that the IM2 vector table (53504) leads to
42120|A=209: the high byte of the vector table address, which is filled with 208
42122|Set the interrupt vector register: IM 2 interrupts now vector through 53504
42124|Select interrupt mode 2
42126|A=0: black border, speaker off
42128|Set the border colour and speaker
42130|Get the strength value back
42131|Keep the low 3 bits (0-7)
42133|Add 1 to make 1-8
42134|Store it as Mugsy's hit points (the hit man's bullets take one off each time they hit him)
42137|Draw the restaurant and put the figures in place
42140|Main loop: let any figure whose timer says it is ready decide what to do next
42143|Deal with Mugsy's and the hit man's bullets landing
42146|Deal with anyone who has been hit
42149|A=the "shootout over" flag (set when Mugsy or the hit man has fallen over)
42152|Test it
42153|Keep going until it is set
42155|BC=65535: a pause of about a second and a half so the player can see the result
42158|Count BC down
42159|A=B
42160|Combine with C to test for zero
42161|Loop until BC is zero
42163|A=63: the high byte of the ROM's interrupt table address
42165|Put the interrupt vector register back as the ROM expects it
42167|Back to interrupt mode 1
42169|A=the result bits (bit 0 Mugsy killed, bit 1 hit man killed, bit 2 bystander 1 hit, bit 3 bystander 2 hit)
42172|Leave with interrupts disabled (the caller restores the ROM's FLAGS)
42173|Return to the VM's native-call routine
42639|Clear the screen and draw the walls, door and window
42642|HL=start of the flag area (42303-42335)
42645|B=33 bytes to clear
42647|A=0
42648|Clear a flag
42649|Move on
42650|Loop for all 33 bytes
42652|HL=the figure timers (one byte per figure, from 42250)
42655|B=7 timers
42657|Set a timer to 3: "idle" (1 means ready for orders, 0 means a countdown is running)
42659|Next timer
42660|Loop for all seven
42662|BC=405
42665|HL=24575, the top of a work area below the code
42668|DE=24574
42671|A=0
42672|Clear the first byte of the work area
42673|Clear 405 more, working backwards (24170-24575): the sprite frame buffers are cleaned out
42675|BC=60
42678|HL=24115
42681|DE=24114
42684|A=56: white paper, black ink
42686|Store the first attribute
42687|Fill 60 attribute bytes (24055-24115) with white paper
42689|A=has the walls graphic been inverted already? (42300)
42692|Test it
42693|Skip the inversion if it has
42695|A=1
42697|Mark the sprite data as inverted (it is stored inverted in the file and flipped once, on first use)
42700|HL=start of the sprite data (47082)
42703|BC=1326 bytes
42706|Fetch a byte of sprite data
42707|Invert it
42708|Store it back
42709|Next byte
42710|Count down
42711|A=C
42712|Combine with B
42713|Loop until all 1326 bytes are done
42715|A=7
42717|Seven figure slots to service while the furniture is drawn (the seventh draws furniture)
42720|A=1
42722|Make the furniture slot's timer expire at once
42725|HL=first furniture descriptor (45711)
42728|Load it into the furniture slot's record
42731|Wait for the interrupt routine to draw it
42734|HL=screen address of the next piece
42737|DE=its attribute address
42740|Request a redraw and wait
42743|HL=screen address
42746|DE=attribute address
42749|Request a redraw and wait
42752|HL=screen address
42755|DE=attribute address
42758|Request a redraw and wait
42761|A=1
42763|Re-arm the furniture slot's timer
42766|HL=second furniture descriptor (45721)
42769|Load it into the furniture slot's record
42772|Wait for the interrupt routine to draw it
42775|HL=screen address of a copy
42778|DE=its attribute address
42781|Redraw and wait
42784|HL=screen address
42787|DE=attribute address
42790|Redraw and wait
42793|HL=screen address
42796|DE=attribute address
42799|Redraw and wait
42802|HL=address of the third furniture graphic (48354)
42805|Patch it into the furniture slot's record
42808|HL=screen address
42811|DE=attribute address
42814|Redraw and wait
42817|HL=screen address
42820|DE=attribute address
42823|Redraw and wait
42826|HL=screen address
42829|DE=attribute address
42832|Redraw and wait
42835|HL=initial records of the six real figures (45731)
42838|DE=the first figure's record (42375)
42841|BC=234 bytes (6 records of 39)
42844|Copy the figure records into place
42846|A=6
42848|From now on only six slots are serviced (the furniture slot is retired)
42851|HL=23875: a sprite frame buffer
42854|Use it for the next figure drawn
42857|HL=42492: the hit man's record
42860|Save it
42861|Copy the record into the workspace
42864|Work out where to draw him
42867|Draw him
42870|DE=the record again
42871|Copy the workspace back into the record
42874|HL=42253: the timer for figure 3 (the hit man)
42877|Set it to 0: his countdown starts running
42879|A=1
42881|The hit man waits one tick before first acting
42884|Enable interrupts
42885|Let one interrupt happen
42886|Disable interrupts again
42887|HL=42527: the hit man's record, byte +35
42890|Set it to 1
42892|HL=42253 (the hit man's timer)
42895|Set it to 3: idle
42897|HL=42250: the timers again
42900|Set the first timer to 1: bystander 1 may act at once
42902|Next timer
42903|Set the second timer to 1: bystander 2 may act at once
42905|HL=bystander 1's route script (46645)
42908|Store it as that figure's script pointer
42911|HL=bystander 2's route script (46825)
42914|Store it
42917|HL=the hit man's route script (47058)
42920|Store it
42923|HL=16512: the top row of the playing area on the screen
42926|Store it as the upper limit for Mugsy and the hit man
42929|Enable interrupts: the shootout is live
42930|Return
42931|HL=the furniture slot's timer
42934|Set it to 0 so that the interrupt routine runs its countdown
42936|Enable interrupts
42937|Wait for the next interrupt
42938|Disable interrupts
42939|Return
42940|DE=where the furniture slot keeps its first six data bytes (42623)
42943|BC=6 bytes
42946|Copy the screen position and graphic data
42948|DE=where it keeps the attribute data (42635)
42951|BC=4 bytes
42954|Copy them
42956|Return
42957|A=1
42959|Re-arm the furniture slot's timer
42962|Store the screen address
42965|Store the attribute address
42969|Return
42970|Set the new position
42973|Let the interrupt routine draw it
42976|Return
'''
