TXT = """
26905|Restore BC
26937|Restore DE
27002|Restore DE
27003|Restore BC
27025|Save BC
27056|Restore BC
27057|Restore DE
27749|Restore BC
27750|Restore DE
27960|D=0
28275|Wait for the next interrupt (a key may arrive)
28694|Restore HL
28695|Restore IX
28698|Save BC
28699|Save HL
28724|Restore HL
28726|Restore BC
28769|Keep bit 0: 1 if the number of lines is odd
28890|A=the high byte
28900|A=the high byte
28905|Save IY
29006|Save BC
29024|Restore HL
29025|Restore BC
29519|Save HL
29542|Restore HL
29722|DE=100
29739|DE=10
30026|Save IX
30028|Save BC
30064|Save HL
30069|Restore HL
30086|Restore BC
30087|Restore IX
30223|Restore HL
30358|Restore DE
30603|DE=100
30612|DE=100
30685|DE=100
30746|DE=0
31188|Restore DE
31218|Save HL
31245|Restore HL
31512|Is the address 88 or more (attribute file)?
31520|Store the byte
31521|Done
31850|Done: Z means the edge was reached
31869|Not the bottom: done with NZ
31886|Done: Z means the edge was reached
31899|Done: Z means the edge was reached
31905|Keep the column
31907|Did it wrap round to column 31?
31912|Back to the cell on the right
31914|Done: Z means the edge was reached
31917|Save HL
31932|Swap in the pixel count
32034|Save HL
32035|A=the pixel mask
32036|Keep it
32040|Get the mask back
32042|Store the byte with the pixel set
32043|Restore HL
32044|Done
32045|Save HL
32064|Restore HL
32432|Add the old x (C)
32800|Done
32803|Save IX
32812|H=the high byte of the fragment address
32816|Combine with L: a zero address ends the list
32822|Next fragment...
32824|...(2 bytes per entry)
32828|Restore IX
32982|Save BC
32983|(Never used: B is overwritten by the next instruction)
32986|B=12: the fixed delay
32990|Restore BC
32994|Done
33010|Mask the pitch (A is overwritten below, so this has no effect)
33020|A=0: speaker bit off
"""
