TXT = """
29007|Save HL...
29016|A=the width again
29019|B=the width
29024|Restore HL
29025|Restore BC
29026|Done
29812|A=the number of alternatives
29831|HL=the counter of alternatives still to skip
29834|Is this the chosen one?
29837|Keep the message pointer
29842|Restore the message pointer
29853|Two-byte item: skip both bytes
29866|One alternative fewer to go
29872|Done: the zero flag tells the caller the message continues
28674|Save IX...
28676|...and HL
28684|Next entry in the table
28688|Clear the carry flag
28693|Store the measured value
28694|Restore HL
28695|Restore IX
28697|Done
30101|HL=start of the VM jump table
30104|Add the doubled opcode to L...
30105|L=the low byte of the entry address
30106|Prepare to add the carry to H...
30108|...A=H+carry
30111|Next byte of the entry
30112|H=high byte of the handler address
30113|L=low byte: HL=handler
30587|Store the top word of the value
30591|Clear the upper words...
30594|...bytes 4-5...
30597|...and bytes 6-7 of the 64-bit dividend
30603|DE=100
30612|DE=100
30622|BC=the top word of the result
30629|Test the sign flag
30660|Switch to BC'DE', the second operand...
30665|Store its top word as the multiplier's
30669|Back to the main registers
30673|Clear multiplier bytes 4-5...
30676|...and 6-7
30685|DE=100
30695|BC=the top word of the quotient
30702|Test the sign flag
"""
