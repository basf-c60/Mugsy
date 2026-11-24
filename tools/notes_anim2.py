"""Hand-written comments for the bar-room animation (36366-37100)."""
TXT = r'''
36366|A=0
36367|Black border
36369|A=0
36370|Figure 1 starts in its first state
36373|Figure 6 starts in its first state
36376|Figure 5 starts in its first state
36379|Figure 7 starts in its first state (bit 7 clear: it may move)
36382|A=128
36384|Figure 8 starts out of action (bit 7 set)
36387|A=1: every counter starts at 1, so each figure moves on the first tick
36389|Counter for the hoods' route
36392|Counter for figure 1
36395|Counter for figure 5
36398|Counter for figure 6
36401|Counter for figure 7
36404|Counter for figure 8
36407|Counter for figure 2
36410|Counter for figure 3
36413|Counter for figure 4
36416|HL=the first entry of the hoods' route table
36419|Store it as the route pointer
36422|A=1
36424|Counter for the hoods walking through the club
36427|HL=the first frame of the walking hoods
36430|Store it as the frame pointer
36433|HL=the first frame of figure 1
36436|Store it
36439|HL=the first frame of figure 5
36442|Store it
36445|HL=the first frame of figure 6
36448|Store it
36451|HL=the first frame of figure 7
36454|Store it
36457|HL=the first frame of figure 8
36460|Store it
36463|HL=the compressed picture of the Partridge Club
36466|Draw it
36469|DE=figure 8's frame pointer
36473|Skip the link to the next frame...
36474|...to the sprite
36475|Draw figure 8 for the first time
36478|HL=500
36481|The first pause lasts 500 ticks
36484|A=0: the step is complete
36485|Return
36486|A=1
36488|Mark the animation as finished
36491|A=0
36492|Return (zero flag set: the step is complete)
36495|Animate all the figures
36498|HL=the pause counter
36501|One tick less
36502|Store it
36505|A=H
36506|Combine with L to test for zero
36507|Return (Z set when the pause is over)
36508|Animate all the figures
36511|Advance the hoods along their route
36514|Return until the route entry is finished
36515|HL=the next route (41200)
36518|Use it
36521|A=1
36523|Make the route routine fetch its first entry at once
36526|Return
36527|Animate figure 1
36530|Advance the hoods along their route
36533|Return until the route entry is finished
36534|HL=the next route (41221)
36537|Use it
36540|A=1
36542|Fetch the first entry at once
36545|Return
36546|Animate figure 1
36549|Advance the hoods along their route
36552|Not finished: draw the walking hoods
36554|HL=the next route (41237)
36557|Use it
36560|A=1
36562|Fetch the first entry at once
36565|Return
36566|Animate figure 1
36569|Animate the hoods walking
36572|Animate figure 1
36575|Advance the hoods along their route
36578|Return until the route is finished
36579|HL=400
36582|Pause for 400 ticks
36585|Return
36586|Animate figure 1
36589|Animate figure 2
36592|Animate figure 3
36595|Animate figure 4
36598|Animate figure 5
36601|Animate figure 6
36604|Animate figure 7
36607|Animate figure 8 and return
36610|A=the range
36611|A=a random number from 0 to C
36614|Add the minimum
36615|Return
36617|A=the counter
36620|One tick less
36621|Store it
36624|Not time for a new frame
36625|HL=the position in the walking hoods' list
36628|A=the number of ticks this frame lasts
36629|Test it
36630|Zero marks the end of the list: stop
36631|Next byte
36632|Store it as the new counter
36635|Is the delay 2?
36637|B=1
36639|Save the list position
36640|If so, wait a moment (a step sound)
36643|Restore the list position
36644|E=the low byte of the record address
36645|Next byte
36646|D=the high byte
36647|Next byte
36648|Store the new list position
36651|HL=the record: the screen address then the sprite
36652|E=the screen address, low byte
36653|Next byte
36654|D=high byte
36655|Next byte
36656|HL=the screen address, DE=the sprite
36657|Draw the three-cell-wide sprite
36660|Clear the zero flag: the step is not complete
36662|Return
36664|A=the counter
36667|One tick less
36668|Store it
36671|Not time for a new entry
36672|HL=the route pointer
36675|A=the number of ticks this entry lasts
36676|Test it
36677|Zero marks the end of the route
36678|Next byte
36679|Store it as the new counter
36682|E=the screen address, low byte
36683|Next byte
36684|D=high byte
36685|Next byte
36686|Save the screen address
36687|E=the sprite address, low byte
36688|Next byte
36689|D=high byte
36690|Next byte
36691|Store the new route pointer
36694|HL=the screen address
36695|Draw the two-cell-wide sprite
36698|Clear the zero flag: the route is not finished
36700|Return
36703|A=figure 1's counter
36706|One tick less
36707|Store it
36710|Not time to change yet
36711|A=figure 1's state
36714|Flip it
36716|Store it
36719|BC=the long delay range (minimum 60, up to 40 more ticks)
36722|State 0: use the long delay
36724|BC=the short delay range (minimum 10, up to 20 more ticks)
36727|A=a random delay
36730|Set the counter
36733|HL=figure 1's frame pointer
36736|E=the next frame's address, low byte
36737|Next byte
36738|D=high byte
36739|Next byte
36740|Store the pointer to the next frame
36744|DE=the sprite
36745|HL=figure 1's screen address
36748|Draw the sprite
36752|A=figure 2's counter
36755|One tick less
36756|Store it
36759|Not time to change yet
36760|BC=the delay range (minimum 10, up to 4 more)
36763|A=a random delay
36766|Set the counter
36769|HL=figure 2's frame pointer
36772|E=the next frame's address, low byte
36773|Next byte
36774|D=high byte
36775|Next byte
36776|Store the pointer to the next frame
36780|DE=the sprite
36781|HL=figure 2's screen address
36784|Draw the sprite
36788|A=figure 3's counter
36791|One tick less
36792|Store it
36795|Not time to change yet
36796|BC=the delay range (minimum 14, up to 4 more)
36799|A=a random delay
36802|Set the counter
36805|HL=figure 3's frame pointer
36808|E=the next frame's address, low byte
36809|Next byte
36810|D=high byte
36811|Next byte
36812|Store the pointer to the next frame
36816|DE=the sprite
36817|HL=figure 3's screen address
36820|Draw the sprite
36824|A=figure 4's counter
36827|One tick less
36828|Store it
36831|Not time to change yet
36832|BC=the delay range (minimum 8, up to 4 more)
36835|A=a random delay
36838|Set the counter
36841|HL=figure 4's frame pointer
36844|E=the next frame's address, low byte
36845|Next byte
36846|D=high byte
36847|Next byte
36848|Store the pointer to the next frame
36852|DE=the sprite
36853|HL=figure 4's screen address
36856|Draw the sprite
36861|A=figure 5's counter
36864|One tick less
36865|Store it
36868|Not time to change yet
36869|A=figure 5's state
36872|Flip it
36874|Store it
36877|BC=the long delay range (minimum 100, up to 50 more)
36880|State 0: use the long delay
36882|BC=the short delay range (minimum 40, up to 30 more)
36885|A=a random delay
36888|Set the counter
36891|HL=figure 5's frame pointer
36894|E=the next frame's address, low byte
36895|Next byte
36896|D=high byte
36897|Next byte
36898|Store the pointer to the next frame
36902|DE=the sprite
36903|HL=figure 5's screen address
36906|Draw the three-cell-wide sprite
36911|A=figure 6's counter
36914|One tick less
36915|Store it
36918|Not time to change yet
36919|A=figure 6's state
36922|Flip it
36924|Store it
36927|BC=the long delay range (minimum 30, up to 20 more)
36930|State 0: use the long delay
36932|BC=the short delay range (minimum 20, up to 10 more)
36935|A=a random delay
36938|Set the counter
36941|HL=figure 6's frame pointer
36944|E=the next frame's address, low byte
36945|Next byte
36946|D=high byte
36947|Next byte
36948|Store the pointer to the next frame
36952|DE=the sprite
36953|HL=figure 6's screen address
36956|Draw the three-cell-wide sprite
36961|A=figure 7's state
36964|Is bit 7 set (figure 7 is out of action while figure 8 is active)?
36966|Yes: nothing to do
36967|A=figure 7's counter
36970|One tick less
36971|Store it
36974|Not time to change yet
36975|A=figure 7's state
36978|Flip bit 0
36980|Store it
36983|Bit 0 is set: keep this figure active
36985|Set bit 7: it hands over to figure 8
36987|Store it
36990|A=figure 8's state
36993|Clear bit 7: figure 8 becomes active
36995|Store it
36998|BC=the long delay range (minimum 80, up to 30 more)
37001|Zero: use the long delay
37003|BC=the short delay range (minimum 20, up to 20 more)
37006|A=a random delay
37009|Set the counter
37012|HL=figure 7's frame pointer
37015|E=the next frame's address, low byte
37016|Next byte
37017|D=high byte
37018|Next byte
37019|Store the pointer to the next frame
37023|DE=the sprite
37024|HL=figure 7's screen address
37027|Draw the three-cell-wide sprite
37032|A=figure 8's state
37035|Is bit 7 set (figure 8 is out of action while figure 7 is active)?
37037|Yes: nothing to do
37038|A=figure 8's counter
37041|One tick less
37042|Store it
37045|Not time to change yet
37046|A=figure 8's state
37049|Flip bit 0
37051|Store it
37054|Bit 0 is set: keep this figure active
37056|Set bit 7: hand over to figure 7
37058|Store it
37061|A=figure 7's state
37064|Clear bit 7: figure 7 becomes active
37066|Store it
37069|BC=the long delay range (minimum 80, up to 30 more)
37072|Zero: use the long delay
37074|BC=the short delay range (minimum 20, up to 20 more)
37077|A=a random delay
37080|Set the counter
37083|HL=figure 8's frame pointer
37086|E=the next frame's address, low byte
37087|Next byte
37088|D=high byte
37089|Next byte
37090|Store the pointer to the next frame
37094|DE=the sprite
37095|HL=figure 8's screen address
37098|Draw the three-cell-wide sprite
'''
