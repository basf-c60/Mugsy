"""Hand-written comments: the flood fill."""
TXT = r'''
31528|Save BC
31529|Save DE
31530|Save HL
31531|HL=22528: an address in the attribute file, used as the end marker
31535|BC=0
31538|Push the marker (HL=22528, DE=0 below it) on the seed stack
31542|D=the pixel mask of the seed
31544|Is the pixel at HL set?
31552|The left edge of the screen was reached: start filling
31564|Clear both flags (above and below)
31569|Is the mask the leftmost pixel of a byte?
31571|No: do it pixel by pixel
31574|Test the byte
31577|Save the screen address
31581|A=0: the flag for "above" if nothing is pushed
31585|A=the pixel mask
31586|Is the pixel above set?
31587|A=0: the flag if it is blocked
31594|Test the flag
31598|Push the mask
31599|Push the address
31600|A=1: the flag says a seed is now pending above
31601|Store the flag
31604|HL=the current address
31605|Keep it on the stack
31609|A=0: the flag for "below" if nothing is pushed
31613|A=the pixel mask
31614|Is the pixel below set?
31615|A=0: the flag if it is blocked
31622|Test the flag
31626|Push the mask
31627|Push the address
31628|A=1: a seed is now pending below
31630|Store the flag
31633|HL=the current address
31640|Move on along the line
31646|Save the screen address
31647|Look at the byte above
31650|A=the byte above
31651|Restore the address
31652|At the top of the screen: it counts as clear
31654|Is the byte above full?
31656|Yes: treat as blocked
31658|Is it empty?
31659|Neither empty nor full: do it pixel by pixel
31661|C=1: the byte above is empty
31662|Save the address
31663|Look at the byte below
31666|A=the byte below
31667|Restore the address
31668|At the bottom of the picture: it counts as clear
31670|Is the byte below full?
31672|Yes: treat as blocked
31674|Is it empty?
31675|Neither: do it pixel by pixel
31677|B=1: the byte below is empty
31678|A=the flag for above
31681|Test it
31682|A=C (above is empty)
31683|A seed is already pending above
31685|Is the byte above empty?
31686|No: nothing to push
31688|Remember that a seed is pending above
31691|Save the address
31692|Move to the byte above
31695|Push it as a new seed
31696|Push the mask
31697|Store the flag
31700|A=the flag for below
31703|Test it
31704|A=B (below is empty)
31705|A seed is already pending below
31707|Is the byte below empty?
31708|No: nothing to push
31710|Remember that a seed is pending below
31713|Save the address
31714|Move to the byte below
31717|Push it as a new seed
31718|Push the mask
31726|Keep the column
31728|At the right edge: this run is finished
31730|A=the mask
31731|Is the next pixel set?
31732|No: carry on filling
31739|Pick up the address of the next seed
31741|Is it the end marker (high byte 88)?
31748|Reset the attribute bits to 0
31751|Restore HL
31752|Restore DE
31753|Restore BC
31754|Return
'''
