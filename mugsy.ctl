@ 24576 start
@ 24576 org=24576
@ 24576 set-handle-unsupported-macros=1
c 24576 Start the game
D 24576 This is the entry point (from #R24576(PRINT USR 24576) in the BASIC loader). It disables interrupts, moves the stack down into the printer buffer, saves IY (which the ROM interrupt routine needs) and calls the main loop. When the player answers "nope" to "Hows about another game, Mugsy?" the main loop returns here and the machine locks up in an infinite loop (see #LINK(Bugs#noquit)(the bugs page)).
@ 24576 label=START
C 24576,1 Disable interrupts
C 24577,3 Put the stack in the printer buffer, just below the system variables
C 24580,4 Save IY (the ROM interrupt routine needs it to point at the system variables)
C 24584,3 Play games until the player has had enough
C 24587,2 Then hang forever (see #LINK(Bugs#noquit)(the bugs page))
c 24589 Main loop: play one game
D 24589 Initialises the variables, shows Louey's greeting and then plays years until the game status flag at #R33897 is non-zero. A value of 2 means "another game"; 1 means "no more".
@ 24589 label=MAINLOOP
C 24589,3 Initialise the VM variables and flags
C 24592,4 Run the script at #R24609: Louey says "Hi Boss, it's Louey your sidekick here..."
C 24596,3 Run the greeting script
C 24599,3 Play years until the game ends
C 24602,3 Pick up the game status flag (1=quit, 2=new game)
C 24605,1 Count down: 1 (quit) becomes 0
C 24606,1 Return (and hang) if the player doesn't want another game
C 24607,2 Otherwise start a new game
b 24609 VM script: Louey's greeting
D 24609 Run by #R24589 at the start of each game.
B 24609,4,4 VM: SAY #R49798,20 "Hi Boss, it's Louey your sidekick here wit' da lowdown on da mob..."
B 24613,1,1 VM: END
c 24614 Play one year
D 24614 Picks one of the two speech bubble layout tables at random (#R33913 or #R33925), runs the main VM script at #R24652 and loops until the script sets the game status flag at #R33897.
@ 24614 label=PLAYYEAR
C 24614,3 No bubble layout is current yet
C 24617,3 Remember that no layout is current
C 24620,2 A=100: the upper limit (#R30014 takes the absolute value, giving 0..100)
C 24622,3 A=a random number from 0 to 100
C 24625,2 Is it less than 50?
C 24627,3 Use the first table of bubble layouts...
C 24630,2 ...if so
C 24632,3 Otherwise use the second table
C 24635,3 Store the layout table pointer
C 24638,4 Run the main script at #R24652 for this year
C 24642,3 Run the year's script
C 24645,3 Has the game finished?
C 24648,1 Test the game status flag
C 24649,2 Play another year if not
C 24651,1 Return: the game is over
b 24652 VM script: one year of the game
D 24652 Run by #R24614. This is the whole game: the report on last year, Rocco, the contract, buying and selling clients, ammo, the squeeze, the kickback, the hit man, the year's results and finally the end-of-game rating. See the #LINK(VM)(VM reference) for the instruction set.
B 24652,6,6 VM: SAY #R49838,1 "Last year (Killed) guys got rubbed out by other mobs and (Recruits) hoods wuz recruited by the organisation."
B 24658,5,5 VM: IFLT K0,Recruits,#R24670
B 24663,4,4 VM: SAY #R49917,9 "[City Hall think you stink/Some of da boys is sayin' you're all washed up], Boss."
B 24667,3,3 VM: GOTO #R24713
B 24670,6,6 VM: IFPEEKEQ #R33888,1,#R24713
B 24676,2,2 VM: RND K1
B 24678,2,2 VM: MUL K10
B 24680,2,2 VM: MUL Recruits
B 24682,2,2 VM: DIV Hoods
B 24684,2,2 VM: STORE FedsKilled
B 24686,3,3 VM: DIV Recruits,K2
B 24689,2,2 VM: ADD FedsKilled
B 24691,1,1 VM: INT
B 24692,2,2 VM: STORE FedsKilled
B 24694,3,3 VM: ADD TotalKilled,FedsKilled
B 24697,2,2 VM: STORE TotalKilled
B 24699,3,3 VM: SUB Hoods,FedsKilled
B 24702,2,2 VM: STORE Hoods
B 24704,5,5 VM: SAY #R49927,9 "But some was undercover feds and (FedsKilled) got killed in the shootout."
B 24709,4,4 VM: POKE 1,#R33888
B 24713,6,6 VM: IFPEEKEQ #R33888,1,#R24729
B 24719,7,7 VM: SAY #R49960,8 "So da mob now contains (Hoods) <msg 53284> hoodlums."
B 24726,3,3 VM: GOTO #R24736
B 24729,7,7 VM: SAY #R49960,9 "So da mob now contains (Hoods) <msg 53286> hoodlums."
B 24736,5,5 VM: IFLT K9,Hoods,#R24756
B 24741,4,4 VM: SAY #R49984,1 "Me and the boys is gettin' out pronto."
B 24745,4,4 VM: SAY #R50003,9 "What a Schmuck you are, Mugsy!"
B 24749,4,4 VM: POKE 2,#R33890
B 24753,3,3 VM: GOTO #R26431
B 24756,3,3 VM: ADD HoodYears,Hoods
B 24759,2,2 VM: STORE HoodYears
B 24761,5,5 VM: IFNE K0,Squeezed,#R24781
B 24766,4,4 VM: SAY #R50016,1 "We didn't run no rackets, Boss."
B 24770,2,2 VM: LOAD K0
B 24772,2,2 VM: STORE Takings
B 24774,2,2 VM: LOAD K0
B 24776,2,2 VM: STORE Profit
B 24778,3,3 VM: GOTO #R24832
B 24781,3,3 VM: MUL Squeezed,Price
B 24784,2,2 VM: ADD K05
B 24786,1,1 VM: INT
B 24787,2,2 VM: STORE Takings
B 24789,3,3 VM: MUL Price,K1000
B 24792,2,2 VM: STORE Tmp
B 24794,8,8 VM: SAY #R50037,1 "We protected (Squeezed) of your (Clients) clients last year and squeezed them for an average of $(Tmp), so we made (Takings) thousand bucks."
B 24802,2,2 VM: LOAD Takings
B 24804,2,2 VM: STORE Profit
B 24806,3,3 VM: ADD TotalTakings,Takings
B 24809,2,2 VM: STORE TotalTakings
B 24811,6,6 VM: IFPEEKEQ #R33891,1,#R24843
B 24817,5,5 VM: IFGE K3,Takings,#R24843
B 24822,3,3 VM: DIV Takings,K2
B 24825,1,1 VM: INT
B 24826,2,2 VM: STORE Profit
B 24828,4,4 VM: SAY #R50080,9 "but Rocco's mob got half of that when they jumped us last winter."
B 24832,5,5 VM: IFEQ K0,Raided,#R24879
B 24837,3,3 VM: SETMSG #R53293
B 24840,3,3 VM: GOTO #R24851
B 24843,5,5 VM: IFEQ K0,Raided,#R24879
B 24848,3,3 VM: SETMSG #R53295
B 24851,3,3 VM: ADD Dough,Profit
B 24854,2,2 VM: SUB Raided
B 24856,2,2 VM: STORE Tmp
B 24858,5,5 VM: IFLT K10,Tmp,#R24903
B 24863,3,3 VM: ADD Dough,Profit
B 24866,2,2 VM: SUB K10
B 24868,2,2 VM: STORE Raided
B 24870,5,5 VM: IFLT K1,Raided,#R24903
B 24875,2,2 VM: LOAD K0
B 24877,2,2 VM: STORE Raided
B 24879,6,6 VM: IFPEEKEQ #R33891,1,#R24894
B 24885,6,6 VM: SAY #R50121,9 "<msg 53295>, we kept our noses clean wit' da inmates of da precint house,"
B 24891,3,3 VM: GOTO #R24900
B 24894,6,6 VM: SAY #R50121,9 "<msg 53293>, we kept our noses clean wit' da inmates of da precint house,"
B 24900,3,3 VM: GOTO #R24910
B 24903,7,7 VM: SAY #R50173,9 "<msg 0> the cops raided us and took (Raided) grand from our safe, Boss."
B 24910,4,4 VM: POKE 1,#R33891
B 24914,3,3 VM: ADD ClientYears,Clients
B 24917,2,2 VM: STORE ClientYears
B 24919,3,3 VM: ADD Dough,Profit
B 24922,2,2 VM: SUB Raided
B 24924,2,2 VM: STORE Dough
B 24926,3,3 VM: ADD TotalProfit,Profit
B 24929,2,2 VM: STORE TotalProfit
B 24931,5,5 VM: IFEQ K0,Loan,#R24987
B 24936,3,3 VM: ADD Interest,K100
B 24939,2,2 VM: MUL Loan
B 24941,2,2 VM: DIV K100
B 24943,1,1 VM: INT
B 24944,2,2 VM: STORE Loan
B 24946,3,3 VM: SUB Dough,Loan
B 24949,2,2 VM: STORE Tmp
B 24951,5,5 VM: IFLE K0,Tmp,#R24965
B 24956,6,6 VM: SAY #R50203,1 "You've got exactly (Dough) grand in the safe, Boss. Anyways, dat's less than da (Loan) grand ya owe Nick the Greek, so he's takin' over."
B 24962,3,3 VM: GOTO #R24745
B 24965,5,5 VM: SAY #R50267,1 "Nick the Greek has got the (Loan) grand ya owed him."
B 24970,5,5 VM: IFNE K10,Tmp,#R24982
B 24975,4,4 VM: SAY #R50289,1 "So ya aint got the dough ta buy rods and bullets so da boys can defend theirselves. Sorry, Boss,- you're goin' for a ride."
B 24979,3,3 VM: GOTO #R24745
B 24982,3,3 VM: SUB Dough,Loan
B 24985,2,2 VM: STORE Dough
B 24987,5,5 VM: SAY #R50351,9 "You got (Dough) thousand bucks."
B 24992,6,6 VM: IFPEEKEQ #R33895,1,#R25015
B 24998,6,6 VM: IFPEEKEQ #R33894,1,#R25011
B 25004,4,4 VM: SAY #R50520,1 "Your cousin Abe has muscled in on your territory. You've had it."
B 25008,3,3 VM: GOTO #R24745
B 25011,4,4 VM: SAY #R50670,9 "[Well, ya lived for another year./Lucky you're still in charge./I gotta hand it to ya, Boss./I just don't know how ya do it, Boss./Ya sure are a survivor, Boss./Gee, You're still da boss, Boss./Cripes, you're still hangin' on.]"
B 25015,3,3 VM: ADD TotalBlunders,Blunders
B 25018,2,2 VM: STORE TotalBlunders
B 25020,5,5 VM: IFEQ Years,Year,#R26431
B 25025,5,5 VM: IFGE K2,Blunders,#R25037
B 25030,2,2 VM: LOAD K0
B 25032,2,2 VM: STORE Blunders
B 25034,3,3 VM: GOTO #R25048
B 25037,3,3 VM: DIV Years,K2
B 25040,1,1 VM: INT
B 25041,2,2 VM: STORE Tmp
B 25043,5,5 VM: IFNE Years,Year,#R25138
B 25048,6,6 VM: IFPEEKEQ #R33893,1,#R25063
B 25054,6,6 VM: SAY #R50687,0 "<msg 53299> some of da boys in the mob is sayin' you're past it and they're talkin about puttin' out a contract on you. If it goes any further, how many grand ( if any) will you pay to keep the good guys faithful?"
B 25060,3,3 VM: GOTO #R25069
B 25063,6,6 VM: SAY #R50687,0 "<msg 53297> some of da boys in the mob is sayin' you're past it and they're talkin about puttin' out a contract on you. If it goes any further, how many grand ( if any) will you pay to keep the good guys faithful?"
B 25069,3,3 VM: CALL #R27790 (get a number from the player)
B 25072,2,2 VM: LOAD Input
B 25074,2,2 VM: STORE Handout
B 25076,6,6 VM: IFPEEKEQ #R33896,1,#R25111
B 25082,6,6 VM: IFPEEKEQ #R33896,2,#R25134
B 25088,3,3 VM: SUB Dough,Handout
B 25091,2,2 VM: STORE Tmp
B 25093,5,5 VM: IFLT K0,Tmp,#R25125
B 25098,5,5 VM: SAY #R50819,9 "You'll kill us wit' kindness, Boss.....( you've only got (Dough) grand). Tell me that again, Boss."
B 25103,3,3 VM: ADD Blunders,K1
B 25106,2,2 VM: STORE Blunders
B 25108,3,3 VM: GOTO #R25118
B 25111,4,4 VM: SAY #R50787,9 "Boss, the boys'll gun ya down."
B 25115,3,3 VM: CALL #R28297 (Louey charges hush money for a blunder)
B 25118,4,4 VM: SAY #R50806,8 "How many grand for the handout?."
B 25122,3,3 VM: GOTO #R25069
B 25125,4,4 VM: SAY #R50869,9 "Okay, Boss, my guys will help ya."
B 25129,3,3 VM: SUB Dough,Handout
B 25132,2,2 VM: STORE Dough
B 25134,4,4 VM: POKE 2,#R33892
B 25138,6,6 VM: IFPEEKEQ #R33895,2,#R25148
B 25144,4,4 VM: SAY #R50888,9 "It costs one grand to put the squeeze on each client, and the godfather made the rule that our gangsters each get one client to protect for theirselves."
B 25148,2,2 VM: RND K1
B 25150,2,2 VM: MUL K6
B 25152,2,2 VM: ADD K1
B 25154,2,2 VM: STORE Tmp
B 25156,5,5 VM: IFLT K5,Tmp,#R25168
B 25161,4,4 VM: POKE 1,#R33891
B 25165,3,3 VM: GOTO #R25287
B 25168,4,4 VM: POKE 2,#R33891
B 25172,4,4 VM: SAY #R50955,1 "The word is that Rocco's gettin' uppity. They say he wants ta muscle in on your patch, Boss."
B 25176,3,3 VM: MUL Hoods,K2
B 25179,2,2 VM: ADD Clients
B 25181,2,2 VM: ADD Loan
B 25183,2,2 VM: ADD K100
B 25185,2,2 VM: STORE Tmp
B 25187,5,5 VM: IFLT Tmp,Dough,#R25287
B 25192,4,4 VM: SAY #R51001,8 "Dis could be tough, but maybe we can buy off Rocco's mob. How many grand ( if any) can you pay?"
B 25196,3,3 VM: CALL #R27790 (get a number from the player)
B 25199,2,2 VM: LOAD Input
B 25201,2,2 VM: STORE Bribe
B 25203,6,6 VM: IFPEEKEQ #R33896,1,#R25235
B 25209,6,6 VM: IFPEEKEQ #R33896,2,#R25287
B 25215,5,5 VM: IFLE Bribe,Dough,#R25249
B 25220,5,5 VM: SAY #R51113,9 "You must be off ya rocker, Boss, we've only got (Dough) grand."
B 25225,3,3 VM: CALL #R28297 (Louey charges hush money for a blunder)
B 25228,4,4 VM: SAY #R51144,8 "Better try again - how many G's?"
B 25232,3,3 VM: GOTO #R25196
B 25235,4,4 VM: SAY #R51048,9 "Rocco aint usually regarded as a philanthropist, Boss. He don't give nuthin' away."
B 25239,3,3 VM: CALL #R28297 (Louey charges hush money for a blunder)
B 25242,4,4 VM: SAY #R51103,8 "How many thousand, Boss?"
B 25246,3,3 VM: GOTO #R25196
B 25249,3,3 VM: SUB Dough,Bribe
B 25252,2,2 VM: STORE Tmp
B 25254,5,5 VM: IFLT K5,Tmp,#R25274
B 25259,4,4 VM: SAY #R51163,9 "Geez, Boss, we're gonna need some ourselves. Ya wanna think again?"
B 25263,3,3 VM: CALL #R28297 (Louey charges hush money for a blunder)
B 25266,3,3 VM: ADD Blunders,K1
B 25269,2,2 VM: STORE Blunders
B 25271,3,3 VM: GOTO #R25196
B 25274,4,4 VM: SAY #R51199,9 "Okay, Boss, we'll see if it works."
B 25278,3,3 VM: SUB Dough,Bribe
B 25281,2,2 VM: STORE Dough
B 25283,4,4 VM: POKE 1,#R33891
B 25287,6,6 VM: IFPEEKEQ #R33895,1,#R25305
B 25293,2,2 VM: RND K1
B 25295,2,2 VM: MUL K6
B 25297,2,2 VM: ADD K13
B 25299,1,1 VM: INT
B 25300,2,2 VM: STORE ClientCost
B 25302,3,3 VM: GOTO #R25314
B 25305,2,2 VM: RND K1
B 25307,2,2 VM: MUL K10
B 25309,2,2 VM: ADD K11
B 25311,1,1 VM: INT
B 25312,2,2 VM: STORE ClientCost
B 25314,5,5 VM: SAY #R51223,1 "This year we can buy or sell clients for (ClientCost) grand each."
B 25319,3,3 VM: MUL Hoods,K5
B 25322,2,2 VM: STORE Tmp
B 25324,5,5 VM: IFGT Clients,Tmp,#R25345
B 25329,4,4 VM: SAY #R51241,9 "The boys is workin' real hard. Now, how many clients do we buy from the syndicate?"
B 25333,3,3 VM: GOTO #R25361
B 25336,4,4 VM: SAY #R51317,9 "Minuses won't wash here, Mugsy. How many do we buy?"
B 25340,3,3 VM: ADD Blunders,K1
B 25343,2,2 VM: STORE Blunders
B 25345,5,5 VM: IFLE K13,ClientCost,#R25357
B 25350,4,4 VM: SAY #R51312,8 "How many do we buy from the syndicate this year, Boss? ( The price is right!)."
B 25354,3,3 VM: GOTO #R25361
B 25357,4,4 VM: SAY #R51292,8 "How many do we buy from the syndicate this year, Boss?"
B 25361,3,3 VM: CALL #R27790 (get a number from the player)
B 25364,2,2 VM: LOAD Input
B 25366,2,2 VM: STORE Bought
B 25368,6,6 VM: IFPEEKEQ #R33896,2,#R25423
B 25374,6,6 VM: IFPEEKEQ #R33896,1,#R25336
B 25380,3,3 VM: MUL Bought,ClientCost
B 25383,2,2 VM: STORE Tmp
B 25385,3,3 VM: SUB Dough,Tmp
B 25388,2,2 VM: STORE Tmp
B 25390,5,5 VM: IFLE K0,Tmp,#R25402
B 25395,4,4 VM: SAY #R51340,9 "Cripes, Boss, you gotta be outa ya mind, we aint made of money."
B 25399,3,3 VM: GOTO #R25345
B 25402,2,2 VM: LOAD Tmp
B 25404,2,2 VM: STORE Dough
B 25406,3,3 VM: ADD Clients,Bought
B 25409,2,2 VM: STORE Clients
B 25411,3,3 VM: GOTO #R25505
B 25414,4,4 VM: SAY #R51461,1 "Cut the minus garbage, Mugsy!"
B 25418,3,3 VM: ADD Blunders,K1
B 25421,2,2 VM: STORE Blunders
B 25423,5,5 VM: IFGE K19,ClientCost,#R25435
B 25428,4,4 VM: SAY #R51382,8 "How many do ya wanna sell? ( The price is right!)."
B 25432,3,3 VM: GOTO #R25439
B 25435,4,4 VM: SAY #R51371,8 "How many do ya wanna sell?"
B 25439,3,3 VM: CALL #R27790 (get a number from the player)
B 25442,2,2 VM: LOAD Input
B 25444,2,2 VM: STORE Sold
B 25446,6,6 VM: IFPEEKEQ #R33896,2,#R25505
B 25452,6,6 VM: IFPEEKEQ #R33896,1,#R25414
B 25458,5,5 VM: IFGE Clients,Sold,#R25474
B 25463,5,5 VM: SAY #R51387,9 "Geez, Boss, we've only got (Clients) customers. If the boys think you wanna make a fast buck and then skip, you could be takin' an unexpected ride!"
B 25468,3,3 VM: CALL #R28297 (Louey charges hush money for a blunder)
B 25471,3,3 VM: GOTO #R25423
B 25474,5,5 VM: IFNE Clients,Sold,#R25483
B 25479,4,4 VM: SAY #R51483,9 "Jumpin' jellyfish, Boss,- how do ya expect us ta survive if ya sell all our clients to the syndicate?"
B 25483,3,3 VM: SUB Clients,Sold
B 25486,2,2 VM: STORE ClientsLeft
B 25488,5,5 VM: IFGT Hoods,ClientsLeft,#R25463
B 25493,3,3 VM: MUL Sold,ClientCost
B 25496,2,2 VM: ADD Dough
B 25498,2,2 VM: STORE Dough
B 25500,3,3 VM: SUB Clients,Sold
B 25503,2,2 VM: STORE Clients
B 25505,5,5 VM: IFNE K0,Dough,#R25517
B 25510,4,4 VM: SAY #R51534,1 "As you know, Mugsy, that means we aint got nuthin' left."
B 25514,3,3 VM: GOTO #R24745
B 25517,5,5 VM: SAY #R51554,0 "As you know, Boss, that leaves (Dough) thousand bucks in the safe. How many grand are ya gonna give the boys for artillery and ammo?"
B 25522,3,3 VM: GOTO #R25534
B 25525,4,4 VM: SAY #R51684,8 "Cut the negatives, sucker!"
B 25529,3,3 VM: ADD Blunders,K1
B 25532,2,2 VM: STORE Blunders
B 25534,3,3 VM: CALL #R27790 (get a number from the player)
B 25537,2,2 VM: LOAD Input
B 25539,2,2 VM: STORE Ammo
B 25541,6,6 VM: IFPEEKEQ #R33896,2,#R25621
B 25547,6,6 VM: IFPEEKEQ #R33896,1,#R25525
B 25553,3,3 VM: SUB Dough,Ammo
B 25556,2,2 VM: STORE Tmp
B 25558,5,5 VM: IFEQ K0,Tmp,#R25583
B 25563,5,5 VM: IFLT K0,Tmp,#R25595
B 25568,5,5 VM: SAY #R51612,9 "You aint thinkin' straight, Boss. There's only (Dough) grand left in the safe."
B 25573,3,3 VM: CALL #R28297 (Louey charges hush money for a blunder)
B 25576,4,4 VM: SAY #R51103,8 "How many thousand, Boss?"
B 25580,3,3 VM: GOTO #R25534
B 25583,4,4 VM: SAY #R51644,8 "Geez, there'll be nuthin' left. Tell me that again, Boss, I musta misheard you."
B 25587,3,3 VM: ADD Blunders,K1
B 25590,2,2 VM: STORE Blunders
B 25592,3,3 VM: GOTO #R25534
B 25595,5,5 VM: IFLT Hoods,Ammo,#R25641
B 25600,4,4 VM: SAY #R51699,9 "Gee, da boys is gonna be hoppin' mad, Boss- you sure got guts!"
B 25604,3,3 VM: DIV Ammo,Hoods
B 25607,2,2 VM: STORE Tmp
B 25609,5,5 VM: IFGT K05,Tmp,#R25625
B 25614,4,4 VM: POKE 1,#R33894
B 25618,3,3 VM: GOTO #R25629
B 25621,4,4 VM: SAY #R51734,9 "Ya gonna get da guys bumped off."
B 25625,4,4 VM: POKE 2,#R33894
B 25629,4,4 VM: POKE 2,#R33889
B 25633,3,3 VM: ADD Blunders,K1
B 25636,2,2 VM: STORE Blunders
B 25638,3,3 VM: GOTO #R25681
B 25641,3,3 VM: MUL Hoods,K2
B 25644,2,2 VM: STORE Tmp
B 25646,5,5 VM: IFLE Tmp,Ammo,#R25658
B 25651,4,4 VM: SAY #R51751,9 "Yeah, Boss, keep'em scared, eh!"
B 25655,3,3 VM: GOTO #R25672
B 25658,3,3 VM: MUL Hoods,K5
B 25661,2,2 VM: STORE Tmp
B 25663,5,5 VM: IFGT Hoods,Ammo,#R25677
B 25668,4,4 VM: SAY #R51770,9 "Cripes, Boss, they could fight a war with the hardware that'll buy."
B 25672,3,3 VM: ADD Blunders,K1
B 25675,2,2 VM: STORE Blunders
B 25677,4,4 VM: POKE 1,#R33894
B 25681,3,3 VM: SUB Dough,Ammo
B 25684,2,2 VM: STORE Dough
B 25686,3,3 VM: SUB Clients,Hoods
B 25689,2,2 VM: STORE Unsqueezed
B 25691,5,5 VM: IFLT K0,Unsqueezed,#R25725
B 25696,4,4 VM: SAY #R51809,9 "We got so few clients left that squeezin' them aint gonna pay your moll's hooch bills."
B 25700,3,3 VM: ADD Blunders,K1
B 25703,2,2 VM: STORE Blunders
B 25705,2,2 VM: LOAD K0
B 25707,2,2 VM: STORE Squeezed
B 25709,2,2 VM: LOAD K0
B 25711,2,2 VM: STORE Loan
B 25713,3,3 VM: GOTO #R25909
B 25716,4,4 VM: SAY #R51889,9 "Forget the negatives, Mugsy- just tell me how many customers to lean on this year."
B 25720,3,3 VM: ADD Blunders,K1
B 25723,2,2 VM: STORE Blunders
B 25725,5,5 VM: SAY #R51858,8 "We got (Unsqueezed) clients in need of protection, Boss. How many do we put the squeeze on this year?"
B 25730,3,3 VM: CALL #R27790 (get a number from the player)
B 25733,2,2 VM: LOAD Input
B 25735,2,2 VM: STORE Squeezed
B 25737,6,6 VM: IFPEEKEQ #R33896,2,#R25886
B 25743,6,6 VM: IFPEEKEQ #R33896,1,#R25716
B 25749,5,5 VM: IFGE Unsqueezed,Squeezed,#R25762
B 25754,5,5 VM: SAY #R51919,9 "Boss, there's only (Unsqueezed) clients, and da guys gotta make an honest livin'........ How many clients, Mugsy?"
B 25759,3,3 VM: GOTO #R25720
B 25762,5,5 VM: IFGE Dough,Squeezed,#R25828
B 25767,5,5 VM: SAY #R52074,9 "[But we've only got (Dough) grand./Have ya lost ya marbles, Mugsy? We've only $(Dough) thousand left./Cut the kiddin', Boss. You know there's only (Dough) grand in the safe.]"
B 25772,3,3 VM: ADD Blunders,K1
B 25775,2,2 VM: STORE Blunders
B 25777,3,3 VM: SUB Squeezed,Dough
B 25780,2,2 VM: STORE Tmp
B 25782,5,5 VM: IFGT K20,Tmp,#R25725
B 25787,5,5 VM: IFGT K800,Tmp,#R25800
B 25792,5,5 VM: SAY #R52083,9 "What wuz dat, Boss? I could've swore you said (Squeezed)."
B 25797,3,3 VM: GOTO #R25725
B 25800,3,3 VM: SUB Squeezed,Dough
B 25803,2,2 VM: STORE Loan
B 25805,2,2 VM: RND K1
B 25807,2,2 VM: MUL K60
B 25809,2,2 VM: ADD K40
B 25811,1,1 VM: INT
B 25812,2,2 VM: STORE Interest
B 25814,6,6 VM: SAY #R52114,9 "Great noos, Boss!...... I set up this deal wit' Nick the Greek. He's gonna lend you the other (Loan) grand at only (Interest) percent interest."
B 25820,3,3 VM: ADD Dough,Loan
B 25823,2,2 VM: STORE Dough
B 25825,3,3 VM: GOTO #R25842
B 25828,3,3 VM: DIV Unsqueezed,K3
B 25831,2,2 VM: STORE Tmp
B 25833,5,5 VM: IFGE Tmp,Squeezed,#R25886
B 25838,2,2 VM: LOAD K0
B 25840,2,2 VM: STORE Loan
B 25842,3,3 VM: MUL Hoods,K40
B 25845,2,2 VM: STORE Tmp
B 25847,5,5 VM: IFLT Squeezed,Tmp,#R25904
B 25852,4,4 VM: SAY #R52194,9 "Watch out, Boss, the boys aint gonna like workin' that hard."
B 25856,3,3 VM: ADD Dough,Ammo
B 25859,2,2 VM: STORE Dough
B 25861,3,3 VM: MUL Hoods,K50
B 25864,1,1 VM: NEG
B 25865,2,2 VM: ADD Squeezed
B 25867,2,2 VM: ADD Ammo
B 25869,2,2 VM: STORE Ammo
B 25871,3,3 VM: MUL Hoods,K50
B 25874,2,2 VM: STORE Squeezed
B 25876,3,3 VM: SUB Dough,Ammo
B 25879,2,2 VM: SUB Squeezed
B 25881,2,2 VM: STORE Dough
B 25883,3,3 VM: GOTO #R25909
B 25886,4,4 VM: SAY #R51971,9 "You sure don't dig da protection racket, - do ya, Boss?"
B 25890,3,3 VM: ADD Blunders,K1
B 25893,2,2 VM: STORE Blunders
B 25895,6,6 VM: IFPEEKEQ #R33896,2,#R25909
B 25901,3,3 VM: GOTO #R25838
B 25904,3,3 VM: SUB Dough,Squeezed
B 25907,2,2 VM: STORE Dough
B 25909,5,5 VM: IFEQ K0,Dough,#R25991
B 25914,3,3 VM: GOTO #R25929
B 25917,4,4 VM: SAY #R52262,8 "If dat means you want the cops to pay us, forget it. How much?"
B 25921,3,3 VM: ADD Blunders,K1
B 25924,2,2 VM: STORE Blunders
B 25926,3,3 VM: GOTO #R25934
B 25929,5,5 VM: SAY #R52217,8 "Outa you (Dough) grand, how much are you putting aside for the annual kickback to the cops?"
B 25934,3,3 VM: CALL #R27790 (get a number from the player)
B 25937,2,2 VM: LOAD Input
B 25939,2,2 VM: STORE Kickback
B 25941,6,6 VM: IFPEEKEQ #R33896,2,#R25995
B 25947,6,6 VM: IFPEEKEQ #R33896,1,#R25917
B 25953,5,5 VM: IFGT Kickback,Dough,#R25966
B 25958,3,3 VM: SUB Dough,Kickback
B 25961,2,2 VM: STORE Dough
B 25963,3,3 VM: GOTO #R25995
B 25966,5,5 VM: IFEQ K0,Dough,#R25987
B 25971,5,5 VM: SAY #R52353,9 "Geez, Boss, you sure are scared of these cops. But you musta forgot you only have (Dough) grand...... Anyway, I guess you want I should let da cops have the whole lot. ( Ya stoopid jerk )."
B 25976,2,2 VM: LOAD Dough
B 25978,2,2 VM: STORE Kickback
B 25980,2,2 VM: LOAD K0
B 25982,2,2 VM: STORE Dough
B 25984,3,3 VM: GOTO #R25995
B 25987,4,4 VM: SAY #R52289,9 "Boy are you scared of da cops! Well they're gonna get a dissy dis year'cos there aint no funds left. ( Ya stoopid wally )."
B 25991,2,2 VM: LOAD K0
B 25993,2,2 VM: STORE Kickback
B 25995,4,4 VM: POKE 2,#R33895
B 25999,6,6 VM: IFPEEKNE #R33892,2,#R26071
B 26005,3,3 VM: DIV Handout,Hoods
B 26008,2,2 VM: DIV K3
B 26010,2,2 VM: ADD K1
B 26012,2,2 VM: STORE Tmp
B 26014,4,4 VM: SAY #R50359,9 "You're through, Boss, the hit man from Detroit is on his way in,"
B 26018,3,3 VM: CALL #R28358 (shootout with the hit man from Detroit)
B 26021,6,6 VM: IFPEEKNE #R33892,3,#R26034
B 26027,4,4 VM: SAY #R50434,1 "Tough luck Boss, me and the boys'll give ya a decent funeral."
B 26031,3,3 VM: GOTO #R24745
B 26034,4,4 VM: SAY #R50398,1 "Geez, so much for the contract, you've eliminated their hit man."
B 26038,6,6 VM: IFPEEKNE #R33892,2,#R26067
B 26044,2,2 VM: RND K1
B 26046,2,2 VM: MUL K40
B 26048,2,2 VM: ADD K20
B 26050,2,2 VM: DIV K100
B 26052,2,2 VM: MUL Dough
B 26054,1,1 VM: INT
B 26055,2,2 VM: STORE Tmp
B 26057,3,3 VM: SUB Dough,Tmp
B 26060,2,2 VM: STORE Dough
B 26062,5,5 VM: SAY #R50471,9 "But its gonna cost ya (Tmp) grand to keep the cops quiet about all the people what got wasted in the shootout."
B 26067,4,4 VM: POKE 1,#R33892
B 26071,6,6 VM: IFPEEKEQ #R33894,1,#R26090
B 26077,2,2 VM: RND K1
B 26079,2,2 VM: STORE Tmp
B 26081,5,5 VM: IFGE K05,Tmp,#R26090
B 26086,4,4 VM: POKE 1,#R33894
B 26090,2,2 VM: RND K1
B 26092,2,2 VM: MUL K35
B 26094,2,2 VM: ADD K15
B 26096,2,2 VM: STORE Price
B 26098,3,3 VM: MUL Price,K100
B 26101,2,2 VM: ADD K05
B 26103,1,1 VM: INT
B 26104,2,2 VM: DIV K100
B 26106,2,2 VM: STORE Price
B 26108,3,3 VM: SUB K10,Price
B 26111,2,2 VM: SUB Blunders
B 26113,2,2 VM: STORE Tmp
B 26115,5,5 VM: IFNE K0,Tmp,#R26125
B 26120,3,3 VM: SUB Blunders,K1
B 26123,2,2 VM: STORE Blunders
B 26125,3,3 VM: ADD Dough,Kickback
B 26128,2,2 VM: ADD K1
B 26130,2,2 VM: STORE Tmp
B 26132,3,3 VM: MUL Dough,Dough
B 26135,2,2 VM: DIV Tmp
B 26137,2,2 VM: STORE Input
B 26139,3,3 VM: MUL Kickback,K8
B 26142,2,2 VM: STORE Raided
B 26144,3,3 VM: MUL Squeezed,Price
B 26147,2,2 VM: SUB Raided
B 26149,2,2 VM: STORE Raided
B 26151,3,3 VM: SUB K10,Price
B 26154,2,2 VM: SUB Blunders
B 26156,2,2 VM: STORE Tmp
B 26158,3,3 VM: DIV Raided,Tmp
B 26161,2,2 VM: STORE Raided
B 26163,2,2 VM: RND K1
B 26165,2,2 VM: MUL Kickback
B 26167,2,2 VM: STORE Tmp
B 26169,3,3 VM: SUB Input,Tmp
B 26172,2,2 VM: ADD Raided
B 26174,1,1 VM: INT
B 26175,2,2 VM: STORE Raided
B 26177,5,5 VM: IFLT K20,Raided,#R26186
B 26182,2,2 VM: LOAD K0
B 26184,2,2 VM: STORE Raided
B 26186,2,2 VM: SQRT Hoods
B 26188,2,2 VM: MUL Hoods
B 26190,2,2 VM: MUL Clients
B 26192,2,2 VM: STORE Tmp
B 26194,3,3 VM: ADD Ammo,Kickback
B 26197,1,1 VM: SQRT
B 26198,2,2 VM: MUL Clients
B 26200,2,2 VM: MUL Clients
B 26202,2,2 VM: DIV Tmp
B 26204,2,2 VM: STORE Recruits
B 26206,3,3 VM: MUL Blunders,K4
B 26209,2,2 VM: STORE Tmp
B 26211,3,3 VM: SUB Recruits,Tmp
B 26214,2,2 VM: STORE Recruits
B 26216,3,3 VM: MUL Blunders,K2
B 26219,2,2 VM: STORE Tmp
B 26221,3,3 VM: SUB Recruits,Tmp
B 26224,1,1 VM: INT
B 26225,2,2 VM: STORE Recruits
B 26227,6,6 VM: IFPEEKEQ #R33894,1,#R26238
B 26233,3,3 VM: ADD Recruits,Recruits
B 26236,2,2 VM: STORE Recruits
B 26238,5,5 VM: IFLE K0,Recruits,#R26250
B 26243,2,2 VM: LOAD K0
B 26245,2,2 VM: STORE Recruits
B 26247,3,3 VM: GOTO #R26259
B 26250,5,5 VM: IFGT K100,Recruits,#R26259
B 26255,2,2 VM: LOAD K99
B 26257,2,2 VM: STORE Recruits
B 26259,4,4 VM: POKE 1,#R33888
B 26263,2,2 VM: RND K1
B 26265,2,2 VM: MUL K10
B 26267,2,2 VM: STORE Tmp
B 26269,5,5 VM: IFGT K8,Tmp,#R26278
B 26274,4,4 VM: POKE 2,#R33888
B 26278,5,5 VM: IFGT K15b,Recruits,#R26287
B 26283,4,4 VM: SAY #R52535,9 "[Say, Boss, the word is you're doin' okay!/They're sayin' you're doin' a good job here, Boss./The Chicago mobs have heard of you now. They think you might be another Scarface.]"
B 26287,3,3 VM: MUL Ammo,K2
B 26290,2,2 VM: ADD K1
B 26292,2,2 VM: STORE Tmp
B 26294,3,3 VM: MUL Hoods,Hoods
B 26297,2,2 VM: DIV Tmp
B 26299,2,2 VM: STORE Killed
B 26301,3,3 VM: ADD Dough,K1
B 26304,2,2 VM: STORE Tmp
B 26306,3,3 VM: MUL Kickback,K20
B 26309,2,2 VM: DIV Tmp
B 26311,2,2 VM: STORE Tmp
B 26313,2,2 VM: RND K1
B 26315,2,2 VM: MUL Blunders
B 26317,2,2 VM: MUL K10
B 26319,2,2 VM: ADD Killed
B 26321,2,2 VM: SUB Tmp
B 26323,1,1 VM: INT
B 26324,2,2 VM: STORE Killed
B 26326,5,5 VM: IFLE K0,Killed,#R26338
B 26331,2,2 VM: LOAD K0
B 26333,2,2 VM: STORE Killed
B 26335,3,3 VM: GOTO #R26402
B 26338,5,5 VM: IFGT K100,Killed,#R26347
B 26343,2,2 VM: LOAD K99
B 26345,2,2 VM: STORE Killed
B 26347,5,5 VM: IFLT Killed,Hoods,#R26402
B 26352,3,3 VM: ADD Blunders,K6
B 26355,2,2 VM: STORE Killed
B 26357,2,2 VM: RND K1
B 26359,2,2 VM: ADD Blunders
B 26361,2,2 VM: ADD K5
B 26363,2,2 VM: DIV Killed
B 26365,2,2 VM: STORE Killed
B 26367,3,3 VM: ADD Hoods,K1
B 26370,2,2 VM: MUL Killed
B 26372,1,1 VM: INT
B 26373,2,2 VM: STORE Killed
B 26375,5,5 VM: IFGE K100,Killed,#R26384
B 26380,2,2 VM: LOAD K99
B 26382,2,2 VM: STORE Killed
B 26384,3,3 VM: MUL Hoods,K6
B 26387,2,2 VM: STORE Tmp
B 26389,5,5 VM: IFGT Tmp,Ammo,#R26398
B 26394,2,2 VM: HALF Killed
B 26396,2,2 VM: STORE Killed
B 26398,4,4 VM: SAY #R52544,9 "You aint doin' too good, Mugsy! The organisation is gettin' a bad reputation an some of da boys is thinkin' of gettin' out while they can."
B 26402,3,3 VM: SUB Hoods,Killed
B 26405,2,2 VM: ADD Recruits
B 26407,2,2 VM: STORE Hoods
B 26409,3,3 VM: ADD TotalKilled,Killed
B 26412,2,2 VM: STORE TotalKilled
B 26414,4,4 VM: SAY #R49784,9 "A year goes by ......"
B 26418,3,3 VM: CALL #R33994 ("A year goes by ......" animation)
B 26421,3,3 VM: ADD Year,K1
B 26424,2,2 VM: STORE Year
B 26426,4,4 VM: POKE 0,#R33897
B 26430,1,1 VM: END
B 26431,6,6 VM: IFPEEKEQ #R33890,2,#R26469
B 26437,5,5 VM: SAY #R52607,5 "Okay, Mugsy, me an the (Hoods) boys,"
B 26442,3,3 VM: MUL Year,K12
B 26445,2,2 VM: STORE Tmp
B 26447,5,5 VM: IFGT Tmp,TotalKilled,#R26460
B 26452,5,5 VM: SAY #R52631,5 "has had enough of your crazy mob for the last (Year) years. So we're off ta find some better rackets in [The Bahamas/Florida/Disneyland/Hawaii/Las Vegas]."
B 26457,3,3 VM: GOTO #R26465
B 26460,5,5 VM: SAY #R52705,5 "has done pretty good in the mob for the last (Year) years. So we're goin' ta invest in some new rackets in [Alcatraz/Sing - Sing/San Quentin/Siberia]."
B 26465,4,4 VM: SAY #R49774,9 "So long Mugsy."
B 26469,3,3 VM: SUB Hoods,K40
B 26472,2,2 VM: MUL K100
B 26474,2,2 VM: DIV K40
B 26476,2,2 VM: STORE HoodGrowth
B 26478,3,3 VM: DIV TotalTakings,HoodYears
B 26481,2,2 VM: STORE TotalTakings
B 26483,3,3 VM: SUB Clients,StartClients
B 26486,2,2 VM: MUL K100
B 26488,2,2 VM: DIV StartClients
B 26490,2,2 VM: STORE ClientGrowth
B 26492,3,3 VM: DIV TotalProfit,ClientYears
B 26495,2,2 VM: STORE TotalProfit
B 26497,3,3 VM: ADD Score,K10
B 26500,2,2 VM: STORE Score
B 26502,6,6 VM: IFPEEKEQ #R33890,2,#R26513
B 26508,3,3 VM: ADD Score,K10
B 26511,2,2 VM: STORE Score
B 26513,3,3 VM: SUB Years,Year
B 26516,2,2 VM: STORE Tmp
B 26518,5,5 VM: IFGE K4,Tmp,#R26527
B 26523,2,2 VM: LOAD K4
B 26525,2,2 VM: STORE Tmp
B 26527,3,3 VM: MUL Tmp,K3
B 26530,1,1 VM: NEG
B 26531,2,2 VM: ADD Score
B 26533,2,2 VM: STORE Score
B 26535,3,3 VM: DIV HoodGrowth,K10
B 26538,1,1 VM: INT
B 26539,2,2 VM: STORE Tmp
B 26541,5,5 VM: IFLE Km005,Tmp,#R26550
B 26546,2,2 VM: LOAD Km005
B 26548,2,2 VM: STORE Tmp
B 26550,5,5 VM: IFGE K15b,Tmp,#R26559
B 26555,2,2 VM: LOAD K15b
B 26557,2,2 VM: STORE Tmp
B 26559,3,3 VM: ADD Score,Tmp
B 26562,2,2 VM: STORE Score
B 26564,3,3 VM: SUB TotalTakings,K25
B 26567,2,2 VM: MUL K2
B 26569,1,1 VM: INT
B 26570,2,2 VM: STORE Tmp
B 26572,5,5 VM: IFLE K0,Tmp,#R26581
B 26577,2,2 VM: LOAD K0
B 26579,2,2 VM: STORE Tmp
B 26581,5,5 VM: IFGE K10,Tmp,#R26590
B 26586,2,2 VM: LOAD K10
B 26588,2,2 VM: STORE Tmp
B 26590,3,3 VM: ADD Tmp,Score
B 26593,2,2 VM: STORE Score
B 26595,3,3 VM: DIV ClientGrowth,K4
B 26598,1,1 VM: INT
B 26599,2,2 VM: STORE Tmp
B 26601,5,5 VM: IFLE Km010,Tmp,#R26610
B 26606,2,2 VM: LOAD Km010
B 26608,2,2 VM: STORE Tmp
B 26610,5,5 VM: IFGE K17,Tmp,#R26619
B 26615,2,2 VM: LOAD K17
B 26617,2,2 VM: STORE Tmp
B 26619,3,3 VM: ADD Score,Tmp
B 26622,2,2 VM: ADD K35b
B 26624,2,2 VM: SUB TotalBlunders
B 26626,2,2 VM: STORE Score
B 26628,3,3 VM: DIV TotalKilled,K4
B 26631,1,1 VM: INT
B 26632,2,2 VM: STORE Tmp
B 26634,5,5 VM: IFGE K20,Tmp,#R26643
B 26639,2,2 VM: LOAD K20
B 26641,2,2 VM: STORE Tmp
B 26643,3,3 VM: SUB Score,Tmp
B 26646,2,2 VM: STORE Score
B 26648,3,3 VM: SUB TotalProfit,K25c
B 26651,2,2 VM: MUL K20
B 26653,1,1 VM: INT
B 26654,2,2 VM: STORE Tmp
B 26656,5,5 VM: IFLE Km010,Tmp,#R26665
B 26661,2,2 VM: LOAD Km010
B 26663,2,2 VM: STORE Tmp
B 26665,5,5 VM: IFGE K10,Tmp,#R26674
B 26670,2,2 VM: LOAD K10
B 26672,2,2 VM: STORE Tmp
B 26674,3,3 VM: ADD Score,Tmp
B 26677,2,2 VM: STORE Score
B 26679,5,5 VM: IFGE K100,Score,#R26688
B 26684,2,2 VM: LOAD K100
B 26686,2,2 VM: STORE Score
B 26688,5,5 VM: IFLT K0,Score,#R26704
B 26693,2,2 VM: LOAD K0
B 26695,2,2 VM: STORE Score
B 26697,4,4 VM: POKE 1,#R33896
B 26701,3,3 VM: GOTO #R26714
B 26704,3,3 VM: DIV Score,K10
B 26707,1,1 VM: INT
B 26708,2,2 VM: ADD K2
B 26710,2,2 VM: DIV K100
B 26712,2,2 VM: STORE Tmp
B 26714,3,3 VM: CALL #R26740 (choose the end-of-game rating)
B 26717,7,7 VM: SAY #R52770,8 "You were <msg 0>. You scored (Score)%. Hows about another game, Mugsy?"
B 26724,3,3 VM: CALL #R27753 (get a yes/no answer)
B 26727,3,3 VM: JZ #R26735
B 26730,4,4 VM: POKE 1,#R33897
B 26734,1,1 VM: END
B 26735,4,4 VM: POKE 2,#R33897
B 26739,1,1 VM: END
c 26740 VM native: choose the end-of-game rating
D 26740 Called from the VM script at #R26714. Uses the value in v33 (the score divided into bands) to pick one of the rating words ("lousy", "ghastly", "swell" and so on) from the table at #R53301, and stores its address as the default sub-message (#R33898) for the "You were ..." message.
C 26740,2 L=33 (v33: the rating number worked out by the script)
C 26742,3 Load it into BCDE
C 26745,1 A=low byte
C 26746,3 Get the address of the rating word
C 26749,3 Make it the default sub-message for the "You were ..." message
C 26752,1 Done: HL points at the rating word
c 26753 Get the address of a rating word
D 26753 Returns the address of rating word number A (1-11) in the table of words at #R53301. Any other value, including 0, gives the twelfth word, "terrific", which has no end code (see #LINK(Bugs#terrific)(the bugs page)).
R 26753 Input:A Rating number
R 26753 Output:HL Address of the word
C 26753,3 Rating 1: "lousy"
C 26756,1 Count the rating down
C 26757,1 Return if this is the one
C 26758,3 Rating 2: "real bad"
C 26761,1 Count the rating down
C 26762,1 Return if this is the one
C 26763,3 Rating 3: "terrible"
C 26766,1 Count the rating down
C 26767,1 Return if this is the one
C 26768,3 Rating 4: "ghastly"
C 26771,1 Count the rating down
C 26772,1 Return if this is the one
C 26773,3 Rating 5: "poor"
C 26776,1 Count the rating down
C 26777,1 Return if this is the one
C 26778,3 Rating 6: "so-so"
C 26781,1 Count the rating down
C 26782,1 Return if this is the one
C 26783,3 Rating 7: "fair"
C 26786,1 Count the rating down
C 26787,1 Return if this is the one
C 26788,3 Rating 8: "good"
C 26791,1 Count the rating down
C 26792,1 Return if this is the one
C 26793,3 Rating 9: "okay"
C 26796,1 Count the rating down
C 26797,1 Return if this is the one
C 26798,3 Rating 10: "great"
C 26801,1 Count the rating down
C 26802,1 Return if this is the one
C 26803,3 Rating 11: "swell"
C 26806,1 Count the rating down
C 26807,1 Return if this is the one
C 26808,3 Anything else (including 0): "terrific" (see #LINK(Bugs#terrific)(the bugs page))
C 26811,1 Done: HL points at the rating word
c 26812 Draw the picture for a speech bubble layout
D 26812 IY points at a 4-byte bubble layout entry: byte 0 is the bubble placement chance, bytes 1-2 are the address of the picture data and byte 3 is the border colour. If the same layout is still on screen (33906=0) the screen is left alone except that the speech bubbles are wiped (cells with attribute 120 cleared); otherwise the screen is cleared and the picture is redrawn by #R31247.
R 26812 Input:IY Layout entry
@ 26812 label=DRAWLAYOUT
C 26812,3 Set the border colour for this layout
C 26815,2 Set the border to the layout's colour
C 26817,1 Keep the caller's HL
C 26818,3 Pick up the address of the layout's picture
C 26821,3 H=high byte of the picture address (HL=picture address)
C 26824,1 HL=the caller's HL again; the picture address is on the stack
C 26825,2 IY=picture data
C 26827,3 Has the layout changed?
C 26830,1 Test the layout-changed flag
C 26831,3 If so, draw the whole picture
C 26834,1 Otherwise just wipe the speech bubbles: they are the cells with attribute 120
C 26835,1 Save DE...
C 26836,1 ...and BC
C 26837,3 HL=display file
C 26840,3 DE=attribute file
C 26843,1 Reached the end of the attribute file?
C 26844,2 Is this the end of the attribute file (high byte 91)?
C 26846,2 Finish if so
C 26848,1 Is this cell part of a bubble (bright white)?
C 26849,2 Is the cell bright white paper (a bubble cell)?
C 26851,2 Jump if not
C 26853,1 Keep the cell's address
C 26854,2 Clear the 8 pixel rows of the cell
C 26856,2 Clear one pixel row of the cell
C 26858,1 Down to the next pixel row
C 26859,2 Repeat for all eight pixel rows
C 26861,1 Back to the top of the cell
C 26862,1 Next attribute
C 26863,1 Next cell
C 26864,2 Jump back unless a third of the screen is done
C 26866,1 A=H: the current screen third...
C 26867,2 Move to the next third
C 26869,1 H=the next third
C 26870,2 Carry on with the next cell
C 26872,1 Restore BC...
C 26873,1 ...DE...
C 26874,1 ...and HL
C 26875,1 Done: all speech bubbles are wiped
c 26876 Wait for a key to be pressed or for a timeout
D 26876 First waits until all keys are released, then waits (up to A periods of about one second each) for a key to be pressed. Used after each speech bubble.
R 26876 Input:A Number of timeout periods
@ 26876 label=WAITKEY
C 26876,1 Save AF...
C 26877,1 ...and BC
C 26878,1 B=number of timeout periods
C 26879,1 Select every keyboard half-row (high byte of the port = 0)
C 26880,2 Read every half-row of the keyboard
C 26882,2 Keep the key bits only
C 26884,2 Are all keys released?
C 26886,2 Wait until they are
C 26888,3 Wait about a second for a keypress
C 26891,2 Finish if a key was pressed
C 26893,2 Otherwise try again for up to B periods
C 26895,1 Restore BC...
C 26896,1 ...and AF
C 26897,1 Done: Z set if the time ran out, NZ if a key was pressed
c 26898 Wait for a keypress with a timeout (one period)
D 26898 Returns with the zero flag reset if a key was pressed.
C 26898,1 Save BC
C 26899,3 BC=loop count (about one second)
C 26902,3 Wait for a key or the timeout
C 26905,1 Restore BC
C 26906,1 Done
c 26907 Wait for a keypress for up to BC iterations
D 26907 Returns with the zero flag reset as soon as a key is pressed, or with the zero flag set after BC loops.
R 26907 Input:BC Loop count
C 26907,1 A=0: select every keyboard half-row
C 26908,2 Read every half-row of the keyboard
C 26910,2 Keep the key bits
C 26912,2 Is any key pressed?
C 26914,1 Return (zero flag reset) if so
C 26915,1 Count down
C 26916,1 Is BC zero? Test B...
C 26917,1 ...together with C
C 26918,2 Keep waiting until BC is zero
C 26920,1 Return with the zero flag set (timeout)
c 26921 Get the address of a character in the font
D 26921 The proportional font at #R27087 has 7 bytes per character (a width byte and six rows of pixels), starting with character 32. This routine computes 26863+7*A.
R 26921 Input:A Character code
R 26921 Output:HL Address of the character's width byte
@ 26921 label=CHARADDR
C 26921,1 Save DE
C 26922,1 HL=A
C 26923,2 HL=the character code
C 26925,1 DE=A
C 26926,1 DE=the character code
C 26927,1 HL=2*code
C 26928,1 HL=4*code
C 26929,1 HL=8*A
C 26930,1 Clear the carry flag
C 26931,2 HL=7*A
C 26933,3 Add #R26863 (the font minus 7*32)
C 26936,1 HL=address of the glyph
C 26937,1 Restore DE
C 26938,1 Done
b 26939 The current character
B 26939,1,1
c 26940 Print a character in the proportional font
D 26940 Prints character A at pixel offset C within the cell at HL. The glyph is six pixels high and starts one pixel row down. Characters may straddle two cells, so each row is shifted into place by #R27021, which also clears the pixels behind the glyph. The dollar sign and the comma get a seventh row (a tail below the line). On exit C and L have been moved past the character plus one pixel of spacing.
R 26940 Input:A Character code
R 26940 C Pixel offset (0-7) within the current cell
R 26940 HL Display file address
R 26940 Output:C Updated pixel offset
R 26940 L Updated column
@ 26940 label=PRINTCHAR
C 26940,3 Remember the character
C 26943,1 Save the character...
C 26944,1 ...and the registers
C 26945,1 (DE)
C 26946,1 (HL, the screen address)
C 26947,3 Get the address of its glyph
C 26950,1 DE=glyph
C 26951,1 Restore the screen address
C 26952,1 Keep the screen address
C 26953,1 Start one pixel row down
C 26954,1 A=width
C 26955,1 Point at the first row
C 26956,1 Save the width
C 26957,1 Build a mask of width+1 zero bits...
C 26958,1 One more bit of mask than the width
C 26959,2 Start from a full byte
C 26961,2 Shift in a zero from the left
C 26963,2 Shift again until the mask has the right number of leading zeros
C 26965,3 ...and store it
C 26968,2 Six rows
C 26970,3 Print a row
C 26973,1 Step on to the next row of the glyph
C 26974,1 Next pixel row
C 26975,2 Repeat for six rows
C 26977,3 Was it a dollar sign?
C 26980,2 Is it a dollar sign (36)?
C 26982,2 Jump if not
C 26984,2 Add the tail of the dollar sign below the line
C 26986,3 Print the extra pixel row
C 26989,2 Skip the comma test
C 26991,2 A comma?
C 26993,2 Jump if not
C 26995,2 Add the tail of the comma below the line
C 26997,3 Print the extra pixel row
C 27000,1 A=width
C 27001,1 Restore the screen address
C 27002,1 Restore DE
C 27003,1 Restore BC
C 27004,1 Add the old pixel offset
C 27005,1 +1 pixel of spacing
C 27006,2 Into the next cell?
C 27008,2 Jump if not
C 27010,2 Subtract the 8 pixels already passed
C 27012,1 Move to the next cell
C 27013,2 Check again
C 27015,1 C=new pixel offset
C 27016,1 Restore the character
C 27017,1 Done: HL, C updated to the next print position
b 27018 The glyph mask
B 27018,2,2
c 27020 Print one pixel row of a glyph (from DE)
D 27020 Fetches the row byte at DE and falls through to #R27021.
C 27020,1 Pick up the pixel row
c 27021 Print one pixel row of a glyph
D 27021 Shifts the pixel row in A right by C bits across a 16-bit word and ORs it into the two screen bytes at HL and HL+1, using the mask at #R27018.
R 27021 Input:A Pixel row
R 27021 C Pixel offset
R 27021 HL Display file address
C 27021,1 Save DE
C 27022,1 D=pixel row
C 27023,2 E=0 (the overflow into the next cell)
C 27025,1 Save BC
C 27026,1 A=pixel offset
C 27027,4 BC=glyph mask
C 27031,1 Is the offset 0?
C 27032,2 Jump if so
C 27034,2 Shift the row right one pixel...
C 27036,2 The bits that fall off go into E
C 27038,1 ...and the mask, bringing in a 1
C 27039,2 Shift a 1 into the mask (B)...
C 27041,2 ...and on into C
C 27043,1 One fewer shift to go
C 27044,2 Repeat for each pixel of the offset
C 27046,1 Clear the pixels behind the glyph in the first cell...
C 27047,1 Keep the background pixels outside the glyph
C 27048,1 ...and draw the left part of the row
C 27049,1 Store the combined byte
C 27050,1 Next cell
C 27051,1 Do the same for the second cell
C 27052,1 Keep the background pixels in the second cell
C 27053,1 Add the overflow from the shifted row
C 27054,1 Store it
C 27055,1 Back to the first cell
C 27056,1 Restore BC
C 27057,1 Restore DE
C 27058,1 Done
b 27059 The attribute for the status line
B 27059,1,1
c 27060 Clear a character cell and set its attribute
D 27060 Clears the eight bytes of the character cell at HL and sets its attribute to the value at #R27059.
R 27060 Input:HL Display file address
C 27060,1 Save the cell address
C 27061,1 Keep the attribute value
C 27062,2 8 pixel rows
C 27064,2 Clear one
C 27066,1 Next pixel row
C 27067,1 One fewer row to clear
C 27068,2 Repeat for all eight rows
C 27070,1 Work out the attribute address from the display file address
C 27071,1 H-1: the display file third is now 0-2 in bits 3-4
C 27072,1 Move the third number...
C 27073,1 ...down into the low bits...
C 27074,1 ...(three rotates)
C 27075,2 Keep the two bits of the third
C 27077,2 Add the high byte of the attribute file
C 27079,1 H=attribute address high byte
C 27080,3 Set the attribute
C 27083,1 Set the cell's attribute
C 27084,1 Restore the attribute value
C 27085,1 Restore the screen address
C 27086,1 Done: the cell is blank with the new attribute
b 27087 Proportional font
D 27087 Used by #R26940 for the text in the speech bubbles. Each character has 7 bytes: the width in pixels followed by six pixel rows (the font is only six pixels high). Characters 32-122 are present; lower case letters are drawn as small capitals. #HTML[<img src="../images/font.png" alt="The proportional font" />]
B 27087,7,7 Character 32 (space): width 2
B 27094,7,7 Character 33 (!): width 1
B 27101,7,7 Character 34 (double quote): width 3
B 27108,7,7 Character 35 (#): width 5
B 27115,7,7 Character 36 ($): width 5
B 27122,7,7 Character 37 (%): width 5
B 27129,7,7 Character 38 (&): width 5
B 27136,7,7 Character 39 ('): width 2
B 27143,7,7 Character 40 ((): width 2
B 27150,7,7 Character 41 ()): width 2
B 27157,7,7 Character 42 (*): width 5
B 27164,7,7 Character 43 (+): width 5
B 27171,7,7 Character 44 (,): width 2
B 27178,7,7 Character 45 (-): width 4
B 27185,7,7 Character 46 (.): width 2
B 27192,7,7 Character 47 (/): width 5
B 27199,7,7 Character 48 (0): width 4
B 27206,7,7 Character 49 (1): width 3
B 27213,7,7 Character 50 (2): width 4
B 27220,7,7 Character 51 (3): width 4
B 27227,7,7 Character 52 (4): width 4
B 27234,7,7 Character 53 (5): width 4
B 27241,7,7 Character 54 (6): width 4
B 27248,7,7 Character 55 (7): width 4
B 27255,7,7 Character 56 (8): width 4
B 27262,7,7 Character 57 (9): width 4
B 27269,7,7 Character 58 (:): width 1
B 27276,7,7 Character 59 (;): width 2
B 27283,7,7 Character 60 (<): width 3
B 27290,7,7 Character 61 (=): width 4
B 27297,7,7 Character 62 (>): width 3
B 27304,7,7 Character 63 (?): width 5
B 27311,7,7 Character 64 (@): width 5
B 27318,7,7 Character 65 (A): width 6
B 27325,7,7 Character 66 (B): width 6
B 27332,7,7 Character 67 (C): width 6
B 27339,7,7 Character 68 (D): width 6
B 27346,7,7 Character 69 (E): width 6
B 27353,7,7 Character 70 (F): width 6
B 27360,7,7 Character 71 (G): width 6
B 27367,7,7 Character 72 (H): width 6
B 27374,7,7 Character 73 (I): width 5
B 27381,7,7 Character 74 (J): width 6
B 27388,7,7 Character 75 (K): width 5
B 27395,7,7 Character 76 (L): width 5
B 27402,7,7 Character 77 (M): width 6
B 27409,7,7 Character 78 (N): width 6
B 27416,7,7 Character 79 (O): width 6
B 27423,7,7 Character 80 (P): width 6
B 27430,7,7 Character 81 (Q): width 6
B 27437,7,7 Character 82 (R): width 6
B 27444,7,7 Character 83 (S): width 6
B 27451,7,7 Character 84 (T): width 5
B 27458,7,7 Character 85 (U): width 6
B 27465,7,7 Character 86 (V): width 6
B 27472,7,7 Character 87 (W): width 6
B 27479,7,7 Character 88 (X): width 5
B 27486,7,7 Character 89 (Y): width 5
B 27493,7,7 Character 90 (Z): width 6
B 27500,7,7 Character 91 ([): width 3
B 27507,7,7 Character 92 (backslash): width 5
B 27514,7,7 Character 93 (]): width 3
B 27521,7,7 Character 94 (^): width 5
B 27528,7,7 Character 95 (_): width 5
B 27535,7,7 Character 96 (`): width 5
B 27542,7,7 Character 97 (a): width 4
B 27549,7,7 Character 98 (b): width 4
B 27556,7,7 Character 99 (c): width 4
B 27563,7,7 Character 100 (d): width 4
B 27570,7,7 Character 101 (e): width 4
B 27577,7,7 Character 102 (f): width 4
B 27584,7,7 Character 103 (g): width 4
B 27591,7,7 Character 104 (h): width 4
B 27598,7,7 Character 105 (i): width 3
B 27605,7,7 Character 106 (j): width 4
B 27612,7,7 Character 107 (k): width 4
B 27619,7,7 Character 108 (l): width 4
B 27626,7,7 Character 109 (m): width 5
B 27633,7,7 Character 110 (n): width 5
B 27640,7,7 Character 111 (o): width 4
B 27647,7,7 Character 112 (p): width 4
B 27654,7,7 Character 113 (q): width 4
B 27661,7,7 Character 114 (r): width 4
B 27668,7,7 Character 115 (s): width 4
B 27675,7,7 Character 116 (t): width 3
B 27682,7,7 Character 117 (u): width 4
B 27689,7,7 Character 118 (v): width 4
B 27696,7,7 Character 119 (w): width 5
B 27703,7,7 Character 120 (x): width 5
B 27710,7,7 Character 121 (y): width 4
B 27717,7,7 Character 122 (z): width 4
c 27724 Print a character using the ROM font
D 27724 Used for the status line at the bottom of the screen. Copies the 8x8 glyph from the ROM character set (15360+8*A) to the cell at HL, then moves HL one cell right.
R 27724 Input:A Character code
R 27724 HL Display file address
@ 27724 label=ROMCHAR
C 27724,1 Save DE (the screen address)
C 27725,1 Save BC...
C 27726,1 ...and HL
C 27727,1 HL=character code
C 27728,2 HL=character code
C 27730,1 HL=2*code
C 27731,1 HL=4*code
C 27732,1 HL=8*code
C 27733,3 Add 15360 (the ROM character set minus 256)
C 27736,1 HL=address of the glyph in the ROM font
C 27737,1 DE=screen address
C 27738,1 Keep the screen address
C 27739,1 HL=screen, DE=glyph
C 27740,2 8 pixel rows
C 27742,1 Copy a row
C 27743,1 Store the glyph row on the screen
C 27744,1 Next glyph row
C 27745,1 Next pixel row
C 27746,2 Repeat for all 8 rows
C 27748,1 HL=screen address
C 27749,1 Restore BC
C 27750,1 Restore DE
C 27751,1 Move one cell right
C 27752,1 Done: the character is on screen and HL has moved right
c 27753 VM native: get a yes/no answer
D 27753 Reads a line of input and returns with the zero flag set for "Y" or "y" and reset for "N" or "n". Any other answer makes Louey say "Don't get smart wit' me, Mugsy!..." (script at #R27785) and asks again.
@ 27753 label=YESNO
C 27753,3 Read a line of input
C 27756,3 Pick up the first character
C 27759,2 "Y"?
C 27761,1 Return with the zero flag set if so
C 27762,2 "y"?
C 27764,1 Return with the zero flag set (yes)
C 27765,2 "N"?
C 27767,2 Jump if so
C 27769,2 "n"?
C 27771,2 Jump if so (no)
C 27773,4 Otherwise Louey says "Don't get smart wit' me, Mugsy!..."
C 27777,3 Run the script that says "Don't get smart wit' me"
C 27780,2 And asks again
C 27782,2 Reset the zero flag for "no"
C 27784,1 Return with the zero flag reset (no)
b 27785 VM script: complain about a yes/no answer
B 27785,4,4 VM: SAY #R52964,8 "Don't get smart wit' me, Mugsy! Just " yeah" or " nope" is fine."
B 27789,1,1 VM: END
c 27790 VM native: get a number from the player
D 27790 Reads a line of input and parses it into v35 (in hundredths, like all VM numbers). On an invalid entry Louey complains (script at #R27807 or #R27828 for fractions) and the blunder count v11 goes up. Flag 8 (#R33896) is set to the type of the answer: 1 = negative, 2 = zero, 3 = 0.01 (not possible from the keyboard), 4 = anything else.
@ 27790 label=GETNUMBER
C 27790,3 Read a line of input
C 27793,3 Parse it as a number into v35
C 27796,2 Jump unless it was invalid
C 27798,4 Louey says "What wuz dat, Boss?..." (and the blunder count goes up)
C 27802,3 Run the script that asks what he said
C 27805,2 Ask again
b 27807 VM script: complain about an invalid number
D 27807 Also counts a blunder (v11).
B 27807,4,4 VM: SAY #R52861,8 "[What wuz dat, Boss? I missed it/It's okay, Boss - this line aint tapped. Let's have the answer]."
B 27811,3,3 VM: ADD Blunders,K1
B 27814,2,2 VM: STORE Blunders
B 27816,1,1 VM: END
c 27817 Complain about a fraction and try again
D 27817 Entered with the carry flag reset when the number contained a decimal point.
C 27817,2 Jump if there was no decimal point
C 27819,4 Louey complains about fractions (another blunder)
C 27823,3 Run the script that complains about fractions
C 27826,2 Ask again
b 27828 VM script: complain about a fraction
B 27828,4,4 VM: SAY #R52957,8 "[Geez, Boss, fractions makes my head hurt. Gimme a good answer./Cripes, Boss, don't make wit' da fractions. I never did learn to dig them. Let's have it in good numbers!]"
B 27832,3,3 VM: GOTO #R27811
c 27835 Classify the number entered
D 27835 Sets flag 8 (#R33896) according to the value in BCDE: 1 if negative, 2 if zero, 3 if exactly 1 (0.01), 4 otherwise.
R 27835 Input:BCDE Number
C 27835,2 Is the number negative?
C 27837,2 Jump if not
C 27839,2 Type 1: negative
C 27841,3 Store the type in flag 8
C 27844,1 Done
C 27845,1 Is it at least 2.56?
C 27846,1 Combine the upper bytes
C 27847,1 ...
C 27848,2 Jump if so
C 27850,1 Is the low byte zero?
C 27851,1 Test the low byte
C 27852,2 Jump if not
C 27854,2 Type 2: zero
C 27856,2 Store the type
C 27858,2 Is it exactly 0.01?
C 27860,2 Type 3 if so
C 27862,2 Store the type
C 27864,2 Type 4: anything else
C 27866,2 Store the type
b 27868 The minus-sign flag
B 27868,1,1
c 27869 Parse the input buffer as a number
D 27869 Checks the text at 23808 for an optional sign, digits and a decimal point, then runs the small VM scripts at #R27995, #R28000 and #R28006 to accumulate the value in v35 (each digit: v35=v35*10+digit*100). Returns with the zero flag reset if the entry was not a valid whole number, and with the carry flag reset if it contained a decimal point.
C 27869,3 Point HL at the input
C 27872,1 Pick up the first character
C 27873,1 Test the first character
C 27874,1 Return (zero flag set: invalid) if the line is empty
C 27875,2 A minus sign?
C 27877,2 Jump if so
C 27879,2 A plus sign?
C 27881,2 Jump if so
C 27883,2 A decimal point?
C 27885,3 Jump if so
C 27888,3 Is it a digit?
C 27891,1 Return (zero flag set: invalid) if not
C 27892,1 Next character
C 27893,1 A=the next character
C 27894,1 End of the line?
C 27895,2 Jump if so: the entry is valid
C 27897,2 A decimal point?
C 27899,3 Jump if so
C 27902,3 A digit?
C 27905,1 Return (invalid) if not
C 27906,2 Check the next character
C 27908,4 Now convert the number
C 27912,1 Clear the minus flag
C 27913,3 Store it: no minus sign yet
C 27916,3 Pick up the first character
C 27919,2 A minus sign?
C 27921,2 Jump if not
C 27923,3 Set the minus flag
C 27926,2 Skip over the sign
C 27928,2 A plus sign?
C 27930,2 Jump if not
C 27932,2 Skip the sign
C 27934,4 Run the VM script that sets v35 to 0
C 27938,3 Run the script: v35=0
C 27941,3 Next character
C 27944,1 End of the line?
C 27945,2 Jump if so
C 27947,4 Run the VM script that multiplies v35 by 10
C 27951,3 Run the script: v35=v35*10
C 27954,3 A=the digit
C 27957,2 Convert it from ASCII
C 27959,1 BCDE=digit
C 27960,2 D=0
C 27962,1 B=0
C 27963,1 C=0: BCDE=the digit
C 27964,2 Store it in v33
C 27966,3 Store the digit in v33
C 27969,4 Run the VM script that adds 100*v33 to v35
C 27973,3 Run the script: add 100*v33 to v35 (the number is kept in hundredths)
C 27976,2 Next character
C 27978,2 Next character
C 27980,2 Load v35 into BCDE
C 27982,3 BCDE=the number
C 27985,3 Was there a minus sign?
C 27988,1 Test the minus-sign flag
C 27989,3 Negate the number if so
C 27992,2 Reset the zero flag: the entry was valid
C 27994,1 Done: Z set if the entry was invalid, NZ if it was valid
b 27995 VM script: set the input value to zero
B 27995,2,2 VM: LOAD K0
B 27997,2,2 VM: STORE Input
B 27999,1,1 VM: END
b 28000 VM script: multiply the input value by 10
B 28000,3,3 VM: MUL Input,K10
B 28003,2,2 VM: STORE Input
B 28005,1,1 VM: END
b 28006 VM script: add a digit to the input value
D 28006 v33 holds the digit; it is multiplied by 100 (the fixed-point scale) and added to v35.
B 28006,3,3 VM: MUL Tmp,K100
B 28009,2,2 VM: STORE Tmp
B 28011,3,3 VM: ADD Input,Tmp
B 28014,2,2 VM: STORE Input
B 28016,1,1 VM: END
c 28017 Set the "decimal point" result
D 28017 Returns with the zero flag reset and the carry flag set.
C 28017,2 Reset the zero flag...
C 28019,1 ...and set the carry flag: a decimal point was found
C 28020,1 Done: NZ and carry set means a decimal point
c 28021 Check whether A is a digit
D 28021 Returns with the carry flag set if A is "0"-"9".
R 28021 Input:A Character code
R 28021 Output:F Carry set if A is a digit
C 28021,2 Below "0"?
C 28023,2 Jump if so
C 28025,2 Below ":" (i.e. "0"-"9")?
C 28027,1 Return with the carry flag set if so
C 28028,1 Set the zero flag (and reset the carry flag): not a digit
C 28029,1 Done: Z means not a digit
c 28030 Clear a row of character cells
D 28030 Clears B cells starting at HL (via #R27060).
R 28030 Input:B Number of cells
R 28030 HL Display file address
C 28030,3 Clear a cell and set its attribute
C 28033,1 Next cell
C 28034,2 Repeat for the whole row of cells
C 28036,1 Done
c 28037 Read a line of input in the answer bubble
D 28037 Clears the answer bubble on the right of the screen, then reads keys (via #R28221) into the buffer at 23808, echoing them in the proportional font. DELETE (12) and LEFT (8) rub out the last character, ENTER (13) ends the line. The line is terminated with a zero byte.
@ 28037 label=READLINE
C 28037,3 Fill the input buffer with 20 spaces
C 28040,3 DE=the next byte
C 28043,3 BC=19: copy the first space along
C 28046,2 Put a space in the first byte
C 28048,2 Fill the 20 bytes with spaces
C 28050,3 Clear the answer bubble, line by line
C 28053,2 Eight cells in the row
C 28055,3 Clear the first row of the bubble (8 cells)
C 28058,3 HL=the second row
C 28061,2 B=10 cells
C 28063,3 Clear it
C 28066,3 HL=the third row
C 28069,2 B=12 cells
C 28071,3 Clear it
C 28074,3 HL=the fourth row
C 28077,2 B=10 cells
C 28079,3 Clear it
C 28082,3 HL=the fifth row
C 28085,2 B=8 cells
C 28087,3 Clear it
C 28090,3 HL=the tail of the bubble
C 28093,2 B=2 cells
C 28095,3 Clear it
C 28098,3 HL=the end of the tail
C 28101,2 B=1 cell
C 28103,3 Clear it
C 28106,3 HL=the last cell of the tail
C 28109,2 B=1 cell
C 28111,3 Clear it
C 28114,3 HL=start of the answer line
C 28117,2 C=pixel offset 0
C 28119,3 DE=input buffer
C 28122,2 B counts the characters typed
C 28124,3 Wait for a key (flashing the cursor)
C 28127,2 ENTER?
C 28129,2 Finish if so
C 28131,2 LEFT (CAPS SHIFT+5)?
C 28133,2 Rub out if so
C 28135,2 DELETE (CAPS SHIFT+0)?
C 28137,2 Rub out if so
C 28139,2 Ignore other control keys
C 28141,2 Control key: ignore it
C 28143,2 Ignore graphics and keyword codes
C 28145,2 Graphics or keyword: ignore it
C 28147,3 Echo the character
C 28150,1 Count it
C 28151,1 Store it in the buffer
C 28152,1 Next byte of the buffer
C 28153,1 Has the line reached column 30?
C 28154,2 Keep the column number
C 28156,2 Has it reached column 30 (the right-hand end of the bubble)?
C 28158,2 Get another key if not
C 28160,3 The line is full: only ENTER or rubbing out will do
C 28163,2 Rub out?
C 28165,2 Yes
C 28167,2 Delete?
C 28169,2 Yes
C 28171,2 ENTER?
C 28173,2 Not a wanted key: wait for another
C 28175,1 Terminate the input with a zero byte
C 28176,1 Store the terminator
C 28177,1 Return
C 28178,1 Anything to rub out?
C 28179,1 Test the count
C 28180,2 Ignore the key if not
C 28182,1 One character fewer
C 28183,1 Back up in the buffer
C 28184,1 Save BC...
C 28185,1 ...and HL
C 28186,2 Print two spaces over the cursor
C 28188,3 Print a space over the cursor
C 28191,3 And another to erase the character
C 28194,1 Restore the screen position
C 28195,1 Restore the count
C 28196,1 Save the screen position
C 28197,1 Get the width of the character being rubbed out
C 28198,3 Get the glyph address of the character being rubbed out
C 28201,1 A=its width
C 28202,1 Restore the screen position
C 28203,1 +1 pixel of spacing
C 28204,1 Move the print position back by that many pixels
C 28205,2 Work out the pixel offset after moving back
C 28207,2 Is the offset negative?
C 28209,2 No: done
C 28211,1 Back one cell
C 28212,2 Add a cell's 8 pixels
C 28214,2 Check again
C 28216,1 C=new pixel offset
C 28217,2 Wait for the next key
b 28219 The cursor character
B 28219,2,2
c 28221 Wait for a key, flashing the cursor
D 28221 Calls #R28266 to wait for a key while flashing an asterisk cursor (every fourth frame) in the answer bubble.
R 28221 Output:A Key code (from LAST-K)
C 28221,3 Wait one frame and check for a key
C 28224,1 Save the key
C 28225,1 Save HL
C 28226,1 Save BC
C 28227,3 Advance the flash counter (0-3)
C 28230,1 Add one
C 28231,2 Wrap round after 3
C 28233,3 Store the counter
C 28236,3 Pick up the cursor character
C 28239,2 Jump unless it is time to flash
C 28241,2 Swap between "*" and a space
C 28243,2 A=42: the asterisk cursor
C 28245,2 It was a space: switch to the asterisk
C 28247,2 A=32: a space
C 28249,3 Store the cursor character
C 28252,3 Print the cursor
C 28255,2 A=space: blank the next position
C 28257,3 Print it
C 28260,1 Restore BC
C 28261,1 Restore HL
C 28262,1 Restore the key
C 28263,2 Back for another frame if no key was pressed
C 28265,1 Return
c 28266 Wait one frame and read the keyboard
D 28266 Enables interrupts long enough for one ROM interrupt (which scans the keyboard), then checks bit 5 of FLAGS to see if a new key has been pressed.
R 28266 Output:A Key code (if the zero flag is reset)
C 28266,2 Save IY
C 28268,1 Save HL
C 28269,1 Save BC
C 28270,4 Restore IY for the ROM interrupt routine
C 28274,1 Let one interrupt happen (the ROM scans the keyboard)
C 28275,1 Wait for the next interrupt
C 28276,1 Interrupts off again
C 28277,3 Has a new key been pressed?
C 28280,2 Is the ROM's new-key flag (bit 5 of FLAGS) set?
C 28282,2 Jump if not
C 28284,2 Acknowledge it
C 28286,3 Store the flags
C 28289,3 A=the key code
C 28292,1 Restore BC
C 28293,1 Restore HL
C 28294,2 Restore IY
C 28296,1 Return
c 28297 VM native: Louey charges hush money for a blunder
D 28297 Runs the VM script at #R28304. Each blunder increments v11; if the safe holds enough, Louey asks for one grand (or a tenth of the safe, if it holds 19 grand or more) to keep quiet about it.
@ 28297 label=HUSHMONEY
C 28297,4 Run the script at IY
C 28301,3 Run it: the script's own END returns to the caller
b 28304 VM script: Louey's hush money
D 28304 Run by #R28297 after a blunder.
B 28304,3,3 VM: ADD Blunders,K1
B 28307,2,2 VM: STORE Blunders
B 28309,5,5 VM: IFLE K3,Dough,#R28320
B 28314,3,3 VM: ADD Blunders,K1
B 28317,2,2 VM: STORE Blunders
B 28319,1,1 VM: END
B 28320,5,5 VM: IFLE K19,Dough,#R28344
B 28325,3,3 VM: DIV Dough,K10
B 28328,1,1 VM: INT
B 28329,2,2 VM: STORE Tmp
B 28331,3,3 VM: SUB Dough,Tmp
B 28334,2,2 VM: STORE Dough
B 28336,5,5 VM: SAY #R53256,5 "[Your stoopidity takes my breath away, Mugsy. But for a mere (Tmp) grand I won't tell nobody./Mugsy! You're so dumb. It's gonna cost you (Tmp) G's ta make me forget it.]"
B 28341,3,3 VM: GOTO #R28353
B 28344,4,4 VM: SAY #R53164,5 "[Dat was real stoopid, Boss! If your boys heard about it you wud get more laughs than Jack Benny. However, for one crummy grand I guarantee ta keep my trap shut./Cripes, Boss, sometimes you're real dumb. But for a lousy grand I can be persuaded not to spill da beans about your stoopidity.]"
B 28348,3,3 VM: SUB Dough,K1
B 28351,2,2 VM: STORE Dough
B 28353,4,4 VM: SAY #R53263,9 "Gee ta, Boss! Now tell me........."
B 28357,1,1 VM: END
c 28358 VM native: shootout with the hit man from Detroit
D 28358 Works out Mugsy's hit points from v33 (set by the script from the handout: (low byte of v33 AND 7)+1, or 8 if v33 is 2.56 or more) and plays the shootout at #R42112. On return flag 4 (#R33892) is set to the result: 1 = the hit man was killed, 2 = the hit man was killed but bystanders were hit (the cops then want 20-60% of the safe), 3 = Mugsy was killed.
@ 28358 label=HITMAN
C 28358,2 Variable 33 holds the handout, set by the script
C 28360,3 BCDE=the handout (as a fixed-point number)
C 28363,1 Combine the upper three bytes
C 28364,1 ...
C 28365,1 ...
C 28366,1 A=the low byte of the handout
C 28367,2 The upper bytes are zero: use the low byte as it is
C 28369,2 The handout is 2.56 or more: use 255 (8 hit points)
C 28371,3 Play the shootout (A gives Mugsy's hit points)
C 28374,1 Save the result
C 28375,3 Read the keyboard flags
C 28378,2 Forget any keypress left over from the shootout
C 28380,3 Store the flags
C 28383,1 Restore the result
C 28384,2 Was Mugsy killed (bit 0)?
C 28386,2 No
C 28388,2 A=3: Mugsy was killed
C 28390,3 Store the outcome in flag 4
C 28393,1 Return
C 28394,2 Were any bystanders hit (bits 2 and 3)?
C 28396,2 A=1: the hit man was killed and no bystanders were hurt
C 28398,2 Zero: store 1
C 28400,2 A=2: the hit man was killed but bystanders were hit
C 28402,2 Store the outcome
t 28404 Status line templates
D 28404 "HOODS ... CUSTOMERS ..." and "DOUGH IN DA SAFE $..." (32 characters each), filled in by #R28468 and #R28504.
B 28404,32,32 "HOODS         CUSTOMERS         "
B 28436,32,32 "DOUGH IN DA SAFE $              "
c 28468 Print the first status line
D 28468 Prints "HOODS nn CUSTOMERS nnn" on the second-to-last line of the screen using the values of v3 and v8.
C 28468,3 HL=the template for the number of hoods
C 28471,2 A=7: the field is seven characters wide
C 28473,2 D=3: variable 3 holds the number of hoods
C 28475,3 Format it into the template
C 28478,3 HL=the template for the number of customers
C 28481,2 A=7: the field is seven characters wide
C 28483,2 D=8: variable 8 holds the number of customers
C 28485,3 Format it into the template
C 28488,2 B=32: the whole line
C 28490,3 DE=the text of the line
C 28493,3 HL=the second-to-last character row
C 28496,1 A=the next character
C 28497,3 Print it
C 28500,1 Next character
C 28501,2 Loop for the whole line
C 28503,1 Return
c 28504 Print the second status line
D 28504 Prints "DOUGH IN DA SAFE $nnn" using the value of v7.
C 28504,3 HL=the template for the money in the safe
C 28507,2 A=7: the field is seven characters wide
C 28509,2 D=7: variable 7 holds the money in the safe
C 28511,3 Format it into the template
C 28514,2 B=32: the whole line
C 28516,3 DE=the text of the line
C 28519,3 HL=the last character row
C 28522,1 A=the next character
C 28523,3 Print it
C 28526,1 Next character
C 28527,2 Loop for the whole line
C 28529,1 Return
c 28530 Print a VM variable into a status line template
D 28530 Formats variable D into the template at HL (A characters long) via #R29630.
R 28530 Input:A Field width
R 28530 D Variable number
R 28530 HL Template address
C 28530,1 Save the template address
C 28531,1 L=the variable number
C 28532,3 BCDE=its value
C 28535,1 HL=the template address
C 28536,3 Remember where the number goes
C 28539,2 Blank the field with spaces
C 28541,1 Next character of the field
C 28542,1 One fewer
C 28543,2 Loop until the field is blank
C 28545,3 Print the value into the field
b 28548 The SAY flags
B 28548,1,1
c 28549 Show a message in a speech bubble
D 28549 The handler for VM op 1 (SAY, #R30225) jumps here. This is the heart of the comic strip display. HL holds the address of a message and A holds a flags byte:
D 28549 #TABLE(default,centre,:w) { =h Bits | =h Meaning } { 0-1 | Non-zero: wait for a keypress (with timeout) afterwards } { 2-3 | Bubble placement: 0 = random entry from the layout table at #R33902; 4 (bit 2) = the fixed entry at #R33909 (the answer bubble); 8 (bit 3) = keep the current entry } { 4-6 | 16 = play the theme tune (#R32785) } TABLE#
R 28549 The message is rendered into the text buffer at 23808 (expanding dictionary words and any variables, which are taken from the VM byte stream after the SAY instruction), the picture is redrawn if the layout has changed, the status lines are printed and the text is word-wrapped into the bubble by #R28757.
N 28549 Input:A Flags HL Message address
@ 28549 label=SAY
C 28549,3 Save the SAY flags
C 28552,1 Save the message address
C 28553,4 Point IY at the fixed "answer" bubble layout
C 28557,2 Keep bits 2 and 3 of the flags
C 28559,2 Bit 2 set?
C 28561,2 Use the fixed layout if so
C 28563,4 Otherwise start with the current layout
C 28567,2 Bit 3 set?
C 28569,2 Keep the current layout if so
C 28571,4 Otherwise pick a layout at random: point IY at this year's layout table
C 28575,2 A=100: the upper limit
C 28577,3 A=random number 0-100
C 28580,3 Compare it with the entry's chance
C 28583,2 Use this entry if the number is lower
C 28585,2 Otherwise move on to the next entry
C 28587,2 Four bytes per layout entry...
C 28589,2 ...
C 28591,2 ...
C 28593,2 Compare against the next entry
C 28595,3 Is it the layout already on screen?
C 28598,2 If so pick again (the bubble must move)
C 28600,3 Set A=1 if the layout has changed
C 28603,3 Store the layout-unchanged flag
C 28606,4 Make this the current layout
C 28610,3 Draw the picture (or just wipe the old bubble)
C 28613,3 Print the status lines
C 28616,3 Print the second status line
C 28619,1 Restore the message address
C 28620,3 Render the message into the text buffer
C 28623,4 Point IX at the text buffer
C 28627,3 HL=top of the screen
C 28630,3 Print the text in a bubble
C 28633,3 Pick up the SAY flags
C 28636,2 Keep bits 4-6
C 28638,3 Play the theme tune if they are 16
C 28641,3 Pick up the SAY flags again
C 28644,2 Keep bits 0-1
C 28646,1 Return unless they ask for a pause
C 28647,2 Wait up to 8 periods...
C 28649,3 ...or until a key is pressed
c 28652 Check whether the bubble layout has changed
D 28652 Compares IY with the current layout (#R33904).
R 28652 Output:A 0 if unchanged, 1 if changed
R 28652 F Zero flag set if unchanged
C 28652,1 Save HL...
C 28653,1 ...and DE
C 28654,2 HL=IY
C 28656,1 HL=IY, the layout being asked for
C 28657,4 DE=current layout
C 28661,1 Clear the carry flag
C 28662,2 Compare
C 28664,2 A=0 (unchanged)
C 28666,1 Restore DE...
C 28667,1 ...and HL
C 28668,1 Return with A=0 and the zero flag set if they are the same
C 28669,1 A=1 (changed)
C 28670,1 Done: A=1 and NZ if the layout is different
c 28671 Measure the words in the text buffer
D 28671 Builds a list of word widths (in pixels) at 24192, terminated by 255.
R 28671 Input:IX Text
C 28671,3 Point DE at the word width list
C 28674,2 Save IX...
C 28676,1 ...and HL
C 28677,3 Measure the next word
C 28680,1 Was it empty (two spaces in a row)?
C 28681,2 Skip it if so
C 28683,1 Store its width
C 28684,1 Next entry in the table
C 28685,3 Reached the end of the text?
C 28688,1 Clear the carry flag
C 28689,2 Back for the next word if not
C 28691,2 Terminate the list with 255
C 28693,1 Store the measured value
C 28694,1 Restore HL
C 28695,2 Restore IX
C 28697,1 Done
c 28698 Measure one word
D 28698 Adds up the widths (+1 pixel spacing) of the characters at IX up to the next space.
R 28698 Input:IX Text
R 28698 Output:A Width in pixels
R 28698 IX Next word
C 28698,1 Save BC
C 28699,1 Save HL
C 28700,2 C will accumulate the width
C 28702,3 Pick up a character
C 28705,1 End of the text?
C 28706,2 Finish if so
C 28708,3 Get the address of its glyph
C 28711,1 A=width of the character
C 28712,1 +1 pixel of spacing
C 28713,1 Add the character's width to the total
C 28714,1 Add it to the total
C 28715,3 Pick up the character again
C 28718,2 Move on
C 28720,2 Was it a space?
C 28722,2 Carry on until the end of the word
C 28724,1 Restore HL
C 28725,1 A=width of the word
C 28726,1 Restore BC
C 28727,1 Done: A=the width of the word in pixels
b 28728 Speech bubble shape
D 28728 Line widths (#R28728-28736), left offsets (28737-28746) and margins (28747-28756) for the oval speech bubble; used by #R28757 and #R29161. #R29161 fills lines from the top and the bottom of the bubble at the same time, so each of the nine widths serves a pair of lines (the outermost pair first), and the table covers bubbles of up to 18 lines.
B 28728,29,8*3,5
c 28757 Print the text buffer into a speech bubble
D 28757 Works out how many lines the text needs (#R29161), then prints it line by line, centring each line within the oval bubble shape described by the table of line widths at #R28728 and left margins at 28746. The bubble outline itself is drawn first by #R28905.
R 28757 Input:IX Text
R 28757 HL Display file address of the top of the bubble
@ 28757 label=PRINTBUBBLE
C 28757,3 Measure the words of the text
C 28760,2 Save IX...
C 28762,2 ...and IY
C 28764,1 Save the screen address
C 28765,3 Work out the number of lines needed (B)
C 28768,1 Is it odd?
C 28769,2 Keep bit 0: 1 if the number of lines is odd
C 28771,3 Store the odd-line flag
C 28774,1 A=number of lines again
C 28775,2 B/2 lines in each half of the bubble
C 28777,3 Remember the number of lines in each half
C 28780,1 B=lines in each half
C 28781,3 C=index of the widest line
C 28784,1 Add the odd-line flag: the index of the middle line
C 28785,1 C=index of the middle line
C 28786,2 BC=index, to look up the left offset
C 28788,3 Look up the left offset of the bubble
C 28791,1 HL=address of the offset for that line
C 28792,1 C=the left offset of the bubble
C 28793,1 Restore the screen address
C 28794,1 Add the left offset
C 28795,3 Leave a blank row above the text
C 28798,4 IY points at the margins for each line
C 28802,3 DE points at the widths of the lines
C 28805,3 Draw the bubble outline
C 28808,3 B=number of lines in the top half (plus the middle line if odd)
C 28811,1 B=the odd-line flag...
C 28812,3 ...plus the lines in the top half...
C 28815,1 ...gives the rows above the middle line...
C 28816,1 ...B=row counter
C 28817,2 C=pixel offset 0
C 28819,1 Keep the screen position of this row
C 28820,3 Indent by the margin for this line
C 28823,1 A=width of this line
C 28824,3 Print as many words as fit
C 28827,1 Back to the start of the row
C 28828,2 Next margin
C 28830,1 Next width
C 28831,3 Move down a row
C 28834,2 Repeat for the top half
C 28836,1 Step back to the middle line
C 28837,2 Back to the middle line's margin entry
C 28839,3 Is there an odd middle line?
C 28842,1 Test for an odd middle line
C 28843,2 Jump if not
C 28845,1 If so step back once more
C 28846,2 ...and its margin entry
C 28848,3 B=number of lines in the bottom half
C 28851,1 B=number of lines in the bottom half
C 28852,1 Test for none
C 28853,2 Jump if there are none
C 28855,2 C=pixel offset 0
C 28857,1 Keep the screen position of this row
C 28858,3 Indent by the margin for this line
C 28861,1 A=width of this line
C 28862,3 Print as many words as fit
C 28865,1 Back to the start of the row
C 28866,2 Previous margin (the bottom half mirrors the top)
C 28868,1 Previous width
C 28869,3 Move down a row
C 28872,2 Repeat for the bottom half
C 28874,2 Restore IY...
C 28876,2 ...and IX
C 28878,1 Done: the bubble and its text are drawn
c 28879 Add the bubble margin for the current line
D 28879 L=L+(IY+0).
C 28879,3 A=margin for this line
C 28882,1 Add it to the column
C 28883,1 L=the indented column
C 28884,1 Done
c 28885 Move HL down one character row
D 28885 HL=HL+32, crossing display file thirds as needed.
C 28885,1 Move down 32 bytes
C 28886,2 Add 32 to move down one pixel row...
C 28888,1 L=the new low byte
C 28889,1 Return unless this crossed into the next third of the screen
C 28890,1 A=H
C 28891,2 Move to the next third
C 28893,1 H=the next third
C 28894,1 Done
c 28895 Move HL up one character row
D 28895 HL=HL-32, crossing display file thirds as needed.
C 28895,1 Move up 32 bytes
C 28896,2 Subtract 32 to move up one pixel row...
C 28898,1 L=the new low byte
C 28899,1 Return unless this crossed into the previous third
C 28900,1 A=H
C 28901,2 Move to the previous third
C 28903,1 H=the previous third
C 28904,1 Done
c 28905 Draw the outline of a speech bubble
D 28905 Draws the rounded white bubble (paper 7) with one blank line above and below the text area.
C 28905,2 Save IY
C 28907,1 Save the registers this routine uses...
C 28908,1 ...(HL=screen position, DE=width table)...
C 28909,1 ...and BC, which will count rows
C 28910,3 Start one row above the text
C 28913,3 B=number of lines in the top half
C 28916,1 B=lines in the top half...
C 28917,3 ...plus the lines in the bottom half (28756)...
C 28920,1 ...to give the number of rows above the middle line
C 28921,1 B=the row counter
C 28922,2 C=pixel offset 0
C 28924,1 Keep the screen position for the next row
C 28925,3 Indent by the margin
C 28928,1 A=width of this line
C 28929,3 Paint the white background for it
C 28932,1 Back to the start of this row
C 28933,2 Next margin entry
C 28935,1 Next line width
C 28936,3 Move down a row
C 28939,2 Repeat for the top half
C 28941,1 Keep the screen position of the middle row
C 28942,1 Back to the widest line
C 28943,2 Back to the widest line's margin entry
C 28945,3 Indent by the margin
C 28948,1 A=the width of the widest line
C 28949,3 Paint the blank row above the text (as wide as the line below it)
C 28952,3 Is there an odd middle line?
C 28955,1 Test for no odd middle line
C 28956,2 Skip the extra step if there is none
C 28958,1 Odd middle line: step back one more width...
C 28959,2 ...and one more margin entry
C 28961,1 Restore the screen position
C 28962,3 Move down a row
C 28965,1 Keep the screen position of the middle row
C 28966,3 Indent by the margin of the middle line
C 28969,1 A=width of the middle line
C 28970,3 Paint the middle row
C 28973,1 Restore the screen position
C 28974,3 B=number of lines in the bottom half
C 28977,1 B=lines in the bottom half
C 28978,1 Test for none
C 28979,2 Jump if there are none
C 28981,2 C=pixel offset 0
C 28983,3 Move down a row
C 28986,1 Keep the screen position
C 28987,3 Indent by the margin
C 28990,1 A=the width of the line
C 28991,3 Paint the background for this line
C 28994,1 Restore the screen position
C 28995,2 Previous margin
C 28997,1 Previous width
C 28998,2 Repeat for the bottom half
C 29000,1 Restore BC...
C 29001,1 ...DE...
C 29002,1 ...HL...
C 29003,2 ...and IY
C 29005,1 Done: the whole bubble background is painted
c 29006 Fill part of a bubble line with white cells
D 29006 Paints A+16 pixels of white bubble background (via #R27060) from the cell at HL.
C 29006,1 Save BC
C 29007,1 Save HL...
C 29008,2 Add 16 pixels of margin to the line width
C 29010,1 B=pixels to paint
C 29011,1 Start one cell to the left
C 29012,3 Clear a cell and make it white
C 29015,1 Next cell
C 29016,1 A=the width again
C 29017,2 8 pixels done
C 29019,1 B=the width
C 29020,2 Any more?
C 29022,2 Jump back if so
C 29024,1 Restore HL
C 29025,1 Restore BC
C 29026,1 Done
b 29027 The line start pointer
B 29027,2,2
c 29029 Print one line of text in a bubble
D 29029 Prints as many words from IX as will fit in A pixels, centred.
R 29029 Input:A Line width in pixels
R 29029 IX Text
C 29029,1 Save BC
C 29030,1 Save DE
C 29031,1 B=the width of the line in pixels
C 29032,3 A=the first character of the text
C 29035,1 Test it
C 29036,2 End of the text: nothing to print
C 29038,2 Save the start of the line
C 29040,4 Remember the start of the line
C 29044,3 A=the next character
C 29047,1 Test it
C 29048,2 End of the text: the line ends here
C 29050,3 Measure the next word
C 29053,1 D=the width of the word
C 29054,1 A=the width left on the line
C 29055,1 Subtract the word's width
C 29056,2 It does not fit: the line ends before this word
C 29058,1 B=the width left
C 29059,2 Try the next word
C 29061,1 DE=the start of the line
C 29062,1 Save the width left
C 29063,1 Save the start of the line
C 29064,1 Save the screen position
C 29065,3 HL=the end of the words that fit (where the next word starts)
C 29068,1 Clear the carry flag
C 29069,2 Subtract the start: the number of characters on the line
C 29071,1 A=the character count
C 29072,1 Restore the screen position
C 29073,1 C=the character count
C 29074,2 E=250: a counter for the spaces at the end of the line
C 29076,2 D=254: a counter for the spaces at the start of the line
C 29078,4 IX=the end of the line
C 29082,1 B=the character count
C 29083,2 Back up one character
C 29085,1 Count it in D
C 29086,1 Count three pixels in E for each space...
C 29087,1 ...
C 29088,1 ...
C 29089,3 A=the character
C 29092,2 A space?
C 29094,2 No: stop looking
C 29096,2 Keep looking for spaces at the end
C 29098,2 IX=the start of the line
C 29100,2 Step back one
C 29102,1 B=the character count
C 29103,1 Count three pixels in E for each space at the start...
C 29104,1 ...
C 29105,1 ...
C 29106,1 Count it in D
C 29107,2 Move on one character
C 29109,3 A=the character
C 29112,2 A space?
C 29114,2 No: stop looking
C 29116,2 Keep looking for spaces at the start
C 29118,1 A=the pixels to be trimmed
C 29119,1 E=the character count
C 29120,1 Restore the width left
C 29121,1 Add it
C 29122,2 Halve it: this is the pixel offset that centres the line
C 29124,1 Add the character count
C 29125,2 At least 8 pixels?
C 29127,2 No: that is the pixel offset within the cell
C 29129,2 Take off a character cell's 8 pixels
C 29131,1 Move one cell right
C 29132,2 Repeat
C 29134,1 C=the pixel offset within the first cell
C 29135,1 A=the character count
C 29136,1 Take off the spaces to be skipped
C 29137,1 E=the number of characters to print
C 29138,2 None: nothing to print
C 29140,2 None: nothing to print
C 29142,3 A=the character
C 29145,3 Print it in the proportional font
C 29148,2 Next character
C 29150,1 One fewer to print
C 29151,2 Loop until the line is printed
C 29153,4 IX=the end of the line (the start of the next one)
C 29157,1 Restore DE
C 29158,1 Restore AF
C 29159,1 B=A
C 29160,1 Return
c 29161 Work out the bubble shape for the text
D 29161 Chooses the smallest bubble (number of lines, B) into which the measured words will fit, using the line widths at #R28728.
R 29161 Output:B Number of lines
C 29161,2 Save IX
C 29163,2 Save IY
C 29165,4 IX=just before the list of word widths (24192)
C 29169,4 IY=the list of word widths
C 29173,3 A=a width
C 29176,2 Next one
C 29178,1 The end marker is 255
C 29179,2 Keep looking for it
C 29181,2 IY=the end marker
C 29183,2 B=0: no lines yet
C 29185,3 HL=the table of line widths (#R28728)
C 29188,2 C=0: nothing in this line yet
C 29190,2 Next word from the front of the text
C 29192,3 A=its width
C 29195,1 Add it to the line
C 29196,1 C=the line width so far
C 29197,1 A=the width allowed for this line
C 29198,1 Does the word fit?
C 29199,2 Yes: try another
C 29201,2 Back off the last word
C 29203,1 One more line
C 29204,3 Have the front and back met?
C 29207,2 Yes: finished
C 29209,2 C=0: nothing in the line from the back
C 29211,2 Back one word from the end
C 29213,3 A=its width
C 29216,1 Add it to the line
C 29217,1 C=the line width so far
C 29218,1 A=the width allowed for this line
C 29219,1 Does the word fit?
C 29220,2 Yes: try another
C 29222,1 One more line (the last one, filled from the back)
C 29223,2 Put the word back
C 29225,1 Next width in the table (the next pair of lines is wider)
C 29226,3 Have the front and back met?
C 29229,2 No: fill another line from the front
C 29231,2 Restore IY
C 29233,2 Restore IX
C 29235,1 Return
c 29236 Compare IX and IY
D 29236 Returns with the carry flag set if IX<IY.
C 29236,1 Save HL
C 29237,2 Save IX...
C 29239,1 ...in HL
C 29240,2 Save IY...
C 29242,1 ...in DE
C 29243,1 Clear the carry flag
C 29244,2 Subtract: carry set if IX is less than IY
C 29246,1 Restore HL
C 29247,1 Return
w 29248 Message control code jump table
D 29248 Addresses of the handlers for control codes 0-22 (used by #R29458).
W 29248,46,8*5,6
c 29294 Measure the width of the text buffer
D 29294 Returns the total pixel width of the text at 23808 in HL.
C 29294,4 IX=the text buffer
C 29298,3 HL=0: the width so far
C 29301,3 A=the next character
C 29304,1 Test it
C 29305,1 End of the text: return
C 29306,1 DE=the width so far
C 29307,3 HL=the character's glyph address
C 29310,1 L=the glyph width
C 29311,2 H=0
C 29313,1 Add one pixel of spacing
C 29314,1 Add the width so far
C 29315,2 Next character
C 29317,2 Loop
b 29319 The first-character flag
B 29319,1,1
c 29320 Render a message into the text buffer
D 29320 Clears the buffer, renders the message at HL into it and then, if the text is too wide for one line, inserts a line break near the middle so that the bubble comes out roughly round.
R 29320 Input:HL Message address
@ 29320 label=RENDER
C 29320,1 Save the message address
C 29321,1 A=0, to clear the first-character flag
C 29322,3 Clear the first-character flag
C 29325,3 Point the buffer pointer at the start of the text buffer
C 29328,3 Start the text buffer pointer at 23808
C 29331,2 IX=message address
C 29333,3 Render the message into the buffer
C 29336,1 Terminate the buffer with a zero byte
C 29337,3 Store the zero terminator in the buffer
C 29340,3 Has the bubble layout changed since the last message?
C 29343,1 Test the layout-changed flag
C 29344,2 Jump if so (the screen will be redrawn anyway)
C 29346,3 HL=width of the new text in pixels
C 29349,4 DE=width of the previous text
C 29353,1 Clear the carry flag for the subtraction
C 29354,2 Is the new text at least as wide?
C 29356,2 Jump if so (the new bubble will cover the old one)
C 29358,3 Otherwise work out how many 3-pixel spaces are needed...
C 29361,1 DE=0 (the new width), HL=old width
C 29362,1 Clear the carry flag
C 29363,2 ...HL=old width-new width
C 29365,3 Spaces are 3 pixels wide
C 29368,3 BC will count the spaces
C 29371,1 Count one more space
C 29372,1 Clear the carry flag
C 29373,2 Divide by 3
C 29375,2 Loop while the width remaining is at least 3
C 29377,1 Are any spaces needed?
C 29378,1 Combine B and C to test BC for zero
C 29379,2 Jump if not
C 29381,1 Save the number of spaces
C 29382,2 Half of them go in front of the text
C 29384,2 Half the count in BC (carry out of B into C)
C 29386,3 HL=address of the terminator
C 29389,1 HL=address of the last character
C 29390,1 DE=HL: the address of the last character...
C 29391,1 DE=HL
C 29392,1 Move the end of the text along by BC
C 29393,3 Update the buffer pointer
C 29396,1 HL=last character, DE=its new position
C 29397,3 BC=length of the text
C 29400,1 Clear the carry flag
C 29401,2 HL=length of the text in the buffer (counted down from the end)
C 29403,1 Keep the length
C 29404,1 HL=address of the last character again
C 29405,1 BC=length, ready for LDDR
C 29406,2 Shift the text right to make room for the leading spaces
C 29408,1 Restore the total number of spaces
C 29409,3 HL=end of the text
C 29412,3 DE=start of the buffer
C 29415,1 Fill in pairs of spaces...
C 29416,1 Test the high byte of the count
C 29417,2 Jump if at least 256 left
C 29419,1 A=low byte of the count
C 29420,1 Test it for zero
C 29421,2 Jump if none left
C 29423,2 Just one left?
C 29425,2 Jump if so
C 29427,2 Put a space at the front...
C 29429,1 Space at the start of the buffer
C 29430,1 ...and one at the end
C 29431,1 Next position at the front
C 29432,1 Next position at the end
C 29433,1 One fewer space to place...
C 29434,1 Two fewer spaces to place
C 29435,2 Loop back for the next pair
C 29437,2 Put the odd space at the end
C 29439,1 Step over the odd space
C 29440,2 Terminate the text
C 29442,3 Update the buffer pointer
C 29445,3 Measure the final text...
C 29448,3 ...and remember its width for next time
C 29451,1 Return with HL=the final width
c 29452 Render a message
D 29452 Calls #R29458 for each item until the end of the message.
R 29452 Input:IX Message
C 29452,3 Render one item
C 29455,2 Repeat until an item ends the message
C 29457,1 Done: the message has been rendered
c 29458 Render one message item
D 29458 A message is a sequence of items:
D 29458 #TABLE(default,centre,:w) { =h Byte(s) | =h Meaning } { 0-31 | Control code (see the table at #R29248) } { 32-95 | Literal character (letters are converted to lower case) } { 96-127 | Common word: index into the table at #R49710 } { 128-255, n | Dictionary word at 48640+((b AND 15)*256)+n; bits 4-6 of b: 7 = capitalise, 2 or 6 = last word, 3 = last word plus a full stop } TABLE#
R 29458 Returns with the zero flag set at the end of the message.
N 29458 Input:IX Item Output:IX Next item
@ 29458 label=RENDERITEM
C 29458,3 Pick up the first byte of the item
C 29461,2 Is it a two-byte dictionary reference?
C 29463,2 Jump if not
C 29465,2 D=first byte without bit 7 (bits 0-3: page; bits 4-6: type)
C 29467,1 D=the type and page
C 29468,3 E=offset into the page
C 29471,2 Point IX at the second byte
C 29473,2 Keep the type bits
C 29475,2 Type 3 (last word plus full stop)?
C 29477,2 Jump if so
C 29479,2 Type 2 (last word)?
C 29481,2 Jump if so
C 29483,2 Type 6 (last word)?
C 29485,2 Jump if so
C 29487,3 Print the dictionary word
C 29490,2 Move IX to the next item
C 29492,2 Reset the zero flag: the message continues
C 29494,1 Done: NZ means the message goes on
C 29495,2 Is it a control code (0-31)?
C 29497,2 Jump if so
C 29499,2 Is it a common word (96-127)?
C 29501,3 Jump if so
C 29504,3 Otherwise it is a literal character: put it in the buffer
C 29507,2 And move on
c 29509 Put a character into the text buffer (converting to lower case)
D 29509 Converts A-Z to a-z first.
C 29509,2 Is it an upper case letter?
C 29511,2 Below A: not a capital, store as it is
C 29513,2 Above Z?
C 29515,2 Yes: store as it is
C 29517,2 Convert it to lower case (which the font draws as small capitals)
c 29519 Put a character into the text buffer
D 29519 Stores A at the buffer pointer (#R29926). A space as the very first character is suppressed.
C 29519,1 Save HL
C 29520,3 HL=buffer pointer
C 29523,1 Store the character
C 29524,3 Has anything been stored yet?
C 29527,1 Test the first-character flag
C 29528,1 A=the character
C 29529,2 Jump if so: advance the pointer
C 29531,3 Note that something has been stored
C 29534,2 Is the first character a space?
C 29536,2 Jump if so: do not advance, so the next character overwrites it
C 29538,1 Advance the buffer pointer
C 29539,3 Store the updated buffer pointer
C 29542,1 Restore HL
C 29543,1 Done
C 29544,1 Save DE
C 29545,1 DE=control code
C 29546,2 DE=code
C 29548,3 Point HL at the control code jump table
C 29551,1 Add the code once...
C 29552,1 Add 2*code
C 29553,1 Pick up the handler address
C 29554,1 Next byte of the table entry
C 29555,1 D=high byte of the handler address
C 29556,1 HL=handler address
C 29557,1 Restore DE
C 29558,2 Codes 20 and above...
C 29560,2 ...are jumped to directly (they end the message)
C 29562,3 Codes 0-19 are called
C 29565,2 Zero flag set: the handler has done its work; move on
C 29567,2 Otherwise print the dictionary word in DE
c 29569 Jump to a control code handler
D 29569 JP (HL).
C 29569,1 Jump to the handler
c 29570 Control codes 0, 2, 3, 6, 7, 9 and 12-20 (no-op)
C 29570,2 D=96 (as for a type 6 last word)
C 29572,2 End the message without a full stop
c 29574 Control code 21: full stop and end
C 29574,2 D=48 (as for a type 3 last word)
C 29576,2 End the message with a full stop
C 29578,3 Print the last word
C 29581,2 A=full stop
C 29583,2 Type 6?
C 29585,2 Jump if so: no full stop
C 29587,2 Type 3?
C 29589,3 Print the full stop if so
C 29592,2 Test bit 4 of D again
c 29594 Control code 22: end
C 29594,1 Set the zero flag: end of message
C 29595,1 Done
c 29596 Control codes 1/4: fetch a variable from the VM stream
D 29596 Reads a variable number from the VM byte stream (not the message!) and loads that variable into BCDE, then puts a space in the buffer.
C 29596,3 Fetch a variable number from the VM byte stream
C 29599,1 L=variable number
C 29600,3 Load the variable into BCDE
C 29603,2 A=space
C 29605,3 Put a space in the buffer
c 29608 Control code 1: print " $" and a variable
C 29608,3 Fetch the variable and put a space in the buffer
C 29611,2 A="$"
C 29613,3 Put it in the buffer
C 29616,3 Print the number
C 29619,1 Set the zero flag: control code done
C 29620,1 Done
c 29621 Control code 4: print " " and a variable
C 29621,3 Fetch the variable and put a space in the buffer
C 29624,3 Print the number
C 29627,1 Set the zero flag: control code done
C 29628,1 Done
b 29629 The leading-zero flag
B 29629,1,1
c 29630 Print a number
D 29630 Prints the signed fixed-point value in BCDE in decimal (without leading zeros), adding a decimal point and two decimal places only if the fractional part is non-zero.
R 29630 Input:BCDE Number (x100)
@ 29630 label=PRINTNUM
C 29630,2 Is the number negative?
C 29632,2 Jump if not
C 29634,3 Make it positive
C 29637,2 A="-"
C 29639,3 Put the minus sign in the buffer
C 29642,1 Copy the high word (BC) into HL'
C 29643,1 Switch to the alternate registers...
C 29644,1 ...HL'=high word of the number...
C 29645,1 ...and back again
C 29646,1 HL=low word
C 29647,1 Leading zeros are not printed yet
C 29648,3 Clear the leading-zero flag
C 29651,3 BC/DE=1,000,000,000 (the number is in hundredths, so this is ten million)
C 29654,3 DE=low word of the divisor 1,000,000,000
C 29657,3 Print that digit
C 29660,3 BC/DE=100,000,000
C 29663,3 DE=low word of 100,000,000
C 29666,3 Print the millions digit
C 29669,3 BC/DE=10,000,000
C 29672,3 DE=low word of 10,000,000
C 29675,3 Print the hundred-thousands digit
C 29678,3 BC/DE=1,000,000
C 29681,3 DE=low word of 1,000,000
C 29684,3 Print the ten-thousands digit
C 29687,3 BC/DE=100,000
C 29690,3 DE=low word of 100,000
C 29693,3 Print the thousands digit
C 29696,3 BC/DE=10,000
C 29699,3 DE=10,000
C 29702,3 Print the hundreds digit
C 29705,3 BC/DE=1,000 (tens)
C 29708,3 DE=1,000
C 29711,3 Print the tens digit
C 29714,2 From now on zeros are printed (so 0 comes out as "0")
C 29716,3 Set the leading-zero flag
C 29719,3 BC/DE=100 (units)
C 29722,3 DE=100
C 29725,3 Print the units digit
C 29728,1 Is there a fractional part?
C 29729,1 Combine with H to test the fraction
C 29730,1 Return if not: whole numbers have no decimal point
C 29731,2 A="."
C 29733,3 Put the decimal point in the buffer
C 29736,3 BC/DE=10 (tenths)
C 29739,3 DE=10
C 29742,3 Print the tenths digit
C 29745,1 A=hundredths digit
C 29746,2 Convert it to ASCII
C 29748,3 Put it in the buffer
C 29751,1 Done
c 29752 Print one decimal digit
D 29752 Subtracts the power of ten in BC/DE from the number in HL'/HL repeatedly to work out the digit.
C 29752,1 Copy the high word of the power of ten into DE'
C 29753,1 Switch to the alternate registers...
C 29754,1 ...DE'=high word of the power of ten...
C 29755,1 ...and back again
C 29756,2 C will count from "0"
C 29758,1 Next digit value
C 29759,1 Clear the carry flag
C 29760,2 Subtract the power of ten (low word)...
C 29762,1 Switch to the high words...
C 29763,2 ...and high word
C 29765,1 ...and back
C 29766,2 Repeat until the number goes negative
C 29768,1 Add the power of ten back on (low word)...
C 29769,1 Switch to the high words...
C 29770,2 ...and high word
C 29772,1 ...and back
C 29773,3 Has a non-zero digit been printed yet?
C 29776,1 Test the leading-zero flag
C 29777,1 A=digit
C 29778,3 Print it if so
C 29781,2 Is it a leading zero?
C 29783,1 Skip it if so
C 29784,3 Otherwise leading zeros are over
C 29787,3 Print the digit
c 29790 Control code 11: repeat earlier text
D 29790 The next byte is an offset back (n-256) to some text earlier in the message area, which is rendered up to its own end marker. This saves space where messages share phrases.
C 29790,2 Save the message pointer
C 29792,3 E=offset (as a negative number: the text is earlier in memory)
C 29795,2 D=255, so DE is a negative offset
C 29797,2 IX=address of the earlier text
C 29799,3 Render it until its own end marker
C 29802,2 Restore the message pointer
C 29804,2 Skip the offset byte
C 29806,1 Set the zero flag: code done
C 29807,1 Done
b 29808 The random-choice counter
B 29808,2,2
c 29810 Control code 10: random choice
D 29810 The next byte is the number of alternatives n, followed by n single items (one or two bytes each). One item is chosen at random and rendered. This is how Louey varies his patter ("[What wuz dat, Boss? I missed it/It's okay, Boss - this line aint tapped...]").
C 29810,2 Point at the number of alternatives
C 29812,3 A=the number of alternatives
C 29815,3 Store it as the counter
C 29818,1 A=n-1
C 29819,3 Pick a random number 0..n-1
C 29822,1 A=1..n
C 29823,3 Store the choice
C 29826,2 Point at the first alternative
C 29828,3 Is this the chosen alternative?
C 29831,3 HL=the counter of alternatives still to skip
C 29834,1 Is this the chosen one?
C 29835,2 Jump if not
C 29837,2 Keep the message pointer
C 29839,3 Render it
C 29842,2 Restore the message pointer
C 29844,3 Get the first byte of this alternative
C 29847,2 A dictionary word (2 bytes)?
C 29849,2 Jump if so
C 29851,2 Control code 2 (2 bytes)?
C 29853,2 Two-byte item: skip both bytes
C 29855,2 Control code 11 (2 bytes)?
C 29857,2 Jump if not
C 29859,2 Skip the second byte
C 29861,2 Skip the first byte
C 29863,3 Count down the alternatives
C 29866,1 One alternative fewer to go
C 29867,2 Jump back for the next one
C 29869,2 Point at the last byte (the caller moves on)
C 29871,1 Set the zero flag: code done
C 29872,1 Done: the zero flag tells the caller the message continues
c 29873 Control code 5: insert a sub-message
D 29873 Takes a message address from the VM byte stream (or uses the default set by SETMSG/26740 if it is 0) and renders it.
C 29873,3 Fetch a message address from the VM byte stream
C 29876,1 DE=address
C 29877,1 Is it 0?
C 29878,1 Combine with E: is the address zero?
C 29879,2 Jump if not
C 29881,4 Otherwise use the default set by SETMSG
C 29885,2 Save the message pointer
C 29887,1 Keep the sub-message address
C 29888,2 IX=sub-message
C 29890,3 Render it
C 29893,2 Restore the message pointer
C 29895,1 Set the zero flag: code done
C 29896,1 Done
b 29897 Control code 8 handler (broken backspace)
D 29897 The handler for message control code 8, which was evidently meant to be a backspace: it steps the text buffer pointer (#R29926) back one character so that the next character overwrites the last. The jump table at #R29248 points here. These bytes are Z80 code; each comment gives the instruction.
D 29897 It is broken. The first instruction, PUSH HL, is never undone, and the dispatcher (#R29544) has just put the handler's own address in HL, so the final RET goes back to the start of the handler. The handler then runs a second time and this time returns to 23807, one byte before the start of the text buffer (23808), and executes whatever is there as code. Run in the simulator, the buffer pointer dropped by two and the call never returned. No message in the game uses code 8, so nobody ever sees it (see the #LINK(Bugs#backspace)(bugs page)).
B 29897,1,1 PUSH HL: the stray instruction (nothing ever pops it)
B 29898,3,3 LD HL,(#R29926): HL=the text buffer pointer
B 29901,1,1 DEC HL: step back one character
B 29902,3,3 LD (#R29926),HL: store the new pointer
B 29905,1,1 XOR A: set the zero flag (code done)
B 29906,1,1 RET: return, but to the wrong place because of the PUSH HL
c 29907 Expand a common word
D 29907 Byte values 96-127 index the table of common words at #R49710 (values from 128 are two-byte dictionary references and never reach this routine).
C 29907,2 A=index (0-31)
C 29909,1 E=the index
C 29910,2 DE=index
C 29912,3 Point HL at the table of common words
C 29915,1 Add the index once...
C 29916,1 Add 2*index
C 29917,1 E=offset
C 29918,1 Next byte of the table entry
C 29919,1 A=page
C 29920,2 Add 80 (type 5: an ordinary word)
C 29922,1 D=page and type
C 29923,3 Print the word
b 29926 The text buffer pointer
B 29926,2,2
c 29928 Expand a dictionary word
D 29928 Words are stored one byte per letter, of which only the low 5 bits count (1=a ... 26=z, 27-31 punctuation), in the dictionary at #R48640. Bit 7 marks the last letter, except on the second letter, or the third if the second also has bit 7 set; this lets short words overlap the starts of longer ones.
R 29928 Input:D Bits 0-3: dictionary page; bits 4-6: type
R 29928 E Offset
@ 29928 label=DICTWORD
C 29928,1 Is the reference zero (no word)?
C 29929,2 Keep only the page number (low 4 bits of D)...
C 29931,1 ...and combine it with the offset in E: zero means no word at all
C 29932,1 Return if so
C 29933,1 Save HL...
C 29934,1 ...BC...
C 29935,1 ...and DE
C 29936,1 C=type
C 29937,1 A=the type and page byte
C 29938,2 D=page (0-15)
C 29940,1 D=page, so DE=256*page+offset
C 29941,3 HL=48640+256*page+offset
C 29944,1 HL=the address of the word's text
C 29945,4 DE=where the next character goes in the text buffer
C 29949,2 Put a space before the word
C 29951,3 Put the space in the buffer
C 29954,1 First letter: low 5 bits
C 29955,1 Step on to the second letter
C 29956,2 Keep the low 5 bits (1-26 = A-Z)
C 29958,2 Convert to a lower case letter
C 29960,1 B=letter
C 29961,1 Is this a capitalised word (type 7)?
C 29962,2 Look at the type nibble only
C 29964,2 Is it type 7 (capitalised word)?
C 29966,2 Jump if not
C 29968,2 Make the letter upper case
C 29970,1 A=the first letter, upper or lower case
C 29971,3 Put the first letter in the buffer
C 29974,2 B counts the letters
C 29976,1 Next letter
C 29977,2 Keep the low 5 bits of the next letter
C 29979,2 A zero letter ends the word
C 29981,1 Count it
C 29982,2 Convert to a lower case letter
C 29984,3 Put it in the buffer
C 29987,2 Does bit 7 mark the end of the word?
C 29989,1 Step on to the next byte
C 29990,2 Carry on if not
C 29992,1 Bit 7 is ignored on the second letter...
C 29993,2 Is this the second letter?
C 29995,2 Yes: its end bit is ignored, so carry on
C 29997,2 ...and on the third...
C 29999,2 Finished if this is the fourth letter or later
C 30001,1 ...if the second letter also had bit 7 set
C 30002,1 Step back two bytes to the second letter...
C 30003,1 ...and pick it up
C 30004,1 Step forward again...
C 30005,1 ...to the byte after the third letter
C 30006,2 Did the second letter have its end bit set?
C 30008,2 Carry on if so
C 30010,1 Restore DE...
C 30011,1 ...BC...
C 30012,1 ...and HL
C 30013,1 Done: the word is in the text buffer
c 30014 Get a random number between 0 and n
D 30014 Calls #R30026 (which returns -n..n) and negates a negative result, so the result is always 0..n. Because of the way #R30026 folds large values, the result is not uniform: for n=100, the values 1-27 are twice as likely as the others (raw bytes above 200 are halved, which lands them just above n).
R 30014 Input:A n
R 30014 Output:A Random number
@ 30014 label=RANDOMPM
C 30014,3 Get a random number 0..A
C 30017,2 Is bit 7 of the result set?
C 30019,1 Return if not
C 30020,2 Otherwise negate it
C 30022,1 Done: A=0..limit
b 30023 The random number pointer
B 30023,3,3
c 30026 Get a random number
D 30026 Steps a pointer through the code of the program itself (#R30023) and mixes the bytes it finds, ensuring that the same value never comes up twice in a row, halves it until it is no more than 2*A, and subtracts A, giving a number between -A and A.
R 30026 Input:A Upper limit
R 30026 Output:A Random number
@ 30026 label=RANDOM
C 30026,2 Save IX
C 30028,1 Save BC
C 30029,1 C=upper limit
C 30030,2 Double it for the mask comparison
C 30032,2 The doubled limit fits in a byte
C 30034,2 Limit to 255
C 30036,1 B=limit*2
C 30037,4 Point IX at the random number pointer
C 30041,3 Step the pointer on by 256 bytes (increment its high byte)...
C 30044,2 No wrap-round: carry on
C 30046,3 ...and the low byte too if the high byte wrapped
C 30049,4 IX=the pointer (which wanders through the whole of memory)
C 30053,3 Pick up the last random number
C 30056,3 Add the byte at the pointer
C 30059,2 Step on by DE (whatever DE happens to hold)
C 30061,3 Mix in another byte
C 30064,1 Save HL
C 30065,3 Is the new number the same as the last one?
C 30068,1 Same as the previous number?
C 30069,1 Restore HL
C 30070,2 Try again if so
C 30072,3 Store the new random number
C 30075,1 Halve it until it is no greater than 2*limit
C 30076,2 Within range: done
C 30078,2 Exactly equal to the limit: done
C 30080,2 Halve the number
C 30082,3 Check again
C 30085,1 Subtract the limit (giving -limit..+limit)
C 30086,1 Restore BC
C 30087,2 Restore IX
C 30089,1 Done: A=a random number from -limit to +limit
b 30090 The VM program counter
B 30090,2,2
c 30092 Run a VM script
D 30092 The game logic is written in a compact interpreted language. IY points at the first instruction; instructions are executed until op 0 (END). See the #LINK(VM)(VM reference) page for the full instruction set. The flags returned by each instruction are preserved (PUSH AF/POP AF) so that op 12 (JZ) can test the result of a native routine called by op 14.
R 30092 Input:IY Script address
@ 30092 label=RUNVM
C 30092,4 Set the VM program counter
C 30096,1 Save the flags from the previous instruction
C 30097,3 Fetch the opcode
C 30100,1 Double it for the jump table at #R30123
C 30101,3 HL=start of the VM jump table
C 30104,1 Add the doubled opcode to L...
C 30105,1 L=the low byte of the entry address
C 30106,2 Prepare to add the carry to H...
C 30108,1 ...A=H+carry
C 30109,1 HL=entry in the jump table
C 30110,1 Pick up the handler address
C 30111,1 Next byte of the entry
C 30112,1 H=high byte of the handler address
C 30113,1 L=low byte: HL=handler
C 30114,1 Restore the flags from the previous instruction
C 30115,3 Execute the instruction
C 30118,2 Back for the next one
c 30120 VM op 0: END
C 30120,1 Op 0 (END): drop the return address to #R30118...
C 30121,1 ...and return from the interpreter
c 30122 Jump to the address in HL
C 30122,1 Jump to the opcode handler
w 30123 VM opcode jump table
D 30123 Addresses of the handlers for VM opcodes 0-34 (used by #R30092).
W 30123,70,8*8,6
c 30193 Compare two variables and fetch a jump address
D 30193 Used by ops 3-8.
R 30193 Output:F Flags of (second variable - first variable)
R 30193 HL Jump address
C 30193,3 Compare the variable in the next byte with the one in the byte after
c 30196 Fetch a word from the VM stream
D 30196 Flags are preserved.
R 30196 Output:HL Word
@ 30196 label=FETCHWORD
C 30196,1 Save the flags
C 30197,3 Pick up the VM program counter
C 30200,1 Fetch the low byte
C 30201,1 Step past the low byte...
C 30202,1 ...and the high byte
C 30203,3 Advance the program counter by 2
C 30206,1 Back to the high byte
C 30207,1 Fetch the high byte
C 30208,1 HL=word
C 30209,1 Restore the flags
C 30210,1 Done: HL=the 16-bit operand
c 30211 Fetch a word and then a byte from the VM stream
D 30211 Output:HL Word A Byte
C 30211,3 Fetch a word into HL first
c 30214 Fetch a byte from the VM stream
D 30214 Output:A Byte
@ 30214 label=FETCHBYTE
C 30214,1 Save HL
C 30215,3 Pick up the VM program counter
C 30218,1 Fetch the byte
C 30219,1 Advance the program counter
C 30220,3 Advance the program counter
C 30223,1 Restore HL
C 30224,1 Done: A=the byte
c 30225 VM op 1: SAY
C 30225,3 Op 1 (SAY): fetch the message address (HL) and the flags (A)
C 30228,3 Show the speech bubble
c 30231 VM op 2: SETMSG
C 30231,3 Op 2 (SETMSG): fetch a message address
C 30234,3 Make it the default sub-message for control code 5
C 30237,1 Done
c 30238 VM op 3: IFEQ
C 30238,3 Op 3 (IFEQ): compare the variables
C 30241,1 Return unless they are equal
C 30242,3 Jump: set the VM program counter to HL
C 30245,1 Done
c 30246 VM op 4: IFNE
C 30246,3 Op 4 (IFNE)
C 30249,1 Return if the variables are equal
C 30250,2 Otherwise jump
c 30252 VM op 5: IFLE
C 30252,3 Op 5 (IFLE)
C 30255,1 Return if the second variable is less than the first
C 30256,2 Otherwise jump
c 30258 VM op 6: IFLT
C 30258,3 Op 6 (IFLT)
C 30261,1 Return if the variables are equal...
C 30262,1 ...or if the second is less than the first
C 30263,2 Otherwise jump
c 30265 VM op 7: IFGT
C 30265,3 Op 7 (IFGT)
C 30268,1 Return unless the second variable is less than the first
C 30269,2 Otherwise jump
c 30271 VM op 8: IFGE
C 30271,3 Op 8 (IFGE)
C 30274,2 Jump if the variables are equal
C 30276,1 Return if the second variable is greater
C 30277,2 Otherwise jump
c 30279 VM op 9: IFPEEKEQ
C 30279,3 Op 9 (IFPEEKEQ): fetch an address and a byte
C 30282,1 Compare the byte at the address
C 30283,3 Fetch the jump address
C 30286,1 Return unless equal
C 30287,2 Otherwise jump
c 30289 VM op 10: IFPEEKNE
C 30289,3 Op 10 (IFPEEKNE): fetch an address and a byte
C 30292,1 Compare the byte at the address
C 30293,3 Fetch the jump address
C 30296,1 Return if equal
C 30297,2 Otherwise jump
c 30299 VM op 11: POKE
C 30299,3 Op 11 (POKE): fetch the byte
C 30302,3 Fetch the address
C 30305,1 POKE it
C 30306,1 Done
c 30307 VM op 12: JZ
C 30307,3 Op 12 (JZ): fetch the jump address (preserving the flags)
C 30310,1 Return if the zero flag is reset
C 30311,2 Otherwise jump
c 30313 VM op 13: GOTO
C 30313,3 Op 13 (GOTO): fetch the jump address
C 30316,2 And jump
c 30318 VM op 14: CALL
C 30318,3 Op 14 (CALL): save the address of the operand
C 30321,1 Keep the address of the operand
C 30322,3 Fetch the address of the native routine
C 30325,3 Call it
C 30328,1 Restore the address of the operand
C 30329,1 Step past the first byte of the operand...
C 30330,1 Skip the operand
C 30331,3 Set the VM program counter (anything the native routine fetched is ignored)
C 30334,1 Done
c 30335 VM op 15: STORE
C 30335,3 Op 15 (STORE): fetch the variable number
C 30338,1 L=the variable number
C 30339,3 Store BCDE in it
c 30342 Compare BCDE with a variable
D 30342 Compares the value in BCDE with the variable whose number is the next byte in the VM stream.
R 30342 Input:BCDE First value
R 30342 Output:F Zero set if equal; carry set if the variable is less than BCDE
@ 30342 label=COMPARE
C 30342,3 BCDE=first variable
C 30345,3 Fetch the number of the second variable
C 30348,1 L=the variable number
C 30349,2 HL=variable number
C 30351,1 HL=2*variable
C 30352,1 HL=4*variable number
C 30353,1 Save the low word of the first value
C 30354,3 Point IY at the second variable
C 30357,1 HL=address of the second variable
C 30358,1 Restore DE
C 30359,1 Copy HL into IY...
C 30360,2 ...by way of the stack
C 30362,1 Is the first value zero?
C 30363,1 Combine C into the zero test...
C 30364,1 ...and D...
C 30365,1 ...and E
C 30366,2 Jump if so
C 30368,3 Do the signs differ?
C 30371,1 Compare the sign bits: XOR the top bytes
C 30372,2 Keep just the sign bit
C 30374,2 Jump if so
C 30376,3 Same sign: compare the high bytes
C 30379,1 Compare the top bytes
C 30380,1 Return if they differ (carry set if the second is lower)
C 30381,3 Compare the next bytes
C 30384,1 Compare the next bytes
C 30385,1 Different: that decides it
C 30386,3 Next byte of the second value
C 30389,1 Compare with D
C 30390,1 Different: that decides it
C 30391,3 Compare the low bytes
C 30394,1 Compare the lowest bytes
C 30395,1 Return with the flags: Z=equal, C=second is smaller
C 30396,4 First value is zero: is the second negative?
C 30400,2 Jump if not
C 30402,1 Carry set: second < first
C 30403,1 Return with carry set
C 30404,3 Set the zero flag if the second is also zero
C 30407,3 OR in the next byte...
C 30410,3 ...and the next...
C 30413,3 ...and the lowest
C 30416,1 Return (the carry flag is reset by OR)
C 30417,2 Signs differ: is the first value negative?
C 30419,1 Return (zero and carry reset: second > first) if so
C 30420,2 Otherwise reset the zero flag...
C 30422,1 ...and set the carry flag: second < first
C 30423,1 Return with NZ and carry set
c 30424 Load two variables
D 30424 Loads the variable named by the next VM byte into BCDE and the one after into BC'DE'.
C 30424,3 BCDE=first operand
c 30427 Load the second operand
D 30427 Loads the variable named by the next VM byte into BC'DE'.
C 30427,1 Switch to the second register set
C 30428,3 BC'DE'=second operand
C 30431,1 Back to the main registers
C 30432,1 Done: BCDE=first operand, BC'DE'=second
c 30433 VM op 17: ADD v
C 30433,3 Load the operand into BC'DE'
C 30436,2 Add
c 30438 VM op 18: ADD v,v
C 30438,3 Load the two operands into BCDE and BC'DE'
c 30441 VM op 16: ADD (BCDE=BCDE+BC'DE')
C 30441,1 Add the low words...
C 30442,1 ...and the low word
C 30443,1 Switch to the second operand
C 30444,1 HL=low word of the first operand
C 30445,1 Clear the carry flag
C 30446,2 Add the low words
C 30448,1 HL=high word of the first operand; the low sum goes on the stack
C 30449,2 ...and the high words with carry
C 30451,1 Keep the high sum
C 30452,1 Back to the main registers
C 30453,1 BC=high word of the sum
C 30454,1 DE=low word
C 30455,1 Done: BCDE=the sum
c 30456 VM op 20: SUB v
C 30456,3 Load the operand into BC'DE'
C 30459,2 Subtract
c 30461 VM op 21: SUB v,v
C 30461,3 Load the two operands into BCDE and BC'DE'
c 30464 VM op 19: SUB
C 30464,1 Subtract the low words...
C 30465,1 Keep the low word
C 30466,1 Switch to the second operand
C 30467,1 HL=low word of the first operand
C 30468,1 Clear the carry flag
C 30469,2 Subtract the low words
C 30471,1 HL=high word of the first operand; the low difference goes on the stack
C 30472,2 ...and the high words with borrow
C 30474,1 Keep the high difference
C 30475,1 Back to the main registers
C 30476,1 BC=high word of the difference
C 30477,1 DE=low word
C 30478,1 Done: BCDE=the difference
c 30479 VM op 30: RND v
C 30479,3 Load the operand
c 30482 VM op 29: RND (replace E with a random number 0..E)
D 30482 Only the low byte of the accumulator is changed, so RND behaves oddly on values of 2.56 or more. The script only ever uses RND v71 (1.00), giving a random number between 0 and 1.00.
C 30482,1 A=low byte
C 30483,3 Replace it with a random number 0..A
C 30486,1 E=the random number
C 30487,1 Done
c 30488 VM op 32: HALF v
C 30488,3 Load the operand
c 30491 Halve BCDE (arithmetic shift right)
C 30491,2 Halve BCDE
C 30493,2 Shift C right with the carry from B
C 30495,2 ...D...
C 30497,2 ...and E
C 30499,1 Done: BCDE=BCDE/2
b 30500 Square root workspace
D 30500 Used by the square root routine at #R30511. Both values are 32-bit numbers in hundredths.
B 30500,4,4 The current estimate x (#R30500-30503)
B 30504,4,4 The argument n (#R30504-30507)
c 30508 VM op 34: SQRT v (BCDE=square root of a variable)
C 30508,3 Load the operand
c 30511 VM op 33: SQRT (Newton's method; never terminates for some values; see #LINK(Bugs#sqrt)(the bugs page))
C 30511,4 Store the argument n
C 30515,4 Store the top word of the argument
C 30519,3 First estimate: x=n/2
C 30522,4 Store the estimate x
C 30526,4 Store the top word of the estimate
C 30530,1 Switch to the alternate registers (BC'DE' will hold x)
C 30531,4 BCDE=n
C 30535,4 BC=top word of n
C 30539,3 BCDE=n/x (BC'DE' holds x)
C 30542,1 Back to the main registers
C 30543,4 BCDE=x
C 30547,4 BC=top word of x
C 30551,3 Add n/x
C 30554,3 Halve: the new estimate is (x+n/x)/2
C 30557,3 Compare it with the previous estimate
C 30560,1 A=byte 0 of the previous estimate
C 30561,1 Same as E?
C 30562,2 Try again if different
C 30564,1 Next byte
C 30565,1 A=byte 1 of the previous estimate
C 30566,1 Same as D?
C 30567,2 Not the same: do another iteration
C 30569,1 Next byte
C 30570,1 A=byte 2 of the previous estimate
C 30571,1 Same as C?
C 30572,2 Not the same: do another iteration
C 30574,1 Next byte
C 30575,1 A=byte 3 of the previous estimate
C 30576,1 Same as B?
C 30577,2 Try again if different (for some arguments the estimates alternate for ever)
C 30579,1 Return with the square root in BCDE
c 30580 VM op 27: INT
C 30580,3 Make the operands positive, noting the sign of the result (from BCDE and, wrongly, BC'DE')
C 30583,4 Copy BCDE into the 64-bit dividend
C 30587,4 Store the top word of the value
C 30591,3 Clear the upper words...
C 30594,3 ...bytes 4-5...
C 30597,3 ...and bytes 6-7 of the 64-bit dividend
C 30600,3 Divide by 100
C 30603,3 DE=100
C 30606,3 Divide by 100
C 30609,3 Multiply by 100 (dropping the fractional part)
C 30612,3 DE=100
C 30615,3 Multiply by 100
C 30618,4 BCDE=result
C 30622,4 BC=the top word of the result
C 30626,3 Should it be negative?
C 30629,1 Test the sign flag
C 30630,1 Return if not
C 30631,3 Negate it
c 30634 VM op 31: NEG (BCDE=-BCDE)
C 30634,3 Negate the low word...
C 30637,1 Clear the carry flag
C 30638,2 Subtract the low word from 0
C 30640,1 DE=the negated low word
C 30641,3 ...and the high word
C 30644,2 Subtract the high word from 0
C 30646,1 Copy HL into BC...
C 30647,1 ...by way of the stack
C 30648,1 Done: BCDE=-BCDE
c 30649 VM op 23: MUL v
C 30649,3 Load the operand into BC'DE'
C 30652,2 Multiply
c 30654 VM op 24: MUL v,v
C 30654,3 Load the two operands into BCDE and BC'DE'
c 30657 VM op 22: MUL (BCDE=BCDE*BC'DE'/100)
D 30657 Both values are fixed point with two decimal places, so the 64-bit product is divided by 100. The signs are handled separately by #R30993.
C 30657,3 Make both operands positive, noting the sign of the result
C 30660,1 Switch to BC'DE', the second operand...
C 30661,4 Store BC'DE' as the multiplier
C 30665,4 Store its top word as the multiplier's
C 30669,1 Back to the main registers
C 30670,3 Clear the top half of the multiplier
C 30673,3 Clear multiplier bytes 4-5...
C 30676,3 ...and 6-7
C 30679,3 64-bit product=BCDE*multiplier
C 30682,3 Divide by 100 (the fixed-point scale)
C 30685,3 DE=100
C 30688,3 Divide by 100 (the fixed-point scale)
C 30691,4 BCDE=result
C 30695,4 BC=the top word of the quotient
C 30699,3 Should it be negative?
C 30702,1 Test the sign flag
C 30703,1 Return if not
C 30704,3 Negate it
c 30707 VM op 25: DIV v
C 30707,3 Load the operand into BC'DE'
C 30710,2 Divide
c 30712 VM op 26: DIV v,v
C 30712,3 Load the two operands into BCDE and BC'DE'
c 30715 Divide BCDE by BC'DE' (x100)
D 30715 Returns 0 if the divisor is 0.
C 30715,3 Make both operands positive, noting the sign of the result
C 30718,4 Store BCDE (the dividend) as the multiplier
C 30722,4 Store the top word of the dividend
C 30726,3 HL=0...
C 30729,3 ...clear the upper half...
C 30732,3 ...of the 64-bit multiplier
C 30735,1 Switch to BC'DE', the divisor
C 30736,1 Is the divisor zero?
C 30737,1 Combine C...
C 30738,1 ...D...
C 30739,1 ...E: the divisor is zero if all clear
C 30740,2 Jump if not
C 30742,1 Switch back to the main registers
C 30743,3 Return 0 for division by zero
C 30746,3 DE=0
C 30749,1 Done: division by zero gives zero
C 30750,1 Save the divisor
C 30751,1 Save the divisor's low word
C 30752,3 BCDE=100
C 30755,3 BCDE=100
C 30758,3 64-bit product=dividend*100
C 30761,1 Restore the divisor
C 30762,1 Restore the divisor's high word
C 30763,3 Divide the product by it
C 30766,4 BCDE=quotient
C 30770,4 BC=the high word of the quotient
C 30774,3 Should it be negative?
C 30777,1 Test the result sign flag
C 30778,1 Return if not
C 30779,3 Negate it
c 30782 Multiply BCDE by the value at #R31038 (64-bit)
D 30782 The product goes into #R31030-31037.
C 30782,3 Clear the 64-bit product
C 30785,3 Clear bytes 0-1 of the 64-bit product...
C 30788,3 ...bytes 2-3...
C 30791,3 ...bytes 4-5...
C 30794,3 ...and bytes 6-7
C 30797,1 Any bits of BCDE left?
C 30798,1 Combine C into the test...
C 30799,1 ...and D...
C 30800,1 ...and E: zero when the multiplier is used up
C 30801,1 Return if not
C 30802,2 Is the lowest bit set?
C 30804,2 Jump if not
C 30806,1 Add the multiplier to the product (64 bits)
C 30807,3 HL=low word of the shifted multiplicand
C 30810,4 DE=low word of the product so far
C 30814,1 Add them
C 30815,3 Store the new low word of the product
C 30818,3 HL=second word of the multiplicand
C 30821,4 DE=second word of the product
C 30825,2 Add with the carry from below
C 30827,3 Store it
C 30830,3 HL=third word of the multiplicand
C 30833,4 DE=third word of the product
C 30837,2 Add with carry
C 30839,3 Store it
C 30842,3 HL=top word of the multiplicand
C 30845,4 DE=top word of the product
C 30849,2 Add with carry
C 30851,3 Store it
C 30854,1 Back to the normal registers
C 30855,3 Double the multiplier
C 30858,3 Shift the multiplier left
C 30861,2 Shift BCDE right one bit
C 30863,2 Shift BCDE right: C...
C 30865,2 ...D...
C 30867,2 ...and E
C 30869,2 Next bit
c 30871 Shift an 8-byte number left one bit
D 30871 HL points at the low byte.
C 30871,2 Shift the low byte left
C 30873,2 7 more bytes
C 30875,1 Next byte
C 30876,2 Shift the next byte left, bringing in the carry
C 30878,1 One fewer byte to do
C 30879,2 Repeat for all the remaining bytes
C 30881,1 Done
c 30882 Shift an 8-byte number right one bit (arithmetic)
D 30882 HL points at the high byte.
C 30882,2 Shift the high byte right (keeping the sign)
C 30884,2 7 more bytes
C 30886,1 Next byte
C 30887,2 Shift the next byte right, bringing in the carry
C 30889,1 One fewer byte to do
C 30890,2 Repeat for all the remaining bytes
C 30892,1 Done
c 30893 Subtract the divisor from the dividend (64-bit)
C 30893,3 Subtract the divisor from the dividend, 16 bits at a time
C 30896,4 DE=low word of the divisor
C 30900,1 Clear the carry flag
C 30901,2 Subtract the low words
C 30903,3 Store the new low word
C 30906,3 HL=second word of the dividend
C 30909,4 DE=second word of the divisor
C 30913,2 Subtract with borrow
C 30915,3 Store it
C 30918,3 HL=third word of the dividend
C 30921,4 DE=third word of the divisor
C 30925,2 Subtract with borrow
C 30927,3 Store it
C 30930,3 HL=top word of the dividend
C 30933,4 DE=top word of the divisor
C 30937,2 Subtract with borrow
C 30939,3 Store it (H holds the sign of the 64-bit result)
C 30942,2 Set the zero flag if the result is not negative
C 30944,1 Return with Z set if the result is not negative
c 30945 Add the divisor to the dividend (64-bit)
C 30945,3 Add the divisor to the dividend, 16 bits at a time
C 30948,4 DE=low word of the divisor
C 30952,1 Add the low words
C 30953,3 Store the new low word
C 30956,3 HL=second word of the dividend
C 30959,4 DE=second word of the divisor
C 30963,2 Add with carry
C 30965,3 Store it
C 30968,3 HL=third word of the dividend
C 30971,4 DE=third word of the divisor
C 30975,2 Add with carry
C 30977,3 Store it
C 30980,3 HL=top word of the dividend
C 30983,4 DE=top word of the divisor
C 30987,2 Add with carry
C 30989,3 Store it
C 30992,1 Done: the trial subtraction is undone
c 30993 Make BCDE and BC'DE' positive
D 30993 Records in #R31054 whether the result must be negated.
C 30993,1 Clear the sign flag
C 30994,3 Store 0: the result is positive so far
C 30997,2 Is BCDE negative?
C 30999,2 Jump if not
C 31001,3 Make it positive
C 31004,3 Flip the sign flag
C 31007,2 Flip the sign flag...
C 31009,3 ...and store it
C 31012,1 Now look at BC'DE'
C 31013,2 Is it negative?
C 31015,2 Jump if not
C 31017,3 Make it positive
C 31020,3 Flip the sign flag
C 31023,2 Flip the sign flag...
C 31025,3 ...and store it
C 31028,1 Back to the main registers
C 31029,1 Done: both operands positive, #R31054 holds the sign of the result
b 31030 Arithmetic workspace
D 31030 64-bit product/dividend (#R31030-31037), multiplier/quotient (#R31038-31045), divisor (#R31046-31053) and the sign flag (#R31054).
B 31030,25,8*3,1
c 31055 Divide the 64-bit number at #R31030 by BCDE
D 31055 Shift-and-subtract long division. The quotient goes into #R31038.
C 31055,3 Clear the quotient
C 31058,3 Clear the quotient: bytes 0-1...
C 31061,3 ...bytes 2-3...
C 31064,3 ...bytes 4-5...
C 31067,3 ...and bytes 6-7
C 31070,4 Store BCDE as the divisor (64 bits)
C 31074,4 Divisor bytes 4-5 from BC
C 31078,3 Divisor bytes 6-7 are zero...
C 31081,3 ...(HL is still 0)
C 31084,3 Is the dividend smaller than the divisor?
C 31087,1 Keep the comparison result...
C 31088,3 Undo the trial subtraction
C 31091,1 ...and get it back after undoing
C 31092,1 Return with a quotient of 0 if so
C 31093,3 Find the highest non-zero byte of the dividend
C 31096,2 Examine up to 8 bytes
C 31098,1 A=the byte of the dividend
C 31099,1 Is it zero?
C 31100,2 Found a non-zero byte
C 31102,1 Zero: look at the next lower byte
C 31103,2 Keep looking down the bytes
C 31105,1 The dividend is zero: quotient 0
C 31106,2 Find its highest set bit
C 31108,1 A=the byte
C 31109,1 Test bit C
C 31110,2 Found the highest set bit
C 31112,2 Try the next lower bit
C 31114,2 Keep looking
C 31116,3 Point DE at the corresponding byte of the divisor
C 31119,1 HL=the matching byte of the divisor
C 31120,1 DE=address of the divisor byte
C 31121,2 B counts the shifts needed
C 31123,1 Shift the divisor left until its top bit lines up with the dividend's
C 31124,1 Is the same bit set in the divisor?
C 31125,2 The bits line up: stop shifting
C 31127,1 Not yet: count another shift
C 31128,3 HL=the divisor
C 31131,3 Shift the divisor left
C 31134,2 Check again
C 31136,1 Save the shift count
C 31137,3 Shift the quotient left
C 31140,3 Shift the quotient left
C 31143,3 Subtract the divisor
C 31146,2 Jump if the result was not negative
C 31148,3 Otherwise add it back
C 31151,2 Skip the remaining bit-setting
C 31153,3 Set the lowest bit of the quotient
C 31156,2 ...a 1 for a successful subtraction
C 31158,3 Store the quotient
C 31161,3 Shift the dividend left
C 31164,3 Shift the dividend left
C 31167,2 Repeat for each bit position
C 31169,1 Restore the shift count
C 31170,3 Shift the remainder back
C 31173,3 Shift the remainder right
C 31176,2 Once for each shift made
C 31178,1 Done: the quotient is in #R31038 (64 bits)
c 31179 Store BCDE in a variable
D 31179 Used by VM op 15 (STORE, #R30335) and by native routines that leave results in VM variables.
R 31179 Input:L Variable number (from the VM stream)
@ 31179 label=STOREVAR
C 31179,2 HL=4*variable number
C 31181,1 HL=2*variable
C 31182,1 HL=4*variable
C 31183,1 Save the low word of the value
C 31184,3 Point HL at the variable
C 31187,1 HL=address of the variable
C 31188,1 Restore DE
C 31189,1 Store BCDE (low byte first)
C 31190,1 Next byte of the variable
C 31191,1 Store the second byte
C 31192,1 Next byte
C 31193,1 Store the third byte
C 31194,1 Next byte
C 31195,1 Store the top byte (the sign)
C 31196,1 Done
c 31197 VM op 28: LOAD (load a variable into BCDE)
C 31197,3 Fetch the variable number from the VM stream
C 31200,1 L=the variable number
c 31201 Load variable L into BCDE
D 31201 Input:L Variable number
@ 31201 label=LOADVAR
C 31201,2 HL=4*variable number
C 31203,1 HL=2*variable
C 31204,1 HL=4*variable
C 31205,3 Point HL at the variable
C 31208,1 HL=address of the variable
C 31209,1 Load it into BCDE (low byte first)
C 31210,1 Next byte
C 31211,1 D=second byte
C 31212,1 Next byte
C 31213,1 C=third byte
C 31214,1 Next byte
C 31215,1 B=top byte (the sign)
C 31216,1 Point past the variable
C 31217,1 Done: BCDE=the variable
c 31218 Clear the screen
D 31218 Clears the display file and sets every attribute to 56 (paper 7, ink 0).
@ 31218 label=CLS
C 31218,1 Save HL
C 31219,3 Clear the display file
C 31222,3 DE=the next byte
C 31225,3 BC=the remaining 6143 bytes
C 31228,2 Clear the first byte
C 31230,2 Propagate it across the display file
C 31232,3 Set every attribute to paper 7, ink 0
C 31235,3 DE=the next attribute
C 31238,3 BC=the remaining 767 attributes
C 31241,2 Paper 7 (white), ink 0 (black)
C 31243,2 Propagate it across the attribute file
C 31245,1 Restore HL
C 31246,1 Done: a clean white screen
c 31247 Draw a picture
D 31247 Pictures are stored as a list of drawing commands at IY:
D 31247 #TABLE(default,centre,:w) { =h Command | =h Meaning } { 0 | End of picture } { 8, x, y | Move the pen to (x,y) } { 16, lo, hi, w, h, data... | Copy a w x h block of bytes to the screen at hi*256+lo (ORed into the display file; written directly into the attributes) } { 128-255 | Draw a line: bits 0-2 are the direction flags, and the length comes from bits 3-6 and the top 2 bits of the next byte } { 64-127, x, y | Flood fill from (x,y); bits 0-2 = the ink colour of the filled cells } { 32-63, hi, lo, runs..., 255 | Paint attribute paper colour (bits 0-2) along a path starting at hi*256+lo; each run byte gives a count (bits 2-7) and a direction (bits 0-1: up, right, down, left) } TABLE#
R 31247 Input:IY Picture data
@ 31247 label=DRAWPIC
C 31247,1 Save HL
C 31248,1 Save DE
C 31249,1 Save BC
C 31250,3 Clear the screen
C 31253,2 Pen x=127
C 31255,2 Pen y=63
C 31257,2 Default slope
C 31259,2 Default direction
C 31261,2 Default length
C 31263,3 Pick up the next command
C 31266,1 Is it 0 (end of picture)?
C 31267,3 Finish if so
C 31270,2 Point at its operands
C 31272,2 Command 8 (move the pen)?
C 31274,2 Jump if not
C 31276,3 D=new x
C 31279,2 Point at y
C 31281,3 E=new y
C 31284,2 Point at the next command
C 31286,2 Next command
C 31288,2 Command 16 (bitmap block)?
C 31290,2 Jump if not
C 31292,3 HL=screen address
C 31295,3 H=the high byte of the screen address
C 31298,3 B=width in bytes
C 31301,3 C=height in rows
C 31304,2 Skip the address, low byte...
C 31306,2 ...high byte...
C 31308,2 ...and the width
C 31310,2 Point at the bitmap data
C 31312,1 Save the start of the row
C 31313,1 Save the width and height
C 31314,3 Put a byte on the screen
C 31317,1 Next column
C 31318,2 Next byte of data
C 31320,2 Repeat for the width of the block
C 31322,1 Restore the width and height
C 31323,1 Back to the start of the row
C 31324,3 Move down a pixel row (or an attribute row)
C 31327,1 One row done
C 31328,2 Repeat for each row
C 31330,2 Next command
C 31332,2 Bit 7 set (line)?
C 31334,2 Jump if not
C 31336,1 B=the command byte
C 31337,2 C=direction flags (bits 0-2)
C 31339,1 C=the direction flags
C 31340,1 A=the command byte again
C 31341,1 Move bits 3-6 down...
C 31342,2 B=bits 3-6 (high bits of the slope)...
C 31344,1 B=the high part of the slope
C 31345,3 Pick up the second byte
C 31348,2 Bits 0-5: length-1
C 31350,1 L=the low part of the length
C 31351,1 L=length
C 31352,3 A=the second byte again
C 31355,2 Point at the next command
C 31357,1 ...plus bits 6-7 of the second byte
C 31358,1 Rotate bits 6-7 round to bits 0-1...
C 31359,2 ...and keep them
C 31361,1 Combine them with the high part of the slope
C 31362,1 B=the slope
C 31363,1 B=slope
C 31364,3 Draw the line
C 31367,2 Next command
C 31369,2 Bit 6 set (flood fill)?
C 31371,2 Jump if not
C 31373,2 A=the ink colour
C 31375,1 Save the pen position
C 31376,3 D=x of the seed point
C 31379,2 Point at y
C 31381,3 E=y
C 31384,2 Point at the next command
C 31386,3 Fill the area
C 31389,1 Restore the pen position
C 31390,3 Next command
C 31393,2 Bit 5 set (paint attributes)?
C 31395,3 Ignore the command if not
C 31398,2 Bits 0-2: paper colour
C 31400,1 Multiply the paper colour by 8...
C 31401,1 ...to put it in bits 3-5
C 31402,1 C=paper colour*8
C 31403,1 Save HL
C 31404,1 Save DE
C 31405,1 Save BC
C 31406,1 C=the paper colour in bits 3-5
C 31407,3 HL=attribute address
C 31410,2 Point at the low byte of the address
C 31412,3 L=the low byte
C 31415,2 Point at the first run
C 31417,3 Pick up the next run
C 31420,2 Point at the next run
C 31422,2 End of the runs?
C 31424,2 Finish if so
C 31426,1 B=the run byte
C 31427,2 E=direction (0 up, 1 right, 2 down, 3 left)
C 31429,1 E=the direction
C 31430,1 B=length of the run (bits 2-7, plus 1)
C 31431,1 Shift the run length down...
C 31432,1 ...two places
C 31433,2 Keep the length bits
C 31435,1 The length is one more
C 31436,1 B=the length
C 31437,1 Take the ink of this cell
C 31438,2 Keep the ink
C 31440,1 Move the ink to bits 3-5, where the paper is...
C 31441,1 ...
C 31442,1 ...
C 31443,1 Is it the same as the new paper?
C 31444,2 Jump if not
C 31446,2 If so use paper 7 instead, so the ink stays visible
C 31448,1 Move the ink back to bits 0-2
C 31449,1 Move the ink back to bits 0-2...
C 31450,1 ...
C 31451,1 Combine it with the paper
C 31452,1 Set the attribute
C 31453,1 Move in the run's direction
C 31454,1 Zero means up
C 31455,3 Up
C 31458,1 1 means right
C 31459,3 Right
C 31462,1 2 means down
C 31463,3 Down
C 31466,1 3 means left
C 31467,3 Left
C 31470,2 Repeat for the length of the run
C 31472,2 Next run
C 31474,1 Restore BC
C 31475,1 Restore DE
C 31476,1 Restore HL
C 31477,3 Next command
C 31480,1 Restore BC
C 31481,1 Restore DE
C 31482,1 Restore HL
C 31483,1 Return
c 31484 Move HL down one pixel row in the display file (or one row in the attributes)
C 31484,1 Is HL in the attribute file?
C 31485,2 Is the high byte 88 or more (attribute file)?
C 31487,2 Jump if not
C 31489,1 Move down one attribute row
C 31490,2 Add 32 to move down one row of cells...
C 31492,1 ...L=the new low byte
C 31493,1 Done unless the add carried into the high byte
C 31494,1 Carry: the next page
C 31495,1 Done
C 31496,1 Move down one pixel row
C 31497,1 A=the new high byte
C 31498,2 The low 3 bits count the pixel row in the cell
C 31500,1 Return unless that crossed a character row
C 31501,1 Crossed into the next cell row: add 32 to L
C 31502,2 (next row of cells)
C 31504,1 L=the new low byte
C 31505,1 Carry: in the next third, H is already right
C 31506,1 Otherwise H must go back 8...
C 31507,2 ...to stay in the same third
C 31509,1 H=the corrected high byte
C 31510,1 Done
c 31511 Put a byte from a bitmap block on the screen
D 31511 ORs the byte at IY into the display file, or writes it if HL is in the attribute file.
C 31511,1 Is HL in the attribute file?
C 31512,2 Is the address 88 or more (attribute file)?
C 31514,3 Pick up the data byte
C 31517,2 Jump if so: store it as it is
C 31519,1 Otherwise merge it with the picture
C 31520,1 Store the byte
C 31521,1 Done
b 31522 The fill attribute
B 31522,3,3
c 31525 Flood fill
D 31525 Fills the area containing the pixel at (D,E) solidly with ink, scanning left and right along each row and remembering whether the rows above and below need filling. Every cell it touches also gets A as its ink colour (bits 3-5 of A, if any, are ORed in as paper: the compressed pictures pass 56, meaning ink 0 on paper 7).
R 31525 Input:A Attribute bits for the filled cells (ink in bits 0-2)
R 31525 D x coordinate
R 31525 E y coordinate
@ 31525 label=FILL
C 31525,3 Store the attribute bits for the filled cells
C 31528,1 Save BC
C 31529,1 Save DE
C 31530,1 Save HL
C 31531,3 HL=22528: an address in the attribute file, used as the end marker
C 31534,1 Push a zero marker (the end of the stack of seeds)
C 31535,3 BC=0
C 31538,1 Push the marker (HL=22528, DE=0 below it) on the seed stack
C 31539,3 Get the address and mask of the seed point
C 31542,1 D=the pixel mask of the seed
C 31543,1 Is this pixel set?
C 31544,1 Is the pixel at HL set?
C 31545,2 Jump if so: the left edge has been reached
C 31547,3 Otherwise move left
C 31550,2 And keep going
C 31552,3 The left edge of the screen was reached: start filling
C 31555,3 Plot the edge pixel
C 31558,3 Move right
C 31561,3 Clear the up/down flags
C 31564,4 Clear both flags (above and below)
C 31568,1 Reached a full byte boundary?
C 31569,2 Is the mask the leftmost pixel of a byte?
C 31571,2 No: do it pixel by pixel
C 31573,1 Is the whole byte empty?
C 31574,1 Test the byte
C 31575,2 Jump if so (fill it in one go)
C 31577,1 Save the screen address
C 31578,3 Look at the pixel above
C 31581,2 A=0: the flag for "above" if nothing is pushed
C 31583,2 Jump if at the top
C 31585,1 A=the pixel mask
C 31586,1 Is the pixel above set?
C 31587,2 A=0: the flag if it is blocked
C 31589,2 Jump if it is set
C 31591,3 Was the pixel above already being filled?
C 31594,1 Test the flag
C 31595,2 Jump if so
C 31597,1 Otherwise push it as a new seed
C 31598,1 Push the mask
C 31599,1 Push the address
C 31600,1 A=1: the flag says a seed is now pending above
C 31601,3 Store the flag
C 31604,1 HL=the current address
C 31605,1 Keep it on the stack
C 31606,3 Look at the pixel below
C 31609,2 A=0: the flag for "below" if nothing is pushed
C 31611,2 Jump if at the bottom
C 31613,1 A=the pixel mask
C 31614,1 Is the pixel below set?
C 31615,2 A=0: the flag if it is blocked
C 31617,2 Jump if it is set
C 31619,3 Was the pixel below already being filled?
C 31622,1 Test the flag
C 31623,2 Jump if so
C 31625,1 Otherwise push it as a new seed
C 31626,1 Push the mask
C 31627,1 Push the address
C 31628,2 A=1: a seed is now pending below
C 31630,3 Store the flag
C 31633,1 HL=the current address
C 31634,3 Plot this pixel
C 31637,3 Move right
C 31640,3 Move on along the line
C 31643,3 Fill a whole byte at once: check the bytes above and below
C 31646,1 Save the screen address
C 31647,3 Look at the byte above
C 31650,1 A=the byte above
C 31651,1 Restore the address
C 31652,2 At the top of the screen: it counts as clear
C 31654,2 Is the byte above full?
C 31656,2 Yes: treat as blocked
C 31658,1 Is it empty?
C 31659,2 Neither empty nor full: do it pixel by pixel
C 31661,1 C=1: the byte above is empty
C 31662,1 Save the address
C 31663,3 Look at the byte below
C 31666,1 A=the byte below
C 31667,1 Restore the address
C 31668,2 At the bottom of the picture: it counts as clear
C 31670,2 Is the byte below full?
C 31672,2 Yes: treat as blocked
C 31674,1 Is it empty?
C 31675,2 Neither: do it pixel by pixel
C 31677,1 B=1: the byte below is empty
C 31678,3 A=the flag for above
C 31681,1 Test it
C 31682,1 A=C (above is empty)
C 31683,2 A seed is already pending above
C 31685,1 Is the byte above empty?
C 31686,2 No: nothing to push
C 31688,3 Remember that a seed is pending above
C 31691,1 Save the address
C 31692,3 Move to the byte above
C 31695,1 Push it as a new seed
C 31696,1 Push the mask
C 31697,3 Store the flag
C 31700,3 A=the flag for below
C 31703,1 Test it
C 31704,1 A=B (below is empty)
C 31705,2 A seed is already pending below
C 31707,1 Is the byte below empty?
C 31708,2 No: nothing to push
C 31710,3 Remember that a seed is pending below
C 31713,1 Save the address
C 31714,3 Move to the byte below
C 31717,1 Push it as a new seed
C 31718,1 Push the mask
C 31719,2 Fill the whole byte
C 31721,3 Set its ink
C 31724,1 Next byte
C 31725,1 Reached the right edge of the screen?
C 31726,2 Keep the column
C 31728,2 At the right edge: this run is finished
C 31730,1 A=the mask
C 31731,1 Is the next pixel set?
C 31732,3 No: carry on filling
C 31735,3 Plot the pixel
C 31738,1 Pick up the next seed
C 31739,1 Pick up the address of the next seed
C 31740,1 Is it the zero marker?
C 31741,2 Is it the end marker (high byte 88)?
C 31743,3 Fill from it if not
C 31746,2 A=0
C 31748,3 Reset the attribute bits to 0
C 31751,1 Restore HL
C 31752,1 Restore DE
C 31753,1 Restore BC
C 31754,1 Return
c 31755 Move up one attribute row (unless at the top)
C 31755,1 Save AF
C 31756,1 Save DE
C 31757,3 Move up one attribute row
C 31760,1 Clear the carry flag
C 31761,2 Subtract 32 from the address
C 31763,1 Above the top?
C 31764,2 Is it 87 (just below the attribute file at 88)?
C 31766,2 No: the move is fine
C 31768,1 Undo the move if so
C 31769,1 Restore DE
C 31770,1 Restore AF
C 31771,1 Return
c 31772 Move down one attribute row (unless at the bottom of the picture area)
C 31772,1 Save AF
C 31773,1 Save DE
C 31774,3 Move down one attribute row
C 31777,1 Add 32 to the address
C 31778,1 Into the status lines (row 22)?
C 31779,2 Is the high byte 90 (attribute rows 16-23)?
C 31781,2 No: the move is fine
C 31783,1 A=the low byte
C 31784,2 Keep the row bits
C 31786,2 Is it row 22 or 23 (the status lines)?
C 31788,2 No: the move is fine
C 31790,1 Clear the carry flag
C 31791,2 Undo the move if so
C 31793,1 Restore DE
C 31794,1 Restore AF
C 31795,1 Return
c 31796 Move left one attribute cell
C 31796,1 Save AF
C 31797,1 Move left one cell
C 31798,1 Before the start of the attribute file?
C 31799,2 Is it 87 (just below the attribute file)?
C 31801,2 No: the move is fine
C 31803,1 Undo the move if so
C 31804,1 Restore AF
C 31805,1 Return
c 31806 Move right one attribute cell
C 31806,1 Save AF
C 31807,1 Move right one cell
C 31808,1 Past the end of the picture area?
C 31809,2 Is the high byte 90?
C 31811,2 No: the move is fine
C 31813,1 A=the low byte
C 31814,2 Keep the row bits
C 31816,2 Row 22 or 23 (the status lines)?
C 31818,2 No: the move is fine
C 31820,1 Undo the move if so
C 31821,1 Restore AF
C 31822,1 Return
c 31823 Move HL up one pixel row
D 31823 Returns with the zero flag set if the top of the screen has been reached.
C 31823,1 Move up one pixel row
C 31824,1 A=the high byte
C 31825,2 Pixel row within the cell
C 31827,2 Did that cross a character row?
C 31829,1 Return (zero flag reset) if not
C 31830,1 A=the low byte
C 31831,2 Up one character row
C 31833,1 L=it
C 31834,2 Borrow: H is already right
C 31836,1 A=the high byte
C 31837,2 Add 8 to move to the previous third's last row
C 31839,1 H=it
C 31840,1 Above the top of the screen?
C 31841,2 Is it 63 (above the display file)?
C 31843,1 Return (zero flag reset) if not
C 31844,1 Undo the move
C 31845,1 A=the low byte
C 31846,2 Put the row back
C 31848,1 L=it
C 31849,1 Set the zero flag
C 31850,1 Done: Z means the edge was reached
c 31851 Move HL down one pixel row
D 31851 Returns with the zero flag set if the bottom of the picture area (row 160) has been reached.
C 31851,1 Move down one pixel row
C 31852,1 A=the high byte
C 31853,2 Pixel row within the cell
C 31855,1 Return (zero flag reset) unless that crossed a character row
C 31856,1 A=the low byte
C 31857,2 Down one character row
C 31859,1 L=it
C 31860,2 Carry: H is already right
C 31862,1 A=the high byte
C 31863,2 Take 8 off
C 31865,1 H=it
C 31866,1 Reached row 160 (the bottom of the picture area)?
C 31867,2 Is it 80 (past the third)?
C 31869,1 Not the bottom: done with NZ
C 31870,1 A=the low byte
C 31871,2 Keep the row bits
C 31873,2 Is it row 6 (the bottom of the picture area)?
C 31875,1 Return (zero flag reset) if not
C 31876,1 Undo the move
C 31877,1 A=the low byte
C 31878,2 Up one character row
C 31880,1 L=it
C 31881,1 A=the high byte
C 31882,2 Add 8 back
C 31884,1 H=it
C 31885,1 Set the zero flag
C 31886,1 Done: Z means the edge was reached
c 31887 Move the pixel mask D one pixel right
D 31887 Returns with the zero flag set at the right edge.
C 31887,2 Move the mask right one pixel
C 31889,1 Return unless it wrapped round
C 31890,1 Next cell
C 31891,1 At the right edge?
C 31892,2 Keep the column
C 31894,1 Return (zero flag reset) if not
C 31895,2 Undo the move
C 31897,1 Previous cell
C 31898,1 Set the zero flag
C 31899,1 Done: Z means the edge was reached
c 31900 Move the pixel mask D one pixel left
D 31900 Returns with the zero flag set at the left edge.
C 31900,2 Move the mask left one pixel
C 31902,1 Return unless it wrapped round
C 31903,1 Previous cell
C 31904,1 Wrapped round the left edge?
C 31905,2 Keep the column
C 31907,2 Did it wrap round to column 31?
C 31909,1 Return (zero flag reset) if not
C 31910,2 Undo the move
C 31912,1 Back to the cell on the right
C 31913,1 Set the zero flag
C 31914,1 Done: Z means the edge was reached
b 31915 Unused: a stray jump
D 31915 Nothing refers to these two bytes. They are the Z80 instruction JR #R31887, sitting just after the RET of the routine at #R31900 where it can never be executed. #R31887 is the routine that moves the pixel mask right one pixel, so this is probably a leftover from an earlier version of the line routines.
B 31915,2,2 JR #R31887: never executed
c 31917 Draw a line segment
D 31917 Draws a line of L pixels from the pen position (D,E). Bit 0 of C chooses a mostly horizontal (0) or mostly vertical (1) line; bit 1 means down rather than up and bit 2 means left rather than right. B is the number of pixels drawn along the main direction before each step in the other direction, so it sets the slope. Each pixel also sets the ink of its attribute. Drawing stops early at the edge of the picture area, and the pen is left at the end of the line.
R 31917 Input:B Pixels per minor step
R 31917 C Direction flags
R 31917 D Pen x
R 31917 E Pen y
R 31917 L Length
R 31917 Output:D,E New pen position
C 31917,1 Save HL
C 31918,1 A=the line length...
C 31919,1 A'=length
C 31920,1 Keep the direction and step count (BC)
C 31921,3 Get the screen address and mask of the pen
C 31924,1 D=mask
C 31925,1 Get the direction and step count back...
C 31926,1 ...and keep them for later
C 31927,1 A=pixel count again
C 31928,2 Mostly vertical?
C 31930,2 Jump if so
C 31932,1 Swap in the pixel count
C 31933,3 Plot the pixel
C 31936,2 Moving left?
C 31938,2 Jump if not
C 31940,3 Move left
C 31943,2 Stop at the edge
C 31945,2 Now do the vertical step check
C 31947,3 Move right
C 31950,2 Stop at the edge
C 31952,1 Time for a vertical step?
C 31953,2 Jump if not
C 31955,2 Down?
C 31957,2 Not moving down: go up instead
C 31959,3 Move down
C 31962,2 Stop at the edge
C 31964,2 Skip the up move
C 31966,3 Move up
C 31969,2 Stop at the edge
C 31971,1 Reset the step counter
C 31972,1 Keep the step counter for the next time round
C 31973,1 Keep the count in A'
C 31974,1 Count the pixels
C 31975,2 Repeat for the length of the line
C 31977,3 Work out the new pen position
C 31980,1 Restore the direction and step count...
C 31981,1 ...and the caller's HL
C 31982,1 Done: the line has been drawn
C 31983,1 A=pixel count
C 31984,3 Plot the pixel
C 31987,2 Down?
C 31989,2 Not moving down: go up instead
C 31991,3 Move down
C 31994,2 Stop at the edge
C 31996,2 Skip the up move
C 31998,3 Move up
C 32001,2 Stop at the edge
C 32003,1 Time for a horizontal step?
C 32004,2 Jump if not
C 32006,2 Left?
C 32008,2 Not moving left: go right instead
C 32010,3 Move left
C 32013,2 Stop at the edge
C 32015,2 Skip the right move
C 32017,3 Move right
C 32020,2 Stop at the edge
C 32022,1 Reset the step counter
C 32023,1 Keep the step counter for the next time round
C 32024,1 Keep the count in A'
C 32025,1 Count the pixels
C 32026,2 Repeat for the length of the line
C 32028,3 Work out the new pen position
C 32031,1 Restore the direction and step count...
C 32032,1 ...and the caller's HL
C 32033,1 Done: the line has been drawn
c 32034 Plot the pixel at HL (mask D) and set its attribute
C 32034,1 Save HL
C 32035,1 A=the pixel mask
C 32036,1 Keep it
C 32037,3 Set the ink of the cell
C 32040,1 Get the mask back
C 32041,1 Set the pixel
C 32042,1 Store the byte with the pixel set
C 32043,1 Restore HL
C 32044,1 Done
c 32045 Set the ink of the attribute for display file address HL
D 32045 Uses the ink colour in #R31522.
C 32045,1 Save HL
C 32046,1 Work out the attribute address
C 32047,2 Keep bits 3-4 of H: the screen third (0-2) times 8
C 32049,1 Move the third number...
C 32050,1 ...down...
C 32051,1 ...to the low bits
C 32052,2 Add the high byte of the attribute file
C 32054,1 H=attribute address high byte
C 32055,1 Clear the old ink
C 32056,2 Clear the three ink bits
C 32058,1 Store the attribute without ink
C 32059,3 Put in the new one
C 32062,1 Add the new ink colour
C 32063,1 Store the updated attribute
C 32064,1 Restore HL
C 32065,1 Done
c 32066 Get the display file address and mask for pixel (D,E)
D 32066 Uses the ROM routine PIXEL-ADD (entered at 8880, just after its first instructions).
R 32066 Input:D x
R 32066 E y
R 32066 Output:HL Address
R 32066 A Pixel mask
C 32066,1 Save BC
C 32067,1 C=x
C 32068,2 B=175-y (the ROM counts from the bottom)
C 32070,1 A=175-y
C 32071,3 Use the ROM's PIXEL-ADD (skipping its first instructions)
C 32074,1 A=bit position
C 32075,1 B=the bit position plus one
C 32076,2 Turn it into a mask
C 32078,2 Rotate the mask right
C 32080,2 Repeat for each position
C 32082,1 Restore BC
C 32083,1 Return
c 32084 Convert a display file address and mask back to coordinates
D 32084 Inverse of #R32066.
C 32084,2 Turn the mask back into a bit position
C 32086,1 Count the shifts
C 32087,2 Rotate the mask left until the bit falls out
C 32089,2 Repeat
C 32091,1 D=the bit position (0-7)
C 32092,1 x=8*column+bit
C 32093,2 Keep the column
C 32095,1 Multiply by 8
C 32096,1 ...
C 32097,1 ...
C 32098,1 Add the bit position
C 32099,1 D=x
C 32100,1 y=row within the character...
C 32101,2 Keep the pixel row within the cell
C 32103,1 E=it
C 32104,1 ...plus 8*character row...
C 32105,2 Keep the character row bits
C 32107,1 Move them to bits 3-5
C 32108,1 ...
C 32109,1 Add the pixel row
C 32110,1 E=it
C 32111,1 ...plus 64*third
C 32112,2 Keep the third bits
C 32114,1 Move them to bits 6-7
C 32115,1 ...
C 32116,1 ...
C 32117,1 Add the lower bits
C 32118,1 E=y counted from the top
C 32119,2 Convert to the ROM's coordinates
C 32121,1 Subtract from 175
C 32122,1 E=y counted from the bottom
C 32123,1 Return
b 32124 The end of the point list
B 32124,2,2
c 32126 Draw a compressed picture
D 32126 The larger full-screen pictures (the Partridge Club and the street outside Milton's) use a second, more compact format: a 9-byte header (the offset of the end of the point bit-stream, the bit position where it ends, the offset of the attribute data and four bit widths for the coordinate deltas), a bit-stream of points in which each coordinate is stored as a variable-width delta read by #R32539, line segments drawn between the points (#R32612), and finally three run-length encoded passes over the attribute file (ink, then paper, then bright and flash).
R 32126 Input:HL Picture data
@ 32126 label=DRAWCPIC
C 32126,1 Save HL
C 32127,2 IY=picture header
C 32129,3 Clear the screen
C 32132,3 The bit-stream starts after the 9-byte header
C 32135,1 HL=the start of the bit-stream
C 32136,3 Set the bit-stream pointer
C 32139,1 Start at bit 0
C 32140,3 Store bit position 0
C 32143,3 Start at (0,0)
C 32146,3 Draw the strokes...
C 32149,2 ...until the end of the point list
C 32151,3 HL=the offset of the attribute data (header bytes 3-4)
C 32154,3 H=the high byte of the offset
C 32157,2 Copy IY into DE...
C 32159,1 ...by way of the stack
C 32160,1 Add the address of the header
C 32161,3 Remember it: it also marks the end of the list of fill seeds
C 32164,3 HL=the offset of the end of the point bit-stream (header bytes 0-1)
C 32167,3 H=the high byte of the offset
C 32170,1 HL=the address just after the bit-stream
C 32171,3 Does the bit-stream end part-way through a byte (header byte 2)?
C 32174,1 Test the byte
C 32175,2 Zero: no padding byte
C 32177,1 Yes: skip that last byte
C 32178,1 Save the address
C 32179,2 IY=the list of fill seed points
C 32181,3 D=x
C 32184,2 E=175-y
C 32186,3 A=175-y
C 32189,1 E=y counted from the top
C 32190,2 Next byte
C 32192,2 Next seed point
C 32194,2 Fill with ink 0 on paper 7
C 32196,3 Fill the area around the seed
C 32199,2 Reached the end of the seed points?
C 32201,1 HL=the position in the list
C 32202,4 DE=the end of the list
C 32206,1 Clear the carry flag
C 32207,2 Compare
C 32209,2 Jump back if not
C 32211,4 DE=run-length attribute data
C 32215,3 First pass over the attribute file: the ink colours
C 32218,1 Reached the end of the attribute file?
C 32219,2 Is the high byte 91 (the end of the attribute file)?
C 32221,2 Jump if so
C 32223,1 Bits 0-4: run length-1
C 32224,2 Keep the run length bits
C 32226,1 B=the run length minus one
C 32227,1 B=the run length
C 32228,1 Bits 5-7: the ink colour
C 32229,1 Next byte of attribute data
C 32230,2 Keep the colour bits
C 32232,1 Rotate bits 5-7 round to bits 0-2...
C 32233,1 ...
C 32234,1 ...
C 32235,1 Set the ink for the run
C 32236,1 Next cell
C 32237,2 Repeat for every cell in the run
C 32239,2 Next run
C 32241,3 Second pass: the paper colours
C 32244,1 Reached the end of the attribute file?
C 32245,2 Is the high byte 91?
C 32247,2 Jump if so
C 32249,1 Bits 0-4: run length-1
C 32250,2 Keep the run length bits
C 32252,1 B=the run length minus one
C 32253,1 B=the run length
C 32254,1 Bits 5-7: the paper colour
C 32255,1 Next byte of attribute data
C 32256,2 Keep the colour bits
C 32258,1 Move bits 5-7 down to bits 3-5...
C 32259,1 ...
C 32260,1 C=the paper colour
C 32261,1 Add the paper to each cell in the run
C 32262,1 Merge it with the ink already there
C 32263,1 Store it
C 32264,1 Next cell
C 32265,2 Repeat for every cell in the run
C 32267,2 Next run
C 32269,3 Third pass: bright and flash
C 32272,1 Reached the end of the attribute file?
C 32273,2 Is the high byte 91?
C 32275,1 Return if so
C 32276,1 Bits 0-5: run length-1
C 32277,2 Keep the run length bits
C 32279,1 B=the run length minus one
C 32280,1 B=the run length
C 32281,1 Bits 6-7: bright and flash
C 32282,1 Next byte of attribute data
C 32283,2 Keep the bright and flash bits
C 32285,1 C=the bits
C 32286,1 Add them to each cell in the run
C 32287,1 Merge them with the colours already there
C 32288,1 Store them
C 32289,1 Next cell
C 32290,2 Repeat for every cell in the run
C 32292,2 Next run
c 32294 Draw the next stroke of a compressed picture
D 32294 Returns with the zero flag set at the end of the point list.
C 32294,3 Reached the end of the point list?
C 32297,2 Copy IY into DE...
C 32299,1 ...by way of the stack
C 32300,1 Clear the carry flag
C 32301,2 HL=the stream pointer's offset from the header
C 32303,3 E=the low byte of the offset of the end
C 32306,3 D=the high byte
C 32309,1 Clear the carry flag
C 32310,2 Compare: is this the end byte?
C 32312,2 Jump if not
C 32314,3 Check the bit position too
C 32317,3 Is it the end bit position too?
C 32320,1 Return with the zero flag set at the end
C 32321,2 Read one bit: 1 = start a new stroke, 0 = continue the current one
C 32323,3 Read the bit
C 32326,1 Test the bit
C 32327,2 Jump to continue the stroke
C 32329,3 Read the starting point
C 32332,3 Plot it
C 32335,1 Merge the pixel with the screen byte
C 32336,1 Store it
C 32337,2 Reset the zero flag: more to come
C 32339,1 Return
C 32340,4 Remember the start of the line
C 32344,3 Get its screen address
C 32347,1 D=the pixel mask
C 32348,1 Switch to the alternate registers
C 32349,4 BC'=the line start
C 32353,3 Read the next point
C 32356,1 Save the end point
C 32357,3 Draw a line to it
C 32360,1 Switch back
C 32361,1 BC=the end point
C 32362,2 Reset the zero flag: more to come
C 32364,1 Return
c 32365 Read the next point (x in C, y in B)
C 32365,2 Read one bit: absolute or relative coordinates?
C 32367,3 Read it
C 32370,1 Test it
C 32371,2 Zero: only one coordinate is given
C 32373,3 Read x
C 32376,1 C=x
C 32377,3 Read y
C 32380,1 B=y
C 32381,1 Return
C 32382,2 Read one bit: short or long deltas?
C 32384,3 Read it
C 32387,1 Test it
C 32388,2 One: it is a y delta
C 32390,3 Read a long x delta
C 32393,1 C=the new x
C 32394,1 Return
C 32395,3 Read a long y delta
C 32398,1 B=the new y
C 32399,1 Return
c 32400 Read an x coordinate (absolute or delta)
C 32400,2 D=1: read one bit
C 32402,3 Read it
C 32405,1 Test it
C 32406,2 Zero: a short delta follows
C 32408,2 D=8: an absolute coordinate has eight bits
C 32410,3 Read it and return
C 32413,3 A=the number of bits in a short x delta (from the picture header)
C 32416,1 D=the number of bits
C 32417,3 Read the delta (left-aligned in A)
C 32420,1 D=the delta
C 32421,3 A=the number of bits
C 32424,2 Shift right, keeping the sign...
C 32426,1 ...until the delta is right-aligned
C 32427,2 ...(8 minus the number of bits times)
C 32429,2 Repeat
C 32431,1 A=the signed delta
C 32432,1 Add the old x (C)
C 32433,1 Add it to the old x
c 32434 Read a y coordinate (absolute or delta)
C 32434,2 Return
C 32436,3 Read it
C 32439,1 Test it
C 32440,2 Zero: a short delta follows
C 32442,2 D=8: an absolute coordinate has eight bits
C 32444,3 Read it and return
C 32447,3 A=the number of bits in a short y delta (from the picture header)
C 32450,1 D=the number of bits
C 32451,3 Read the delta (left-aligned in A)
C 32454,1 D=the delta
C 32455,3 A=the number of bits
C 32458,2 Shift right, keeping the sign...
C 32460,1 ...until the delta is right-aligned
C 32461,2 ...(8 minus the number of bits times)
C 32463,2 Repeat
C 32465,1 A=the signed delta
C 32466,1 Add it to the old y
C 32467,1 Return
c 32468 Read a long x delta
C 32468,2 D=1: read one bit
C 32470,3 Read it
C 32473,1 Test it
C 32474,2 Zero: a long delta follows
C 32476,2 D=8: an absolute coordinate has eight bits
C 32478,3 Read it and return
C 32481,3 A=the number of bits in a long x delta (from the picture header)
C 32484,1 D=the number of bits
C 32485,3 Read the delta (left-aligned in A)
C 32488,1 D=the delta
C 32489,3 A=the number of bits
C 32492,2 Shift right, keeping the sign...
C 32494,1 ...until the delta is right-aligned
C 32495,2 ...(8 minus the number of bits times)
C 32497,2 Repeat
C 32499,1 A=the signed delta
C 32500,1 Add it to the old x
C 32501,1 Return
c 32502 Read a long y delta
C 32502,2 D=1: read one bit
C 32504,3 Read it
C 32507,1 Test it
C 32508,2 Zero: a long delta follows
C 32510,2 D=8: an absolute coordinate has eight bits
C 32512,3 Read it and return
C 32515,3 A=the number of bits in a long y delta (from the picture header)
C 32518,1 D=the number of bits
C 32519,3 Read the delta (left-aligned in A)
C 32522,1 D=the delta
C 32523,3 A=the number of bits
C 32526,2 Shift right, keeping the sign...
C 32528,1 ...until the delta is right-aligned
C 32529,2 ...(8 minus the number of bits times)
C 32531,2 Repeat
C 32533,1 A=the signed delta
C 32534,1 Add it to the old y
C 32535,1 Return
b 32536 The bit-stream pointer
B 32536,3,3
c 32539 Read D bits from the picture bit-stream
D 32539 The bits come back left-aligned: the value is in the top D bits of A and the callers shift it down.
R 32539 Input:D Number of bits
R 32539 Output:A The bits, left-aligned
C 32539,1 Save HL
C 32540,1 Save DE
C 32541,3 Pick up the next two bytes of the bit-stream
C 32544,1 D=the first byte of the stream
C 32545,1 Next byte
C 32546,1 E=the second byte
C 32547,1 HL=the two bytes
C 32548,3 Shift them left by the bit position
C 32551,1 Test the bit position...
C 32552,1 ...
C 32553,2 Zero: the shift is done
C 32555,1 Shift the pair left
C 32556,2 Shift the pair left one more bit
C 32558,1 D=number of bits wanted
C 32559,1 A=the number of bits
C 32560,2 Build a mask of D bits
C 32562,1 Set the carry
C 32563,2 Shift a one into the mask
C 32565,1 Count down
C 32566,2 Repeat until the mask has D bits
C 32568,1 A=the mask
C 32569,1 Extract the bits
C 32570,1 Save the value
C 32571,3 Advance the bit position by D
C 32574,1 Add the number of bits to the bit position
C 32575,3 HL=the stream pointer
C 32578,2 Past the end of the byte?
C 32580,2 Less than 8: the position is right
C 32582,2 Take off 8
C 32584,1 Moving on a byte for each 8 bits
C 32585,2 Subtract 8 again
C 32587,3 Store the new bit position
C 32590,3 Store the new pointer
C 32593,1 Restore the value
C 32594,1 Restore HL
C 32595,1 Return with the bits left-aligned in A (the callers shift them down)
c 32596 Get the pixel address for (C,B)
D 32596 Uses ROM PIXEL-ADD.
C 32596,1 Save BC
C 32597,1 B=y
C 32598,3 Use the ROM's PIXEL-ADD
C 32601,1 B=the bit position plus one
C 32602,1 ...
C 32603,2 Turn the bit position into a mask
C 32605,1 Rotate the mask right
C 32606,2 Rotate the mask once for each bit position
C 32608,1 Restore BC
C 32609,1 Return
b 32610 The line start point
B 32610,2,2
c 32612 Draw a line from the last point to (C,B)
D 32612 A Bresenham line drawer.
C 32612,1 L=the target x
C 32613,2 H=0
C 32615,3 A=the start x (#R32610)
C 32618,1 E=it
C 32619,1 D=0
C 32620,1 Clear the carry flag
C 32621,2 HL=target x minus start x: the signed x distance
C 32623,1 A=the low byte of the distance
C 32624,3 D=1, E=1: the y step and the x step both start as +1
C 32627,2 Is the x distance negative?
C 32629,2 No
C 32631,2 A=its size
C 32633,2 E=255: the x step is -1
C 32635,1 C=the size of the x distance
C 32636,1 Save the steps
C 32637,1 L=the target y
C 32638,2 H=0
C 32640,3 A=the start y (32611)
C 32643,1 E=it
C 32644,1 D=0
C 32645,1 Clear the carry flag
C 32646,2 HL=target y minus start y: the signed y distance
C 32648,1 Get the steps back
C 32649,1 A=the low byte of the distance
C 32650,2 Is the y distance negative?
C 32652,2 No
C 32654,2 A=its size
C 32656,2 D=255: the y step is -1
C 32658,1 B=the size of the y distance
C 32659,1 A=the size of the x distance
C 32660,1 Compare it with the y distance
C 32661,2 x is the longer: that is the main direction
C 32663,1 y is the longer: L=the x distance (the shorter)
C 32664,4 Store the steps in the operand of the LD BC,0 at #R32693 (self-modifying)
C 32668,1 A=0
C 32669,1 E=0: no x step on the main direction
C 32670,3 Carry on
C 32673,1 L=the y distance (the shorter)
C 32674,1 B=the x distance (the number of pixels to draw)
C 32675,4 Store the steps in the operand of the LD BC,0 at #R32693 (self-modifying)
C 32679,2 D=0: no y step on the main direction
C 32681,1 H=the length of the main direction
C 32682,1 A=it
C 32683,1 Halve it: the error term starts half-way
C 32684,1 Add the shorter distance to the error term
C 32685,2 It overflowed a byte: step sideways
C 32687,1 Compare with the longer distance
C 32688,2 Smaller: no sideways step this time
C 32690,1 Take off the longer distance
C 32691,1 C=the new error term
C 32692,1 Switch to the alternate registers
C 32693,3 BC=the step for both directions (set above)
C 32696,3 Carry on
C 32699,1 C=the error term
C 32700,1 Save the main-direction step
C 32701,1 Switch to the alternate registers
C 32702,1 BC=the main-direction step only
C 32703,1 A=the vertical step
C 32704,1 Test it
C 32705,2 None: skip the vertical move
C 32707,2 Is it negative?
C 32709,2 No: move down
C 32711,1 Up one pixel row
C 32712,1 A=the high byte of the screen address
C 32713,2 Pixel row within the character cell
C 32715,2 Did the row wrap round to 7 (crossed a character boundary)?
C 32717,2 Yes: adjust the address
C 32719,3 No
C 32722,1 Down one pixel row
C 32723,1 A=the high byte
C 32724,2 Pixel row within the character cell
C 32726,2 Crossed into the next character row: adjust
C 32728,1 A=the horizontal step
C 32729,1 Test it
C 32730,2 None: plot the pixel
C 32732,2 Is it negative?
C 32734,2 Yes: move left
C 32736,2 Rotate the pixel mask right
C 32738,3 Still in the same byte
C 32741,1 Next byte
C 32742,3 Plot the pixel
C 32745,2 Rotate the pixel mask left
C 32747,3 Still in the same byte
C 32750,1 Previous byte
C 32751,1 A=the pixel mask
C 32752,1 Combine it with the screen byte
C 32753,1 Plot the pixel
C 32754,1 Switch back to the main registers
C 32755,1 A=the error term
C 32756,2 Loop for every pixel of the line
C 32758,1 Return
C 32759,1 A=the low byte
C 32760,2 Down one character row
C 32762,1 L=it
C 32763,2 Carry: this was the last row of the third, so H is already right
C 32765,1 A=the high byte
C 32766,2 Take back the 8
C 32768,1 H=it
C 32769,3 Carry on
C 32772,1 A=the low byte
C 32773,2 Up one character row
C 32775,1 L=it
C 32776,2 Carry: the borrow means H is already right
C 32778,1 A=the high byte
C 32779,2 Move up 8 in the high byte
C 32781,1 H=it
C 32782,3 Carry on
c 32785 Play the theme tune (if A=16)
D 32785 Plays the list of tune fragments at #R32832 via #R32866. The stack pointer is temporarily moved to 53792.
R 32785 Input:A SAY flags bits 4-6
@ 32785 label=TUNE
C 32785,4 Save the stack pointer
C 32789,3 Use a stack up at 53792
C 32792,2 Is the tune wanted?
C 32794,2 Play it if so
C 32796,4 Restore the stack pointer
C 32800,1 Done
b 32801 The saved stack pointer
B 32801,2,2
c 32803 Play the tune fragments listed at #R32832
C 32803,2 Save IX
C 32805,4 Point IX at the list of tune fragments
C 32809,3 Pick up the next fragment address
C 32812,3 H=the high byte of the fragment address
C 32815,1 End of the list?
C 32816,1 Combine with L: a zero address ends the list
C 32817,2 Finish if so
C 32819,3 Play the fragment
C 32822,2 Next fragment...
C 32824,2 ...(2 bytes per entry)
C 32826,2 Next fragment
C 32828,2 Restore IX
C 32830,2 Restore the stack and return
w 32832 Theme tune: list of fragments
D 32832 Addresses of the note lists played by #R32803 (terminated by 0).
W 32832,34,8*4,2
c 32866 Play a tune fragment
D 32866 Each note is four bytes: pitch, duration (2 bytes) and a flags byte. Stops early if a key is pressed.
R 32866 Input:HL Note data
C 32866,1 Stop if a key is pressed
C 32867,2 Read the keyboard
C 32869,2 Keep the key bits
C 32871,2 No key pressed?
C 32873,2 A key is pressed: stop the tune
C 32875,1 D=pitch
C 32876,1 A pitch of 0 ends the fragment
C 32877,1 Is the pitch zero?
C 32878,3 A pitch of zero: the fragment is over
C 32881,1 Next byte (the duration)
C 32882,1 E=duration
C 32883,1 Next byte (the flags)
C 32884,1 C=flags
C 32885,1 Next byte (the repeat count)
C 32886,1 B=repeat count
C 32887,1 Next byte (the next note)
C 32888,2 Default border/speaker value
C 32890,3 Modify the OUT value at 33000
C 32893,1 Bits 4-7 of the flags...
C 32894,1 Shift bits 4-7 down...
C 32895,1 ...
C 32896,1 ...
C 32897,1 ...
C 32898,2 Keep them
C 32900,2 Non-zero: use it as the delay
C 32902,3 ...override it if non-zero
C 32905,1 A=1: the default delay
C 32906,3 Modify the delay at 32930
C 32909,1 C=pitch slide (bits 0-3)
C 32910,2 Keep the slide bits
C 32912,1 C=the slide
C 32913,1 Save DE
C 32914,3 Start the note
C 32917,1 Save BC
C 32918,2 Short pause between repeats
C 32920,2 Pause
C 32922,3 Pad the timing
C 32925,1 Pad the timing
C 32926,1 Pad the timing
C 32927,1 Restore BC
C 32928,1 Save BC
C 32929,2 Delay (modified above)
C 32931,1 Pad the timing
C 32932,1 Pad the timing
C 32933,1 Pad the timing
C 32934,3 Play the note
C 32937,2 Pad the timing
C 32939,2 Play the note again for each repeat
C 32941,1 Restore BC
C 32942,1 Slide the pitch
C 32943,1 Add the slide to the pitch
C 32944,1 D=the new pitch
C 32945,1 Save the carry flag
C 32946,2 Up or down?
C 32948,3 Pitch slide is upward: go on
C 32951,1 Restore the carry flag
C 32952,3 Stop if the pitch wrapped round
C 32955,3 Continue
C 32958,1 Restore the carry flag
C 32959,3 Stop if the pitch wrapped round
C 32962,3 Continue
C 32965,1 Shorten the duration
C 32966,1 Take the slide off the duration
C 32967,1 E=the new duration
C 32968,2 A=refresh register (adds a little noise)
C 32970,2 Repeat
C 32972,1 Restore DE
C 32973,3 Next note
C 32976,1 Return
C 32977,1 Restore DE
C 32978,1 Save DE
C 32979,3 Finish this note
c 32982 Delay and toggle the speaker
C 32982,1 Save BC
C 32983,3 (Never used: B is overwritten by the next instruction)
C 32986,2 B=12: the fixed delay
C 32988,2 Wait about 12 loops
C 32990,1 Restore BC
C 32991,3 Toggle the speaker
C 32994,1 Done
c 32995 Toggle the speaker with a pulse
C 32995,2 Test bit 7 of the pitch
C 32997,2 A=0: speaker off
C 32999,2 A=speaker bit (this operand is modified by #R32890)
C 33001,3 Pad the timing
C 33004,3 Pad the timing
C 33007,2 Speaker on
C 33009,1 Save DE
C 33010,2 Mask the pitch (A is overwritten below, so this has no effect)
C 33012,1 A=the pitch
C 33013,1 D=pitch
C 33014,1 Delay for half a cycle
C 33015,3 Wait a half cycle
C 33018,2 Repeat until the half cycle is over
C 33020,2 A=0: speaker bit off
C 33022,2 Speaker off
C 33024,1 Delay for the other half
C 33025,3 Wait a half cycle
C 33028,2 Repeat until the half cycle is over
C 33030,1 Restore DE
C 33031,1 Return
c 33032 Short delay
C 33032,1 Save BC
C 33033,1 Timing padding
C 33034,1 Waste 4 T-states
C 33035,1 Waste 4 T-states
C 33036,1 Waste 4 T-states
C 33037,1 Restore BC
C 33038,1 Save BC
C 33039,1 Waste 4 T-states
C 33040,1 Waste 4 T-states
C 33041,1 Waste 4 T-states
C 33042,1 Waste 4 T-states
C 33043,1 Restore BC
C 33044,1 Save BC
C 33045,1 Waste 4 T-states
C 33046,1 Waste 4 T-states
C 33047,1 Waste 4 T-states
C 33048,1 Waste 4 T-states
C 33049,1 Restore BC
C 33050,1 Return
b 33051 Theme tune: note data
D 33051 Used by #R32866.
B 33051,501,8*62,5
b 33552 VM variables
D 33552 The VM has 84 32-bit signed variables, each holding a fixed-point number with two decimal places (so 1.00 is stored as 100). Variables 37-64 are constants; variables 65-83 are the table of initial values for v0-v18 copied by #R33937, but the script also uses v68-v72 as the constants 40, 10, 2.5, 1 and 0. See the #LINK(Variables)(variables page).
B 33552,4,4 v0 (StartClients): Number of clients at the start of the game (400) [0]
B 33556,4,4 v1 (Squeezed): Number of clients squeezed this year [0]
B 33560,4,4 v2 (Raided): Amount (in grand) taken by the cops in a raid [0]
B 33564,4,4 v3 (Hoods): Number of hoods in the mob (shown on the status line) [0]
B 33568,4,4 v4 (Killed): Number of hoods rubbed out last year [0]
B 33572,4,4 v5 (Price): Average protection payment per client [0]
B 33576,4,4 v6 (Year): Current year (starts at 1) [0]
B 33580,4,4 v7 (Dough): Dough in the safe, in thousands of dollars (shown on the status line) [0]
B 33584,4,4 v8 (Clients): Number of clients (shown on the status line as CUSTOMERS) [0]
B 33588,4,4 v9 (Recruits): Number of hoods recruited last year [0]
B 33592,4,4 v10 (TotalKilled): Total number of hoods killed during the game [0]
B 33596,4,4 v11 (Blunders): Number of blunders (silly answers) made this year [0]
B 33600,4,4 v12 (TotalBlunders): Total number of blunders made during the game [0]
B 33604,4,4 v13 (HoodYears): Sum of the mob size over all years [0]
B 33608,4,4 v14 (Loan): Loan from Nick the Greek (in grand) [0]
B 33612,4,4 v15 (Score): Final score (percentage) [0]
B 33616,4,4 v16 (TotalTakings): Total protection takings [0]
B 33620,4,4 v17 (TotalProfit): Total profit [0]
B 33624,4,4 v18 (ClientYears): Sum of the number of clients over all years [0]
B 33628,4,4 v19 (Bought): Number of clients bought from the syndicate this year [0]
B 33632,4,4 v20 (Sold): Number of clients sold to the syndicate this year [0]
B 33636,4,4 v21 (Unsqueezed): Number of clients available to be squeezed [0]
B 33640,4,4 v22 (ClientsLeft): Number of clients that would be left after a sale [0]
B 33644,4,4 v23 (Ammo): Amount spent on artillery and ammo this year [0]
B 33648,4,4 v24 (FedsKilled): Number of recruits killed in the shootout with the feds [0]
B 33652,4,4 v25 (Takings): Protection takings this year [0]
B 33656,4,4 v26 (Profit): Profit this year (after Rocco has taken his cut) [0]
B 33660,4,4 v27 (Interest): Interest rate on Nick the Greek's loan (percent) [0]
B 33664,4,4 v28 (HoodGrowth): Percentage growth of the mob over the game [0]
B 33668,4,4 v29 (ClientGrowth): Percentage growth of the client list over the game [0]
B 33672,4,4 v30 (Handout): Handout paid to keep the hoods loyal [0]
B 33676,4,4 v31 (Bribe): Bribe paid to Rocco's mob [0]
B 33680,4,4 v32 (Kickback): Annual kickback to the cops [0]
B 33684,4,4 v33 (Tmp): Scratch variable [0]
B 33688,4,4 v34 (ClientCost): Price of a client this year (in grand) [0]
B 33692,4,4 v35 (Input): Number entered by the player (x100 fixed point; see #R27790) [0]
B 33696,4,4 v36 (Years): Number of years the game will last (7-11, chosen at random by #R33937) [0]
B 33700,4,4 v37 (K800): Constant: 800 [800]
B 33704,4,4 v38 (K1000): Constant: 1000 [1000]
B 33708,4,4 v39 (Km005): Constant: -0.05 [-0.05]
B 33712,4,4 v40 (Km010): Constant: -0.1 [-0.1]
B 33716,4,4 v41 (K05): Constant: 0.5 [0.5]
B 33720,4,4 v42 (K15): Constant: 1.5 [1.5]
B 33724,4,4 v43 (K2): Constant: 2 [2]
B 33728,4,4 v44 (K3): Constant: 3 [3]
B 33732,4,4 v45 (K35): Constant: 3.5 [3.5]
B 33736,4,4 v46 (K4): Constant: 4 [4]
B 33740,4,4 v47 (K5): Constant: 5 [5]
B 33744,4,4 v48 (K6): Constant: 6 [6]
B 33748,4,4 v49 (K7): Constant: 7 [7]
B 33752,4,4 v50 (K8): Constant: 8 [8]
B 33756,4,4 v51 (K9): Constant: 9 [9]
B 33760,4,4 v52 (K11): Constant: 11 [11]
B 33764,4,4 v53 (K12): Constant: 12 [12]
B 33768,4,4 v54 (K13): Constant: 13 [13]
B 33772,4,4 v55 (K15b): Constant: 15 [15]
B 33776,4,4 v56 (K17): Constant: 17 [17]
B 33780,4,4 v57 (K19): Constant: 19 [19]
B 33784,4,4 v58 (K20): Constant: 20 [20]
B 33788,4,4 v59 (K25): Constant: 25 [25]
B 33792,4,4 v60 (K35b): Constant: 35 [35]
B 33796,4,4 v61 (K50): Constant: 50 [50]
B 33800,4,4 v62 (K60): Constant: 60 [60]
B 33804,4,4 v63 (K99): Constant: 99 [99]
B 33808,4,4 v64 (K100): Constant: 100 [100]
B 33812,4,4 v65 (v65): Initial value of v0 (part of the table at #R33812); not otherwise used [400]
B 33816,4,4 v66 (v66): Initial value of v1 (part of the table at #R33812); not otherwise used [300]
B 33820,4,4 v67 (v67): Initial value of v2 (part of the table at #R33812); not otherwise used [75]
B 33824,4,4 v68 (K40): Initial value of v3 (part of the table at #R33812); also used as the constant 40 [40]
B 33828,4,4 v69 (K10): Initial value of v4 (part of the table at #R33812); also used as the constant 10 [10]
B 33832,4,4 v70 (K25c): Initial value of v5 (part of the table at #R33812); also used as the constant 2.5 [2.5]
B 33836,4,4 v71 (K1): Initial value of v6 (part of the table at #R33812); also used as the constant 1 [1]
B 33840,4,4 v72 (K0): Initial value of v7 (part of the table at #R33812); also used as the constant 0 [0]
B 33844,4,4 v73 (v73): Initial value of v8 (part of the table at #R33812); not otherwise used [400]
B 33848,4,4 v74 (v74): Initial value of v9 (part of the table at #R33812); not otherwise used [10]
B 33852,4,4 v75 (v75): Initial value of v10 (part of the table at #R33812); not otherwise used [0]
B 33856,4,4 v76 (v76): Initial value of v11 (part of the table at #R33812); not otherwise used [0]
B 33860,4,4 v77 (v77): Initial value of v12 (part of the table at #R33812); not otherwise used [0]
B 33864,4,4 v78 (v78): Initial value of v13 (part of the table at #R33812); not otherwise used [0]
B 33868,4,4 v79 (v79): Initial value of v14 (part of the table at #R33812); not otherwise used [0]
B 33872,4,4 v80 (v80): Initial value of v15 (part of the table at #R33812); not otherwise used [0]
B 33876,4,4 v81 (v81): Initial value of v16 (part of the table at #R33812); not otherwise used [0]
B 33880,4,4 v82 (v82): Initial value of v17 (part of the table at #R33812); not otherwise used [0]
B 33884,4,4 v83 (v83): Initial value of v18 (part of the table at #R33812); not otherwise used [0]
b 33888 VM flags
D 33888 Nine flag bytes that the script tests and sets with IFPEEKEQ, IFPEEKNE and POKE, followed by the game status flag and some workspace used by the speech bubble code. #R33937 sets the nine flags and the status flag to 1 at the start of each game; the values below are those in the saved game image.
B 33888,1,1 Flag 0: the feds flag. 1 normally, 2 when the feds have been tipped off (set at the end of the recruiting step, tested in the next report; see the #LINK(Economics)(economics page))
B 33889,1,1 Flag 1: set to 2 when the ammo comes to 1 grand per hood or less (adequate or not), but never tested
B 33890,1,1 Flag 2: set to 2 when the game ends early (the mob walks out, Nick the Greek, no money left for ammo, cousin Abe, an empty safe, or the hit man); the end of the game then skips the farewell from the hoods
B 33891,1,1 Flag 3: Rocco. Set to 2 when Rocco gets uppity; next year's report then halves the takings (if they are 3 grand or more) and changes its wording. Reset to 1 after the report
B 33892,1,1 Flag 4: the contract. 2 when the hit man is coming, 3 when he has won the shootout (set by #R28358); reset to 1 afterwards
B 33893,1,1 Flag 5: chooses between two openings of the contract warning; never changed from 1, so the second opening is never used
B 33894,1,1 Flag 6: the ammo flag. 2 when last year's ammo was inadequate and not forgiven (cousin Abe then takes over), 1 otherwise
B 33895,1,1 Flag 7: 1 in the first year, set to 2 at the end of every year
B 33896,1,1 Flag 8: the type of the last number entered, set by #R27835 (1 negative, 2 zero, 3 exactly 0.01, 4 anything else)
B 33897,1,1 Game status flag: non-zero ends the main loop at #R24614
B 33898,2,2 Default sub-message address
B 33900,2,2 Saved IY
B 33902,2,2 Pointer to this year's bubble layout table (#R33913 or #R33925)
B 33904,2,2 The current bubble layout
B 33906,1,1 Layout-unchanged flag
B 33907,2,2 Text width
b 33909 Speech bubble layouts
D 33909 Each entry is 4 bytes: a chance value (compared with a random number from 0 to 100), the address of the picture, and a byte that is always 0. #R33909 is the fixed "answer" layout. #R33913 and #R33925 start the two tables, one of which #R24614 picks at random each year; the SAY routine (#R28549) then takes the first entry in that table whose chance value is above a new random number. See #LINK(Facts#backgrounds)(Which background you get) on the trivia page for the resulting odds.
B 33909,4,4 Fixed "answer" layout: picture #R64646 (close-up of a hood)
B 33913,4,4 First table, below 30: picture #R58673 (a figure in a doorway)
B 33917,4,4 First table, below 70: picture #R59397 (two hoods at a table)
B 33921,4,4 First table, otherwise: picture #R57583 (a man in a hat at a table)
B 33925,4,4 Second table, below 33: picture #R63601 (hoods and a car in the city)
B 33929,4,4 Second table, below 66: picture #R60526 (the getaway car from above)
B 33933,4,4 Second table, otherwise: picture #R61625 (two figures at the waterfront)
c 33937 Initialise the game variables
D 33937 Copies the initial values of v0-v18 from the table at #R33812, sets the nine VM flags at #R33888 to 1 and chooses the length of the game: v36 = 7 + 4 x (a random number from 0 to 1.00), which is not rounded (see #LINK(Bugs#years)(the bugs page)).
@ 33937 label=INITVARS
C 33937,3 Copy the initial values of v0-v18...
C 33940,3 ...from the table at #R33812 (which doubles as variables v65-v83)
C 33943,3 BC=76: nineteen four-byte variables
C 33946,2 Copy them into place
C 33948,3 Set the nine VM flag bytes at #R33888...
C 33951,2 B=10: nine VM flags plus the game status flag
C 33953,2 ...and the game status flag to 1
C 33955,1 Next flag
C 33956,2 Loop for all ten
C 33958,3 BCDE=1.00
C 33961,3 BC=0: the high half of 1.00
C 33964,3 Get a random number in BCDE (0..1.00)
C 33967,1 Switch to the alternate registers to hold the multiplier
C 33968,3 BC'DE'=4.00
C 33971,3 BC'=0: the high half of 4.00
C 33974,3 Multiply
C 33977,1 Switch back
C 33978,3 BC'DE'=7.00
C 33981,3 BC=0: the high half of 7.00
C 33984,3 Add
C 33987,2 Store the result in v36 (the length of the game in years)
C 33989,3 Store BCDE in v36: the length of the game, 7 + 4 x (a random number), an unrounded number of years
C 33992,1 Return
b 33993 The sequence-finished flag
B 33993,1,1
c 33994 VM native: "A year goes by ......" animation
D 33994 Installs the IM2 interrupt routine at #R34069 (via the jump at #R53456 and the vector table at #R53504) and then plays one of two short animations chosen at random: the bar-room scene (step table at #R36348) or the getaway car (step table at #R34298).
R 33994 Nothing in the game chooses between them: not the year, the hoods, the cash or what happened in the year. The choice is one call of the random routine (#R30014, limit 100); a result below 50 gives the bar room. That is not an even split, because the routine is not uniform (see #R30026): counting the 256 raw values gives 154 for the bar room and 102 for the car, about 60% to 40%.
N 33994 #HTML[<img src="../images/baranim.gif" alt="The bar-room animation" /> <img src="../images/caranim.gif" alt="The getaway car animation" />]
@ 33994 label=YEARGOESBY
C 33994,1 Interrupts off while the animation interrupt routine is installed
C 33995,3 Point the interrupt jump at #R53456...
C 33998,3 ...at the interrupt routine at #R34069
C 34001,2 Point I at the vector table at #R53504
C 34003,2 Point the interrupt vector register at the table at #R53504
C 34005,2 Select interrupt mode 2
C 34007,1 Enable interrupts: #R34069 now runs fifty times a second
C 34008,1 Clear the sequence-finished flag
C 34009,3 Clear the "animation finished" flag
C 34012,2 Pick one of the two animations at random
C 34014,3 A=a random number from 0 to 100 (not evenly spread: below 50 about 60% of the time)
C 34017,4 Bar-room animation...
C 34021,2 Below 50?
C 34023,2 ...if the number is below 50
C 34025,4 Otherwise the getaway car animation
C 34029,3 Run the animation
C 34032,1 Interrupts off again
C 34033,2 Restore I (63 is its normal value)
C 34035,2 Put I back as the ROM expects it
C 34037,2 Back to interrupt mode 1
C 34039,1 Return
c 34040 Run the steps of an animation
D 34040 IX points at a list of step routine addresses. Once per tick (set by the interrupt routine) the current step is called; while it returns with the zero flag reset it is called again on the next tick, otherwise IX moves on to the next step. The sequence ends when #R33993 is set.
R 34040 Input:IX Step table
@ 34040 label=RUNSTEPS
C 34040,3 Has the animation finished?
C 34043,1 Test the flag
C 34044,1 Return if so
C 34045,1 Enable interrupts
C 34046,1 Wait for an interrupt
C 34047,1 And again, to be sure they are on
C 34048,3 Pick up the address of the current step routine
C 34051,3 H=the high byte of the step routine's address
C 34054,3 Call it
C 34057,2 Keep calling it until it returns with the zero flag set
C 34059,2 Then move to the next step
C 34061,2 Next step
C 34063,2 Loop back to wait for the interrupt and run the step
c 34065 Jump to the address in HL
C 34065,1 Jump to the step routine
b 34066 The interrupt countdown
B 34066,3,3
c 34069 Interrupt routine for the animations
D 34069 Counts down #R34066; when it reaches zero it reloads it from 34067 and sets the tick flag at 34068.
@ 34069 label=ISR1
C 34069,1 Save AF
C 34070,3 Decrement the interrupt countdown
C 34073,1 One tick less
C 34074,3 Store it
C 34077,2 Jump unless it has reached zero
C 34079,3 Reload the countdown
C 34082,3 Store it
C 34085,2 Set the tick flag
C 34087,3 Set the tick flag
C 34090,1 Restore AF
C 34091,2 Return from the interrupt
c 34093 Draw a 2-cell-wide sprite (no mask)
D 34093 Copies B=2 bytes per pixel row from DE to the screen at HL; the first byte at DE is the height.
C 34093,2 B=2: two bytes per pixel row
C 34095,2 Carry on with the common code
c 34097 Draw a 3-cell-wide sprite (no mask)
D 34097 As #R34093 but 3 bytes wide.
C 34097,2 B=3: three bytes per pixel row
C 34099,1 A=the height of the sprite (the first byte of the sprite data)
C 34100,1 Move to the graphic data
C 34101,1 C=the number of pixel rows
C 34102,1 Save the row counter and width
C 34103,1 Save the screen address
C 34104,1 A=a byte of the graphic
C 34105,1 Put it on the screen
C 34106,1 Next graphic byte
C 34107,1 Next screen column
C 34108,2 Loop for every byte of the row
C 34110,1 Restore the screen address
C 34111,1 Restore the row counter
C 34112,1 Down one pixel row
C 34113,1 A=the high byte
C 34114,2 Crossed into a new character row?
C 34116,2 Yes: adjust the address
C 34118,1 One row less
C 34119,2 Loop for every pixel row
C 34121,1 Return
C 34122,1 A=the low byte
C 34123,2 Down one character row
C 34125,1 L=the new low byte
C 34126,2 Carry: the next third of the screen (H is already right)
C 34128,1 A=the high byte
C 34129,2 Take back the 8 added by the pixel row steps
C 34131,1 H=it
C 34132,3 Carry on
c 34135 Prepare a pre-shifted masked sprite
D 34135 Copies the 32x32 sprite whose address is at HL into the buffer at DE, giving each row of 4 graphic bytes a mask byte of 255 and a spare 0 byte, then shifts the whole buffer right A pixels.
R 34135 This routine has a serious bug: it leaves the buffer address on the stack (PUSH DE ... POP HL; PUSH HL) and so, when A is 0, the RET Z at #R34164 "returns" into the sprite buffer and the CPU executes the graphic data. See the #LINK(Bugs#preshift)(bugs page).
N 34135 Input:A Shift (0-7) DE Buffer (24192 or 24384) HL Pointer to the sprite address
@ 34135 label=PRESHIFT
C 34135,1 Push the buffer address (this is the problem)
C 34136,1 Pick up the address of the sprite graphic
C 34137,1 Next byte
C 34138,1 D=the high byte of the sprite's graphic address
C 34139,1 HL=buffer address
C 34140,1 Leave it on the stack (above the return address)
C 34141,1 HL=graphic, DE=buffer
C 34142,1 Save the shift count
C 34143,1 A=0
C 34144,1 Switch to the alternate registers
C 34145,2 32 pixel rows
C 34147,1 Switch back
C 34148,3 Copy the 4 graphic bytes of this row
C 34151,2 Copy the four graphic bytes of the row
C 34153,1 A=255
C 34154,1 Add a mask byte of 255
C 34155,1 Next buffer byte
C 34156,1 A=0
C 34157,1 Add a spare byte of 0
C 34158,1 Next buffer byte
C 34159,1 Switch to the alternate registers (for the row counter)
C 34160,2 Next row
C 34162,1 Restore the shift count
C 34163,1 Is it zero?
C 34164,1 BUG: return to the buffer address left on the stack if so
C 34165,1 C=shift count
C 34166,1 HL=buffer
C 34167,1 Save the buffer address
C 34168,2 32 rows
C 34170,1 Rotate a 1 into the mask...
C 34171,2 Shift the mask byte right (the carry brings in a 1)
C 34173,1 Skip to the next mask byte
C 34174,1 (rows are 6 bytes long)
C 34175,2 Shift the second mask byte
C 34177,1 Skip on
C 34178,1 ...
C 34179,2 Shift the third mask byte
C 34181,1 Back to the first graphic byte
C 34182,1 ...
C 34183,1 ...
C 34184,1 ...and a 0 into the graphic
C 34185,2 Shift the first graphic byte (a 0 comes in)
C 34187,1 Next graphic byte
C 34188,1 ...
C 34189,2 Shift the second graphic byte
C 34191,1 Next graphic byte
C 34192,1 ...
C 34193,2 Shift the third graphic byte
C 34195,1 Next row
C 34196,2 Next row
C 34198,1 One pixel of shift less
C 34199,2 Repeat for each pixel of the shift
C 34201,1 Drop the buffer address
C 34202,1 Return properly
C 34203,2 C=32 pixel rows
C 34205,2 B=3 bytes per row
C 34207,1 A=the screen byte
C 34208,1 Switch to the alternate registers
C 34209,1 Save it in the background store
C 34210,1 Next store byte
C 34211,1 Switch back
C 34212,1 AND with the mask
C 34213,1 Next byte of the sprite buffer
C 34214,1 OR in the graphic
C 34215,1 Save the result in A'
C 34216,1 A=the screen column
C 34217,2 Column bits
C 34219,2 Is it column 30 or more?
C 34221,2 Yes: do not draw (off the right of the scene)
C 34223,1 Get the result back
C 34224,1 Draw it
C 34225,1 Next sprite buffer byte
C 34226,1 Next column
C 34227,2 Loop for three bytes
C 34229,1 Back to the first column
C 34230,1 ...
C 34231,1 ...
C 34232,1 Down one pixel row
C 34233,1 A=the high byte
C 34234,2 Crossed into the next character row?
C 34236,2 Yes: adjust
C 34238,1 One row less
C 34239,2 Loop for every row
C 34241,1 Return
C 34242,1 A=the low byte
C 34243,2 Down one character row
C 34245,1 E=the new low byte
C 34246,2 Carry: next third (D is right)
C 34248,1 A=the high byte
C 34249,2 Take back the 8
C 34251,1 D=it
C 34252,3 Carry on
C 34255,2 C=32 pixel rows
C 34257,2 B=3 bytes per row
C 34259,1 A=a saved background byte
C 34260,1 Put it back on the screen
C 34261,1 Next column
C 34262,1 Next saved byte
C 34263,2 Loop for three bytes
C 34265,1 Back to the first column
C 34266,1 ...
C 34267,1 ...
C 34268,1 Down one pixel row
C 34269,1 A=the high byte
C 34270,2 Crossed into the next character row?
C 34272,2 Yes: adjust
C 34274,1 One row less
C 34275,2 Loop for every row
C 34277,1 Return
C 34278,1 A=the low byte
C 34279,2 Down one character row
C 34281,1 E=the new low byte
C 34282,2 Carry: next third
C 34284,1 A=the high byte
C 34285,2 Take back the 8
C 34287,1 D=it
C 34288,3 Carry on
b 34291 Getaway car animation: counters
B 34291,7,7
w 34298 Getaway car animation: step table
D 34298 Used by #R34040.
W 34298,20,8*2,4
c 34318 Getaway car animation: step 1 (set up)
D 34318 Draws the street picture at #R55692 and initialises the positions and timers of the car and the hoods.
C 34318,1 A=0
C 34319,2 Black border
C 34321,3 HL=the compressed picture of the street
C 34324,3 Draw it
C 34327,3 HL=the screen address of the first hood's start position
C 34330,3 Store it
C 34333,3 HL=the screen address of the second hood's start position
C 34336,3 Store it
C 34339,3 HL=the first hood's frame list (#R37109)
C 34342,3 Store it
C 34345,3 HL=the second hood's frame list (#R37941)
C 34348,3 Store it
C 34351,3 HL=the screen address where the car starts (52311, with the left-clip flag in bit 7 of H)
C 34354,3 Store it as the car's position
C 34357,1 A=0
C 34358,3 The first hood's pixel shift is 0
C 34361,3 The second hood's pixel shift is 0
C 34364,3 The car's pixel shift is 0
C 34367,2 A=10
C 34369,3 The first hood waits 10 steps before moving
C 34372,3 Set the reload value of the interrupt countdown (one tick every 10 interrupts)
C 34375,3 Set the countdown
C 34378,3 Figure counter 34295 starts at 10
C 34381,2 A=9
C 34383,3 The first hood moves every 9 ticks
C 34386,2 A=13
C 34388,3 The second hood moves every 13 ticks
C 34391,2 A=8
C 34393,3 Counter for the figure at 17728
C 34396,3 Counter for the figure's delay
C 34399,2 A=3
C 34401,3 Step counter
C 34404,3 HL=the first hood's frame list
C 34407,1 Skip the first entry
C 34408,1 ...
C 34409,3 A=the first hood's pixel shift
C 34412,3 DE=the first hood's sprite buffer (24384)
C 34415,3 Prepare the shifted sprite
C 34418,3 Draw the first hood
C 34421,3 HL=the second hood's frame list
C 34424,1 Skip the first entry
C 34425,1 ...
C 34426,3 A=the second hood's pixel shift
C 34429,3 DE=the second hood's sprite buffer (24192)
C 34432,3 Prepare the shifted sprite
C 34435,3 Draw the second hood
C 34438,1 A=0: this step is complete
C 34439,1 Return
c 34440 Getaway car animation: last step
D 34440 Sets #R33993 to end the animation, then keeps scrolling the car off the screen.
C 34440,2 A=1
C 34442,3 Mark the animation as finished
C 34445,3 A=the car's pixel shift
C 34448,1 Test it
C 34449,1 Done if it is at a byte boundary
C 34450,3 Otherwise keep scrolling the car
C 34453,2 Check again
c 34455 Getaway step 2
C 34455,3 Draw the next frame of the street animation
C 34458,3 Restore the background behind the second hood
C 34461,3 Draw the second hood
C 34464,3 Draw the five-byte-wide graphic
C 34467,3 Move the second hood on
C 34470,3 A=the second hood's screen address
C 34473,2 Column
C 34475,2 Column 18?
C 34477,1 Yes: this step is not finished (Z set)
C 34478,2 Column 30?
C 34480,1 Return (Z set when the hood has reached column 30)
c 34481 Getaway step 3
C 34481,3 Draw the next frame of the street animation
C 34484,3 Restore the background behind the first hood
C 34487,3 Draw the first hood
C 34490,3 Restore the background behind the second hood
C 34493,3 Draw the second hood
C 34496,3 Draw the five-byte-wide graphic
C 34499,3 Move the first hood on
C 34502,3 Move the second hood on
C 34505,3 A=the first hood's screen address
C 34508,2 Column
C 34510,2 Column 30?
C 34512,1 Return (Z set when the first hood has reached column 30)
c 34513 Getaway step 5
C 34513,3 Draw the next frame of the street animation
C 34516,3 Scroll the car and redraw it
C 34519,3 HL=the car's screen address
C 34522,1 A=the low byte
C 34523,2 Column
C 34525,2 Column 20?
C 34527,1 No: keep going
C 34528,2 Is the left-clip flag set?
C 34530,1 Yes: keep going
C 34531,3 A=the car's pixel shift
C 34534,2 Shift 4?
C 34536,1 Return (Z set when the car is in position)
c 34537 Getaway step 6
C 34537,3 Draw the next frame of the street animation
C 34540,3 Draw the next frame of the figure at 18838
C 34543,1 Return if the figure's frame did not change
C 34544,3 A=the step counter
C 34547,1 One less
C 34548,3 Store it
C 34551,1 Return if not zero
C 34552,2 A=5
C 34554,3 Reload the step counter
C 34557,1 Return (Z set when the counter ran out)
c 34558 Getaway step 7
C 34558,3 Draw the next frame of the street animation
C 34561,3 Draw the next frame of the figure at 17728
C 34564,3 Play the delay sound and animate the figures
C 34567,3 Draw the next frame of the figure at 18838
C 34570,1 Return if the figure's frame did not change
C 34571,3 A=the step counter
C 34574,1 One less
C 34575,3 Store it
C 34578,1 Return (Z set when the counter ran out)
c 34579 Getaway step 8
C 34579,3 Draw the next frame of the street animation
C 34582,3 Scroll the car and redraw it
C 34585,3 Draw the next frame of the figure at 17728
C 34588,3 HL=the car's screen address
C 34591,1 A=the low byte
C 34592,2 Column
C 34594,2 Column 30?
C 34596,1 No: keep going
C 34597,2 Is the left-clip flag set?
C 34599,1 Return (Z set when the car has gone)
c 34600 Getaway step 9
C 34600,3 Draw the next frame of the street animation
C 34603,3 Draw the next frame of the figure at 17728
C 34606,3 A=the figure counter
C 34609,1 Test it
C 34610,1 Return (Z set when it has run out)
c 34611 Getaway car animation: scroll the car and wait
C 34611,3 Scroll the car two pixels
C 34614,3 Draw the car's moving parts
C 34617,3 BC=440: a long delay when the car is at a byte boundary
C 34620,3 A=the car's pixel shift
C 34623,1 Test it
C 34624,2 At a boundary: use the long delay
C 34626,3 BC=60: a short delay between pixels
C 34629,1 Count BC down
C 34630,1 A=B
C 34631,1 Combine with C
C 34632,2 Loop until it reaches zero
C 34634,3 Draw the car, clipped to the scene
C 34637,3 Draw the masked graphic at 19299
C 34640,3 Draw the car's lower parts
c 34643 Getaway car animation: move the first hood
C 34643,3 A=the first hood's counter
C 34646,1 One tick less
C 34647,3 Store it
C 34650,1 Not time to move yet
C 34651,2 A=9
C 34653,3 Reload the counter
C 34656,3 HL=the first hood's screen address
C 34659,3 A=the number of steps to wait first
C 34662,1 Test it
C 34663,2 None: move the hood
C 34665,1 One less
C 34666,3 Store it
C 34669,2 Skip the move this time
C 34671,3 A=the pixel shift
C 34674,2 Add 4 (the hood moves 4 pixels per step)
C 34676,2 Keep it within a byte
C 34678,3 Store it
C 34681,2 Still inside the byte
C 34683,1 Next screen column
C 34684,3 Store the new address
C 34687,3 HL=the hood's frame list
C 34690,1 E=the next frame address, low byte
C 34691,1 Next byte
C 34692,1 D=high byte
C 34693,1 Next byte
C 34694,4 Store the new list position
C 34698,3 A=the pixel shift
C 34701,3 DE=the hood's sprite buffer
C 34704,3 Prepare the shifted sprite
c 34707 Getaway car animation: move the second hood
C 34707,3 A=the second hood's counter
C 34710,1 One tick less
C 34711,3 Store it
C 34714,1 Not time to move yet
C 34715,2 A=5
C 34717,3 Reload the counter
C 34720,3 HL=the second hood's screen address
C 34723,3 A=the pixel shift
C 34726,2 Add 2
C 34728,2 Keep it within a byte
C 34730,3 Store it
C 34733,2 Still inside the byte
C 34735,1 Next screen column
C 34736,3 Store the new address
C 34739,3 HL=the second hood's frame list
C 34742,1 E=the next frame address, low byte
C 34743,1 Next byte
C 34744,1 D=high byte
C 34745,1 Next byte
C 34746,4 Store the new list position
C 34750,3 A=the pixel shift
C 34753,3 DE=the second hood's sprite buffer
C 34756,3 Prepare the shifted sprite
c 34759 Restore the background behind the second hood
C 34759,4 DE=where the second hood was drawn
C 34763,3 HL=its saved background (24000)
C 34766,3 Put the background back
c 34769 Restore the background behind the first hood
C 34769,4 DE=where the first hood was drawn
C 34773,3 HL=its saved background (24096)
C 34776,3 Put the background back
c 34779 Draw the first hood (masked, pre-shifted)
C 34779,3 HL=the first hood's sprite buffer (24384)
C 34782,4 DE=its screen address
C 34786,4 Remember where it is drawn
C 34790,1 Switch to the alternate registers
C 34791,3 HL'=the first hood's background save area
C 34794,1 Switch back
C 34795,3 Draw it, saving the background
c 34798 Draw the second hood (masked, pre-shifted)
C 34798,3 HL=the second hood's sprite buffer (24192)
C 34801,4 DE=its screen address
C 34805,4 Remember where it is drawn
C 34809,1 Switch to the alternate registers
C 34810,3 HL'=the second hood's background save area
C 34813,1 Switch back
C 34814,3 Draw it, saving the background
c 34817 Getaway car animation: draw the 5-byte-wide graphic at 18465
C 34817,3 HL=a 5-byte-wide mask/graphic pair buffer (#R38469)
C 34820,3 DE=its screen address
C 34823,2 C=32 pixel rows
C 34825,2 B=5 bytes per row
C 34827,1 Save the row's address
C 34828,1 A=the screen byte
C 34829,1 Mask it
C 34830,1 Next buffer byte
C 34831,1 OR in the graphic
C 34832,1 Next buffer byte
C 34833,1 Put it on the screen
C 34834,1 Next column
C 34835,2 Loop for five bytes
C 34837,1 Restore the row's address
C 34838,1 Down one pixel row
C 34839,1 A=the high byte
C 34840,2 Crossed into the next character row?
C 34842,2 Yes: adjust
C 34844,1 One row less
C 34845,2 Loop for every row
C 34847,1 Return
C 34848,1 A=the low byte
C 34849,2 Down one character row
C 34851,1 E=the new low byte
C 34852,3 Carry: next third
C 34855,1 A=the high byte
C 34856,2 Take back the 8
C 34858,1 D=it
C 34859,3 Carry on
c 34862 Getaway car animation: draw the next frame of the animation at 21260
C 34862,3 A=the tick flag
C 34865,1 Test it
C 34866,1 Return if no tick has happened
C 34867,1 A=0
C 34868,3 Clear the flag
C 34871,3 HL=the frame list position
C 34874,1 E=the next frame's address, low byte
C 34875,1 Next byte
C 34876,1 D=high byte
C 34877,1 Next byte
C 34878,4 Store the new position
C 34882,3 DE=the screen address (21260)
C 34885,2 B=13 pixel rows
C 34887,1 A=a byte of the frame
C 34888,1 Put it on the screen
C 34889,1 Next byte
C 34890,1 Down a pixel row
C 34891,1 A=the high byte
C 34892,2 Crossed into the next character row?
C 34894,2 Yes: adjust
C 34896,2 Loop for 13 rows
C 34898,1 Return
C 34899,1 A=the low byte
C 34900,2 Down one character row
C 34902,1 E=the new low byte
C 34903,2 Carry: next third
C 34905,1 A=the high byte
C 34906,2 Take back the 8
C 34908,1 D=it
C 34909,3 Carry on
c 34912 Getaway car animation: draw the car's moving parts (frame depends on 38791)
C 34912,3 DE=where the first moving part is drawn (39143)
C 34915,3 HL=its first frame (#R39325)
C 34918,3 A=the car's pixel shift
C 34921,1 Test it
C 34922,2 Zero: use the first frame
C 34924,3 HL=the second frame (#R39341)
C 34927,2 Shift 2?
C 34929,2 Yes: use it
C 34931,3 HL=the third frame (#R39357)
C 34934,2 Shift 4?
C 34936,2 Yes: use it
C 34938,3 HL=the fourth frame (#R39373)
C 34941,3 Draw the first part
C 34944,3 DE=where the second moving part is drawn (39151)
C 34947,3 HL=its first frame (#R39389)
C 34950,3 A=the car's pixel shift
C 34953,1 Test it
C 34954,2 Zero: draw the first frame
C 34956,3 HL=the second frame (#R39405)
C 34959,2 Shift 2?
C 34961,2 Yes: draw it
C 34963,3 HL=the third frame (#R39421)
C 34966,2 Shift 4?
C 34968,2 Yes: draw it
C 34970,3 HL=the fourth frame (#R39437)
c 34973 Draw a masked 2x4 tile
C 34973,3 BC=11: the distance to the next row
C 34976,2 A=4 rows
C 34978,1 Save the row counter
C 34979,1 A=a byte of the car buffer
C 34980,1 OR in the next graphic byte
C 34981,1 Next byte
C 34982,1 AND with the mask byte
C 34983,1 Store it
C 34984,1 Next byte
C 34985,1 Next buffer byte
C 34986,1 A=the next byte of the car buffer
C 34987,1 OR in the graphic
C 34988,1 Next byte
C 34989,1 AND with the mask
C 34990,1 Store it
C 34991,1 Next byte
C 34992,1 HL=the buffer address
C 34993,1 Move to the start of the next row
C 34994,1 DE=the buffer address
C 34995,1 Get the row counter
C 34996,1 One row less
C 34997,2 Loop for four rows
C 34999,1 Return
c 35000 Scroll the car one pixel
D 35000 Shifts the car image buffer right and moves the car when 8 pixels have been done.
C 35000,3 HL=the car's screen address
C 35003,3 Remember it for the drawing routine
C 35006,3 HL=the car buffer (38794)
C 35009,1 Save it
C 35010,2 C=38 rows
C 35012,1 Clear the carry flag
C 35013,1 Save the start of the row
C 35014,2 B=12 bytes
C 35016,2 Rotate a byte right (carry passes along the row)
C 35018,1 Next byte
C 35019,2 Loop for 12 bytes
C 35021,1 Restore the start of the row
C 35022,2 B=12 bytes
C 35024,2 Rotate it right again: that is two pixels in all
C 35026,1 Next byte
C 35027,2 Loop for 12 bytes
C 35029,1 One row less
C 35030,2 Loop for 38 rows
C 35032,2 C=3: three more rows
C 35034,1 Set the carry flag: these rows (the mask) shift in 1s
C 35035,1 Save the start of the row
C 35036,2 B=12 bytes
C 35038,2 Rotate a byte right
C 35040,1 Next byte
C 35041,2 Loop for 12 bytes
C 35043,1 Restore the start of the row
C 35044,2 B=12 bytes
C 35046,2 Rotate right a second time
C 35048,1 Next byte
C 35049,2 Loop for 12 bytes
C 35051,1 One row less
C 35052,2 Loop for three rows
C 35054,1 Restore the buffer address
C 35055,3 A=the car's pixel shift
C 35058,2 Add 2 pixels
C 35060,2 Keep it within a byte
C 35062,3 Store it
C 35065,1 Return if the car has not completed a byte
C 35066,4 DE=the car's screen address
C 35070,1 Move on one column
C 35071,2 No carry from the low byte
C 35073,1 A=the high byte
C 35074,2 Move on to the next third of the screen
C 35076,1 D=it
C 35077,1 A=the low byte
C 35078,2 Column
C 35080,2 Column 3?
C 35082,2 No
C 35084,2 Clear the left-clip flag: the car has come into view
C 35086,4 Store the new position
C 35090,3 BC=455 bytes
C 35093,1 DE=the buffer
C 35094,1 ...
C 35095,1 HL=the next byte
C 35096,2 Shift the buffer down by one byte
C 35098,1 A=0
C 35099,1 Clear a byte
C 35100,1 Next byte
C 35101,1 Next source byte
C 35102,3 BC=36
C 35105,2 Shift 36 more bytes (the mask area)
C 35107,2 A=255
C 35109,1 Store a final mask byte
C 35110,1 Return
C 35111,3 HL=the car's screen address
C 35114,2 A=252: offset for the first part
C 35116,3 DE=the car's lower graphic (39250)
C 35119,3 Draw part of the car
C 35122,3 HL=the car's screen address
C 35125,2 A=253: offset for the second part
C 35127,3 DE=the next graphic (39262)
C 35130,3 Draw part of the car
C 35133,3 HL=the car's screen address
C 35136,2 A=0: no offset for the third part
C 35138,3 DE=the third graphic (39274)
c 35141 Draw part of the car (clipped)
C 35141,1 Add the offset to the high byte
C 35142,1 H=it
C 35143,1 A=the low byte
C 35144,2 Add 96: three character rows down
C 35146,1 L=it
C 35147,2 B=12 bytes
C 35149,2 Is the left-clip flag set?
C 35151,2 Yes: clip on the left
C 35153,1 A=the low byte
C 35154,2 Column
C 35156,2 Column 30?
C 35158,1 Yes: clipped on the right, return
C 35159,1 A=a graphic byte
C 35160,1 Mask the screen byte
C 35161,1 Store it
C 35162,1 Next column
C 35163,1 Next graphic byte
C 35164,2 Loop for 12 bytes
C 35166,1 Return
C 35167,1 A=the low byte
C 35168,2 Column
C 35170,2 Column 3?
C 35172,2 Yes: start drawing
C 35174,1 Next column
C 35175,2 Wrapped to column 0: adjust the third
C 35177,1 Skip a graphic byte
C 35178,2 Loop
C 35180,1 Return
C 35181,2 Clear the left-clip flag
C 35183,2 Start drawing
C 35185,1 A=the high byte
C 35186,2 Next third of the screen
C 35188,1 H=it
C 35189,3 Carry on
c 35192 Getaway car animation: draw the masked graphic at 19299
C 35192,3 HL=the screen address (19299)
C 35195,3 DE=the masked graphic (39286)
C 35198,2 B=5 pixel rows
C 35200,1 A=a graphic byte
C 35201,1 Mask the screen
C 35202,1 Store it
C 35203,1 Next graphic byte
C 35204,1 Next column
C 35205,1 A=the next graphic byte
C 35206,1 Mask the screen
C 35207,1 Store it
C 35208,1 Next graphic byte
C 35209,1 Next column
C 35210,1 A=the next graphic byte
C 35211,1 Mask the screen
C 35212,1 Store it
C 35213,1 Next graphic byte
C 35214,1 Back a column
C 35215,1 And another
C 35216,1 Down a pixel row
C 35217,2 Loop for 5 rows
C 35219,1 A=the low byte
C 35220,2 Down one character row
C 35222,1 L=it
C 35223,1 A=the high byte
C 35224,2 Take back the 8
C 35226,1 H=it
C 35227,2 C=3 character rows
C 35229,2 B=8 pixel rows
C 35231,1 A=a graphic byte
C 35232,1 Mask the screen
C 35233,1 Store it
C 35234,1 Next graphic byte
C 35235,1 Down a pixel row
C 35236,2 Loop for 8 rows
C 35238,1 A=the low byte
C 35239,2 Down one character row
C 35241,1 L=it
C 35242,1 A=the high byte
C 35243,2 Take back the 8
C 35245,1 H=it
C 35246,1 One character row less
C 35247,3 Loop
C 35250,1 Return
c 35251 Getaway car animation: draw the next frame of the figure at 18838
C 35251,3 A=the figure's frame counter
C 35254,1 One tick less
C 35255,3 Store it
C 35258,1 Not time for a new frame
C 35259,2 A=6
C 35261,3 Reload the counter
C 35264,3 HL=the frame list position
C 35267,1 E=the next frame's address, low byte
C 35268,1 Next byte
C 35269,1 D=high byte
C 35270,1 Next byte
C 35271,4 Store the new position
C 35275,3 DE=the screen address (18838)
C 35278,1 HL=the frame, DE=the screen address
C 35279,3 Draw the frame
C 35282,1 A=0
C 35283,1 Return
c 35284 Getaway car animation: play a delay sound and animate the figures
C 35284,3 A=the frame counter
C 35287,2 Is it 6?
C 35289,2 B=2
C 35291,3 Yes: pause
C 35294,3 A=the frame counter
C 35297,2 Is it 3?
C 35299,2 B=2
C 35301,3 Yes: pause
C 35304,3 A=the frame counter
C 35307,2 Is it 5?
C 35309,2 Yes: draw a gun flash
C 35311,2 Is it 2?
C 35313,1 No: return
C 35314,3 HL=the flash list position
C 35317,1 E=the next flash address, low byte
C 35318,1 Next byte
C 35319,1 D=high byte
C 35320,1 Next byte
C 35321,4 Store the new position
C 35325,1 E=the screen address, low byte
C 35326,1 Next byte
C 35327,1 D=high byte
C 35328,3 HL=the flash graphic (39892)
C 35331,2 B=16 pixel rows
C 35333,1 A=a screen byte
C 35334,1 OR in the flash
C 35335,1 Draw it
C 35336,1 Next flash byte
C 35337,1 Next column
C 35338,1 A=the next screen byte
C 35339,1 OR in the flash
C 35340,1 Draw it
C 35341,1 Next flash byte
C 35342,1 Back a column
C 35343,1 Down a pixel row
C 35344,1 A=the high byte
C 35345,2 Crossed into the next character row?
C 35347,2 Yes: adjust
C 35349,2 Loop for 16 rows
C 35351,1 Return
C 35352,1 A=the low byte
C 35353,2 Down one character row
C 35355,1 E=the new low byte
C 35356,3 Carry: next third
C 35359,1 A=the high byte
C 35360,2 Take back the 8
C 35362,1 D=it
C 35363,3 Carry on
c 35366 Getaway car animation: draw the next frame of the figure at 17728
C 35366,3 A=the figure's counter
C 35369,1 One tick less
C 35370,3 Store it
C 35373,1 Not time for a new frame
C 35374,2 A=8
C 35376,3 Reload the counter
C 35379,3 A=the step counter
C 35382,1 One less
C 35383,3 Store it
C 35386,3 HL=the frame list position
C 35389,1 E=the next frame's address, low byte
C 35390,1 Next byte
C 35391,1 D=high byte
C 35392,1 Next byte
C 35393,4 Store the new position
C 35397,1 E=the frame's graphic address, low byte
C 35398,1 Next byte
C 35399,1 D=high byte
C 35400,3 HL=the screen address (17728)
C 35403,3 Draw the sprite (two cells wide)
c 35406 Draw the car (unrolled, clipped at the screen edge)
D 35406 A long unrolled loop that ORs the car graphic into the screen, with clipping at column 30, for speed.
C 35406,3 DE=the first buffer (24119, 12 bytes per row)
C 35409,3 HL=the screen address where the picture starts (38792)
C 35412,1 Switch to the alternate registers
C 35413,3 HL'=the car buffer (38794, 12 bytes by 38 rows)
C 35416,1 Switch back
C 35417,2 C=38 pixel rows to draw
C 35419,3 A=the shift flag (38791)
C 35422,1 Test it
C 35423,3 Zero: use the version that copies the first buffer (#R35890)
C 35426,3 Non-zero: use the version that ORs in the car buffer (#R35452)
C 35429,1 Skip a byte of the first buffer
C 35430,1 Switch to the car buffer pointer (HL')
C 35431,1 Skip a car buffer byte
C 35432,1 Switch back to the first buffer and screen pointers
C 35433,1 Skip a byte of the first buffer
C 35434,1 Switch to the car buffer pointer (HL')
C 35435,1 Skip a car buffer byte
C 35436,1 Switch back to the first buffer and screen pointers
C 35437,1 Skip a byte of the first buffer
C 35438,1 Switch to the car buffer pointer (HL')
C 35439,1 Skip a car buffer byte
C 35440,1 Switch back to the first buffer and screen pointers
C 35441,1 Skip a byte of the first buffer
C 35442,1 Switch to the car buffer pointer (HL')
C 35443,1 Skip a car buffer byte
C 35444,1 Switch back to the first buffer and screen pointers
C 35445,1 Skip a byte of the first buffer
C 35446,1 Switch to the car buffer pointer (HL')
C 35447,1 Skip a car buffer byte
C 35448,1 Switch back to the first buffer and screen pointers
C 35449,3 Carry on with the next row
C 35452,1 Save the screen address of the start of this row
C 35453,1 A=the screen address, low byte
C 35454,2 Keep the row bits
C 35456,2 Column 30: the right-hand clip position
C 35458,1 B=the low byte of the clip position on this row
C 35459,2 Is the left-clip flag (bit 7 of H) set for this row?
C 35461,3 Yes: skip the columns left of the street scene first
C 35464,1 A=the next byte of the buffer at 24119
C 35465,1 Switch to the car buffer pointer (HL')
C 35466,1 OR in the matching byte of the car buffer
C 35467,1 Next car buffer byte
C 35468,1 Switch back to the first buffer and screen pointers
C 35469,1 Draw it on the screen
C 35470,1 Next byte of the first buffer
C 35471,1 Next screen column
C 35472,1 A=the screen column byte
C 35473,1 Reached the clip column (30)?
C 35474,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35476,1 A=the next byte of the buffer at 24119
C 35477,1 Switch to the car buffer pointer (HL')
C 35478,1 OR in the matching byte of the car buffer
C 35479,1 Next car buffer byte
C 35480,1 Switch back to the first buffer and screen pointers
C 35481,1 Draw it on the screen
C 35482,1 Next byte of the first buffer
C 35483,1 Next screen column
C 35484,1 A=the screen column byte
C 35485,1 Reached the clip column (30)?
C 35486,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35488,1 A=the next byte of the buffer at 24119
C 35489,1 Switch to the car buffer pointer (HL')
C 35490,1 OR in the matching byte of the car buffer
C 35491,1 Next car buffer byte
C 35492,1 Switch back to the first buffer and screen pointers
C 35493,1 Draw it on the screen
C 35494,1 Next byte of the first buffer
C 35495,1 Next screen column
C 35496,1 A=the screen column byte
C 35497,1 Reached the clip column (30)?
C 35498,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35500,1 A=the next byte of the buffer at 24119
C 35501,1 Switch to the car buffer pointer (HL')
C 35502,1 OR in the matching byte of the car buffer
C 35503,1 Next car buffer byte
C 35504,1 Switch back to the first buffer and screen pointers
C 35505,1 Draw it on the screen
C 35506,1 Next byte of the first buffer
C 35507,1 Next screen column
C 35508,1 A=the screen column byte
C 35509,1 Reached the clip column (30)?
C 35510,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35512,1 A=the next byte of the buffer at 24119
C 35513,1 Switch to the car buffer pointer (HL')
C 35514,1 OR in the matching byte of the car buffer
C 35515,1 Next car buffer byte
C 35516,1 Switch back to the first buffer and screen pointers
C 35517,1 Draw it on the screen
C 35518,1 Next byte of the first buffer
C 35519,1 Next screen column
C 35520,1 A=the screen column byte
C 35521,1 Reached the clip column (30)?
C 35522,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35524,1 A=the next byte of the buffer at 24119
C 35525,1 Switch to the car buffer pointer (HL')
C 35526,1 OR in the matching byte of the car buffer
C 35527,1 Next car buffer byte
C 35528,1 Switch back to the first buffer and screen pointers
C 35529,1 Draw it on the screen
C 35530,1 Next byte of the first buffer
C 35531,1 Next screen column
C 35532,1 A=the screen column byte
C 35533,1 Reached the clip column (30)?
C 35534,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35536,1 A=the next byte of the buffer at 24119
C 35537,1 Switch to the car buffer pointer (HL')
C 35538,1 OR in the matching byte of the car buffer
C 35539,1 Next car buffer byte
C 35540,1 Switch back to the first buffer and screen pointers
C 35541,1 Draw it on the screen
C 35542,1 Next byte of the first buffer
C 35543,1 Next screen column
C 35544,1 A=the screen column byte
C 35545,1 Reached the clip column (30)?
C 35546,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35548,1 A=the next byte of the buffer at 24119
C 35549,1 Switch to the car buffer pointer (HL')
C 35550,1 OR in the matching byte of the car buffer
C 35551,1 Next car buffer byte
C 35552,1 Switch back to the first buffer and screen pointers
C 35553,1 Draw it on the screen
C 35554,1 Next byte of the first buffer
C 35555,1 Next screen column
C 35556,1 A=the screen column byte
C 35557,1 Reached the clip column (30)?
C 35558,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35560,1 A=the next byte of the buffer at 24119
C 35561,1 Switch to the car buffer pointer (HL')
C 35562,1 OR in the matching byte of the car buffer
C 35563,1 Next car buffer byte
C 35564,1 Switch back to the first buffer and screen pointers
C 35565,1 Draw it on the screen
C 35566,1 Next byte of the first buffer
C 35567,1 Next screen column
C 35568,1 A=the screen column byte
C 35569,1 Reached the clip column (30)?
C 35570,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35572,1 A=the next byte of the buffer at 24119
C 35573,1 Switch to the car buffer pointer (HL')
C 35574,1 OR in the matching byte of the car buffer
C 35575,1 Next car buffer byte
C 35576,1 Switch back to the first buffer and screen pointers
C 35577,1 Draw it on the screen
C 35578,1 Next byte of the first buffer
C 35579,1 Next screen column
C 35580,1 A=the screen column byte
C 35581,1 Reached the clip column (30)?
C 35582,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35584,1 A=the next byte of the buffer at 24119
C 35585,1 Switch to the car buffer pointer (HL')
C 35586,1 OR in the matching byte of the car buffer
C 35587,1 Next car buffer byte
C 35588,1 Switch back to the first buffer and screen pointers
C 35589,1 Draw it on the screen
C 35590,1 Next byte of the first buffer
C 35591,1 Next screen column
C 35592,1 A=the screen column byte
C 35593,1 Reached the clip column (30)?
C 35594,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35596,1 A=the next byte of the buffer at 24119
C 35597,1 Switch to the car buffer pointer (HL')
C 35598,1 OR in the matching byte of the car buffer
C 35599,1 Next car buffer byte
C 35600,1 Switch back to the first buffer and screen pointers
C 35601,1 Draw it on the screen
C 35602,1 Next byte of the first buffer
C 35603,1 Next screen column
C 35604,1 Get the start of the row back
C 35605,1 Down one pixel row
C 35606,1 A=the high byte
C 35607,2 Crossed into the next character row?
C 35609,2 Yes: move down to the next character row
C 35611,1 One row less
C 35612,3 Draw the next row
C 35615,1 Return
C 35616,1 Skip a byte of the first buffer
C 35617,1 Switch to the car buffer pointer (HL')
C 35618,1 Skip a car buffer byte
C 35619,1 Switch back to the first buffer and screen pointers
C 35620,1 Skip a byte of the first buffer
C 35621,1 Switch to the car buffer pointer (HL')
C 35622,1 Skip a car buffer byte
C 35623,1 Switch back to the first buffer and screen pointers
C 35624,1 Skip a byte of the first buffer
C 35625,1 Switch to the car buffer pointer (HL')
C 35626,1 Skip a car buffer byte
C 35627,1 Switch back to the first buffer and screen pointers
C 35628,1 Skip a byte of the first buffer
C 35629,1 Switch to the car buffer pointer (HL')
C 35630,1 Skip a car buffer byte
C 35631,1 Switch back to the first buffer and screen pointers
C 35632,1 Skip a byte of the first buffer
C 35633,1 Switch to the car buffer pointer (HL')
C 35634,1 Skip a car buffer byte
C 35635,1 Switch back to the first buffer and screen pointers
C 35636,1 Skip a byte of the first buffer
C 35637,1 Switch to the car buffer pointer (HL')
C 35638,1 Skip a car buffer byte
C 35639,1 Switch back to the first buffer and screen pointers
C 35640,3 Carry on with the next row
C 35643,1 A=L
C 35644,2 Add one character row (32 bytes)
C 35646,1 L=the new low byte
C 35647,3 Carry: that was the last character row of its third, so H (already 8 higher) is right
C 35650,1 No carry: still in the same third, so A=the high byte
C 35651,2 Take back the 8 that the pixel row steps added
C 35653,1 H=the new high byte
C 35654,3 Carry on with the next row
C 35657,2 Clear the left-clip flag in H
C 35659,1 A=the screen address, low byte
C 35660,2 Isolate the column
C 35662,2 Reached column 3, the left edge of the street scene?
C 35664,3 Yes: start drawing
C 35667,1 No: skip this column (it is off the left of the scene)
C 35668,3 If L wrapped round, move down to the next third of the screen
C 35671,1 Skip a byte of the first buffer
C 35672,1 Switch to the car buffer pointer (HL')
C 35673,1 Skip a car buffer byte
C 35674,1 Switch back to the first buffer and screen pointers
C 35675,1 A=the screen address, low byte
C 35676,2 Isolate the column
C 35678,2 Reached column 3, the left edge of the street scene?
C 35680,3 Yes: start drawing
C 35683,1 No: skip this column (it is off the left of the scene)
C 35684,3 If L wrapped round, move down to the next third of the screen
C 35687,1 Skip a byte of the first buffer
C 35688,1 Switch to the car buffer pointer (HL')
C 35689,1 Skip a car buffer byte
C 35690,1 Switch back to the first buffer and screen pointers
C 35691,1 A=the screen address, low byte
C 35692,2 Isolate the column
C 35694,2 Reached column 3, the left edge of the street scene?
C 35696,3 Yes: start drawing
C 35699,1 No: skip this column (it is off the left of the scene)
C 35700,3 If L wrapped round, move down to the next third of the screen
C 35703,1 Skip a byte of the first buffer
C 35704,1 Switch to the car buffer pointer (HL')
C 35705,1 Skip a car buffer byte
C 35706,1 Switch back to the first buffer and screen pointers
C 35707,1 A=the screen address, low byte
C 35708,2 Isolate the column
C 35710,2 Reached column 3, the left edge of the street scene?
C 35712,3 Yes: start drawing
C 35715,1 No: skip this column (it is off the left of the scene)
C 35716,3 If L wrapped round, move down to the next third of the screen
C 35719,1 Skip a byte of the first buffer
C 35720,1 Switch to the car buffer pointer (HL')
C 35721,1 Skip a car buffer byte
C 35722,1 Switch back to the first buffer and screen pointers
C 35723,1 A=the screen address, low byte
C 35724,2 Isolate the column
C 35726,2 Reached column 3, the left edge of the street scene?
C 35728,3 Yes: start drawing
C 35731,1 No: skip this column (it is off the left of the scene)
C 35732,3 If L wrapped round, move down to the next third of the screen
C 35735,1 Skip a byte of the first buffer
C 35736,1 Switch to the car buffer pointer (HL')
C 35737,1 Skip a car buffer byte
C 35738,1 Switch back to the first buffer and screen pointers
C 35739,1 A=the screen address, low byte
C 35740,2 Isolate the column
C 35742,2 Reached column 3, the left edge of the street scene?
C 35744,3 Yes: start drawing
C 35747,1 No: skip this column (it is off the left of the scene)
C 35748,3 If L wrapped round, move down to the next third of the screen
C 35751,1 Skip a byte of the first buffer
C 35752,1 Switch to the car buffer pointer (HL')
C 35753,1 Skip a car buffer byte
C 35754,1 Switch back to the first buffer and screen pointers
C 35755,1 A=the screen address, low byte
C 35756,2 Isolate the column
C 35758,2 Reached column 3, the left edge of the street scene?
C 35760,3 Yes: start drawing
C 35763,1 No: skip this column (it is off the left of the scene)
C 35764,3 If L wrapped round, move down to the next third of the screen
C 35767,1 Skip a byte of the first buffer
C 35768,1 Switch to the car buffer pointer (HL')
C 35769,1 Skip a car buffer byte
C 35770,1 Switch back to the first buffer and screen pointers
C 35771,1 A=the screen address, low byte
C 35772,2 Isolate the column
C 35774,2 Reached column 3, the left edge of the street scene?
C 35776,3 Yes: start drawing
C 35779,1 No: skip this column (it is off the left of the scene)
C 35780,3 If L wrapped round, move down to the next third of the screen
C 35783,1 Skip a byte of the first buffer
C 35784,1 Switch to the car buffer pointer (HL')
C 35785,1 Skip a car buffer byte
C 35786,1 Switch back to the first buffer and screen pointers
C 35787,1 A=the screen address, low byte
C 35788,2 Isolate the column
C 35790,2 Reached column 3, the left edge of the street scene?
C 35792,3 Yes: start drawing
C 35795,1 No: skip this column (it is off the left of the scene)
C 35796,3 If L wrapped round, move down to the next third of the screen
C 35799,1 Skip a byte of the first buffer
C 35800,1 Switch to the car buffer pointer (HL')
C 35801,1 Skip a car buffer byte
C 35802,1 Switch back to the first buffer and screen pointers
C 35803,1 A=the screen address, low byte
C 35804,2 Isolate the column
C 35806,2 Reached column 3, the left edge of the street scene?
C 35808,3 Yes: start drawing
C 35811,1 No: skip this column (it is off the left of the scene)
C 35812,3 If L wrapped round, move down to the next third of the screen
C 35815,1 Skip a byte of the first buffer
C 35816,1 Switch to the car buffer pointer (HL')
C 35817,1 Skip a car buffer byte
C 35818,1 Switch back to the first buffer and screen pointers
C 35819,1 A=the screen address, low byte
C 35820,2 Isolate the column
C 35822,2 Reached column 3, the left edge of the street scene?
C 35824,3 Yes: start drawing
C 35827,1 No: skip this column (it is off the left of the scene)
C 35828,3 If L wrapped round, move down to the next third of the screen
C 35831,1 Skip a byte of the first buffer
C 35832,1 Switch to the car buffer pointer (HL')
C 35833,1 Skip a car buffer byte
C 35834,1 Switch back to the first buffer and screen pointers
C 35835,1 A=the screen address, low byte
C 35836,2 Isolate the column
C 35838,2 Reached column 3, the left edge of the street scene?
C 35840,3 Yes: start drawing
C 35843,1 No: skip this column (it is off the left of the scene)
C 35844,3 If L wrapped round, move down to the next third of the screen
C 35847,1 Skip a byte of the first buffer
C 35848,1 Switch to the car buffer pointer (HL')
C 35849,1 Skip a car buffer byte
C 35850,1 Switch back to the first buffer and screen pointers
C 35851,3 Carry on with the next row
c 35854 Move H to the next third of the display file
C 35854,1 A=H
C 35855,2 A=A+8
C 35857,1 H=A
C 35858,1 Return
C 35859,1 Skip a byte of the first buffer
C 35860,1 Switch to the car buffer pointer (HL')
C 35861,1 Skip a car buffer byte
C 35862,1 Switch back to the first buffer and screen pointers
C 35863,1 Skip a byte of the first buffer
C 35864,1 Switch to the car buffer pointer (HL')
C 35865,1 Skip a car buffer byte
C 35866,1 Switch back to the first buffer and screen pointers
C 35867,1 Skip a byte of the first buffer
C 35868,1 Switch to the car buffer pointer (HL')
C 35869,1 Skip a car buffer byte
C 35870,1 Switch back to the first buffer and screen pointers
C 35871,1 Skip a byte of the first buffer
C 35872,1 Switch to the car buffer pointer (HL')
C 35873,1 Skip a car buffer byte
C 35874,1 Switch back to the first buffer and screen pointers
C 35875,1 Skip a byte of the first buffer
C 35876,1 Switch to the car buffer pointer (HL')
C 35877,1 Skip a car buffer byte
C 35878,1 Switch back to the first buffer and screen pointers
C 35879,1 Skip a byte of the first buffer
C 35880,1 Switch to the car buffer pointer (HL')
C 35881,1 Skip a car buffer byte
C 35882,1 Switch back to the first buffer and screen pointers
C 35883,1 Skip a byte of the first buffer
C 35884,1 Switch to the car buffer pointer (HL')
C 35885,1 Skip a car buffer byte
C 35886,1 Switch back to the first buffer and screen pointers
C 35887,3 Carry on with the next row
C 35890,1 Save the screen address of the start of this row
C 35891,1 A=the screen address, low byte
C 35892,2 Keep the row bits
C 35894,2 Column 30: the right-hand clip position
C 35896,1 B=the low byte of the clip position on this row
C 35897,2 Is the left-clip flag (bit 7 of H) set for this row?
C 35899,3 Yes: skip the columns left of the street scene first
C 35902,1 A=the next byte of the buffer at 24119
C 35903,1 Draw it on the screen
C 35904,1 Increment L
C 35905,1 A=the screen column byte
C 35906,1 Reached the clip column (30)?
C 35907,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35909,1 Increment DE
C 35910,1 A=the byte at DE
C 35911,1 Decrement DE
C 35912,1 Store A at DE
C 35913,1 Switch to the car buffer pointer (HL')
C 35914,1 OR in the matching byte of the car buffer
C 35915,1 Next car buffer byte
C 35916,1 Switch back to the first buffer and screen pointers
C 35917,1 Draw it on the screen
C 35918,1 Next byte of the first buffer
C 35919,1 Next screen column
C 35920,1 A=the screen column byte
C 35921,1 Reached the clip column (30)?
C 35922,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35924,1 Increment DE
C 35925,1 A=the byte at DE
C 35926,1 Decrement DE
C 35927,1 Store A at DE
C 35928,1 Switch to the car buffer pointer (HL')
C 35929,1 OR in the matching byte of the car buffer
C 35930,1 Next car buffer byte
C 35931,1 Switch back to the first buffer and screen pointers
C 35932,1 Draw it on the screen
C 35933,1 Next byte of the first buffer
C 35934,1 Next screen column
C 35935,1 A=the screen column byte
C 35936,1 Reached the clip column (30)?
C 35937,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35939,1 Increment DE
C 35940,1 A=the byte at DE
C 35941,1 Decrement DE
C 35942,1 Store A at DE
C 35943,1 Switch to the car buffer pointer (HL')
C 35944,1 OR in the matching byte of the car buffer
C 35945,1 Next car buffer byte
C 35946,1 Switch back to the first buffer and screen pointers
C 35947,1 Draw it on the screen
C 35948,1 Next byte of the first buffer
C 35949,1 Next screen column
C 35950,1 A=the screen column byte
C 35951,1 Reached the clip column (30)?
C 35952,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35954,1 Increment DE
C 35955,1 A=the byte at DE
C 35956,1 Decrement DE
C 35957,1 Store A at DE
C 35958,1 Switch to the car buffer pointer (HL')
C 35959,1 OR in the matching byte of the car buffer
C 35960,1 Next car buffer byte
C 35961,1 Switch back to the first buffer and screen pointers
C 35962,1 Draw it on the screen
C 35963,1 Next byte of the first buffer
C 35964,1 Next screen column
C 35965,1 A=the screen column byte
C 35966,1 Reached the clip column (30)?
C 35967,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35969,1 Increment DE
C 35970,1 A=the byte at DE
C 35971,1 Decrement DE
C 35972,1 Store A at DE
C 35973,1 Switch to the car buffer pointer (HL')
C 35974,1 OR in the matching byte of the car buffer
C 35975,1 Next car buffer byte
C 35976,1 Switch back to the first buffer and screen pointers
C 35977,1 Draw it on the screen
C 35978,1 Next byte of the first buffer
C 35979,1 Next screen column
C 35980,1 A=the screen column byte
C 35981,1 Reached the clip column (30)?
C 35982,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35984,1 Increment DE
C 35985,1 A=the byte at DE
C 35986,1 Decrement DE
C 35987,1 Store A at DE
C 35988,1 Switch to the car buffer pointer (HL')
C 35989,1 OR in the matching byte of the car buffer
C 35990,1 Next car buffer byte
C 35991,1 Switch back to the first buffer and screen pointers
C 35992,1 Draw it on the screen
C 35993,1 Next byte of the first buffer
C 35994,1 Next screen column
C 35995,1 A=the screen column byte
C 35996,1 Reached the clip column (30)?
C 35997,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 35999,1 Increment DE
C 36000,1 A=the byte at DE
C 36001,1 Decrement DE
C 36002,1 Store A at DE
C 36003,1 Switch to the car buffer pointer (HL')
C 36004,1 OR in the matching byte of the car buffer
C 36005,1 Next car buffer byte
C 36006,1 Switch back to the first buffer and screen pointers
C 36007,1 Draw it on the screen
C 36008,1 Next byte of the first buffer
C 36009,1 Next screen column
C 36010,1 A=the screen column byte
C 36011,1 Reached the clip column (30)?
C 36012,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 36014,1 Increment DE
C 36015,1 A=the byte at DE
C 36016,1 Decrement DE
C 36017,1 Store A at DE
C 36018,1 Switch to the car buffer pointer (HL')
C 36019,1 OR in the matching byte of the car buffer
C 36020,1 Next car buffer byte
C 36021,1 Switch back to the first buffer and screen pointers
C 36022,1 Draw it on the screen
C 36023,1 Next byte of the first buffer
C 36024,1 Next screen column
C 36025,1 A=the screen column byte
C 36026,1 Reached the clip column (30)?
C 36027,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 36029,1 Increment DE
C 36030,1 A=the byte at DE
C 36031,1 Decrement DE
C 36032,1 Store A at DE
C 36033,1 Switch to the car buffer pointer (HL')
C 36034,1 OR in the matching byte of the car buffer
C 36035,1 Next car buffer byte
C 36036,1 Switch back to the first buffer and screen pointers
C 36037,1 Draw it on the screen
C 36038,1 Next byte of the first buffer
C 36039,1 Next screen column
C 36040,1 A=the screen column byte
C 36041,1 Reached the clip column (30)?
C 36042,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 36044,1 Increment DE
C 36045,1 A=the byte at DE
C 36046,1 Decrement DE
C 36047,1 Store A at DE
C 36048,1 Switch to the car buffer pointer (HL')
C 36049,1 OR in the matching byte of the car buffer
C 36050,1 Next car buffer byte
C 36051,1 Switch back to the first buffer and screen pointers
C 36052,1 Draw it on the screen
C 36053,1 Next byte of the first buffer
C 36054,1 Next screen column
C 36055,1 A=the screen column byte
C 36056,1 Reached the clip column (30)?
C 36057,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 36059,1 Increment DE
C 36060,1 A=the byte at DE
C 36061,1 Decrement DE
C 36062,1 Store A at DE
C 36063,1 Switch to the car buffer pointer (HL')
C 36064,1 OR in the matching byte of the car buffer
C 36065,1 Next car buffer byte
C 36066,1 Switch back to the first buffer and screen pointers
C 36067,1 Draw it on the screen
C 36068,1 Next byte of the first buffer
C 36069,1 Next screen column
C 36070,1 A=the screen column byte
C 36071,1 Reached the clip column (30)?
C 36072,2 Yes: skip the rest of the row (the picture is clipped at column 30)
C 36074,1 Final byte of the row
C 36075,1 Store A at DE
C 36076,1 Switch to the car buffer pointer (HL')
C 36077,1 OR in the matching byte of the car buffer
C 36078,1 Next car buffer byte
C 36079,1 Switch back to the first buffer and screen pointers
C 36080,1 Draw it on the screen
C 36081,1 Increment DE
C 36082,1 Get the start of the row back
C 36083,1 Down one pixel row
C 36084,1 A=the high byte
C 36085,2 Crossed into the next character row?
C 36087,2 Yes: move down to the next character row
C 36089,1 One row less
C 36090,3 Draw the next row
C 36093,1 Return
C 36094,1 Skip a byte of the first buffer
C 36095,1 Switch to the car buffer pointer (HL')
C 36096,1 Skip a car buffer byte
C 36097,1 Switch back to the first buffer and screen pointers
C 36098,1 Skip a byte of the first buffer
C 36099,1 Switch to the car buffer pointer (HL')
C 36100,1 Skip a car buffer byte
C 36101,1 Switch back to the first buffer and screen pointers
C 36102,1 Skip a byte of the first buffer
C 36103,1 Switch to the car buffer pointer (HL')
C 36104,1 Skip a car buffer byte
C 36105,1 Switch back to the first buffer and screen pointers
C 36106,1 Skip a byte of the first buffer
C 36107,1 Switch to the car buffer pointer (HL')
C 36108,1 Skip a car buffer byte
C 36109,1 Switch back to the first buffer and screen pointers
C 36110,1 Skip a byte of the first buffer
C 36111,1 Switch to the car buffer pointer (HL')
C 36112,1 Skip a car buffer byte
C 36113,1 Switch back to the first buffer and screen pointers
C 36114,3 Carry on with the next row
C 36117,1 A=L
C 36118,2 Add one character row (32 bytes)
C 36120,1 L=the new low byte
C 36121,3 Carry: that was the last character row of its third, so H (already 8 higher) is right
C 36124,1 No carry: still in the same third, so A=the high byte
C 36125,2 Take back the 8 that the pixel row steps added
C 36127,1 H=the new high byte
C 36128,3 Carry on with the next row
C 36131,2 Clear the left-clip flag in H
C 36133,1 A=the screen address, low byte
C 36134,2 Isolate the column
C 36136,2 Reached column 3, the left edge of the street scene?
C 36138,3 Yes: start drawing
C 36141,1 No: skip this column (it is off the left of the scene)
C 36142,3 If L wrapped round, move down to the next third of the screen
C 36145,1 Skip a byte of the first buffer
C 36146,1 Switch to the car buffer pointer (HL')
C 36147,1 Skip a car buffer byte
C 36148,1 Switch back to the first buffer and screen pointers
C 36149,1 Decrement DE
C 36150,1 Switch register sets
C 36151,1 Decrement HL
C 36152,1 Switch register sets
C 36153,1 A=the screen address, low byte
C 36154,2 Isolate the column
C 36156,2 Reached column 3, the left edge of the street scene?
C 36158,3 Yes: start drawing
C 36161,1 No: skip this column (it is off the left of the scene)
C 36162,3 If L wrapped round, move down to the next third of the screen
C 36165,1 Skip a byte of the first buffer
C 36166,1 Switch to the car buffer pointer (HL')
C 36167,1 Skip a car buffer byte
C 36168,1 Switch back to the first buffer and screen pointers
C 36169,1 A=the screen address, low byte
C 36170,2 Isolate the column
C 36172,2 Reached column 3, the left edge of the street scene?
C 36174,3 Yes: start drawing
C 36177,1 No: skip this column (it is off the left of the scene)
C 36178,3 If L wrapped round, move down to the next third of the screen
C 36181,1 Skip a byte of the first buffer
C 36182,1 Switch to the car buffer pointer (HL')
C 36183,1 Skip a car buffer byte
C 36184,1 Switch back to the first buffer and screen pointers
C 36185,1 A=the screen address, low byte
C 36186,2 Isolate the column
C 36188,2 Reached column 3, the left edge of the street scene?
C 36190,3 Yes: start drawing
C 36193,1 No: skip this column (it is off the left of the scene)
C 36194,3 If L wrapped round, move down to the next third of the screen
C 36197,1 Skip a byte of the first buffer
C 36198,1 Switch to the car buffer pointer (HL')
C 36199,1 Skip a car buffer byte
C 36200,1 Switch back to the first buffer and screen pointers
C 36201,1 A=the screen address, low byte
C 36202,2 Isolate the column
C 36204,2 Reached column 3, the left edge of the street scene?
C 36206,3 Yes: start drawing
C 36209,1 No: skip this column (it is off the left of the scene)
C 36210,3 If L wrapped round, move down to the next third of the screen
C 36213,1 Skip a byte of the first buffer
C 36214,1 Switch to the car buffer pointer (HL')
C 36215,1 Skip a car buffer byte
C 36216,1 Switch back to the first buffer and screen pointers
C 36217,1 A=the screen address, low byte
C 36218,2 Isolate the column
C 36220,2 Reached column 3, the left edge of the street scene?
C 36222,3 Yes: start drawing
C 36225,1 No: skip this column (it is off the left of the scene)
C 36226,3 If L wrapped round, move down to the next third of the screen
C 36229,1 Skip a byte of the first buffer
C 36230,1 Switch to the car buffer pointer (HL')
C 36231,1 Skip a car buffer byte
C 36232,1 Switch back to the first buffer and screen pointers
C 36233,1 A=the screen address, low byte
C 36234,2 Isolate the column
C 36236,2 Reached column 3, the left edge of the street scene?
C 36238,3 Yes: start drawing
C 36241,1 No: skip this column (it is off the left of the scene)
C 36242,3 If L wrapped round, move down to the next third of the screen
C 36245,1 Skip a byte of the first buffer
C 36246,1 Switch to the car buffer pointer (HL')
C 36247,1 Skip a car buffer byte
C 36248,1 Switch back to the first buffer and screen pointers
C 36249,1 A=the screen address, low byte
C 36250,2 Isolate the column
C 36252,2 Reached column 3, the left edge of the street scene?
C 36254,3 Yes: start drawing
C 36257,1 No: skip this column (it is off the left of the scene)
C 36258,3 If L wrapped round, move down to the next third of the screen
C 36261,1 Skip a byte of the first buffer
C 36262,1 Switch to the car buffer pointer (HL')
C 36263,1 Skip a car buffer byte
C 36264,1 Switch back to the first buffer and screen pointers
C 36265,1 A=the screen address, low byte
C 36266,2 Isolate the column
C 36268,2 Reached column 3, the left edge of the street scene?
C 36270,3 Yes: start drawing
C 36273,1 No: skip this column (it is off the left of the scene)
C 36274,3 If L wrapped round, move down to the next third of the screen
C 36277,1 Skip a byte of the first buffer
C 36278,1 Switch to the car buffer pointer (HL')
C 36279,1 Skip a car buffer byte
C 36280,1 Switch back to the first buffer and screen pointers
C 36281,1 A=the screen address, low byte
C 36282,2 Isolate the column
C 36284,2 Reached column 3, the left edge of the street scene?
C 36286,3 Yes: start drawing
C 36289,1 No: skip this column (it is off the left of the scene)
C 36290,3 If L wrapped round, move down to the next third of the screen
C 36293,1 Skip a byte of the first buffer
C 36294,1 Switch to the car buffer pointer (HL')
C 36295,1 Skip a car buffer byte
C 36296,1 Switch back to the first buffer and screen pointers
C 36297,1 A=the screen address, low byte
C 36298,2 Isolate the column
C 36300,2 Reached column 3, the left edge of the street scene?
C 36302,3 Yes: start drawing
C 36305,1 No: skip this column (it is off the left of the scene)
C 36306,3 If L wrapped round, move down to the next third of the screen
C 36309,1 Skip a byte of the first buffer
C 36310,1 Switch to the car buffer pointer (HL')
C 36311,1 Skip a car buffer byte
C 36312,1 Switch back to the first buffer and screen pointers
C 36313,1 A=the screen address, low byte
C 36314,2 Isolate the column
C 36316,2 Reached column 3, the left edge of the street scene?
C 36318,3 Yes: start drawing
C 36321,1 No: skip this column (it is off the left of the scene)
C 36322,3 If L wrapped round, move down to the next third of the screen
C 36325,1 Skip a byte of the first buffer
C 36326,1 Switch to the car buffer pointer (HL')
C 36327,1 Skip a car buffer byte
C 36328,1 Switch back to the first buffer and screen pointers
C 36329,1 A=the screen address, low byte
C 36330,2 Isolate the column
C 36332,2 Reached column 3, the left edge of the street scene?
C 36334,3 Yes: start drawing
C 36337,1 No: skip this column (it is off the left of the scene)
C 36338,3 If L wrapped round, move down to the next third of the screen
C 36341,1 Skip a byte of the first buffer
C 36342,1 Switch to the car buffer pointer (HL')
C 36343,1 Skip a car buffer byte
C 36344,1 Switch back to the first buffer and screen pointers
C 36345,3 Carry on with the next row
w 36348 Bar-room animation: step table
D 36348 Used by #R34040.
W 36348,18,8*2,2
c 36366 Bar-room animation: step 1 (set up)
D 36366 Draws the Partridge Club picture at #R53793 and initialises the frame pointers and timers for the animated customers, waiters and hoods.
C 36366,1 A=0
C 36367,2 Black border
C 36369,1 A=0
C 36370,3 Figure 1 starts in its first state
C 36373,3 Figure 6 starts in its first state
C 36376,3 Figure 5 starts in its first state
C 36379,3 Figure 7 starts in its first state (bit 7 clear: it may move)
C 36382,2 A=128
C 36384,3 Figure 8 starts out of action (bit 7 set)
C 36387,2 A=1: every counter starts at 1, so each figure moves on the first tick
C 36389,3 Counter for the hoods' route
C 36392,3 Counter for figure 1
C 36395,3 Counter for figure 5
C 36398,3 Counter for figure 6
C 36401,3 Counter for figure 7
C 36404,3 Counter for figure 8
C 36407,3 Counter for figure 2
C 36410,3 Counter for figure 3
C 36413,3 Counter for figure 4
C 36416,3 HL=the first entry of the hoods' route table
C 36419,3 Store it as the route pointer
C 36422,2 A=1
C 36424,3 Counter for the hoods walking through the club
C 36427,3 HL=the first frame of the walking hoods
C 36430,3 Store it as the frame pointer
C 36433,3 HL=the first frame of figure 1
C 36436,3 Store it
C 36439,3 HL=the first frame of figure 5
C 36442,3 Store it
C 36445,3 HL=the first frame of figure 6
C 36448,3 Store it
C 36451,3 HL=the first frame of figure 7
C 36454,3 Store it
C 36457,3 HL=the first frame of figure 8
C 36460,3 Store it
C 36463,3 HL=the compressed picture of the Partridge Club
C 36466,3 Draw it
C 36469,4 DE=figure 8's frame pointer
C 36473,1 Skip the link to the next frame...
C 36474,1 ...to the sprite
C 36475,3 Draw figure 8 for the first time
C 36478,3 HL=500
C 36481,3 The first pause lasts 500 ticks
C 36484,1 A=0: the step is complete
C 36485,1 Return
c 36486 Bar-room animation: last step (end the animation)
C 36486,2 A=1
C 36488,3 Mark the animation as finished
C 36491,1 A=0
C 36492,1 Return (zero flag set: the step is complete)
b 36493 Bar-room animation: pause counter
D 36493 A 16-bit tick counter used by #R36495. It is set to 500 at #R36481 for the first pause (before the door opens) and to 400 at #R36582 for the final pause.
B 36493,2,2 Pause counter (word)
c 36495 Bar-room animation: count down the delay
C 36495,3 Animate all the figures
C 36498,3 HL=the pause counter
C 36501,1 One tick less
C 36502,3 Store it
C 36505,1 A=H
C 36506,1 Combine with L to test for zero
C 36507,1 Return (Z set when the pause is over)
c 36508 Bar-room animation: animate and wait for the door to open
C 36508,3 Animate all the figures
C 36511,3 Advance the hoods along their route
C 36514,1 Return until the route entry is finished
C 36515,3 HL=the next route (41200)
C 36518,3 Use it
C 36521,2 A=1
C 36523,3 Make the route routine fetch its first entry at once
C 36526,1 Return
c 36527 Bar-room animation: the hoods walk in
C 36527,3 Animate figure 1
C 36530,3 Advance the hoods along their route
C 36533,1 Return until the route entry is finished
C 36534,3 HL=the next route (#R41221)
C 36537,3 Use it
C 36540,2 A=1
C 36542,3 Fetch the first entry at once
C 36545,1 Return
c 36546 Bar-room animation: the hoods cross the room
C 36546,3 Animate figure 1
C 36549,3 Advance the hoods along their route
C 36552,2 Not finished: draw the walking hoods
C 36554,3 HL=the next route (#R41237)
C 36557,3 Use it
C 36560,2 A=1
C 36562,3 Fetch the first entry at once
C 36565,1 Return
c 36566 Bar-room animation: the hoods go out
C 36566,3 Animate figure 1
C 36569,3 Animate the hoods walking
c 36572 Bar-room animation: final pause
C 36572,3 Animate figure 1
C 36575,3 Advance the hoods along their route
C 36578,1 Return until the route is finished
C 36579,3 HL=400
C 36582,3 Pause for 400 ticks
C 36585,1 Return
c 36586 Bar-room animation: update all the animated figures
C 36586,3 Animate figure 1
C 36589,3 Animate figure 2
C 36592,3 Animate figure 3
C 36595,3 Animate figure 4
C 36598,3 Animate figure 5
C 36601,3 Animate figure 6
C 36604,3 Animate figure 7
C 36607,3 Animate figure 8 and return
c 36610 Get a random delay
D 36610 A=B+random(0..C).
R 36610 Input:B Minimum
R 36610 C Range
C 36610,1 A=the range
C 36611,3 A=a random number from 0 to C
C 36614,1 Add the minimum
C 36615,1 Return
b 36616 Bar-room animation: walking hoods counter
D 36616 Ticks left until the next frame of the hoods walking through the club (see #R36617). It starts at 1 so the first frame is drawn at once, and is then reloaded with the duration of each frame from the list at 39924.
B 36616,1,1 Ticks until the next frame
c 36617 Bar-room animation: animate the hoods walking through the club
C 36617,3 A=the counter
C 36620,1 One tick less
C 36621,3 Store it
C 36624,1 Not time for a new frame
C 36625,3 HL=the position in the walking hoods' list
C 36628,1 A=the number of ticks this frame lasts
C 36629,1 Test it
C 36630,1 Zero marks the end of the list: stop
C 36631,1 Next byte
C 36632,3 Store it as the new counter
C 36635,2 Is the delay 2?
C 36637,2 B=1
C 36639,1 Save the list position
C 36640,3 If so, wait a moment (a step sound)
C 36643,1 Restore the list position
C 36644,1 E=the low byte of the record address
C 36645,1 Next byte
C 36646,1 D=the high byte
C 36647,1 Next byte
C 36648,3 Store the new list position
C 36651,1 HL=the record: the screen address then the sprite
C 36652,1 E=the screen address, low byte
C 36653,1 Next byte
C 36654,1 D=high byte
C 36655,1 Next byte
C 36656,1 HL=the screen address, DE=the sprite
C 36657,3 Draw the three-cell-wide sprite
C 36660,2 Clear the zero flag: the step is not complete
C 36662,1 Return
b 36663 Bar-room animation: route counter
D 36663 Ticks left before #R36664 fetches the next entry from the hoods' route table. Setting it to 1 (#R36389, #R36523, #R36542 and #R36562) makes the routine fetch an entry at once.
B 36663,1,1 Ticks until the next route entry
c 36664 Bar-room animation: advance along the hoods' route table
C 36664,3 A=the counter
C 36667,1 One tick less
C 36668,3 Store it
C 36671,1 Not time for a new entry
C 36672,3 HL=the route pointer
C 36675,1 A=the number of ticks this entry lasts
C 36676,1 Test it
C 36677,1 Zero marks the end of the route
C 36678,1 Next byte
C 36679,3 Store it as the new counter
C 36682,1 E=the screen address, low byte
C 36683,1 Next byte
C 36684,1 D=high byte
C 36685,1 Next byte
C 36686,1 Save the screen address
C 36687,1 E=the sprite address, low byte
C 36688,1 Next byte
C 36689,1 D=high byte
C 36690,1 Next byte
C 36691,3 Store the new route pointer
C 36694,1 HL=the screen address
C 36695,3 Draw the two-cell-wide sprite
C 36698,2 Clear the zero flag: the route is not finished
C 36700,1 Return
b 36701 Bar-room animation: figure 1 counter and state
D 36701 Used by #R36703. The counter counts down to the next frame; when it expires the state flips between 0 and 1, which chooses a long wait (60-100 ticks) or a short one (10-30 ticks), and the next frame is drawn.
B 36701,1,1 Counter
B 36702,1,1 State (0 or 1)
c 36703 Bar-room animation: animate figure 1 (at 21584)
C 36703,3 A=figure 1's counter
C 36706,1 One tick less
C 36707,3 Store it
C 36710,1 Not time to change yet
C 36711,3 A=figure 1's state
C 36714,2 Flip it
C 36716,3 Store it
C 36719,3 BC=the long delay range (minimum 60, up to 40 more ticks)
C 36722,2 State 0: use the long delay
C 36724,3 BC=the short delay range (minimum 10, up to 20 more ticks)
C 36727,3 A=a random delay
C 36730,3 Set the counter
C 36733,3 HL=figure 1's frame pointer
C 36736,1 E=the next frame's address, low byte
C 36737,1 Next byte
C 36738,1 D=high byte
C 36739,1 Next byte
C 36740,4 Store the pointer to the next frame
C 36744,1 DE=the sprite
C 36745,3 HL=figure 1's screen address
C 36748,3 Draw the sprite
b 36751 Bar-room animation: figure 2 counter
D 36751 Ticks until figure 2 (at 16769) changes frame; used by #R36752. Starts at 1.
B 36751,1,1 Counter
c 36752 Bar-room animation: animate figure 2 (at 16769)
C 36752,3 A=figure 2's counter
C 36755,1 One tick less
C 36756,3 Store it
C 36759,1 Not time to change yet
C 36760,3 BC=the delay range (minimum 10, up to 4 more)
C 36763,3 A=a random delay
C 36766,3 Set the counter
C 36769,3 HL=figure 2's frame pointer
C 36772,1 E=the next frame's address, low byte
C 36773,1 Next byte
C 36774,1 D=high byte
C 36775,1 Next byte
C 36776,4 Store the pointer to the next frame
C 36780,1 DE=the sprite
C 36781,3 HL=figure 2's screen address
C 36784,3 Draw the sprite
b 36787 Bar-room animation: figure 3 counter
D 36787 Ticks until figure 3 (at 16803) changes frame; used by #R36788. Starts at 1.
B 36787,1,1 Counter
c 36788 Bar-room animation: animate figure 3 (at 16803)
C 36788,3 A=figure 3's counter
C 36791,1 One tick less
C 36792,3 Store it
C 36795,1 Not time to change yet
C 36796,3 BC=the delay range (minimum 14, up to 4 more)
C 36799,3 A=a random delay
C 36802,3 Set the counter
C 36805,3 HL=figure 3's frame pointer
C 36808,1 E=the next frame's address, low byte
C 36809,1 Next byte
C 36810,1 D=high byte
C 36811,1 Next byte
C 36812,4 Store the pointer to the next frame
C 36816,1 DE=the sprite
C 36817,3 HL=figure 3's screen address
C 36820,3 Draw the sprite
b 36823 Bar-room animation: figure 4 counter
D 36823 Ticks until figure 4 (at 17253) changes frame; used by #R36824. Starts at 1.
B 36823,1,1 Counter
c 36824 Bar-room animation: animate figure 4 (at 17253)
C 36824,3 A=figure 4's counter
C 36827,1 One tick less
C 36828,3 Store it
C 36831,1 Not time to change yet
C 36832,3 BC=the delay range (minimum 8, up to 4 more)
C 36835,3 A=a random delay
C 36838,3 Set the counter
C 36841,3 HL=figure 4's frame pointer
C 36844,1 E=the next frame's address, low byte
C 36845,1 Next byte
C 36846,1 D=high byte
C 36847,1 Next byte
C 36848,4 Store the pointer to the next frame
C 36852,1 DE=the sprite
C 36853,3 HL=figure 4's screen address
C 36856,3 Draw the sprite
b 36859 Bar-room animation: figure 5 counter and state
D 36859 Used by #R36861 for figure 5 (at 19576). The counter counts down to the next change; the state starts at 0 (the first state).
B 36859,1,1 Counter
B 36860,1,1 State
c 36861 Bar-room animation: animate figure 5 (at 19576)
C 36861,3 A=figure 5's counter
C 36864,1 One tick less
C 36865,3 Store it
C 36868,1 Not time to change yet
C 36869,3 A=figure 5's state
C 36872,2 Flip it
C 36874,3 Store it
C 36877,3 BC=the long delay range (minimum 100, up to 50 more)
C 36880,2 State 0: use the long delay
C 36882,3 BC=the short delay range (minimum 40, up to 30 more)
C 36885,3 A=a random delay
C 36888,3 Set the counter
C 36891,3 HL=figure 5's frame pointer
C 36894,1 E=the next frame's address, low byte
C 36895,1 Next byte
C 36896,1 D=high byte
C 36897,1 Next byte
C 36898,4 Store the pointer to the next frame
C 36902,1 DE=the sprite
C 36903,3 HL=figure 5's screen address
C 36906,3 Draw the three-cell-wide sprite
b 36909 Bar-room animation: figure 6 counter and state
D 36909 Used by #R36911 for figure 6 (at 19087). The counter counts down to the next change; the state starts at 0 (the first state).
B 36909,1,1 Counter
B 36910,1,1 State
c 36911 Bar-room animation: animate figure 6 (at 19087)
C 36911,3 A=figure 6's counter
C 36914,1 One tick less
C 36915,3 Store it
C 36918,1 Not time to change yet
C 36919,3 A=figure 6's state
C 36922,2 Flip it
C 36924,3 Store it
C 36927,3 BC=the long delay range (minimum 30, up to 20 more)
C 36930,2 State 0: use the long delay
C 36932,3 BC=the short delay range (minimum 20, up to 10 more)
C 36935,3 A=a random delay
C 36938,3 Set the counter
C 36941,3 HL=figure 6's frame pointer
C 36944,1 E=the next frame's address, low byte
C 36945,1 Next byte
C 36946,1 D=high byte
C 36947,1 Next byte
C 36948,4 Store the pointer to the next frame
C 36952,1 DE=the sprite
C 36953,3 HL=figure 6's screen address
C 36956,3 Draw the three-cell-wide sprite
b 36959 Bar-room animation: figure 7 counter and state
D 36959 Used by #R36961 for figure 7 (at 18633). The counter counts down to the next change; the state starts at 0 (bit 7 clear: the figure may move).
B 36959,1,1 Counter
B 36960,1,1 State
c 36961 Bar-room animation: animate figure 7 (at 18633)
C 36961,3 A=figure 7's state
C 36964,2 Is bit 7 set (figure 7 is out of action while figure 8 is active)?
C 36966,1 Yes: nothing to do
C 36967,3 A=figure 7's counter
C 36970,1 One tick less
C 36971,3 Store it
C 36974,1 Not time to change yet
C 36975,3 A=figure 7's state
C 36978,2 Flip bit 0
C 36980,3 Store it
C 36983,2 Bit 0 is set: keep this figure active
C 36985,2 Set bit 7: it hands over to figure 8
C 36987,3 Store it
C 36990,3 A=figure 8's state
C 36993,2 Clear bit 7: figure 8 becomes active
C 36995,3 Store it
C 36998,3 BC=the long delay range (minimum 80, up to 30 more)
C 37001,2 Zero: use the long delay
C 37003,3 BC=the short delay range (minimum 20, up to 20 more)
C 37006,3 A=a random delay
C 37009,3 Set the counter
C 37012,3 HL=figure 7's frame pointer
C 37015,1 E=the next frame's address, low byte
C 37016,1 Next byte
C 37017,1 D=high byte
C 37018,1 Next byte
C 37019,4 Store the pointer to the next frame
C 37023,1 DE=the sprite
C 37024,3 HL=figure 7's screen address
C 37027,3 Draw the three-cell-wide sprite
b 37030 Bar-room animation: figure 8 counter and state
D 37030 Used by #R37032 for figure 8. The counter counts down to the next change; the state starts at 128 (bit 7 set: the figure is out of action until the script brings it in).
B 37030,1,1 Counter
B 37031,1,1 State
c 37032 Bar-room animation: animate figure 8
C 37032,3 A=figure 8's state
C 37035,2 Is bit 7 set (figure 8 is out of action while figure 7 is active)?
C 37037,1 Yes: nothing to do
C 37038,3 A=figure 8's counter
C 37041,1 One tick less
C 37042,3 Store it
C 37045,1 Not time to change yet
C 37046,3 A=figure 8's state
C 37049,2 Flip bit 0
C 37051,3 Store it
C 37054,2 Bit 0 is set: keep this figure active
C 37056,2 Set bit 7: hand over to figure 7
C 37058,3 Store it
C 37061,3 A=figure 7's state
C 37064,2 Clear bit 7: figure 7 becomes active
C 37066,3 Store it
C 37069,3 BC=the long delay range (minimum 80, up to 30 more)
C 37072,2 Zero: use the long delay
C 37074,3 BC=the short delay range (minimum 20, up to 20 more)
C 37077,3 A=a random delay
C 37080,3 Set the counter
C 37083,3 HL=figure 8's frame pointer
C 37086,1 E=the next frame's address, low byte
C 37087,1 Next byte
C 37088,1 D=high byte
C 37089,1 Next byte
C 37090,4 Store the pointer to the next frame
C 37094,1 DE=the sprite
c 37095 Draw a 3-cell-wide sprite at 18536
C 37095,3 HL=figure 8's screen address
C 37098,3 Draw the three-cell-wide sprite
b 37101 Animation data and graphics
D 37101 Positions, frame lists and sprite graphics for the getaway car and bar-room animations.
B 37101,4896,8
c 41997 Delay for BC units, B times
C 41997,1 Save the repeat count
C 41998,3 Play the shootout sound effect
C 42001,4 BC=the delay length
C 42005,1 Count the delay down
C 42006,1 Test BC...
C 42007,1 ...for zero
C 42008,2 Loop until it is zero
C 42010,1 Restore the repeat count
C 42011,2 Repeat B times
C 42013,1 Return
c 42014 Short delay (length at 41995)
C 42014,1 Save BC
C 42015,4 BC=the short delay length
C 42019,1 Count down
C 42020,1 Test BC...
C 42021,1 ...for zero
C 42022,2 Loop until it is zero
C 42024,1 Restore BC
C 42025,1 Return
c 42026 Play the shootout sound effect
D 42026 Plays the bit pattern at #R42057 through the speaker.
C 42026,3 HL=the sound data
C 42029,3 DE=40: the number of bytes
C 42032,1 C=the next byte of the pattern
C 42033,2 B=8 bits
C 42035,2 A=0: the speaker and border low
C 42037,2 Rotate the next bit out
C 42039,2 Zero: leave the speaker low
C 42041,2 A=24: speaker on (bit 4) and MIC (bit 3)
C 42043,2 Output it
C 42045,3 Wait a short time
C 42048,2 Next bit
C 42050,1 Next byte
C 42051,1 One fewer left
C 42052,1 Test DE...
C 42053,1 ...for zero
C 42054,2 Loop until all are played
C 42056,1 Return
b 42057 Shootout: sound effect data
D 42057 Played by #R42026.
B 42057,55,8*6,7
c 42112 Shootout with the hit man from Detroit
D 42112 An arcade sequence. Mugsy (controlled with Q/Z up/down, I/P left/right and B/N/M to fire) must shoot the hit man in a restaurant before the hit man shoots him. Installs its own IM2 interrupt routine (#R48539), sets Mugsy's hit points to (A AND 7)+1 (42301; the hit man always has 4, at 42302), runs the game and restores IM1 on exit.
R 42112 Input:A Value from the handout: Mugsy gets (A AND 7)+1 hit points (8 if A is 255)
R 42112 Output:A Result: bit 0 set if Mugsy was killed; bits 2-3 set if bystanders were hit
@ 42112 label=SHOOTOUT
C 42112,1 Interrupts off while the IM2 handler is installed
C 42113,1 Save the strength value passed in A (it is needed again below)
C 42114,3 HL=address of the shootout's interrupt routine
C 42117,3 Patch it into the JP at 53457 that the IM2 vector table (#R53504) leads to
C 42120,2 A=209: the high byte of the vector table address, which is filled with 208
C 42122,2 Set the interrupt vector register: IM 2 interrupts now vector through #R53504
C 42124,2 Select interrupt mode 2
C 42126,2 A=0: black border, speaker off
C 42128,2 Set the border colour and speaker
C 42130,1 Get the strength value back
C 42131,2 Keep the low 3 bits (0-7)
C 42133,1 Add 1 to make 1-8
C 42134,3 Store it as Mugsy's hit points (the hit man's bullets take one off each time they hit him)
C 42137,3 Draw the restaurant and put the figures in place
C 42140,3 Main loop: let any figure whose timer says it is ready decide what to do next
C 42143,3 Deal with Mugsy's and the hit man's bullets landing
C 42146,3 Deal with anyone who has been hit
C 42149,3 A=the "shootout over" flag (set when Mugsy or the hit man has fallen over)
C 42152,1 Test it
C 42153,2 Keep going until it is set
C 42155,3 BC=65535: a pause of about a second and a half so the player can see the result
C 42158,1 Count BC down
C 42159,1 A=B
C 42160,1 Combine with C to test for zero
C 42161,2 Loop until BC is zero
C 42163,2 A=63: the high byte of the ROM's interrupt table address
C 42165,2 Put the interrupt vector register back as the ROM expects it
C 42167,2 Back to interrupt mode 1
C 42169,3 A=the result bits (bit 0 Mugsy killed, bit 1 hit man killed, bit 2 bystander 1 hit, bit 3 bystander 2 hit)
C 42172,1 Leave with interrupts disabled (the caller restores the ROM's FLAGS)
C 42173,1 Return to the VM's native-call routine
b 42174 Shootout: animation frame tables
D 42174 Four bytes per frame: a direction mask, the graphic height in pixel rows, and the address of the graphic. Mugsy, the hit man and the bystanders each use a table (#R42174, 42194, #R42206, #R42222 ...).
B 42174,64,8
w 42238 Shootout: figure handlers
D 42238 One handler per figure slot, called by #R42977.
W 42238,12,8,4
b 42250 Shootout: figure timers
D 42250 0 = counting down, 1 = ready for orders, 2 and 3 = waiting/parked. One byte per figure slot (the seventh is the furniture slot).
B 42250,7,7
w 42257 Shootout: countdown pointers
D 42257 The address of each figure slot's countdown record, used by the interrupt routine #R48539.
W 42257,14,8,6
b 42271 Shootout: figure countdowns
D 42271 Three bytes per figure slot: the number of interrupts left before the next frame is drawn, and the address of the figure's record plus 3 (where the drawing job begins).
B 42271,21,8*2,5
b 42292 Shootout: variables
D 42292 #TABLE(default,centre,:w) { =h Address | =h Meaning } { #R42292-42297 | Route script pointers for bystander 1, bystander 2 and the hit man } { 42298 | Upper limit on the screen for Mugsy and the hit man } { #R42300 | Set once the sprite graphics have been inverted } { 42301 | Mugsy's remaining hit points (from the handout) } { 42302 | The hit man's remaining hit points (4) } { 42303-42306 | Saved stack pointer and temporary } { 42307 | Frame buffer address } { 42309 | Frame table address } { 42311 | Number of figure slots in use } { 42312-42313 | Number of frames in the current animation and delay between frames } { 42314 | Left limit for the current figure } { 42315 | Direction code from the keyboard } { #R42316-42317 | Firing state of Mugsy and the hit man } { 42318-42321 | Steps left for the two bullets and bullet cancel flags } { 42322 | Set when a figure could not move } { 42323-42326 | Bystander 1, bystander 2, Mugsy and the hit man have gone down } { 42327-42328 | A bullet touches bystander 1 or bystander 2 } { 42329-42330 | Mugsy or the hit man has run out of hit points } { 42331-42332 | Mugsy's or the hit man's bullet has landed } { 42333 | Somebody has gone down in this pass of the main loop } { 42334 | The result: bit 0 Mugsy killed, bit 1 hit man killed, bits 2-3 bystanders hit } { 42335 | The shootout is over } TABLE#
B 42292,44,8*5,4
b 42336 Shootout: figure workspace
D 42336 A 39-byte copy of the figure being worked on, made by #R45693 and copied back by #R45702.
B 42336,39,8*4,7
b 42375 Shootout: figure records
D 42375 Six 39-byte records (bystander 1 at #R42375, bystander 2 at 42414, Mugsy at 42453, the hit man at 42492, Mugsy's bullet at 42531 and the hit man's bullet at 42570) and a seventh, shorter one at 42609 for the furniture. Byte 0 is the state (4 facing right, 64 left, other values diagonals), 1 and 2 are counters, 3-10 hold the registers for the drawing job (screen address, graphic address, routine address), 17-18 is the screen address and 29-30 the attribute address.
B 42375,264,8
c 42639 Shootout: set up the restaurant
C 42639,3 Clear the screen and draw the walls, door and window
C 42642,3 HL=start of the flag area (42303-42335)
C 42645,2 B=33 bytes to clear
C 42647,1 A=0
C 42648,1 Clear a flag
C 42649,1 Move on
C 42650,2 Loop for all 33 bytes
C 42652,3 HL=the figure timers (one byte per figure, from #R42250)
C 42655,2 B=7 timers
C 42657,2 Set a timer to 3: "idle" (1 means ready for orders, 0 means a countdown is running)
C 42659,1 Next timer
C 42660,2 Loop for all seven
C 42662,3 BC=405
C 42665,3 HL=24575, the top of a work area below the code
C 42668,3 DE=24574
C 42671,1 A=0
C 42672,1 Clear the first byte of the work area
C 42673,2 Clear 405 more, working backwards (24170-24575): the sprite frame buffers are cleaned out
C 42675,3 BC=60
C 42678,3 HL=24115
C 42681,3 DE=24114
C 42684,2 A=56: white paper, black ink
C 42686,1 Store the first attribute
C 42687,2 Fill 60 attribute bytes (24055-24115) with white paper
C 42689,3 A=has the walls graphic been inverted already? (#R42300)
C 42692,1 Test it
C 42693,2 Skip the inversion if it has
C 42695,2 A=1
C 42697,3 Mark the sprite data as inverted (it is stored inverted in the file and flipped once, on first use)
C 42700,3 HL=start of the sprite data (#R47082)
C 42703,3 BC=1326 bytes
C 42706,1 Fetch a byte of sprite data
C 42707,1 Invert it
C 42708,1 Store it back
C 42709,1 Next byte
C 42710,1 Count down
C 42711,1 A=C
C 42712,1 Combine with B
C 42713,2 Loop until all 1326 bytes are done
C 42715,2 A=7
C 42717,3 Seven figure slots to service while the furniture is drawn (the seventh draws furniture)
C 42720,2 A=1
C 42722,3 Make the furniture slot's timer expire at once
C 42725,3 HL=first furniture descriptor (#R45711)
C 42728,3 Load it into the furniture slot's record
C 42731,3 Wait for the interrupt routine to draw it
C 42734,3 HL=screen address of the next piece
C 42737,3 DE=its attribute address
C 42740,3 Request a redraw and wait
C 42743,3 HL=screen address
C 42746,3 DE=attribute address
C 42749,3 Request a redraw and wait
C 42752,3 HL=screen address
C 42755,3 DE=attribute address
C 42758,3 Request a redraw and wait
C 42761,2 A=1
C 42763,3 Re-arm the furniture slot's timer
C 42766,3 HL=second furniture descriptor (45721)
C 42769,3 Load it into the furniture slot's record
C 42772,3 Wait for the interrupt routine to draw it
C 42775,3 HL=screen address of a copy
C 42778,3 DE=its attribute address
C 42781,3 Redraw and wait
C 42784,3 HL=screen address
C 42787,3 DE=attribute address
C 42790,3 Redraw and wait
C 42793,3 HL=screen address
C 42796,3 DE=attribute address
C 42799,3 Redraw and wait
C 42802,3 HL=address of the third furniture graphic (#R48354)
C 42805,3 Patch it into the furniture slot's record
C 42808,3 HL=screen address
C 42811,3 DE=attribute address
C 42814,3 Redraw and wait
C 42817,3 HL=screen address
C 42820,3 DE=attribute address
C 42823,3 Redraw and wait
C 42826,3 HL=screen address
C 42829,3 DE=attribute address
C 42832,3 Redraw and wait
C 42835,3 HL=initial records of the six real figures (#R45731)
C 42838,3 DE=the first figure's record (#R42375)
C 42841,3 BC=234 bytes (6 records of 39)
C 42844,2 Copy the figure records into place
C 42846,2 A=6
C 42848,3 From now on only six slots are serviced (the furniture slot is retired)
C 42851,3 HL=23875: a sprite frame buffer
C 42854,3 Use it for the next figure drawn
C 42857,3 HL=42492: the hit man's record
C 42860,1 Save it
C 42861,3 Copy the record into the workspace
C 42864,3 Work out where to draw him
C 42867,3 Draw him
C 42870,1 DE=the record again
C 42871,3 Copy the workspace back into the record
C 42874,3 HL=42253: the timer for figure 3 (the hit man)
C 42877,2 Set it to 0: his countdown starts running
C 42879,2 A=1
C 42881,3 The hit man waits one tick before first acting
C 42884,1 Enable interrupts
C 42885,1 Let one interrupt happen
C 42886,1 Disable interrupts again
C 42887,3 HL=42527: the hit man's record, byte +35
C 42890,2 Set it to 1
C 42892,3 HL=42253 (the hit man's timer)
C 42895,2 Set it to 3: idle
C 42897,3 HL=42250: the timers again
C 42900,2 Set the first timer to 1: bystander 1 may act at once
C 42902,1 Next timer
C 42903,2 Set the second timer to 1: bystander 2 may act at once
C 42905,3 HL=bystander 1's route script (#R46645)
C 42908,3 Store it as that figure's script pointer
C 42911,3 HL=bystander 2's route script (#R46825)
C 42914,3 Store it
C 42917,3 HL=the hit man's route script (#R47058)
C 42920,3 Store it
C 42923,3 HL=16512: the top row of the playing area on the screen
C 42926,3 Store it as the upper limit for Mugsy and the hit man
C 42929,1 Enable interrupts: the shootout is live
C 42930,1 Return
c 42931 Shootout: wait for an interrupt
C 42931,3 HL=the furniture slot's timer
C 42934,2 Set it to 0 so that the interrupt routine runs its countdown
C 42936,1 Enable interrupts
C 42937,1 Wait for the next interrupt
C 42938,1 Disable interrupts
C 42939,1 Return
c 42940 Shootout: load a furniture descriptor into the furniture slot
D 42940 Copies the 10-byte descriptor at HL: 6 bytes (screen address and graphic data) and then 4 bytes (attribute address and colour) into the seventh figure record, which the interrupt routine draws.
C 42940,3 DE=where the furniture slot keeps its first six data bytes (#R42623)
C 42943,3 BC=6 bytes
C 42946,2 Copy the screen position and graphic data
C 42948,3 DE=where it keeps the attribute data (42635)
C 42951,3 BC=4 bytes
C 42954,2 Copy them
C 42956,1 Return
c 42957 Shootout: place a piece of furniture (HL=screen address, DE=attribute address)
C 42957,2 A=1
C 42959,3 Re-arm the furniture slot's timer
C 42962,3 Store the screen address
C 42965,4 Store the attribute address
C 42969,1 Return
c 42970 Shootout: draw a piece of furniture and wait for the interrupt
C 42970,3 Set the new position
C 42973,3 Let the interrupt routine draw it
C 42976,1 Return
c 42977 Shootout: main loop (the figure dispatcher)
D 42977 The shootout is a small cooperative scheduler. Each of the six figures (bystander 1, bystander 2, Mugsy, the hit man, Mugsy's bullet and the hit man's bullet) has a timer byte at 42250+n and a handler address in the table at #R42238. A timer of 0 means that the figure's countdown is running; the interrupt routine #R48539 ticks the countdown and, when it reaches zero, draws the figure's next frame and sets the timer to 1. A timer of 1 tells this routine that the figure is ready for new orders: it runs the handler, which reads the next byte of the figure's route script (or the keyboard, for Mugsy), moves it, and leaves the timer to be decremented back to 0. A timer of 3 parks a figure for good.
C 42977,1 A=0
C 42978,3 Clear the "somebody is down" flag for this pass of the loop
C 42981,3 A=number of figure slots in use (7 while the furniture is drawn, then 6)
C 42984,1 B=the slot count
C 42985,2 C=0: the slot number
C 42987,3 HL=the slot timers (#R42250...)
C 42990,2 A=1: a timer of 1 means the figure is ready for new orders
C 42992,1 Is this slot's timer 1?
C 42993,2 No: leave this figure alone for now
C 42995,1 Save the loop counter and slot number
C 42996,1 Save the timer pointer
C 42997,2 B=0
C 42999,2 C=slot number*2: the offset into the handler table
C 43001,3 HL=handler table (#R42238)
C 43004,1 Point at this slot's entry
C 43005,1 E=low byte of the handler address
C 43006,1 Next byte
C 43007,1 D=high byte
C 43008,1 HL=handler address
C 43009,1 Run the handler (it ends with JP #R43010)
C 43010,1 Restore the timer pointer
C 43011,1 Restore the loop counter and slot number
C 43012,1 Timer 1 becomes 0: the interrupt routine now counts this figure's next move down
C 43013,1 Next slot's timer
C 43014,1 Next slot number
C 43015,2 Loop for all slots
C 43017,1 Return
c 43018 Shootout: handler for bystander 1
D 43018 Route script bytes are direction codes (4 right, 64 left, 2 up-right, 128 up-left, 8 down-right, 32 down-left), 0 for "stand still for a tick", 80, 81 and 82 for standing for 25, 1 or 128 ticks, 255 to hand over to the next figure and 254 to leave the restaurant and end the shootout.
C 43018,3 Handler for slot 0 (bystander 1): A=has he already gone down or left?
C 43021,1 Test it
C 43022,2 No: carry on
C 43024,3 HL=his timer
C 43027,2 Park the timer at 3 so he is never serviced again
C 43029,3 Back to the dispatcher
C 43032,3 A=has a bullet hit him?
C 43035,1 Test it
C 43036,2 Yes: make him fall over
C 43038,3 HL=his script pointer
C 43041,1 A=the next script byte
C 43042,2 254: end of the script
C 43044,3 Handle that below
C 43047,2 255: hand over to the hit man
C 43049,2 Handle that below
C 43051,2 80: stand still for a long time
C 43053,2 Handle that below
C 43055,2 81: stand still for one tick
C 43057,2 Handle that below
C 43059,2 82: stand still for a very long time
C 43061,2 Handle that below
C 43063,2 0: a plain animation step
C 43065,2 Handle that with the moves
C 43067,2 Keep only the bits that are not 1 or 16
C 43069,2 A real direction code: make the move
C 43071,3 Anything else (1, 16 or 17) is ignored this time
C 43074,3 HL=the result byte (42334)
C 43077,2 Set bit 2: bystander 1 has been hit
C 43079,3 Remember that he is down (A is non-zero)
C 43082,2 A=30
C 43084,3 He lies there for 30 ticks before his countdown ends
C 43087,2 A=8: the falling animation length
C 43089,3 BC=48250: the falling-over graphic
C 43092,3 HL=his record (#R42375)
C 43095,3 Set up the falling animation
C 43098,1 Save the script pointer
C 43099,2 A=4
C 43101,3 Four animation frames in the cycle
C 43104,1 A=3
C 43105,3 The frame delay is 3
C 43108,1 A=2
C 43109,3 His countdown is 2 ticks
C 43112,3 HL=the walking frame table (#R42174)
C 43115,3 Use it
C 43118,3 HL=23575: the frame buffer for this figure
C 43121,3 Use it
C 43124,1 A=0
C 43125,3 Reset the left limit
C 43128,1 Get the script pointer back
C 43129,1 A=the direction code from the script
C 43130,1 Move the pointer on
C 43131,3 Store the new script pointer
C 43134,3 HL=his record
C 43137,3 Move him and redraw
C 43140,3 Back to the dispatcher
C 43143,1 80: swap pointer and frame table
C 43144,3 HL=standing frame table (#R42190)
C 43147,2 A=25: stand for 25 ticks
C 43149,3 Carry on
C 43152,1 81: swap pointer and frame table
C 43153,3 HL=walking frame table (#R42174)
C 43156,2 A=1: one tick
C 43158,3 Carry on
C 43161,1 82: swap pointer and frame table
C 43162,3 HL=walking frame table
C 43165,2 A=128: a long wait
C 43167,3 Carry on
C 43170,3 255: HL=his timer
C 43173,2 Park him at 3
C 43175,1 Move to the next timer
C 43176,1 And the next
C 43177,1 And the hit man's timer
C 43178,2 Make the hit man ready for orders
C 43180,3 Back to the dispatcher
C 43183,3 254: HL=his record
C 43186,1 Save it
C 43187,3 Copy it to the workspace
C 43190,3 Copy his coordinates
C 43193,3 HL=1000: off the screen
C 43196,3 Move him off the screen
C 43199,3 And his attribute address
C 43202,1 DE=the record
C 43203,3 Copy the workspace back
C 43206,2 A=1
C 43208,3 He is gone
C 43211,3 His countdown is 1
C 43214,3 Set the "shootout over" flag
C 43217,3 Back to the dispatcher
C 43220,1 Point past the script byte
C 43221,4 Store the new script pointer
C 43225,3 Set the countdown
C 43228,3 Set the frame table
C 43231,3 HL=frame buffer
C 43234,3 Use it
C 43237,3 HL=his record
C 43240,3 Redraw him
C 43243,3 Back to the dispatcher
c 43246 Shootout: handler for bystander 2
C 43246,3 Handler for slot 1 (bystander 2): has he gone down?
C 43249,1 Test it
C 43250,2 No: carry on
C 43252,3 HL=his timer
C 43255,2 Park it
C 43257,3 Back to the dispatcher
C 43260,3 Has a bullet hit him?
C 43263,1 Test it
C 43264,2 Yes: make him fall over
C 43266,3 HL=his script pointer
C 43269,1 A=the next script byte
C 43270,2 254: end of script
C 43272,3 Handle that below
C 43275,2 255: hand over
C 43277,2 Handle that below
C 43279,2 80: stand still for a long time
C 43281,2 Handle that below
C 43283,2 81: stand still for one tick
C 43285,2 Handle that below
C 43287,2 82: stand still for a while
C 43289,2 Handle that below
C 43291,2 0: plain step
C 43293,2 Handle that with the moves
C 43295,2 Keep only the bits that are not 1 or 16
C 43297,2 A real direction code: move
C 43299,3 Ignore 1, 16 and 17
C 43302,3 HL=the result byte
C 43305,2 Set bit 3: bystander 2 has been hit
C 43307,3 Remember he is down
C 43310,2 A=30
C 43312,3 His countdown is 30
C 43315,2 A=16: the falling animation length
C 43317,3 BC=48154: the falling-over graphic
C 43320,3 HL=his record (42414)
C 43323,3 Set up the falling animation
C 43326,1 Save the script pointer
C 43327,2 A=2
C 43329,3 Two animation frames in the cycle
C 43332,3 Frame delay 2
C 43335,1 A=3
C 43336,3 Countdown 3
C 43339,3 HL=his walking frame table (42194)
C 43342,3 Use it
C 43345,3 HL=frame buffer (23675)
C 43348,3 Use it
C 43351,1 A=0
C 43352,3 Reset the left limit
C 43355,1 Get the script pointer back
C 43356,1 A=the direction code
C 43357,1 Advance the pointer
C 43358,3 Store it
C 43361,3 HL=his record
C 43364,3 Move him and redraw
C 43367,3 Back to the dispatcher
C 43370,1 80: swap
C 43371,3 HL=standing frame table (42202)
C 43374,2 A=25
C 43376,3 Carry on
C 43379,1 81: swap
C 43380,3 HL=walking frame table (42194)
C 43383,2 A=1
C 43385,3 Carry on
C 43388,1 82: swap
C 43389,3 HL=walking frame table
C 43392,2 A=100: wait
C 43394,3 Carry on
C 43397,3 255: HL=his timer
C 43400,2 Park it
C 43402,1 Next timer
C 43403,2 Make slot 2 (Mugsy) ready
C 43405,3 Back to the dispatcher
C 43408,3 254: HL=his record
C 43411,1 Save it
C 43412,3 Copy to workspace
C 43415,3 Copy coordinates
C 43418,3 HL=1000: off screen
C 43421,3 Move him off the screen
C 43424,3 And his attributes
C 43427,1 DE=the record
C 43428,3 Copy back
C 43431,2 A=1
C 43433,3 He is gone
C 43436,3 Countdown 1
C 43439,3 Set the "shootout over" flag
C 43442,3 Back to the dispatcher
C 43445,1 Point past the script byte
C 43446,4 Store the pointer
C 43450,3 Set the countdown
C 43453,3 Set the frame table
C 43456,3 HL=frame buffer
C 43459,3 Use it
C 43462,3 HL=his record
C 43465,3 Redraw him
C 43468,3 Back to the dispatcher
c 43471 Shootout: handler for Mugsy
D 43471 Takes the direction code from #R46460, handles firing (state 0 idle, 1 and 2 raising the gun, 3 firing a bullet) and Mugsy's death.
C 43471,3 Handler for slot 2 (Mugsy): is he dead?
C 43474,1 Test it
C 43475,2 No: carry on
C 43477,3 HL=his timer
C 43480,2 Park it at 3
C 43482,3 A=the "somebody is down" flag
C 43485,1 Test it
C 43486,2 Already set: skip
C 43488,2 A=1
C 43490,3 Tell the other figures that a gunfight has ended
C 43493,4 IX=his record (42453)
C 43497,3 HL=18576: where he lies
C 43500,3 Put him there (low byte)
C 43503,3 And the high byte
C 43506,3 Back to the dispatcher
C 43509,3 Has the hit man's bullet used up his hit points?
C 43512,1 Test it
C 43513,2 Yes: he dies
C 43515,3 A=is Mugsy's gun being fired (his fire state)?
C 43518,1 Test it
C 43519,3 Yes: continue the firing sequence
C 43522,3 A=the direction code from the keyboard
C 43525,1 B=the code
C 43526,2 10 means fire
C 43528,2 Start firing
C 43530,2 0 means no key pressed
C 43532,2 Stand still
C 43534,2 Keep only the bits that are not 1 or 16
C 43536,2 A real direction: move
C 43538,3 Otherwise do nothing
C 43541,3 HL=the result byte
C 43544,2 Set bit 0: Mugsy has been killed
C 43546,3 Remember he is dead
C 43549,2 A=30
C 43551,3 His countdown is 30
C 43554,2 A=16: the falling animation length
C 43556,3 BC=48106: the falling-over graphic
C 43559,3 HL=his record (42453)
C 43562,3 Set up the falling animation
C 43565,2 A=2
C 43567,3 Mugsy's animation has two frames
C 43570,3 Countdown 2
C 43573,2 A=4
C 43575,3 Frame delay 4
C 43578,3 HL=Mugsy's walking frame table (#R42206)
C 43581,3 Use it
C 43584,3 DE=frame buffer (23775)
C 43587,4 Use it
C 43591,4 IX=his record
C 43595,3 Work out the limits of his movement
C 43598,3 HL=his record
C 43601,1 A=the direction code
C 43602,3 Move him
C 43605,3 Back to the dispatcher
C 43608,3 He is firing: HL=his fire state
C 43611,1 Raise it to 1
C 43612,1 And to 2
C 43613,3 HL=Mugsy's firing frame table (#R42214)
C 43616,3 Use it
C 43619,3 HL=frame buffer (23775)
C 43622,3 Use it
C 43625,2 A=5
C 43627,3 Countdown 5
C 43630,3 HL=his record
C 43633,3 Draw the gun being raised
C 43636,3 Back to the dispatcher
C 43639,2 Is the fire state 2?
C 43641,3 No: end of the firing sequence
C 43644,4 IX=Mugsy's record
C 43648,3 A=his state byte
C 43651,2 Which way is he facing (bits 5-7)?
C 43653,2 Facing left: use that branch
C 43655,3 A=his screen address, low byte
C 43658,2 Column
C 43660,2 Is he at column 28, the right wall?
C 43662,2 Yes: no room for a bullet
C 43664,2 Fire the bullet
C 43666,3 Facing left: A=screen address low byte
C 43669,2 Column
C 43671,1 B=column
C 43672,3 A=the left limit
C 43675,1 Same column?
C 43676,2 Yes: no room for a bullet
C 43678,4 IY=the bullet's record (42531)
C 43682,2 B=11: the bullet starts 11 pixel rows down
C 43684,3 Position the bullet next to the gun
C 43687,2 A=10
C 43689,3 The bullet flies for 10 steps
C 43692,3 HL=the bullet's timer
C 43695,2 Make the bullet ready to move
C 43697,3 HL=fire state
C 43700,1 Raise it to 3
C 43701,2 A=5
C 43703,3 Countdown 5
C 43706,3 Back to the dispatcher
c 43709 Shootout: place a bullet in front of its owner (B=rows down from the top of the figure)
C 43709,3 A=the owner's state byte
C 43712,3 Give the bullet the same facing
C 43715,3 L=the owner's screen address, low byte
C 43718,3 H=high byte
C 43721,1 Move down one pixel row...
C 43722,3 (using this subroutine)
C 43725,2 ...B times
C 43727,3 A=the bullet's state
C 43730,2 Which way?
C 43732,2 Left: handle that
C 43734,1 Facing right: move the bullet two cells right of the gun
C 43735,1 Another one
C 43736,2 A=4: right
C 43738,3 Set the bullet's direction
C 43741,2 Carry on
C 43743,1 Facing left: one cell to the left
C 43744,2 A=64: left
C 43746,3 Set the direction
C 43749,3 Set the bullet's screen address
C 43752,3 And high byte
C 43755,1 DE=screen address
C 43756,3 Convert to an attribute address
C 43759,3 Store it
C 43762,3 And high byte
C 43765,1 A=0
C 43766,3 Clear some counters
C 43769,3 And another
C 43772,3 And another
C 43775,3 And another
C 43778,1 Return
C 43779,3 HL=Mugsy's standing frame table (42218)
C 43782,3 Use it
C 43785,3 HL=frame buffer (23775)
C 43788,3 Use it
C 43791,2 A=6
C 43793,3 Countdown 6
C 43796,1 A=0
C 43797,3 Reset the fire state
C 43800,3 HL=his record
C 43803,3 Redraw him standing
C 43806,3 HL=42488
C 43809,2 Set the flag
C 43811,3 Back to the dispatcher
c 43814 Shootout: handler for the hit man
D 43814 Follows short move fragments (#R47034-47081). At the end of each fragment he compares his position with Mugsy's and picks a new one that moves him towards Mugsy, firing when they are on the same row.
C 43814,3 Handler for slot 3 (the hit man): has Mugsy's bullet used up his hit points?
C 43817,1 Test it
C 43818,2 No: carry on
C 43820,3 HL=his timer
C 43823,2 Park it at 3
C 43825,3 A=the "somebody is down" flag
C 43828,1 Test it
C 43829,2 Already set: skip
C 43831,2 A=1
C 43833,3 Set it
C 43836,3 Back to the dispatcher
C 43839,3 Has Mugsy's bullet used up the hit man's hit points?
C 43842,1 Test it
C 43843,2 Yes: he dies
C 43845,3 A=the hit man's fire state
C 43848,1 Test it
C 43849,3 Yes: continue the firing sequence
C 43852,3 HL=his script pointer
C 43855,1 A=the next script byte
C 43856,2 255: end of the fragment
C 43858,2 Choose a new one
C 43860,2 10: fire
C 43862,2 Fire
C 43864,2 0: standing step
C 43866,2 Do that
C 43868,2 Keep only the bits that are not 1 or 16
C 43870,2 A real direction: move
C 43872,3 Ignore the rest
C 43875,3 HL=the result byte
C 43878,2 Set bit 1: the hit man has been killed
C 43880,3 Remember he is dead
C 43883,2 A=30
C 43885,3 His countdown is 30
C 43888,2 A=16: the falling animation length
C 43890,3 BC=48202: the falling-over graphic
C 43893,3 HL=his record (42492)
C 43896,3 Set up the falling animation
C 43899,1 Save the script pointer
C 43900,2 A=2
C 43902,3 Two frames in the cycle
C 43905,3 Frame delay 2
C 43908,3 Countdown 2
C 43911,3 HL=the hit man's walking frame table (#R42222)
C 43914,3 Use it
C 43917,3 HL=frame buffer (23875)
C 43920,3 Use it
C 43923,1 Get the pointer back
C 43924,1 A=the direction code
C 43925,1 Advance the pointer
C 43926,3 Store it
C 43929,3 HL=his record
C 43932,3 Move him
C 43935,3 Back to the dispatcher
C 43938,1 Fire: skip the script byte
C 43939,3 Store the pointer
C 43942,3 HL=his fire state
C 43945,1 Raise it to 1
C 43946,1 And to 2
C 43947,3 HL=the hit man's firing frame table (#R42230)
C 43950,3 Use it
C 43953,3 HL=frame buffer (23875)
C 43956,3 Use it
C 43959,4 IX=his record
C 43963,2 A=8
C 43965,3 Countdown 8
C 43968,3 HL=his record
C 43971,3 Draw the gun being raised
C 43974,3 Back to the dispatcher
C 43977,1 End of the fragment: work out where Mugsy is
C 43978,1 B=0
C 43979,1 C=0: the direction bits
C 43980,4 IX=Mugsy's record
C 43984,4 IY=the hit man's record
C 43988,3 A=Mugsy's column (low byte)
C 43991,2 Keep the column bits
C 43993,1 L=Mugsy's column
C 43994,3 A=the hit man's address low byte
C 43997,2 Column bits
C 43999,1 H=the hit man's column
C 44000,3 A=Mugsy's address high byte
C 44003,2 Which third of the screen?
C 44005,1 E=Mugsy's third
C 44006,3 A=the hit man's address high byte
C 44009,2 Which third?
C 44011,1 D=the hit man's third
C 44012,1 A=the hit man's column
C 44013,1 Compare with Mugsy's
C 44014,2 Hit man is to the left
C 44016,2 Bit 2: hit man at or right of Mugsy
C 44018,3 Carry on
C 44021,2 Bit 3: hit man left of Mugsy
C 44023,1 A=the hit man's third
C 44024,1 Compare with Mugsy's
C 44025,2 Same third
C 44027,2 Hit man is higher
C 44029,2 Bit 0: hit man is lower
C 44031,3 Choose a fragment
C 44034,2 Bit 1: hit man is higher
C 44036,3 Choose a fragment
C 44039,3 Same third: A=Mugsy's row bits
C 44042,2 Row within the third
C 44044,1 L=it
C 44045,3 A=the hit man's row bits
C 44048,2 Row within the third
C 44050,1 Compare
C 44051,2 Hit man is higher
C 44053,2 Bit 0: hit man is lower
C 44055,3 Carry on
C 44058,2 Bit 1: hit man is higher
C 44060,1 Difference in rows
C 44061,2 Different rows: choose a fragment
C 44063,3 Same row: is Mugsy already dead?
C 44066,1 Test it
C 44067,2 Yes: just move
C 44069,2 Same row and Mugsy alive: clear bit 0
C 44071,2 And bit 1
C 44073,2 B=10: fire
C 44075,3 Is there furniture beside the hit man?
C 44078,2 No: carry on
C 44080,2 A=12
C 44082,1 Flip the horizontal bits: go the other way
C 44083,1 C=the new direction bits
C 44084,2 B=0: do not fire
C 44086,1 A=the direction bits
C 44087,2 Right (4)?
C 44089,2 No
C 44091,3 Fragment #R47042
C 44094,3 Use it
C 44097,2 Left (8)?
C 44099,2 No
C 44101,3 Fragment #R47034
C 44104,3 Use it
C 44107,2 Right and lower (5)?
C 44109,2 No
C 44111,3 Fragment #R47058
C 44114,2 Use it
C 44116,2 Left and higher (6)?
C 44118,2 No
C 44120,3 Fragment #R47074
C 44123,2 Use it
C 44125,2 Left and lower (9)?
C 44127,2 No
C 44129,3 Fragment #R47050
C 44132,2 Use it
C 44134,3 Otherwise fragment #R47066
C 44137,3 Store the new script pointer
C 44140,1 Skip two bytes
C 44141,1 Poke B (fire or not) into the fragment
C 44142,1 Next byte
C 44143,1 Poke it again
C 44144,1 Next byte of the fragment
C 44145,3 HL=his timer
C 44148,2 Wait two ticks
C 44150,3 Back to the dispatcher
c 44153 Shootout: check for furniture next to a figure
C 44153,1 Save BC
C 44154,3 E=the figure's attribute address, low byte
C 44157,3 D=high byte
C 44160,3 A=the figure's state byte
C 44163,2 Which way is he facing?
C 44165,2 Left: use the left offset
C 44167,3 Facing right: look 96 bytes ahead
C 44170,2 Carry on
C 44172,3 Facing left: look 95 bytes ahead
C 44175,1 HL=the attribute cell to inspect
C 44176,2 A=58: the attribute of a piece of furniture
C 44178,3 BC=4: look at four cells
C 44181,2 Compare A with a cell
C 44183,2 Found: stop
C 44185,3 Keep looking
C 44188,1 Restore BC
C 44189,1 Return (zero flag set if there is furniture)
C 44190,2 Is the hit man's fire state 2?
C 44192,2 No: finish the firing sequence below
C 44194,4 IX=the hit man's record
C 44198,3 A=his state byte
C 44201,2 Which way is he facing?
C 44203,2 Left: use that branch
C 44205,3 Facing right: A=screen address low byte
C 44208,2 Column
C 44210,2 At column 28, the right wall?
C 44212,2 Yes: no bullet
C 44214,2 Fire the bullet
C 44216,3 Facing left: A=screen address low byte
C 44219,2 Column
C 44221,1 B=column
C 44222,3 A=the left limit
C 44225,1 Same column?
C 44226,2 Yes: no bullet
C 44228,4 IY=the hit man's bullet record (42570)
C 44232,2 B=13: the bullet starts 13 pixel rows down
C 44234,3 Position the bullet next to the gun
C 44237,2 A=15
C 44239,3 The bullet flies for 15 steps
C 44242,3 HL=the bullet's timer
C 44245,2 Make the bullet ready to move
C 44247,3 HL=the hit man's fire state
C 44250,1 Raise it to 3
C 44251,2 A=4
C 44253,3 Countdown 4
C 44256,3 Back to the dispatcher
C 44259,3 HL=the hit man's standing frame table (42234)
C 44262,3 Use it
C 44265,3 HL=frame buffer (23875)
C 44268,3 Use it
C 44271,2 A=8
C 44273,3 Countdown 8
C 44276,1 A=0
C 44277,3 Reset the fire state
C 44280,3 HL=his record
C 44283,3 Redraw him standing
C 44286,3 HL=42527
C 44289,2 Set the flag
C 44291,3 Back to the dispatcher
c 44294 Shootout: handler for Mugsy's bullet
C 44294,3 Handler for slot 4 (Mugsy's bullet): was a bullet just cancelled?
C 44297,1 Test it
C 44298,2 No: carry on
C 44300,1 A=0
C 44301,3 Clear the flag
C 44304,3 HL=the bullet's timer
C 44307,2 Park it at 3
C 44309,3 Back to the dispatcher
C 44312,3 HL=the bullet's record (42531)
C 44315,1 Save it
C 44316,3 Copy it to the workspace
C 44319,3 HL=the bullet's remaining flight
C 44322,1 One step less
C 44323,3 Used up: remove it
C 44326,2 A=9
C 44328,1 Is this the first step?
C 44329,2 Yes: it has only just been drawn
C 44331,3 Copy its coordinates
C 44334,1 HL=screen address
C 44335,3 Move it a cell in its direction
C 44338,1 DE=new screen address
C 44339,3 Get the next route byte
C 44342,1 Test it
C 44343,2 Nothing in the way
C 44345,2 A=1
C 44347,3 The bullet has hit something: stop it next time
C 44350,3 Tell the hit tests that Mugsy's bullet has landed
C 44353,4 Store the new position
C 44357,3 Convert to an attribute address
C 44360,4 Store it
C 44364,1 DE=the record
C 44365,3 Copy the workspace back
C 44368,2 A=1
C 44370,3 Redraw the bullet at the next tick
C 44373,3 Back to the dispatcher
C 44376,3 Copy the coordinates
C 44379,3 HL=1000: off the screen
C 44382,3 Move the bullet off the screen
C 44385,3 And its attributes
C 44388,1 DE=the record
C 44389,3 Copy back
C 44392,2 A=1
C 44394,3 Redraw
C 44397,3 Flag the bullet as cancelled
C 44400,3 Back to the dispatcher
c 44403 Shootout: get the next byte of a figure's route
C 44403,3 A=the figure's state byte
C 44406,2 Which way is it moving?
C 44408,2 Left
C 44410,1 Moving right: A=the byte at DE
C 44411,1 Return
C 44412,1 Moving left: next byte
C 44413,1 A=the byte there
C 44414,1 Back to DE
C 44415,1 Return
c 44416 Shootout: handler for the hit man's bullet
C 44416,3 Handler for slot 5 (the hit man's bullet): was a bullet just cancelled?
C 44419,1 Test it
C 44420,2 No: carry on
C 44422,1 A=0
C 44423,3 Clear the flag
C 44426,3 HL=the bullet's timer
C 44429,2 Park it at 3
C 44431,3 Back to the dispatcher
C 44434,3 HL=the bullet's record (42570)
C 44437,1 Save it
C 44438,3 Copy it to the workspace
C 44441,3 HL=the bullet's remaining flight
C 44444,1 One step less
C 44445,3 Used up: remove it
C 44448,2 A=14
C 44450,1 Is this the first step?
C 44451,2 Yes
C 44453,3 Copy its coordinates
C 44456,1 HL=screen address
C 44457,3 Move it a cell
C 44460,1 DE=new address
C 44461,3 Get the next route byte
C 44464,1 Test it
C 44465,2 Nothing in the way
C 44467,2 A=1
C 44469,3 The bullet has hit something
C 44472,3 Tell the hit tests that the hit man's bullet has landed
C 44475,4 Store the new position
C 44479,3 Convert to an attribute address
C 44482,4 Store it
C 44486,1 DE=the record
C 44487,3 Copy back
C 44490,2 A=1
C 44492,3 Redraw at the next tick
C 44495,3 Back to the dispatcher
C 44498,3 Copy the coordinates
C 44501,3 HL=1000: off the screen
C 44504,3 Move the bullet off the screen
C 44507,3 And its attributes
C 44510,1 DE=the record
C 44511,3 Copy back
C 44514,2 A=1
C 44516,3 Redraw
C 44519,3 Flag the bullet as cancelled
C 44522,3 Back to the dispatcher
c 44525 Shootout: look for a bullet touching a figure
D 44525 Returns A=1 if any of the 4x3 attribute cells at the figure's attribute address has the bullet colour (57).
C 44525,3 L=the target's attribute address, low byte
C 44528,3 H=high byte
C 44531,3 DE=32: one row of attributes
C 44534,2 C=3: three rows to examine
C 44536,1 Save the row start
C 44537,2 B=4: four cells per row
C 44539,2 A=57: the attribute of a bullet
C 44541,1 Is this cell a bullet?
C 44542,2 Yes: it is in the target
C 44544,1 Next cell
C 44545,2 Loop for four cells
C 44547,1 Restore the row start
C 44548,1 Move down one row
C 44549,1 Count the rows
C 44550,2 Loop for three rows
C 44552,1 A=0: no bullet near the target
C 44553,1 Return
C 44554,2 A=1: a bullet is touching the target
C 44556,1 Tidy the stack
C 44557,1 Return
c 44558 Shootout: start a falling-over animation
C 44558,1 Save the record address
C 44559,1 Save the animation length
C 44560,1 Save the graphic address
C 44561,3 Copy the record to the workspace
C 44564,1 Get the graphic address back
C 44565,4 Store it as the figure's frame pointer
C 44569,3 Copy the coordinates
C 44572,1 Get the animation length
C 44573,3 Store it
C 44576,1 Divide by 8...
C 44577,1 ...by shifting right...
C 44578,1 ...three times
C 44579,3 Store the number of cells
C 44582,1 HL=the screen address
C 44583,2 B=20: drop the figure 20 pixel rows
C 44585,1 Down one row
C 44586,3 Fix up the address across character boundaries
C 44589,2 Repeat 20 times
C 44591,3 Store the new screen address
C 44594,1 DE=the screen address
C 44595,3 Compute the pixel shift
C 44598,3 Convert to an attribute address
C 44601,4 Store it
C 44605,1 DE=the record
C 44606,3 Copy the workspace back
C 44609,3 Back to the dispatcher
c 44612 Shootout: work out the left and upper limits for a figure
C 44612,3 A=the figure's screen address, high byte
C 44615,2 Is it in the top part of the screen?
C 44617,2 No: use the default limit
C 44619,3 A=the screen address, low byte
C 44622,1 C=it
C 44623,2 Column bits
C 44625,1 D=column
C 44626,1 A=the full byte
C 44627,2 Row bits
C 44629,1 C=row bits
C 44630,2 Row 4 (128)?
C 44632,2 No
C 44634,1 A=column
C 44635,2 Column 4?
C 44637,2 No: default
C 44639,2 A=4: left limit
C 44641,3 HL=16512
C 44644,2 Store it
C 44646,1 A=row bits
C 44647,2 Row 5 (160)?
C 44649,2 No
C 44651,1 A=column
C 44652,2 Column below 3?
C 44654,2 Yes: default
C 44656,2 A=3: left limit
C 44658,3 HL=16544
C 44661,2 Store it
C 44663,1 A=row bits
C 44664,2 Row 6 (192)?
C 44666,2 No
C 44668,1 A=column
C 44669,2 Column below 2?
C 44671,2 Yes: default
C 44673,2 A=2: left limit
C 44675,3 HL=16576
C 44678,2 Store it
C 44680,1 A=row bits
C 44681,2 Row 7 (224)?
C 44683,2 No
C 44685,1 A=column
C 44686,2 Low two bits of the column
C 44688,2 Zero: default
C 44690,2 A=1: left limit
C 44692,3 HL=16608
C 44695,2 Store it
C 44697,1 A=row bits
C 44698,2 Row 0?
C 44700,2 No: default
C 44702,1 A=column
C 44703,2 Column 0?
C 44705,2 No: default
C 44707,2 A=0: left limit
C 44709,3 HL=18432
C 44712,2 Store it
C 44714,2 A=0: no left limit
C 44716,3 HL=16512: the top of the playing area
C 44719,3 Store the upper limit
C 44722,3 Store the left limit
C 44725,1 Return
c 44726 Shootout: move and redraw the current figure
C 44726,1 Save the record address
C 44727,3 Copy it to the workspace
C 44730,3 Copy the coordinates
C 44733,3 HL=the frame table
C 44736,3 Store it in the workspace
C 44739,3 Update the figure's position and animation
C 44742,4 Store the new screen address
C 44746,3 A=the state byte
C 44749,2 Facing left?
C 44751,2 Yes: erase and redraw leftwards
C 44753,3 Draw facing right
C 44756,2 Done
C 44758,3 Draw facing left
C 44761,1 DE=the record
C 44762,3 Copy the workspace back
C 44765,1 Return
c 44766 Shootout: deal with Mugsy firing
C 44766,3 A=has Mugsy's bullet landed?
C 44769,1 Test it
C 44770,2 No: check the hit man's
C 44772,1 A=0
C 44773,3 Clear the flag
C 44776,4 IX=the hit man's record
C 44780,3 Is the bullet touching him?
C 44783,1 Test it
C 44784,2 No
C 44786,1 A=0
C 44787,3 HL=the hit man's hit points (42302)
C 44790,1 One hit
C 44791,2 Still alive
C 44793,2 Reset the counter (he has taken 4 hits)
C 44795,2 A=1: he is dead
C 44797,3 Record whether he is dead
C 44800,2 Carry on
C 44802,3 A=has the hit man's bullet landed?
C 44805,1 Test it
C 44806,2 No: finished
C 44808,1 A=0
C 44809,3 Clear the flag
C 44812,4 IX=Mugsy's record
C 44816,3 Is the bullet touching him?
C 44819,1 Test it
C 44820,2 No
C 44822,1 A=0
C 44823,3 HL=Mugsy's hit points (42301)
C 44826,1 One hit
C 44827,2 Still alive
C 44829,2 A=1: Mugsy is dead
C 44831,3 Record whether Mugsy is dead
C 44834,4 IX=bystander 1's record
C 44838,3 Is a bullet touching him?
C 44841,3 Record it
C 44844,4 IX=bystander 2's record
C 44848,3 Is a bullet touching him?
C 44851,3 Record it
C 44854,1 Test it
C 44855,2 No
C 44857,3 HL=bystander 2's timer
C 44860,1 A=his timer
C 44861,2 Is it 2?
C 44863,2 No
C 44865,2 Make him ready
C 44867,3 A=is bystander 1 hit?
C 44870,1 Test it
C 44871,2 No
C 44873,3 HL=his timer
C 44876,1 A=his timer
C 44877,2 Is it 2?
C 44879,2 No
C 44881,2 Make him ready
C 44883,1 Return
c 44884 Shootout: deal with a hit
C 44884,3 A=has bystander 1 gone down?
C 44887,1 Test it
C 44888,3 Yes: look at bystander 2
C 44891,3 A=the "somebody is down" flag
C 44894,1 Test it
C 44895,1 Return if not
C 44896,3 HL=his script pointer
C 44899,1 Skip a byte
C 44900,3 Store it
C 44903,3 HL=his timer
C 44906,2 Make him ready
C 44908,1 Return
C 44909,3 A=has bystander 2 gone down?
C 44912,1 Test it
C 44913,3 Yes: look at the main figures
C 44916,3 A=the "somebody is down" flag
C 44919,1 Test it
C 44920,1 Return if not
C 44921,3 HL=his script pointer
C 44924,1 Skip a byte
C 44925,3 Store it
C 44928,3 HL=his timer
C 44931,2 Make him ready
C 44933,1 Return
C 44934,3 A=has Mugsy been killed?
C 44937,1 Test it
C 44938,2 No
C 44940,3 Set the "shootout over" flag
C 44943,1 Return
C 44944,3 A=has the hit man been killed?
C 44947,1 Test it
C 44948,1 No: return
C 44949,3 Set the "shootout over" flag
C 44952,1 Return
c 44953 Shootout: move a figure
C 44953,1 Save the record address
C 44954,1 Save the direction code
C 44955,3 Copy the record to the workspace
C 44958,3 Copy the coordinates
C 44961,3 HL=the workspace
C 44964,1 Get the direction code back
C 44965,1 B=it
C 44966,1 Zero?
C 44967,2 Then keep the old direction
C 44969,1 Store the new one
C 44970,1 Next workspace byte (the animation delay)
C 44971,1 One tick less
C 44972,2 Not time to change frame
C 44974,3 A=the frame delay
C 44977,1 Reload it
C 44978,3 Move to the next frame of the animation
C 44981,1 Next workspace byte (the step counter)
C 44982,1 One tick less
C 44983,2 Not time to step
C 44985,3 A=the step delay
C 44988,1 Reload it
C 44989,3 Is there a gun flash to remove?
C 44992,2 Yes
C 44994,2 A=1
C 44996,3 Mark the figure as standing
C 44999,3 Carry on
C 45002,1 DE=screen address
C 45003,3 Step the figure
C 45006,1 Back
C 45007,3 Update the position
C 45010,4 Store the screen address
C 45014,3 Compute the pixel shift
C 45017,3 Convert to an attribute address
C 45020,4 Store it
C 45024,3 A=the state byte
C 45027,2 Facing left?
C 45029,2 Yes
C 45031,3 Draw it facing right
C 45034,2 Done
C 45036,3 Draw it facing left
C 45039,1 DE=the record
C 45040,3 Copy back
C 45043,1 Return
c 45044 Shootout: remove the gun flash
C 45044,1 Save DE
C 45045,3 Convert to an attribute address
C 45048,3 A=the state byte
C 45051,2 Facing left?
C 45053,2 Yes
C 45055,3 HL=96
C 45058,3 Carry on
C 45061,3 HL=95
C 45064,1 HL=the cell ahead
C 45065,2 A=58: furniture
C 45067,3 BC=4
C 45070,2 Look for it
C 45072,2 Found
C 45074,3 Keep looking
C 45077,1 Restore DE
C 45078,1 Return
c 45079 Shootout: update a figure's position
C 45079,1 Save DE
C 45080,3 HL=the frame table position
C 45083,3 A=the state byte
C 45086,1 B=it
C 45087,2 Facing left?
C 45089,2 Yes
C 45091,1 A=the old state byte
C 45092,2 Facing left?
C 45094,1 Store the new state
C 45095,2 It was facing left
C 45097,2 Carry on
C 45099,1 A=the old state
C 45100,2 Facing left?
C 45102,1 Store the new state
C 45103,2 Same direction
C 45105,1 Next byte
C 45106,1 A=the frame count
C 45107,1 Back to the first byte
C 45108,3 Move to the next frame
C 45111,1 Skip a byte
C 45112,1 And another
C 45113,1 E=graphic address, low byte
C 45114,1 Next byte
C 45115,1 D=high byte
C 45116,4 Store the graphic address
C 45120,1 Restore DE
C 45121,1 Return
c 45122 Shootout: move to the next figure slot
C 45122,1 Save HL
C 45123,3 A=frame counter
C 45126,3 HL=the frame table pointer
C 45129,1 One frame less
C 45130,2 None left: wrap round
C 45132,1 Next frame (4 bytes)
C 45133,1 ...
C 45134,1 ...
C 45135,1 ...
C 45136,3 Store the pointer
C 45139,2 Carry on
C 45141,3 HL=the start of the table
C 45144,3 Store the pointer
C 45147,3 A=the number of frames
C 45150,3 Store the counter
C 45153,1 Restore HL
C 45154,1 Return
c 45155 Shootout: copy the current figure's coordinates
C 45155,3 HL=the figure's attribute address
C 45158,3 Store it
C 45161,4 DE=the figure's screen address
C 45165,4 Store it
C 45169,3 A=the pixel shift
C 45172,3 Store it
C 45175,3 A=the pixel width
C 45178,3 Store it
C 45181,1 Return
c 45182 Shootout: compute a figure's pixel shift
C 45182,1 A=the high byte of the screen address
C 45183,2 Pixel row within a character (0-7)
C 45185,1 B=it
C 45186,2 A=8
C 45188,1 A=8 minus the row
C 45189,3 Store the pixel shift
C 45192,1 B=it
C 45193,3 A=the figure's height in pixels
C 45196,1 A=height minus the shift
C 45197,3 Store it
C 45200,1 Return
c 45201 Shootout: draw a figure (masked)
C 45201,2 B=0
C 45203,2 A=255
C 45205,1 Keep it in A'
C 45206,2 A=32: 32 rows to copy
C 45208,3 HL=the figure's graphic
C 45211,4 DE=the frame buffer
C 45215,1 Get the row counter
C 45216,2 C=2: two bytes per row
C 45218,2 Copy a row of two bytes
C 45220,3 Loop for each byte
C 45223,1 Add a blank byte
C 45224,1 Next byte in the buffer
C 45225,1 Save the counter
C 45226,1 One row less
C 45227,2 Loop for 32 rows
C 45229,3 HL=the frame buffer
C 45232,3 The buffer is the graphic now
C 45235,3 A=the number of cells
C 45238,1 E=it
C 45239,3 A=the width in bytes
C 45242,1 C=it
C 45243,3 A=the pixel shift
C 45246,1 B=it
C 45247,2 A=4
C 45249,1 4 minus the shift
C 45250,1 Double it
C 45251,2 Nothing to shift
C 45253,1 Set the carry flag
C 45254,1 D=the shift count
C 45255,1 B=the width
C 45256,1 Save the row start
C 45257,2 Shift a byte right
C 45259,1 Next byte
C 45260,2 Repeat for the whole row
C 45262,3 Remember the position reached
C 45265,1 Restore the row start
C 45266,1 One shift less
C 45267,2 Repeat
C 45269,3 HL=the position reached
C 45272,1 One row less
C 45273,2 Repeat
C 45275,1 Return
c 45276 Shootout: erase a figure
C 45276,2 B=0
C 45278,2 A=255
C 45280,1 Keep it in A'
C 45281,2 A=32: 32 rows to copy
C 45283,3 HL=the figure's graphic
C 45286,4 DE=the frame buffer
C 45290,1 Get the row counter
C 45291,1 Start with a blank byte
C 45292,1 Next byte
C 45293,2 C=2: two bytes per row
C 45295,2 Copy a row of two bytes
C 45297,3 Loop for each byte
C 45300,1 Save the counter
C 45301,1 One row less
C 45302,2 Loop for 32 rows
C 45304,3 HL=the frame buffer
C 45307,3 The buffer is the graphic now
C 45310,1 Back one byte
C 45311,1 HL=the end of the buffer
C 45312,3 A=the number of cells
C 45315,1 E=it
C 45316,3 A=the width in bytes
C 45319,1 C=it
C 45320,3 A=the pixel shift
C 45323,1 B=it
C 45324,2 A=4
C 45326,1 4 minus the shift
C 45327,1 Double it
C 45328,2 Nothing to shift
C 45330,1 Set the carry flag
C 45331,1 D=the shift count
C 45332,1 B=the width
C 45333,1 Save the row end
C 45334,2 Shift a byte left
C 45336,1 Previous byte
C 45337,2 Repeat for the whole row
C 45339,3 Remember the position reached
C 45342,1 Restore the row end
C 45343,1 One shift less
C 45344,2 Repeat
C 45346,3 HL=the position reached
C 45349,1 One row less
C 45350,2 Repeat
C 45352,1 Return
c 45353 Shootout: get the next animation frame
C 45353,1 Save the record address
C 45354,1 Skip the state and counters...
C 45355,1 ...to the frame table pointer
C 45356,1 E=the frame table address, low byte
C 45357,1 Next byte
C 45358,1 D=high byte
C 45359,1 HL=the frame table address
C 45360,1 C=the number of frames
C 45361,1 D=a byte of the frame table
C 45362,2 Shift the next bit out of D
C 45364,1 and into A (this reverses the bits)
C 45365,2 Shift the next bit out of D
C 45367,1 and into A (this reverses the bits)
C 45368,2 Shift the next bit out of D
C 45370,1 and into A (this reverses the bits)
C 45371,2 Shift the next bit out of D
C 45373,1 and into A (this reverses the bits)
C 45374,2 Shift the next bit out of D
C 45376,1 and into A (this reverses the bits)
C 45377,2 Shift the next bit out of D
C 45379,1 and into A (this reverses the bits)
C 45380,2 Shift the next bit out of D
C 45382,1 and into A (this reverses the bits)
C 45383,2 Shift the next bit out of D
C 45385,1 and into A (this reverses the bits)
C 45386,1 B=the reversed byte
C 45387,1 Next byte
C 45388,1 D=the next byte
C 45389,2 Shift the next bit out of D
C 45391,1 and into A (this reverses the bits)
C 45392,2 Shift the next bit out of D
C 45394,1 and into A (this reverses the bits)
C 45395,2 Shift the next bit out of D
C 45397,1 and into A (this reverses the bits)
C 45398,2 Shift the next bit out of D
C 45400,1 and into A (this reverses the bits)
C 45401,2 Shift the next bit out of D
C 45403,1 and into A (this reverses the bits)
C 45404,2 Shift the next bit out of D
C 45406,1 and into A (this reverses the bits)
C 45407,2 Shift the next bit out of D
C 45409,1 and into A (this reverses the bits)
C 45410,2 Shift the next bit out of D
C 45412,1 and into A (this reverses the bits)
C 45413,1 Store the second byte
C 45414,1 Back one byte
C 45415,1 Store the first
C 45416,1 Forward
C 45417,1 And on to the next pair
C 45418,1 One frame less
C 45419,2 Loop for every frame
C 45421,1 Restore the record address
C 45422,1 Return
c 45423 Shootout: step a figure in its current direction
C 45423,1 A=the figure's screen address, low byte
C 45424,2 Column bits
C 45426,1 E=the column
C 45427,1 A=the low byte again
C 45428,2 Row bits
C 45430,1 D=the row
C 45431,3 A=the direction code
C 45434,2 Right?
C 45436,2 No
c 45438 Shootout: move right one cell (unless at column 28)
C 45438,2 A=28: the right-hand column limit
C 45440,1 Is the figure there?
C 45441,2 No
C 45443,2 A=1
C 45445,3 Stop the figure
C 45448,3 Report that it could not move
C 45451,1 Return
C 45452,1 Move one column right
C 45453,1 Return
C 45454,2 Left?
C 45456,2 No
c 45458 Shootout: move left one cell (unless at the left limit)
C 45458,3 A=the left limit
C 45461,1 Is the figure there?
C 45462,2 No
C 45464,2 A=1
C 45466,3 Stop the figure
C 45469,3 Report that it could not move
C 45472,1 Return
C 45473,1 Move one column left
C 45474,1 Return
C 45475,2 Up?
C 45477,2 No
c 45479 Shootout: move up one pixel row (unless at the top limit)
C 45479,1 Save the address
C 45480,1 Save the row
C 45481,1 L=the row
C 45482,4 DE=the upper limit
C 45486,1 Clear the carry flag
C 45487,2 Compare with the limit
C 45489,1 Restore the row
C 45490,1 Restore the address
C 45491,2 Not at the limit
C 45493,1 At the top: no move
C 45494,1 Up a pixel row
C 45495,3 Fix up across character boundaries
C 45498,1 Up another
C 45499,3 Fix up
C 45502,1 Up another
C 45503,3 Fix up
C 45506,1 Up another
C 45507,3 Fix up
C 45510,1 Return
C 45511,2 Down?
C 45513,2 No
c 45515 Shootout: move down one pixel row (unless at the bottom limit)
C 45515,1 Save the address
C 45516,1 Save the row
C 45517,1 L=the row
C 45518,1 DE=the row
C 45519,3 HL=the lower limit (20576)
C 45522,1 Clear the carry flag
C 45523,2 Compare
C 45525,1 Restore the row
C 45526,1 Restore the address
C 45527,2 Not at the limit
C 45529,1 At the bottom: no move
C 45530,1 Down a pixel row
C 45531,3 Fix up across character boundaries
C 45534,1 Down another
C 45535,3 Fix up
C 45538,1 Down another
C 45539,3 Fix up
C 45542,1 Down another
C 45543,3 Fix up
C 45546,1 Return
C 45547,2 Up and left?
C 45549,2 No
C 45551,1 A=0
C 45552,3 Clear the "could not move" flag
C 45555,3 Move left
C 45558,3 A=the flag
C 45561,1 Test it
C 45562,1 Could not move: return
C 45563,3 Move up
C 45566,1 Return
C 45567,2 Up and right?
C 45569,2 No
C 45571,1 A=0
C 45572,3 Clear the flag
C 45575,3 Move right
C 45578,3 A=the flag
C 45581,1 Test it
C 45582,1 Could not move: return
C 45583,3 Move up
C 45586,1 Return
C 45587,2 Down and left?
C 45589,2 No
C 45591,1 A=0
C 45592,3 Clear the flag
C 45595,3 Move left
C 45598,3 A=the flag
C 45601,1 Test it
C 45602,1 Could not move: return
C 45603,3 Move down
C 45606,1 Return
C 45607,2 Down and right?
C 45609,1 No: return
C 45610,1 A=0
C 45611,3 Clear the flag
C 45614,3 Move right
C 45617,3 A=the flag
C 45620,1 Test it
C 45621,1 Could not move: return
C 45622,3 Move down
C 45625,1 Return
c 45626 Convert a display file address in DE into an attribute address
C 45626,1 A=the high byte of the display address
C 45627,2 Which third of the screen (0-2)?
C 45629,1 Divide by 8...
C 45630,1 ...to...
C 45631,1 ...get it into bits 0-1
C 45632,2 Add the base of the attribute file (88*256=22528)
C 45634,1 D=the high byte of the attribute address
C 45635,1 Return
c 45636 Move HL up one pixel row
C 45636,1 A=the high byte
C 45637,1 Invert it
C 45638,2 Pixel row within a character (inverted)
C 45640,1 Return if not at the top of a character
C 45641,1 A=the low byte
C 45642,2 Up one character row
C 45644,1 L=it
C 45645,1 Return if that did not cross a third
C 45646,1 A=the high byte
C 45647,2 Up one third
C 45649,1 H=it
C 45650,1 Return
c 45651 Move HL down one pixel row
C 45651,1 A=the high byte
C 45652,2 Pixel row within a character
C 45654,1 Return if still inside a character
C 45655,2 A=32
C 45657,1 Down one character row
C 45658,1 L=it
C 45659,1 Return if that did not cross a third
C 45660,1 A=the high byte
C 45661,2 Down one third
C 45663,1 H=it
C 45664,1 Return
c 45665 Shootout: clear the screen
C 45665,3 HL=the start of the display file
C 45668,3 DE=the next byte
C 45671,3 BC=6143
C 45674,1 A=0
C 45675,1 Clear the first byte
C 45676,2 Clear the rest of the pixels
C 45678,3 HL=the start of the attributes
C 45681,3 DE=the next byte
C 45684,3 BC=767
C 45687,2 A=56: white paper, black ink
C 45689,1 Set the first attribute
C 45690,2 Set the rest of the attributes
C 45692,1 Return
c 45693 Shootout: copy a figure's 39-byte record into the workspace at #R42336
C 45693,3 DE=the workspace (#R42336)
C 45696,3 BC=39 bytes
C 45699,2 Copy the record into the workspace
C 45701,1 Return
c 45702 Shootout: copy the workspace at #R42336 back into a figure's record
C 45702,3 HL=the workspace (#R42336)
C 45705,3 BC=39 bytes
C 45708,2 Copy it back into the record
C 45710,1 Return
b 45711 Shootout: furniture descriptors
D 45711 Two 10-byte descriptors loaded by #R42940.
B 45711,20,8*2,4
b 45731 Shootout: initial figure records
D 45731 Six 39-byte records copied to #R42375 by #R42639.
B 45731,234,8*29,2
c 45965 Shootout: XOR a sprite onto the screen
C 45965,1 Fetch a byte of the graphic (the graphic is read backwards, from DE)
C 45966,1 Combine it with the screen byte
C 45967,1 Draw it
C 45968,1 Back one byte in the graphic
C 45969,1 Next screen byte to the right
C 45970,1 Fetch the next graphic byte
C 45971,1 Combine it with the screen
C 45972,1 Draw it
C 45973,1 Back one byte in the graphic
C 45974,1 Back to the left-hand column
C 45975,1 Down a pixel row (within the character)
C 45976,2 Loop for B pixel rows
C 45978,1 A=C: pixel rows left to do
C 45979,1 Test it
C 45980,2 None left: finish the job
C 45982,2 Subtract eight rows (one character row)
C 45984,2 B=8: a full character
C 45986,1 C=the rows left
C 45987,2 At least eight were left
C 45989,2 Add the eight back
C 45991,1 B=what is left
C 45992,2 C=0: that is the last block
C 45994,2 A=32
C 45996,1 Move down one character row
C 45997,1 L=the new low byte
C 45998,2 Still in the same third: draw the next block
C 46000,1 Crossed into the next third: A=the high byte
C 46001,2 Down 8 in the high byte
C 46003,1 H=it
C 46004,3 Draw the next block
C 46007,1 Restore the attribute address
C 46008,1 Restore the screen address
C 46009,1 Restore the attribute count
C 46010,3 BC=32: one row of attributes
C 46013,1 Save the row counter
C 46014,1 A=an attribute byte (the attributes are read backwards too)
C 46015,1 Set it
C 46016,1 Back one byte
C 46017,1 Next cell
C 46018,1 A=the next attribute
C 46019,1 Set it
C 46020,1 Back one byte
C 46021,1 Get the row counter
C 46022,1 One row less
C 46023,3 All done: go on to the second half of the job
C 46026,1 Back to the first column
C 46027,1 Down one attribute row
C 46028,3 Next row
C 46031,1 Use the alternate registers for the mask pointers
C 46032,1 A=a mask byte
C 46033,1 Combine with the screen byte
C 46034,1 Invert it (this gives the screen bits to keep)
C 46035,1 B=the bits that will be changed
C 46036,1 Combine with the screen byte again
C 46037,1 Put the byte back with the mask bits set to 1
C 46038,1 Next mask byte
C 46039,1 Next screen byte
C 46040,1 A=the next mask byte
C 46041,1 Combine with the screen byte
C 46042,1 Invert it
C 46043,1 C=the bits that will be changed
C 46044,1 Combine with the screen byte
C 46045,1 Set the mask bits
C 46046,1 Next mask byte
C 46047,1 Save the old screen bits on the stack
C 46048,1 Back to the first column
C 46049,1 Down a pixel row
C 46050,1 Back to the main registers
C 46051,2 Loop for B pixel rows
C 46053,1 A=C: pixel rows left
C 46054,1 Test it
C 46055,2 None left: restore the attributes
C 46057,2 Subtract eight rows
C 46059,2 B=8
C 46061,1 C=the rows left
C 46062,2 At least eight were left
C 46064,2 Add the eight back
C 46066,1 B=what is left
C 46067,2 C=0
C 46069,1 Alternate registers again
C 46070,2 A=32
C 46072,1 Down one character row
C 46073,1 L=the new low byte
C 46074,2 Same third: continue
C 46076,1 A=the high byte
C 46077,2 Down one third
C 46079,1 H=it
C 46080,3 Continue
C 46083,4 Restore the stack pointer used by the background buffer
C 46087,1 HL=where the saved screen bytes begin
C 46088,1 DE=the attribute address
C 46089,1 BC=the attribute colour and count
C 46090,1 SP=the saved-background pointer
C 46091,1 Step past the last byte saved
C 46092,1 HL=the attribute address
C 46093,1 A=an attribute byte
C 46094,1 D=it
C 46095,2 Keep the paper, bright and flash bits and clear the ink
C 46097,1 Set the ink colour from B
C 46098,1 Store it
C 46099,1 Next cell
C 46100,1 A=the next attribute
C 46101,1 E=it
C 46102,2 Keep the paper, bright and flash bits and clear the ink
C 46104,1 Set the ink colour from B
C 46105,1 Store it
C 46106,1 Save the old attributes on the stack
C 46107,1 One row less
C 46108,3 All done: finish the job
C 46111,1 Back a column
C 46112,3 DE=32
C 46115,1 Down one row
C 46116,3 Next row
C 46119,1 Fetch a byte of the graphic
C 46120,1 Combine with the screen
C 46121,1 Draw it
C 46122,1 Back a byte
C 46123,1 Next column
C 46124,1 Fetch the next byte
C 46125,1 Combine with the screen
C 46126,1 Draw it
C 46127,1 Back a byte
C 46128,1 Next column
C 46129,1 Fetch the third byte
C 46130,1 Combine with the screen
C 46131,1 Draw it
C 46132,1 Back a byte
C 46133,1 Back to the first column
C 46134,1 (two columns)
C 46135,1 Down a pixel row
C 46136,2 Loop for B pixel rows
C 46138,1 A=C: pixel rows left
C 46139,1 Test it
C 46140,2 None left: restore the attributes
C 46142,2 Subtract eight rows
C 46144,2 B=8
C 46146,1 C=the rows left
C 46147,2 At least eight were left
C 46149,2 Add the eight back
C 46151,1 B=what is left
C 46152,2 C=0
C 46154,2 A=32
C 46156,1 Down one character row
C 46157,1 L=the new low byte
C 46158,2 Same third: continue
C 46160,1 A=the high byte
C 46161,2 Down one third
C 46163,1 H=it
C 46164,3 Continue
C 46167,1 Restore the attribute address
C 46168,1 Restore the screen address
C 46169,1 Restore the attribute count
C 46170,3 BC=32
C 46173,1 Save the row counter
C 46174,1 A=an attribute byte
C 46175,1 Set it
C 46176,1 Back one byte
C 46177,1 Next cell
C 46178,1 A=the next attribute
C 46179,1 Set it
C 46180,1 Back one byte
C 46181,1 Next cell
C 46182,1 A=the third attribute
C 46183,1 Set it
C 46184,1 Back one byte
C 46185,1 Get the row counter
C 46186,1 One row less
C 46187,3 All done: go on to the second half of the job
C 46190,1 Back a cell
C 46191,1 Back another
C 46192,1 Down one attribute row
C 46193,3 Next row
C 46196,1 Alternate registers
C 46197,1 A=a mask byte
C 46198,1 Combine with the screen
C 46199,1 Invert it
C 46200,1 B=the bits that will change
C 46201,1 Combine with the screen
C 46202,1 Draw it
C 46203,1 Next mask byte
C 46204,1 Next column
C 46205,1 A=the next mask byte
C 46206,1 Combine with the screen
C 46207,1 Invert it
C 46208,1 C=the bits that will change
C 46209,1 Combine with the screen
C 46210,1 Draw it
C 46211,1 Next mask byte
C 46212,1 Next column
C 46213,1 Save the old bits on the stack
C 46214,1 A=the third mask byte
C 46215,1 Combine with the screen
C 46216,1 Invert it
C 46217,1 B=the bits that will change
C 46218,1 Combine with the screen
C 46219,1 Draw it
C 46220,1 Next mask byte
C 46221,1 Save the old bits on the stack
C 46222,1 Move the stack pointer back a byte
C 46223,1 Back a column
C 46224,1 And another
C 46225,1 Down a pixel row
C 46226,1 Main registers again
C 46227,2 Loop for B pixel rows
C 46229,1 A=C: pixel rows left
C 46230,1 Test it
C 46231,2 None left: restore the attributes
C 46233,2 Subtract eight rows
C 46235,2 B=8
C 46237,1 C=the rows left
C 46238,2 At least eight were left
C 46240,2 Add the eight back
C 46242,1 B=what is left
C 46243,2 C=0
C 46245,1 Alternate registers
C 46246,2 A=32
C 46248,1 Down one character row
C 46249,1 L=the new low byte
C 46250,2 Same third: continue
C 46252,1 A=the high byte
C 46253,2 Down one third
C 46255,1 H=it
C 46256,3 Continue
C 46259,4 Restore the stack pointer used by the background buffer
C 46263,1 HL=where the saved screen bytes begin
C 46264,1 DE=the attribute address
C 46265,1 BC=the attribute colour and count
C 46266,1 SP=the saved-background pointer
C 46267,1 Step past the last byte saved
C 46268,1 HL=the attribute address
C 46269,1 A=an attribute byte
C 46270,1 D=it
C 46271,2 Keep the paper, bright and flash bits and clear the ink
C 46273,1 Set the ink colour from B
C 46274,1 Store it
C 46275,1 Next cell
C 46276,1 A=the next attribute
C 46277,1 E=it
C 46278,2 Keep the paper, bright and flash bits and clear the ink
C 46280,1 Set the ink colour from B
C 46281,1 Store it
C 46282,1 Next cell
C 46283,1 Save the old attributes on the stack
C 46284,1 A=the third attribute
C 46285,1 D=it
C 46286,2 Keep the paper, bright and flash bits and clear the ink
C 46288,1 Set the ink colour from B
C 46289,1 Store it
C 46290,1 Save the old attributes on the stack
C 46291,1 Move the stack pointer back a byte
C 46292,1 One row less
C 46293,3 All done: finish the job
C 46296,1 Back a column
C 46297,1 And another
C 46298,3 DE=32
C 46301,1 Down one row
C 46302,3 Next row
c 46305 Shootout: draw the walls of the restaurant
C 46305,3 Clear the screen to white paper
C 46308,2 A=95: the starting y coordinate
C 46310,2 C=0: the starting x coordinate
C 46312,2 D=255: y changes by -1 each step
C 46314,2 E=1: x changes by +1 each step
C 46316,2 B=41 points
C 46318,3 Plot a diagonal line (the left wall in perspective)
C 46321,2 B=27 bytes
C 46323,3 Draw a horizontal line (the back wall's base) along the row HL points at
C 46326,2 A=54: the starting y
C 46328,2 C=40: the starting x
C 46330,2 D=255: y changes by -1
C 46332,2 E=0: x does not change
C 46334,2 B=54 points
C 46336,3 Plot a vertical line (a wall edge)
C 46339,2 A=90: the starting y
C 46341,2 C=5: the starting x
C 46343,2 D=255: y -1
C 46345,2 E=0: x constant
C 46347,2 B=42 points
C 46349,3 Plot a vertical line
C 46352,2 A=80: the starting y
C 46354,2 C=15: the starting x
C 46356,2 D=255: y -1
C 46358,2 E=0: x constant
C 46360,2 B=42 points
C 46362,3 Plot a vertical line
C 46365,2 A=39: the starting y
C 46367,2 C=15: the starting x
C 46369,2 D=1: y +1
C 46371,2 E=255: x -1
C 46373,2 B=10 points
C 46375,3 Plot a short diagonal
C 46378,2 A=24: 24 pixel rows for the door
C 46380,3 DE=16435: the door's position on the screen
C 46383,1 Save it
C 46384,3 HL=the door graphic (48404)
C 46387,3 BC=5 bytes per row
C 46390,1 Save the row's address
C 46391,2 Copy a row of the door onto the screen
C 46393,1 Get the row's address back
C 46394,1 Next pixel row
C 46395,1 HL=the address
C 46396,1 Save the row counter
C 46397,3 Fix up the address across character boundaries
C 46400,1 Restore the row counter
C 46401,1 DE=the address
C 46402,1 One row less
C 46403,2 Loop for 24 rows
C 46405,1 DE=the door's screen address
C 46406,3 Convert it to an attribute address
C 46409,2 A=3: three attribute rows
C 46411,3 BC=5 cells per row
C 46414,1 Save the row's address
C 46415,2 Set the door's attributes
C 46417,1 Restore the address
C 46418,3 BC=32
C 46421,1 HL=the address
C 46422,1 Down one attribute row
C 46423,1 DE=the address
C 46424,1 One row less
C 46425,2 Loop for 3 rows
C 46427,1 Return
c 46428 Shootout: plot a pixel
C 46428,1 Save the counter
C 46429,1 Save the coordinates
C 46430,3 Get the display address for the point from the ROM (the PIXEL-ADD routine, skipping its range check)
C 46433,1 B=the bit position
C 46434,1 One more than the bit position
C 46435,2 A=%11111110
C 46437,1 Rotate it to line up with the pixel...
C 46438,2 ...for B steps
C 46440,1 Make it the single pixel mask
C 46441,1 Combine with the screen byte
C 46442,1 Plot the pixel
C 46443,1 Restore the coordinates
C 46444,1 Restore the counter
C 46445,1 Add the y step
C 46446,1 Save it
C 46447,1 A=x
C 46448,1 Add the x step
C 46449,1 C=the new x
C 46450,1 Restore y
C 46451,2 Plot B points
C 46453,1 Return
c 46454 Shootout: draw a horizontal line
C 46454,2 Set a screen byte to 255
C 46456,1 Next byte
C 46457,2 Loop for B bytes
C 46459,1 Return
c 46460 Shootout: read the controls
D 46460 Reads Q (up), Z (down), I (left), P (right) and B/N/M (fire) and converts them to a direction code. Opposite directions pressed together cancel out.
R 46460 Output:A Direction code
@ 46460 label=CONTROLS
C 46460,3 HL=Mugsy's record (the figure the keys move)
C 46463,2 C=0: the direction bits
C 46465,2 Read the half-row Y U I O P
C 46467,2 Read the keyboard
C 46469,1 B=the key states
C 46470,2 Is P pressed?
C 46472,2 No
C 46474,2 Set bit 2: right
C 46476,1 A=the key states
C 46477,2 Is I pressed?
C 46479,2 No
C 46481,2 Set bit 6: left
C 46483,2 Read the half-row CAPS Z X C V
C 46485,2 Read the keyboard
C 46487,2 Is Z pressed?
C 46489,2 No
C 46491,2 Set bit 4: down
C 46493,2 Read the half-row Q W E R T
C 46495,2 Read the keyboard
C 46497,2 Is Q pressed?
C 46499,2 No
C 46501,2 Set bit 0: up
C 46503,2 Read the half-row SPACE SYM M N B
C 46505,2 Read the keyboard
C 46507,1 B=the key states
C 46508,2 Is M pressed?
C 46510,2 No
C 46512,2 Set bit 7: fire
C 46514,1 A=the key states
C 46515,2 Is N pressed?
C 46517,2 No
C 46519,2 Set bit 7: fire
C 46521,1 A=the key states
C 46522,2 Is B pressed?
C 46524,2 No
C 46526,2 Set bit 7: fire
C 46528,1 A=the combined bits
C 46529,1 Test them
C 46530,2 No key pressed: no movement
C 46532,1 B=the bits
C 46533,2 Up and down together?
C 46535,2 Compare
C 46537,2 Yes: they cancel
C 46539,1 A=the bits
C 46540,2 Left and right together?
C 46542,2 Compare
C 46544,2 Yes: they cancel
C 46546,1 A=the bits
C 46547,2 Is fire pressed?
C 46549,2 A=10: the code for fire
C 46551,2 Yes: use it
C 46553,1 A=the bits
C 46554,2 Drop the fire bit
C 46556,1 B=the direction bits
C 46557,2 Right?
C 46559,2 Use the code
C 46561,2 Left?
C 46563,2 Use the code
C 46565,2 Up and right?
C 46567,2 A=2
C 46569,2 Use the code
C 46571,1 A=the bits
C 46572,2 Down and right?
C 46574,2 A=8
C 46576,2 Use the code
C 46578,1 A=the bits
C 46579,2 Up and left?
C 46581,2 A=128
C 46583,2 Use the code
C 46585,1 A=the bits
C 46586,2 Down and left?
C 46588,2 A=32
C 46590,2 Use the code
C 46592,1 A=the bits
C 46593,2 Up only?
C 46595,2 No: try down
C 46597,1 A=Mugsy's state byte
C 46598,1 D=it
C 46599,2 Is he facing right?
C 46601,2 No
C 46603,2 A=2: up and right
C 46605,2 Use the code
C 46607,1 A=his state
C 46608,2 Is he facing left?
C 46610,2 No
C 46612,2 A=128: up and left
C 46614,2 Use the code
C 46616,1 A=the bits
C 46617,2 Down only?
C 46619,2 No: no movement
C 46621,1 A=Mugsy's state byte
C 46622,2 Is he facing right?
C 46624,2 No
C 46626,2 A=8: down and right
C 46628,2 Use the code
C 46630,1 A=his state
C 46631,2 Is he facing left?
C 46633,2 No: no movement
C 46635,2 A=32: down and left
C 46637,2 Use the code
b 46639 Unused: a stray byte
D 46639 Nothing can reach this byte: the JR at #R46637 jumps over it and the JR Z at #R46633 lands just after it. It is 120, the instruction LD A,B, probably the remains of an earlier version of this routine.
B 46639,1,1 LD A,B: never executed
c 46640 Shootout: no movement
C 46640,1 A=Mugsy's current state (no new direction)
C 46641,3 Store the direction code for the main loop
C 46644,1 Return
b 46645 Shootout: bystander 1 route script
D 46645 One byte per step: a direction code, 0 to stand still, 80/81/82 for long pauses, 255 to wake the hit man and 254 to leave. See #R43018.
B 46645,180,8*22,4
b 46825 Shootout: bystander 2 route script
D 46825 Used by #R43246.
B 46825,209,8*26,1
b 47034 Shootout: the hit man's move fragments
D 47034 Six fragments of eight bytes: a direction code, two bytes that #R43977 sets to 10 when the hit man should fire, a pause and the end marker 255.
B 47034,48,8
b 47082 Shootout: graphics
D 47082 Sprites for Mugsy, the hit man, the bystanders, the furniture and the bullets. Inverted in place the first time the shootout runs (#R42700). Each figure frame is 16 pixels wide and 32 rows tall (two bytes per row). Left to right: the woman at the bar (four walking frames and one standing), the second bystander (three frames), Mugsy (two walking, two kneeling) and the hit man (two walking, two kneeling): #HTML[<img src="../images/sprites.png" alt="The shootout figures" />]
B 47082,1457,8*182,1
c 48539 Interrupt routine for the shootout: the sprite scheduler
D 48539 Runs fifty times a second. For each figure whose timer is 0 it counts down the figure's countdown; when that reaches zero it points SP at the figure's record and uses POP to load HL, DE, BC and IY from it, then jumps to IY: a sprite drawing routine (#R45965, #R46031, #R46119 or #R46196) that draws the figure with the registers already set up. The drawing routines pass control on through #R48601 and finish at #R48617, which restores the real stack and sets the timer to 1. The routine ends by reading the keyboard.
@ 48539 label=ISR2
C 48539,1 Save AF
C 48540,1 Save BC
C 48541,1 Save DE
C 48542,1 Save HL
C 48543,2 Save IX
C 48545,2 Save IY
C 48547,3 HL=the figure timers
C 48550,3 A=the number of figures in use
C 48553,1 B=the count
C 48554,2 C=0: the figure number
C 48556,1 A=this figure's timer
C 48557,1 Test it
C 48558,2 Not zero: the figure is idle or waiting for orders
C 48560,1 Save the counters
C 48561,1 Save the timer pointer
C 48562,3 HL=the table of countdown pointers (#R42257)
C 48565,2 B=0
C 48567,2 C=the figure number*2
C 48569,1 HL=its entry
C 48570,1 E=the countdown address, low byte
C 48571,1 Next byte
C 48572,1 D=high byte
C 48573,1 HL=the countdown address
C 48574,1 One tick less
C 48575,2 Reached zero: draw the figure
C 48577,1 Restore the timer pointer
C 48578,2 Set the timer to 255 so that the INC below leaves it at 0
C 48580,2 Next figure
C 48582,1 Next byte: the sprite job pointer
C 48583,1 E=the low byte
C 48584,1 Next byte
C 48585,1 D=the high byte
C 48586,1 HL=the sprite job (a block of register values)
C 48587,4 IX=0
C 48591,2 IX=the stack pointer
C 48593,1 SP=the sprite job
C 48594,1 HL=the first register pair from the job
C 48595,1 DE=the second pair
C 48596,1 BC=the third pair
C 48597,2 IY=the address of the drawing routine
C 48599,2 Run the drawing routine (it finishes with a jump to #R48601 or #R48617)
C 48601,1 Switch to the alternate registers
C 48602,1 HL'=the next value from the job
C 48603,1 DE'=the next value
C 48604,1 Back to the main registers
C 48605,1 BC=the next value
C 48606,1 HL=the next value
C 48607,2 IY=the next routine
C 48609,4 Remember the stack pointer
C 48613,1 SP=the job's saved-background area
C 48614,1 Step past the last byte
C 48615,2 Run the second routine (it finishes with a jump to #R48617)
C 48617,2 Restore the real stack pointer
C 48619,1 Restore the timer pointer
C 48620,1 Restore the counters
C 48621,1 Timer: 0 becomes 1 (the figure is ready for orders)
C 48622,1 Next timer
C 48623,1 Next figure
C 48624,2 Loop for all the figures
C 48626,3 Read the keyboard
C 48629,2 Restore IY
C 48631,2 Restore IX
C 48633,1 Restore HL
C 48634,1 Restore DE
C 48635,1 Restore BC
C 48636,1 Restore AF
C 48637,1 Enable interrupts
C 48638,1 Return from the interrupt
b 48639 Padding before the dictionary
D 48639 A single zero byte (a NOP) after the interrupt routine. It brings the dictionary to #R48640, which is 190 x 256, so that the dictionary starts on a page boundary; dictionary references are a page number plus an offset (see #R29928).
B 48639,1,1 Padding
b 48640 Dictionary
D 48640 The 225 words that Louey's messages are built from, 1006 bytes in all, in alphabetical order. A message refers to a word by a page number (0-4) and an offset (#R29928 adds them to #R48640), or, for the 32 commonest, by a single byte (the table at #R49710). The block starts with a letter index of 32 two-byte entries (64 bytes); the words follow.
D 48640 Each letter takes one byte: the low five bits are the letter (1 = a to 26 = z; 27 to 31 are the punctuation marks ' - ! ? and ") and the top bits are mostly ignored. Bit 7 marks the last letter of a word, but only from the third letter on, so no word is cut short at two letters. A short word is closed by a byte whose letter is 0. Each line below is one word, with its offset from #R48640 (the number a message uses; the page is the offset divided by 256).
D 48640 The game never reads the letter index: it finds words only through the references. It looks like a by-product of the tool that built the dictionary. 9 words are never referred to by any message: "fin", "fun", "lea", "liv", "min", "per", "pre", "some", "the".
B 48640,2,2 Index: unused
B 48642,2,2 Index: offset 64, the first word beginning with "a" ("a")
B 48644,2,2 Index: offset 140, the first word beginning with "b" ("bad")
B 48646,2,2 Index: offset 189, the first word beginning with "c" ("can")
B 48648,2,2 Index: offset 255, the first word beginning with "d" ("da")
B 48650,2,2 Index: offset 301, the first word beginning with "e" ("each")
B 48652,2,2 Index: offset 305, the first word beginning with "f" ("fin")
B 48654,2,2 Index: offset 340, the first word beginning with "g" ("g")
B 48656,2,2 Index: offset 412, the first word beginning with "h" ("had")
B 48658,2,2 Index: offset 480, the first word beginning with "i" ("i")
B 48660,2,2 Index: offset 495, the first word beginning with "j" ("jack")
B 48662,2,2 Index: offset 509, the first word beginning with "k" ("keep")
B 48664,2,2 Index: offset 521, the first word beginning with "l" ("las")
B 48666,2,2 Index: offset 556, the first word beginning with "m" ("made")
B 48668,2,2 Index: offset 623, the first word beginning with "n" ("need")
B 48670,2,2 Index: offset 652, the first word beginning with "o" ("of")
B 48672,2,2 Index: offset 705, the first word beginning with "p" ("pay")
B 48674,2,2 Index: offset 740, the first word beginning with "q" ("quentin")
B 48676,2,2 Index: offset 747, the first word beginning with "r" ("rackets")
B 48678,2,2 Index: offset 767, the first word beginning with "s" ("safe")
B 48680,2,2 Index: offset 890, the first word beginning with "t" ("ta")
B 48682,2,2 Index: offset 980, the first word beginning with "u" ("up")
B 48684,2,2 Index: offset 986, the first word beginning with "v" ("vegas")
B 48686,2,2 Index: offset 991, the first word beginning with "w" ("wanna")
B 48688,2,2 Index: no words begin with "x"
B 48690,2,2 Index: offset 1046, the first word beginning with "y" ("ya")
B 48692,2,2 Index: no words begin with "z"
B 48694,2,2 Index: unused
B 48696,2,2 Index: unused
B 48698,2,2 Index: unused
B 48700,2,2 Index: unused
B 48702,2,2 Index: unused
B 48704,3,3 64: "a" (also the single-byte token 106)
B 48707,3,3 67: "abe"
B 48710,5,5 70: "about"
B 48715,5,5 75: "again"
B 48720,4,4 80: "aint" (also the single-byte token 114)
B 48724,8,8 84: "alcatraz"
B 48732,3,3 92: "all"
B 48735,3,3 95: "an"
B 48738,3,3 98: "and" (also the single-byte token 108)
B 48741,7,7 101: "another"
B 48748,6,6 108: "answer"
B 48754,3,3 114: "any"
B 48757,6,6 117: "anyway"
B 48763,7,7 123: "anyways"
B 48770,3,3 130: "are"
B 48773,3,3 133: "as"
B 48776,4,4 136: "away"
B 48780,3,3 140: "bad"
B 48783,7,7 143: "bahamas"
B 48790,3,3 150: "be" (also the single-byte token 125)
B 48793,5,5 153: "benny"
B 48798,6,6 158: "better"
B 48804,4,4 164: "boss"
B 48808,3,3 168: "boy"
B 48811,4,4 171: "boys" (also the single-byte token 105)
B 48815,5,5 175: "bucks"
B 48820,3,3 180: "but"
B 48823,3,3 183: "buy"
B 48826,3,3 186: "by"
B 48829,3,3 189: "can"
B 48832,7,7 192: "chicago"
B 48839,4,4 199: "city"
B 48843,6,6 203: "client"
B 48849,7,7 209: "clients" (also the single-byte token 120)
B 48856,8,8 216: "contract"
B 48864,4,4 224: "cops" (also the single-byte token 127)
B 48868,4,4 228: "cost"
B 48872,5,5 232: "could"
B 48877,6,6 237: "cripes"
B 48883,9,9 243: "customers"
B 48892,3,3 252: "cut"
B 48895,3,3 255: "da" (also the single-byte token 99)
B 48898,3,3 258: "dat"
B 48901,7,7 261: "detroit"
B 48908,3,3 268: "did"
B 48911,3,3 271: "dig"
B 48914,3,3 274: "dis"
B 48917,10,10 277: "disneyland"
B 48927,3,3 287: "do" (also the single-byte token 124)
B 48930,4,4 290: "doin"
B 48934,3,3 294: "don"
B 48937,4,4 297: "dumb"
B 48941,4,4 301: "each"
B 48945,3,3 305: "fin" (not used by any message)
B 48948,7,7 308: "florida"
B 48955,3,3 315: "for" (also the single-byte token 107)
B 48958,6,6 318: "forget"
B 48964,9,9 324: "fractions"
B 48973,4,4 333: "from"
B 48977,3,3 337: "fun" (not used by any message)
B 48980,3,3 340: "g"
B 48983,3,3 343: "gee"
B 48986,4,4 346: "geez"
B 48990,3,3 350: "get"
B 48993,6,6 353: "gettin"
B 48999,5,5 359: "gimme"
B 49004,4,4 364: "give"
B 49008,4,4 368: "goes"
B 49012,4,4 372: "goin"
B 49016,5,5 376: "gonna" (also the single-byte token 115)
B 49021,4,4 381: "good"
B 49025,3,3 385: "got" (also the single-byte token 103)
B 49028,5,5 388: "gotta"
B 49033,5,5 393: "grand" (also the single-byte token 98)
B 49038,5,5 398: "great"
B 49043,5,5 403: "greek"
B 49048,4,4 408: "guys"
B 49052,3,3 412: "had"
B 49055,4,4 415: "hall"
B 49059,4,4 419: "hand"
B 49063,4,4 423: "hard"
B 49067,3,3 427: "has"
B 49070,4,4 430: "have"
B 49074,6,6 434: "hawaii"
B 49080,3,3 440: "he"
B 49083,5,5 443: "heard"
B 49088,4,4 448: "here"
B 49092,3,3 452: "hi"
B 49095,3,3 455: "hit"
B 49098,4,4 458: "hood"
B 49102,3,3 462: "how"
B 49105,7,7 465: "however"
B 49112,4,4 472: "hows"
B 49116,4,4 476: "hurt"
B 49120,3,3 480: "i"
B 49123,3,3 483: "if"
B 49126,3,3 486: "in" (also the single-byte token 101)
B 49129,3,3 489: "is" (also the single-byte token 111)
B 49132,3,3 492: "it" (also the single-byte token 110)
B 49135,4,4 495: "jack"
B 49139,6,6 499: "jumpin"
B 49145,4,4 505: "just"
B 49149,4,4 509: "keep"
B 49153,4,4 513: "kill"
B 49157,4,4 517: "know"
B 49161,3,3 521: "las"
B 49164,4,4 524: "last"
B 49168,3,3 528: "lea" (not used by any message)
B 49171,4,4 531: "left"
B 49175,3,3 535: "let"
B 49178,3,3 538: "liv" (not used by any message)
B 49181,5,5 541: "louey"
B 49186,5,5 546: "lousy"
B 49191,5,5 551: "lucky"
B 49196,4,4 556: "made"
B 49200,4,4 560: "make"
B 49204,3,3 564: "man"
B 49207,4,4 567: "many" (also the single-byte token 109)
B 49211,3,3 571: "me" (also the single-byte token 123)
B 49214,5,5 574: "means"
B 49219,3,3 579: "min" (not used by any message)
B 49222,7,7 582: "minuses"
B 49229,4,4 589: "miss"
B 49233,3,3 593: "mob" (also the single-byte token 126)
B 49236,4,4 596: "mobs"
B 49240,4,4 600: "much"
B 49244,5,5 604: "mugsy"
B 49249,6,6 609: "muscle"
B 49255,5,5 615: "musta"
B 49260,3,3 620: "my"
B 49263,4,4 623: "need"
B 49267,9,9 627: "negatives"
B 49276,4,4 636: "nick"
B 49280,3,3 640: "no"
B 49283,3,3 643: "now"
B 49286,6,6 646: "nuthin"
B 49292,3,3 652: "of" (also the single-byte token 104)
B 49295,3,3 655: "off"
B 49298,4,4 658: "okay"
B 49302,3,3 662: "on" (also the single-byte token 118)
B 49305,3,3 665: "one"
B 49308,4,4 668: "only" (also the single-byte token 116)
B 49312,3,3 672: "or"
B 49315,12,12 675: "organisation"
B 49327,5,5 687: "other"
B 49332,3,3 692: "our"
B 49335,3,3 695: "out"
B 49338,4,4 698: "outa"
B 49342,3,3 702: "owe"
B 49345,3,3 705: "pay"
B 49348,3,3 708: "per" (not used by any message)
B 49351,3,3 711: "pre" (not used by any message)
B 49354,7,7 714: "protect"
B 49361,10,10 721: "protection"
B 49371,3,3 731: "put"
B 49374,6,6 734: "puttin"
B 49380,7,7 740: "quentin"
B 49387,7,7 747: "rackets"
B 49394,4,4 754: "real"
B 49398,4,4 758: "ride"
B 49402,5,5 762: "rocco"
B 49407,4,4 767: "safe"
B 49411,3,3 771: "san"
B 49414,3,3 774: "say"
B 49417,5,5 777: "sayin"
B 49422,6,6 782: "scared"
B 49428,8,8 788: "scarface"
B 49436,7,7 796: "schmuck"
B 49443,4,4 803: "sell"
B 49447,8,8 807: "shootout"
B 49455,7,7 815: "siberia"
B 49462,4,4 822: "sing"
B 49466,3,3 826: "so" (also the single-byte token 121)
B 49469,4,4 829: "some"
B 49473,4,4 833: "some" (not used by any message)
B 49477,5,5 837: "sorry"
B 49482,7,7 842: "squeeze"
B 49489,5,5 849: "still"
B 49494,7,7 854: "stoopid"
B 49501,10,10 861: "stoopidity"
B 49511,4,4 871: "sure"
B 49515,6,6 875: "surviv"
B 49521,9,9 881: "syndicate"
B 49530,3,3 890: "ta" (also the single-byte token 122)
B 49533,5,5 893: "takin"
B 49538,4,4 898: "tell"
B 49542,5,5 902: "terri"
B 49547,4,4 907: "than"
B 49551,4,4 911: "that" (also the single-byte token 113)
B 49555,3,3 915: "the" (also the single-byte token 96)
B 49558,3,3 918: "the" (not used by any message)
B 49561,11,11 921: "theirselves"
B 49572,4,4 932: "them"
B 49576,5,5 936: "there"
B 49581,4,4 941: "they"
B 49585,5,5 945: "think"
B 49590,7,7 950: "thinkin"
B 49597,4,4 957: "this"
B 49601,8,8 961: "thousand"
B 49609,3,3 969: "to" (also the single-byte token 112)
B 49612,3,3 972: "too"
B 49615,5,5 975: "tough"
B 49620,3,3 980: "up"
B 49623,3,3 983: "us"
B 49626,5,5 986: "vegas"
B 49631,5,5 991: "wanna"
B 49636,4,4 996: "want"
B 49640,3,3 1000: "was"
B 49643,4,4 1003: "wash"
B 49647,5,5 1007: "watch"
B 49652,3,3 1012: "we" (also the single-byte token 102)
B 49655,4,4 1015: "well"
B 49659,4,4 1019: "what"
B 49663,4,4 1023: "will"
B 49667,3,3 1027: "wit"
B 49670,3,3 1030: "won"
B 49673,4,4 1033: "word"
B 49677,6,6 1037: "workin"
B 49683,3,3 1043: "wuz"
B 49686,3,3 1046: "ya" (also the single-byte token 100)
B 49689,4,4 1049: "yeah"
B 49693,4,4 1053: "year" (also the single-byte token 117)
B 49697,5,5 1057: "years"
B 49702,3,3 1062: "you" (also the single-byte token 97)
B 49705,5,5 1065: "your" (also the single-byte token 119)
b 49710 Common words
D 49710 The 32 words that the game uses most, each reachable through a single byte in a message (96-127) instead of the two bytes of an ordinary dictionary reference. #R29907 takes the byte minus 96 as an index into this table; each entry is two bytes, the offset of the word in the dictionary at #R48640 (which also gives the page), and the page number in the low four bits of the second byte (the routine adds 80 to it to make the word type 5, an ordinary word). The table is in order of use, commonest first, which is why the low token numbers are the busiest. The counts below are the number of times each token appears in the messages.
D 49710 The commonest are "the" (49), "you" (36), "grand" (22), "da" (19), "ya" (19).
B 49710,2,2 Token 96: "the" (dictionary offset 915), used 49 times
B 49712,2,2 Token 97: "you" (dictionary offset 1062), used 36 times
B 49714,2,2 Token 98: "grand" (dictionary offset 393), used 22 times
B 49716,2,2 Token 99: "da" (dictionary offset 255), used 19 times
B 49718,2,2 Token 100: "ya" (dictionary offset 1046), used 19 times
B 49720,2,2 Token 101: "in" (dictionary offset 486), used 17 times
B 49722,2,2 Token 102: "we" (dictionary offset 1012), used 17 times
B 49724,2,2 Token 103: "got" (dictionary offset 385), used 16 times
B 49726,2,2 Token 104: "of" (dictionary offset 652), used 14 times
B 49728,2,2 Token 105: "boys" (dictionary offset 171), used 14 times
B 49730,2,2 Token 106: "a" (dictionary offset 64), used 14 times
B 49732,2,2 Token 107: "for" (dictionary offset 315), used 14 times
B 49734,2,2 Token 108: "and" (dictionary offset 98), used 13 times
B 49736,2,2 Token 109: "many" (dictionary offset 567), used 13 times
B 49738,2,2 Token 110: "it" (dictionary offset 492), used 12 times
B 49740,2,2 Token 111: "is" (dictionary offset 489), used 12 times
B 49742,2,2 Token 112: "to" (dictionary offset 969), used 11 times
B 49744,2,2 Token 113: "that" (dictionary offset 911), used 10 times
B 49746,2,2 Token 114: "aint" (dictionary offset 80), used 10 times
B 49748,2,2 Token 115: "gonna" (dictionary offset 376), used 10 times
B 49750,2,2 Token 116: "only" (dictionary offset 668), used 10 times
B 49752,2,2 Token 117: "year" (dictionary offset 1053), used 9 times
B 49754,2,2 Token 118: "on" (dictionary offset 662), used 9 times
B 49756,2,2 Token 119: "your" (dictionary offset 1065), used 8 times
B 49758,2,2 Token 120: "clients" (dictionary offset 209), used 8 times
B 49760,2,2 Token 121: "so" (dictionary offset 826), used 8 times
B 49762,2,2 Token 122: "ta" (dictionary offset 890), used 8 times
B 49764,2,2 Token 123: "me" (dictionary offset 571), used 8 times
B 49766,2,2 Token 124: "do" (dictionary offset 287), used 8 times
B 49768,2,2 Token 125: "be" (dictionary offset 150), used 8 times
B 49770,2,2 Token 126: "mob" (dictionary offset 593), used 7 times
B 49772,2,2 Token 127: "cops" (dictionary offset 224), used 7 times
b 49774 Messages
D 49774 All of Louey's lines. Placeholders in parentheses are filled in from VM variables given after the SAY instruction; [a/b/c] marks a random choice.
B 49774,10,8,2 Message: "So long Mugsy."
B 49784,14,8,6 Message: "A year goes by ......"
B 49798,40,8 Message: "Hi Boss, it's Louey your sidekick here wit' da lowdown on da mob..."
B 49838,44,8*5,4 Message: "Last year (v0) guys got rubbed out by other mobs and (v1) hoods wuz recruited by the organisation."
B 49882,14,8,6 Message: "City Hall think you stink" (only reached through the random choice at 49917)
B 49896,21,8*2,5 Message: "Some of da boys is sayin' you're all washed up" (only reached through the random choice at 49917)
B 49917,10,8,2 Message: a random choice of the messages at 49882 or 49896 (25 or 46 characters)
B 49927,33,8*4,1 Message: "But some was undercover feds and (v0) got killed in the shootout."
B 49960,24,8 Message: "So da mob now contains (v0) (msg1) hoodlums."
B 49984,19,8*2,3 Message: "Me and the boys is gettin' out pronto."
B 50003,13,8,5 Message: "What a Schmuck you are, Mugsy!"
B 50016,21,8*2,5 Message: "We didn't run no rackets, Boss."
B 50037,43,8*5,3 Message: "We protected (v0) of your (v1) clients last year and squeezed them for an average of $(v2), so we made (v3) thousand bucks."
B 50080,41,8*5,1 Message: "but Rocco's mob got half of that when they jumped us last winter."
B 50121,52,8*6,4 Message: "(msg0), we kept our noses clean wit' da inmates of da precint house,"
B 50173,30,8*3,6 Message: "(msg0) the cops raided us and took (v1) grand from our safe, Boss."
B 50203,64,8 Message: "You've got exactly (v0) grand in the safe, Boss. Anyways, dat's less than da (v1) grand ya owe Nick the Greek, so he's takin' over."
B 50267,22,8*2,6 Message: "Nick the Greek has got the (v0) grand ya owed him."
B 50289,62,8*7,6 Message: "So ya aint got the dough ta buy rods and bullets so da boys can defend theirselves. Sorry, Boss,- you're goin' for a ride."
B 50351,8,8 Message: "You got (v0) thousand bucks."
B 50359,39,8*4,7 Message: "You're through, Boss, the hit man from Detroit is on his way in,"
B 50398,36,8*4,4 Message: "Geez, so much for the contract, you've eliminated their hit man."
B 50434,37,8*4,5 Message: "Tough luck Boss, me and the boys'll give ya a decent funeral."
B 50471,49,8*6,1 Message: "But its gonna cost ya (v0) grand to keep the cops quiet about all the people what got wasted in the shootout."
B 50520,35,8*4,3 Message: "Your cousin Abe has muscled in on your territory. You've had it."
B 50555,15,8,7 Message: "Well, ya lived for another year." (only reached through the random choice at 50670)
B 50570,17,8*2,1 Message: "Lucky you're still in charge." (only reached through the random choice at 50670)
B 50587,13,8,5 Message: "I gotta hand it to ya, Boss." (only reached through the random choice at 50670)
B 50600,19,8*2,3 Message: "I just don't know how ya do it, Boss." (only reached through the random choice at 50670)
B 50619,15,8,7 Message: "Ya sure are a survivor, Boss." (only reached through the random choice at 50670)
B 50634,17,8*2,1 Message: "Gee, You're still da boss, Boss." (only reached through the random choice at 50670)
B 50651,19,8*2,3 Message: "Cripes, you're still hangin' on." (only reached through the random choice at 50670)
B 50670,17,8*2,1 Message: a random choice of the messages at 50555 or 50570 or 50587 or 50600 or 50619 or 50634 or 50651 (32 or 29 or 28 or 37 or 29 or 32 or 32 characters)
B 50687,100,8*12,4 Message: "(msg0) some of da boys in the mob is sayin' you're past it and they're talkin about puttin' out a contract on you. If it goes any further, how many grand ( if any) will you pay to keep the good guys faithful?"
B 50787,19,8*2,3 Message: "Boss, the boys'll gun ya down."
B 50806,13,8,5 Message: "How many grand for the handout?."
B 50819,50,8*6,2 Message: "You'll kill us wit' kindness, Boss.....( you've only got (v0) grand). Tell me that again, Boss."
B 50869,19,8*2,3 Message: "Okay, Boss, my guys will help ya."
B 50888,67,8*8,3 Message: "It costs one grand to put the squeeze on each client, and the godfather made the rule that our gangsters each get one client to protect for theirselves."
B 50955,46,8*5,6 Message: "The word is that Rocco's gettin' uppity. They say he wants ta muscle in on your patch, Boss."
B 51001,47,8*5,7 Message: "Dis could be tough, but maybe we can buy off Rocco's mob. How many grand ( if any) can you pay?"
B 51048,55,8*6,7 Message: "Rocco aint usually regarded as a philanthropist, Boss. He don't give nuthin' away."
B 51103,10,8,2 Message: "How many thousand, Boss?"
B 51113,31,8*3,7 Message: "You must be off ya rocker, Boss, we've only got (v0) grand."
B 51144,19,8*2,3 Message: "Better try again - how many G's?"
B 51163,36,8*4,4 Message: "Geez, Boss, we're gonna need some ourselves. Ya wanna think again?"
B 51199,24,8 Message: "Okay, Boss, we'll see if it works."
B 51223,18,8*2,2 Message: "This year we can buy or sell clients for (v0) grand each."
B 51241,30,8*3,6 Message: "The boys is workin' real hard. Now, how many clients do we buy from the syndicate?"
B 51271,20,8*2,4 Message: "( The price is right!)"
B 51291,1,1 Message: ""
B 51292,20,8*2,4 Message: "How many do we buy from the syndicate this year, Boss?"
B 51312,5,5 Message: "How many do we buy from the syndicate this year, Boss? ( The price is right!)."
B 51317,23,8*2,7 Message: "Minuses won't wash here, Mugsy. How many do we buy?"
B 51340,31,8*3,7 Message: "Cripes, Boss, you gotta be outa ya mind, we aint made of money."
B 51371,11,8,3 Message: "How many do ya wanna sell?"
B 51382,5,5 Message: "How many do ya wanna sell? ( The price is right!)."
B 51387,74,8*9,2 Message: "Geez, Boss, we've only got (v0) customers. If the boys think you wanna make a fast buck and then skip, you could be takin' an unexpected ride!"
B 51461,22,8*2,6 Message: "Cut the minus garbage, Mugsy!"
B 51483,51,8*6,3 Message: "Jumpin' jellyfish, Boss,- how do ya expect us ta survive if ya sell all our clients to the syndicate?"
B 51534,20,8*2,4 Message: "As you know, Mugsy, that means we aint got nuthin' left."
B 51554,58,8*7,2 Message: "As you know, Boss, that leaves (v0) thousand bucks in the safe. How many grand are ya gonna give the boys for artillery and ammo?"
B 51612,32,8 Message: "You aint thinkin' straight, Boss. There's only (v0) grand left in the safe."
B 51644,40,8 Message: "Geez, there'll be nuthin' left. Tell me that again, Boss, I musta misheard you."
B 51684,15,8,7 Message: "Cut the negatives, sucker!"
B 51699,35,8*4,3 Message: "Gee, da boys is gonna be hoppin' mad, Boss- you sure got guts!"
B 51734,17,8*2,1 Message: "Ya gonna get da guys bumped off."
B 51751,19,8*2,3 Message: "Yeah, Boss, keep'em scared, eh!"
B 51770,39,8*4,7 Message: "Cripes, Boss, they could fight a war with the hardware that'll buy."
B 51809,49,8*6,1 Message: "We got so few clients left that squeezin' them aint gonna pay your moll's hooch bills."
B 51858,31,8*3,7 Message: "We got (v0) clients in need of protection, Boss. How many do we put the squeeze on this year?"
B 51889,30,8*3,6 Message: "Forget the negatives, Mugsy- just tell me how many customers to lean on this year."
B 51919,52,8*6,4 Message: "Boss, there's only (v0) clients, and da guys gotta make an honest livin'........ How many clients, Mugsy?"
B 51971,30,8*3,6 Message: "You sure don't dig da protection racket, - do ya, Boss?"
B 52001,11,8,3 Message: "But we've only got (v0) grand." (only reached through the random choice at 52074)
B 52012,32,8 Message: "Have ya lost ya marbles, Mugsy? We've only $(v0) thousand left." (only reached through the random choice at 52074)
B 52044,30,8*3,6 Message: "Cut the kiddin', Boss. You know there's only (v0) grand in the safe." (only reached through the random choice at 52074)
B 52074,9,8,1 Message: a random choice of the messages at 52001 or 52012 or 52044 (30 or 63 or 68 characters)
B 52083,31,8*3,7 Message: "What wuz dat, Boss? I could've swore you said (v0)."
B 52114,80,8 Message: "Great noos, Boss!...... I set up this deal wit' Nick the Greek. He's gonna lend you the other (v0) grand at only (v1) percent interest."
B 52194,23,8*2,7 Message: "Watch out, Boss, the boys aint gonna like workin' that hard."
B 52217,45,8*5,5 Message: "Outa you (v0) grand, how much are you putting aside for the annual kickback to the cops?"
B 52262,27,8*3,3 Message: "If dat means you want the cops to pay us, forget it. How much?"
B 52289,64,8 Message: "Boy are you scared of da cops! Well they're gonna get a dissy dis year'cos there aint no funds left. ( Ya stoopid wally )."
B 52353,101,8*12,5 Message: "Geez, Boss, you sure are scared of these cops. But you musta forgot you only have (v0) grand...... Anyway, I guess you want I should let da cops have the whole lot. ( Ya stoopid jerk )."
B 52454,21,8*2,5 Message: "Say, Boss, the word is you're doin' okay!" (only reached through the random choice at 52535)
B 52475,28,8*3,4 Message: "They're sayin' you're doin' a good job here, Boss." (only reached through the random choice at 52535)
B 52503,32,8 Message: "The Chicago mobs have heard of you now. They think you might be another Scarface." (only reached through the random choice at 52535)
B 52535,9,8,1 Message: a random choice of the messages at 52454 or 52475 or 52503 (41 or 50 or 81 characters)
B 52544,63,8*7,7 Message: "You aint doin' too good, Mugsy! The organisation is gettin' a bad reputation an some of da boys is thinkin' of gettin' out while they can."
B 52607,14,8,6 Message: "Okay, Mugsy, me an the (v0) boys,"
B 52621,5,5 Message: "The Bahamas" (only reached through the random choice at 52631)
B 52626,5,5 Message: "Las Vegas" (only reached through the random choice at 52631)
B 52631,62,8*7,6 Message: "has had enough of your crazy mob for the last (v0) years. So we're off ta find some better rackets in [The Bahamas/Florida/Disneyland/Hawaii/Las Vegas]."
B 52693,7,7 Message: "Sing - Sing" (only reached through the random choice at 52705)
B 52700,5,5 Message: "San Quentin" (only reached through the random choice at 52705)
B 52705,65,8*8,1 Message: "has done pretty good in the mob for the last (v0) years. So we're goin' ta invest in some new rackets in [Alcatraz/Sing - Sing/San Quentin/Siberia]."
B 52770,37,8*4,5 Message: "You were (msg0). You scored (v1)%. Hows about another game, Mugsy?"
B 52807,18,8*2,2 Message: "What wuz dat, Boss? I missed it" (only reached through the random choice at 52861)
B 52825,36,8*4,4 Message: "It's okay, Boss - this line aint tapped. Let's have the answer" (only reached through the random choice at 52861)
B 52861,7,7 Message: a random choice of the messages at 52807 or 52825 (31 or 62 characters)
B 52868,28,8*3,4 Message: "Geez, Boss, fractions makes my head hurt. Gimme a good answer." (only reached through the random choice at 52957)
B 52896,61,8*7,5 Message: "Cripes, Boss, don't make wit' da fractions. I never did learn to dig them. Let's have it in good numbers!" (only reached through the random choice at 52957)
B 52957,7,7 Message: a random choice of the messages at 52868 or 52896 (62 or 105 characters)
B 52964,44,8*5,4 Message: "Don't get smart wit' me, Mugsy! Just " yeah" or " nope" is fine."
B 53008,89,8*11,1 Message: "Dat was real stoopid, Boss! If your boys heard about it you wud get more laughs than Jack Benny. However, for one crummy grand I guarantee ta keep my trap shut." (only reached through the random choice at 53164)
B 53097,67,8*8,3 Message: "Cripes, Boss, sometimes you're real dumb. But for a lousy grand I can be persuaded not to spill da beans about your stoopidity." (only reached through the random choice at 53164)
B 53164,7,7 Message: a random choice of the messages at 53008 or 53097 (160 or 127 characters)
B 53171,52,8*6,4 Message: "Your stoopidity takes my breath away, Mugsy. But for a mere (v0) grand I won't tell nobody." (only reached through the random choice at 53256)
B 53223,33,8*4,1 Message: "Mugsy! You're so dumb. It's gonna cost you (v0) G's ta make me forget it." (only reached through the random choice at 53256)
B 53256,7,7 Message: a random choice of the messages at 53171 or 53223 (91 or 73 characters)
B 53263,21,8*2,5 Message: "Gee ta, Boss! Now tell me........."
B 53284,2,2 Message: "scared"
B 53286,7,7 Message: "loyal"
B 53293,2,2 Message: "and"
B 53295,2,2 Message: "but"
B 53297,2,2 Message: "now"
B 53299,2,2 Message: "again"
B 53301,2,2 Message: "lousy"
B 53303,4,4 Message: "real bad"
B 53307,6,6 Message: "terrible"
B 53313,9,8,1 Message: "ghastly"
B 53322,6,6 Message: "poor"
B 53328,4,4 Message: "so- so"
B 53332,6,6 Message: "fair"
B 53338,2,2 Message: "good"
B 53340,2,2 Message: "okay"
B 53342,2,2 Message: "great"
B 53344,7,7 Message: "swell"
B 53351,2,2 Message: "terrificld(hl),3  +ld(regenfl)... (runs on: see #LINK(Bugs#terrific)(the bugs page))"
t 53353 Leftover assembler source
D 53353 Fragments of the original Z80 source code, left in memory by the assembler. See the #LINK(Facts#source)(trivia page).
B 53353,32,32 "FIC.LD.(HL),3  +..LD.(REGENFL),A"
B 53385,32,32 " *+..JP.COMEBK 4+.; >+.HITOK.EQU"
B 53417,32,32 ".$ H+..LD.A,(HITST) R+..AND.A \+"
B 53449,7,7 "..JR.NZ"
c 53456 Interrupt jump
D 53456 The IM2 vector table at #R53504 is filled with 208, so every interrupt jumps here (53456=208*257). The address is set to #R34069 or #R48539 when interrupts are enabled. Note that these three bytes sit in the middle of leftover assembler source text (see the #LINK(Facts#source)(trivia page)).
@ 53456 label=INTJUMP
C 53456,3 Jump back
t 53459 Leftover assembler source
B 53459,32,32 "TDED f+.; p+..LD.A,(HTSTAT) z+.."
B 53491,13,13 "AND.A .+..JP."
b 53504 Interrupt vector table
D 53504 257 bytes of 208 (only 256 are needed), so that an IM2 interrupt with I=209 always jumps to #R53456. The table is placed over more leftover source code.
B 53504,257,8*32,1
t 53761 Leftover assembler source
B 53761,32,32 "HAPE3),A B,..LD.A,16 L,..LD.BC,D"
b 53793 Picture: the Partridge Club (compressed)
D 53793 Drawn by #R32126 for the bar-room animation. #HTML[<img src="../images/pic53793.png" width="256" alt="The Partridge Club" />]
B 53793,1899,8*237,3
b 55692 Picture: the street (compressed)
D 55692 Drawn by #R32126 for the getaway car animation. #HTML[<img src="../images/pic55692.png" width="256" alt="The street" />]
B 55692,1891,8*236,3
b 57583 Picture: a man in a hat at a table
D 57583 Command list drawn by #R31247; used by the bubble layout at #R33921 (first table). #HTML[<img src="../images/pic57583.png" width="256" alt="A man in a hat at a table" />]
B 57583,1090,8*136,2
b 58673 Picture: a figure in a doorway between headlights
D 58673 Command list drawn by #R31247; used by the bubble layout at #R33913 (first table). #HTML[<img src="../images/pic58673.png" width="256" alt="A figure in a doorway" />]
B 58673,724,8*90,4
b 59397 Picture: two hoods at a table
D 59397 Command list drawn by #R31247; used by the bubble layout at #R33917 (first table). #HTML[<img src="../images/pic59397.png" width="256" alt="Two hoods at a table" />]
B 59397,1129,8*141,1
b 60526 Picture: the getaway car from above
D 60526 Command list drawn by #R31247; used by the bubble layout at #R33929 (second table). #HTML[<img src="../images/pic60526.png" width="256" alt="The getaway car from above" />]
B 60526,1099,8*137,3
b 61625 Picture: two figures at the waterfront
D 61625 Command list drawn by #R31247; used by the bubble layout at #R33933 (second table). #HTML[<img src="../images/pic61625.png" width="256" alt="Two figures at the waterfront" />]
B 61625,1976,8
b 63601 Picture: hoods and a car in the city
D 63601 Command list drawn by #R31247; used by the bubble layout at #R33925 (second table). #HTML[<img src="../images/pic63601.png" width="256" alt="Hoods and a car in the city" />]
B 63601,1045,8*130,5
b 64646 Picture: close-up of a hood
D 64646 Command list drawn by #R31247; used by the fixed "answer" bubble layout at #R33909. #HTML[<img src="../images/pic64646.png" width="256" alt="Close-up of a hood" />]
B 64646,890,8*111,2
