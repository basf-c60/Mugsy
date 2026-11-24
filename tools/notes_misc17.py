TXT = """
31181|HL=2*variable
31182|HL=4*variable
31183|Save the low word of the value
31187|HL=address of the variable
31188|Restore DE
31190|Next byte of the variable
31191|Store the second byte
31192|Next byte
31193|Store the third byte
31194|Next byte
31195|Store the top byte (the sign)
31196|Done
31203|HL=2*variable
31204|HL=4*variable
31208|HL=address of the variable
31210|Next byte
31211|D=second byte
31212|Next byte
31213|C=third byte
31214|Next byte
31215|B=top byte (the sign)
31216|Point past the variable
31217|Done: BCDE=the variable
31222|DE=the next byte
31225|BC=the remaining 6143 bytes
31228|Clear the first byte
31230|Propagate it across the display file
31235|DE=the next attribute
31238|BC=the remaining 767 attributes
31241|Paper 7 (white), ink 0 (black)
31243|Propagate it across the attribute file
31245|Restore HL
31246|Done: a clean white screen
32047|Keep bits 3-4 of H: the screen third (0-2) times 8
32049|Move the third number...
32050|...down...
32051|...to the low bits
32052|Add the high byte of the attribute file
32054|H=attribute address high byte
32056|Clear the three ink bits
32058|Store the attribute without ink
32062|Add the new ink colour
32063|Store the updated attribute
32064|Restore HL
32065|Done
33034|Waste 4 T-states
33035|Waste 4 T-states
33036|Waste 4 T-states
33039|Waste 4 T-states
33040|Waste 4 T-states
33041|Waste 4 T-states
33042|Waste 4 T-states
33045|Waste 4 T-states
33046|Waste 4 T-states
33047|Waste 4 T-states
33048|Waste 4 T-states
"""
