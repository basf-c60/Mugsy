TXT = """
30785|Clear bytes 0-1 of the 64-bit product...
30788|...bytes 2-3...
30791|...bytes 4-5...
30794|...and bytes 6-7
30798|Combine C into the test...
30799|...and D...
30800|...and E: zero when the multiplier is used up
30807|HL=low word of the shifted multiplicand
30810|DE=low word of the product so far
30814|Add them
30815|Store the new low word of the product
30818|HL=second word of the multiplicand
30821|DE=second word of the product
30825|Add with the carry from below
30827|Store it
30830|HL=third word of the multiplicand
30833|DE=third word of the product
30837|Add with carry
30839|Store it
30842|HL=top word of the multiplicand
30845|DE=top word of the product
30849|Add with carry
30851|Store it
30854|Back to the normal registers
30863|Shift BCDE right: C...
30865|...D...
30867|...and E
31058|Clear the quotient: bytes 0-1...
31061|...bytes 2-3...
31064|...bytes 4-5...
31067|...and bytes 6-7
31074|Divisor bytes 4-5 from BC
31078|Divisor bytes 6-7 are zero...
31081|...(HL is still 0)
31087|Keep the comparison result...
31091|...and get it back after undoing
31096|Examine up to 8 bytes
31098|A=the byte of the dividend
31099|Is it zero?
31102|Zero: look at the next lower byte
31105|The dividend is zero: quotient 0
31108|A=the byte
31109|Test bit C
31112|Try the next lower bit
31119|HL=the matching byte of the divisor
31120|DE=address of the divisor byte
31124|Is the same bit set in the divisor?
31127|Not yet: count another shift
31153|Quotient bit 0 holds...
31156|...a 1 for a successful subtraction
31158|Store the quotient
31178|Done: the quotient is in 31038 (64 bits)
30348|L=the variable number
30349|HL=variable number
30351|HL=2*variable
30353|Save the low word of the first value
30357|HL=address of the second variable
30358|Restore DE
30363|Combine C into the zero test...
30364|...and D...
30365|...and E
30371|Compare the sign bits: XOR the top bytes
30372|Keep just the sign bit
30379|Compare the top bytes
30384|Compare the next bytes
30385|Different: that decides it
30386|Next byte of the second value
30389|Compare with D
30390|Different: that decides it
30394|Compare the lowest bytes
30395|Return with the flags: Z=equal, C=second is smaller
30403|Return with carry set
30407|OR in the next byte...
30410|...and the next...
30413|...and the lowest
30416|Return with Z set only if the second is also zero
30423|Return with NZ and carry set
"""
