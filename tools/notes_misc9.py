"""Hand-written comments: picture command interpreter, compressed picture decoder, bit reader, tune player.
(FIX overrides earlier comments that had the ink and paper passes the wrong way round.)"""
TXT = r'''
31247|Save HL
31248|Save DE
31249|Save BC
31279|Point at y
31284|Point at the next command
31295|H=the high byte of the screen address
31304|Skip the address, low byte...
31306|...high byte...
31308|...and the width
31313|Save the width and height
31322|Restore the width and height
31327|One row done
31336|B=the command byte
31339|C=the direction flags
31340|A=the command byte again
31341|Move bits 3-6 down...
31344|B=the high part of the slope
31350|L=the low part of the length
31352|A=the second byte again
31355|Point at the next command
31358|Rotate bits 6-7 round to bits 0-1...
31359|...and keep them
31361|Combine them with the high part of the slope
31362|B=the slope
31375|Save the pen position
31379|Point at y
31384|Point at the next command
31389|Restore the pen position
31400|Multiply the paper colour by 8...
31401|...to put it in bits 3-5
31403|Save HL
31404|Save DE
31405|Save BC
31406|C=the paper colour in bits 3-5
31410|Point at the low byte of the address
31412|L=the low byte
31415|Point at the first run
31420|Point at the next run
31426|B=the run byte
31429|E=the direction
31431|Shift the run length down...
31432|...two places
31433|Keep the length bits
31435|The length is one more
31436|B=the length
31438|Keep the ink
31440|Move the ink to bits 3-5, where the paper is...
31441|...
31442|...
31449|Move the ink back to bits 0-2...
31450|...
31454|Zero means up
31458|1 means right
31462|2 means down
31466|3 means left
31474|Restore BC
31475|Restore DE
31476|Restore HL
31480|Restore BC
31481|Restore DE
31482|Restore HL
31483|Return
32066|Save BC
32070|A=175-y
32075|B=the bit position plus one
32078|Rotate the mask right
32080|Repeat for each position
32082|Restore BC
32083|Return
32126|Save HL
32135|HL=the start of the bit-stream
32140|Store bit position 0
32154|H=the high byte of the offset
32167|H=the high byte of the offset
32170|Add the address of the header
32174|Test the byte
32178|Save the address
32186|A=175-y
32189|E=y counted from the top
32190|Next byte
32201|HL=the position in the list
32202|DE=the end of the list
32206|Clear the carry flag
32207|Compare
32219|Is the high byte 91 (the end of the attribute file)?
32224|Keep the run length bits
32226|B=the run length minus one
32227|B=the run length
32229|Next byte of attribute data
32230|Keep the colour bits
32232|Rotate bits 5-7 round to bits 0-2...
32233|...
32234|...
32236|Next cell
32245|Is the high byte 91?
32250|Keep the run length bits
32252|B=the run length minus one
32253|B=the run length
32255|Next byte of attribute data
32256|Keep the colour bits
32258|Move bits 5-7 down to bits 3-5...
32259|...
32260|C=the paper colour
32262|Merge it with the ink already there
32263|Store it
32264|Next cell
32273|Is the high byte 91?
32277|Keep the run length bits
32279|B=the run length minus one
32280|B=the run length
32282|Next byte of attribute data
32283|Keep the bright and flash bits
32285|C=the bits
32287|Merge them with the colours already there
32288|Store them
32289|Next cell
32300|Clear the carry flag
32301|HL=the stream pointer's offset from the header
32303|E=the low byte of the offset of the end
32306|D=the high byte
32309|Clear the carry flag
32310|Compare: is this the end byte?
32317|Is it the end bit position too?
32326|Test the bit
32335|Merge the pixel with the screen byte
32336|Store it
32339|Return
32347|D=the pixel mask
32348|Switch to the alternate registers
32349|BC'=the line start
32356|Save the end point
32360|Switch back
32361|BC=the end point
32364|Return
32539|Save HL
32540|Save DE
32544|D=the first byte of the stream
32545|Next byte
32546|E=the second byte
32547|HL=the two bytes
32551|Test the bit position...
32552|...
32555|Shift the pair left
32559|A=the number of bits
32562|Set the carry
32563|Shift a one into the mask
32565|Count down
32568|A=the mask
32570|Save the value
32574|Add the number of bits to the bit position
32575|HL=the stream pointer
32578|Past the end of the byte?
32582|Take off 8
32587|Store the new bit position
32590|Store the new pointer
32593|Restore the value
32594|Restore HL
32596|Save BC
32601|B=the bit position plus one
32602|...
32605|Rotate the mask right
32608|Restore BC
32609|Return
32867|Read the keyboard
32869|Keep the key bits
32871|No key pressed?
32877|Is the pitch zero?
32881|Next byte (the duration)
32883|Next byte (the flags)
32885|Next byte (the repeat count)
32887|Next byte (the next note)
32894|Shift bits 4-7 down...
32895|...
32896|...
32897|...
32898|Keep them
32905|A=1: the default delay
32910|Keep the slide bits
32912|C=the slide
32913|Save DE
32917|Save BC
32925|Pad the timing
32926|Pad the timing
32927|Restore BC
32928|Save BC
32931|Pad the timing
32932|Pad the timing
32933|Pad the timing
32937|Pad the timing
32941|Restore BC
32943|Add the slide to the pitch
32944|D=the new pitch
32945|Save the carry flag
32951|Restore the carry flag
32958|Restore the carry flag
32966|Take the slide off the duration
32967|E=the new duration
32972|Restore DE
32976|Return
32977|Restore DE
32978|Save DE
'''
FIX = {
 32151: 'HL=the offset of the attribute data (header bytes 3-4)',
 32161: 'Remember it: it also marks the end of the list of fill seeds',
 32164: 'HL=the offset of the end of the point bit-stream (header bytes 0-1)',
 32170: 'HL=the address just after the bit-stream',
 32171: 'Does the bit-stream end part-way through a byte (header byte 2)?',
 32177: 'Yes: skip that last byte',
 32179: 'IY=the list of fill seed points',
 32215: 'First pass over the attribute file: the ink colours',
 32228: 'Bits 5-7: the ink colour',
 32235: 'Set the ink for the run',
 32241: 'Second pass: the paper colours',
 32254: 'Bits 5-7: the paper colour',
 32261: 'Add the paper to each cell in the run',
}
