"""Hand-written comments: shootout caller, status lines, rating words."""
TXT = r'''
28358|Variable 33 holds the handout, set by the script
28360|BCDE=the handout (as a fixed-point number)
28363|Combine the upper three bytes
28364|...
28365|...
28366|A=the low byte of the handout
28367|The upper bytes are zero: use the low byte as it is
28369|The handout is 2.56 or more: use 255 (8 hit points)
28371|Play the shootout (A gives Mugsy's hit points)
28374|Save the result
28375|Read the keyboard flags
28378|Forget any keypress left over from the shootout
28380|Store the flags
28383|Restore the result
28384|Was Mugsy killed (bit 0)?
28386|No
28388|A=3: Mugsy was killed
28390|Store the outcome in flag 4
28393|Return
28394|Were any bystanders hit (bits 2 and 3)?
28396|A=1: the hit man was killed and no bystanders were hurt
28398|Zero: store 1
28400|A=2: the hit man was killed but bystanders were hit
28402|Store the outcome
28468|HL=the template for the number of hoods
28471|A=7: the field is seven characters wide
28473|D=3: variable 3 holds the number of hoods
28475|Format it into the template
28478|HL=the template for the number of customers
28481|A=7: the field is seven characters wide
28483|D=8: variable 8 holds the number of customers
28485|Format it into the template
28488|B=32: the whole line
28490|DE=the text of the line
28493|HL=the second-to-last character row
28496|A=the next character
28497|Print it
28500|Next character
28501|Loop for the whole line
28503|Return
28504|HL=the template for the money in the safe
28507|A=7: the field is seven characters wide
28509|D=7: variable 7 holds the money in the safe
28511|Format it into the template
28514|B=32: the whole line
28516|DE=the text of the line
28519|HL=the last character row
28522|A=the next character
28523|Print it
28526|Next character
28527|Loop for the whole line
28529|Return
28530|Save the template address
28531|L=the variable number
28532|BCDE=its value
28535|HL=the template address
28536|Remember where the number goes
28539|Blank the field with spaces
28541|Next character of the field
28542|One fewer
28543|Loop until the field is blank
28545|Print the value into the field
'''
