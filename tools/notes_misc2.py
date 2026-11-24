"""Hand-written comments: attribute/pixel-row movers, speaker and delay helpers."""
TXT = r'''
31755|Save AF
31756|Save DE
31760|Clear the carry flag
31761|Subtract 32 from the address
31763|A=the high byte
31764|Is it 87 (just below the attribute file at 88)?
31766|No: the move is fine
31769|Restore DE
31770|Restore AF
31771|Return
31772|Save AF
31773|Save DE
31777|Add 32 to the address
31779|Is the high byte 90 (attribute rows 16-23)?
31781|No: the move is fine
31783|A=the low byte
31784|Keep the row bits
31786|Is it row 22 or 23 (the status lines)?
31788|No: the move is fine
31790|Clear the carry flag
31793|Restore DE
31794|Restore AF
31795|Return
31796|Save AF
31799|Is it 87 (just below the attribute file)?
31801|No: the move is fine
31804|Restore AF
31805|Return
31806|Save AF
31809|Is the high byte 90?
31811|No: the move is fine
31813|A=the low byte
31814|Keep the row bits
31816|Row 22 or 23 (the status lines)?
31818|No: the move is fine
31821|Restore AF
31822|Return
31824|A=the high byte
31825|Pixel row within the cell
31830|A=the low byte
31831|Up one character row
31833|L=it
31834|Borrow: H is already right
31836|A=the high byte
31837|Add 8 to move to the previous third's last row
31839|H=it
31841|Is it 63 (above the display file)?
31845|A=the low byte
31846|Put the row back
31848|L=it
31852|A=the high byte
31853|Pixel row within the cell
31856|A=the low byte
31857|Down one character row
31859|L=it
31860|Carry: H is already right
31862|A=the high byte
31863|Take 8 off
31865|H=it
31867|Is it 80 (past the third)?
31870|A=the low byte
31871|Keep the row bits
31873|Is it row 6 (the bottom of the picture area)?
31877|A=the low byte
31878|Up one character row
31880|L=it
31881|A=the high byte
31882|Add 8 back
31884|H=it
31891|A=the low byte
31892|Keep the column
31895|Rotate the mask back
31897|Previous cell
32995|Test bit 7 of the pitch
32997|A=0: speaker off
33009|Save DE
33012|A=the pitch
33030|Restore DE
33031|Return
33032|Save BC
33037|Restore BC
33038|Save BC
33043|Restore BC
33044|Save BC
33049|Restore BC
33050|Return
41997|Save the repeat count
41998|Play the shootout sound effect
42001|BC=the delay length
42005|Count the delay down
42006|Test BC...
42007|...for zero
42008|Loop until it is zero
42010|Restore the repeat count
42011|Repeat B times
42013|Return
42014|Save BC
42015|BC=the short delay length
42019|Count down
42020|Test BC...
42021|...for zero
42022|Loop until it is zero
42024|Restore BC
42025|Return
42026|HL=the sound data
42029|DE=40: the number of bytes
42032|C=the next byte of the pattern
42033|B=8 bits
42035|A=0: the speaker and border low
42037|Rotate the next bit out
42039|Zero: leave the speaker low
42041|A=24: speaker on (bit 4) and MIC (bit 3)
42043|Output it
42045|Wait a short time
42048|Next bit
42050|Next byte
42051|One fewer left
42052|Test DE...
42053|...for zero
42054|Loop until all are played
42056|Return
'''
