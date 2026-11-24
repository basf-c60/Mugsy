TXT = """
30515|Store the top word of the argument
30526|Store the top word of the estimate
30530|Switch to the alternate registers (BC'DE' will hold x)
30535|BC=top word of n
30542|Back to the main registers
30547|BC=top word of x
30560|A=byte 0 of the previous estimate
30561|Same as E?
30564|Next byte
30565|A=byte 1 of the previous estimate
30566|Same as D?
30569|Next byte
30570|A=byte 2 of the previous estimate
30571|Same as C?
30574|Next byte
30575|A=byte 3 of the previous estimate
30576|Same as B?
30896|DE=low word of the divisor
30900|Clear the carry flag
30901|Subtract the low words
30903|Store the new low word
30906|HL=second word of the dividend
30909|DE=second word of the divisor
30913|Subtract with borrow
30915|Store it
30918|HL=third word of the dividend
30921|DE=third word of the divisor
30925|Subtract with borrow
30927|Store it
30930|HL=top word of the dividend
30933|DE=top word of the divisor
30937|Subtract with borrow
30939|Store it (H holds the sign of the 64-bit result)
30944|Return with Z set if the result is not negative
31918|A=the line length...
31920|Keep the direction and step count (BC)
31925|Get the direction and step count back...
31926|...and keep them for later
31927|A=pixel count again

31972|Keep the step counter for the next time round
31973|Keep the count in A'
31980|Restore the direction and step count...
31981|...and the caller's HL
31982|Done: the line has been drawn
31983|A=pixel count
32023|Keep the step counter for the next time round
32024|Keep the count in A'
32031|Restore the direction and step count...
32032|...and the caller's HL
32033|Done: the line has been drawn
"""
