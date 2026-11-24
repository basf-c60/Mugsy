TXT = """
30948|DE=low word of the divisor
30952|Add the low words
30953|Store the new low word
30956|HL=second word of the dividend
30959|DE=second word of the divisor
30963|Add with carry
30965|Store it
30968|HL=third word of the dividend
30971|DE=third word of the divisor
30975|Add with carry
30977|Store it
30980|HL=top word of the dividend
30983|DE=top word of the divisor
30987|Add with carry
30989|Store it
30992|Done: the trial subtraction is undone
29527|Test the first-character flag
29539|Store the updated buffer pointer
29542|Restore HL
29543|Done
29546|DE=code
29551|Add the code once...
29554|Next byte of the table entry
29555|D=high byte of the handler address
29753|Switch to the alternate registers...
29754|...DE'=high word of the power of ten...
29755|...and back again
29759|Clear the carry flag
29762|Switch to the high words...
29765|...and back
29769|Switch to the high words...
29772|...and back
29776|Test the leading-zero flag
30028|Save BC
30064|Save HL
30068|Same as the previous number?
30069|Restore HL
30080|Halve the number
30086|Restore BC
30087|Restore IX
30089|Done: A=a random number from -limit to +limit
"""
