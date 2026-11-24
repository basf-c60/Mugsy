TXT = """
30022|Done: A=0..limit
30028|Save BC
30064|Save HL
30069|Restore HL
30086|Restore BC
30087|Restore IX
30201|Step past the low byte...
30202|...and the high byte
30206|Back to the high byte
30210|Done: HL=the 16-bit operand
30219|Advance the program counter
30223|Restore HL
30224|Done: A=the byte
30237|Done
30245|Done
30306|Done
30321|Keep the address of the operand
30329|Step past the first byte of the operand...
30334|Done
30338|L=the variable number
30358|Restore DE
30431|Back to the main registers
30432|Done: BCDE=first operand, BC'DE'=second
30441|Keep the high word of BC...
30442|...and the low word
30443|Switch to the second operand
30444|HL=low word of the first operand
30445|Clear the carry flag
30446|Add the low words
30448|HL=high word of the first operand; the low sum goes on the stack
30451|Keep the high sum
30452|Back to the main registers
30455|Done: BCDE=the sum
30465|Keep the low word
30466|Switch to the second operand
30467|HL=low word of the first operand
30468|Clear the carry flag
30469|Subtract the low words
30471|HL=high word of the first operand; the low difference goes on the stack
30474|Keep the high difference
30475|Back to the main registers
30478|Done: BCDE=the difference
30486|E=the random number
30487|Done
30493|Shift C right with the carry from B
30495|...D...
30497|...and E
30499|Done: BCDE=BCDE/2
30603|DE=100
30612|DE=100
30637|Clear the carry flag
30638|Subtract the low word from 0
30640|DE=the negated low word
30644|Subtract the high word from 0
30648|Done: BCDE=-BCDE
30685|DE=100
30746|DE=0
30875|Next byte
30878|One fewer byte to do
30881|Done
30886|Next byte
30889|One fewer byte to do
30892|Done
30994|Store 0: the result is positive so far
31007|Flip the sign flag...
31009|...and store it
31023|Flip the sign flag...
31025|...and store it
31028|Back to the main registers
31029|Done: both operands positive, 31054 holds the sign of the result
31128|HL=the divisor
31188|Restore DE
31200|L=the variable number
31218|Save HL
"""
