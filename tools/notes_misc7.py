"""Hand-written comments: loops and jumps in the picture decoder, bit reader, tune player and speaker."""
TXT = r'''
26859|Repeat for all eight pixel rows
26870|Carry on with the next cell
28297|Run the script at IY
30567|Not the same: do another iteration
30572|Not the same: do another iteration
30606|Divide by 100
30615|Multiply by 100
30688|Divide by 100 (the fixed-point scale)
30858|Shift the multiplier left
30879|Repeat for all the remaining bytes
30890|Repeat for all the remaining bytes
32175|Zero: no padding byte
32196|Fill the area around the seed
32237|Repeat for every cell in the run
32239|Next run
32265|Repeat for every cell in the run
32267|Next run
32290|Repeat for every cell in the run
32292|Next run
32323|Read the bit
32553|Zero: the shift is done
32556|Shift the pair left one more bit
32566|Repeat until the mask has D bits
32580|Less than 8: the position is right
32585|Subtract 8 again
32606|Rotate the mask once for each bit position
32826|Next fragment
32830|Restore the stack and return
32873|A key is pressed: stop the tune
32878|A pitch of zero: the fragment is over
32900|Non-zero: use it as the delay
32914|Start the note
32920|Pause
32922|Pad the timing
32939|Play the note again for each repeat
32948|Pitch slide is upward: go on
32955|Continue
32962|Continue
32979|Finish this note
32988|Wait about 12 loops
33004|Pad the timing
33015|Wait a half cycle
33018|Repeat until the half cycle is over
33025|Wait a half cycle
33028|Repeat until the half cycle is over
'''
