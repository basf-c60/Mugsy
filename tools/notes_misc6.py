"""Hand-written comments: control-flow lines in the font printer, number entry, number printing, random and divide."""
TXT = r'''
26963|Shift again until the mask has the right number of leading zeros
26975|Repeat for six rows
26986|Print the extra pixel row
26989|Skip the comma test
26997|Print the extra pixel row
27013|Check again
27906|Check the next character
27926|Skip over the sign
27938|Run the script: v35=0
27951|Run the script: v35=v35*10
27966|Store the digit in v33
27973|Run the script: add 100*v33 to v35 (the number is kept in hundredths)
27978|Next character
27982|BCDE=the number
29666|Print the millions digit
29675|Print the hundred-thousands digit
29684|Print the ten-thousands digit
29693|Print the thousands digit
29702|Print the hundreds digit
29711|Print the tens digit
29725|Print the units digit
29742|Print the tenths digit
30032|The doubled limit fits in a byte
30044|No carry into the high byte
30076|Within range: done
30078|Exactly equal to the limit: done
30082|Check again
31100|Found a non-zero byte
31103|Keep looking down the bytes
31110|Found the highest set bit
31114|Keep looking
31125|The bits line up: stop shifting
31131|Shift the divisor left
31134|Check again
31140|Shift the quotient left
31151|Skip the remaining bit-setting
31164|Shift the dividend left
31173|Shift the remainder right
31176|Once for each shift made
31945|Now do the vertical step check
31957|Not moving down: go up instead
31964|Skip the up move
31989|Not moving down: go up instead
31996|Skip the up move
32008|Not moving left: go right instead
32015|Skip the right move
'''
