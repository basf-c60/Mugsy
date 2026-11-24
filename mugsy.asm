  ORG 24576

; Start the game
;
; This is the entry point (from PRINT USR 24576 in the BASIC loader). It
; disables interrupts, moves the stack down into the printer buffer, saves IY
; (which the ROM interrupt routine needs) and calls the main loop. When the
; player answers "nope" to "Hows about another game, Mugsy?" the main loop
; returns here and the machine locks up in an infinite loop (see the bugs
; page).
START:
  DI                      ; Disable interrupts
  LD SP,23552             ; Put the stack in the printer buffer, just below the
                          ; system variables
  LD (33900),IY           ; Save IY (the ROM interrupt routine needs it to
                          ; point at the system variables)
  CALL MAINLOOP           ; Play games until the player has had enough
  JR 24587                ; Then hang forever (see the bugs page)

; Main loop: play one game
;
; Initialises the variables, shows Louey's greeting and then plays years until
; the game status flag at 33897 is non-zero. A value of 2 means "another game";
; 1 means "no more".
MAINLOOP:
  CALL INITVARS           ; Initialise the VM variables and flags
  LD IY,24609             ; Run the script at 24609: Louey says "Hi Boss, it's
                          ; Louey your sidekick here..."
  CALL RUNVM              ; Run the greeting script
  CALL PLAYYEAR           ; Play years until the game ends
  LD A,(33897)            ; Pick up the game status flag (1=quit, 2=new game)
  DEC A                   ; Count down: 1 (quit) becomes 0
  RET Z                   ; Return (and hang) if the player doesn't want
                          ; another game
  JR MAINLOOP             ; Otherwise start a new game

; VM script: Louey's greeting
;
; Run by MAINLOOP at the start of each game.
  DEFB 1,134,194,20       ; VM: SAY 49798,20 "Hi Boss, it's Louey your sidekick
                          ; here wit' da lowdown on da mob..."
  DEFB 0                  ; VM: END

; Play one year
;
; Picks one of the two speech bubble layout tables at random (33913 or 33925),
; runs the main VM script at 24652 and loops until the script sets the game
; status flag at 33897.
PLAYYEAR:
  LD HL,0                 ; No bubble layout is current yet
  LD (33904),HL           ; Remember that no layout is current
  LD A,100                ; A=100: the upper limit (RANDOMPM takes the absolute
                          ; value, giving 0..100)
  CALL RANDOMPM           ; A=a random number from 0 to 100
  CP 50                   ; Is it less than 50?
  LD HL,33913             ; Use the first table of bubble layouts...
  JR C,24635              ; ...if so
  LD HL,33925             ; Otherwise use the second table
  LD (33902),HL           ; Store the layout table pointer
  LD IY,24652             ; Run the main script at 24652 for this year
  CALL RUNVM              ; Run the year's script
  LD A,(33897)            ; Has the game finished?
  AND A                   ; Test the game status flag
  JR Z,PLAYYEAR           ; Play another year if not
  RET                     ; Return: the game is over

; VM script: one year of the game
;
; Run by PLAYYEAR. This is the whole game: the report on last year, Rocco, the
; contract, buying and selling clients, ammo, the squeeze, the kickback, the
; hit man, the year's results and finally the end-of-game rating. See the VM
; reference for the instruction set.
  DEFB 1,174,194,1,4,9    ; VM: SAY 49838,1 "Last year (Killed) guys got rubbed
                          ; out by other mobs and (Recruits) hoods wuz
                          ; recruited by the organisation."
  DEFB 6,72,9,94,96       ; VM: IFLT K0,Recruits,24670
  DEFB 1,253,194,9        ; VM: SAY 49917,9 "[City Hall think you stink/Some of
                          ; da boys is sayin' you're all washed up], Boss."
  DEFB 13,137,96          ; VM: GOTO 24713
  DEFB 9,96,132,1,137,96  ; VM: IFPEEKEQ 33888,1,24713
  DEFB 30,71              ; VM: RND K1
  DEFB 23,69              ; VM: MUL K10
  DEFB 23,9               ; VM: MUL Recruits
  DEFB 25,3               ; VM: DIV Hoods
  DEFB 15,24              ; VM: STORE FedsKilled
  DEFB 26,9,43            ; VM: DIV Recruits,K2
  DEFB 17,24              ; VM: ADD FedsKilled
  DEFB 27                 ; VM: INT
  DEFB 15,24              ; VM: STORE FedsKilled
  DEFB 18,10,24           ; VM: ADD TotalKilled,FedsKilled
  DEFB 15,10              ; VM: STORE TotalKilled
  DEFB 21,3,24            ; VM: SUB Hoods,FedsKilled
  DEFB 15,3               ; VM: STORE Hoods
  DEFB 1,7,195,9,24       ; VM: SAY 49927,9 "But some was undercover feds and
                          ; (FedsKilled) got killed in the shootout."
  DEFB 11,1,96,132        ; VM: POKE 1,33888
  DEFB 9,96,132,1,153,96  ; VM: IFPEEKEQ 33888,1,24729
  DEFB 1,40,195,8,3,36,208 ; VM: SAY 49960,8 "So da mob now contains (Hoods)
                           ; <msg 53284> hoodlums."
  DEFB 13,160,96          ; VM: GOTO 24736
  DEFB 1,40,195,9,3,38,208 ; VM: SAY 49960,9 "So da mob now contains (Hoods)
                           ; <msg 53286> hoodlums."
  DEFB 6,51,3,180,96      ; VM: IFLT K9,Hoods,24756
  DEFB 1,64,195,1         ; VM: SAY 49984,1 "Me and the boys is gettin' out
                          ; pronto."
  DEFB 1,83,195,9         ; VM: SAY 50003,9 "What a Schmuck you are, Mugsy!"
  DEFB 11,2,98,132        ; VM: POKE 2,33890
  DEFB 13,63,103          ; VM: GOTO 26431
  DEFB 18,13,3            ; VM: ADD HoodYears,Hoods
  DEFB 15,13              ; VM: STORE HoodYears
  DEFB 4,72,1,205,96      ; VM: IFNE K0,Squeezed,24781
  DEFB 1,96,195,1         ; VM: SAY 50016,1 "We didn't run no rackets, Boss."
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,25              ; VM: STORE Takings
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,26              ; VM: STORE Profit
  DEFB 13,0,97            ; VM: GOTO 24832
  DEFB 24,1,5             ; VM: MUL Squeezed,Price
  DEFB 17,41              ; VM: ADD K05
  DEFB 27                 ; VM: INT
  DEFB 15,25              ; VM: STORE Takings
  DEFB 24,5,38            ; VM: MUL Price,K1000
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 1,117,195,1,1,8,33,25 ; VM: SAY 50037,1 "We protected (Squeezed) of your
                             ; (Clients) clients last year and squeezed them
                             ; for an average of $(Tmp), so we made (Takings)
                             ; thousand bucks."
  DEFB 28,25              ; VM: LOAD Takings
  DEFB 15,26              ; VM: STORE Profit
  DEFB 18,16,25           ; VM: ADD TotalTakings,Takings
  DEFB 15,16              ; VM: STORE TotalTakings
  DEFB 9,99,132,1,11,97   ; VM: IFPEEKEQ 33891,1,24843
  DEFB 8,44,25,11,97      ; VM: IFGE K3,Takings,24843
  DEFB 26,25,43           ; VM: DIV Takings,K2
  DEFB 27                 ; VM: INT
  DEFB 15,26              ; VM: STORE Profit
  DEFB 1,160,195,9        ; VM: SAY 50080,9 "but Rocco's mob got half of that
                          ; when they jumped us last winter."
  DEFB 3,72,2,47,97       ; VM: IFEQ K0,Raided,24879
  DEFB 2,45,208           ; VM: SETMSG 53293
  DEFB 13,19,97           ; VM: GOTO 24851
  DEFB 3,72,2,47,97       ; VM: IFEQ K0,Raided,24879
  DEFB 2,47,208           ; VM: SETMSG 53295
  DEFB 18,7,26            ; VM: ADD Dough,Profit
  DEFB 20,2               ; VM: SUB Raided
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 6,69,33,71,97      ; VM: IFLT K10,Tmp,24903
  DEFB 18,7,26            ; VM: ADD Dough,Profit
  DEFB 20,69              ; VM: SUB K10
  DEFB 15,2               ; VM: STORE Raided
  DEFB 6,71,2,71,97       ; VM: IFLT K1,Raided,24903
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,2               ; VM: STORE Raided
  DEFB 9,99,132,1,62,97   ; VM: IFPEEKEQ 33891,1,24894
  DEFB 1,201,195,9,47,208 ; VM: SAY 50121,9 "<msg 53295>, we kept our noses
                          ; clean wit' da inmates of da precint house,"
  DEFB 13,68,97           ; VM: GOTO 24900
  DEFB 1,201,195,9,45,208 ; VM: SAY 50121,9 "<msg 53293>, we kept our noses
                          ; clean wit' da inmates of da precint house,"
  DEFB 13,78,97           ; VM: GOTO 24910
  DEFB 1,253,195,9,0,0,2  ; VM: SAY 50173,9 "<msg 0> the cops raided us and
                          ; took (Raided) grand from our safe, Boss."
  DEFB 11,1,99,132        ; VM: POKE 1,33891
  DEFB 18,18,8            ; VM: ADD ClientYears,Clients
  DEFB 15,18              ; VM: STORE ClientYears
  DEFB 18,7,26            ; VM: ADD Dough,Profit
  DEFB 20,2               ; VM: SUB Raided
  DEFB 15,7               ; VM: STORE Dough
  DEFB 18,17,26           ; VM: ADD TotalProfit,Profit
  DEFB 15,17              ; VM: STORE TotalProfit
  DEFB 3,72,14,155,97     ; VM: IFEQ K0,Loan,24987
  DEFB 18,27,64           ; VM: ADD Interest,K100
  DEFB 23,14              ; VM: MUL Loan
  DEFB 25,64              ; VM: DIV K100
  DEFB 27                 ; VM: INT
  DEFB 15,14              ; VM: STORE Loan
  DEFB 21,7,14            ; VM: SUB Dough,Loan
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 5,72,33,133,97     ; VM: IFLE K0,Tmp,24965
  DEFB 1,27,196,1,7,14    ; VM: SAY 50203,1 "You've got exactly (Dough) grand
                          ; in the safe, Boss. Anyways, dat's less than da
                          ; (Loan) grand ya owe Nick the Greek, so he's takin'
                          ; over."
  DEFB 13,169,96          ; VM: GOTO 24745
  DEFB 1,91,196,1,14      ; VM: SAY 50267,1 "Nick the Greek has got the (Loan)
                          ; grand ya owed him."
  DEFB 4,69,33,150,97     ; VM: IFNE K10,Tmp,24982
  DEFB 1,113,196,1        ; VM: SAY 50289,1 "So ya aint got the dough ta buy
                          ; rods and bullets so da boys can defend theirselves.
                          ; Sorry, Boss,- you're goin' for a ride."
  DEFB 13,169,96          ; VM: GOTO 24745
  DEFB 21,7,14            ; VM: SUB Dough,Loan
  DEFB 15,7               ; VM: STORE Dough
  DEFB 1,175,196,9,7      ; VM: SAY 50351,9 "You got (Dough) thousand bucks."
  DEFB 9,103,132,1,183,97 ; VM: IFPEEKEQ 33895,1,25015
  DEFB 9,102,132,1,179,97 ; VM: IFPEEKEQ 33894,1,25011
  DEFB 1,88,197,1         ; VM: SAY 50520,1 "Your cousin Abe has muscled in on
                          ; your territory. You've had it."
  DEFB 13,169,96          ; VM: GOTO 24745
  DEFB 1,238,197,9        ; VM: SAY 50670,9 "[Well, ya lived for another
                          ; year./Lucky you're still in charge./I gotta hand it
                          ; to ya, Boss./I just don't know how ya do it,
                          ; Boss./Ya sure are a survivor, Boss./Gee, You're
                          ; still da boss, Boss./Cripes, you're still hangin'
                          ; on.]"
  DEFB 18,12,11           ; VM: ADD TotalBlunders,Blunders
  DEFB 15,12              ; VM: STORE TotalBlunders
  DEFB 3,36,6,63,103      ; VM: IFEQ Years,Year,26431
  DEFB 8,43,11,205,97     ; VM: IFGE K2,Blunders,25037
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 13,216,97          ; VM: GOTO 25048
  DEFB 26,36,43           ; VM: DIV Years,K2
  DEFB 27                 ; VM: INT
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 4,36,6,50,98       ; VM: IFNE Years,Year,25138
  DEFB 9,101,132,1,231,97 ; VM: IFPEEKEQ 33893,1,25063
  DEFB 1,255,197,0,51,208 ; VM: SAY 50687,0 "<msg 53299> some of da boys in the
                          ; mob is sayin' you're past it and they're talkin
                          ; about puttin' out a contract on you. If it goes any
                          ; further, how many grand ( if any) will you pay to
                          ; keep the good guys faithful?"
  DEFB 13,237,97          ; VM: GOTO 25069
  DEFB 1,255,197,0,49,208 ; VM: SAY 50687,0 "<msg 53297> some of da boys in the
                          ; mob is sayin' you're past it and they're talkin
                          ; about puttin' out a contract on you. If it goes any
                          ; further, how many grand ( if any) will you pay to
                          ; keep the good guys faithful?"
  DEFB 14,142,108         ; VM: CALL GETNUMBER (get a number from the player)
  DEFB 28,35              ; VM: LOAD Input
  DEFB 15,30              ; VM: STORE Handout
  DEFB 9,104,132,1,23,98  ; VM: IFPEEKEQ 33896,1,25111
  DEFB 9,104,132,2,46,98  ; VM: IFPEEKEQ 33896,2,25134
  DEFB 21,7,30            ; VM: SUB Dough,Handout
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 6,72,33,37,98      ; VM: IFLT K0,Tmp,25125
  DEFB 1,131,198,9,7      ; VM: SAY 50819,9 "You'll kill us wit' kindness,
                          ; Boss.....( you've only got (Dough) grand). Tell me
                          ; that again, Boss."
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 13,30,98           ; VM: GOTO 25118
  DEFB 1,99,198,9         ; VM: SAY 50787,9 "Boss, the boys'll gun ya down."
  DEFB 14,137,110         ; VM: CALL HUSHMONEY (Louey charges hush money for a
                          ; blunder)
  DEFB 1,118,198,8        ; VM: SAY 50806,8 "How many grand for the handout?."
  DEFB 13,237,97          ; VM: GOTO 25069
  DEFB 1,181,198,9        ; VM: SAY 50869,9 "Okay, Boss, my guys will help ya."
  DEFB 21,7,30            ; VM: SUB Dough,Handout
  DEFB 15,7               ; VM: STORE Dough
  DEFB 11,2,100,132       ; VM: POKE 2,33892
  DEFB 9,103,132,2,60,98  ; VM: IFPEEKEQ 33895,2,25148
  DEFB 1,200,198,9        ; VM: SAY 50888,9 "It costs one grand to put the
                          ; squeeze on each client, and the godfather made the
                          ; rule that our gangsters each get one client to
                          ; protect for theirselves."
  DEFB 30,71              ; VM: RND K1
  DEFB 23,48              ; VM: MUL K6
  DEFB 17,71              ; VM: ADD K1
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 6,47,33,80,98      ; VM: IFLT K5,Tmp,25168
  DEFB 11,1,99,132        ; VM: POKE 1,33891
  DEFB 13,199,98          ; VM: GOTO 25287
  DEFB 11,2,99,132        ; VM: POKE 2,33891
  DEFB 1,11,199,1         ; VM: SAY 50955,1 "The word is that Rocco's gettin'
                          ; uppity. They say he wants ta muscle in on your
                          ; patch, Boss."
  DEFB 24,3,43            ; VM: MUL Hoods,K2
  DEFB 17,8               ; VM: ADD Clients
  DEFB 17,14              ; VM: ADD Loan
  DEFB 17,64              ; VM: ADD K100
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 6,33,7,199,98      ; VM: IFLT Tmp,Dough,25287
  DEFB 1,57,199,8         ; VM: SAY 51001,8 "Dis could be tough, but maybe we
                          ; can buy off Rocco's mob. How many grand ( if any)
                          ; can you pay?"
  DEFB 14,142,108         ; VM: CALL GETNUMBER (get a number from the player)
  DEFB 28,35              ; VM: LOAD Input
  DEFB 15,31              ; VM: STORE Bribe
  DEFB 9,104,132,1,147,98 ; VM: IFPEEKEQ 33896,1,25235
  DEFB 9,104,132,2,199,98 ; VM: IFPEEKEQ 33896,2,25287
  DEFB 5,31,7,161,98      ; VM: IFLE Bribe,Dough,25249
  DEFB 1,169,199,9,7      ; VM: SAY 51113,9 "You must be off ya rocker, Boss,
                          ; we've only got (Dough) grand."
  DEFB 14,137,110         ; VM: CALL HUSHMONEY (Louey charges hush money for a
                          ; blunder)
  DEFB 1,200,199,8        ; VM: SAY 51144,8 "Better try again - how many G's?"
  DEFB 13,108,98          ; VM: GOTO 25196
  DEFB 1,104,199,9        ; VM: SAY 51048,9 "Rocco aint usually regarded as a
                          ; philanthropist, Boss. He don't give nuthin' away."
  DEFB 14,137,110         ; VM: CALL HUSHMONEY (Louey charges hush money for a
                          ; blunder)
  DEFB 1,159,199,8        ; VM: SAY 51103,8 "How many thousand, Boss?"
  DEFB 13,108,98          ; VM: GOTO 25196
  DEFB 21,7,31            ; VM: SUB Dough,Bribe
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 6,47,33,186,98     ; VM: IFLT K5,Tmp,25274
  DEFB 1,219,199,9        ; VM: SAY 51163,9 "Geez, Boss, we're gonna need some
                          ; ourselves. Ya wanna think again?"
  DEFB 14,137,110         ; VM: CALL HUSHMONEY (Louey charges hush money for a
                          ; blunder)
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 13,108,98          ; VM: GOTO 25196
  DEFB 1,255,199,9        ; VM: SAY 51199,9 "Okay, Boss, we'll see if it
                          ; works."
  DEFB 21,7,31            ; VM: SUB Dough,Bribe
  DEFB 15,7               ; VM: STORE Dough
  DEFB 11,1,99,132        ; VM: POKE 1,33891
  DEFB 9,103,132,1,217,98 ; VM: IFPEEKEQ 33895,1,25305
  DEFB 30,71              ; VM: RND K1
  DEFB 23,48              ; VM: MUL K6
  DEFB 17,54              ; VM: ADD K13
  DEFB 27                 ; VM: INT
  DEFB 15,34              ; VM: STORE ClientCost
  DEFB 13,226,98          ; VM: GOTO 25314
  DEFB 30,71              ; VM: RND K1
  DEFB 23,69              ; VM: MUL K10
  DEFB 17,52              ; VM: ADD K11
  DEFB 27                 ; VM: INT
  DEFB 15,34              ; VM: STORE ClientCost
  DEFB 1,23,200,1,34      ; VM: SAY 51223,1 "This year we can buy or sell
                          ; clients for (ClientCost) grand each."
  DEFB 24,3,47            ; VM: MUL Hoods,K5
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 7,8,33,1,99        ; VM: IFGT Clients,Tmp,25345
  DEFB 1,41,200,9         ; VM: SAY 51241,9 "The boys is workin' real hard.
                          ; Now, how many clients do we buy from the
                          ; syndicate?"
  DEFB 13,17,99           ; VM: GOTO 25361
  DEFB 1,117,200,9        ; VM: SAY 51317,9 "Minuses won't wash here, Mugsy.
                          ; How many do we buy?"
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 5,54,34,13,99      ; VM: IFLE K13,ClientCost,25357
  DEFB 1,112,200,8        ; VM: SAY 51312,8 "How many do we buy from the
                          ; syndicate this year, Boss? ( The price is right!)."
  DEFB 13,17,99           ; VM: GOTO 25361
  DEFB 1,92,200,8         ; VM: SAY 51292,8 "How many do we buy from the
                          ; syndicate this year, Boss?"
  DEFB 14,142,108         ; VM: CALL GETNUMBER (get a number from the player)
  DEFB 28,35              ; VM: LOAD Input
  DEFB 15,19              ; VM: STORE Bought
  DEFB 9,104,132,2,79,99  ; VM: IFPEEKEQ 33896,2,25423
  DEFB 9,104,132,1,248,98 ; VM: IFPEEKEQ 33896,1,25336
  DEFB 24,19,34           ; VM: MUL Bought,ClientCost
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 21,7,33            ; VM: SUB Dough,Tmp
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 5,72,33,58,99      ; VM: IFLE K0,Tmp,25402
  DEFB 1,140,200,9        ; VM: SAY 51340,9 "Cripes, Boss, you gotta be outa ya
                          ; mind, we aint made of money."
  DEFB 13,1,99            ; VM: GOTO 25345
  DEFB 28,33              ; VM: LOAD Tmp
  DEFB 15,7               ; VM: STORE Dough
  DEFB 18,8,19            ; VM: ADD Clients,Bought
  DEFB 15,8               ; VM: STORE Clients
  DEFB 13,161,99          ; VM: GOTO 25505
  DEFB 1,5,201,1          ; VM: SAY 51461,1 "Cut the minus garbage, Mugsy!"
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 8,57,34,91,99      ; VM: IFGE K19,ClientCost,25435
  DEFB 1,182,200,8        ; VM: SAY 51382,8 "How many do ya wanna sell? ( The
                          ; price is right!)."
  DEFB 13,95,99           ; VM: GOTO 25439
  DEFB 1,171,200,8        ; VM: SAY 51371,8 "How many do ya wanna sell?"
  DEFB 14,142,108         ; VM: CALL GETNUMBER (get a number from the player)
  DEFB 28,35              ; VM: LOAD Input
  DEFB 15,20              ; VM: STORE Sold
  DEFB 9,104,132,2,161,99 ; VM: IFPEEKEQ 33896,2,25505
  DEFB 9,104,132,1,70,99  ; VM: IFPEEKEQ 33896,1,25414
  DEFB 8,8,20,130,99      ; VM: IFGE Clients,Sold,25474
  DEFB 1,187,200,9,8      ; VM: SAY 51387,9 "Geez, Boss, we've only got
                          ; (Clients) customers. If the boys think you wanna
                          ; make a fast buck and then skip, you could be takin'
                          ; an unexpected ride!"
  DEFB 14,137,110         ; VM: CALL HUSHMONEY (Louey charges hush money for a
                          ; blunder)
  DEFB 13,79,99           ; VM: GOTO 25423
  DEFB 4,8,20,139,99      ; VM: IFNE Clients,Sold,25483
  DEFB 1,27,201,9         ; VM: SAY 51483,9 "Jumpin' jellyfish, Boss,- how do
                          ; ya expect us ta survive if ya sell all our clients
                          ; to the syndicate?"
  DEFB 21,8,20            ; VM: SUB Clients,Sold
  DEFB 15,22              ; VM: STORE ClientsLeft
  DEFB 7,3,22,119,99      ; VM: IFGT Hoods,ClientsLeft,25463
  DEFB 24,20,34           ; VM: MUL Sold,ClientCost
  DEFB 17,7               ; VM: ADD Dough
  DEFB 15,7               ; VM: STORE Dough
  DEFB 21,8,20            ; VM: SUB Clients,Sold
  DEFB 15,8               ; VM: STORE Clients
  DEFB 4,72,7,173,99      ; VM: IFNE K0,Dough,25517
  DEFB 1,78,201,1         ; VM: SAY 51534,1 "As you know, Mugsy, that means we
                          ; aint got nuthin' left."
  DEFB 13,169,96          ; VM: GOTO 24745
  DEFB 1,98,201,0,7       ; VM: SAY 51554,0 "As you know, Boss, that leaves
                          ; (Dough) thousand bucks in the safe. How many grand
                          ; are ya gonna give the boys for artillery and ammo?"
  DEFB 13,190,99          ; VM: GOTO 25534
  DEFB 1,228,201,8        ; VM: SAY 51684,8 "Cut the negatives, sucker!"
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 14,142,108         ; VM: CALL GETNUMBER (get a number from the player)
  DEFB 28,35              ; VM: LOAD Input
  DEFB 15,23              ; VM: STORE Ammo
  DEFB 9,104,132,2,21,100 ; VM: IFPEEKEQ 33896,2,25621
  DEFB 9,104,132,1,181,99 ; VM: IFPEEKEQ 33896,1,25525
  DEFB 21,7,23            ; VM: SUB Dough,Ammo
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 3,72,33,239,99     ; VM: IFEQ K0,Tmp,25583
  DEFB 6,72,33,251,99     ; VM: IFLT K0,Tmp,25595
  DEFB 1,156,201,9,7      ; VM: SAY 51612,9 "You aint thinkin' straight, Boss.
                          ; There's only (Dough) grand left in the safe."
  DEFB 14,137,110         ; VM: CALL HUSHMONEY (Louey charges hush money for a
                          ; blunder)
  DEFB 1,159,199,8        ; VM: SAY 51103,8 "How many thousand, Boss?"
  DEFB 13,190,99          ; VM: GOTO 25534
  DEFB 1,188,201,8        ; VM: SAY 51644,8 "Geez, there'll be nuthin' left.
                          ; Tell me that again, Boss, I musta misheard you."
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 13,190,99          ; VM: GOTO 25534
  DEFB 6,3,23,41,100      ; VM: IFLT Hoods,Ammo,25641
  DEFB 1,243,201,9        ; VM: SAY 51699,9 "Gee, da boys is gonna be hoppin'
                          ; mad, Boss- you sure got guts!"
  DEFB 26,23,3            ; VM: DIV Ammo,Hoods
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 7,41,33,25,100     ; VM: IFGT K05,Tmp,25625
  DEFB 11,1,102,132       ; VM: POKE 1,33894
  DEFB 13,29,100          ; VM: GOTO 25629
  DEFB 1,22,202,9         ; VM: SAY 51734,9 "Ya gonna get da guys bumped off."
  DEFB 11,2,102,132       ; VM: POKE 2,33894
  DEFB 11,2,97,132        ; VM: POKE 2,33889
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 13,81,100          ; VM: GOTO 25681
  DEFB 24,3,43            ; VM: MUL Hoods,K2
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 5,33,23,58,100     ; VM: IFLE Tmp,Ammo,25658
  DEFB 1,39,202,9         ; VM: SAY 51751,9 "Yeah, Boss, keep'em scared, eh!"
  DEFB 13,72,100          ; VM: GOTO 25672
  DEFB 24,3,47            ; VM: MUL Hoods,K5
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 7,3,23,77,100      ; VM: IFGT Hoods,Ammo,25677
  DEFB 1,58,202,9         ; VM: SAY 51770,9 "Cripes, Boss, they could fight a
                          ; war with the hardware that'll buy."
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 11,1,102,132       ; VM: POKE 1,33894
  DEFB 21,7,23            ; VM: SUB Dough,Ammo
  DEFB 15,7               ; VM: STORE Dough
  DEFB 21,8,3             ; VM: SUB Clients,Hoods
  DEFB 15,21              ; VM: STORE Unsqueezed
  DEFB 6,72,21,125,100    ; VM: IFLT K0,Unsqueezed,25725
  DEFB 1,97,202,9         ; VM: SAY 51809,9 "We got so few clients left that
                          ; squeezin' them aint gonna pay your moll's hooch
                          ; bills."
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,1               ; VM: STORE Squeezed
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,14              ; VM: STORE Loan
  DEFB 13,53,101          ; VM: GOTO 25909
  DEFB 1,177,202,9        ; VM: SAY 51889,9 "Forget the negatives, Mugsy- just
                          ; tell me how many customers to lean on this year."
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 1,146,202,8,21     ; VM: SAY 51858,8 "We got (Unsqueezed) clients in
                          ; need of protection, Boss. How many do we put the
                          ; squeeze on this year?"
  DEFB 14,142,108         ; VM: CALL GETNUMBER (get a number from the player)
  DEFB 28,35              ; VM: LOAD Input
  DEFB 15,1               ; VM: STORE Squeezed
  DEFB 9,104,132,2,30,101 ; VM: IFPEEKEQ 33896,2,25886
  DEFB 9,104,132,1,116,100 ; VM: IFPEEKEQ 33896,1,25716
  DEFB 8,21,1,162,100     ; VM: IFGE Unsqueezed,Squeezed,25762
  DEFB 1,207,202,9,21     ; VM: SAY 51919,9 "Boss, there's only (Unsqueezed)
                          ; clients, and da guys gotta make an honest
                          ; livin'........ How many clients, Mugsy?"
  DEFB 13,120,100         ; VM: GOTO 25720
  DEFB 8,7,1,228,100      ; VM: IFGE Dough,Squeezed,25828
  DEFB 1,106,203,9,7      ; VM: SAY 52074,9 "[But we've only got (Dough)
                          ; grand./Have ya lost ya marbles, Mugsy? We've only
                          ; $(Dough) thousand left./Cut the kiddin', Boss. You
                          ; know there's only (Dough) grand in the safe.]"
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 21,1,7             ; VM: SUB Squeezed,Dough
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 7,58,33,125,100    ; VM: IFGT K20,Tmp,25725
  DEFB 7,37,33,200,100    ; VM: IFGT K800,Tmp,25800
  DEFB 1,115,203,9,1      ; VM: SAY 52083,9 "What wuz dat, Boss? I could've
                          ; swore you said (Squeezed)."
  DEFB 13,125,100         ; VM: GOTO 25725
  DEFB 21,1,7             ; VM: SUB Squeezed,Dough
  DEFB 15,14              ; VM: STORE Loan
  DEFB 30,71              ; VM: RND K1
  DEFB 23,62              ; VM: MUL K60
  DEFB 17,68              ; VM: ADD K40
  DEFB 27                 ; VM: INT
  DEFB 15,27              ; VM: STORE Interest
  DEFB 1,146,203,9,14,27  ; VM: SAY 52114,9 "Great noos, Boss!...... I set up
                          ; this deal wit' Nick the Greek. He's gonna lend you
                          ; the other (Loan) grand at only (Interest) percent
                          ; interest."
  DEFB 18,7,14            ; VM: ADD Dough,Loan
  DEFB 15,7               ; VM: STORE Dough
  DEFB 13,242,100         ; VM: GOTO 25842
  DEFB 26,21,44           ; VM: DIV Unsqueezed,K3
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 8,33,1,30,101      ; VM: IFGE Tmp,Squeezed,25886
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,14              ; VM: STORE Loan
  DEFB 24,3,68            ; VM: MUL Hoods,K40
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 6,1,33,48,101      ; VM: IFLT Squeezed,Tmp,25904
  DEFB 1,226,203,9        ; VM: SAY 52194,9 "Watch out, Boss, the boys aint
                          ; gonna like workin' that hard."
  DEFB 18,7,23            ; VM: ADD Dough,Ammo
  DEFB 15,7               ; VM: STORE Dough
  DEFB 24,3,61            ; VM: MUL Hoods,K50
  DEFB 31                 ; VM: NEG
  DEFB 17,1               ; VM: ADD Squeezed
  DEFB 17,23              ; VM: ADD Ammo
  DEFB 15,23              ; VM: STORE Ammo
  DEFB 24,3,61            ; VM: MUL Hoods,K50
  DEFB 15,1               ; VM: STORE Squeezed
  DEFB 21,7,23            ; VM: SUB Dough,Ammo
  DEFB 20,1               ; VM: SUB Squeezed
  DEFB 15,7               ; VM: STORE Dough
  DEFB 13,53,101          ; VM: GOTO 25909
  DEFB 1,3,203,9          ; VM: SAY 51971,9 "You sure don't dig da protection
                          ; racket, - do ya, Boss?"
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 9,104,132,2,53,101 ; VM: IFPEEKEQ 33896,2,25909
  DEFB 13,238,100         ; VM: GOTO 25838
  DEFB 21,7,1             ; VM: SUB Dough,Squeezed
  DEFB 15,7               ; VM: STORE Dough
  DEFB 3,72,7,135,101     ; VM: IFEQ K0,Dough,25991
  DEFB 13,73,101          ; VM: GOTO 25929
  DEFB 1,38,204,8         ; VM: SAY 52262,8 "If dat means you want the cops to
                          ; pay us, forget it. How much?"
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 13,78,101          ; VM: GOTO 25934
  DEFB 1,249,203,8,7      ; VM: SAY 52217,8 "Outa you (Dough) grand, how much
                          ; are you putting aside for the annual kickback to
                          ; the cops?"
  DEFB 14,142,108         ; VM: CALL GETNUMBER (get a number from the player)
  DEFB 28,35              ; VM: LOAD Input
  DEFB 15,32              ; VM: STORE Kickback
  DEFB 9,104,132,2,139,101 ; VM: IFPEEKEQ 33896,2,25995
  DEFB 9,104,132,1,61,101 ; VM: IFPEEKEQ 33896,1,25917
  DEFB 7,32,7,110,101     ; VM: IFGT Kickback,Dough,25966
  DEFB 21,7,32            ; VM: SUB Dough,Kickback
  DEFB 15,7               ; VM: STORE Dough
  DEFB 13,139,101         ; VM: GOTO 25995
  DEFB 3,72,7,131,101     ; VM: IFEQ K0,Dough,25987
  DEFB 1,129,204,9,7      ; VM: SAY 52353,9 "Geez, Boss, you sure are scared of
                          ; these cops. But you musta forgot you only have
                          ; (Dough) grand...... Anyway, I guess you want I
                          ; should let da cops have the whole lot. ( Ya stoopid
                          ; jerk )."
  DEFB 28,7               ; VM: LOAD Dough
  DEFB 15,32              ; VM: STORE Kickback
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,7               ; VM: STORE Dough
  DEFB 13,139,101         ; VM: GOTO 25995
  DEFB 1,65,204,9         ; VM: SAY 52289,9 "Boy are you scared of da cops!
                          ; Well they're gonna get a dissy dis year'cos there
                          ; aint no funds left. ( Ya stoopid wally )."
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,32              ; VM: STORE Kickback
  DEFB 11,2,103,132       ; VM: POKE 2,33895
  DEFB 10,100,132,2,215,101 ; VM: IFPEEKNE 33892,2,26071
  DEFB 26,30,3            ; VM: DIV Handout,Hoods
  DEFB 25,44              ; VM: DIV K3
  DEFB 17,71              ; VM: ADD K1
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 1,183,196,9        ; VM: SAY 50359,9 "You're through, Boss, the hit man
                          ; from Detroit is on his way in,"
  DEFB 14,198,110         ; VM: CALL HITMAN (shootout with the hit man from
                          ; Detroit)
  DEFB 10,100,132,3,178,101 ; VM: IFPEEKNE 33892,3,26034
  DEFB 1,2,197,1          ; VM: SAY 50434,1 "Tough luck Boss, me and the
                          ; boys'll give ya a decent funeral."
  DEFB 13,169,96          ; VM: GOTO 24745
  DEFB 1,222,196,1        ; VM: SAY 50398,1 "Geez, so much for the contract,
                          ; you've eliminated their hit man."
  DEFB 10,100,132,2,211,101 ; VM: IFPEEKNE 33892,2,26067
  DEFB 30,71              ; VM: RND K1
  DEFB 23,68              ; VM: MUL K40
  DEFB 17,58              ; VM: ADD K20
  DEFB 25,64              ; VM: DIV K100
  DEFB 23,7               ; VM: MUL Dough
  DEFB 27                 ; VM: INT
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 21,7,33            ; VM: SUB Dough,Tmp
  DEFB 15,7               ; VM: STORE Dough
  DEFB 1,39,197,9,33      ; VM: SAY 50471,9 "But its gonna cost ya (Tmp) grand
                          ; to keep the cops quiet about all the people what
                          ; got wasted in the shootout."
  DEFB 11,1,100,132       ; VM: POKE 1,33892
  DEFB 9,102,132,1,234,101 ; VM: IFPEEKEQ 33894,1,26090
  DEFB 30,71              ; VM: RND K1
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 8,41,33,234,101    ; VM: IFGE K05,Tmp,26090
  DEFB 11,1,102,132       ; VM: POKE 1,33894
  DEFB 30,71              ; VM: RND K1
  DEFB 23,45              ; VM: MUL K35
  DEFB 17,42              ; VM: ADD K15
  DEFB 15,5               ; VM: STORE Price
  DEFB 24,5,64            ; VM: MUL Price,K100
  DEFB 17,41              ; VM: ADD K05
  DEFB 27                 ; VM: INT
  DEFB 25,64              ; VM: DIV K100
  DEFB 15,5               ; VM: STORE Price
  DEFB 21,69,5            ; VM: SUB K10,Price
  DEFB 20,11              ; VM: SUB Blunders
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 4,72,33,13,102     ; VM: IFNE K0,Tmp,26125
  DEFB 21,11,71           ; VM: SUB Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 18,7,32            ; VM: ADD Dough,Kickback
  DEFB 17,71              ; VM: ADD K1
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 24,7,7             ; VM: MUL Dough,Dough
  DEFB 25,33              ; VM: DIV Tmp
  DEFB 15,35              ; VM: STORE Input
  DEFB 24,32,50           ; VM: MUL Kickback,K8
  DEFB 15,2               ; VM: STORE Raided
  DEFB 24,1,5             ; VM: MUL Squeezed,Price
  DEFB 20,2               ; VM: SUB Raided
  DEFB 15,2               ; VM: STORE Raided
  DEFB 21,69,5            ; VM: SUB K10,Price
  DEFB 20,11              ; VM: SUB Blunders
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 26,2,33            ; VM: DIV Raided,Tmp
  DEFB 15,2               ; VM: STORE Raided
  DEFB 30,71              ; VM: RND K1
  DEFB 23,32              ; VM: MUL Kickback
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 21,35,33           ; VM: SUB Input,Tmp
  DEFB 17,2               ; VM: ADD Raided
  DEFB 27                 ; VM: INT
  DEFB 15,2               ; VM: STORE Raided
  DEFB 6,58,2,74,102      ; VM: IFLT K20,Raided,26186
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,2               ; VM: STORE Raided
  DEFB 34,3               ; VM: SQRT Hoods
  DEFB 23,3               ; VM: MUL Hoods
  DEFB 23,8               ; VM: MUL Clients
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 18,23,32           ; VM: ADD Ammo,Kickback
  DEFB 33                 ; VM: SQRT
  DEFB 23,8               ; VM: MUL Clients
  DEFB 23,8               ; VM: MUL Clients
  DEFB 25,33              ; VM: DIV Tmp
  DEFB 15,9               ; VM: STORE Recruits
  DEFB 24,11,46           ; VM: MUL Blunders,K4
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 21,9,33            ; VM: SUB Recruits,Tmp
  DEFB 15,9               ; VM: STORE Recruits
  DEFB 24,11,43           ; VM: MUL Blunders,K2
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 21,9,33            ; VM: SUB Recruits,Tmp
  DEFB 27                 ; VM: INT
  DEFB 15,9               ; VM: STORE Recruits
  DEFB 9,102,132,1,126,102 ; VM: IFPEEKEQ 33894,1,26238
  DEFB 18,9,9             ; VM: ADD Recruits,Recruits
  DEFB 15,9               ; VM: STORE Recruits
  DEFB 5,72,9,138,102     ; VM: IFLE K0,Recruits,26250
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,9               ; VM: STORE Recruits
  DEFB 13,147,102         ; VM: GOTO 26259
  DEFB 7,64,9,147,102     ; VM: IFGT K100,Recruits,26259
  DEFB 28,63              ; VM: LOAD K99
  DEFB 15,9               ; VM: STORE Recruits
  DEFB 11,1,96,132        ; VM: POKE 1,33888
  DEFB 30,71              ; VM: RND K1
  DEFB 23,69              ; VM: MUL K10
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 7,50,33,166,102    ; VM: IFGT K8,Tmp,26278
  DEFB 11,2,96,132        ; VM: POKE 2,33888
  DEFB 7,55,9,175,102     ; VM: IFGT K15b,Recruits,26287
  DEFB 1,55,205,9         ; VM: SAY 52535,9 "[Say, Boss, the word is you're
                          ; doin' okay!/They're sayin' you're doin' a good job
                          ; here, Boss./The Chicago mobs have heard of you now.
                          ; They think you might be another Scarface.]"
  DEFB 24,23,43           ; VM: MUL Ammo,K2
  DEFB 17,71              ; VM: ADD K1
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 24,3,3             ; VM: MUL Hoods,Hoods
  DEFB 25,33              ; VM: DIV Tmp
  DEFB 15,4               ; VM: STORE Killed
  DEFB 18,7,71            ; VM: ADD Dough,K1
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 24,32,58           ; VM: MUL Kickback,K20
  DEFB 25,33              ; VM: DIV Tmp
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 30,71              ; VM: RND K1
  DEFB 23,11              ; VM: MUL Blunders
  DEFB 23,69              ; VM: MUL K10
  DEFB 17,4               ; VM: ADD Killed
  DEFB 20,33              ; VM: SUB Tmp
  DEFB 27                 ; VM: INT
  DEFB 15,4               ; VM: STORE Killed
  DEFB 5,72,4,226,102     ; VM: IFLE K0,Killed,26338
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,4               ; VM: STORE Killed
  DEFB 13,34,103          ; VM: GOTO 26402
  DEFB 7,64,4,235,102     ; VM: IFGT K100,Killed,26347
  DEFB 28,63              ; VM: LOAD K99
  DEFB 15,4               ; VM: STORE Killed
  DEFB 6,4,3,34,103       ; VM: IFLT Killed,Hoods,26402
  DEFB 18,11,48           ; VM: ADD Blunders,K6
  DEFB 15,4               ; VM: STORE Killed
  DEFB 30,71              ; VM: RND K1
  DEFB 17,11              ; VM: ADD Blunders
  DEFB 17,47              ; VM: ADD K5
  DEFB 25,4               ; VM: DIV Killed
  DEFB 15,4               ; VM: STORE Killed
  DEFB 18,3,71            ; VM: ADD Hoods,K1
  DEFB 23,4               ; VM: MUL Killed
  DEFB 27                 ; VM: INT
  DEFB 15,4               ; VM: STORE Killed
  DEFB 8,64,4,16,103      ; VM: IFGE K100,Killed,26384
  DEFB 28,63              ; VM: LOAD K99
  DEFB 15,4               ; VM: STORE Killed
  DEFB 24,3,48            ; VM: MUL Hoods,K6
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 7,33,23,30,103     ; VM: IFGT Tmp,Ammo,26398
  DEFB 32,4               ; VM: HALF Killed
  DEFB 15,4               ; VM: STORE Killed
  DEFB 1,64,205,9         ; VM: SAY 52544,9 "You aint doin' too good, Mugsy!
                          ; The organisation is gettin' a bad reputation an
                          ; some of da boys is thinkin' of gettin' out while
                          ; they can."
  DEFB 21,3,4             ; VM: SUB Hoods,Killed
  DEFB 17,9               ; VM: ADD Recruits
  DEFB 15,3               ; VM: STORE Hoods
  DEFB 18,10,4            ; VM: ADD TotalKilled,Killed
  DEFB 15,10              ; VM: STORE TotalKilled
  DEFB 1,120,194,9        ; VM: SAY 49784,9 "A year goes by ......"
  DEFB 14,202,132         ; VM: CALL YEARGOESBY ("A year goes by ......"
                          ; animation)
  DEFB 18,6,71            ; VM: ADD Year,K1
  DEFB 15,6               ; VM: STORE Year
  DEFB 11,0,105,132       ; VM: POKE 0,33897
  DEFB 0                  ; VM: END
  DEFB 9,98,132,2,101,103 ; VM: IFPEEKEQ 33890,2,26469
  DEFB 1,127,205,5,3      ; VM: SAY 52607,5 "Okay, Mugsy, me an the (Hoods)
                          ; boys,"
  DEFB 24,6,53            ; VM: MUL Year,K12
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 7,33,10,92,103     ; VM: IFGT Tmp,TotalKilled,26460
  DEFB 1,151,205,5,6      ; VM: SAY 52631,5 "has had enough of your crazy mob
                          ; for the last (Year) years. So we're off ta find
                          ; some better rackets in [The
                          ; Bahamas/Florida/Disneyland/Hawaii/Las Vegas]."
  DEFB 13,97,103          ; VM: GOTO 26465
  DEFB 1,225,205,5,6      ; VM: SAY 52705,5 "has done pretty good in the mob
                          ; for the last (Year) years. So we're goin' ta invest
                          ; in some new rackets in [Alcatraz/Sing - Sing/San
                          ; Quentin/Siberia]."
  DEFB 1,110,194,9        ; VM: SAY 49774,9 "So long Mugsy."
  DEFB 21,3,68            ; VM: SUB Hoods,K40
  DEFB 23,64              ; VM: MUL K100
  DEFB 25,68              ; VM: DIV K40
  DEFB 15,28              ; VM: STORE HoodGrowth
  DEFB 26,16,13           ; VM: DIV TotalTakings,HoodYears
  DEFB 15,16              ; VM: STORE TotalTakings
  DEFB 21,8,0             ; VM: SUB Clients,StartClients
  DEFB 23,64              ; VM: MUL K100
  DEFB 25,0               ; VM: DIV StartClients
  DEFB 15,29              ; VM: STORE ClientGrowth
  DEFB 26,17,18           ; VM: DIV TotalProfit,ClientYears
  DEFB 15,17              ; VM: STORE TotalProfit
  DEFB 18,15,69           ; VM: ADD Score,K10
  DEFB 15,15              ; VM: STORE Score
  DEFB 9,98,132,2,145,103 ; VM: IFPEEKEQ 33890,2,26513
  DEFB 18,15,69           ; VM: ADD Score,K10
  DEFB 15,15              ; VM: STORE Score
  DEFB 21,36,6            ; VM: SUB Years,Year
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 8,46,33,159,103    ; VM: IFGE K4,Tmp,26527
  DEFB 28,46              ; VM: LOAD K4
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 24,33,44           ; VM: MUL Tmp,K3
  DEFB 31                 ; VM: NEG
  DEFB 17,15              ; VM: ADD Score
  DEFB 15,15              ; VM: STORE Score
  DEFB 26,28,69           ; VM: DIV HoodGrowth,K10
  DEFB 27                 ; VM: INT
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 5,39,33,182,103    ; VM: IFLE Km005,Tmp,26550
  DEFB 28,39              ; VM: LOAD Km005
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 8,55,33,191,103    ; VM: IFGE K15b,Tmp,26559
  DEFB 28,55              ; VM: LOAD K15b
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 18,15,33           ; VM: ADD Score,Tmp
  DEFB 15,15              ; VM: STORE Score
  DEFB 21,16,59           ; VM: SUB TotalTakings,K25
  DEFB 23,43              ; VM: MUL K2
  DEFB 27                 ; VM: INT
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 5,72,33,213,103    ; VM: IFLE K0,Tmp,26581
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 8,69,33,222,103    ; VM: IFGE K10,Tmp,26590
  DEFB 28,69              ; VM: LOAD K10
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 18,33,15           ; VM: ADD Tmp,Score
  DEFB 15,15              ; VM: STORE Score
  DEFB 26,29,46           ; VM: DIV ClientGrowth,K4
  DEFB 27                 ; VM: INT
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 5,40,33,242,103    ; VM: IFLE Km010,Tmp,26610
  DEFB 28,40              ; VM: LOAD Km010
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 8,56,33,251,103    ; VM: IFGE K17,Tmp,26619
  DEFB 28,56              ; VM: LOAD K17
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 18,15,33           ; VM: ADD Score,Tmp
  DEFB 17,60              ; VM: ADD K35b
  DEFB 20,12              ; VM: SUB TotalBlunders
  DEFB 15,15              ; VM: STORE Score
  DEFB 26,10,46           ; VM: DIV TotalKilled,K4
  DEFB 27                 ; VM: INT
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 8,58,33,19,104     ; VM: IFGE K20,Tmp,26643
  DEFB 28,58              ; VM: LOAD K20
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 21,15,33           ; VM: SUB Score,Tmp
  DEFB 15,15              ; VM: STORE Score
  DEFB 21,17,70           ; VM: SUB TotalProfit,K25c
  DEFB 23,58              ; VM: MUL K20
  DEFB 27                 ; VM: INT
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 5,40,33,41,104     ; VM: IFLE Km010,Tmp,26665
  DEFB 28,40              ; VM: LOAD Km010
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 8,69,33,50,104     ; VM: IFGE K10,Tmp,26674
  DEFB 28,69              ; VM: LOAD K10
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 18,15,33           ; VM: ADD Score,Tmp
  DEFB 15,15              ; VM: STORE Score
  DEFB 8,64,15,64,104     ; VM: IFGE K100,Score,26688
  DEFB 28,64              ; VM: LOAD K100
  DEFB 15,15              ; VM: STORE Score
  DEFB 6,72,15,80,104     ; VM: IFLT K0,Score,26704
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,15              ; VM: STORE Score
  DEFB 11,1,104,132       ; VM: POKE 1,33896
  DEFB 13,90,104          ; VM: GOTO 26714
  DEFB 26,15,69           ; VM: DIV Score,K10
  DEFB 27                 ; VM: INT
  DEFB 17,43              ; VM: ADD K2
  DEFB 25,64              ; VM: DIV K100
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 14,116,104         ; VM: CALL 26740 (choose the end-of-game rating)
  DEFB 1,34,206,8,0,0,15  ; VM: SAY 52770,8 "You were <msg 0>. You scored
                          ; (Score)%. Hows about another game, Mugsy?"
  DEFB 14,105,108         ; VM: CALL YESNO (get a yes/no answer)
  DEFB 12,111,104         ; VM: JZ 26735
  DEFB 11,1,105,132       ; VM: POKE 1,33897
  DEFB 0                  ; VM: END
  DEFB 11,2,105,132       ; VM: POKE 2,33897
  DEFB 0                  ; VM: END

; VM native: choose the end-of-game rating
;
; Called from the VM script at 26714. Uses the value in v33 (the score divided
; into bands) to pick one of the rating words ("lousy", "ghastly", "swell" and
; so on) from the table at 53301, and stores its address as the default
; sub-message (33898) for the "You were ..." message.
  LD L,33                 ; L=33 (v33: the rating number worked out by the
                          ; script)
  CALL LOADVAR            ; Load it into BCDE
  LD A,E                  ; A=low byte
  CALL 26753              ; Get the address of the rating word
  LD (33898),HL           ; Make it the default sub-message for the "You were
                          ; ..." message
  RET                     ; Done: HL points at the rating word

; Get the address of a rating word
;
; Returns the address of rating word number A (1-11) in the table of words at
; 53301. Any other value, including 0, gives the twelfth word, "terrific",
; which has no end code (see the bugs page).
;
;  Input:A Rating number
; Output:HL Address of the word
  LD HL,53301             ; Rating 1: "lousy"
  DEC A                   ; Count the rating down
  RET Z                   ; Return if this is the one
  LD HL,53303             ; Rating 2: "real bad"
  DEC A                   ; Count the rating down
  RET Z                   ; Return if this is the one
  LD HL,53307             ; Rating 3: "terrible"
  DEC A                   ; Count the rating down
  RET Z                   ; Return if this is the one
  LD HL,53313             ; Rating 4: "ghastly"
  DEC A                   ; Count the rating down
  RET Z                   ; Return if this is the one
  LD HL,53322             ; Rating 5: "poor"
  DEC A                   ; Count the rating down
  RET Z                   ; Return if this is the one
  LD HL,53328             ; Rating 6: "so-so"
  DEC A                   ; Count the rating down
  RET Z                   ; Return if this is the one
  LD HL,53332             ; Rating 7: "fair"
  DEC A                   ; Count the rating down
  RET Z                   ; Return if this is the one
  LD HL,53338             ; Rating 8: "good"
  DEC A                   ; Count the rating down
  RET Z                   ; Return if this is the one
  LD HL,53340             ; Rating 9: "okay"
  DEC A                   ; Count the rating down
  RET Z                   ; Return if this is the one
  LD HL,53342             ; Rating 10: "great"
  DEC A                   ; Count the rating down
  RET Z                   ; Return if this is the one
  LD HL,53344             ; Rating 11: "swell"
  DEC A                   ; Count the rating down
  RET Z                   ; Return if this is the one
  LD HL,53351             ; Anything else (including 0): "terrific" (see the
                          ; bugs page)
  RET                     ; Done: HL points at the rating word

; Draw the picture for a speech bubble layout
;
; IY points at a 4-byte bubble layout entry: byte 0 is the bubble placement
; chance, bytes 1-2 are the address of the picture data and byte 3 is the
; border colour. If the same layout is still on screen (33906=0) the screen is
; left alone except that the speech bubbles are wiped (cells with attribute 120
; cleared); otherwise the screen is cleared and the picture is redrawn by
; DRAWPIC.
;
; Input:IY Layout entry
DRAWLAYOUT:
  LD A,(IY+3)             ; Set the border colour for this layout
  OUT (254),A             ; Set the border to the layout's colour
  PUSH HL                 ; Keep the caller's HL
  LD L,(IY+1)             ; Pick up the address of the layout's picture
  LD H,(IY+2)             ; H=high byte of the picture address (HL=picture
                          ; address)
  EX (SP),HL              ; HL=the caller's HL again; the picture address is on
                          ; the stack
  POP IY                  ; IY=picture data
  LD A,(33906)            ; Has the layout changed?
  AND A                   ; Test the layout-changed flag
  JP NZ,DRAWPIC           ; If so, draw the whole picture
  PUSH HL                 ; Otherwise just wipe the speech bubbles: they are
                          ; the cells with attribute 120
  PUSH DE                 ; Save DE...
  PUSH BC                 ; ...and BC
  LD HL,16384             ; HL=display file
  LD DE,22528             ; DE=attribute file
  LD A,D                  ; Reached the end of the attribute file?
  CP 91                   ; Is this the end of the attribute file (high byte
                          ; 91)?
  JR Z,26872              ; Finish if so
  LD A,(DE)               ; Is this cell part of a bubble (bright white)?
  CP 120                  ; Is the cell bright white paper (a bubble cell)?
  JR NZ,26862             ; Jump if not
  PUSH HL                 ; Keep the cell's address
  LD B,8                  ; Clear the 8 pixel rows of the cell
  LD (HL),0               ; Clear one pixel row of the cell
  INC H                   ; Down to the next pixel row
  DJNZ 26856              ; Repeat for all eight pixel rows
  POP HL                  ; Back to the top of the cell
  INC DE                  ; Next attribute
  INC L                   ; Next cell
  JR NZ,26843             ; Jump back unless a third of the screen is done
  LD A,H                  ; A=H: the current screen third...
  ADD A,8                 ; Move to the next third
  LD H,A                  ; H=the next third
  JR 26843                ; Carry on with the next cell
  POP BC                  ; Restore BC...
  POP DE                  ; ...DE...
  POP HL                  ; ...and HL
  RET                     ; Done: all speech bubbles are wiped

; Wait for a key to be pressed or for a timeout
;
; First waits until all keys are released, then waits (up to A periods of about
; one second each) for a key to be pressed. Used after each speech bubble.
;
; Input:A Number of timeout periods
WAITKEY:
  PUSH AF                 ; Save AF...
  PUSH BC                 ; ...and BC
  LD B,A                  ; B=number of timeout periods
  XOR A                   ; Select every keyboard half-row (high byte of the
                          ; port = 0)
  IN A,(254)              ; Read every half-row of the keyboard
  AND 31                  ; Keep the key bits only
  CP 31                   ; Are all keys released?
  JR NZ,26879             ; Wait until they are
  CALL 26898              ; Wait about a second for a keypress
  JR NZ,26895             ; Finish if a key was pressed
  DJNZ 26888              ; Otherwise try again for up to B periods
  POP BC                  ; Restore BC...
  POP AF                  ; ...and AF
  RET                     ; Done: Z set if the time ran out, NZ if a key was
                          ; pressed

; Wait for a keypress with a timeout (one period)
;
; Returns with the zero flag reset if a key was pressed.
  PUSH BC                 ; Save BC
  LD BC,54600             ; BC=loop count (about one second)
  CALL 26907              ; Wait for a key or the timeout
  POP BC                  ; Restore BC
  RET                     ; Done

; Wait for a keypress for up to BC iterations
;
; Returns with the zero flag reset as soon as a key is pressed, or with the
; zero flag set after BC loops.
;
; Input:BC Loop count
  XOR A                   ; A=0: select every keyboard half-row
  IN A,(254)              ; Read every half-row of the keyboard
  AND 31                  ; Keep the key bits
  CP 31                   ; Is any key pressed?
  RET NZ                  ; Return (zero flag reset) if so
  DEC BC                  ; Count down
  LD A,B                  ; Is BC zero? Test B...
  OR C                    ; ...together with C
  JR NZ,26907             ; Keep waiting until BC is zero
  RET                     ; Return with the zero flag set (timeout)

; Get the address of a character in the font
;
; The proportional font at 27087 has 7 bytes per character (a width byte and
; six rows of pixels), starting with character 32. This routine computes
; 26863+7*A.
;
;  Input:A Character code
; Output:HL Address of the character's width byte
CHARADDR:
  PUSH DE                 ; Save DE
  LD L,A                  ; HL=A
  LD H,0                  ; HL=the character code
  LD E,A                  ; DE=A
  LD D,H                  ; DE=the character code
  ADD HL,HL               ; HL=2*code
  ADD HL,HL               ; HL=4*code
  ADD HL,HL               ; HL=8*A
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; HL=7*A
  LD DE,26863             ; Add 26863 (the font minus 7*32)
  ADD HL,DE               ; HL=address of the glyph
  POP DE                  ; Restore DE
  RET                     ; Done

; The current character
  DEFB 0

; Print a character in the proportional font
;
; Prints character A at pixel offset C within the cell at HL. The glyph is six
; pixels high and starts one pixel row down. Characters may straddle two cells,
; so each row is shifted into place by 27021, which also clears the pixels
; behind the glyph. The dollar sign and the comma get a seventh row (a tail
; below the line). On exit C and L have been moved past the character plus one
; pixel of spacing.
;
;  Input:A Character code
;        C Pixel offset (0-7) within the current cell
;        HL Display file address
; Output:C Updated pixel offset
;        L Updated column
PRINTCHAR:
  LD (26939),A            ; Remember the character
  PUSH AF                 ; Save the character...
  PUSH BC                 ; ...and the registers
  PUSH DE                 ; (DE)
  PUSH HL                 ; (HL, the screen address)
  CALL CHARADDR           ; Get the address of its glyph
  EX DE,HL                ; DE=glyph
  POP HL                  ; Restore the screen address
  PUSH HL                 ; Keep the screen address
  INC H                   ; Start one pixel row down
  LD A,(DE)               ; A=width
  INC DE                  ; Point at the first row
  PUSH AF                 ; Save the width
  LD B,A                  ; Build a mask of width+1 zero bits...
  INC B                   ; One more bit of mask than the width
  LD A,255                ; Start from a full byte
  SRL A                   ; Shift in a zero from the left
  DJNZ 26961              ; Shift again until the mask has the right number of
                          ; leading zeros
  LD (27019),A            ; ...and store it
  LD B,6                  ; Six rows
  CALL 27020              ; Print a row
  INC DE                  ; Step on to the next row of the glyph
  INC H                   ; Next pixel row
  DJNZ 26970              ; Repeat for six rows
  LD A,(26939)            ; Was it a dollar sign?
  CP 36                   ; Is it a dollar sign (36)?
  JR NZ,26991             ; Jump if not
  LD A,32                 ; Add the tail of the dollar sign below the line
  CALL 27021              ; Print the extra pixel row
  JR 27000                ; Skip the comma test
  CP 44                   ; A comma?
  JR NZ,27000             ; Jump if not
  LD A,128                ; Add the tail of the comma below the line
  CALL 27021              ; Print the extra pixel row
  POP AF                  ; A=width
  POP HL                  ; Restore the screen address
  POP DE                  ; Restore DE
  POP BC                  ; Restore BC
  ADD A,C                 ; Add the old pixel offset
  INC A                   ; +1 pixel of spacing
  CP 8                    ; Into the next cell?
  JR C,27015              ; Jump if not
  SUB 8                   ; Subtract the 8 pixels already passed
  INC L                   ; Move to the next cell
  JR 27006                ; Check again
  LD C,A                  ; C=new pixel offset
  POP AF                  ; Restore the character
  RET                     ; Done: HL, C updated to the next print position

; The glyph mask
  DEFB 255,0

; Print one pixel row of a glyph (from DE)
;
; Fetches the row byte at DE and falls through to 27021.
  LD A,(DE)               ; Pick up the pixel row

; Print one pixel row of a glyph
;
; Shifts the pixel row in A right by C bits across a 16-bit word and ORs it
; into the two screen bytes at HL and HL+1, using the mask at 27018.
;
; Input:A Pixel row
;       C Pixel offset
;       HL Display file address
  PUSH DE                 ; Save DE
  LD D,A                  ; D=pixel row
  LD E,0                  ; E=0 (the overflow into the next cell)
  PUSH BC                 ; Save BC
  LD A,C                  ; A=pixel offset
  LD BC,(27018)           ; BC=glyph mask
  AND A                   ; Is the offset 0?
  JR Z,27046              ; Jump if so
  SRL D                   ; Shift the row right one pixel...
  RR E                    ; The bits that fall off go into E
  SCF                     ; ...and the mask, bringing in a 1
  RR B                    ; Shift a 1 into the mask (B)...
  RR C                    ; ...and on into C
  DEC A                   ; One fewer shift to go
  JR NZ,27034             ; Repeat for each pixel of the offset
  LD A,B                  ; Clear the pixels behind the glyph in the first
                          ; cell...
  AND (HL)                ; Keep the background pixels outside the glyph
  OR D                    ; ...and draw the left part of the row
  LD (HL),A               ; Store the combined byte
  INC L                   ; Next cell
  LD A,C                  ; Do the same for the second cell
  AND (HL)                ; Keep the background pixels in the second cell
  OR E                    ; Add the overflow from the shifted row
  LD (HL),A               ; Store it
  DEC L                   ; Back to the first cell
  POP BC                  ; Restore BC
  POP DE                  ; Restore DE
  RET                     ; Done

; The attribute for the status line
  DEFB 120

; Clear a character cell and set its attribute
;
; Clears the eight bytes of the character cell at HL and sets its attribute to
; the value at 27059.
;
; Input:HL Display file address
  PUSH HL                 ; Save the cell address
  PUSH AF                 ; Keep the attribute value
  LD A,8                  ; 8 pixel rows
  LD (HL),0               ; Clear one
  INC H                   ; Next pixel row
  DEC A                   ; One fewer row to clear
  JR NZ,27064             ; Repeat for all eight rows
  LD A,H                  ; Work out the attribute address from the display
                          ; file address
  DEC A                   ; H-1: the display file third is now 0-2 in bits 3-4
  RRCA                    ; Move the third number...
  RRCA                    ; ...down into the low bits...
  RRCA                    ; ...(three rotates)
  AND 3                   ; Keep the two bits of the third
  ADD A,88                ; Add the high byte of the attribute file
  LD H,A                  ; H=attribute address high byte
  LD A,(27059)            ; Set the attribute
  LD (HL),A               ; Set the cell's attribute
  POP AF                  ; Restore the attribute value
  POP HL                  ; Restore the screen address
  RET                     ; Done: the cell is blank with the new attribute

; Proportional font
;
; Used by PRINTCHAR for the text in the speech bubbles. Each character has 7
; bytes: the width in pixels followed by six pixel rows (the font is only six
; pixels high). Characters 32-122 are present; lower case letters are drawn as
; small capitals.
  DEFB 2,0,0,0,0,0,0      ; Character 32 (space): width 2
  DEFB 1,0,128,128,128,0,128 ; Character 33 (!): width 1
  DEFB 3,160,160,0,0,0,0  ; Character 34 (double quote): width 3
  DEFB 5,0,80,248,80,248,80 ; Character 35 (#): width 5
  DEFB 5,32,248,160,248,40,248 ; Character 36 ($): width 5
  DEFB 5,0,200,144,32,72,152 ; Character 37 (%): width 5
  DEFB 5,64,160,64,168,144,232 ; Character 38 (&): width 5
  DEFB 2,64,128,0,0,0,0   ; Character 39 ('): width 2
  DEFB 2,64,128,128,128,128,64 ; Character 40 ((): width 2
  DEFB 2,128,64,64,64,64,128 ; Character 41 ()): width 2
  DEFB 5,0,80,32,248,32,80 ; Character 42 (*): width 5
  DEFB 5,0,32,32,248,32,32 ; Character 43 (+): width 5
  DEFB 2,0,0,0,0,64,64    ; Character 44 (,): width 2
  DEFB 4,0,0,0,240,0,0    ; Character 45 (-): width 4
  DEFB 2,0,0,0,0,128,128  ; Character 46 (.): width 2
  DEFB 5,0,8,16,32,64,128 ; Character 47 (/): width 5
  DEFB 4,0,96,144,144,144,96 ; Character 48 (0): width 4
  DEFB 3,0,64,192,64,64,224 ; Character 49 (1): width 3
  DEFB 4,0,96,144,32,64,240 ; Character 50 (2): width 4
  DEFB 4,0,96,144,32,144,96 ; Character 51 (3): width 4
  DEFB 4,0,32,96,160,240,32 ; Character 52 (4): width 4
  DEFB 4,0,224,128,224,16,224 ; Character 53 (5): width 4
  DEFB 4,0,96,128,224,144,96 ; Character 54 (6): width 4
  DEFB 4,0,240,16,32,64,64 ; Character 55 (7): width 4
  DEFB 4,0,96,144,96,144,96 ; Character 56 (8): width 4
  DEFB 4,0,96,144,112,16,96 ; Character 57 (9): width 4
  DEFB 1,0,0,128,0,128,0  ; Character 58 (:): width 1
  DEFB 2,0,0,64,0,64,64   ; Character 59 (;): width 2
  DEFB 3,0,32,64,128,64,32 ; Character 60 (<): width 3
  DEFB 4,0,0,240,0,240,0  ; Character 61 (=): width 4
  DEFB 3,0,128,64,32,64,128 ; Character 62 (>): width 3
  DEFB 5,112,136,16,32,0,32 ; Character 63 (?): width 5
  DEFB 5,0,112,168,176,128,112 ; Character 64 (@): width 5
  DEFB 6,112,136,136,248,136,136 ; Character 65 (A): width 6
  DEFB 6,240,136,240,136,136,240 ; Character 66 (B): width 6
  DEFB 6,112,136,128,128,136,112 ; Character 67 (C): width 6
  DEFB 6,224,144,136,136,144,224 ; Character 68 (D): width 6
  DEFB 6,248,128,240,128,128,248 ; Character 69 (E): width 6
  DEFB 6,248,128,240,128,128,128 ; Character 70 (F): width 6
  DEFB 6,112,136,128,184,136,112 ; Character 71 (G): width 6
  DEFB 6,136,136,248,136,136,136 ; Character 72 (H): width 6
  DEFB 5,248,32,32,32,32,248 ; Character 73 (I): width 5
  DEFB 6,8,8,8,136,136,112 ; Character 74 (J): width 6
  DEFB 5,144,160,192,160,144,136 ; Character 75 (K): width 5
  DEFB 5,128,128,128,128,128,248 ; Character 76 (L): width 5
  DEFB 6,136,216,168,136,136,136 ; Character 77 (M): width 6
  DEFB 6,136,200,168,168,152,136 ; Character 78 (N): width 6
  DEFB 6,112,136,136,136,136,112 ; Character 79 (O): width 6
  DEFB 6,240,136,136,240,128,128 ; Character 80 (P): width 6
  DEFB 6,112,136,136,168,144,104 ; Character 81 (Q): width 6
  DEFB 6,240,136,136,240,144,136 ; Character 82 (R): width 6
  DEFB 6,112,128,112,8,136,112 ; Character 83 (S): width 6
  DEFB 5,248,32,32,32,32,32 ; Character 84 (T): width 5
  DEFB 6,136,136,136,136,136,112 ; Character 85 (U): width 6
  DEFB 6,136,136,136,136,80,32 ; Character 86 (V): width 6
  DEFB 6,136,136,136,168,216,136 ; Character 87 (W): width 6
  DEFB 5,136,80,32,32,80,136 ; Character 88 (X): width 5
  DEFB 5,136,136,80,32,32,32 ; Character 89 (Y): width 5
  DEFB 6,248,8,48,64,128,248 ; Character 90 (Z): width 6
  DEFB 3,224,128,128,128,128,224 ; Character 91 ([): width 3
  DEFB 5,128,64,32,16,8,0 ; Character 92 (backslash): width 5
  DEFB 3,224,32,32,32,32,224 ; Character 93 (]): width 3
  DEFB 5,32,112,168,32,32,32 ; Character 94 (^): width 5
  DEFB 5,0,0,0,0,0,248    ; Character 95 (_): width 5
  DEFB 5,48,72,224,64,64,184 ; Character 96 (`): width 5
  DEFB 4,0,96,144,240,144,144 ; Character 97 (a): width 4
  DEFB 4,0,224,144,224,144,224 ; Character 98 (b): width 4
  DEFB 4,0,96,144,128,144,96 ; Character 99 (c): width 4
  DEFB 4,0,224,144,144,144,224 ; Character 100 (d): width 4
  DEFB 4,0,240,128,224,128,240 ; Character 101 (e): width 4
  DEFB 4,0,240,128,224,128,128 ; Character 102 (f): width 4
  DEFB 4,0,96,128,176,144,96 ; Character 103 (g): width 4
  DEFB 4,0,144,144,240,144,144 ; Character 104 (h): width 4
  DEFB 3,0,224,64,64,64,224 ; Character 105 (i): width 3
  DEFB 4,0,16,16,16,144,96 ; Character 106 (j): width 4
  DEFB 4,0,144,160,192,160,144 ; Character 107 (k): width 4
  DEFB 4,0,128,128,128,128,240 ; Character 108 (l): width 4
  DEFB 5,0,136,216,168,136,136 ; Character 109 (m): width 5
  DEFB 5,0,136,200,168,152,136 ; Character 110 (n): width 5
  DEFB 4,0,96,144,144,144,96 ; Character 111 (o): width 4
  DEFB 4,0,224,144,224,128,128 ; Character 112 (p): width 4
  DEFB 4,0,96,144,144,160,80 ; Character 113 (q): width 4
  DEFB 4,0,224,144,224,144,144 ; Character 114 (r): width 4
  DEFB 4,0,96,128,96,16,224 ; Character 115 (s): width 4
  DEFB 3,0,224,64,64,64,64 ; Character 116 (t): width 3
  DEFB 4,0,144,144,144,144,96 ; Character 117 (u): width 4
  DEFB 4,0,144,144,144,160,64 ; Character 118 (v): width 4
  DEFB 5,0,136,136,136,168,80 ; Character 119 (w): width 5
  DEFB 5,0,136,80,32,80,136 ; Character 120 (x): width 5
  DEFB 4,0,144,144,160,64,64 ; Character 121 (y): width 4
  DEFB 4,0,240,32,64,128,240 ; Character 122 (z): width 4

; Print a character using the ROM font
;
; Used for the status line at the bottom of the screen. Copies the 8x8 glyph
; from the ROM character set (15360+8*A) to the cell at HL, then moves HL one
; cell right.
;
; Input:A Character code
;       HL Display file address
ROMCHAR:
  PUSH DE                 ; Save DE (the screen address)
  PUSH BC                 ; Save BC...
  PUSH HL                 ; ...and HL
  LD L,A                  ; HL=character code
  LD H,0                  ; HL=character code
  ADD HL,HL               ; HL=2*code
  ADD HL,HL               ; HL=4*code
  ADD HL,HL               ; HL=8*code
  LD DE,15360             ; Add 15360 (the ROM character set minus 256)
  ADD HL,DE               ; HL=address of the glyph in the ROM font
  POP DE                  ; DE=screen address
  PUSH DE                 ; Keep the screen address
  EX DE,HL                ; HL=screen, DE=glyph
  LD B,8                  ; 8 pixel rows
  LD A,(DE)               ; Copy a row
  LD (HL),A               ; Store the glyph row on the screen
  INC DE                  ; Next glyph row
  INC H                   ; Next pixel row
  DJNZ 27742              ; Repeat for all 8 rows
  POP HL                  ; HL=screen address
  POP BC                  ; Restore BC
  POP DE                  ; Restore DE
  INC L                   ; Move one cell right
  RET                     ; Done: the character is on screen and HL has moved
                          ; right

; VM native: get a yes/no answer
;
; Reads a line of input and returns with the zero flag set for "Y" or "y" and
; reset for "N" or "n". Any other answer makes Louey say "Don't get smart wit'
; me, Mugsy!..." (script at 27785) and asks again.
YESNO:
  CALL READLINE           ; Read a line of input
  LD A,(23808)            ; Pick up the first character
  CP 89                   ; "Y"?
  RET Z                   ; Return with the zero flag set if so
  CP 121                  ; "y"?
  RET Z                   ; Return with the zero flag set (yes)
  CP 78                   ; "N"?
  JR Z,27782              ; Jump if so
  CP 110                  ; "n"?
  JR Z,27782              ; Jump if so (no)
  LD IY,27785             ; Otherwise Louey says "Don't get smart wit' me,
                          ; Mugsy!..."
  CALL RUNVM              ; Run the script that says "Don't get smart wit' me"
  JR YESNO                ; And asks again
  OR 1                    ; Reset the zero flag for "no"
  RET                     ; Return with the zero flag reset (no)

; VM script: complain about a yes/no answer
  DEFB 1,228,206,8        ; VM: SAY 52964,8 "Don't get smart wit' me, Mugsy!
                          ; Just " yeah" or " nope" is fine."
  DEFB 0                  ; VM: END

; VM native: get a number from the player
;
; Reads a line of input and parses it into v35 (in hundredths, like all VM
; numbers). On an invalid entry Louey complains (script at 27807 or 27828 for
; fractions) and the blunder count v11 goes up. Flag 8 (33896) is set to the
; type of the answer: 1 = negative, 2 = zero, 3 = 0.01 (not possible from the
; keyboard), 4 = anything else.
GETNUMBER:
  CALL READLINE           ; Read a line of input
  CALL 27869              ; Parse it as a number into v35
  JR NZ,27817             ; Jump unless it was invalid
  LD IY,27807             ; Louey says "What wuz dat, Boss?..." (and the
                          ; blunder count goes up)
  CALL RUNVM              ; Run the script that asks what he said
  JR GETNUMBER            ; Ask again

; VM script: complain about an invalid number
;
; Also counts a blunder (v11).
  DEFB 1,125,206,8        ; VM: SAY 52861,8 "[What wuz dat, Boss? I missed
                          ; it/It's okay, Boss - this line aint tapped. Let's
                          ; have the answer]."
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 0                  ; VM: END

; Complain about a fraction and try again
;
; Entered with the carry flag reset when the number contained a decimal point.
  JR NC,27835             ; Jump if there was no decimal point
  LD IY,27828             ; Louey complains about fractions (another blunder)
  CALL RUNVM              ; Run the script that complains about fractions
  JR GETNUMBER            ; Ask again

; VM script: complain about a fraction
  DEFB 1,221,206,8        ; VM: SAY 52957,8 "[Geez, Boss, fractions makes my
                          ; head hurt. Gimme a good answer./Cripes, Boss, don't
                          ; make wit' da fractions. I never did learn to dig
                          ; them. Let's have it in good numbers!]"
  DEFB 13,163,108         ; VM: GOTO 27811

; Classify the number entered
;
; Sets flag 8 (33896) according to the value in BCDE: 1 if negative, 2 if zero,
; 3 if exactly 1 (0.01), 4 otherwise.
;
; Input:BCDE Number
  BIT 7,B                 ; Is the number negative?
  JR Z,27845              ; Jump if not
  LD A,1                  ; Type 1: negative
  LD (33896),A            ; Store the type in flag 8
  RET                     ; Done
  LD A,B                  ; Is it at least 2.56?
  OR C                    ; Combine the upper bytes
  OR D                    ; ...
  JR NZ,27864             ; Jump if so
  LD A,E                  ; Is the low byte zero?
  AND A                   ; Test the low byte
  JR NZ,27858             ; Jump if not
  LD A,2                  ; Type 2: zero
  JR 27841                ; Store the type
  CP 1                    ; Is it exactly 0.01?
  LD A,3                  ; Type 3 if so
  JR Z,27841              ; Store the type
  LD A,4                  ; Type 4: anything else
  JR 27841                ; Store the type

; The minus-sign flag
  DEFB 0

; Parse the input buffer as a number
;
; Checks the text at 23808 for an optional sign, digits and a decimal point,
; then runs the small VM scripts at 27995, 28000 and 28006 to accumulate the
; value in v35 (each digit: v35=v35*10+digit*100). Returns with the zero flag
; reset if the entry was not a valid whole number, and with the carry flag
; reset if it contained a decimal point.
  LD HL,23808             ; Point HL at the input
  LD A,(HL)               ; Pick up the first character
  AND A                   ; Test the first character
  RET Z                   ; Return (zero flag set: invalid) if the line is
                          ; empty
  CP 45                   ; A minus sign?
  JR Z,27892              ; Jump if so
  CP 43                   ; A plus sign?
  JR Z,27892              ; Jump if so
  CP 46                   ; A decimal point?
  JP Z,28017              ; Jump if so
  CALL 28021              ; Is it a digit?
  RET Z                   ; Return (zero flag set: invalid) if not
  INC HL                  ; Next character
  LD A,(HL)               ; A=the next character
  AND A                   ; End of the line?
  JR Z,27908              ; Jump if so: the entry is valid
  CP 46                   ; A decimal point?
  JP Z,28017              ; Jump if so
  CALL 28021              ; A digit?
  RET Z                   ; Return (invalid) if not
  JR 27892                ; Check the next character
  LD IX,23808             ; Now convert the number
  XOR A                   ; Clear the minus flag
  LD (27868),A            ; Store it: no minus sign yet
  LD A,(IX+0)             ; Pick up the first character
  CP 45                   ; A minus sign?
  JR NZ,27928             ; Jump if not
  LD (27868),A            ; Set the minus flag
  JR 27932                ; Skip over the sign
  CP 43                   ; A plus sign?
  JR NZ,27934             ; Jump if not
  INC IX                  ; Skip the sign
  LD IY,27995             ; Run the VM script that sets v35 to 0
  CALL RUNVM              ; Run the script: v35=0
  LD A,(IX+0)             ; Next character
  AND A                   ; End of the line?
  JR Z,27980              ; Jump if so
  LD IY,28000             ; Run the VM script that multiplies v35 by 10
  CALL RUNVM              ; Run the script: v35=v35*10
  LD A,(IX+0)             ; A=the digit
  SUB 48                  ; Convert it from ASCII
  LD E,A                  ; BCDE=digit
  LD D,0                  ; D=0
  LD B,D                  ; B=0
  LD C,D                  ; C=0: BCDE=the digit
  LD L,33                 ; Store it in v33
  CALL STOREVAR           ; Store the digit in v33
  LD IY,28006             ; Run the VM script that adds 100*v33 to v35
  CALL RUNVM              ; Run the script: add 100*v33 to v35 (the number is
                          ; kept in hundredths)
  INC IX                  ; Next character
  JR 27941                ; Next character
  LD L,35                 ; Load v35 into BCDE
  CALL LOADVAR            ; BCDE=the number
  LD A,(27868)            ; Was there a minus sign?
  AND A                   ; Test the minus-sign flag
  CALL NZ,30634           ; Negate the number if so
  OR 1                    ; Reset the zero flag: the entry was valid
  RET                     ; Done: Z set if the entry was invalid, NZ if it was
                          ; valid

; VM script: set the input value to zero
  DEFB 28,72              ; VM: LOAD K0
  DEFB 15,35              ; VM: STORE Input
  DEFB 0                  ; VM: END

; VM script: multiply the input value by 10
  DEFB 24,35,69           ; VM: MUL Input,K10
  DEFB 15,35              ; VM: STORE Input
  DEFB 0                  ; VM: END

; VM script: add a digit to the input value
;
; v33 holds the digit; it is multiplied by 100 (the fixed-point scale) and
; added to v35.
  DEFB 24,33,64           ; VM: MUL Tmp,K100
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 18,35,33           ; VM: ADD Input,Tmp
  DEFB 15,35              ; VM: STORE Input
  DEFB 0                  ; VM: END

; Set the "decimal point" result
;
; Returns with the zero flag reset and the carry flag set.
  OR 1                    ; Reset the zero flag...
  SCF                     ; ...and set the carry flag: a decimal point was
                          ; found
  RET                     ; Done: NZ and carry set means a decimal point

; Check whether A is a digit
;
; Returns with the carry flag set if A is "0"-"9".
;
;  Input:A Character code
; Output:F Carry set if A is a digit
  CP 48                   ; Below "0"?
  JR C,28028              ; Jump if so
  CP 58                   ; Below ":" (i.e. "0"-"9")?
  RET C                   ; Return with the carry flag set if so
  XOR A                   ; Set the zero flag (and reset the carry flag): not a
                          ; digit
  RET                     ; Done: Z means not a digit

; Clear a row of character cells
;
; Clears B cells starting at HL (via 27060).
;
; Input:B Number of cells
;       HL Display file address
  CALL 27060              ; Clear a cell and set its attribute
  INC L                   ; Next cell
  DJNZ 28030              ; Repeat for the whole row of cells
  RET                     ; Done

; Read a line of input in the answer bubble
;
; Clears the answer bubble on the right of the screen, then reads keys (via
; 28221) into the buffer at 23808, echoing them in the proportional font.
; DELETE (12) and LEFT (8) rub out the last character, ENTER (13) ends the
; line. The line is terminated with a zero byte.
READLINE:
  LD HL,23808             ; Fill the input buffer with 20 spaces
  LD DE,23809             ; DE=the next byte
  LD BC,19                ; BC=19: copy the first space along
  LD (HL),32              ; Put a space in the first byte
  LDIR                    ; Fill the 20 bytes with spaces
  LD HL,16438             ; Clear the answer bubble, line by line
  LD B,8                  ; Eight cells in the row
  CALL 28030              ; Clear the first row of the bubble (8 cells)
  LD HL,16469             ; HL=the second row
  LD B,10                 ; B=10 cells
  CALL 28030              ; Clear it
  LD HL,16500             ; HL=the third row
  LD B,12                 ; B=12 cells
  CALL 28030              ; Clear it
  LD HL,16533             ; HL=the fourth row
  LD B,10                 ; B=10 cells
  CALL 28030              ; Clear it
  LD HL,16566             ; HL=the fifth row
  LD B,8                  ; B=8 cells
  CALL 28030              ; Clear it
  LD HL,16604             ; HL=the tail of the bubble
  LD B,2                  ; B=2 cells
  CALL 28030              ; Clear it
  LD HL,16637             ; HL=the end of the tail
  LD B,1                  ; B=1 cell
  CALL 28030              ; Clear it
  LD HL,18461             ; HL=the last cell of the tail
  LD B,1                  ; B=1 cell
  CALL 28030              ; Clear it
  LD HL,16502             ; HL=start of the answer line
  LD C,0                  ; C=pixel offset 0
  LD DE,23808             ; DE=input buffer
  LD B,0                  ; B counts the characters typed
  CALL 28221              ; Wait for a key (flashing the cursor)
  CP 13                   ; ENTER?
  JR Z,28175              ; Finish if so
  CP 8                    ; LEFT (CAPS SHIFT+5)?
  JR Z,28178              ; Rub out if so
  CP 12                   ; DELETE (CAPS SHIFT+0)?
  JR Z,28178              ; Rub out if so
  CP 32                   ; Ignore other control keys
  JR C,28124              ; Control key: ignore it
  CP 128                  ; Ignore graphics and keyword codes
  JR NC,28124             ; Graphics or keyword: ignore it
  CALL PRINTCHAR          ; Echo the character
  INC B                   ; Count it
  LD (DE),A               ; Store it in the buffer
  INC DE                  ; Next byte of the buffer
  LD A,L                  ; Has the line reached column 30?
  AND 31                  ; Keep the column number
  CP 30                   ; Has it reached column 30 (the right-hand end of the
                          ; bubble)?
  JR NZ,28124             ; Get another key if not
  CALL 28221              ; The line is full: only ENTER or rubbing out will do
  CP 8                    ; Rub out?
  JR Z,28178              ; Yes
  CP 12                   ; Delete?
  JR Z,28178              ; Yes
  CP 13                   ; ENTER?
  JR NZ,28160             ; Not a wanted key: wait for another
  XOR A                   ; Terminate the input with a zero byte
  LD (DE),A               ; Store the terminator
  RET                     ; Return
  LD A,B                  ; Anything to rub out?
  AND A                   ; Test the count
  JR Z,28124              ; Ignore the key if not
  DEC B                   ; One character fewer
  DEC DE                  ; Back up in the buffer
  PUSH BC                 ; Save BC...
  PUSH HL                 ; ...and HL
  LD A,32                 ; Print two spaces over the cursor
  CALL PRINTCHAR          ; Print a space over the cursor
  CALL PRINTCHAR          ; And another to erase the character
  POP HL                  ; Restore the screen position
  POP BC                  ; Restore the count
  PUSH HL                 ; Save the screen position
  LD A,(DE)               ; Get the width of the character being rubbed out
  CALL CHARADDR           ; Get the glyph address of the character being rubbed
                          ; out
  LD A,(HL)               ; A=its width
  POP HL                  ; Restore the screen position
  INC A                   ; +1 pixel of spacing
  SUB C                   ; Move the print position back by that many pixels
  NEG                     ; Work out the pixel offset after moving back
  BIT 7,A                 ; Is the offset negative?
  JR Z,28216              ; No: done
  DEC L                   ; Back one cell
  ADD A,8                 ; Add a cell's 8 pixels
  JR 28207                ; Check again
  LD C,A                  ; C=new pixel offset
  JR 28124                ; Wait for the next key

; The cursor character
  DEFB 32,0

; Wait for a key, flashing the cursor
;
; Calls 28266 to wait for a key while flashing an asterisk cursor (every fourth
; frame) in the answer bubble.
;
; Output:A Key code (from LAST-K)
  CALL 28266              ; Wait one frame and check for a key
  PUSH AF                 ; Save the key
  PUSH HL                 ; Save HL
  PUSH BC                 ; Save BC
  LD A,(28220)            ; Advance the flash counter (0-3)
  INC A                   ; Add one
  AND 3                   ; Wrap round after 3
  LD (28220),A            ; Store the counter
  LD A,(28219)            ; Pick up the cursor character
  JR NZ,28252             ; Jump unless it is time to flash
  CP 32                   ; Swap between "*" and a space
  LD A,42                 ; A=42: the asterisk cursor
  JR Z,28249              ; It was a space: switch to the asterisk
  LD A,32                 ; A=32: a space
  LD (28219),A            ; Store the cursor character
  CALL PRINTCHAR          ; Print the cursor
  LD A,32                 ; A=space: blank the next position
  CALL PRINTCHAR          ; Print it
  POP BC                  ; Restore BC
  POP HL                  ; Restore HL
  POP AF                  ; Restore the key
  JR Z,28221              ; Back for another frame if no key was pressed
  RET                     ; Return

; Wait one frame and read the keyboard
;
; Enables interrupts long enough for one ROM interrupt (which scans the
; keyboard), then checks bit 5 of FLAGS to see if a new key has been pressed.
;
; Output:A Key code (if the zero flag is reset)
  PUSH IY                 ; Save IY
  PUSH HL                 ; Save HL
  PUSH BC                 ; Save BC
  LD IY,(33900)           ; Restore IY for the ROM interrupt routine
  EI                      ; Let one interrupt happen (the ROM scans the
                          ; keyboard)
  HALT                    ; Wait for the next interrupt
  DI                      ; Interrupts off again
  LD A,(23611)            ; Has a new key been pressed?
  BIT 5,A                 ; Is the ROM's new-key flag (bit 5 of FLAGS) set?
  JR Z,28292              ; Jump if not
  RES 5,A                 ; Acknowledge it
  LD (23611),A            ; Store the flags
  LD A,(23560)            ; A=the key code
  POP BC                  ; Restore BC
  POP HL                  ; Restore HL
  POP IY                  ; Restore IY
  RET                     ; Return

; VM native: Louey charges hush money for a blunder
;
; Runs the VM script at 28304. Each blunder increments v11; if the safe holds
; enough, Louey asks for one grand (or a tenth of the safe, if it holds 19
; grand or more) to keep quiet about it.
HUSHMONEY:
  LD IY,28304             ; Run the script at IY
  JP RUNVM                ; Run it: the script's own END returns to the caller

; VM script: Louey's hush money
;
; Run by HUSHMONEY after a blunder.
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 5,44,7,160,110     ; VM: IFLE K3,Dough,28320
  DEFB 18,11,71           ; VM: ADD Blunders,K1
  DEFB 15,11              ; VM: STORE Blunders
  DEFB 0                  ; VM: END
  DEFB 5,57,7,184,110     ; VM: IFLE K19,Dough,28344
  DEFB 26,7,69            ; VM: DIV Dough,K10
  DEFB 27                 ; VM: INT
  DEFB 15,33              ; VM: STORE Tmp
  DEFB 21,7,33            ; VM: SUB Dough,Tmp
  DEFB 15,7               ; VM: STORE Dough
  DEFB 1,8,208,5,33       ; VM: SAY 53256,5 "[Your stoopidity takes my breath
                          ; away, Mugsy. But for a mere (Tmp) grand I won't
                          ; tell nobody./Mugsy! You're so dumb. It's gonna cost
                          ; you (Tmp) G's ta make me forget it.]"
  DEFB 13,193,110         ; VM: GOTO 28353
  DEFB 1,172,207,5        ; VM: SAY 53164,5 "[Dat was real stoopid, Boss! If
                          ; your boys heard about it you wud get more laughs
                          ; than Jack Benny. However, for one crummy grand I
                          ; guarantee ta keep my trap shut./Cripes, Boss,
                          ; sometimes you're real dumb. But for a lousy grand I
                          ; can be persuaded not to spill da beans about your
                          ; stoopidity.]"
  DEFB 21,7,71            ; VM: SUB Dough,K1
  DEFB 15,7               ; VM: STORE Dough
  DEFB 1,15,208,9         ; VM: SAY 53263,9 "Gee ta, Boss! Now tell
                          ; me........."
  DEFB 0                  ; VM: END

; VM native: shootout with the hit man from Detroit
;
; Works out Mugsy's hit points from v33 (set by the script from the handout:
; (low byte of v33 AND 7)+1, or 8 if v33 is 2.56 or more) and plays the
; shootout at SHOOTOUT. On return flag 4 (33892) is set to the result: 1 = the
; hit man was killed, 2 = the hit man was killed but bystanders were hit (the
; cops then want 20-60% of the safe), 3 = Mugsy was killed.
HITMAN:
  LD L,33                 ; Variable 33 holds the handout, set by the script
  CALL LOADVAR            ; BCDE=the handout (as a fixed-point number)
  LD A,B                  ; Combine the upper three bytes
  OR C                    ; ...
  OR D                    ; ...
  LD A,E                  ; A=the low byte of the handout
  JR Z,28371              ; The upper bytes are zero: use the low byte as it is
  LD A,255                ; The handout is 2.56 or more: use 255 (8 hit points)
  CALL SHOOTOUT           ; Play the shootout (A gives Mugsy's hit points)
  PUSH AF                 ; Save the result
  LD A,(23611)            ; Read the keyboard flags
  RES 5,A                 ; Forget any keypress left over from the shootout
  LD (23611),A            ; Store the flags
  POP AF                  ; Restore the result
  BIT 0,A                 ; Was Mugsy killed (bit 0)?
  JR Z,28394              ; No
  LD A,3                  ; A=3: Mugsy was killed
  LD (33892),A            ; Store the outcome in flag 4
  RET                     ; Return
  AND 12                  ; Were any bystanders hit (bits 2 and 3)?
  LD A,1                  ; A=1: the hit man was killed and no bystanders were
                          ; hurt
  JR Z,28390              ; Zero: store 1
  LD A,2                  ; A=2: the hit man was killed but bystanders were hit
  JR 28390                ; Store the outcome

; Status line templates
;
; "HOODS ... CUSTOMERS ..." and "DOUGH IN DA SAFE $..." (32 characters each),
; filled in by 28468 and 28504.
  DEFB 72,79,79,68,83,32,32,32,32,32,32,32,32,32,67,85,83,84,79,77,69,82,83,32,32,32,32,32,32,32,32,32 ; "HOODS
                                                                                                       ; CUSTOMERS
                                                                                                       ; "
  DEFB 68,79,85,71,72,32,73,78,32,68,65,32,83,65,70,69,32,36,32,32,32,32,32,32,32,32,32,32,32,32,32,32 ; "DOUGH IN
                                                                                                       ; DA SAFE $
                                                                                                       ; "

; Print the first status line
;
; Prints "HOODS nn CUSTOMERS nnn" on the second-to-last line of the screen
; using the values of v3 and v8.
  LD HL,28410             ; HL=the template for the number of hoods
  LD A,7                  ; A=7: the field is seven characters wide
  LD D,3                  ; D=3: variable 3 holds the number of hoods
  CALL 28530              ; Format it into the template
  LD HL,28428             ; HL=the template for the number of customers
  LD A,7                  ; A=7: the field is seven characters wide
  LD D,8                  ; D=8: variable 8 holds the number of customers
  CALL 28530              ; Format it into the template
  LD B,32                 ; B=32: the whole line
  LD DE,28404             ; DE=the text of the line
  LD HL,20672             ; HL=the second-to-last character row
  LD A,(DE)               ; A=the next character
  CALL ROMCHAR            ; Print it
  INC DE                  ; Next character
  DJNZ 28496              ; Loop for the whole line
  RET                     ; Return

; Print the second status line
;
; Prints "DOUGH IN DA SAFE $nnn" using the value of v7.
  LD HL,28454             ; HL=the template for the money in the safe
  LD A,7                  ; A=7: the field is seven characters wide
  LD D,7                  ; D=7: variable 7 holds the money in the safe
  CALL 28530              ; Format it into the template
  LD B,32                 ; B=32: the whole line
  LD DE,28436             ; DE=the text of the line
  LD HL,20704             ; HL=the last character row
  LD A,(DE)               ; A=the next character
  CALL ROMCHAR            ; Print it
  INC DE                  ; Next character
  DJNZ 28522              ; Loop for the whole line
  RET                     ; Return

; Print a VM variable into a status line template
;
; Formats variable D into the template at HL (A characters long) via PRINTNUM.
;
; Input:A Field width
;       D Variable number
;       HL Template address
  PUSH HL                 ; Save the template address
  LD L,D                  ; L=the variable number
  CALL LOADVAR            ; BCDE=its value
  POP HL                  ; HL=the template address
  LD (29926),HL           ; Remember where the number goes
  LD (HL),32              ; Blank the field with spaces
  INC HL                  ; Next character of the field
  DEC A                   ; One fewer
  JR NZ,28539             ; Loop until the field is blank
  JP PRINTNUM             ; Print the value into the field

; The SAY flags
  DEFB 0

; Show a message in a speech bubble
;
; The handler for VM op 1 (SAY, 30225) jumps here. This is the heart of the
; comic strip display. HL holds the address of a message and A holds a flags
; byte:
;
; +------+--------------------------------------------------------------------+
; | Bits | Meaning                                                            |
; +------+--------------------------------------------------------------------+
; | 0-1  | Non-zero: wait for a keypress (with timeout) afterwards            |
; | 2-3  | Bubble placement: 0 = random entry from the layout table at 33902; |
; |      | 4 (bit 2) = the fixed entry at 33909 (the answer bubble); 8 (bit   |
; |      | 3) = keep the current entry                                        |
; | 4-6  | 16 = play the theme tune (TUNE)                                    |
; +------+--------------------------------------------------------------------+
;
; The message is rendered into the text buffer at 23808 (expanding dictionary
;     words and any variables, which are taken from the VM byte stream after
;     the SAY instruction), the picture is redrawn if the layout has changed,
;     the status lines are printed and the text is word-wrapped into the bubble
;     by PRINTBUBBLE.
;
; Input:A Flags HL Message address
SAY:
  LD (28548),A            ; Save the SAY flags
  PUSH HL                 ; Save the message address
  LD IY,33909             ; Point IY at the fixed "answer" bubble layout
  AND 12                  ; Keep bits 2 and 3 of the flags
  CP 4                    ; Bit 2 set?
  JR Z,28600              ; Use the fixed layout if so
  LD IY,(33904)           ; Otherwise start with the current layout
  CP 8                    ; Bit 3 set?
  JR Z,28600              ; Keep the current layout if so
  LD IY,(33902)           ; Otherwise pick a layout at random: point IY at this
                          ; year's layout table
  LD A,100                ; A=100: the upper limit
  CALL RANDOMPM           ; A=random number 0-100
  CP (IY+0)               ; Compare it with the entry's chance
  JR C,28595              ; Use this entry if the number is lower
  INC IY                  ; Otherwise move on to the next entry
  INC IY                  ; Four bytes per layout entry...
  INC IY                  ; ...
  INC IY                  ; ...
  JR 28580                ; Compare against the next entry
  CALL 28652              ; Is it the layout already on screen?
  JR Z,28571              ; If so pick again (the bubble must move)
  CALL 28652              ; Set A=1 if the layout has changed
  LD (33906),A            ; Store the layout-unchanged flag
  LD (33904),IY           ; Make this the current layout
  CALL DRAWLAYOUT         ; Draw the picture (or just wipe the old bubble)
  CALL 28468              ; Print the status lines
  CALL 28504              ; Print the second status line
  POP HL                  ; Restore the message address
  CALL RENDER             ; Render the message into the text buffer
  LD IX,23808             ; Point IX at the text buffer
  LD HL,16384             ; HL=top of the screen
  CALL PRINTBUBBLE        ; Print the text in a bubble
  LD A,(28548)            ; Pick up the SAY flags
  AND 112                 ; Keep bits 4-6
  CALL TUNE               ; Play the theme tune if they are 16
  LD A,(28548)            ; Pick up the SAY flags again
  AND 3                   ; Keep bits 0-1
  RET Z                   ; Return unless they ask for a pause
  LD A,8                  ; Wait up to 8 periods...
  JP WAITKEY              ; ...or until a key is pressed

; Check whether the bubble layout has changed
;
; Compares IY with the current layout (33904).
;
; Output:A 0 if unchanged, 1 if changed
;        F Zero flag set if unchanged
  PUSH HL                 ; Save HL...
  PUSH DE                 ; ...and DE
  PUSH IY                 ; HL=IY
  POP HL                  ; HL=IY, the layout being asked for
  LD DE,(33904)           ; DE=current layout
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Compare
  LD A,0                  ; A=0 (unchanged)
  POP DE                  ; Restore DE...
  POP HL                  ; ...and HL
  RET Z                   ; Return with A=0 and the zero flag set if they are
                          ; the same
  INC A                   ; A=1 (changed)
  RET                     ; Done: A=1 and NZ if the layout is different

; Measure the words in the text buffer
;
; Builds a list of word widths (in pixels) at 24192, terminated by 255.
;
; Input:IX Text
  LD DE,24192             ; Point DE at the word width list
  PUSH IX                 ; Save IX...
  PUSH HL                 ; ...and HL
  CALL 28698              ; Measure the next word
  AND A                   ; Was it empty (two spaces in a row)?
  JR Z,28685              ; Skip it if so
  LD (DE),A               ; Store its width
  INC DE                  ; Next entry in the table
  LD A,(IX+0)             ; Reached the end of the text?
  AND A                   ; Clear the carry flag
  JR NZ,28677             ; Back for the next word if not
  LD A,255                ; Terminate the list with 255
  LD (DE),A               ; Store the measured value
  POP HL                  ; Restore HL
  POP IX                  ; Restore IX
  RET                     ; Done

; Measure one word
;
; Adds up the widths (+1 pixel spacing) of the characters at IX up to the next
; space.
;
;  Input:IX Text
; Output:A Width in pixels
;        IX Next word
  PUSH BC                 ; Save BC
  PUSH HL                 ; Save HL
  LD C,0                  ; C will accumulate the width
  LD A,(IX+0)             ; Pick up a character
  AND A                   ; End of the text?
  JR Z,28724              ; Finish if so
  CALL CHARADDR           ; Get the address of its glyph
  LD A,(HL)               ; A=width of the character
  INC A                   ; +1 pixel of spacing
  ADD A,C                 ; Add the character's width to the total
  LD C,A                  ; Add it to the total
  LD A,(IX+0)             ; Pick up the character again
  INC IX                  ; Move on
  CP 32                   ; Was it a space?
  JR NZ,28702             ; Carry on until the end of the word
  POP HL                  ; Restore HL
  LD A,C                  ; A=width of the word
  POP BC                  ; Restore BC
  RET                     ; Done: A=the width of the word in pixels

; Speech bubble shape
;
; Line widths (28728-28736), left offsets (28737-28746) and margins
; (28747-28756) for the oval speech bubble; used by PRINTBUBBLE and 29161.
; 29161 fills lines from the top and the bottom of the bubble at the same time,
; so each of the nine widths serves a pair of lines (the outermost pair first),
; and the table covers bubbles of up to 18 lines.
  DEFB 43,75,91,91,107,107,107,107
  DEFB 107,1,3,4,4,5,5,5
  DEFB 5,5,0,254,253,253,252,252
  DEFB 252,252,252,0,0

; Print the text buffer into a speech bubble
;
; Works out how many lines the text needs (29161), then prints it line by line,
; centring each line within the oval bubble shape described by the table of
; line widths at 28728 and left margins at 28746. The bubble outline itself is
; drawn first by 28905.
;
; Input:IX Text
;       HL Display file address of the top of the bubble
PRINTBUBBLE:
  CALL 28671              ; Measure the words of the text
  PUSH IX                 ; Save IX...
  PUSH IY                 ; ...and IY
  PUSH HL                 ; Save the screen address
  CALL 29161              ; Work out the number of lines needed (B)
  LD A,B                  ; Is it odd?
  AND 1                   ; Keep bit 0: 1 if the number of lines is odd
  LD (28755),A            ; Store the odd-line flag
  LD A,B                  ; A=number of lines again
  SRL A                   ; B/2 lines in each half of the bubble
  LD (28756),A            ; Remember the number of lines in each half
  LD B,A                  ; B=lines in each half
  LD A,(28755)            ; C=index of the widest line
  ADD A,B                 ; Add the odd-line flag: the index of the middle line
  LD C,A                  ; C=index of the middle line
  LD B,0                  ; BC=index, to look up the left offset
  LD HL,28737             ; Look up the left offset of the bubble
  ADD HL,BC               ; HL=address of the offset for that line
  LD C,(HL)               ; C=the left offset of the bubble
  POP HL                  ; Restore the screen address
  ADD HL,BC               ; Add the left offset
  CALL 28885              ; Leave a blank row above the text
  LD IY,28746             ; IY points at the margins for each line
  LD DE,28728             ; DE points at the widths of the lines
  CALL 28905              ; Draw the bubble outline
  LD A,(28755)            ; B=number of lines in the top half (plus the middle
                          ; line if odd)
  LD B,A                  ; B=the odd-line flag...
  LD A,(28756)            ; ...plus the lines in the top half...
  ADD A,B                 ; ...gives the rows above the middle line...
  LD B,A                  ; ...B=row counter
  LD C,0                  ; C=pixel offset 0
  PUSH HL                 ; Keep the screen position of this row
  CALL 28879              ; Indent by the margin for this line
  LD A,(DE)               ; A=width of this line
  CALL 29029              ; Print as many words as fit
  POP HL                  ; Back to the start of the row
  INC IY                  ; Next margin
  INC DE                  ; Next width
  CALL 28885              ; Move down a row
  DJNZ 28817              ; Repeat for the top half
  DEC DE                  ; Step back to the middle line
  DEC IY                  ; Back to the middle line's margin entry
  LD A,(28755)            ; Is there an odd middle line?
  AND A                   ; Test for an odd middle line
  JR Z,28848              ; Jump if not
  DEC DE                  ; If so step back once more
  DEC IY                  ; ...and its margin entry
  LD A,(28756)            ; B=number of lines in the bottom half
  LD B,A                  ; B=number of lines in the bottom half
  AND A                   ; Test for none
  JR Z,28874              ; Jump if there are none
  LD C,0                  ; C=pixel offset 0
  PUSH HL                 ; Keep the screen position of this row
  CALL 28879              ; Indent by the margin for this line
  LD A,(DE)               ; A=width of this line
  CALL 29029              ; Print as many words as fit
  POP HL                  ; Back to the start of the row
  DEC IY                  ; Previous margin (the bottom half mirrors the top)
  DEC DE                  ; Previous width
  CALL 28885              ; Move down a row
  DJNZ 28855              ; Repeat for the bottom half
  POP IY                  ; Restore IY...
  POP IX                  ; ...and IX
  RET                     ; Done: the bubble and its text are drawn

; Add the bubble margin for the current line
;
; L=L+(IY+0).
  LD A,(IY+0)             ; A=margin for this line
  ADD A,L                 ; Add it to the column
  LD L,A                  ; L=the indented column
  RET                     ; Done

; Move HL down one character row
;
; HL=HL+32, crossing display file thirds as needed.
  LD A,L                  ; Move down 32 bytes
  ADD A,32                ; Add 32 to move down one pixel row...
  LD L,A                  ; L=the new low byte
  RET NC                  ; Return unless this crossed into the next third of
                          ; the screen
  LD A,H                  ; A=H
  ADD A,8                 ; Move to the next third
  LD H,A                  ; H=the next third
  RET                     ; Done

; Move HL up one character row
;
; HL=HL-32, crossing display file thirds as needed.
  LD A,L                  ; Move up 32 bytes
  SUB 32                  ; Subtract 32 to move up one pixel row...
  LD L,A                  ; L=the new low byte
  RET NC                  ; Return unless this crossed into the previous third
  LD A,H                  ; A=H
  SUB 8                   ; Move to the previous third
  LD H,A                  ; H=the previous third
  RET                     ; Done

; Draw the outline of a speech bubble
;
; Draws the rounded white bubble (paper 7) with one blank line above and below
; the text area.
  PUSH IY                 ; Save IY
  PUSH HL                 ; Save the registers this routine uses...
  PUSH DE                 ; ...(HL=screen position, DE=width table)...
  PUSH BC                 ; ...and BC, which will count rows
  CALL 28895              ; Start one row above the text
  LD A,(28755)            ; B=number of lines in the top half
  LD B,A                  ; B=lines in the top half...
  LD A,(28756)            ; ...plus the lines in the bottom half (28756)...
  ADD A,B                 ; ...to give the number of rows above the middle line
  LD B,A                  ; B=the row counter
  LD C,0                  ; C=pixel offset 0
  PUSH HL                 ; Keep the screen position for the next row
  CALL 28879              ; Indent by the margin
  LD A,(DE)               ; A=width of this line
  CALL 29006              ; Paint the white background for it
  POP HL                  ; Back to the start of this row
  INC IY                  ; Next margin entry
  INC DE                  ; Next line width
  CALL 28885              ; Move down a row
  DJNZ 28922              ; Repeat for the top half
  PUSH HL                 ; Keep the screen position of the middle row
  DEC DE                  ; Back to the widest line
  DEC IY                  ; Back to the widest line's margin entry
  CALL 28879              ; Indent by the margin
  LD A,(DE)               ; A=the width of the widest line
  CALL 29006              ; Paint the blank row above the text (as wide as the
                          ; line below it)
  LD A,(28755)            ; Is there an odd middle line?
  AND A                   ; Test for no odd middle line
  JR Z,28961              ; Skip the extra step if there is none
  DEC DE                  ; Odd middle line: step back one more width...
  DEC IY                  ; ...and one more margin entry
  POP HL                  ; Restore the screen position
  CALL 28885              ; Move down a row
  PUSH HL                 ; Keep the screen position of the middle row
  CALL 28879              ; Indent by the margin of the middle line
  LD A,(DE)               ; A=width of the middle line
  CALL 29006              ; Paint the middle row
  POP HL                  ; Restore the screen position
  LD A,(28756)            ; B=number of lines in the bottom half
  LD B,A                  ; B=lines in the bottom half
  AND A                   ; Test for none
  JR Z,29000              ; Jump if there are none
  LD C,0                  ; C=pixel offset 0
  CALL 28885              ; Move down a row
  PUSH HL                 ; Keep the screen position
  CALL 28879              ; Indent by the margin
  LD A,(DE)               ; A=the width of the line
  CALL 29006              ; Paint the background for this line
  POP HL                  ; Restore the screen position
  DEC IY                  ; Previous margin
  DEC DE                  ; Previous width
  DJNZ 28981              ; Repeat for the bottom half
  POP BC                  ; Restore BC...
  POP DE                  ; ...DE...
  POP HL                  ; ...HL...
  POP IY                  ; ...and IY
  RET                     ; Done: the whole bubble background is painted

; Fill part of a bubble line with white cells
;
; Paints A+16 pixels of white bubble background (via 27060) from the cell at
; HL.
  PUSH BC                 ; Save BC
  PUSH HL                 ; Save HL...
  ADD A,16                ; Add 16 pixels of margin to the line width
  LD B,A                  ; B=pixels to paint
  DEC L                   ; Start one cell to the left
  CALL 27060              ; Clear a cell and make it white
  INC L                   ; Next cell
  LD A,B                  ; A=the width again
  SUB 8                   ; 8 pixels done
  LD B,A                  ; B=the width
  CP 8                    ; Any more?
  JR NC,29012             ; Jump back if so
  POP HL                  ; Restore HL
  POP BC                  ; Restore BC
  RET                     ; Done

; The line start pointer
  DEFB 0,0

; Print one line of text in a bubble
;
; Prints as many words from IX as will fit in A pixels, centred.
;
; Input:A Line width in pixels
;       IX Text
  PUSH BC                 ; Save BC
  PUSH DE                 ; Save DE
  LD B,A                  ; B=the width of the line in pixels
  LD A,(IX+0)             ; A=the first character of the text
  AND A                   ; Test it
  JR Z,29157              ; End of the text: nothing to print
  PUSH IX                 ; Save the start of the line
  LD (29027),IX           ; Remember the start of the line
  LD A,(IX+0)             ; A=the next character
  AND A                   ; Test it
  JR Z,29061              ; End of the text: the line ends here
  CALL 28698              ; Measure the next word
  LD D,A                  ; D=the width of the word
  LD A,B                  ; A=the width left on the line
  SUB D                   ; Subtract the word's width
  JR C,29061              ; It does not fit: the line ends before this word
  LD B,A                  ; B=the width left
  JR 29040                ; Try the next word
  POP DE                  ; DE=the start of the line
  PUSH BC                 ; Save the width left
  PUSH DE                 ; Save the start of the line
  PUSH HL                 ; Save the screen position
  LD HL,(29027)           ; HL=the end of the words that fit (where the next
                          ; word starts)
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Subtract the start: the number of characters on the
                          ; line
  LD A,L                  ; A=the character count
  POP HL                  ; Restore the screen position
  LD C,A                  ; C=the character count
  LD E,250                ; E=250: a counter for the spaces at the end of the
                          ; line
  LD D,254                ; D=254: a counter for the spaces at the start of the
                          ; line
  LD IX,(29027)           ; IX=the end of the line
  LD B,C                  ; B=the character count
  DEC IX                  ; Back up one character
  INC D                   ; Count it in D
  INC E                   ; Count three pixels in E for each space...
  INC E                   ; ...
  INC E                   ; ...
  LD A,(IX+0)             ; A=the character
  CP 32                   ; A space?
  JR NZ,29098             ; No: stop looking
  DJNZ 29083              ; Keep looking for spaces at the end
  POP IX                  ; IX=the start of the line
  DEC IX                  ; Step back one
  LD B,C                  ; B=the character count
  INC E                   ; Count three pixels in E for each space at the
                          ; start...
  INC E                   ; ...
  INC E                   ; ...
  INC D                   ; Count it in D
  INC IX                  ; Move on one character
  LD A,(IX+0)             ; A=the character
  CP 32                   ; A space?
  JR NZ,29118             ; No: stop looking
  DJNZ 29103              ; Keep looking for spaces at the start
  LD A,E                  ; A=the pixels to be trimmed
  LD E,C                  ; E=the character count
  POP BC                  ; Restore the width left
  ADD A,B                 ; Add it
  SRL A                   ; Halve it: this is the pixel offset that centres the
                          ; line
  ADD A,C                 ; Add the character count
  CP 8                    ; At least 8 pixels?
  JR C,29134              ; No: that is the pixel offset within the cell
  SUB 8                   ; Take off a character cell's 8 pixels
  INC L                   ; Move one cell right
  JR 29125                ; Repeat
  LD C,A                  ; C=the pixel offset within the first cell
  LD A,E                  ; A=the character count
  SUB D                   ; Take off the spaces to be skipped
  LD E,A                  ; E=the number of characters to print
  JR C,29153              ; None: nothing to print
  JR Z,29153              ; None: nothing to print
  LD A,(IX+0)             ; A=the character
  CALL PRINTCHAR          ; Print it in the proportional font
  INC IX                  ; Next character
  DEC E                   ; One fewer to print
  JR NZ,29142             ; Loop until the line is printed
  LD IX,(29027)           ; IX=the end of the line (the start of the next one)
  POP DE                  ; Restore DE
  POP AF                  ; Restore AF
  LD B,A                  ; B=A
  RET                     ; Return

; Work out the bubble shape for the text
;
; Chooses the smallest bubble (number of lines, B) into which the measured
; words will fit, using the line widths at 28728.
;
; Output:B Number of lines
  PUSH IX                 ; Save IX
  PUSH IY                 ; Save IY
  LD IX,24191             ; IX=just before the list of word widths (24192)
  LD IY,24192             ; IY=the list of word widths
  LD A,(IY+0)             ; A=a width
  INC IY                  ; Next one
  INC A                   ; The end marker is 255
  JR NZ,29173             ; Keep looking for it
  DEC IY                  ; IY=the end marker
  LD B,0                  ; B=0: no lines yet
  LD HL,28728             ; HL=the table of line widths (28728)
  LD C,0                  ; C=0: nothing in this line yet
  INC IX                  ; Next word from the front of the text
  LD A,(IX+0)             ; A=its width
  ADD A,C                 ; Add it to the line
  LD C,A                  ; C=the line width so far
  LD A,(HL)               ; A=the width allowed for this line
  CP C                    ; Does the word fit?
  JR NC,29190             ; Yes: try another
  DEC IX                  ; Back off the last word
  INC B                   ; One more line
  CALL 29236              ; Have the front and back met?
  JR NC,29231             ; Yes: finished
  LD C,0                  ; C=0: nothing in the line from the back
  DEC IY                  ; Back one word from the end
  LD A,(IY+0)             ; A=its width
  ADD A,C                 ; Add it to the line
  LD C,A                  ; C=the line width so far
  LD A,(HL)               ; A=the width allowed for this line
  CP C                    ; Does the word fit?
  JR NC,29211             ; Yes: try another
  INC B                   ; One more line (the last one, filled from the back)
  INC IY                  ; Put the word back
  INC HL                  ; Next width in the table (the next pair of lines is
                          ; wider)
  CALL 29236              ; Have the front and back met?
  JR C,29188              ; No: fill another line from the front
  POP IY                  ; Restore IY
  POP IX                  ; Restore IX
  RET                     ; Return

; Compare IX and IY
;
; Returns with the carry flag set if IX<IY.
  PUSH HL                 ; Save HL
  PUSH IX                 ; Save IX...
  POP HL                  ; ...in HL
  PUSH IY                 ; Save IY...
  POP DE                  ; ...in DE
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Subtract: carry set if IX is less than IY
  POP HL                  ; Restore HL
  RET                     ; Return

; Message control code jump table
;
; Addresses of the handlers for control codes 0-22 (used by RENDERITEM).
  DEFW 29570,29608,29570,29570
  DEFW 29621,29873,29570,29570
  DEFW 29897,29570,29810,29790
  DEFW 29570,29570,29570,29570
  DEFW 29570,29570,29570,29570
  DEFW 29570,29574,29594

; Measure the width of the text buffer
;
; Returns the total pixel width of the text at 23808 in HL.
  LD IX,23808             ; IX=the text buffer
  LD HL,0                 ; HL=0: the width so far
  LD A,(IX+0)             ; A=the next character
  AND A                   ; Test it
  RET Z                   ; End of the text: return
  EX DE,HL                ; DE=the width so far
  CALL CHARADDR           ; HL=the character's glyph address
  LD L,(HL)               ; L=the glyph width
  LD H,0                  ; H=0
  INC HL                  ; Add one pixel of spacing
  ADD HL,DE               ; Add the width so far
  INC IX                  ; Next character
  JR 29301                ; Loop

; The first-character flag
  DEFB 0

; Render a message into the text buffer
;
; Clears the buffer, renders the message at HL into it and then, if the text is
; too wide for one line, inserts a line break near the middle so that the
; bubble comes out roughly round.
;
; Input:HL Message address
RENDER:
  PUSH HL                 ; Save the message address
  XOR A                   ; A=0, to clear the first-character flag
  LD (29319),A            ; Clear the first-character flag
  LD HL,23808             ; Point the buffer pointer at the start of the text
                          ; buffer
  LD (29926),HL           ; Start the text buffer pointer at 23808
  POP IX                  ; IX=message address
  CALL 29452              ; Render the message into the buffer
  XOR A                   ; Terminate the buffer with a zero byte
  CALL 29509              ; Store the zero terminator in the buffer
  LD A,(33906)            ; Has the bubble layout changed since the last
                          ; message?
  AND A                   ; Test the layout-changed flag
  JR NZ,29445             ; Jump if so (the screen will be redrawn anyway)
  CALL 29294              ; HL=width of the new text in pixels
  LD DE,(33907)           ; DE=width of the previous text
  AND A                   ; Clear the carry flag for the subtraction
  SBC HL,DE               ; Is the new text at least as wide?
  JR NC,29445             ; Jump if so (the new bubble will cover the old one)
  LD DE,0                 ; Otherwise work out how many 3-pixel spaces are
                          ; needed...
  EX DE,HL                ; DE=0 (the new width), HL=old width
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; ...HL=old width-new width
  LD DE,3                 ; Spaces are 3 pixels wide
  LD BC,65535             ; BC will count the spaces
  INC BC                  ; Count one more space
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Divide by 3
  JR NC,29371             ; Loop while the width remaining is at least 3
  LD A,B                  ; Are any spaces needed?
  OR C                    ; Combine B and C to test BC for zero
  JR Z,29445              ; Jump if not
  PUSH BC                 ; Save the number of spaces
  SRL B                   ; Half of them go in front of the text
  RR C                    ; Half the count in BC (carry out of B into C)
  LD HL,(29926)           ; HL=address of the terminator
  DEC HL                  ; HL=address of the last character
  LD E,L                  ; DE=HL: the address of the last character...
  LD D,H                  ; DE=HL
  ADD HL,BC               ; Move the end of the text along by BC
  LD (29926),HL           ; Update the buffer pointer
  EX DE,HL                ; HL=last character, DE=its new position
  LD BC,23807             ; BC=length of the text
  AND A                   ; Clear the carry flag
  SBC HL,BC               ; HL=length of the text in the buffer (counted down
                          ; from the end)
  PUSH HL                 ; Keep the length
  ADD HL,BC               ; HL=address of the last character again
  POP BC                  ; BC=length, ready for LDDR
  LDDR                    ; Shift the text right to make room for the leading
                          ; spaces
  POP BC                  ; Restore the total number of spaces
  LD HL,(29926)           ; HL=end of the text
  LD DE,23808             ; DE=start of the buffer
  LD A,B                  ; Fill in pairs of spaces...
  AND A                   ; Test the high byte of the count
  JR NZ,29427             ; Jump if at least 256 left
  LD A,C                  ; A=low byte of the count
  AND A                   ; Test it for zero
  JR Z,29440              ; Jump if none left
  CP 1                    ; Just one left?
  JR Z,29437              ; Jump if so
  LD A,32                 ; Put a space at the front...
  LD (DE),A               ; Space at the start of the buffer
  LD (HL),A               ; ...and one at the end
  INC DE                  ; Next position at the front
  INC HL                  ; Next position at the end
  DEC BC                  ; One fewer space to place...
  DEC BC                  ; Two fewer spaces to place
  JR 29415                ; Loop back for the next pair
  LD (HL),32              ; Put the odd space at the end
  INC HL                  ; Step over the odd space
  LD (HL),0               ; Terminate the text
  LD (29926),HL           ; Update the buffer pointer
  CALL 29294              ; Measure the final text...
  LD (33907),HL           ; ...and remember its width for next time
  RET                     ; Return with HL=the final width

; Render a message
;
; Calls RENDERITEM for each item until the end of the message.
;
; Input:IX Message
  CALL RENDERITEM         ; Render one item
  JR NZ,29452             ; Repeat until an item ends the message
  RET                     ; Done: the message has been rendered

; Render one message item
;
; A message is a sequence of items:
;
; +------------+-------------------------------------------------------------+
; | Byte(s)    | Meaning                                                     |
; +------------+-------------------------------------------------------------+
; | 0-31       | Control code (see the table at 29248)                       |
; | 32-95      | Literal character (letters are converted to lower case)     |
; | 96-127     | Common word: index into the table at 49710                  |
; | 128-255, n | Dictionary word at 48640+((b AND 15)*256)+n; bits 4-6 of b: |
; |            | 7 = capitalise, 2 or 6 = last word, 3 = last word plus a    |
; |            | full stop                                                   |
; +------------+-------------------------------------------------------------+
;
; Returns with the zero flag set at the end of the message.
;
; Input:IX Item Output:IX Next item
RENDERITEM:
  LD A,(IX+0)             ; Pick up the first byte of the item
  BIT 7,A                 ; Is it a two-byte dictionary reference?
  JR Z,29495              ; Jump if not
  AND 127                 ; D=first byte without bit 7 (bits 0-3: page; bits
                          ; 4-6: type)
  LD D,A                  ; D=the type and page
  LD E,(IX+1)             ; E=offset into the page
  INC IX                  ; Point IX at the second byte
  AND 240                 ; Keep the type bits
  CP 48                   ; Type 3 (last word plus full stop)?
  JR Z,29578              ; Jump if so
  CP 32                   ; Type 2 (last word)?
  JR Z,29578              ; Jump if so
  CP 96                   ; Type 6 (last word)?
  JR Z,29578              ; Jump if so
  CALL DICTWORD           ; Print the dictionary word
  INC IX                  ; Move IX to the next item
  OR 1                    ; Reset the zero flag: the message continues
  RET                     ; Done: NZ means the message goes on
  CP 32                   ; Is it a control code (0-31)?
  JR C,29544              ; Jump if so
  CP 96                   ; Is it a common word (96-127)?
  JP NC,29907             ; Jump if so
  CALL 29509              ; Otherwise it is a literal character: put it in the
                          ; buffer
  JR 29490                ; And move on

; Put a character into the text buffer (converting to lower case)
;
; Converts A-Z to a-z first.
  CP 65                   ; Is it an upper case letter?
  JR C,29519              ; Below A: not a capital, store as it is
  CP 91                   ; Above Z?
  JR NC,29519             ; Yes: store as it is
  SET 5,A                 ; Convert it to lower case (which the font draws as
                          ; small capitals)

; Put a character into the text buffer
;
; Stores A at the buffer pointer (29926). A space as the very first character
; is suppressed.
  PUSH HL                 ; Save HL
  LD HL,(29926)           ; HL=buffer pointer
  LD (HL),A               ; Store the character
  LD A,(29319)            ; Has anything been stored yet?
  AND A                   ; Test the first-character flag
  LD A,(HL)               ; A=the character
  JR NZ,29538             ; Jump if so: advance the pointer
  LD (29319),A            ; Note that something has been stored
  CP 32                   ; Is the first character a space?
  JR Z,29539              ; Jump if so: do not advance, so the next character
                          ; overwrites it
  INC HL                  ; Advance the buffer pointer
  LD (29926),HL           ; Store the updated buffer pointer
  POP HL                  ; Restore HL
  RET                     ; Done
  PUSH DE                 ; Save DE
  LD E,A                  ; DE=control code
  LD D,0                  ; DE=code
  LD HL,29248             ; Point HL at the control code jump table
  ADD HL,DE               ; Add the code once...
  ADD HL,DE               ; Add 2*code
  LD E,(HL)               ; Pick up the handler address
  INC HL                  ; Next byte of the table entry
  LD D,(HL)               ; D=high byte of the handler address
  EX DE,HL                ; HL=handler address
  POP DE                  ; Restore DE
  CP 20                   ; Codes 20 and above...
  JR NC,29569             ; ...are jumped to directly (they end the message)
  CALL 29569              ; Codes 0-19 are called
  JR Z,29490              ; Zero flag set: the handler has done its work; move
                          ; on
  JR 29487                ; Otherwise print the dictionary word in DE

; Jump to a control code handler
;
; JP (HL).
  JP (HL)                 ; Jump to the handler

; Control codes 0, 2, 3, 6, 7, 9 and 12-20 (no-op)
  LD D,96                 ; D=96 (as for a type 6 last word)
  JR 29581                ; End the message without a full stop

; Control code 21: full stop and end
  LD D,48                 ; D=48 (as for a type 3 last word)
  JR 29581                ; End the message with a full stop
  CALL DICTWORD           ; Print the last word
  LD A,46                 ; A=full stop
  BIT 6,D                 ; Type 6?
  JR NZ,29594             ; Jump if so: no full stop
  BIT 4,D                 ; Type 3?
  CALL NZ,29509           ; Print the full stop if so
  BIT 4,D                 ; Test bit 4 of D again

; Control code 22: end
  XOR A                   ; Set the zero flag: end of message
  RET                     ; Done

; Control codes 1/4: fetch a variable from the VM stream
;
; Reads a variable number from the VM byte stream (not the message!) and loads
; that variable into BCDE, then puts a space in the buffer.
  CALL FETCHBYTE          ; Fetch a variable number from the VM byte stream
  LD L,A                  ; L=variable number
  CALL LOADVAR            ; Load the variable into BCDE
  LD A,32                 ; A=space
  JP 29509                ; Put a space in the buffer

; Control code 1: print " $" and a variable
  CALL 29596              ; Fetch the variable and put a space in the buffer
  LD A,36                 ; A="$"
  CALL 29509              ; Put it in the buffer
  CALL PRINTNUM           ; Print the number
  XOR A                   ; Set the zero flag: control code done
  RET                     ; Done

; Control code 4: print " " and a variable
  CALL 29596              ; Fetch the variable and put a space in the buffer
  CALL PRINTNUM           ; Print the number
  XOR A                   ; Set the zero flag: control code done
  RET                     ; Done

; The leading-zero flag
  DEFB 240

; Print a number
;
; Prints the signed fixed-point value in BCDE in decimal (without leading
; zeros), adding a decimal point and two decimal places only if the fractional
; part is non-zero.
;
; Input:BCDE Number (x100)
PRINTNUM:
  BIT 7,B                 ; Is the number negative?
  JR Z,29642              ; Jump if not
  CALL 30634              ; Make it positive
  LD A,45                 ; A="-"
  CALL 29509              ; Put the minus sign in the buffer
  PUSH BC                 ; Copy the high word (BC) into HL'
  EXX                     ; Switch to the alternate registers...
  POP HL                  ; ...HL'=high word of the number...
  EXX                     ; ...and back again
  EX DE,HL                ; HL=low word
  XOR A                   ; Leading zeros are not printed yet
  LD (29629),A            ; Clear the leading-zero flag
  LD BC,15258             ; BC/DE=1,000,000,000 (the number is in hundredths,
                          ; so this is ten million)
  LD DE,51712             ; DE=low word of the divisor 1,000,000,000
  CALL 29752              ; Print that digit
  LD BC,1525              ; BC/DE=100,000,000
  LD DE,57600             ; DE=low word of 100,000,000
  CALL 29752              ; Print the millions digit
  LD BC,152               ; BC/DE=10,000,000
  LD DE,38528             ; DE=low word of 10,000,000
  CALL 29752              ; Print the hundred-thousands digit
  LD BC,15                ; BC/DE=1,000,000
  LD DE,16960             ; DE=low word of 1,000,000
  CALL 29752              ; Print the ten-thousands digit
  LD BC,1                 ; BC/DE=100,000
  LD DE,34464             ; DE=low word of 100,000
  CALL 29752              ; Print the thousands digit
  LD BC,0                 ; BC/DE=10,000
  LD DE,10000             ; DE=10,000
  CALL 29752              ; Print the hundreds digit
  LD BC,0                 ; BC/DE=1,000 (tens)
  LD DE,1000              ; DE=1,000
  CALL 29752              ; Print the tens digit
  LD A,1                  ; From now on zeros are printed (so 0 comes out as
                          ; "0")
  LD (29629),A            ; Set the leading-zero flag
  LD BC,0                 ; BC/DE=100 (units)
  LD DE,100               ; DE=100
  CALL 29752              ; Print the units digit
  LD A,L                  ; Is there a fractional part?
  OR H                    ; Combine with H to test the fraction
  RET Z                   ; Return if not: whole numbers have no decimal point
  LD A,46                 ; A="."
  CALL 29509              ; Put the decimal point in the buffer
  LD BC,0                 ; BC/DE=10 (tenths)
  LD DE,10                ; DE=10
  CALL 29752              ; Print the tenths digit
  LD A,L                  ; A=hundredths digit
  ADD A,48                ; Convert it to ASCII
  CALL 29509              ; Put it in the buffer
  RET                     ; Done

; Print one decimal digit
;
; Subtracts the power of ten in BC/DE from the number in HL'/HL repeatedly to
; work out the digit.
  PUSH BC                 ; Copy the high word of the power of ten into DE'
  EXX                     ; Switch to the alternate registers...
  POP DE                  ; ...DE'=high word of the power of ten...
  EXX                     ; ...and back again
  LD C,47                 ; C will count from "0"
  INC C                   ; Next digit value
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Subtract the power of ten (low word)...
  EXX                     ; Switch to the high words...
  SBC HL,DE               ; ...and high word
  EXX                     ; ...and back
  JR NC,29758             ; Repeat until the number goes negative
  ADD HL,DE               ; Add the power of ten back on (low word)...
  EXX                     ; Switch to the high words...
  ADC HL,DE               ; ...and high word
  EXX                     ; ...and back
  LD A,(29629)            ; Has a non-zero digit been printed yet?
  AND A                   ; Test the leading-zero flag
  LD A,C                  ; A=digit
  JP NZ,29509             ; Print it if so
  CP 48                   ; Is it a leading zero?
  RET Z                   ; Skip it if so
  LD (29629),A            ; Otherwise leading zeros are over
  JP 29509                ; Print the digit

; Control code 11: repeat earlier text
;
; The next byte is an offset back (n-256) to some text earlier in the message
; area, which is rendered up to its own end marker. This saves space where
; messages share phrases.
  PUSH IX                 ; Save the message pointer
  LD E,(IX+1)             ; E=offset (as a negative number: the text is earlier
                          ; in memory)
  LD D,255                ; D=255, so DE is a negative offset
  ADD IX,DE               ; IX=address of the earlier text
  CALL 29452              ; Render it until its own end marker
  POP IX                  ; Restore the message pointer
  INC IX                  ; Skip the offset byte
  XOR A                   ; Set the zero flag: code done
  RET                     ; Done

; The random-choice counter
  DEFB 0,0

; Control code 10: random choice
;
; The next byte is the number of alternatives n, followed by n single items
; (one or two bytes each). One item is chosen at random and rendered. This is
; how Louey varies his patter ("[What wuz dat, Boss? I missed it/It's okay,
; Boss - this line aint tapped...]").
  INC IX                  ; Point at the number of alternatives
  LD A,(IX+0)             ; A=the number of alternatives
  LD (29808),A            ; Store it as the counter
  DEC A                   ; A=n-1
  CALL RANDOMPM           ; Pick a random number 0..n-1
  INC A                   ; A=1..n
  LD (29809),A            ; Store the choice
  INC IX                  ; Point at the first alternative
  LD A,(29809)            ; Is this the chosen alternative?
  LD HL,29808             ; HL=the counter of alternatives still to skip
  CP (HL)                 ; Is this the chosen one?
  JR NZ,29844             ; Jump if not
  PUSH IX                 ; Keep the message pointer
  CALL RENDERITEM         ; Render it
  POP IX                  ; Restore the message pointer
  LD A,(IX+0)             ; Get the first byte of this alternative
  BIT 7,A                 ; A dictionary word (2 bytes)?
  JR NZ,29859             ; Jump if so
  CP 2                    ; Control code 2 (2 bytes)?
  JR Z,29859              ; Two-byte item: skip both bytes
  CP 11                   ; Control code 11 (2 bytes)?
  JR NZ,29861             ; Jump if not
  INC IX                  ; Skip the second byte
  INC IX                  ; Skip the first byte
  LD HL,29808             ; Count down the alternatives
  DEC (HL)                ; One alternative fewer to go
  JR NZ,29828             ; Jump back for the next one
  DEC IX                  ; Point at the last byte (the caller moves on)
  XOR A                   ; Set the zero flag: code done
  RET                     ; Done: the zero flag tells the caller the message
                          ; continues

; Control code 5: insert a sub-message
;
; Takes a message address from the VM byte stream (or uses the default set by
; SETMSG/26740 if it is 0) and renders it.
  CALL FETCHWORD          ; Fetch a message address from the VM byte stream
  EX DE,HL                ; DE=address
  LD A,D                  ; Is it 0?
  OR E                    ; Combine with E: is the address zero?
  JR NZ,29885             ; Jump if not
  LD DE,(33898)           ; Otherwise use the default set by SETMSG
  PUSH IX                 ; Save the message pointer
  PUSH DE                 ; Keep the sub-message address
  POP IX                  ; IX=sub-message
  CALL 29452              ; Render it
  POP IX                  ; Restore the message pointer
  XOR A                   ; Set the zero flag: code done
  RET                     ; Done

; Control code 8 handler (broken backspace)
;
; The handler for message control code 8, which was evidently meant to be a
; backspace: it steps the text buffer pointer (29926) back one character so
; that the next character overwrites the last. The jump table at 29248 points
; here. These bytes are Z80 code; each comment gives the instruction.
;
; It is broken. The first instruction, PUSH HL, is never undone, and the
; dispatcher (29544) has just put the handler's own address in HL, so the final
; RET goes back to the start of the handler. The handler then runs a second
; time and this time returns to 23807, one byte before the start of the text
; buffer (23808), and executes whatever is there as code. Run in the simulator,
; the buffer pointer dropped by two and the call never returned. No message in
; the game uses code 8, so nobody ever sees it (see the bugs page).
  DEFB 229                ; PUSH HL: the stray instruction (nothing ever pops
                          ; it)
  DEFB 42,230,116         ; LD HL,(29926): HL=the text buffer pointer
  DEFB 43                 ; DEC HL: step back one character
  DEFB 34,230,116         ; LD (29926),HL: store the new pointer
  DEFB 175                ; XOR A: set the zero flag (code done)
  DEFB 201                ; RET: return, but to the wrong place because of the
                          ; PUSH HL

; Expand a common word
;
; Byte values 96-127 index the table of common words at 49710 (values from 128
; are two-byte dictionary references and never reach this routine).
  SUB 96                  ; A=index (0-31)
  LD E,A                  ; E=the index
  LD D,0                  ; DE=index
  LD HL,49710             ; Point HL at the table of common words
  ADD HL,DE               ; Add the index once...
  ADD HL,DE               ; Add 2*index
  LD E,(HL)               ; E=offset
  INC HL                  ; Next byte of the table entry
  LD A,(HL)               ; A=page
  ADD A,80                ; Add 80 (type 5: an ordinary word)
  LD D,A                  ; D=page and type
  JP 29487                ; Print the word

; The text buffer pointer
  DEFB 0,0

; Expand a dictionary word
;
; Words are stored one byte per letter, of which only the low 5 bits count (1=a
; ... 26=z, 27-31 punctuation), in the dictionary at 48640. Bit 7 marks the
; last letter, except on the second letter, or the third if the second also has
; bit 7 set; this lets short words overlap the starts of longer ones.
;
; Input:D Bits 0-3: dictionary page; bits 4-6: type
;       E Offset
DICTWORD:
  LD A,D                  ; Is the reference zero (no word)?
  AND 15                  ; Keep only the page number (low 4 bits of D)...
  OR E                    ; ...and combine it with the offset in E: zero means
                          ; no word at all
  RET Z                   ; Return if so
  PUSH HL                 ; Save HL...
  PUSH BC                 ; ...BC...
  PUSH DE                 ; ...and DE
  LD C,D                  ; C=type
  LD A,D                  ; A=the type and page byte
  AND 15                  ; D=page (0-15)
  LD D,A                  ; D=page, so DE=256*page+offset
  LD HL,48640             ; HL=48640+256*page+offset
  ADD HL,DE               ; HL=the address of the word's text
  LD DE,(29926)           ; DE=where the next character goes in the text buffer
  LD A,32                 ; Put a space before the word
  CALL 29519              ; Put the space in the buffer
  LD A,(HL)               ; First letter: low 5 bits
  INC HL                  ; Step on to the second letter
  AND 31                  ; Keep the low 5 bits (1-26 = A-Z)
  OR 96                   ; Convert to a lower case letter
  LD B,A                  ; B=letter
  LD A,C                  ; Is this a capitalised word (type 7)?
  AND 240                 ; Look at the type nibble only
  CP 112                  ; Is it type 7 (capitalised word)?
  JR NZ,29970             ; Jump if not
  RES 5,B                 ; Make the letter upper case
  LD A,B                  ; A=the first letter, upper or lower case
  CALL 29519              ; Put the first letter in the buffer
  LD B,1                  ; B counts the letters
  LD A,(HL)               ; Next letter
  AND 31                  ; Keep the low 5 bits of the next letter
  JR Z,30010              ; A zero letter ends the word
  INC B                   ; Count it
  ADD A,96                ; Convert to a lower case letter
  CALL 29519              ; Put it in the buffer
  BIT 7,(HL)              ; Does bit 7 mark the end of the word?
  INC HL                  ; Step on to the next byte
  JR Z,29976              ; Carry on if not
  LD A,B                  ; Bit 7 is ignored on the second letter...
  CP 2                    ; Is this the second letter?
  JR Z,29976              ; Yes: its end bit is ignored, so carry on
  CP 3                    ; ...and on the third...
  JR NZ,30010             ; Finished if this is the fourth letter or later
  DEC HL                  ; ...if the second letter also had bit 7 set
  DEC HL                  ; Step back two bytes to the second letter...
  LD A,(HL)               ; ...and pick it up
  INC HL                  ; Step forward again...
  INC HL                  ; ...to the byte after the third letter
  BIT 7,A                 ; Did the second letter have its end bit set?
  JR NZ,29976             ; Carry on if so
  POP DE                  ; Restore DE...
  POP BC                  ; ...BC...
  POP HL                  ; ...and HL
  RET                     ; Done: the word is in the text buffer

; Get a random number between 0 and n
;
; Calls RANDOM (which returns -n..n) and negates a negative result, so the
; result is always 0..n. Because of the way RANDOM folds large values, the
; result is not uniform: for n=100, the values 1-27 are twice as likely as the
; others (raw bytes above 200 are halved, which lands them just above n).
;
;  Input:A n
; Output:A Random number
RANDOMPM:
  CALL RANDOM             ; Get a random number 0..A
  BIT 7,A                 ; Is bit 7 of the result set?
  RET Z                   ; Return if not
  NEG                     ; Otherwise negate it
  RET                     ; Done: A=0..limit

; The random number pointer
  DEFB 0,80,0

; Get a random number
;
; Steps a pointer through the code of the program itself (30023) and mixes the
; bytes it finds, ensuring that the same value never comes up twice in a row,
; halves it until it is no more than 2*A, and subtracts A, giving a number
; between -A and A.
;
;  Input:A Upper limit
; Output:A Random number
RANDOM:
  PUSH IX                 ; Save IX
  PUSH BC                 ; Save BC
  LD C,A                  ; C=upper limit
  SLA A                   ; Double it for the mask comparison
  JR NC,30036             ; The doubled limit fits in a byte
  LD A,255                ; Limit to 255
  LD B,A                  ; B=limit*2
  LD IX,30023             ; Point IX at the random number pointer
  INC (IX+1)              ; Step the pointer on by 256 bytes (increment its
                          ; high byte)...
  JR NZ,30049             ; No wrap-round: carry on
  INC (IX+0)              ; ...and the low byte too if the high byte wrapped
  LD IX,(30023)           ; IX=the pointer (which wanders through the whole of
                          ; memory)
  LD A,(30025)            ; Pick up the last random number
  ADC A,(IX+0)            ; Add the byte at the pointer
  ADD IX,DE               ; Step on by DE (whatever DE happens to hold)
  XOR (IX+1)              ; Mix in another byte
  PUSH HL                 ; Save HL
  LD HL,30025             ; Is the new number the same as the last one?
  CP (HL)                 ; Same as the previous number?
  POP HL                  ; Restore HL
  JR Z,30037              ; Try again if so
  LD (30025),A            ; Store the new random number
  CP B                    ; Halve it until it is no greater than 2*limit
  JR C,30085              ; Within range: done
  JR Z,30085              ; Exactly equal to the limit: done
  SRL A                   ; Halve the number
  JP 30075                ; Check again
  SUB C                   ; Subtract the limit (giving -limit..+limit)
  POP BC                  ; Restore BC
  POP IX                  ; Restore IX
  RET                     ; Done: A=a random number from -limit to +limit

; The VM program counter
  DEFB 0,0

; Run a VM script
;
; The game logic is written in a compact interpreted language. IY points at the
; first instruction; instructions are executed until op 0 (END). See the VM
; reference page for the full instruction set. The flags returned by each
; instruction are preserved (PUSH AF/POP AF) so that op 12 (JZ) can test the
; result of a native routine called by op 14.
;
; Input:IY Script address
RUNVM:
  LD (30090),IY           ; Set the VM program counter
  PUSH AF                 ; Save the flags from the previous instruction
  CALL FETCHBYTE          ; Fetch the opcode
  ADD A,A                 ; Double it for the jump table at 30123
  LD HL,30123             ; HL=start of the VM jump table
  ADD A,L                 ; Add the doubled opcode to L...
  LD L,A                  ; L=the low byte of the entry address
  LD A,0                  ; Prepare to add the carry to H...
  ADC A,H                 ; ...A=H+carry
  LD H,A                  ; HL=entry in the jump table
  LD A,(HL)               ; Pick up the handler address
  INC HL                  ; Next byte of the entry
  LD H,(HL)               ; H=high byte of the handler address
  LD L,A                  ; L=low byte: HL=handler
  POP AF                  ; Restore the flags from the previous instruction
  CALL 30122              ; Execute the instruction
  JR 30096                ; Back for the next one

; VM op 0: END
  POP HL                  ; Op 0 (END): drop the return address to 30118...
  RET                     ; ...and return from the interpreter

; Jump to the address in HL
  JP (HL)                 ; Jump to the opcode handler

; VM opcode jump table
;
; Addresses of the handlers for VM opcodes 0-34 (used by RUNVM).
  DEFW 30120,30225,30231,30238
  DEFW 30246,30252,30258,30265
  DEFW 30271,30279,30289,30299
  DEFW 30307,30313,30318,30335
  DEFW 30441,30433,30438,30464
  DEFW 30456,30461,30657,30649
  DEFW 30654,30707,30712,30580
  DEFW 31197,30482,30479,30634
  DEFW 30488,30511,30508

; Compare two variables and fetch a jump address
;
; Used by ops 3-8.
;
; Output:F Flags of (second variable - first variable)
;        HL Jump address
  CALL COMPARE            ; Compare the variable in the next byte with the one
                          ; in the byte after

; Fetch a word from the VM stream
;
; Flags are preserved.
;
; Output:HL Word
FETCHWORD:
  PUSH AF                 ; Save the flags
  LD HL,(30090)           ; Pick up the VM program counter
  LD A,(HL)               ; Fetch the low byte
  INC HL                  ; Step past the low byte...
  INC HL                  ; ...and the high byte
  LD (30090),HL           ; Advance the program counter by 2
  DEC HL                  ; Back to the high byte
  LD H,(HL)               ; Fetch the high byte
  LD L,A                  ; HL=word
  POP AF                  ; Restore the flags
  RET                     ; Done: HL=the 16-bit operand

; Fetch a word and then a byte from the VM stream
;
; Output:HL Word A Byte
  CALL FETCHWORD          ; Fetch a word into HL first

; Fetch a byte from the VM stream
;
; Output:A Byte
FETCHBYTE:
  PUSH HL                 ; Save HL
  LD HL,(30090)           ; Pick up the VM program counter
  LD A,(HL)               ; Fetch the byte
  INC HL                  ; Advance the program counter
  LD (30090),HL           ; Advance the program counter
  POP HL                  ; Restore HL
  RET                     ; Done: A=the byte

; VM op 1: SAY
  CALL 30211              ; Op 1 (SAY): fetch the message address (HL) and the
                          ; flags (A)
  JP SAY                  ; Show the speech bubble

; VM op 2: SETMSG
  CALL FETCHWORD          ; Op 2 (SETMSG): fetch a message address
  LD (33898),HL           ; Make it the default sub-message for control code 5
  RET                     ; Done

; VM op 3: IFEQ
  CALL 30193              ; Op 3 (IFEQ): compare the variables
  RET NZ                  ; Return unless they are equal
  LD (30090),HL           ; Jump: set the VM program counter to HL
  RET                     ; Done

; VM op 4: IFNE
  CALL 30193              ; Op 4 (IFNE)
  RET Z                   ; Return if the variables are equal
  JR 30242                ; Otherwise jump

; VM op 5: IFLE
  CALL 30193              ; Op 5 (IFLE)
  RET C                   ; Return if the second variable is less than the
                          ; first
  JR 30242                ; Otherwise jump

; VM op 6: IFLT
  CALL 30193              ; Op 6 (IFLT)
  RET Z                   ; Return if the variables are equal...
  RET C                   ; ...or if the second is less than the first
  JR 30242                ; Otherwise jump

; VM op 7: IFGT
  CALL 30193              ; Op 7 (IFGT)
  RET NC                  ; Return unless the second variable is less than the
                          ; first
  JR 30242                ; Otherwise jump

; VM op 8: IFGE
  CALL 30193              ; Op 8 (IFGE)
  JR Z,30242              ; Jump if the variables are equal
  RET NC                  ; Return if the second variable is greater
  JR 30242                ; Otherwise jump

; VM op 9: IFPEEKEQ
  CALL 30211              ; Op 9 (IFPEEKEQ): fetch an address and a byte
  CP (HL)                 ; Compare the byte at the address
  CALL FETCHWORD          ; Fetch the jump address
  RET NZ                  ; Return unless equal
  JR 30242                ; Otherwise jump

; VM op 10: IFPEEKNE
  CALL 30211              ; Op 10 (IFPEEKNE): fetch an address and a byte
  CP (HL)                 ; Compare the byte at the address
  CALL FETCHWORD          ; Fetch the jump address
  RET Z                   ; Return if equal
  JR 30242                ; Otherwise jump

; VM op 11: POKE
  CALL FETCHBYTE          ; Op 11 (POKE): fetch the byte
  CALL FETCHWORD          ; Fetch the address
  LD (HL),A               ; POKE it
  RET                     ; Done

; VM op 12: JZ
  CALL FETCHWORD          ; Op 12 (JZ): fetch the jump address (preserving the
                          ; flags)
  RET NZ                  ; Return if the zero flag is reset
  JR 30242                ; Otherwise jump

; VM op 13: GOTO
  CALL FETCHWORD          ; Op 13 (GOTO): fetch the jump address
  JR 30242                ; And jump

; VM op 14: CALL
  LD HL,(30090)           ; Op 14 (CALL): save the address of the operand
  PUSH HL                 ; Keep the address of the operand
  CALL FETCHWORD          ; Fetch the address of the native routine
  CALL 30122              ; Call it
  POP HL                  ; Restore the address of the operand
  INC HL                  ; Step past the first byte of the operand...
  INC HL                  ; Skip the operand
  LD (30090),HL           ; Set the VM program counter (anything the native
                          ; routine fetched is ignored)
  RET                     ; Done

; VM op 15: STORE
  CALL FETCHBYTE          ; Op 15 (STORE): fetch the variable number
  LD L,A                  ; L=the variable number
  JP STOREVAR             ; Store BCDE in it

; Compare BCDE with a variable
;
; Compares the value in BCDE with the variable whose number is the next byte in
; the VM stream.
;
;  Input:BCDE First value
; Output:F Zero set if equal; carry set if the variable is less than BCDE
COMPARE:
  CALL 31197              ; BCDE=first variable
  CALL FETCHBYTE          ; Fetch the number of the second variable
  LD L,A                  ; L=the variable number
  LD H,0                  ; HL=variable number
  ADD HL,HL               ; HL=2*variable
  ADD HL,HL               ; HL=4*variable number
  PUSH DE                 ; Save the low word of the first value
  LD DE,33552             ; Point IY at the second variable
  ADD HL,DE               ; HL=address of the second variable
  POP DE                  ; Restore DE
  PUSH HL                 ; Copy HL into IY...
  POP IY                  ; ...by way of the stack
  LD A,B                  ; Is the first value zero?
  OR C                    ; Combine C into the zero test...
  OR D                    ; ...and D...
  OR E                    ; ...and E
  JR Z,30396              ; Jump if so
  LD A,(IY+3)             ; Do the signs differ?
  XOR B                   ; Compare the sign bits: XOR the top bytes
  AND 128                 ; Keep just the sign bit
  JR NZ,30417             ; Jump if so
  LD A,(IY+3)             ; Same sign: compare the high bytes
  CP B                    ; Compare the top bytes
  RET NZ                  ; Return if they differ (carry set if the second is
                          ; lower)
  LD A,(IY+2)             ; Compare the next bytes
  CP C                    ; Compare the next bytes
  RET NZ                  ; Different: that decides it
  LD A,(IY+1)             ; Next byte of the second value
  CP D                    ; Compare with D
  RET NZ                  ; Different: that decides it
  LD A,(IY+0)             ; Compare the low bytes
  CP E                    ; Compare the lowest bytes
  RET                     ; Return with the flags: Z=equal, C=second is smaller
  BIT 7,(IY+3)            ; First value is zero: is the second negative?
  JR Z,30404              ; Jump if not
  SCF                     ; Carry set: second < first
  RET                     ; Return with carry set
  LD A,(IY+3)             ; Set the zero flag if the second is also zero
  OR (IY+2)               ; OR in the next byte...
  OR (IY+1)               ; ...and the next...
  OR (IY+0)               ; ...and the lowest
  RET                     ; Return (the carry flag is reset by OR)
  BIT 7,B                 ; Signs differ: is the first value negative?
  RET NZ                  ; Return (zero and carry reset: second > first) if so
  OR 1                    ; Otherwise reset the zero flag...
  SCF                     ; ...and set the carry flag: second < first
  RET                     ; Return with NZ and carry set

; Load two variables
;
; Loads the variable named by the next VM byte into BCDE and the one after into
; BC'DE'.
  CALL 31197              ; BCDE=first operand

; Load the second operand
;
; Loads the variable named by the next VM byte into BC'DE'.
  EXX                     ; Switch to the second register set
  CALL 31197              ; BC'DE'=second operand
  EXX                     ; Back to the main registers
  RET                     ; Done: BCDE=first operand, BC'DE'=second

; VM op 17: ADD v
  CALL 30427              ; Load the operand into BC'DE'
  JR 30441                ; Add

; VM op 18: ADD v,v
  CALL 30424              ; Load the two operands into BCDE and BC'DE'

; VM op 16: ADD (BCDE=BCDE+BC'DE')
  PUSH BC                 ; Add the low words...
  PUSH DE                 ; ...and the low word
  EXX                     ; Switch to the second operand
  POP HL                  ; HL=low word of the first operand
  AND A                   ; Clear the carry flag
  ADC HL,DE               ; Add the low words
  EX (SP),HL              ; HL=high word of the first operand; the low sum goes
                          ; on the stack
  ADC HL,BC               ; ...and the high words with carry
  PUSH HL                 ; Keep the high sum
  EXX                     ; Back to the main registers
  POP BC                  ; BC=high word of the sum
  POP DE                  ; DE=low word
  RET                     ; Done: BCDE=the sum

; VM op 20: SUB v
  CALL 30427              ; Load the operand into BC'DE'
  JR 30464                ; Subtract

; VM op 21: SUB v,v
  CALL 30424              ; Load the two operands into BCDE and BC'DE'

; VM op 19: SUB
  PUSH BC                 ; Subtract the low words...
  PUSH DE                 ; Keep the low word
  EXX                     ; Switch to the second operand
  POP HL                  ; HL=low word of the first operand
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Subtract the low words
  EX (SP),HL              ; HL=high word of the first operand; the low
                          ; difference goes on the stack
  SBC HL,BC               ; ...and the high words with borrow
  PUSH HL                 ; Keep the high difference
  EXX                     ; Back to the main registers
  POP BC                  ; BC=high word of the difference
  POP DE                  ; DE=low word
  RET                     ; Done: BCDE=the difference

; VM op 30: RND v
  CALL 31197              ; Load the operand

; VM op 29: RND (replace E with a random number 0..E)
;
; Only the low byte of the accumulator is changed, so RND behaves oddly on
; values of 2.56 or more. The script only ever uses RND v71 (1.00), giving a
; random number between 0 and 1.00.
  LD A,E                  ; A=low byte
  CALL RANDOMPM           ; Replace it with a random number 0..A
  LD E,A                  ; E=the random number
  RET                     ; Done

; VM op 32: HALF v
  CALL 31197              ; Load the operand

; Halve BCDE (arithmetic shift right)
  SRA B                   ; Halve BCDE
  RR C                    ; Shift C right with the carry from B
  RR D                    ; ...D...
  RR E                    ; ...and E
  RET                     ; Done: BCDE=BCDE/2

; Square root workspace
;
; Used by the square root routine at 30511. Both values are 32-bit numbers in
; hundredths.
  DEFB 0,0,0,0            ; The current estimate x (30500-30503)
  DEFB 0,0,0,0            ; The argument n (30504-30507)

; VM op 34: SQRT v (BCDE=square root of a variable)
  CALL 31197              ; Load the operand

; VM op 33: SQRT (Newton's method; never terminates for some values; see the
; bugs page)
  LD (30504),DE           ; Store the argument n
  LD (30506),BC           ; Store the top word of the argument
  CALL 30491              ; First estimate: x=n/2
  LD (30500),DE           ; Store the estimate x
  LD (30502),BC           ; Store the top word of the estimate
  EXX                     ; Switch to the alternate registers (BC'DE' will hold
                          ; x)
  LD DE,(30504)           ; BCDE=n
  LD BC,(30506)           ; BC=top word of n
  CALL 30715              ; BCDE=n/x (BC'DE' holds x)
  EXX                     ; Back to the main registers
  LD DE,(30500)           ; BCDE=x
  LD BC,(30502)           ; BC=top word of x
  CALL 30441              ; Add n/x
  CALL 30491              ; Halve: the new estimate is (x+n/x)/2
  LD HL,30500             ; Compare it with the previous estimate
  LD A,(HL)               ; A=byte 0 of the previous estimate
  CP E                    ; Same as E?
  JR NZ,30522             ; Try again if different
  INC HL                  ; Next byte
  LD A,(HL)               ; A=byte 1 of the previous estimate
  CP D                    ; Same as D?
  JR NZ,30522             ; Not the same: do another iteration
  INC HL                  ; Next byte
  LD A,(HL)               ; A=byte 2 of the previous estimate
  CP C                    ; Same as C?
  JR NZ,30522             ; Not the same: do another iteration
  INC HL                  ; Next byte
  LD A,(HL)               ; A=byte 3 of the previous estimate
  CP B                    ; Same as B?
  JR NZ,30522             ; Try again if different (for some arguments the
                          ; estimates alternate for ever)
  RET                     ; Return with the square root in BCDE

; VM op 27: INT
  CALL 30993              ; Make the operands positive, noting the sign of the
                          ; result (from BCDE and, wrongly, BC'DE')
  LD (31030),DE           ; Copy BCDE into the 64-bit dividend
  LD (31032),BC           ; Store the top word of the value
  LD HL,0                 ; Clear the upper words...
  LD (31034),HL           ; ...bytes 4-5...
  LD (31036),HL           ; ...and bytes 6-7 of the 64-bit dividend
  LD BC,0                 ; Divide by 100
  LD DE,100               ; DE=100
  CALL 31055              ; Divide by 100
  LD BC,0                 ; Multiply by 100 (dropping the fractional part)
  LD DE,100               ; DE=100
  CALL 30782              ; Multiply by 100
  LD DE,(31030)           ; BCDE=result
  LD BC,(31032)           ; BC=the top word of the result
  LD A,(31054)            ; Should it be negative?
  AND A                   ; Test the sign flag
  RET Z                   ; Return if not
  JP 30634                ; Negate it

; VM op 31: NEG (BCDE=-BCDE)
  LD HL,0                 ; Negate the low word...
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Subtract the low word from 0
  EX DE,HL                ; DE=the negated low word
  LD HL,0                 ; ...and the high word
  SBC HL,BC               ; Subtract the high word from 0
  PUSH HL                 ; Copy HL into BC...
  POP BC                  ; ...by way of the stack
  RET                     ; Done: BCDE=-BCDE

; VM op 23: MUL v
  CALL 30427              ; Load the operand into BC'DE'
  JR 30657                ; Multiply

; VM op 24: MUL v,v
  CALL 30424              ; Load the two operands into BCDE and BC'DE'

; VM op 22: MUL (BCDE=BCDE*BC'DE'/100)
;
; Both values are fixed point with two decimal places, so the 64-bit product is
; divided by 100. The signs are handled separately by 30993.
  CALL 30993              ; Make both operands positive, noting the sign of the
                          ; result
  EXX                     ; Switch to BC'DE', the second operand...
  LD (31038),DE           ; Store BC'DE' as the multiplier
  LD (31040),BC           ; Store its top word as the multiplier's
  EXX                     ; Back to the main registers
  LD HL,0                 ; Clear the top half of the multiplier
  LD (31042),HL           ; Clear multiplier bytes 4-5...
  LD (31044),HL           ; ...and 6-7
  CALL 30782              ; 64-bit product=BCDE*multiplier
  LD BC,0                 ; Divide by 100 (the fixed-point scale)
  LD DE,100               ; DE=100
  CALL 31055              ; Divide by 100 (the fixed-point scale)
  LD DE,(31038)           ; BCDE=result
  LD BC,(31040)           ; BC=the top word of the quotient
  LD A,(31054)            ; Should it be negative?
  AND A                   ; Test the sign flag
  RET Z                   ; Return if not
  JP 30634                ; Negate it

; VM op 25: DIV v
  CALL 30427              ; Load the operand into BC'DE'
  JR 30715                ; Divide

; VM op 26: DIV v,v
  CALL 30424              ; Load the two operands into BCDE and BC'DE'

; Divide BCDE by BC'DE' (x100)
;
; Returns 0 if the divisor is 0.
  CALL 30993              ; Make both operands positive, noting the sign of the
                          ; result
  LD (31038),DE           ; Store BCDE (the dividend) as the multiplier
  LD (31040),BC           ; Store the top word of the dividend
  LD HL,0                 ; HL=0...
  LD (31042),HL           ; ...clear the upper half...
  LD (31044),HL           ; ...of the 64-bit multiplier
  EXX                     ; Switch to BC'DE', the divisor
  LD A,B                  ; Is the divisor zero?
  OR C                    ; Combine C...
  OR D                    ; ...D...
  OR E                    ; ...E: the divisor is zero if all clear
  JR NZ,30750             ; Jump if not
  EXX                     ; Switch back to the main registers
  LD BC,0                 ; Return 0 for division by zero
  LD DE,0                 ; DE=0
  RET                     ; Done: division by zero gives zero
  PUSH BC                 ; Save the divisor
  PUSH DE                 ; Save the divisor's low word
  LD BC,0                 ; BCDE=100
  LD DE,100               ; BCDE=100
  CALL 30782              ; 64-bit product=dividend*100
  POP DE                  ; Restore the divisor
  POP BC                  ; Restore the divisor's high word
  CALL 31055              ; Divide the product by it
  LD DE,(31038)           ; BCDE=quotient
  LD BC,(31040)           ; BC=the high word of the quotient
  LD A,(31054)            ; Should it be negative?
  AND A                   ; Test the result sign flag
  RET Z                   ; Return if not
  JP 30634                ; Negate it

; Multiply BCDE by the value at 31038 (64-bit)
;
; The product goes into 31030-31037.
  LD HL,0                 ; Clear the 64-bit product
  LD (31030),HL           ; Clear bytes 0-1 of the 64-bit product...
  LD (31032),HL           ; ...bytes 2-3...
  LD (31034),HL           ; ...bytes 4-5...
  LD (31036),HL           ; ...and bytes 6-7
  LD A,B                  ; Any bits of BCDE left?
  OR C                    ; Combine C into the test...
  OR D                    ; ...and D...
  OR E                    ; ...and E: zero when the multiplier is used up
  RET Z                   ; Return if not
  BIT 0,E                 ; Is the lowest bit set?
  JR Z,30855              ; Jump if not
  EXX                     ; Add the multiplier to the product (64 bits)
  LD HL,(31038)           ; HL=low word of the shifted multiplicand
  LD DE,(31030)           ; DE=low word of the product so far
  ADD HL,DE               ; Add them
  LD (31030),HL           ; Store the new low word of the product
  LD HL,(31040)           ; HL=second word of the multiplicand
  LD DE,(31032)           ; DE=second word of the product
  ADC HL,DE               ; Add with the carry from below
  LD (31032),HL           ; Store it
  LD HL,(31042)           ; HL=third word of the multiplicand
  LD DE,(31034)           ; DE=third word of the product
  ADC HL,DE               ; Add with carry
  LD (31034),HL           ; Store it
  LD HL,(31044)           ; HL=top word of the multiplicand
  LD DE,(31036)           ; DE=top word of the product
  ADC HL,DE               ; Add with carry
  LD (31036),HL           ; Store it
  EXX                     ; Back to the normal registers
  LD HL,31038             ; Double the multiplier
  CALL 30871              ; Shift the multiplier left
  SRA B                   ; Shift BCDE right one bit
  RR C                    ; Shift BCDE right: C...
  RR D                    ; ...D...
  RR E                    ; ...and E
  JR 30797                ; Next bit

; Shift an 8-byte number left one bit
;
; HL points at the low byte.
  SLA (HL)                ; Shift the low byte left
  LD A,7                  ; 7 more bytes
  INC HL                  ; Next byte
  RL (HL)                 ; Shift the next byte left, bringing in the carry
  DEC A                   ; One fewer byte to do
  JR NZ,30875             ; Repeat for all the remaining bytes
  RET                     ; Done

; Shift an 8-byte number right one bit (arithmetic)
;
; HL points at the high byte.
  SRA (HL)                ; Shift the high byte right (keeping the sign)
  LD A,7                  ; 7 more bytes
  INC HL                  ; Next byte
  RR (HL)                 ; Shift the next byte right, bringing in the carry
  DEC A                   ; One fewer byte to do
  JR NZ,30886             ; Repeat for all the remaining bytes
  RET                     ; Done

; Subtract the divisor from the dividend (64-bit)
  LD HL,(31030)           ; Subtract the divisor from the dividend, 16 bits at
                          ; a time
  LD DE,(31046)           ; DE=low word of the divisor
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Subtract the low words
  LD (31030),HL           ; Store the new low word
  LD HL,(31032)           ; HL=second word of the dividend
  LD DE,(31048)           ; DE=second word of the divisor
  SBC HL,DE               ; Subtract with borrow
  LD (31032),HL           ; Store it
  LD HL,(31034)           ; HL=third word of the dividend
  LD DE,(31050)           ; DE=third word of the divisor
  SBC HL,DE               ; Subtract with borrow
  LD (31034),HL           ; Store it
  LD HL,(31036)           ; HL=top word of the dividend
  LD DE,(31052)           ; DE=top word of the divisor
  SBC HL,DE               ; Subtract with borrow
  LD (31036),HL           ; Store it (H holds the sign of the 64-bit result)
  BIT 7,H                 ; Set the zero flag if the result is not negative
  RET                     ; Return with Z set if the result is not negative

; Add the divisor to the dividend (64-bit)
  LD HL,(31030)           ; Add the divisor to the dividend, 16 bits at a time
  LD DE,(31046)           ; DE=low word of the divisor
  ADD HL,DE               ; Add the low words
  LD (31030),HL           ; Store the new low word
  LD HL,(31032)           ; HL=second word of the dividend
  LD DE,(31048)           ; DE=second word of the divisor
  ADC HL,DE               ; Add with carry
  LD (31032),HL           ; Store it
  LD HL,(31034)           ; HL=third word of the dividend
  LD DE,(31050)           ; DE=third word of the divisor
  ADC HL,DE               ; Add with carry
  LD (31034),HL           ; Store it
  LD HL,(31036)           ; HL=top word of the dividend
  LD DE,(31052)           ; DE=top word of the divisor
  ADC HL,DE               ; Add with carry
  LD (31036),HL           ; Store it
  RET                     ; Done: the trial subtraction is undone

; Make BCDE and BC'DE' positive
;
; Records in 31054 whether the result must be negated.
  XOR A                   ; Clear the sign flag
  LD (31054),A            ; Store 0: the result is positive so far
  BIT 7,B                 ; Is BCDE negative?
  JR Z,31012              ; Jump if not
  CALL 30634              ; Make it positive
  LD A,(31054)            ; Flip the sign flag
  XOR 1                   ; Flip the sign flag...
  LD (31054),A            ; ...and store it
  EXX                     ; Now look at BC'DE'
  BIT 7,B                 ; Is it negative?
  JR Z,31028              ; Jump if not
  CALL 30634              ; Make it positive
  LD A,(31054)            ; Flip the sign flag
  XOR 1                   ; Flip the sign flag...
  LD (31054),A            ; ...and store it
  EXX                     ; Back to the main registers
  RET                     ; Done: both operands positive, 31054 holds the sign
                          ; of the result

; Arithmetic workspace
;
; 64-bit product/dividend (31030-31037), multiplier/quotient (31038-31045),
; divisor (31046-31053) and the sign flag (31054).
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0

; Divide the 64-bit number at 31030 by BCDE
;
; Shift-and-subtract long division. The quotient goes into 31038.
  LD HL,0                 ; Clear the quotient
  LD (31038),HL           ; Clear the quotient: bytes 0-1...
  LD (31040),HL           ; ...bytes 2-3...
  LD (31042),HL           ; ...bytes 4-5...
  LD (31044),HL           ; ...and bytes 6-7
  LD (31046),DE           ; Store BCDE as the divisor (64 bits)
  LD (31048),BC           ; Divisor bytes 4-5 from BC
  LD (31050),HL           ; Divisor bytes 6-7 are zero...
  LD (31052),HL           ; ...(HL is still 0)
  CALL 30893              ; Is the dividend smaller than the divisor?
  PUSH AF                 ; Keep the comparison result...
  CALL 30945              ; Undo the trial subtraction
  POP AF                  ; ...and get it back after undoing
  RET NZ                  ; Return with a quotient of 0 if so
  LD HL,31037             ; Find the highest non-zero byte of the dividend
  LD B,8                  ; Examine up to 8 bytes
  LD A,(HL)               ; A=the byte of the dividend
  AND A                   ; Is it zero?
  JR NZ,31106             ; Found a non-zero byte
  DEC HL                  ; Zero: look at the next lower byte
  DJNZ 31098              ; Keep looking down the bytes
  RET Z                   ; The dividend is zero: quotient 0
  LD C,128                ; Find its highest set bit
  LD A,(HL)               ; A=the byte
  AND C                   ; Test bit C
  JR NZ,31116             ; Found the highest set bit
  RRC C                   ; Try the next lower bit
  JR 31108                ; Keep looking
  LD DE,16                ; Point DE at the corresponding byte of the divisor
  ADD HL,DE               ; HL=the matching byte of the divisor
  EX DE,HL                ; DE=address of the divisor byte
  LD B,1                  ; B counts the shifts needed
  LD A,(DE)               ; Shift the divisor left until its top bit lines up
                          ; with the dividend's
  AND C                   ; Is the same bit set in the divisor?
  JR NZ,31136             ; The bits line up: stop shifting
  INC B                   ; Not yet: count another shift
  LD HL,31046             ; HL=the divisor
  CALL 30871              ; Shift the divisor left
  JR 31123                ; Check again
  PUSH BC                 ; Save the shift count
  LD HL,31038             ; Shift the quotient left
  CALL 30871              ; Shift the quotient left
  CALL 30893              ; Subtract the divisor
  JR Z,31153              ; Jump if the result was not negative
  CALL 30945              ; Otherwise add it back
  JR 31161                ; Skip the remaining bit-setting
  LD A,(31038)            ; Set the lowest bit of the quotient
  OR 1                    ; ...a 1 for a successful subtraction
  LD (31038),A            ; Store the quotient
  LD HL,31030             ; Shift the dividend left
  CALL 30871              ; Shift the dividend left
  DJNZ 31137              ; Repeat for each bit position
  POP BC                  ; Restore the shift count
  LD HL,31030             ; Shift the remainder back
  CALL 30882              ; Shift the remainder right
  DJNZ 31170              ; Once for each shift made
  RET                     ; Done: the quotient is in 31038 (64 bits)

; Store BCDE in a variable
;
; Used by VM op 15 (STORE, 30335) and by native routines that leave results in
; VM variables.
;
; Input:L Variable number (from the VM stream)
STOREVAR:
  LD H,0                  ; HL=4*variable number
  ADD HL,HL               ; HL=2*variable
  ADD HL,HL               ; HL=4*variable
  PUSH DE                 ; Save the low word of the value
  LD DE,33552             ; Point HL at the variable
  ADD HL,DE               ; HL=address of the variable
  POP DE                  ; Restore DE
  LD (HL),E               ; Store BCDE (low byte first)
  INC HL                  ; Next byte of the variable
  LD (HL),D               ; Store the second byte
  INC HL                  ; Next byte
  LD (HL),C               ; Store the third byte
  INC HL                  ; Next byte
  LD (HL),B               ; Store the top byte (the sign)
  RET                     ; Done

; VM op 28: LOAD (load a variable into BCDE)
  CALL FETCHBYTE          ; Fetch the variable number from the VM stream
  LD L,A                  ; L=the variable number

; Load variable L into BCDE
;
; Input:L Variable number
LOADVAR:
  LD H,0                  ; HL=4*variable number
  ADD HL,HL               ; HL=2*variable
  ADD HL,HL               ; HL=4*variable
  LD DE,33552             ; Point HL at the variable
  ADD HL,DE               ; HL=address of the variable
  LD E,(HL)               ; Load it into BCDE (low byte first)
  INC HL                  ; Next byte
  LD D,(HL)               ; D=second byte
  INC HL                  ; Next byte
  LD C,(HL)               ; C=third byte
  INC HL                  ; Next byte
  LD B,(HL)               ; B=top byte (the sign)
  INC HL                  ; Point past the variable
  RET                     ; Done: BCDE=the variable

; Clear the screen
;
; Clears the display file and sets every attribute to 56 (paper 7, ink 0).
CLS:
  PUSH HL                 ; Save HL
  LD HL,16384             ; Clear the display file
  LD DE,16385             ; DE=the next byte
  LD BC,6143              ; BC=the remaining 6143 bytes
  LD (HL),0               ; Clear the first byte
  LDIR                    ; Propagate it across the display file
  LD HL,22528             ; Set every attribute to paper 7, ink 0
  LD DE,22529             ; DE=the next attribute
  LD BC,767               ; BC=the remaining 767 attributes
  LD (HL),56              ; Paper 7 (white), ink 0 (black)
  LDIR                    ; Propagate it across the attribute file
  POP HL                  ; Restore HL
  RET                     ; Done: a clean white screen

; Draw a picture
;
; Pictures are stored as a list of drawing commands at IY:
;
; +-----------------------------+---------------------------------------------+
; | Command                     | Meaning                                     |
; +-----------------------------+---------------------------------------------+
; | 0                           | End of picture                              |
; | 8, x, y                     | Move the pen to (x,y)                       |
; | 16, lo, hi, w, h, data...   | Copy a w x h block of bytes to the screen   |
; |                             | at hi*256+lo (ORed into the display file;   |
; |                             | written directly into the attributes)       |
; | 128-255                     | Draw a line: bits 0-2 are the direction     |
; |                             | flags, and the length comes from bits 3-6   |
; |                             | and the top 2 bits of the next byte         |
; | 64-127, x, y                | Flood fill from (x,y); bits 0-2 = the ink   |
; |                             | colour of the filled cells                  |
; | 32-63, hi, lo, runs..., 255 | Paint attribute paper colour (bits 0-2)     |
; |                             | along a path starting at hi*256+lo; each    |
; |                             | run byte gives a count (bits 2-7) and a     |
; |                             | direction (bits 0-1: up, right, down, left) |
; +-----------------------------+---------------------------------------------+
;
; Input:IY Picture data
DRAWPIC:
  PUSH HL                 ; Save HL
  PUSH DE                 ; Save DE
  PUSH BC                 ; Save BC
  CALL CLS                ; Clear the screen
  LD D,127                ; Pen x=127
  LD E,63                 ; Pen y=63
  LD B,1                  ; Default slope
  LD C,1                  ; Default direction
  LD L,1                  ; Default length
  LD A,(IY+0)             ; Pick up the next command
  AND A                   ; Is it 0 (end of picture)?
  JP Z,31480              ; Finish if so
  INC IY                  ; Point at its operands
  CP 8                    ; Command 8 (move the pen)?
  JR NZ,31288             ; Jump if not
  LD D,(IY+0)             ; D=new x
  INC IY                  ; Point at y
  LD E,(IY+0)             ; E=new y
  INC IY                  ; Point at the next command
  JR 31263                ; Next command
  CP 16                   ; Command 16 (bitmap block)?
  JR NZ,31332             ; Jump if not
  LD L,(IY+0)             ; HL=screen address
  LD H,(IY+1)             ; H=the high byte of the screen address
  LD B,(IY+2)             ; B=width in bytes
  LD C,(IY+3)             ; C=height in rows
  INC IY                  ; Skip the address, low byte...
  INC IY                  ; ...high byte...
  INC IY                  ; ...and the width
  INC IY                  ; Point at the bitmap data
  PUSH HL                 ; Save the start of the row
  PUSH BC                 ; Save the width and height
  CALL 31511              ; Put a byte on the screen
  INC L                   ; Next column
  INC IY                  ; Next byte of data
  DJNZ 31314              ; Repeat for the width of the block
  POP BC                  ; Restore the width and height
  POP HL                  ; Back to the start of the row
  CALL 31484              ; Move down a pixel row (or an attribute row)
  DEC C                   ; One row done
  JR NZ,31312             ; Repeat for each row
  JR 31263                ; Next command
  BIT 7,A                 ; Bit 7 set (line)?
  JR Z,31369              ; Jump if not
  LD B,A                  ; B=the command byte
  AND 7                   ; C=direction flags (bits 0-2)
  LD C,A                  ; C=the direction flags
  LD A,B                  ; A=the command byte again
  RRCA                    ; Move bits 3-6 down...
  AND 60                  ; B=bits 3-6 (high bits of the slope)...
  LD B,A                  ; B=the high part of the slope
  LD A,(IY+0)             ; Pick up the second byte
  AND 63                  ; Bits 0-5: length-1
  LD L,A                  ; L=the low part of the length
  INC L                   ; L=length
  LD A,(IY+0)             ; A=the second byte again
  INC IY                  ; Point at the next command
  RLCA                    ; ...plus bits 6-7 of the second byte
  RLCA                    ; Rotate bits 6-7 round to bits 0-1...
  AND 3                   ; ...and keep them
  OR B                    ; Combine them with the high part of the slope
  LD B,A                  ; B=the slope
  INC B                   ; B=slope
  CALL 31917              ; Draw the line
  JR 31263                ; Next command
  BIT 6,A                 ; Bit 6 set (flood fill)?
  JR Z,31393              ; Jump if not
  AND 7                   ; A=the ink colour
  PUSH DE                 ; Save the pen position
  LD D,(IY+0)             ; D=x of the seed point
  INC IY                  ; Point at y
  LD E,(IY+0)             ; E=y
  INC IY                  ; Point at the next command
  CALL FILL               ; Fill the area
  POP DE                  ; Restore the pen position
  JP 31263                ; Next command
  BIT 5,A                 ; Bit 5 set (paint attributes)?
  JP Z,31263              ; Ignore the command if not
  AND 7                   ; Bits 0-2: paper colour
  RLCA                    ; Multiply the paper colour by 8...
  RLCA                    ; ...to put it in bits 3-5
  RLCA                    ; C=paper colour*8
  PUSH HL                 ; Save HL
  PUSH DE                 ; Save DE
  PUSH BC                 ; Save BC
  LD C,A                  ; C=the paper colour in bits 3-5
  LD H,(IY+0)             ; HL=attribute address
  INC IY                  ; Point at the low byte of the address
  LD L,(IY+0)             ; L=the low byte
  INC IY                  ; Point at the first run
  LD A,(IY+0)             ; Pick up the next run
  INC IY                  ; Point at the next run
  CP 255                  ; End of the runs?
  JR Z,31474              ; Finish if so
  LD B,A                  ; B=the run byte
  AND 3                   ; E=direction (0 up, 1 right, 2 down, 3 left)
  LD E,A                  ; E=the direction
  LD A,B                  ; B=length of the run (bits 2-7, plus 1)
  RRCA                    ; Shift the run length down...
  RRCA                    ; ...two places
  AND 63                  ; Keep the length bits
  INC A                   ; The length is one more
  LD B,A                  ; B=the length
  LD A,(HL)               ; Take the ink of this cell
  AND 7                   ; Keep the ink
  RLCA                    ; Move the ink to bits 3-5, where the paper is...
  RLCA                    ; ...
  RLCA                    ; ...
  CP C                    ; Is it the same as the new paper?
  JR NZ,31448             ; Jump if not
  XOR 56                  ; If so use paper 7 instead, so the ink stays visible
  RRCA                    ; Move the ink back to bits 0-2
  RRCA                    ; Move the ink back to bits 0-2...
  RRCA                    ; ...
  OR C                    ; Combine it with the paper
  LD (HL),A               ; Set the attribute
  LD A,E                  ; Move in the run's direction
  AND A                   ; Zero means up
  CALL Z,31755            ; Up
  DEC A                   ; 1 means right
  CALL Z,31806            ; Right
  DEC A                   ; 2 means down
  CALL Z,31772            ; Down
  DEC A                   ; 3 means left
  CALL Z,31796            ; Left
  DJNZ 31437              ; Repeat for the length of the run
  JR 31417                ; Next run
  POP BC                  ; Restore BC
  POP DE                  ; Restore DE
  POP HL                  ; Restore HL
  JP 31263                ; Next command
  POP BC                  ; Restore BC
  POP DE                  ; Restore DE
  POP HL                  ; Restore HL
  RET                     ; Return

; Move HL down one pixel row in the display file (or one row in the attributes)
  LD A,H                  ; Is HL in the attribute file?
  CP 88                   ; Is the high byte 88 or more (attribute file)?
  JR C,31496              ; Jump if not
  LD A,L                  ; Move down one attribute row
  ADD A,32                ; Add 32 to move down one row of cells...
  LD L,A                  ; ...L=the new low byte
  RET NC                  ; Done unless the add carried into the high byte
  INC H                   ; Carry: the next page
  RET                     ; Done
  INC H                   ; Move down one pixel row
  LD A,H                  ; A=the new high byte
  AND 7                   ; The low 3 bits count the pixel row in the cell
  RET NZ                  ; Return unless that crossed a character row
  LD A,L                  ; Crossed into the next cell row: add 32 to L
  ADD A,32                ; (next row of cells)
  LD L,A                  ; L=the new low byte
  RET C                   ; Carry: in the next third, H is already right
  LD A,H                  ; Otherwise H must go back 8...
  SUB 8                   ; ...to stay in the same third
  LD H,A                  ; H=the corrected high byte
  RET                     ; Done

; Put a byte from a bitmap block on the screen
;
; ORs the byte at IY into the display file, or writes it if HL is in the
; attribute file.
  LD A,H                  ; Is HL in the attribute file?
  CP 88                   ; Is the address 88 or more (attribute file)?
  LD A,(IY+0)             ; Pick up the data byte
  JR NC,31520             ; Jump if so: store it as it is
  OR (HL)                 ; Otherwise merge it with the picture
  LD (HL),A               ; Store the byte
  RET                     ; Done

; The fill attribute
  DEFB 0,0,0

; Flood fill
;
; Fills the area containing the pixel at (D,E) solidly with ink, scanning left
; and right along each row and remembering whether the rows above and below
; need filling. Every cell it touches also gets A as its ink colour (bits 3-5
; of A, if any, are ORed in as paper: the compressed pictures pass 56, meaning
; ink 0 on paper 7).
;
; Input:A Attribute bits for the filled cells (ink in bits 0-2)
;       D x coordinate
;       E y coordinate
FILL:
  LD (31522),A            ; Store the attribute bits for the filled cells
  PUSH BC                 ; Save BC
  PUSH DE                 ; Save DE
  PUSH HL                 ; Save HL
  LD HL,22528             ; HL=22528: an address in the attribute file, used as
                          ; the end marker
  PUSH HL                 ; Push a zero marker (the end of the stack of seeds)
  LD BC,0                 ; BC=0
  PUSH BC                 ; Push the marker (HL=22528, DE=0 below it) on the
                          ; seed stack
  CALL 32066              ; Get the address and mask of the seed point
  LD D,A                  ; D=the pixel mask of the seed
  LD A,D                  ; Is this pixel set?
  AND (HL)                ; Is the pixel at HL set?
  JR NZ,31555             ; Jump if so: the left edge has been reached
  CALL 31900              ; Otherwise move left
  JR NZ,31543             ; And keep going
  JP 31561                ; The left edge of the screen was reached: start
                          ; filling
  CALL 32034              ; Plot the edge pixel
  CALL 31887              ; Move right
  LD BC,0                 ; Clear the up/down flags
  LD (31523),BC           ; Clear both flags (above and below)
  LD A,D                  ; Reached a full byte boundary?
  CP 128                  ; Is the mask the leftmost pixel of a byte?
  JR NZ,31577             ; No: do it pixel by pixel
  LD A,(HL)               ; Is the whole byte empty?
  AND A                   ; Test the byte
  JR Z,31643              ; Jump if so (fill it in one go)
  PUSH HL                 ; Save the screen address
  CALL 31823              ; Look at the pixel above
  LD A,0                  ; A=0: the flag for "above" if nothing is pushed
  JR Z,31601              ; Jump if at the top
  LD A,D                  ; A=the pixel mask
  AND (HL)                ; Is the pixel above set?
  LD A,0                  ; A=0: the flag if it is blocked
  JR NZ,31601             ; Jump if it is set
  LD A,(31523)            ; Was the pixel above already being filled?
  AND A                   ; Test the flag
  JR NZ,31604             ; Jump if so
  EX (SP),HL              ; Otherwise push it as a new seed
  PUSH DE                 ; Push the mask
  PUSH HL                 ; Push the address
  INC A                   ; A=1: the flag says a seed is now pending above
  LD (31523),A            ; Store the flag
  POP HL                  ; HL=the current address
  PUSH HL                 ; Keep it on the stack
  CALL 31851              ; Look at the pixel below
  LD A,0                  ; A=0: the flag for "below" if nothing is pushed
  JR Z,31630              ; Jump if at the bottom
  LD A,D                  ; A=the pixel mask
  AND (HL)                ; Is the pixel below set?
  LD A,0                  ; A=0: the flag if it is blocked
  JR NZ,31630             ; Jump if it is set
  LD A,(31524)            ; Was the pixel below already being filled?
  AND A                   ; Test the flag
  JR NZ,31633             ; Jump if so
  EX (SP),HL              ; Otherwise push it as a new seed
  PUSH DE                 ; Push the mask
  PUSH HL                 ; Push the address
  LD A,1                  ; A=1: a seed is now pending below
  LD (31524),A            ; Store the flag
  POP HL                  ; HL=the current address
  CALL 32034              ; Plot this pixel
  CALL 31887              ; Move right
  JP 31728                ; Move on along the line
  LD BC,0                 ; Fill a whole byte at once: check the bytes above
                          ; and below
  PUSH HL                 ; Save the screen address
  CALL 31823              ; Look at the byte above
  LD A,(HL)               ; A=the byte above
  POP HL                  ; Restore the address
  JR Z,31662              ; At the top of the screen: it counts as clear
  CP 255                  ; Is the byte above full?
  JR Z,31662              ; Yes: treat as blocked
  AND A                   ; Is it empty?
  JR NZ,31577             ; Neither empty nor full: do it pixel by pixel
  INC C                   ; C=1: the byte above is empty
  PUSH HL                 ; Save the address
  CALL 31851              ; Look at the byte below
  LD A,(HL)               ; A=the byte below
  POP HL                  ; Restore the address
  JR Z,31678              ; At the bottom of the picture: it counts as clear
  CP 255                  ; Is the byte below full?
  JR Z,31678              ; Yes: treat as blocked
  AND A                   ; Is it empty?
  JR NZ,31577             ; Neither: do it pixel by pixel
  INC B                   ; B=1: the byte below is empty
  LD A,(31523)            ; A=the flag for above
  AND A                   ; Test it
  LD A,C                  ; A=C (above is empty)
  JR NZ,31697             ; A seed is already pending above
  AND A                   ; Is the byte above empty?
  JR Z,31697              ; No: nothing to push
  LD (31523),A            ; Remember that a seed is pending above
  PUSH HL                 ; Save the address
  CALL 31823              ; Move to the byte above
  EX (SP),HL              ; Push it as a new seed
  PUSH DE                 ; Push the mask
  LD (31523),A            ; Store the flag
  LD A,(31524)            ; A=the flag for below
  AND A                   ; Test it
  LD A,B                  ; A=B (below is empty)
  JR NZ,31719             ; A seed is already pending below
  AND A                   ; Is the byte below empty?
  JR Z,31719              ; No: nothing to push
  LD (31524),A            ; Remember that a seed is pending below
  PUSH HL                 ; Save the address
  CALL 31851              ; Move to the byte below
  EX (SP),HL              ; Push it as a new seed
  PUSH DE                 ; Push the mask
  LD (HL),255             ; Fill the whole byte
  CALL 32045              ; Set its ink
  INC L                   ; Next byte
  LD A,L                  ; Reached the right edge of the screen?
  AND 31                  ; Keep the column
  JR Z,31738              ; At the right edge: this run is finished
  LD A,D                  ; A=the mask
  AND (HL)                ; Is the next pixel set?
  JP Z,31568              ; No: carry on filling
  CALL 32034              ; Plot the pixel
  POP DE                  ; Pick up the next seed
  POP HL                  ; Pick up the address of the next seed
  LD A,H                  ; Is it the zero marker?
  CP 88                   ; Is it the end marker (high byte 88)?
  JP NZ,31543             ; Fill from it if not
  LD A,0                  ; A=0
  LD (31522),A            ; Reset the attribute bits to 0
  POP HL                  ; Restore HL
  POP DE                  ; Restore DE
  POP BC                  ; Restore BC
  RET                     ; Return

; Move up one attribute row (unless at the top)
  PUSH AF                 ; Save AF
  PUSH DE                 ; Save DE
  LD DE,32                ; Move up one attribute row
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Subtract 32 from the address
  LD A,H                  ; Above the top?
  CP 87                   ; Is it 87 (just below the attribute file at 88)?
  JR NZ,31769             ; No: the move is fine
  ADD HL,DE               ; Undo the move if so
  POP DE                  ; Restore DE
  POP AF                  ; Restore AF
  RET                     ; Return

; Move down one attribute row (unless at the bottom of the picture area)
  PUSH AF                 ; Save AF
  PUSH DE                 ; Save DE
  LD DE,32                ; Move down one attribute row
  ADD HL,DE               ; Add 32 to the address
  LD A,H                  ; Into the status lines (row 22)?
  CP 90                   ; Is the high byte 90 (attribute rows 16-23)?
  JR NZ,31793             ; No: the move is fine
  LD A,L                  ; A=the low byte
  AND 224                 ; Keep the row bits
  CP 192                  ; Is it row 22 or 23 (the status lines)?
  JR NZ,31793             ; No: the move is fine
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Undo the move if so
  POP DE                  ; Restore DE
  POP AF                  ; Restore AF
  RET                     ; Return

; Move left one attribute cell
  PUSH AF                 ; Save AF
  DEC HL                  ; Move left one cell
  LD A,H                  ; Before the start of the attribute file?
  CP 87                   ; Is it 87 (just below the attribute file)?
  JR NZ,31804             ; No: the move is fine
  INC HL                  ; Undo the move if so
  POP AF                  ; Restore AF
  RET                     ; Return

; Move right one attribute cell
  PUSH AF                 ; Save AF
  INC HL                  ; Move right one cell
  LD A,H                  ; Past the end of the picture area?
  CP 90                   ; Is the high byte 90?
  JR NZ,31821             ; No: the move is fine
  LD A,L                  ; A=the low byte
  AND 224                 ; Keep the row bits
  CP 192                  ; Row 22 or 23 (the status lines)?
  JR NZ,31821             ; No: the move is fine
  DEC HL                  ; Undo the move if so
  POP AF                  ; Restore AF
  RET                     ; Return

; Move HL up one pixel row
;
; Returns with the zero flag set if the top of the screen has been reached.
  DEC H                   ; Move up one pixel row
  LD A,H                  ; A=the high byte
  AND 7                   ; Pixel row within the cell
  CP 7                    ; Did that cross a character row?
  RET NZ                  ; Return (zero flag reset) if not
  LD A,L                  ; A=the low byte
  SUB 32                  ; Up one character row
  LD L,A                  ; L=it
  JR C,31840              ; Borrow: H is already right
  LD A,H                  ; A=the high byte
  ADD A,8                 ; Add 8 to move to the previous third's last row
  LD H,A                  ; H=it
  LD A,H                  ; Above the top of the screen?
  CP 63                   ; Is it 63 (above the display file)?
  RET NZ                  ; Return (zero flag reset) if not
  INC H                   ; Undo the move
  LD A,L                  ; A=the low byte
  ADD A,32                ; Put the row back
  LD L,A                  ; L=it
  XOR A                   ; Set the zero flag
  RET                     ; Done: Z means the edge was reached

; Move HL down one pixel row
;
; Returns with the zero flag set if the bottom of the picture area (row 160)
; has been reached.
  INC H                   ; Move down one pixel row
  LD A,H                  ; A=the high byte
  AND 7                   ; Pixel row within the cell
  RET NZ                  ; Return (zero flag reset) unless that crossed a
                          ; character row
  LD A,L                  ; A=the low byte
  ADD A,32                ; Down one character row
  LD L,A                  ; L=it
  JR C,31866              ; Carry: H is already right
  LD A,H                  ; A=the high byte
  SUB 8                   ; Take 8 off
  LD H,A                  ; H=it
  LD A,H                  ; Reached row 160 (the bottom of the picture area)?
  CP 80                   ; Is it 80 (past the third)?
  RET NZ                  ; Not the bottom: done with NZ
  LD A,L                  ; A=the low byte
  AND 224                 ; Keep the row bits
  CP 192                  ; Is it row 6 (the bottom of the picture area)?
  RET NZ                  ; Return (zero flag reset) if not
  DEC H                   ; Undo the move
  LD A,L                  ; A=the low byte
  SUB 32                  ; Up one character row
  LD L,A                  ; L=it
  LD A,H                  ; A=the high byte
  ADD A,8                 ; Add 8 back
  LD H,A                  ; H=it
  XOR A                   ; Set the zero flag
  RET                     ; Done: Z means the edge was reached

; Move the pixel mask D one pixel right
;
; Returns with the zero flag set at the right edge.
  RRC D                   ; Move the mask right one pixel
  RET NC                  ; Return unless it wrapped round
  INC L                   ; Next cell
  LD A,L                  ; At the right edge?
  AND 31                  ; Keep the column
  RET NZ                  ; Return (zero flag reset) if not
  RLC D                   ; Undo the move
  DEC L                   ; Previous cell
  XOR A                   ; Set the zero flag
  RET                     ; Done: Z means the edge was reached

; Move the pixel mask D one pixel left
;
; Returns with the zero flag set at the left edge.
  RLC D                   ; Move the mask left one pixel
  RET NC                  ; Return unless it wrapped round
  DEC L                   ; Previous cell
  LD A,L                  ; Wrapped round the left edge?
  AND 31                  ; Keep the column
  CP 31                   ; Did it wrap round to column 31?
  RET NZ                  ; Return (zero flag reset) if not
  RRC D                   ; Undo the move
  INC L                   ; Back to the cell on the right
  XOR A                   ; Set the zero flag
  RET                     ; Done: Z means the edge was reached

; Unused: a stray jump
;
; Nothing refers to these two bytes. They are the Z80 instruction JR 31887,
; sitting just after the RET of the routine at 31900 where it can never be
; executed. 31887 is the routine that moves the pixel mask right one pixel, so
; this is probably a leftover from an earlier version of the line routines.
  DEFB 24,226             ; JR 31887: never executed

; Draw a line segment
;
; Draws a line of L pixels from the pen position (D,E). Bit 0 of C chooses a
; mostly horizontal (0) or mostly vertical (1) line; bit 1 means down rather
; than up and bit 2 means left rather than right. B is the number of pixels
; drawn along the main direction before each step in the other direction, so it
; sets the slope. Each pixel also sets the ink of its attribute. Drawing stops
; early at the edge of the picture area, and the pen is left at the end of the
; line.
;
;  Input:B Pixels per minor step
;        C Direction flags
;        D Pen x
;        E Pen y
;        L Length
; Output:D,E New pen position
  PUSH HL                 ; Save HL
  LD A,L                  ; A=the line length...
  EX AF,AF'               ; A'=length
  PUSH BC                 ; Keep the direction and step count (BC)
  CALL 32066              ; Get the screen address and mask of the pen
  LD D,A                  ; D=mask
  POP BC                  ; Get the direction and step count back...
  PUSH BC                 ; ...and keep them for later
  EX AF,AF'               ; A=pixel count again
  BIT 0,C                 ; Mostly vertical?
  JR NZ,31983             ; Jump if so
  EX AF,AF'               ; Swap in the pixel count
  CALL 32034              ; Plot the pixel
  BIT 2,C                 ; Moving left?
  JR Z,31947              ; Jump if not
  CALL 31900              ; Move left
  JR Z,31977              ; Stop at the edge
  JR 31952                ; Now do the vertical step check
  CALL 31887              ; Move right
  JR Z,31977              ; Stop at the edge
  DEC B                   ; Time for a vertical step?
  JR NZ,31973             ; Jump if not
  BIT 1,C                 ; Down?
  JR Z,31966              ; Not moving down: go up instead
  CALL 31851              ; Move down
  JR Z,31977              ; Stop at the edge
  JR 31971                ; Skip the up move
  CALL 31823              ; Move up
  JR Z,31977              ; Stop at the edge
  POP BC                  ; Reset the step counter
  PUSH BC                 ; Keep the step counter for the next time round
  EX AF,AF'               ; Keep the count in A'
  DEC A                   ; Count the pixels
  JR NZ,31932             ; Repeat for the length of the line
  CALL 32084              ; Work out the new pen position
  POP BC                  ; Restore the direction and step count...
  POP HL                  ; ...and the caller's HL
  RET                     ; Done: the line has been drawn
  EX AF,AF'               ; A=pixel count
  CALL 32034              ; Plot the pixel
  BIT 1,C                 ; Down?
  JR Z,31998              ; Not moving down: go up instead
  CALL 31851              ; Move down
  JR Z,32028              ; Stop at the edge
  JR 32003                ; Skip the up move
  CALL 31823              ; Move up
  JR Z,32028              ; Stop at the edge
  DEC B                   ; Time for a horizontal step?
  JR NZ,32024             ; Jump if not
  BIT 2,C                 ; Left?
  JR Z,32017              ; Not moving left: go right instead
  CALL 31900              ; Move left
  JR Z,32028              ; Stop at the edge
  JR 32022                ; Skip the right move
  CALL 31887              ; Move right
  JR Z,32028              ; Stop at the edge
  POP BC                  ; Reset the step counter
  PUSH BC                 ; Keep the step counter for the next time round
  EX AF,AF'               ; Keep the count in A'
  DEC A                   ; Count the pixels
  JR NZ,31983             ; Repeat for the length of the line
  CALL 32084              ; Work out the new pen position
  POP BC                  ; Restore the direction and step count...
  POP HL                  ; ...and the caller's HL
  RET                     ; Done: the line has been drawn

; Plot the pixel at HL (mask D) and set its attribute
  PUSH HL                 ; Save HL
  LD A,D                  ; A=the pixel mask
  PUSH AF                 ; Keep it
  CALL 32045              ; Set the ink of the cell
  POP AF                  ; Get the mask back
  OR (HL)                 ; Set the pixel
  LD (HL),A               ; Store the byte with the pixel set
  POP HL                  ; Restore HL
  RET                     ; Done

; Set the ink of the attribute for display file address HL
;
; Uses the ink colour in 31522.
  PUSH HL                 ; Save HL
  LD A,H                  ; Work out the attribute address
  AND 24                  ; Keep bits 3-4 of H: the screen third (0-2) times 8
  RRCA                    ; Move the third number...
  RRCA                    ; ...down...
  RRCA                    ; ...to the low bits
  ADD A,88                ; Add the high byte of the attribute file
  LD H,A                  ; H=attribute address high byte
  LD A,(HL)               ; Clear the old ink
  AND 248                 ; Clear the three ink bits
  LD (HL),A               ; Store the attribute without ink
  LD A,(31522)            ; Put in the new one
  OR (HL)                 ; Add the new ink colour
  LD (HL),A               ; Store the updated attribute
  POP HL                  ; Restore HL
  RET                     ; Done

; Get the display file address and mask for pixel (D,E)
;
; Uses the ROM routine PIXEL-ADD (entered at 8880, just after its first
; instructions).
;
;  Input:D x
;        E y
; Output:HL Address
;        A Pixel mask
  PUSH BC                 ; Save BC
  LD C,D                  ; C=x
  LD A,175                ; B=175-y (the ROM counts from the bottom)
  SUB E                   ; A=175-y
  CALL 8880               ; Use the ROM's PIXEL-ADD (skipping its first
                          ; instructions)
  LD B,A                  ; A=bit position
  INC B                   ; B=the bit position plus one
  LD A,1                  ; Turn it into a mask
  RRC A                   ; Rotate the mask right
  DJNZ 32078              ; Repeat for each position
  POP BC                  ; Restore BC
  RET                     ; Return

; Convert a display file address and mask back to coordinates
;
; Inverse of 32066.
  LD A,255                ; Turn the mask back into a bit position
  INC A                   ; Count the shifts
  RLC D                   ; Rotate the mask left until the bit falls out
  JR NC,32086             ; Repeat
  LD D,A                  ; D=the bit position (0-7)
  LD A,L                  ; x=8*column+bit
  AND 31                  ; Keep the column
  RLCA                    ; Multiply by 8
  RLCA                    ; ...
  RLCA                    ; ...
  OR D                    ; Add the bit position
  LD D,A                  ; D=x
  LD A,H                  ; y=row within the character...
  AND 7                   ; Keep the pixel row within the cell
  LD E,A                  ; E=it
  LD A,L                  ; ...plus 8*character row...
  AND 224                 ; Keep the character row bits
  RRCA                    ; Move them to bits 3-5
  RRCA                    ; ...
  OR E                    ; Add the pixel row
  LD E,A                  ; E=it
  LD A,H                  ; ...plus 64*third
  AND 24                  ; Keep the third bits
  RLCA                    ; Move them to bits 6-7
  RLCA                    ; ...
  RLCA                    ; ...
  OR E                    ; Add the lower bits
  LD E,A                  ; E=y counted from the top
  LD A,175                ; Convert to the ROM's coordinates
  SUB E                   ; Subtract from 175
  LD E,A                  ; E=y counted from the bottom
  RET                     ; Return

; The end of the point list
  DEFB 0,0

; Draw a compressed picture
;
; The larger full-screen pictures (the Partridge Club and the street outside
; Milton's) use a second, more compact format: a 9-byte header (the offset of
; the end of the point bit-stream, the bit position where it ends, the offset
; of the attribute data and four bit widths for the coordinate deltas), a
; bit-stream of points in which each coordinate is stored as a variable-width
; delta read by 32539, line segments drawn between the points (32612), and
; finally three run-length encoded passes over the attribute file (ink, then
; paper, then bright and flash).
;
; Input:HL Picture data
DRAWCPIC:
  PUSH HL                 ; Save HL
  POP IY                  ; IY=picture header
  CALL CLS                ; Clear the screen
  LD DE,9                 ; The bit-stream starts after the 9-byte header
  ADD HL,DE               ; HL=the start of the bit-stream
  LD (32536),HL           ; Set the bit-stream pointer
  XOR A                   ; Start at bit 0
  LD (32538),A            ; Store bit position 0
  LD BC,0                 ; Start at (0,0)
  CALL 32294              ; Draw the strokes...
  JR NZ,32146             ; ...until the end of the point list
  LD L,(IY+3)             ; HL=the offset of the attribute data (header bytes
                          ; 3-4)
  LD H,(IY+4)             ; H=the high byte of the offset
  PUSH IY                 ; Copy IY into DE...
  POP DE                  ; ...by way of the stack
  ADD HL,DE               ; Add the address of the header
  LD (32124),HL           ; Remember it: it also marks the end of the list of
                          ; fill seeds
  LD L,(IY+0)             ; HL=the offset of the end of the point bit-stream
                          ; (header bytes 0-1)
  LD H,(IY+1)             ; H=the high byte of the offset
  ADD HL,DE               ; HL=the address just after the bit-stream
  LD A,(IY+2)             ; Does the bit-stream end part-way through a byte
                          ; (header byte 2)?
  AND A                   ; Test the byte
  JR Z,32178              ; Zero: no padding byte
  INC HL                  ; Yes: skip that last byte
  PUSH HL                 ; Save the address
  POP IY                  ; IY=the list of fill seed points
  LD D,(IY+1)             ; D=x
  LD A,175                ; E=175-y
  SUB (IY+0)              ; A=175-y
  LD E,A                  ; E=y counted from the top
  INC IY                  ; Next byte
  INC IY                  ; Next seed point
  LD A,56                 ; Fill with ink 0 on paper 7
  CALL FILL               ; Fill the area around the seed
  PUSH IY                 ; Reached the end of the seed points?
  POP HL                  ; HL=the position in the list
  LD DE,(32124)           ; DE=the end of the list
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Compare
  JR NZ,32181             ; Jump back if not
  LD DE,(32124)           ; DE=run-length attribute data
  LD HL,22528             ; First pass over the attribute file: the ink colours
  LD A,H                  ; Reached the end of the attribute file?
  CP 91                   ; Is the high byte 91 (the end of the attribute
                          ; file)?
  JR Z,32241              ; Jump if so
  LD A,(DE)               ; Bits 0-4: run length-1
  AND 31                  ; Keep the run length bits
  LD B,A                  ; B=the run length minus one
  INC B                   ; B=the run length
  LD A,(DE)               ; Bits 5-7: the ink colour
  INC DE                  ; Next byte of attribute data
  AND 224                 ; Keep the colour bits
  RLCA                    ; Rotate bits 5-7 round to bits 0-2...
  RLCA                    ; ...
  RLCA                    ; ...
  LD (HL),A               ; Set the ink for the run
  INC HL                  ; Next cell
  DJNZ 32235              ; Repeat for every cell in the run
  JR 32218                ; Next run
  LD HL,22528             ; Second pass: the paper colours
  LD A,H                  ; Reached the end of the attribute file?
  CP 91                   ; Is the high byte 91?
  JR Z,32269              ; Jump if so
  LD A,(DE)               ; Bits 0-4: run length-1
  AND 31                  ; Keep the run length bits
  LD B,A                  ; B=the run length minus one
  INC B                   ; B=the run length
  LD A,(DE)               ; Bits 5-7: the paper colour
  INC DE                  ; Next byte of attribute data
  AND 224                 ; Keep the colour bits
  RRCA                    ; Move bits 5-7 down to bits 3-5...
  RRCA                    ; ...
  LD C,A                  ; C=the paper colour
  LD A,C                  ; Add the paper to each cell in the run
  OR (HL)                 ; Merge it with the ink already there
  LD (HL),A               ; Store it
  INC HL                  ; Next cell
  DJNZ 32261              ; Repeat for every cell in the run
  JR 32244                ; Next run
  LD HL,22528             ; Third pass: bright and flash
  LD A,H                  ; Reached the end of the attribute file?
  CP 91                   ; Is the high byte 91?
  RET Z                   ; Return if so
  LD A,(DE)               ; Bits 0-5: run length-1
  AND 63                  ; Keep the run length bits
  LD B,A                  ; B=the run length minus one
  INC B                   ; B=the run length
  LD A,(DE)               ; Bits 6-7: bright and flash
  INC DE                  ; Next byte of attribute data
  AND 192                 ; Keep the bright and flash bits
  LD C,A                  ; C=the bits
  LD A,C                  ; Add them to each cell in the run
  OR (HL)                 ; Merge them with the colours already there
  LD (HL),A               ; Store them
  INC HL                  ; Next cell
  DJNZ 32286              ; Repeat for every cell in the run
  JR 32272                ; Next run

; Draw the next stroke of a compressed picture
;
; Returns with the zero flag set at the end of the point list.
  LD HL,(32536)           ; Reached the end of the point list?
  PUSH IY                 ; Copy IY into DE...
  POP DE                  ; ...by way of the stack
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; HL=the stream pointer's offset from the header
  LD E,(IY+0)             ; E=the low byte of the offset of the end
  LD D,(IY+1)             ; D=the high byte
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Compare: is this the end byte?
  JR NZ,32321             ; Jump if not
  LD A,(32538)            ; Check the bit position too
  CP (IY+2)               ; Is it the end bit position too?
  RET Z                   ; Return with the zero flag set at the end
  LD D,1                  ; Read one bit: 1 = start a new stroke, 0 = continue
                          ; the current one
  CALL 32539              ; Read the bit
  AND A                   ; Test the bit
  JR Z,32340              ; Jump to continue the stroke
  CALL 32365              ; Read the starting point
  CALL 32596              ; Plot it
  OR (HL)                 ; Merge the pixel with the screen byte
  LD (HL),A               ; Store it
  OR 1                    ; Reset the zero flag: more to come
  RET                     ; Return
  LD (32610),BC           ; Remember the start of the line
  CALL 32596              ; Get its screen address
  LD D,A                  ; D=the pixel mask
  EXX                     ; Switch to the alternate registers
  LD BC,(32610)           ; BC'=the line start
  CALL 32365              ; Read the next point
  PUSH BC                 ; Save the end point
  CALL 32612              ; Draw a line to it
  EXX                     ; Switch back
  POP BC                  ; BC=the end point
  OR 1                    ; Reset the zero flag: more to come
  RET                     ; Return

; Read the next point (x in C, y in B)
  LD D,1                  ; Read one bit: absolute or relative coordinates?
  CALL 32539              ; Read it
  AND A                   ; Test it
  JR Z,32382              ; Zero: only one coordinate is given
  CALL 32400              ; Read x
  LD C,A                  ; C=x
  CALL 32434              ; Read y
  LD B,A                  ; B=y
  RET                     ; Return
  LD D,1                  ; Read one bit: short or long deltas?
  CALL 32539              ; Read it
  AND A                   ; Test it
  JR NZ,32395             ; One: it is a y delta
  CALL 32468              ; Read a long x delta
  LD C,A                  ; C=the new x
  RET                     ; Return
  CALL 32502              ; Read a long y delta
  LD B,A                  ; B=the new y
  RET                     ; Return

; Read an x coordinate (absolute or delta)
  LD D,1                  ; D=1: read one bit
  CALL 32539              ; Read it
  AND A                   ; Test it
  JR Z,32413              ; Zero: a short delta follows
  LD D,8                  ; D=8: an absolute coordinate has eight bits
  JP 32539                ; Read it and return
  LD A,(IY+5)             ; A=the number of bits in a short x delta (from the
                          ; picture header)
  LD D,A                  ; D=the number of bits
  CALL 32539              ; Read the delta (left-aligned in A)
  LD D,A                  ; D=the delta
  LD A,(IY+5)             ; A=the number of bits
  SRA D                   ; Shift right, keeping the sign...
  INC A                   ; ...until the delta is right-aligned
  CP 8                    ; ...(8 minus the number of bits times)
  JR NZ,32424             ; Repeat
  LD A,D                  ; A=the signed delta
  ADD A,C                 ; Add the old x (C)
  RET                     ; Add it to the old x

; Read a y coordinate (absolute or delta)
  LD D,1                  ; Return
  CALL 32539              ; Read it
  AND A                   ; Test it
  JR Z,32447              ; Zero: a short delta follows
  LD D,8                  ; D=8: an absolute coordinate has eight bits
  JP 32539                ; Read it and return
  LD A,(IY+6)             ; A=the number of bits in a short y delta (from the
                          ; picture header)
  LD D,A                  ; D=the number of bits
  CALL 32539              ; Read the delta (left-aligned in A)
  LD D,A                  ; D=the delta
  LD A,(IY+6)             ; A=the number of bits
  SRA D                   ; Shift right, keeping the sign...
  INC A                   ; ...until the delta is right-aligned
  CP 8                    ; ...(8 minus the number of bits times)
  JR NZ,32458             ; Repeat
  LD A,D                  ; A=the signed delta
  ADD A,B                 ; Add it to the old y
  RET                     ; Return

; Read a long x delta
  LD D,1                  ; D=1: read one bit
  CALL 32539              ; Read it
  AND A                   ; Test it
  JR Z,32481              ; Zero: a long delta follows
  LD D,8                  ; D=8: an absolute coordinate has eight bits
  JP 32539                ; Read it and return
  LD A,(IY+7)             ; A=the number of bits in a long x delta (from the
                          ; picture header)
  LD D,A                  ; D=the number of bits
  CALL 32539              ; Read the delta (left-aligned in A)
  LD D,A                  ; D=the delta
  LD A,(IY+7)             ; A=the number of bits
  SRA D                   ; Shift right, keeping the sign...
  INC A                   ; ...until the delta is right-aligned
  CP 8                    ; ...(8 minus the number of bits times)
  JR NZ,32492             ; Repeat
  LD A,D                  ; A=the signed delta
  ADD A,C                 ; Add it to the old x
  RET                     ; Return

; Read a long y delta
  LD D,1                  ; D=1: read one bit
  CALL 32539              ; Read it
  AND A                   ; Test it
  JR Z,32515              ; Zero: a long delta follows
  LD D,8                  ; D=8: an absolute coordinate has eight bits
  JP 32539                ; Read it and return
  LD A,(IY+8)             ; A=the number of bits in a long y delta (from the
                          ; picture header)
  LD D,A                  ; D=the number of bits
  CALL 32539              ; Read the delta (left-aligned in A)
  LD D,A                  ; D=the delta
  LD A,(IY+8)             ; A=the number of bits
  SRA D                   ; Shift right, keeping the sign...
  INC A                   ; ...until the delta is right-aligned
  CP 8                    ; ...(8 minus the number of bits times)
  JR NZ,32526             ; Repeat
  LD A,D                  ; A=the signed delta
  ADD A,B                 ; Add it to the old y
  RET                     ; Return

; The bit-stream pointer
  DEFB 0,0,0

; Read D bits from the picture bit-stream
;
; The bits come back left-aligned: the value is in the top D bits of A and the
; callers shift it down.
;
;  Input:D Number of bits
; Output:A The bits, left-aligned
  PUSH HL                 ; Save HL
  PUSH DE                 ; Save DE
  LD HL,(32536)           ; Pick up the next two bytes of the bit-stream
  LD D,(HL)               ; D=the first byte of the stream
  INC HL                  ; Next byte
  LD E,(HL)               ; E=the second byte
  EX DE,HL                ; HL=the two bytes
  LD A,(32538)            ; Shift them left by the bit position
  INC A                   ; Test the bit position...
  DEC A                   ; ...
  JR Z,32558              ; Zero: the shift is done
  ADD HL,HL               ; Shift the pair left
  JR 32552                ; Shift the pair left one more bit
  POP DE                  ; D=number of bits wanted
  LD A,D                  ; A=the number of bits
  LD L,0                  ; Build a mask of D bits
  SCF                     ; Set the carry
  RR L                    ; Shift a one into the mask
  DEC A                   ; Count down
  JR NZ,32562             ; Repeat until the mask has D bits
  LD A,L                  ; A=the mask
  AND H                   ; Extract the bits
  PUSH AF                 ; Save the value
  LD A,(32538)            ; Advance the bit position by D
  ADD A,D                 ; Add the number of bits to the bit position
  LD HL,(32536)           ; HL=the stream pointer
  CP 8                    ; Past the end of the byte?
  JR C,32587              ; Less than 8: the position is right
  SUB 8                   ; Take off 8
  INC HL                  ; Moving on a byte for each 8 bits
  JR 32578                ; Subtract 8 again
  LD (32538),A            ; Store the new bit position
  LD (32536),HL           ; Store the new pointer
  POP AF                  ; Restore the value
  POP HL                  ; Restore HL
  RET                     ; Return with the bits left-aligned in A (the callers
                          ; shift them down)

; Get the pixel address for (C,B)
;
; Uses ROM PIXEL-ADD.
  PUSH BC                 ; Save BC
  LD A,B                  ; B=y
  CALL 8880               ; Use the ROM's PIXEL-ADD
  INC A                   ; B=the bit position plus one
  LD B,A                  ; ...
  LD A,1                  ; Turn the bit position into a mask
  RRCA                    ; Rotate the mask right
  DJNZ 32605              ; Rotate the mask once for each bit position
  POP BC                  ; Restore BC
  RET                     ; Return

; The line start point
  DEFB 0,0

; Draw a line from the last point to (C,B)
;
; A Bresenham line drawer.
  LD L,C                  ; L=the target x
  LD H,0                  ; H=0
  LD A,(32610)            ; A=the start x (32610)
  LD E,A                  ; E=it
  LD D,H                  ; D=0
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; HL=target x minus start x: the signed x distance
  LD A,L                  ; A=the low byte of the distance
  LD DE,257               ; D=1, E=1: the y step and the x step both start as
                          ; +1
  BIT 7,H                 ; Is the x distance negative?
  JR Z,32635              ; No
  NEG                     ; A=its size
  LD E,255                ; E=255: the x step is -1
  LD C,A                  ; C=the size of the x distance
  PUSH DE                 ; Save the steps
  LD L,B                  ; L=the target y
  LD H,0                  ; H=0
  LD A,(32611)            ; A=the start y (32611)
  LD E,A                  ; E=it
  LD D,H                  ; D=0
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; HL=target y minus start y: the signed y distance
  POP DE                  ; Get the steps back
  LD A,L                  ; A=the low byte of the distance
  BIT 7,H                 ; Is the y distance negative?
  JR Z,32658              ; No
  NEG                     ; A=its size
  LD D,255                ; D=255: the y step is -1
  LD B,A                  ; B=the size of the y distance
  LD A,C                  ; A=the size of the x distance
  CP B                    ; Compare it with the y distance
  JR NC,32673             ; x is the longer: that is the main direction
  LD L,C                  ; y is the longer: L=the x distance (the shorter)
  LD (32694),DE           ; Store the steps in the operand of the LD BC,0 at
                          ; 32693 (self-modifying)
  XOR A                   ; A=0
  LD E,A                  ; E=0: no x step on the main direction
  JP 32681                ; Carry on
  LD L,B                  ; L=the y distance (the shorter)
  LD B,C                  ; B=the x distance (the number of pixels to draw)
  LD (32694),DE           ; Store the steps in the operand of the LD BC,0 at
                          ; 32693 (self-modifying)
  LD D,0                  ; D=0: no y step on the main direction
  LD H,B                  ; H=the length of the main direction
  LD A,B                  ; A=it
  RRA                     ; Halve it: the error term starts half-way
  ADD A,L                 ; Add the shorter distance to the error term
  JR C,32690              ; It overflowed a byte: step sideways
  CP H                    ; Compare with the longer distance
  JR C,32699              ; Smaller: no sideways step this time
  SUB H                   ; Take off the longer distance
  LD C,A                  ; C=the new error term
  EXX                     ; Switch to the alternate registers
  LD BC,0                 ; BC=the step for both directions (set above)
  JP 32703                ; Carry on
  LD C,A                  ; C=the error term
  PUSH DE                 ; Save the main-direction step
  EXX                     ; Switch to the alternate registers
  POP BC                  ; BC=the main-direction step only
  LD A,B                  ; A=the vertical step
  AND A                   ; Test it
  JR Z,32728              ; None: skip the vertical move
  BIT 7,A                 ; Is it negative?
  JR Z,32722              ; No: move down
  DEC H                   ; Up one pixel row
  LD A,H                  ; A=the high byte of the screen address
  AND 7                   ; Pixel row within the character cell
  CP 7                    ; Did the row wrap round to 7 (crossed a character
                          ; boundary)?
  JR Z,32772              ; Yes: adjust the address
  JP 32728                ; No
  INC H                   ; Down one pixel row
  LD A,H                  ; A=the high byte
  AND 7                   ; Pixel row within the character cell
  JR Z,32759              ; Crossed into the next character row: adjust
  LD A,C                  ; A=the horizontal step
  AND A                   ; Test it
  JR Z,32751              ; None: plot the pixel
  BIT 7,A                 ; Is it negative?
  JR NZ,32745             ; Yes: move left
  RRC D                   ; Rotate the pixel mask right
  JP NC,32751             ; Still in the same byte
  INC L                   ; Next byte
  JP 32751                ; Plot the pixel
  RLC D                   ; Rotate the pixel mask left
  JP NC,32751             ; Still in the same byte
  DEC L                   ; Previous byte
  LD A,D                  ; A=the pixel mask
  OR (HL)                 ; Combine it with the screen byte
  LD (HL),A               ; Plot the pixel
  EXX                     ; Switch back to the main registers
  LD A,C                  ; A=the error term
  DJNZ 32684              ; Loop for every pixel of the line
  RET                     ; Return
  LD A,L                  ; A=the low byte
  ADD A,32                ; Down one character row
  LD L,A                  ; L=it
  JR C,32728              ; Carry: this was the last row of the third, so H is
                          ; already right
  LD A,H                  ; A=the high byte
  SUB 8                   ; Take back the 8
  LD H,A                  ; H=it
  JP 32728                ; Carry on
  LD A,L                  ; A=the low byte
  SUB 32                  ; Up one character row
  LD L,A                  ; L=it
  JR C,32728              ; Carry: the borrow means H is already right
  LD A,H                  ; A=the high byte
  ADD A,8                 ; Move up 8 in the high byte
  LD H,A                  ; H=it
  JP 32728                ; Carry on

; Play the theme tune (if A=16)
;
; Plays the list of tune fragments at 32832 via 32866. The stack pointer is
; temporarily moved to 53792.
;
; Input:A SAY flags bits 4-6
TUNE:
  LD (32801),SP           ; Save the stack pointer
  LD SP,53792             ; Use a stack up at 53792
  CP 16                   ; Is the tune wanted?
  JR Z,32803              ; Play it if so
  LD SP,(32801)           ; Restore the stack pointer
  RET                     ; Done

; The saved stack pointer
  DEFB 0,0

; Play the tune fragments listed at 32832
  PUSH IX                 ; Save IX
  LD IX,32832             ; Point IX at the list of tune fragments
  LD L,(IX+0)             ; Pick up the next fragment address
  LD H,(IX+1)             ; H=the high byte of the fragment address
  LD A,L                  ; End of the list?
  OR H                    ; Combine with L: a zero address ends the list
  JR Z,32828              ; Finish if so
  CALL 32866              ; Play the fragment
  INC IX                  ; Next fragment...
  INC IX                  ; ...(2 bytes per entry)
  JR 32809                ; Next fragment
  POP IX                  ; Restore IX
  JR 32796                ; Restore the stack and return

; Theme tune: list of fragments
;
; Addresses of the note lists played by 32803 (terminated by 0).
  DEFW 33051,33148,33173,33202
  DEFW 33051,33271,33308,33271
  DEFW 33345,33051,33173,33173
  DEFW 33202,33386,33386,33447
  DEFW 0

; Play a tune fragment
;
; Each note is four bytes: pitch, duration (2 bytes) and a flags byte. Stops
; early if a key is pressed.
;
; Input:HL Note data
  XOR A                   ; Stop if a key is pressed
  IN A,(254)              ; Read the keyboard
  AND 31                  ; Keep the key bits
  CP 31                   ; No key pressed?
  JR NZ,32976             ; A key is pressed: stop the tune
  LD D,(HL)               ; D=pitch
  XOR A                   ; A pitch of 0 ends the fragment
  CP D                    ; Is the pitch zero?
  JP Z,32976              ; A pitch of zero: the fragment is over
  INC HL                  ; Next byte (the duration)
  LD E,(HL)               ; E=duration
  INC HL                  ; Next byte (the flags)
  LD C,(HL)               ; C=flags
  INC HL                  ; Next byte (the repeat count)
  LD B,(HL)               ; B=repeat count
  INC HL                  ; Next byte (the next note)
  LD A,24                 ; Default border/speaker value
  LD (33000),A            ; Modify the OUT value at 33000
  LD A,C                  ; Bits 4-7 of the flags...
  RRCA                    ; Shift bits 4-7 down...
  RRCA                    ; ...
  RRCA                    ; ...
  RRCA                    ; ...
  AND 15                  ; Keep them
  JR NZ,32906             ; Non-zero: use it as the delay
  LD (33000),A            ; ...override it if non-zero
  INC A                   ; A=1: the default delay
  LD (32930),A            ; Modify the delay at 32930
  LD A,C                  ; C=pitch slide (bits 0-3)
  AND 15                  ; Keep the slide bits
  LD C,A                  ; C=the slide
  PUSH DE                 ; Save DE
  JP 32928                ; Start the note
  PUSH BC                 ; Save BC
  LD B,5                  ; Short pause between repeats
  DJNZ 32920              ; Pause
  JP 32925                ; Pad the timing
  NOP                     ; Pad the timing
  NOP                     ; Pad the timing
  POP BC                  ; Restore BC
  PUSH BC                 ; Save BC
  LD B,4                  ; Delay (modified above)
  NOP                     ; Pad the timing
  NOP                     ; Pad the timing
  NOP                     ; Pad the timing
  CALL 32982              ; Play the note
  LD A,0                  ; Pad the timing
  DJNZ 32934              ; Play the note again for each repeat
  POP BC                  ; Restore BC
  LD A,C                  ; Slide the pitch
  ADD A,D                 ; Add the slide to the pitch
  LD D,A                  ; D=the new pitch
  PUSH AF                 ; Save the carry flag
  BIT 7,C                 ; Up or down?
  JP Z,32958              ; Pitch slide is upward: go on
  POP AF                  ; Restore the carry flag
  JP NC,32977             ; Stop if the pitch wrapped round
  JP 32965                ; Continue
  POP AF                  ; Restore the carry flag
  JP C,32977              ; Stop if the pitch wrapped round
  JP 32965                ; Continue
  LD A,E                  ; Shorten the duration
  SUB C                   ; Take the slide off the duration
  LD E,A                  ; E=the new duration
  LD A,R                  ; A=refresh register (adds a little noise)
  DJNZ 32917              ; Repeat
  POP DE                  ; Restore DE
  JP 32866                ; Next note
  RET                     ; Return
  POP DE                  ; Restore DE
  PUSH DE                 ; Save DE
  JP 32970                ; Finish this note

; Delay and toggle the speaker
  PUSH BC                 ; Save BC
  LD B,(IY+0)             ; (Never used: B is overwritten by the next
                          ; instruction)
  LD B,12                 ; B=12: the fixed delay
  DJNZ 32988              ; Wait about 12 loops
  POP BC                  ; Restore BC
  CALL 32995              ; Toggle the speaker
  RET                     ; Done

; Toggle the speaker with a pulse
  BIT 7,D                 ; Test bit 7 of the pitch
  LD A,0                  ; A=0: speaker off
  LD A,16                 ; A=speaker bit (this operand is modified by 32890)
  JP 33004                ; Pad the timing
  JP 33007                ; Pad the timing
  OUT (254),A             ; Speaker on
  PUSH DE                 ; Save DE
  AND 127                 ; Mask the pitch (A is overwritten below, so this has
                          ; no effect)
  LD A,D                  ; A=the pitch
  LD D,A                  ; D=pitch
  DEC D                   ; Delay for half a cycle
  CALL 33032              ; Wait a half cycle
  JR NZ,33014             ; Repeat until the half cycle is over
  LD A,0                  ; A=0: speaker bit off
  OUT (254),A             ; Speaker off
  DEC E                   ; Delay for the other half
  CALL 33032              ; Wait a half cycle
  JR NZ,33024             ; Repeat until the half cycle is over
  POP DE                  ; Restore DE
  RET                     ; Return

; Short delay
  PUSH BC                 ; Save BC
  NOP                     ; Timing padding
  NOP                     ; Waste 4 T-states
  NOP                     ; Waste 4 T-states
  NOP                     ; Waste 4 T-states
  POP BC                  ; Restore BC
  PUSH BC                 ; Save BC
  NOP                     ; Waste 4 T-states
  NOP                     ; Waste 4 T-states
  NOP                     ; Waste 4 T-states
  NOP                     ; Waste 4 T-states
  POP BC                  ; Restore BC
  PUSH BC                 ; Save BC
  NOP                     ; Waste 4 T-states
  NOP                     ; Waste 4 T-states
  NOP                     ; Waste 4 T-states
  NOP                     ; Waste 4 T-states
  POP BC                  ; Restore BC
  RET                     ; Return

; Theme tune: note data
;
; Used by 32866.
  DEFB 13,14,16,131,115,115,0,16
  DEFB 13,14,16,196,13,14,16,131
  DEFB 115,115,0,16,12,13,16,139
  DEFB 115,115,0,16,12,13,16,208
  DEFB 12,13,16,139,115,115,0,16
  DEFB 12,12,16,147,115,115,0,16
  DEFB 12,12,16,110,115,115,0,12
  DEFB 12,13,16,69,12,12,16,73
  DEFB 115,115,0,16,7,8,16,165
  DEFB 7,8,16,165,115,115,0,16
  DEFB 12,12,16,110,12,12,16,110
  DEFB 12,12,16,110,115,115,0,16
  DEFB 0,12,12,16,220,115,115,0
  DEFB 12,7,8,16,165,7,8,16
  DEFB 165,7,8,16,110,115,115,0
  DEFB 16,0,12,12,16,220,115,115
  DEFB 0,12,7,8,16,165,115,115
  DEFB 0,12,8,8,16,104,7,8
  DEFB 16,110,115,115,0,12,0,12
  DEFB 12,16,110,115,115,0,12,12
  DEFB 12,16,110,115,115,0,12,10
  DEFB 10,16,131,115,115,0,12,10
  DEFB 10,16,131,115,115,0,12,11
  DEFB 11,16,78,10,11,16,82,10
  DEFB 10,16,87,115,115,0,8,10
  DEFB 11,16,124,115,115,0,8,12
  DEFB 12,16,73,12,13,16,69,115
  DEFB 115,0,16,0,10,11,16,124
  DEFB 115,115,0,8,10,11,16,124
  DEFB 115,115,0,8,10,11,16,124
  DEFB 115,115,0,8,12,12,16,73
  DEFB 13,14,16,65,115,115,0,16
  DEFB 0,12,12,16,110,115,115,0
  DEFB 8,12,12,16,110,115,115,0
  DEFB 8,12,12,16,110,115,115,0
  DEFB 8,13,14,16,65,14,14,16
  DEFB 62,115,115,0,16,0,10,11
  DEFB 16,124,115,115,0,8,10,11
  DEFB 16,124,115,115,0,8,10,11
  DEFB 16,124,115,115,0,8,11,11
  DEFB 16,78,12,12,16,73,12,13
  DEFB 16,69,115,115,0,12,0,10
  DEFB 10,16,175,115,115,0,12,10
  DEFB 10,16,175,10,10,16,175,115
  DEFB 115,0,8,10,10,16,175,115
  DEFB 115,0,8,11,11,16,117,115
  DEFB 115,0,8,10,10,16,131,8
  DEFB 9,16,147,115,115,0,6,10
  DEFB 10,16,131,8,9,16,147,115
  DEFB 115,0,12,0,12,12,16,147
  DEFB 115,115,0,12,12,12,16,147
  DEFB 12,12,16,147,115,115,0,16
  DEFB 13,14,16,98,12,12,16,110
  DEFB 10,11,16,124,115,115,0,8
  DEFB 13,14,16,98,12,12,16,110
  DEFB 10,11,16,124,115,115,0,8
  DEFB 10,10,16,131,115,115,0,6
  DEFB 13,14,16,98,12,12,16,110
  DEFB 115,115,0,6,13,14,16,98
  DEFB 12,12,16,110,115,115,0,8
  DEFB 10,10,16,131,115,115,0,8
  DEFB 13,14,16,98,115,115,0,8
  DEFB 10,10,16,131,0

; VM variables
;
; The VM has 84 32-bit signed variables, each holding a fixed-point number with
; two decimal places (so 1.00 is stored as 100). Variables 37-64 are constants;
; variables 65-83 are the table of initial values for v0-v18 copied by
; INITVARS, but the script also uses v68-v72 as the constants 40, 10, 2.5, 1
; and 0. See the variables page.
  DEFB 0,0,0,0            ; v0 (StartClients): Number of clients at the start
                          ; of the game (400) [0]
  DEFB 0,0,0,0            ; v1 (Squeezed): Number of clients squeezed this year
                          ; [0]
  DEFB 0,0,0,0            ; v2 (Raided): Amount (in grand) taken by the cops in
                          ; a raid [0]
  DEFB 0,0,0,0            ; v3 (Hoods): Number of hoods in the mob (shown on
                          ; the status line) [0]
  DEFB 0,0,0,0            ; v4 (Killed): Number of hoods rubbed out last year
                          ; [0]
  DEFB 0,0,0,0            ; v5 (Price): Average protection payment per client
                          ; [0]
  DEFB 0,0,0,0            ; v6 (Year): Current year (starts at 1) [0]
  DEFB 0,0,0,0            ; v7 (Dough): Dough in the safe, in thousands of
                          ; dollars (shown on the status line) [0]
  DEFB 0,0,0,0            ; v8 (Clients): Number of clients (shown on the
                          ; status line as CUSTOMERS) [0]
  DEFB 0,0,0,0            ; v9 (Recruits): Number of hoods recruited last year
                          ; [0]
  DEFB 0,0,0,0            ; v10 (TotalKilled): Total number of hoods killed
                          ; during the game [0]
  DEFB 0,0,0,0            ; v11 (Blunders): Number of blunders (silly answers)
                          ; made this year [0]
  DEFB 0,0,0,0            ; v12 (TotalBlunders): Total number of blunders made
                          ; during the game [0]
  DEFB 0,0,0,0            ; v13 (HoodYears): Sum of the mob size over all years
                          ; [0]
  DEFB 0,0,0,0            ; v14 (Loan): Loan from Nick the Greek (in grand) [0]
  DEFB 0,0,0,0            ; v15 (Score): Final score (percentage) [0]
  DEFB 0,0,0,0            ; v16 (TotalTakings): Total protection takings [0]
  DEFB 0,0,0,0            ; v17 (TotalProfit): Total profit [0]
  DEFB 0,0,0,0            ; v18 (ClientYears): Sum of the number of clients
                          ; over all years [0]
  DEFB 0,0,0,0            ; v19 (Bought): Number of clients bought from the
                          ; syndicate this year [0]
  DEFB 0,0,0,0            ; v20 (Sold): Number of clients sold to the syndicate
                          ; this year [0]
  DEFB 0,0,0,0            ; v21 (Unsqueezed): Number of clients available to be
                          ; squeezed [0]
  DEFB 0,0,0,0            ; v22 (ClientsLeft): Number of clients that would be
                          ; left after a sale [0]
  DEFB 0,0,0,0            ; v23 (Ammo): Amount spent on artillery and ammo this
                          ; year [0]
  DEFB 0,0,0,0            ; v24 (FedsKilled): Number of recruits killed in the
                          ; shootout with the feds [0]
  DEFB 0,0,0,0            ; v25 (Takings): Protection takings this year [0]
  DEFB 0,0,0,0            ; v26 (Profit): Profit this year (after Rocco has
                          ; taken his cut) [0]
  DEFB 0,0,0,0            ; v27 (Interest): Interest rate on Nick the Greek's
                          ; loan (percent) [0]
  DEFB 0,0,0,0            ; v28 (HoodGrowth): Percentage growth of the mob over
                          ; the game [0]
  DEFB 0,0,0,0            ; v29 (ClientGrowth): Percentage growth of the client
                          ; list over the game [0]
  DEFB 0,0,0,0            ; v30 (Handout): Handout paid to keep the hoods loyal
                          ; [0]
  DEFB 0,0,0,0            ; v31 (Bribe): Bribe paid to Rocco's mob [0]
  DEFB 0,0,0,0            ; v32 (Kickback): Annual kickback to the cops [0]
  DEFB 0,0,0,0            ; v33 (Tmp): Scratch variable [0]
  DEFB 0,0,0,0            ; v34 (ClientCost): Price of a client this year (in
                          ; grand) [0]
  DEFB 0,0,0,0            ; v35 (Input): Number entered by the player (x100
                          ; fixed point; see GETNUMBER) [0]
  DEFB 0,0,0,0            ; v36 (Years): Number of years the game will last
                          ; (7-11, chosen at random by INITVARS) [0]
  DEFB 128,56,1,0         ; v37 (K800): Constant: 800 [800]
  DEFB 160,134,1,0        ; v38 (K1000): Constant: 1000 [1000]
  DEFB 251,255,255,255    ; v39 (Km005): Constant: -0.05 [-0.05]
  DEFB 246,255,255,255    ; v40 (Km010): Constant: -0.1 [-0.1]
  DEFB 50,0,0,0           ; v41 (K05): Constant: 0.5 [0.5]
  DEFB 150,0,0,0          ; v42 (K15): Constant: 1.5 [1.5]
  DEFB 200,0,0,0          ; v43 (K2): Constant: 2 [2]
  DEFB 44,1,0,0           ; v44 (K3): Constant: 3 [3]
  DEFB 94,1,0,0           ; v45 (K35): Constant: 3.5 [3.5]
  DEFB 144,1,0,0          ; v46 (K4): Constant: 4 [4]
  DEFB 244,1,0,0          ; v47 (K5): Constant: 5 [5]
  DEFB 88,2,0,0           ; v48 (K6): Constant: 6 [6]
  DEFB 188,2,0,0          ; v49 (K7): Constant: 7 [7]
  DEFB 32,3,0,0           ; v50 (K8): Constant: 8 [8]
  DEFB 132,3,0,0          ; v51 (K9): Constant: 9 [9]
  DEFB 76,4,0,0           ; v52 (K11): Constant: 11 [11]
  DEFB 176,4,0,0          ; v53 (K12): Constant: 12 [12]
  DEFB 20,5,0,0           ; v54 (K13): Constant: 13 [13]
  DEFB 220,5,0,0          ; v55 (K15b): Constant: 15 [15]
  DEFB 164,6,0,0          ; v56 (K17): Constant: 17 [17]
  DEFB 108,7,0,0          ; v57 (K19): Constant: 19 [19]
  DEFB 208,7,0,0          ; v58 (K20): Constant: 20 [20]
  DEFB 196,9,0,0          ; v59 (K25): Constant: 25 [25]
  DEFB 172,13,0,0         ; v60 (K35b): Constant: 35 [35]
  DEFB 136,19,0,0         ; v61 (K50): Constant: 50 [50]
  DEFB 112,23,0,0         ; v62 (K60): Constant: 60 [60]
  DEFB 172,38,0,0         ; v63 (K99): Constant: 99 [99]
  DEFB 16,39,0,0          ; v64 (K100): Constant: 100 [100]
  DEFB 64,156,0,0         ; v65 (v65): Initial value of v0 (part of the table
                          ; at 33812); not otherwise used [400]
  DEFB 48,117,0,0         ; v66 (v66): Initial value of v1 (part of the table
                          ; at 33812); not otherwise used [300]
  DEFB 76,29,0,0          ; v67 (v67): Initial value of v2 (part of the table
                          ; at 33812); not otherwise used [75]
  DEFB 160,15,0,0         ; v68 (K40): Initial value of v3 (part of the table
                          ; at 33812); also used as the constant 40 [40]
  DEFB 232,3,0,0          ; v69 (K10): Initial value of v4 (part of the table
                          ; at 33812); also used as the constant 10 [10]
  DEFB 250,0,0,0          ; v70 (K25c): Initial value of v5 (part of the table
                          ; at 33812); also used as the constant 2.5 [2.5]
  DEFB 100,0,0,0          ; v71 (K1): Initial value of v6 (part of the table at
                          ; 33812); also used as the constant 1 [1]
  DEFB 0,0,0,0            ; v72 (K0): Initial value of v7 (part of the table at
                          ; 33812); also used as the constant 0 [0]
  DEFB 64,156,0,0         ; v73 (v73): Initial value of v8 (part of the table
                          ; at 33812); not otherwise used [400]
  DEFB 232,3,0,0          ; v74 (v74): Initial value of v9 (part of the table
                          ; at 33812); not otherwise used [10]
  DEFB 0,0,0,0            ; v75 (v75): Initial value of v10 (part of the table
                          ; at 33812); not otherwise used [0]
  DEFB 0,0,0,0            ; v76 (v76): Initial value of v11 (part of the table
                          ; at 33812); not otherwise used [0]
  DEFB 0,0,0,0            ; v77 (v77): Initial value of v12 (part of the table
                          ; at 33812); not otherwise used [0]
  DEFB 0,0,0,0            ; v78 (v78): Initial value of v13 (part of the table
                          ; at 33812); not otherwise used [0]
  DEFB 0,0,0,0            ; v79 (v79): Initial value of v14 (part of the table
                          ; at 33812); not otherwise used [0]
  DEFB 0,0,0,0            ; v80 (v80): Initial value of v15 (part of the table
                          ; at 33812); not otherwise used [0]
  DEFB 0,0,0,0            ; v81 (v81): Initial value of v16 (part of the table
                          ; at 33812); not otherwise used [0]
  DEFB 0,0,0,0            ; v82 (v82): Initial value of v17 (part of the table
                          ; at 33812); not otherwise used [0]
  DEFB 0,0,0,0            ; v83 (v83): Initial value of v18 (part of the table
                          ; at 33812); not otherwise used [0]

; VM flags
;
; Nine flag bytes that the script tests and sets with IFPEEKEQ, IFPEEKNE and
; POKE, followed by the game status flag and some workspace used by the speech
; bubble code. INITVARS sets the nine flags and the status flag to 1 at the
; start of each game; the values below are those in the saved game image.
  DEFB 0                  ; Flag 0: the feds flag. 1 normally, 2 when the feds
                          ; have been tipped off (set at the end of the
                          ; recruiting step, tested in the next report; see the
                          ; economics page)
  DEFB 0                  ; Flag 1: set to 2 when the ammo comes to 1 grand per
                          ; hood or less (adequate or not), but never tested
  DEFB 0                  ; Flag 2: set to 2 when the game ends early (the mob
                          ; walks out, Nick the Greek, no money left for ammo,
                          ; cousin Abe, an empty safe, or the hit man); the end
                          ; of the game then skips the farewell from the hoods
  DEFB 0                  ; Flag 3: Rocco. Set to 2 when Rocco gets uppity;
                          ; next year's report then halves the takings (if they
                          ; are 3 grand or more) and changes its wording. Reset
                          ; to 1 after the report
  DEFB 0                  ; Flag 4: the contract. 2 when the hit man is coming,
                          ; 3 when he has won the shootout (set by HITMAN);
                          ; reset to 1 afterwards
  DEFB 0                  ; Flag 5: chooses between two openings of the
                          ; contract warning; never changed from 1, so the
                          ; second opening is never used
  DEFB 0                  ; Flag 6: the ammo flag. 2 when last year's ammo was
                          ; inadequate and not forgiven (cousin Abe then takes
                          ; over), 1 otherwise
  DEFB 0                  ; Flag 7: 1 in the first year, set to 2 at the end of
                          ; every year
  DEFB 0                  ; Flag 8: the type of the last number entered, set by
                          ; 27835 (1 negative, 2 zero, 3 exactly 0.01, 4
                          ; anything else)
  DEFB 0                  ; Game status flag: non-zero ends the main loop at
                          ; PLAYYEAR
  DEFB 0,0                ; Default sub-message address
  DEFB 0,0                ; Saved IY
  DEFB 121,132            ; Pointer to this year's bubble layout table (33913
                          ; or 33925)
  DEFB 0,0                ; The current bubble layout
  DEFB 0                  ; Layout-unchanged flag
  DEFB 0,0                ; Text width

; Speech bubble layouts
;
; Each entry is 4 bytes: a chance value (compared with a random number from 0
; to 100), the address of the picture, and a byte that is always 0. 33909 is
; the fixed "answer" layout. 33913 and 33925 start the two tables, one of which
; PLAYYEAR picks at random each year; the SAY routine (SAY) then takes the
; first entry in that table whose chance value is above a new random number.
; See Which background you get on the trivia page for the resulting odds.
  DEFB 0,134,252,0        ; Fixed "answer" layout: picture 64646 (close-up of a
                          ; hood)
  DEFB 30,49,229,0        ; First table, below 30: picture 58673 (a figure in a
                          ; doorway)
  DEFB 70,5,232,0         ; First table, below 70: picture 59397 (two hoods at
                          ; a table)
  DEFB 101,239,224,0      ; First table, otherwise: picture 57583 (a man in a
                          ; hat at a table)
  DEFB 33,113,248,0       ; Second table, below 33: picture 63601 (hoods and a
                          ; car in the city)
  DEFB 66,110,236,0       ; Second table, below 66: picture 60526 (the getaway
                          ; car from above)
  DEFB 101,185,240,0      ; Second table, otherwise: picture 61625 (two figures
                          ; at the waterfront)

; Initialise the game variables
;
; Copies the initial values of v0-v18 from the table at 33812, sets the nine VM
; flags at 33888 to 1 and chooses the length of the game: v36 = 7 + 4 x (a
; random number from 0 to 1.00), which is not rounded (see the bugs page).
INITVARS:
  LD HL,33812             ; Copy the initial values of v0-v18...
  LD DE,33552             ; ...from the table at 33812 (which doubles as
                          ; variables v65-v83)
  LD BC,76                ; BC=76: nineteen four-byte variables
  LDIR                    ; Copy them into place
  LD HL,33888             ; Set the nine VM flag bytes at 33888...
  LD B,10                 ; B=10: nine VM flags plus the game status flag
  LD (HL),1               ; ...and the game status flag to 1
  INC HL                  ; Next flag
  DJNZ 33953              ; Loop for all ten
  LD DE,100               ; BCDE=1.00
  LD BC,0                 ; BC=0: the high half of 1.00
  CALL 30482              ; Get a random number in BCDE (0..1.00)
  EXX                     ; Switch to the alternate registers to hold the
                          ; multiplier
  LD DE,400               ; BC'DE'=4.00
  LD BC,0                 ; BC'=0: the high half of 4.00
  CALL 30657              ; Multiply
  EXX                     ; Switch back
  LD DE,700               ; BC'DE'=7.00
  LD BC,0                 ; BC=0: the high half of 7.00
  CALL 30441              ; Add
  LD L,36                 ; Store the result in v36 (the length of the game in
                          ; years)
  CALL STOREVAR           ; Store BCDE in v36: the length of the game, 7 + 4 x
                          ; (a random number), an unrounded number of years
  RET                     ; Return

; The sequence-finished flag
  DEFB 0

; VM native: "A year goes by ......" animation
;
; Installs the IM2 interrupt routine at ISR1 (via the jump at INTJUMP and the
; vector table at 53504) and then plays one of two short animations chosen at
; random: the bar-room scene (step table at 36348) or the getaway car (step
; table at 34298).
;
; Nothing in the game chooses between them: not the year, the hoods, the cash
;         or what happened in the year. The choice is one call of the random
;         routine (RANDOMPM, limit 100); a result below 50 gives the bar room.
;         That is not an even split, because the routine is not uniform (see
;         RANDOM): counting the 256 raw values gives 154 for the bar room and
;         102 for the car, about 60% to 40%.
;
YEARGOESBY:
  DI                      ; Interrupts off while the animation interrupt
                          ; routine is installed
  LD HL,ISR1              ; Point the interrupt jump at INTJUMP...
  LD (53457),HL           ; ...at the interrupt routine at ISR1
  LD A,209                ; Point I at the vector table at 53504
  LD I,A                  ; Point the interrupt vector register at the table at
                          ; 53504
  IM 2                    ; Select interrupt mode 2
  EI                      ; Enable interrupts: ISR1 now runs fifty times a
                          ; second
  XOR A                   ; Clear the sequence-finished flag
  LD (33993),A            ; Clear the "animation finished" flag
  LD A,100                ; Pick one of the two animations at random
  CALL RANDOMPM           ; A=a random number from 0 to 100 (not evenly spread:
                          ; below 50 about 60% of the time)
  LD IX,36348             ; Bar-room animation...
  CP 50                   ; Below 50?
  JR C,34029              ; ...if the number is below 50
  LD IX,34298             ; Otherwise the getaway car animation
  CALL RUNSTEPS           ; Run the animation
  DI                      ; Interrupts off again
  LD A,63                 ; Restore I (63 is its normal value)
  LD I,A                  ; Put I back as the ROM expects it
  IM 1                    ; Back to interrupt mode 1
  RET                     ; Return

; Run the steps of an animation
;
; IX points at a list of step routine addresses. Once per tick (set by the
; interrupt routine) the current step is called; while it returns with the zero
; flag reset it is called again on the next tick, otherwise IX moves on to the
; next step. The sequence ends when 33993 is set.
;
; Input:IX Step table
RUNSTEPS:
  LD A,(33993)            ; Has the animation finished?
  AND A                   ; Test the flag
  RET NZ                  ; Return if so
  EI                      ; Enable interrupts
  HALT                    ; Wait for an interrupt
  EI                      ; And again, to be sure they are on
  LD L,(IX+0)             ; Pick up the address of the current step routine
  LD H,(IX+1)             ; H=the high byte of the step routine's address
  CALL 34065              ; Call it
  JR NZ,RUNSTEPS          ; Keep calling it until it returns with the zero flag
                          ; set
  INC IX                  ; Then move to the next step
  INC IX                  ; Next step
  JR RUNSTEPS             ; Loop back to wait for the interrupt and run the
                          ; step

; Jump to the address in HL
  JP (HL)                 ; Jump to the step routine

; The interrupt countdown
  DEFB 0,0,0

; Interrupt routine for the animations
;
; Counts down 34066; when it reaches zero it reloads it from 34067 and sets the
; tick flag at 34068.
ISR1:
  PUSH AF                 ; Save AF
  LD A,(34066)            ; Decrement the interrupt countdown
  DEC A                   ; One tick less
  LD (34066),A            ; Store it
  JR NZ,34090             ; Jump unless it has reached zero
  LD A,(34067)            ; Reload the countdown
  LD (34066),A            ; Store it
  LD A,1                  ; Set the tick flag
  LD (34068),A            ; Set the tick flag
  POP AF                  ; Restore AF
  RETI                    ; Return from the interrupt

; Draw a 2-cell-wide sprite (no mask)
;
; Copies B=2 bytes per pixel row from DE to the screen at HL; the first byte at
; DE is the height.
  LD B,2                  ; B=2: two bytes per pixel row
  JR 34099                ; Carry on with the common code

; Draw a 3-cell-wide sprite (no mask)
;
; As 34093 but 3 bytes wide.
  LD B,3                  ; B=3: three bytes per pixel row
  LD A,(DE)               ; A=the height of the sprite (the first byte of the
                          ; sprite data)
  INC DE                  ; Move to the graphic data
  LD C,A                  ; C=the number of pixel rows
  PUSH BC                 ; Save the row counter and width
  PUSH HL                 ; Save the screen address
  LD A,(DE)               ; A=a byte of the graphic
  LD (HL),A               ; Put it on the screen
  INC DE                  ; Next graphic byte
  INC L                   ; Next screen column
  DJNZ 34104              ; Loop for every byte of the row
  POP HL                  ; Restore the screen address
  POP BC                  ; Restore the row counter
  INC H                   ; Down one pixel row
  LD A,H                  ; A=the high byte
  AND 7                   ; Crossed into a new character row?
  JR Z,34122              ; Yes: adjust the address
  DEC C                   ; One row less
  JR NZ,34102             ; Loop for every pixel row
  RET                     ; Return
  LD A,L                  ; A=the low byte
  ADD A,32                ; Down one character row
  LD L,A                  ; L=the new low byte
  JR C,34118              ; Carry: the next third of the screen (H is already
                          ; right)
  LD A,H                  ; A=the high byte
  SUB 8                   ; Take back the 8 added by the pixel row steps
  LD H,A                  ; H=it
  JP 34118                ; Carry on

; Prepare a pre-shifted masked sprite
;
; Copies the 32x32 sprite whose address is at HL into the buffer at DE, giving
; each row of 4 graphic bytes a mask byte of 255 and a spare 0 byte, then
; shifts the whole buffer right A pixels.
;
; This routine has a serious bug: it leaves the buffer address on the stack
;      (PUSH DE ... POP HL; PUSH HL) and so, when A is 0, the RET Z at 34164
;      "returns" into the sprite buffer and the CPU executes the graphic data.
;      See the bugs page.
;
; Input:A Shift (0-7) DE Buffer (24192 or 24384) HL Pointer to the sprite
; address
PRESHIFT:
  PUSH DE                 ; Push the buffer address (this is the problem)
  LD E,(HL)               ; Pick up the address of the sprite graphic
  INC HL                  ; Next byte
  LD D,(HL)               ; D=the high byte of the sprite's graphic address
  POP HL                  ; HL=buffer address
  PUSH HL                 ; Leave it on the stack (above the return address)
  EX DE,HL                ; HL=graphic, DE=buffer
  PUSH AF                 ; Save the shift count
  XOR A                   ; A=0
  EXX                     ; Switch to the alternate registers
  LD B,32                 ; 32 pixel rows
  EXX                     ; Switch back
  LD BC,4                 ; Copy the 4 graphic bytes of this row
  LDIR                    ; Copy the four graphic bytes of the row
  DEC A                   ; A=255
  LD (DE),A               ; Add a mask byte of 255
  INC DE                  ; Next buffer byte
  INC A                   ; A=0
  LD (DE),A               ; Add a spare byte of 0
  INC DE                  ; Next buffer byte
  EXX                     ; Switch to the alternate registers (for the row
                          ; counter)
  DJNZ 34147              ; Next row
  POP AF                  ; Restore the shift count
  AND A                   ; Is it zero?
  RET Z                   ; BUG: return to the buffer address left on the stack
                          ; if so
  LD C,A                  ; C=shift count
  POP HL                  ; HL=buffer
  PUSH HL                 ; Save the buffer address
  LD B,32                 ; 32 rows
  SCF                     ; Rotate a 1 into the mask...
  RR (HL)                 ; Shift the mask byte right (the carry brings in a 1)
  INC HL                  ; Skip to the next mask byte
  INC HL                  ; (rows are 6 bytes long)
  RR (HL)                 ; Shift the second mask byte
  INC HL                  ; Skip on
  INC HL                  ; ...
  RR (HL)                 ; Shift the third mask byte
  DEC HL                  ; Back to the first graphic byte
  DEC HL                  ; ...
  DEC HL                  ; ...
  OR A                    ; ...and a 0 into the graphic
  RR (HL)                 ; Shift the first graphic byte (a 0 comes in)
  INC HL                  ; Next graphic byte
  INC HL                  ; ...
  RR (HL)                 ; Shift the second graphic byte
  INC HL                  ; Next graphic byte
  INC HL                  ; ...
  RR (HL)                 ; Shift the third graphic byte
  INC HL                  ; Next row
  DJNZ 34170              ; Next row
  DEC C                   ; One pixel of shift less
  JR NZ,34166             ; Repeat for each pixel of the shift
  POP HL                  ; Drop the buffer address
  RET                     ; Return properly
  LD C,32                 ; C=32 pixel rows
  LD B,3                  ; B=3 bytes per row
  LD A,(DE)               ; A=the screen byte
  EXX                     ; Switch to the alternate registers
  LD (HL),A               ; Save it in the background store
  INC HL                  ; Next store byte
  EXX                     ; Switch back
  AND (HL)                ; AND with the mask
  INC HL                  ; Next byte of the sprite buffer
  OR (HL)                 ; OR in the graphic
  EX AF,AF'               ; Save the result in A'
  LD A,E                  ; A=the screen column
  AND 31                  ; Column bits
  CP 30                   ; Is it column 30 or more?
  JR NC,34225             ; Yes: do not draw (off the right of the scene)
  EX AF,AF'               ; Get the result back
  LD (DE),A               ; Draw it
  INC HL                  ; Next sprite buffer byte
  INC E                   ; Next column
  DJNZ 34207              ; Loop for three bytes
  DEC E                   ; Back to the first column
  DEC E                   ; ...
  DEC E                   ; ...
  INC D                   ; Down one pixel row
  LD A,D                  ; A=the high byte
  AND 7                   ; Crossed into the next character row?
  JR Z,34242              ; Yes: adjust
  DEC C                   ; One row less
  JR NZ,34205             ; Loop for every row
  RET                     ; Return
  LD A,E                  ; A=the low byte
  ADD A,32                ; Down one character row
  LD E,A                  ; E=the new low byte
  JR C,34238              ; Carry: next third (D is right)
  LD A,D                  ; A=the high byte
  SUB 8                   ; Take back the 8
  LD D,A                  ; D=it
  JP 34238                ; Carry on
  LD C,32                 ; C=32 pixel rows
  LD B,3                  ; B=3 bytes per row
  LD A,(HL)               ; A=a saved background byte
  LD (DE),A               ; Put it back on the screen
  INC E                   ; Next column
  INC HL                  ; Next saved byte
  DJNZ 34259              ; Loop for three bytes
  DEC E                   ; Back to the first column
  DEC E                   ; ...
  DEC E                   ; ...
  INC D                   ; Down one pixel row
  LD A,D                  ; A=the high byte
  AND 7                   ; Crossed into the next character row?
  JR Z,34278              ; Yes: adjust
  DEC C                   ; One row less
  JR NZ,34257             ; Loop for every row
  RET                     ; Return
  LD A,E                  ; A=the low byte
  ADD A,32                ; Down one character row
  LD E,A                  ; E=the new low byte
  JR C,34274              ; Carry: next third
  LD A,D                  ; A=the high byte
  SUB 8                   ; Take back the 8
  LD D,A                  ; D=it
  JP 34274                ; Carry on

; Getaway car animation: counters
  DEFB 0,0,0,0,0,0,0

; Getaway car animation: step table
;
; Used by RUNSTEPS.
  DEFW 34318,34455,34481,34455
  DEFW 34513,34537,34558,34579
  DEFW 34600,34440

; Getaway car animation: step 1 (set up)
;
; Draws the street picture at 55692 and initialises the positions and timers of
; the car and the hoods.
  XOR A                   ; A=0
  OUT (254),A             ; Black border
  LD HL,55692             ; HL=the compressed picture of the street
  CALL DRAWCPIC           ; Draw it
  LD HL,19482             ; HL=the screen address of the first hood's start
                          ; position
  LD (37101),HL           ; Store it
  LD HL,18465             ; HL=the screen address of the second hood's start
                          ; position
  LD (37933),HL           ; Store it
  LD HL,37109             ; HL=the first hood's frame list (37109)
  LD (37107),HL           ; Store it
  LD HL,37941             ; HL=the second hood's frame list (37941)
  LD (37939),HL           ; Store it
  LD HL,52311             ; HL=the screen address where the car starts (52311,
                          ; with the left-clip flag in bit 7 of H)
  LD (38789),HL           ; Store it as the car's position
  XOR A                   ; A=0
  LD (37105),A            ; The first hood's pixel shift is 0
  LD (37937),A            ; The second hood's pixel shift is 0
  LD (38791),A            ; The car's pixel shift is 0
  LD A,10                 ; A=10
  LD (34292),A            ; The first hood waits 10 steps before moving
  LD (34067),A            ; Set the reload value of the interrupt countdown
                          ; (one tick every 10 interrupts)
  LD (34066),A            ; Set the countdown
  LD (34295),A            ; Figure counter 34295 starts at 10
  LD A,9                  ; A=9
  LD (34291),A            ; The first hood moves every 9 ticks
  LD A,13                 ; A=13
  LD (34293),A            ; The second hood moves every 13 ticks
  LD A,8                  ; A=8
  LD (34296),A            ; Counter for the figure at 17728
  LD (34297),A            ; Counter for the figure's delay
  LD A,3                  ; A=3
  LD (34294),A            ; Step counter
  LD HL,(37107)           ; HL=the first hood's frame list
  INC HL                  ; Skip the first entry
  INC HL                  ; ...
  LD A,(37105)            ; A=the first hood's pixel shift
  LD DE,24384             ; DE=the first hood's sprite buffer (24384)
  CALL PRESHIFT           ; Prepare the shifted sprite
  CALL 34779              ; Draw the first hood
  LD HL,(37939)           ; HL=the second hood's frame list
  INC HL                  ; Skip the first entry
  INC HL                  ; ...
  LD A,(37937)            ; A=the second hood's pixel shift
  LD DE,24192             ; DE=the second hood's sprite buffer (24192)
  CALL PRESHIFT           ; Prepare the shifted sprite
  CALL 34798              ; Draw the second hood
  XOR A                   ; A=0: this step is complete
  RET                     ; Return

; Getaway car animation: last step
;
; Sets 33993 to end the animation, then keeps scrolling the car off the screen.
  LD A,1                  ; A=1
  LD (33993),A            ; Mark the animation as finished
  LD A,(38791)            ; A=the car's pixel shift
  AND A                   ; Test it
  RET Z                   ; Done if it is at a byte boundary
  CALL 35000              ; Otherwise keep scrolling the car
  JR 34440                ; Check again

; Getaway step 2
  CALL 34862              ; Draw the next frame of the street animation
  CALL 34759              ; Restore the background behind the second hood
  CALL 34798              ; Draw the second hood
  CALL 34817              ; Draw the five-byte-wide graphic
  CALL 34707              ; Move the second hood on
  LD A,(37933)            ; A=the second hood's screen address
  AND 31                  ; Column
  CP 18                   ; Column 18?
  RET Z                   ; Yes: this step is not finished (Z set)
  CP 30                   ; Column 30?
  RET                     ; Return (Z set when the hood has reached column 30)

; Getaway step 3
  CALL 34862              ; Draw the next frame of the street animation
  CALL 34769              ; Restore the background behind the first hood
  CALL 34779              ; Draw the first hood
  CALL 34759              ; Restore the background behind the second hood
  CALL 34798              ; Draw the second hood
  CALL 34817              ; Draw the five-byte-wide graphic
  CALL 34643              ; Move the first hood on
  CALL 34707              ; Move the second hood on
  LD A,(37101)            ; A=the first hood's screen address
  AND 31                  ; Column
  CP 30                   ; Column 30?
  RET                     ; Return (Z set when the first hood has reached
                          ; column 30)

; Getaway step 5
  CALL 34862              ; Draw the next frame of the street animation
  CALL 34611              ; Scroll the car and redraw it
  LD HL,(38789)           ; HL=the car's screen address
  LD A,L                  ; A=the low byte
  AND 31                  ; Column
  CP 20                   ; Column 20?
  RET NZ                  ; No: keep going
  BIT 7,H                 ; Is the left-clip flag set?
  RET NZ                  ; Yes: keep going
  LD A,(38791)            ; A=the car's pixel shift
  CP 4                    ; Shift 4?
  RET                     ; Return (Z set when the car is in position)

; Getaway step 6
  CALL 34862              ; Draw the next frame of the street animation
  CALL 35251              ; Draw the next frame of the figure at 18838
  RET NZ                  ; Return if the figure's frame did not change
  LD A,(34294)            ; A=the step counter
  DEC A                   ; One less
  LD (34294),A            ; Store it
  RET NZ                  ; Return if not zero
  LD A,5                  ; A=5
  LD (34294),A            ; Reload the step counter
  RET                     ; Return (Z set when the counter ran out)

; Getaway step 7
  CALL 34862              ; Draw the next frame of the street animation
  CALL 35366              ; Draw the next frame of the figure at 17728
  CALL 35284              ; Play the delay sound and animate the figures
  CALL 35251              ; Draw the next frame of the figure at 18838
  RET NZ                  ; Return if the figure's frame did not change
  LD A,(34294)            ; A=the step counter
  DEC A                   ; One less
  LD (34294),A            ; Store it
  RET                     ; Return (Z set when the counter ran out)

; Getaway step 8
  CALL 34862              ; Draw the next frame of the street animation
  CALL 34611              ; Scroll the car and redraw it
  CALL 35366              ; Draw the next frame of the figure at 17728
  LD HL,(38789)           ; HL=the car's screen address
  LD A,L                  ; A=the low byte
  AND 31                  ; Column
  CP 30                   ; Column 30?
  RET NZ                  ; No: keep going
  BIT 7,H                 ; Is the left-clip flag set?
  RET                     ; Return (Z set when the car has gone)

; Getaway step 9
  CALL 34862              ; Draw the next frame of the street animation
  CALL 35366              ; Draw the next frame of the figure at 17728
  LD A,(34296)            ; A=the figure counter
  AND A                   ; Test it
  RET                     ; Return (Z set when it has run out)

; Getaway car animation: scroll the car and wait
  CALL 35000              ; Scroll the car two pixels
  CALL 34912              ; Draw the car's moving parts
  LD BC,440               ; BC=440: a long delay when the car is at a byte
                          ; boundary
  LD A,(38791)            ; A=the car's pixel shift
  AND A                   ; Test it
  JR NZ,34629             ; At a boundary: use the long delay
  LD BC,60                ; BC=60: a short delay between pixels
  DEC BC                  ; Count BC down
  LD A,B                  ; A=B
  OR C                    ; Combine with C
  JR NZ,34629             ; Loop until it reaches zero
  CALL 35406              ; Draw the car, clipped to the scene
  CALL 35192              ; Draw the masked graphic at 19299
  JP 35111                ; Draw the car's lower parts

; Getaway car animation: move the first hood
  LD A,(34291)            ; A=the first hood's counter
  DEC A                   ; One tick less
  LD (34291),A            ; Store it
  RET NZ                  ; Not time to move yet
  LD A,9                  ; A=9
  LD (34291),A            ; Reload the counter
  LD HL,(37101)           ; HL=the first hood's screen address
  LD A,(34292)            ; A=the number of steps to wait first
  AND A                   ; Test it
  JR Z,34671              ; None: move the hood
  DEC A                   ; One less
  LD (34292),A            ; Store it
  JR 34687                ; Skip the move this time
  LD A,(37105)            ; A=the pixel shift
  ADD A,4                 ; Add 4 (the hood moves 4 pixels per step)
  AND 7                   ; Keep it within a byte
  LD (37105),A            ; Store it
  JR NZ,34687             ; Still inside the byte
  INC L                   ; Next screen column
  LD (37101),HL           ; Store the new address
  LD HL,(37107)           ; HL=the hood's frame list
  LD E,(HL)               ; E=the next frame address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (37107),DE           ; Store the new list position
  LD A,(37105)            ; A=the pixel shift
  LD DE,24384             ; DE=the hood's sprite buffer
  JP PRESHIFT             ; Prepare the shifted sprite

; Getaway car animation: move the second hood
  LD A,(34293)            ; A=the second hood's counter
  DEC A                   ; One tick less
  LD (34293),A            ; Store it
  RET NZ                  ; Not time to move yet
  LD A,5                  ; A=5
  LD (34293),A            ; Reload the counter
  LD HL,(37933)           ; HL=the second hood's screen address
  LD A,(37937)            ; A=the pixel shift
  ADD A,2                 ; Add 2
  AND 7                   ; Keep it within a byte
  LD (37937),A            ; Store it
  JR NZ,34739             ; Still inside the byte
  INC L                   ; Next screen column
  LD (37933),HL           ; Store the new address
  LD HL,(37939)           ; HL=the second hood's frame list
  LD E,(HL)               ; E=the next frame address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (37939),DE           ; Store the new list position
  LD A,(37937)            ; A=the pixel shift
  LD DE,24192             ; DE=the second hood's sprite buffer
  JP PRESHIFT             ; Prepare the shifted sprite

; Restore the background behind the second hood
  LD DE,(37935)           ; DE=where the second hood was drawn
  LD HL,24000             ; HL=its saved background (24000)
  JP 34255                ; Put the background back

; Restore the background behind the first hood
  LD DE,(37103)           ; DE=where the first hood was drawn
  LD HL,24096             ; HL=its saved background (24096)
  JP 34255                ; Put the background back

; Draw the first hood (masked, pre-shifted)
  LD HL,24384             ; HL=the first hood's sprite buffer (24384)
  LD DE,(37101)           ; DE=its screen address
  LD (37103),DE           ; Remember where it is drawn
  EXX                     ; Switch to the alternate registers
  LD HL,24096             ; HL'=the first hood's background save area
  EXX                     ; Switch back
  JP 34203                ; Draw it, saving the background

; Draw the second hood (masked, pre-shifted)
  LD HL,24192             ; HL=the second hood's sprite buffer (24192)
  LD DE,(37933)           ; DE=its screen address
  LD (37935),DE           ; Remember where it is drawn
  EXX                     ; Switch to the alternate registers
  LD HL,24000             ; HL'=the second hood's background save area
  EXX                     ; Switch back
  JP 34203                ; Draw it, saving the background

; Getaway car animation: draw the 5-byte-wide graphic at 18465
  LD HL,38469             ; HL=a 5-byte-wide mask/graphic pair buffer (38469)
  LD DE,18465             ; DE=its screen address
  LD C,32                 ; C=32 pixel rows
  LD B,5                  ; B=5 bytes per row
  PUSH DE                 ; Save the row's address
  LD A,(DE)               ; A=the screen byte
  AND (HL)                ; Mask it
  INC HL                  ; Next buffer byte
  OR (HL)                 ; OR in the graphic
  INC HL                  ; Next buffer byte
  LD (DE),A               ; Put it on the screen
  INC E                   ; Next column
  DJNZ 34828              ; Loop for five bytes
  POP DE                  ; Restore the row's address
  INC D                   ; Down one pixel row
  LD A,D                  ; A=the high byte
  AND 7                   ; Crossed into the next character row?
  JR Z,34848              ; Yes: adjust
  DEC C                   ; One row less
  JR NZ,34825             ; Loop for every row
  RET                     ; Return
  LD A,E                  ; A=the low byte
  ADD A,32                ; Down one character row
  LD E,A                  ; E=the new low byte
  JP C,34844              ; Carry: next third
  LD A,D                  ; A=the high byte
  SUB 8                   ; Take back the 8
  LD D,A                  ; D=it
  JP 34844                ; Carry on

; Getaway car animation: draw the next frame of the animation at 21260
  LD A,(34068)            ; A=the tick flag
  AND A                   ; Test it
  RET Z                   ; Return if no tick has happened
  XOR A                   ; A=0
  LD (34068),A            ; Clear the flag
  LD HL,(39453)           ; HL=the frame list position
  LD E,(HL)               ; E=the next frame's address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (39453),DE           ; Store the new position
  LD DE,21260             ; DE=the screen address (21260)
  LD B,13                 ; B=13 pixel rows
  LD A,(HL)               ; A=a byte of the frame
  LD (DE),A               ; Put it on the screen
  INC HL                  ; Next byte
  INC D                   ; Down a pixel row
  LD A,D                  ; A=the high byte
  AND 7                   ; Crossed into the next character row?
  JR Z,34899              ; Yes: adjust
  DJNZ 34887              ; Loop for 13 rows
  RET                     ; Return
  LD A,E                  ; A=the low byte
  ADD A,32                ; Down one character row
  LD E,A                  ; E=the new low byte
  JR C,34896              ; Carry: next third
  LD A,D                  ; A=the high byte
  SUB 8                   ; Take back the 8
  LD D,A                  ; D=it
  JP 34896                ; Carry on

; Getaway car animation: draw the car's moving parts (frame depends on 38791)
  LD DE,39143             ; DE=where the first moving part is drawn (39143)
  LD HL,39325             ; HL=its first frame (39325)
  LD A,(38791)            ; A=the car's pixel shift
  AND A                   ; Test it
  JR Z,34941              ; Zero: use the first frame
  LD HL,39341             ; HL=the second frame (39341)
  CP 2                    ; Shift 2?
  JR Z,34941              ; Yes: use it
  LD HL,39357             ; HL=the third frame (39357)
  CP 4                    ; Shift 4?
  JR Z,34941              ; Yes: use it
  LD HL,39373             ; HL=the fourth frame (39373)
  CALL 34973              ; Draw the first part
  LD DE,39151             ; DE=where the second moving part is drawn (39151)
  LD HL,39389             ; HL=its first frame (39389)
  LD A,(38791)            ; A=the car's pixel shift
  AND A                   ; Test it
  JR Z,34973              ; Zero: draw the first frame
  LD HL,39405             ; HL=the second frame (39405)
  CP 2                    ; Shift 2?
  JR Z,34973              ; Yes: draw it
  LD HL,39421             ; HL=the third frame (39421)
  CP 4                    ; Shift 4?
  JR Z,34973              ; Yes: draw it
  LD HL,39437             ; HL=the fourth frame (39437)

; Draw a masked 2x4 tile
  LD BC,11                ; BC=11: the distance to the next row
  LD A,4                  ; A=4 rows
  EX AF,AF'               ; Save the row counter
  LD A,(DE)               ; A=a byte of the car buffer
  OR (HL)                 ; OR in the next graphic byte
  INC HL                  ; Next byte
  AND (HL)                ; AND with the mask byte
  LD (DE),A               ; Store it
  INC HL                  ; Next byte
  INC DE                  ; Next buffer byte
  LD A,(DE)               ; A=the next byte of the car buffer
  OR (HL)                 ; OR in the graphic
  INC HL                  ; Next byte
  AND (HL)                ; AND with the mask
  LD (DE),A               ; Store it
  INC HL                  ; Next byte
  EX DE,HL                ; HL=the buffer address
  ADD HL,BC               ; Move to the start of the next row
  EX DE,HL                ; DE=the buffer address
  EX AF,AF'               ; Get the row counter
  DEC A                   ; One row less
  JR NZ,34978             ; Loop for four rows
  RET                     ; Return

; Scroll the car one pixel
;
; Shifts the car image buffer right and moves the car when 8 pixels have been
; done.
  LD HL,(38789)           ; HL=the car's screen address
  LD (38792),HL           ; Remember it for the drawing routine
  LD HL,38794             ; HL=the car buffer (38794)
  PUSH HL                 ; Save it
  LD C,38                 ; C=38 rows
  OR A                    ; Clear the carry flag
  PUSH HL                 ; Save the start of the row
  LD B,12                 ; B=12 bytes
  RR (HL)                 ; Rotate a byte right (carry passes along the row)
  INC HL                  ; Next byte
  DJNZ 35016              ; Loop for 12 bytes
  POP HL                  ; Restore the start of the row
  LD B,12                 ; B=12 bytes
  RR (HL)                 ; Rotate it right again: that is two pixels in all
  INC HL                  ; Next byte
  DJNZ 35024              ; Loop for 12 bytes
  DEC C                   ; One row less
  JR NZ,35013             ; Loop for 38 rows
  LD C,3                  ; C=3: three more rows
  SCF                     ; Set the carry flag: these rows (the mask) shift in
                          ; 1s
  PUSH HL                 ; Save the start of the row
  LD B,12                 ; B=12 bytes
  RR (HL)                 ; Rotate a byte right
  INC HL                  ; Next byte
  DJNZ 35038              ; Loop for 12 bytes
  POP HL                  ; Restore the start of the row
  LD B,12                 ; B=12 bytes
  RR (HL)                 ; Rotate right a second time
  INC HL                  ; Next byte
  DJNZ 35046              ; Loop for 12 bytes
  DEC C                   ; One row less
  JR NZ,35035             ; Loop for three rows
  POP HL                  ; Restore the buffer address
  LD A,(38791)            ; A=the car's pixel shift
  ADD A,2                 ; Add 2 pixels
  AND 7                   ; Keep it within a byte
  LD (38791),A            ; Store it
  RET NZ                  ; Return if the car has not completed a byte
  LD DE,(38789)           ; DE=the car's screen address
  INC E                   ; Move on one column
  JR NZ,35077             ; No carry from the low byte
  LD A,D                  ; A=the high byte
  ADD A,8                 ; Move on to the next third of the screen
  LD D,A                  ; D=it
  LD A,E                  ; A=the low byte
  AND 31                  ; Column
  CP 3                    ; Column 3?
  JR NZ,35086             ; No
  RES 7,D                 ; Clear the left-clip flag: the car has come into
                          ; view
  LD (38789),DE           ; Store the new position
  LD BC,455               ; BC=455 bytes
  LD D,H                  ; DE=the buffer
  LD E,L                  ; ...
  INC HL                  ; HL=the next byte
  LDIR                    ; Shift the buffer down by one byte
  XOR A                   ; A=0
  LD (DE),A               ; Clear a byte
  INC DE                  ; Next byte
  INC HL                  ; Next source byte
  LD BC,36                ; BC=36
  LDIR                    ; Shift 36 more bytes (the mask area)
  LD A,255                ; A=255
  LD (DE),A               ; Store a final mask byte
  RET                     ; Return
  LD HL,(38789)           ; HL=the car's screen address
  LD A,252                ; A=252: offset for the first part
  LD DE,39250             ; DE=the car's lower graphic (39250)
  CALL 35141              ; Draw part of the car
  LD HL,(38789)           ; HL=the car's screen address
  LD A,253                ; A=253: offset for the second part
  LD DE,39262             ; DE=the next graphic (39262)
  CALL 35141              ; Draw part of the car
  LD HL,(38789)           ; HL=the car's screen address
  LD A,0                  ; A=0: no offset for the third part
  LD DE,39274             ; DE=the third graphic (39274)

; Draw part of the car (clipped)
  ADD A,H                 ; Add the offset to the high byte
  LD H,A                  ; H=it
  LD A,L                  ; A=the low byte
  ADD A,96                ; Add 96: three character rows down
  LD L,A                  ; L=it
  LD B,12                 ; B=12 bytes
  BIT 7,H                 ; Is the left-clip flag set?
  JR NZ,35167             ; Yes: clip on the left
  LD A,L                  ; A=the low byte
  AND 31                  ; Column
  CP 30                   ; Column 30?
  RET Z                   ; Yes: clipped on the right, return
  LD A,(DE)               ; A=a graphic byte
  AND (HL)                ; Mask the screen byte
  LD (HL),A               ; Store it
  INC L                   ; Next column
  INC DE                  ; Next graphic byte
  DJNZ 35153              ; Loop for 12 bytes
  RET                     ; Return
  LD A,L                  ; A=the low byte
  AND 31                  ; Column
  CP 3                    ; Column 3?
  JR Z,35181              ; Yes: start drawing
  INC L                   ; Next column
  JR Z,35185              ; Wrapped to column 0: adjust the third
  INC DE                  ; Skip a graphic byte
  DJNZ 35167              ; Loop
  RET                     ; Return
  RES 7,H                 ; Clear the left-clip flag
  JR 35153                ; Start drawing
  LD A,H                  ; A=the high byte
  ADD A,8                 ; Next third of the screen
  LD H,A                  ; H=it
  JP 35177                ; Carry on

; Getaway car animation: draw the masked graphic at 19299
  LD HL,19299             ; HL=the screen address (19299)
  LD DE,39286             ; DE=the masked graphic (39286)
  LD B,5                  ; B=5 pixel rows
  LD A,(DE)               ; A=a graphic byte
  AND (HL)                ; Mask the screen
  LD (HL),A               ; Store it
  INC DE                  ; Next graphic byte
  INC L                   ; Next column
  LD A,(DE)               ; A=the next graphic byte
  AND (HL)                ; Mask the screen
  LD (HL),A               ; Store it
  INC DE                  ; Next graphic byte
  INC L                   ; Next column
  LD A,(DE)               ; A=the next graphic byte
  AND (HL)                ; Mask the screen
  LD (HL),A               ; Store it
  INC DE                  ; Next graphic byte
  DEC L                   ; Back a column
  DEC L                   ; And another
  INC H                   ; Down a pixel row
  DJNZ 35200              ; Loop for 5 rows
  LD A,L                  ; A=the low byte
  ADD A,32                ; Down one character row
  LD L,A                  ; L=it
  LD A,H                  ; A=the high byte
  SUB 8                   ; Take back the 8
  LD H,A                  ; H=it
  LD C,3                  ; C=3 character rows
  LD B,8                  ; B=8 pixel rows
  LD A,(DE)               ; A=a graphic byte
  AND (HL)                ; Mask the screen
  LD (HL),A               ; Store it
  INC DE                  ; Next graphic byte
  INC H                   ; Down a pixel row
  DJNZ 35231              ; Loop for 8 rows
  LD A,L                  ; A=the low byte
  ADD A,32                ; Down one character row
  LD L,A                  ; L=it
  LD A,H                  ; A=the high byte
  SUB 8                   ; Take back the 8
  LD H,A                  ; H=it
  DEC C                   ; One character row less
  JP NZ,35229             ; Loop
  RET                     ; Return

; Getaway car animation: draw the next frame of the figure at 18838
  LD A,(34295)            ; A=the figure's frame counter
  DEC A                   ; One tick less
  LD (34295),A            ; Store it
  RET NZ                  ; Not time for a new frame
  LD A,6                  ; A=6
  LD (34295),A            ; Reload the counter
  LD HL,(39583)           ; HL=the frame list position
  LD E,(HL)               ; E=the next frame's address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (39583),DE           ; Store the new position
  LD DE,18838             ; DE=the screen address (18838)
  EX DE,HL                ; HL=the frame, DE=the screen address
  CALL 34097              ; Draw the frame
  XOR A                   ; A=0
  RET                     ; Return

; Getaway car animation: play a delay sound and animate the figures
  LD A,(34295)            ; A=the frame counter
  CP 6                    ; Is it 6?
  LD B,2                  ; B=2
  CALL Z,41997            ; Yes: pause
  LD A,(34295)            ; A=the frame counter
  CP 3                    ; Is it 3?
  LD B,2                  ; B=2
  CALL Z,41997            ; Yes: pause
  LD A,(34295)            ; A=the frame counter
  CP 5                    ; Is it 5?
  JR Z,35314              ; Yes: draw a gun flash
  CP 2                    ; Is it 2?
  RET NZ                  ; No: return
  LD HL,(39850)           ; HL=the flash list position
  LD E,(HL)               ; E=the next flash address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (39850),DE           ; Store the new position
  LD E,(HL)               ; E=the screen address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  LD HL,39892             ; HL=the flash graphic (39892)
  LD B,16                 ; B=16 pixel rows
  LD A,(DE)               ; A=a screen byte
  OR (HL)                 ; OR in the flash
  LD (DE),A               ; Draw it
  INC HL                  ; Next flash byte
  INC E                   ; Next column
  LD A,(DE)               ; A=the next screen byte
  OR (HL)                 ; OR in the flash
  LD (DE),A               ; Draw it
  INC HL                  ; Next flash byte
  DEC E                   ; Back a column
  INC D                   ; Down a pixel row
  LD A,D                  ; A=the high byte
  AND 7                   ; Crossed into the next character row?
  JR Z,35352              ; Yes: adjust
  DJNZ 35333              ; Loop for 16 rows
  RET                     ; Return
  LD A,E                  ; A=the low byte
  ADD A,32                ; Down one character row
  LD E,A                  ; E=the new low byte
  JP C,35349              ; Carry: next third
  LD A,D                  ; A=the high byte
  SUB 8                   ; Take back the 8
  LD D,A                  ; D=it
  JP 35349                ; Carry on

; Getaway car animation: draw the next frame of the figure at 17728
  LD A,(34297)            ; A=the figure's counter
  DEC A                   ; One tick less
  LD (34297),A            ; Store it
  RET NZ                  ; Not time for a new frame
  LD A,8                  ; A=8
  LD (34297),A            ; Reload the counter
  LD A,(34296)            ; A=the step counter
  DEC A                   ; One less
  LD (34296),A            ; Store it
  LD HL,(39753)           ; HL=the frame list position
  LD E,(HL)               ; E=the next frame's address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (39753),DE           ; Store the new position
  LD E,(HL)               ; E=the frame's graphic address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  LD HL,17728             ; HL=the screen address (17728)
  JP 34093                ; Draw the sprite (two cells wide)

; Draw the car (unrolled, clipped at the screen edge)
;
; A long unrolled loop that ORs the car graphic into the screen, with clipping
; at column 30, for speed.
  LD DE,24119             ; DE=the first buffer (24119, 12 bytes per row)
  LD HL,(38792)           ; HL=the screen address where the picture starts
                          ; (38792)
  EXX                     ; Switch to the alternate registers
  LD HL,38794             ; HL'=the car buffer (38794, 12 bytes by 38 rows)
  EXX                     ; Switch back
  LD C,38                 ; C=38 pixel rows to draw
  LD A,(38791)            ; A=the shift flag (38791)
  AND A                   ; Test it
  JP Z,35890              ; Zero: use the version that copies the first buffer
                          ; (35890)
  JP 35452                ; Non-zero: use the version that ORs in the car
                          ; buffer (35452)
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  JP 35616                ; Carry on with the next row
  PUSH HL                 ; Save the screen address of the start of this row
  LD A,L                  ; A=the screen address, low byte
  AND 224                 ; Keep the row bits
  OR 30                   ; Column 30: the right-hand clip position
  LD B,A                  ; B=the low byte of the clip position on this row
  BIT 7,H                 ; Is the left-clip flag (bit 7 of H) set for this
                          ; row?
  JP NZ,35657             ; Yes: skip the columns left of the street scene
                          ; first
  LD A,(DE)               ; A=the next byte of the buffer at 24119
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35429              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  LD A,(DE)               ; A=the next byte of the buffer at 24119
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35433              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  LD A,(DE)               ; A=the next byte of the buffer at 24119
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35437              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  LD A,(DE)               ; A=the next byte of the buffer at 24119
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35441              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  LD A,(DE)               ; A=the next byte of the buffer at 24119
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35445              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  LD A,(DE)               ; A=the next byte of the buffer at 24119
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35616              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  LD A,(DE)               ; A=the next byte of the buffer at 24119
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35620              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  LD A,(DE)               ; A=the next byte of the buffer at 24119
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35624              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  LD A,(DE)               ; A=the next byte of the buffer at 24119
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35628              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  LD A,(DE)               ; A=the next byte of the buffer at 24119
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35632              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  LD A,(DE)               ; A=the next byte of the buffer at 24119
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35636              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  LD A,(DE)               ; A=the next byte of the buffer at 24119
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  POP HL                  ; Get the start of the row back
  INC H                   ; Down one pixel row
  LD A,H                  ; A=the high byte
  AND 7                   ; Crossed into the next character row?
  JR Z,35643              ; Yes: move down to the next character row
  DEC C                   ; One row less
  JP NZ,35452             ; Draw the next row
  RET                     ; Return
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  JP 35604                ; Carry on with the next row
  LD A,L                  ; A=L
  ADD A,32                ; Add one character row (32 bytes)
  LD L,A                  ; L=the new low byte
  JP C,35611              ; Carry: that was the last character row of its
                          ; third, so H (already 8 higher) is right
  LD A,H                  ; No carry: still in the same third, so A=the high
                          ; byte
  SUB 8                   ; Take back the 8 that the pixel row steps added
  LD H,A                  ; H=the new high byte
  JP 35611                ; Carry on with the next row
  RES 7,H                 ; Clear the left-clip flag in H
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35464              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35476              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35488              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35500              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35512              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35524              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35536              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35548              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35560              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35572              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35584              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35596              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  JP 35604                ; Carry on with the next row

; Move H to the next third of the display file
  LD A,H                  ; A=H
  ADD A,8                 ; A=A+8
  LD H,A                  ; H=A
  RET                     ; Return
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  JP 36094                ; Carry on with the next row
  PUSH HL                 ; Save the screen address of the start of this row
  LD A,L                  ; A=the screen address, low byte
  AND 224                 ; Keep the row bits
  OR 30                   ; Column 30: the right-hand clip position
  LD B,A                  ; B=the low byte of the clip position on this row
  BIT 7,H                 ; Is the left-clip flag (bit 7 of H) set for this
                          ; row?
  JP NZ,36131             ; Yes: skip the columns left of the street scene
                          ; first
  LD A,(DE)               ; A=the next byte of the buffer at 24119
  LD (HL),A               ; Draw it on the screen
  INC L                   ; Increment L
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35859              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  INC DE                  ; Increment DE
  LD A,(DE)               ; A=the byte at DE
  DEC DE                  ; Decrement DE
  LD (DE),A               ; Store A at DE
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35863              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  INC DE                  ; Increment DE
  LD A,(DE)               ; A=the byte at DE
  DEC DE                  ; Decrement DE
  LD (DE),A               ; Store A at DE
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35867              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  INC DE                  ; Increment DE
  LD A,(DE)               ; A=the byte at DE
  DEC DE                  ; Decrement DE
  LD (DE),A               ; Store A at DE
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35871              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  INC DE                  ; Increment DE
  LD A,(DE)               ; A=the byte at DE
  DEC DE                  ; Decrement DE
  LD (DE),A               ; Store A at DE
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35875              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  INC DE                  ; Increment DE
  LD A,(DE)               ; A=the byte at DE
  DEC DE                  ; Decrement DE
  LD (DE),A               ; Store A at DE
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35879              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  INC DE                  ; Increment DE
  LD A,(DE)               ; A=the byte at DE
  DEC DE                  ; Decrement DE
  LD (DE),A               ; Store A at DE
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,35883              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  INC DE                  ; Increment DE
  LD A,(DE)               ; A=the byte at DE
  DEC DE                  ; Decrement DE
  LD (DE),A               ; Store A at DE
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,36094              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  INC DE                  ; Increment DE
  LD A,(DE)               ; A=the byte at DE
  DEC DE                  ; Decrement DE
  LD (DE),A               ; Store A at DE
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,36098              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  INC DE                  ; Increment DE
  LD A,(DE)               ; A=the byte at DE
  DEC DE                  ; Decrement DE
  LD (DE),A               ; Store A at DE
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,36102              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  INC DE                  ; Increment DE
  LD A,(DE)               ; A=the byte at DE
  DEC DE                  ; Decrement DE
  LD (DE),A               ; Store A at DE
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,36106              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  INC DE                  ; Increment DE
  LD A,(DE)               ; A=the byte at DE
  DEC DE                  ; Decrement DE
  LD (DE),A               ; Store A at DE
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Next byte of the first buffer
  INC L                   ; Next screen column
  LD A,L                  ; A=the screen column byte
  CP B                    ; Reached the clip column (30)?
  JR Z,36110              ; Yes: skip the rest of the row (the picture is
                          ; clipped at column 30)
  LD A,(HL)               ; Final byte of the row
  LD (DE),A               ; Store A at DE
  EXX                     ; Switch to the car buffer pointer (HL')
  OR (HL)                 ; OR in the matching byte of the car buffer
  INC HL                  ; Next car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD (HL),A               ; Draw it on the screen
  INC DE                  ; Increment DE
  POP HL                  ; Get the start of the row back
  INC H                   ; Down one pixel row
  LD A,H                  ; A=the high byte
  AND 7                   ; Crossed into the next character row?
  JR Z,36117              ; Yes: move down to the next character row
  DEC C                   ; One row less
  JP NZ,35890             ; Draw the next row
  RET                     ; Return
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  JP 36082                ; Carry on with the next row
  LD A,L                  ; A=L
  ADD A,32                ; Add one character row (32 bytes)
  LD L,A                  ; L=the new low byte
  JP C,36089              ; Carry: that was the last character row of its
                          ; third, so H (already 8 higher) is right
  LD A,H                  ; No carry: still in the same third, so A=the high
                          ; byte
  SUB 8                   ; Take back the 8 that the pixel row steps added
  LD H,A                  ; H=the new high byte
  JP 36089                ; Carry on with the next row
  RES 7,H                 ; Clear the left-clip flag in H
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35902              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  DEC DE                  ; Decrement DE
  EXX                     ; Switch register sets
  DEC HL                  ; Decrement HL
  EXX                     ; Switch register sets
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35909              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35924              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35939              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35954              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35969              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35984              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,35999              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,36014              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,36029              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,36044              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,36059              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  LD A,L                  ; A=the screen address, low byte
  AND 31                  ; Isolate the column
  CP 3                    ; Reached column 3, the left edge of the street
                          ; scene?
  JP Z,36074              ; Yes: start drawing
  INC L                   ; No: skip this column (it is off the left of the
                          ; scene)
  CALL Z,35854            ; If L wrapped round, move down to the next third of
                          ; the screen
  INC DE                  ; Skip a byte of the first buffer
  EXX                     ; Switch to the car buffer pointer (HL')
  INC HL                  ; Skip a car buffer byte
  EXX                     ; Switch back to the first buffer and screen pointers
  JP 36082                ; Carry on with the next row

; Bar-room animation: step table
;
; Used by RUNSTEPS.
  DEFW 36366,36495,36508,36527
  DEFW 36546,36566,36572,36495
  DEFW 36486

; Bar-room animation: step 1 (set up)
;
; Draws the Partridge Club picture at 53793 and initialises the frame pointers
; and timers for the animated customers, waiters and hoods.
  XOR A                   ; A=0
  OUT (254),A             ; Black border
  XOR A                   ; A=0
  LD (36702),A            ; Figure 1 starts in its first state
  LD (36910),A            ; Figure 6 starts in its first state
  LD (36860),A            ; Figure 5 starts in its first state
  LD (36960),A            ; Figure 7 starts in its first state (bit 7 clear: it
                          ; may move)
  LD A,128                ; A=128
  LD (37031),A            ; Figure 8 starts out of action (bit 7 set)
  LD A,1                  ; A=1: every counter starts at 1, so each figure
                          ; moves on the first tick
  LD (36663),A            ; Counter for the hoods' route
  LD (36701),A            ; Counter for figure 1
  LD (36859),A            ; Counter for figure 5
  LD (36909),A            ; Counter for figure 6
  LD (36959),A            ; Counter for figure 7
  LD (37030),A            ; Counter for figure 8
  LD (36751),A            ; Counter for figure 2
  LD (36787),A            ; Counter for figure 3
  LD (36823),A            ; Counter for figure 4
  LD HL,41154             ; HL=the first entry of the hoods' route table
  LD (41152),HL           ; Store it as the route pointer
  LD A,1                  ; A=1
  LD (36616),A            ; Counter for the hoods walking through the club
  LD HL,39926             ; HL=the first frame of the walking hoods
  LD (39924),HL           ; Store it as the frame pointer
  LD HL,40249             ; HL=the first frame of figure 1
  LD (40194),HL           ; Store it
  LD HL,40759             ; HL=the first frame of figure 5
  LD (40694),HL           ; Store it
  LD HL,40872             ; HL=the first frame of figure 6
  LD (40822),HL           ; Store it
  LD HL,40973             ; HL=the first frame of figure 7
  LD (40920),HL           ; Store it
  LD HL,41089             ; HL=the first frame of figure 8
  LD (41024),HL           ; Store it
  LD HL,53793             ; HL=the compressed picture of the Partridge Club
  CALL DRAWCPIC           ; Draw it
  LD DE,(41024)           ; DE=figure 8's frame pointer
  INC DE                  ; Skip the link to the next frame...
  INC DE                  ; ...to the sprite
  CALL 37095              ; Draw figure 8 for the first time
  LD HL,500               ; HL=500
  LD (36493),HL           ; The first pause lasts 500 ticks
  XOR A                   ; A=0: the step is complete
  RET                     ; Return

; Bar-room animation: last step (end the animation)
  LD A,1                  ; A=1
  LD (33993),A            ; Mark the animation as finished
  DEC A                   ; A=0
  RET                     ; Return (zero flag set: the step is complete)

; Bar-room animation: pause counter
;
; A 16-bit tick counter used by 36495. It is set to 500 at 36481 for the first
; pause (before the door opens) and to 400 at 36582 for the final pause.
  DEFB 0,0                ; Pause counter (word)

; Bar-room animation: count down the delay
  CALL 36586              ; Animate all the figures
  LD HL,(36493)           ; HL=the pause counter
  DEC HL                  ; One tick less
  LD (36493),HL           ; Store it
  LD A,H                  ; A=H
  OR L                    ; Combine with L to test for zero
  RET                     ; Return (Z set when the pause is over)

; Bar-room animation: animate and wait for the door to open
  CALL 36586              ; Animate all the figures
  CALL 36664              ; Advance the hoods along their route
  RET NZ                  ; Return until the route entry is finished
  LD HL,41200             ; HL=the next route (41200)
  LD (41152),HL           ; Use it
  LD A,1                  ; A=1
  LD (36663),A            ; Make the route routine fetch its first entry at
                          ; once
  RET                     ; Return

; Bar-room animation: the hoods walk in
  CALL 36703              ; Animate figure 1
  CALL 36664              ; Advance the hoods along their route
  RET NZ                  ; Return until the route entry is finished
  LD HL,41221             ; HL=the next route (41221)
  LD (41152),HL           ; Use it
  LD A,1                  ; A=1
  LD (36663),A            ; Fetch the first entry at once
  RET                     ; Return

; Bar-room animation: the hoods cross the room
  CALL 36703              ; Animate figure 1
  CALL 36664              ; Advance the hoods along their route
  JR NZ,36569             ; Not finished: draw the walking hoods
  LD HL,41237             ; HL=the next route (41237)
  LD (41152),HL           ; Use it
  LD A,1                  ; A=1
  LD (36663),A            ; Fetch the first entry at once
  RET                     ; Return

; Bar-room animation: the hoods go out
  CALL 36703              ; Animate figure 1
  JP 36617                ; Animate the hoods walking

; Bar-room animation: final pause
  CALL 36703              ; Animate figure 1
  CALL 36664              ; Advance the hoods along their route
  RET NZ                  ; Return until the route is finished
  LD HL,400               ; HL=400
  LD (36493),HL           ; Pause for 400 ticks
  RET                     ; Return

; Bar-room animation: update all the animated figures
  CALL 36703              ; Animate figure 1
  CALL 36752              ; Animate figure 2
  CALL 36788              ; Animate figure 3
  CALL 36824              ; Animate figure 4
  CALL 36861              ; Animate figure 5
  CALL 36911              ; Animate figure 6
  CALL 36961              ; Animate figure 7
  JP 37032                ; Animate figure 8 and return

; Get a random delay
;
; A=B+random(0..C).
;
; Input:B Minimum
;       C Range
  LD A,C                  ; A=the range
  CALL RANDOMPM           ; A=a random number from 0 to C
  ADD A,B                 ; Add the minimum
  RET                     ; Return

; Bar-room animation: walking hoods counter
;
; Ticks left until the next frame of the hoods walking through the club (see
; 36617). It starts at 1 so the first frame is drawn at once, and is then
; reloaded with the duration of each frame from the list at 39924.
  DEFB 1                  ; Ticks until the next frame

; Bar-room animation: animate the hoods walking through the club
  LD A,(36616)            ; A=the counter
  DEC A                   ; One tick less
  LD (36616),A            ; Store it
  RET NZ                  ; Not time for a new frame
  LD HL,(39924)           ; HL=the position in the walking hoods' list
  LD A,(HL)               ; A=the number of ticks this frame lasts
  AND A                   ; Test it
  RET Z                   ; Zero marks the end of the list: stop
  INC HL                  ; Next byte
  LD (36616),A            ; Store it as the new counter
  CP 2                    ; Is the delay 2?
  LD B,1                  ; B=1
  PUSH HL                 ; Save the list position
  CALL Z,41997            ; If so, wait a moment (a step sound)
  POP HL                  ; Restore the list position
  LD E,(HL)               ; E=the low byte of the record address
  INC HL                  ; Next byte
  LD D,(HL)               ; D=the high byte
  INC HL                  ; Next byte
  LD (39924),HL           ; Store the new list position
  EX DE,HL                ; HL=the record: the screen address then the sprite
  LD E,(HL)               ; E=the screen address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  EX DE,HL                ; HL=the screen address, DE=the sprite
  CALL 34097              ; Draw the three-cell-wide sprite
  OR 1                    ; Clear the zero flag: the step is not complete
  RET                     ; Return

; Bar-room animation: route counter
;
; Ticks left before 36664 fetches the next entry from the hoods' route table.
; Setting it to 1 (36389, 36523, 36542 and 36562) makes the routine fetch an
; entry at once.
  DEFB 1                  ; Ticks until the next route entry

; Bar-room animation: advance along the hoods' route table
  LD A,(36663)            ; A=the counter
  DEC A                   ; One tick less
  LD (36663),A            ; Store it
  RET NZ                  ; Not time for a new entry
  LD HL,(41152)           ; HL=the route pointer
  LD A,(HL)               ; A=the number of ticks this entry lasts
  AND A                   ; Test it
  RET Z                   ; Zero marks the end of the route
  INC HL                  ; Next byte
  LD (36663),A            ; Store it as the new counter
  LD E,(HL)               ; E=the screen address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  PUSH DE                 ; Save the screen address
  LD E,(HL)               ; E=the sprite address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (41152),HL           ; Store the new route pointer
  POP HL                  ; HL=the screen address
  CALL 34093              ; Draw the two-cell-wide sprite
  OR 1                    ; Clear the zero flag: the route is not finished
  RET                     ; Return

; Bar-room animation: figure 1 counter and state
;
; Used by 36703. The counter counts down to the next frame; when it expires the
; state flips between 0 and 1, which chooses a long wait (60-100 ticks) or a
; short one (10-30 ticks), and the next frame is drawn.
  DEFB 1                  ; Counter
  DEFB 0                  ; State (0 or 1)

; Bar-room animation: animate figure 1 (at 21584)
  LD A,(36701)            ; A=figure 1's counter
  DEC A                   ; One tick less
  LD (36701),A            ; Store it
  RET NZ                  ; Not time to change yet
  LD A,(36702)            ; A=figure 1's state
  XOR 1                   ; Flip it
  LD (36702),A            ; Store it
  LD BC,15400             ; BC=the long delay range (minimum 60, up to 40 more
                          ; ticks)
  JR Z,36727              ; State 0: use the long delay
  LD BC,2580              ; BC=the short delay range (minimum 10, up to 20 more
                          ; ticks)
  CALL 36610              ; A=a random delay
  LD (36701),A            ; Set the counter
  LD HL,(40194)           ; HL=figure 1's frame pointer
  LD E,(HL)               ; E=the next frame's address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (40194),DE           ; Store the pointer to the next frame
  EX DE,HL                ; DE=the sprite
  LD HL,21584             ; HL=figure 1's screen address
  JP 34093                ; Draw the sprite

; Bar-room animation: figure 2 counter
;
; Ticks until figure 2 (at 16769) changes frame; used by 36752. Starts at 1.
  DEFB 1                  ; Counter

; Bar-room animation: animate figure 2 (at 16769)
  LD A,(36751)            ; A=figure 2's counter
  DEC A                   ; One tick less
  LD (36751),A            ; Store it
  RET NZ                  ; Not time to change yet
  LD BC,2564              ; BC=the delay range (minimum 10, up to 4 more)
  CALL 36610              ; A=a random delay
  LD (36751),A            ; Set the counter
  LD HL,(40302)           ; HL=figure 2's frame pointer
  LD E,(HL)               ; E=the next frame's address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (40302),DE           ; Store the pointer to the next frame
  EX DE,HL                ; DE=the sprite
  LD HL,16769             ; HL=figure 2's screen address
  JP 34093                ; Draw the sprite

; Bar-room animation: figure 3 counter
;
; Ticks until figure 3 (at 16803) changes frame; used by 36788. Starts at 1.
  DEFB 1                  ; Counter

; Bar-room animation: animate figure 3 (at 16803)
  LD A,(36787)            ; A=figure 3's counter
  DEC A                   ; One tick less
  LD (36787),A            ; Store it
  RET NZ                  ; Not time to change yet
  LD BC,3588              ; BC=the delay range (minimum 14, up to 4 more)
  CALL 36610              ; A=a random delay
  LD (36787),A            ; Set the counter
  LD HL,(40434)           ; HL=figure 3's frame pointer
  LD E,(HL)               ; E=the next frame's address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (40434),DE           ; Store the pointer to the next frame
  EX DE,HL                ; DE=the sprite
  LD HL,16803             ; HL=figure 3's screen address
  JP 34093                ; Draw the sprite

; Bar-room animation: figure 4 counter
;
; Ticks until figure 4 (at 17253) changes frame; used by 36824. Starts at 1.
  DEFB 1                  ; Counter

; Bar-room animation: animate figure 4 (at 17253)
  LD A,(36823)            ; A=figure 4's counter
  DEC A                   ; One tick less
  LD (36823),A            ; Store it
  RET NZ                  ; Not time to change yet
  LD BC,2052              ; BC=the delay range (minimum 8, up to 4 more)
  CALL 36610              ; A=a random delay
  LD (36823),A            ; Set the counter
  LD HL,(40570)           ; HL=figure 4's frame pointer
  LD E,(HL)               ; E=the next frame's address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (40570),DE           ; Store the pointer to the next frame
  EX DE,HL                ; DE=the sprite
  LD HL,17253             ; HL=figure 4's screen address
  JP 34093                ; Draw the sprite

; Bar-room animation: figure 5 counter and state
;
; Used by 36861 for figure 5 (at 19576). The counter counts down to the next
; change; the state starts at 0 (the first state).
  DEFB 1                  ; Counter
  DEFB 0                  ; State

; Bar-room animation: animate figure 5 (at 19576)
  LD A,(36859)            ; A=figure 5's counter
  DEC A                   ; One tick less
  LD (36859),A            ; Store it
  RET NZ                  ; Not time to change yet
  LD A,(36860)            ; A=figure 5's state
  XOR 1                   ; Flip it
  LD (36860),A            ; Store it
  LD BC,25650             ; BC=the long delay range (minimum 100, up to 50
                          ; more)
  JR Z,36885              ; State 0: use the long delay
  LD BC,10270             ; BC=the short delay range (minimum 40, up to 30
                          ; more)
  CALL 36610              ; A=a random delay
  LD (36859),A            ; Set the counter
  LD HL,(40694)           ; HL=figure 5's frame pointer
  LD E,(HL)               ; E=the next frame's address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (40694),DE           ; Store the pointer to the next frame
  EX DE,HL                ; DE=the sprite
  LD HL,19576             ; HL=figure 5's screen address
  JP 34097                ; Draw the three-cell-wide sprite

; Bar-room animation: figure 6 counter and state
;
; Used by 36911 for figure 6 (at 19087). The counter counts down to the next
; change; the state starts at 0 (the first state).
  DEFB 1                  ; Counter
  DEFB 0                  ; State

; Bar-room animation: animate figure 6 (at 19087)
  LD A,(36909)            ; A=figure 6's counter
  DEC A                   ; One tick less
  LD (36909),A            ; Store it
  RET NZ                  ; Not time to change yet
  LD A,(36910)            ; A=figure 6's state
  XOR 1                   ; Flip it
  LD (36910),A            ; Store it
  LD BC,7700              ; BC=the long delay range (minimum 30, up to 20 more)
  JR Z,36935              ; State 0: use the long delay
  LD BC,5130              ; BC=the short delay range (minimum 20, up to 10
                          ; more)
  CALL 36610              ; A=a random delay
  LD (36909),A            ; Set the counter
  LD HL,(40822)           ; HL=figure 6's frame pointer
  LD E,(HL)               ; E=the next frame's address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (40822),DE           ; Store the pointer to the next frame
  EX DE,HL                ; DE=the sprite
  LD HL,19087             ; HL=figure 6's screen address
  JP 34097                ; Draw the three-cell-wide sprite

; Bar-room animation: figure 7 counter and state
;
; Used by 36961 for figure 7 (at 18633). The counter counts down to the next
; change; the state starts at 0 (bit 7 clear: the figure may move).
  DEFB 1                  ; Counter
  DEFB 0                  ; State

; Bar-room animation: animate figure 7 (at 18633)
  LD A,(36960)            ; A=figure 7's state
  AND 128                 ; Is bit 7 set (figure 7 is out of action while
                          ; figure 8 is active)?
  RET NZ                  ; Yes: nothing to do
  LD A,(36959)            ; A=figure 7's counter
  DEC A                   ; One tick less
  LD (36959),A            ; Store it
  RET NZ                  ; Not time to change yet
  LD A,(36960)            ; A=figure 7's state
  XOR 1                   ; Flip bit 0
  LD (36960),A            ; Store it
  JR NZ,36998             ; Bit 0 is set: keep this figure active
  SET 7,A                 ; Set bit 7: it hands over to figure 8
  LD (36960),A            ; Store it
  LD A,(37031)            ; A=figure 8's state
  RES 7,A                 ; Clear bit 7: figure 8 becomes active
  LD (37031),A            ; Store it
  LD BC,20510             ; BC=the long delay range (minimum 80, up to 30 more)
  JR Z,37006              ; Zero: use the long delay
  LD BC,5140              ; BC=the short delay range (minimum 20, up to 20
                          ; more)
  CALL 36610              ; A=a random delay
  LD (36959),A            ; Set the counter
  LD HL,(40920)           ; HL=figure 7's frame pointer
  LD E,(HL)               ; E=the next frame's address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (40920),DE           ; Store the pointer to the next frame
  EX DE,HL                ; DE=the sprite
  LD HL,18633             ; HL=figure 7's screen address
  JP 34097                ; Draw the three-cell-wide sprite

; Bar-room animation: figure 8 counter and state
;
; Used by 37032 for figure 8. The counter counts down to the next change; the
; state starts at 128 (bit 7 set: the figure is out of action until the script
; brings it in).
  DEFB 1                  ; Counter
  DEFB 0                  ; State

; Bar-room animation: animate figure 8
  LD A,(37031)            ; A=figure 8's state
  AND 128                 ; Is bit 7 set (figure 8 is out of action while
                          ; figure 7 is active)?
  RET NZ                  ; Yes: nothing to do
  LD A,(37030)            ; A=figure 8's counter
  DEC A                   ; One tick less
  LD (37030),A            ; Store it
  RET NZ                  ; Not time to change yet
  LD A,(37031)            ; A=figure 8's state
  XOR 1                   ; Flip bit 0
  LD (37031),A            ; Store it
  JR NZ,37069             ; Bit 0 is set: keep this figure active
  SET 7,A                 ; Set bit 7: hand over to figure 7
  LD (37031),A            ; Store it
  LD A,(36960)            ; A=figure 7's state
  RES 7,A                 ; Clear bit 7: figure 7 becomes active
  LD (36960),A            ; Store it
  LD BC,20510             ; BC=the long delay range (minimum 80, up to 30 more)
  JR Z,37077              ; Zero: use the long delay
  LD BC,5140              ; BC=the short delay range (minimum 20, up to 20
                          ; more)
  CALL 36610              ; A=a random delay
  LD (37030),A            ; Set the counter
  LD HL,(41024)           ; HL=figure 8's frame pointer
  LD E,(HL)               ; E=the next frame's address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  INC HL                  ; Next byte
  LD (41024),DE           ; Store the pointer to the next frame
  EX DE,HL                ; DE=the sprite

; Draw a 3-cell-wide sprite at 18536
  LD HL,18536             ; HL=figure 8's screen address
  JP 34097                ; Draw the three-cell-wide sprite

; Animation data and graphics
;
; Positions, frame lists and sprite graphics for the getaway car and bar-room
; animations.
  DEFB 0,0,0,0,0,0,245,144
  DEFB 249,144,45,145,253,144,45,145
  DEFB 1,145,45,145,5,145,45,145
  DEFB 9,145,45,145,13,145,173,145
  DEFB 17,145,173,145,21,145,173,145
  DEFB 25,145,45,145,29,145,45,145
  DEFB 33,145,45,146,37,145,173,146
  DEFB 41,145,45,147,37,145,173,147
  DEFB 252,3,63,192,248,7,63,192
  DEFB 248,7,31,224,224,31,15,240
  DEFB 240,15,31,224,128,107,3,108
  DEFB 128,92,3,180,128,65,3,228
  DEFB 128,64,3,132,128,64,3,132
  DEFB 0,192,1,134,0,224,1,142
  DEFB 0,224,1,142,0,224,1,142
  DEFB 128,64,3,132,128,64,3,132
  DEFB 192,32,7,136,224,24,15,144
  DEFB 224,28,15,176,224,30,15,240
  DEFB 224,31,15,240,224,31,15,240
  DEFB 224,31,15,240,224,31,15,240
  DEFB 248,7,63,192,252,3,63,192
  DEFB 252,3,31,224,252,3,15,176
  DEFB 252,3,15,112,252,3,15,112
  DEFB 248,4,31,224,248,7,63,192
  DEFB 248,7,127,128,248,7,63,192
  DEFB 248,7,63,192,224,31,15,240
  DEFB 240,15,31,224,240,14,31,160
  DEFB 128,120,7,56,128,70,7,104
  DEFB 128,65,7,136,128,65,7,8
  DEFB 128,65,3,12,128,65,3,28
  DEFB 0,193,3,28,0,225,3,28
  DEFB 0,225,7,8,0,225,7,8
  DEFB 128,65,7,8,192,49,15,16
  DEFB 224,25,15,48,224,29,15,112
  DEFB 224,31,15,240,224,31,15,240
  DEFB 224,31,15,240,224,31,15,240
  DEFB 248,7,63,192,252,3,63,192
  DEFB 252,3,31,224,252,3,15,176
  DEFB 252,3,15,112,252,3,15,112
  DEFB 248,4,31,224,248,7,63,192
  DEFB 252,3,63,192,248,7,63,192
  DEFB 248,7,31,224,224,31,15,240
  DEFB 240,15,31,224,240,9,31,160
  DEFB 224,28,31,96,224,22,31,32
  DEFB 224,19,15,112,224,17,15,144
  DEFB 224,17,7,24,192,49,7,56
  DEFB 192,57,7,56,192,57,7,56
  DEFB 192,57,15,16,224,17,15,16
  DEFB 224,17,15,16,224,17,15,16
  DEFB 224,25,15,48,224,29,15,112
  DEFB 224,31,15,240,224,31,15,240
  DEFB 224,31,15,240,224,31,15,240
  DEFB 248,7,63,192,252,3,63,192
  DEFB 252,3,63,192,252,3,63,192
  DEFB 252,3,63,192,248,5,63,64
  DEFB 248,6,31,160,248,7,31,224
  DEFB 255,0,255,0,255,0,15,240
  DEFB 254,1,15,240,254,1,7,248
  DEFB 248,7,1,254,252,3,7,88
  DEFB 248,7,7,88,240,15,3,132
  DEFB 224,31,7,72,224,30,7,56
  DEFB 192,60,15,16,128,120,7,8
  DEFB 128,112,7,8,128,121,15,144
  DEFB 128,127,15,144,192,63,15,176
  DEFB 224,31,15,240,240,15,15,240
  DEFB 240,15,7,248,240,15,7,248
  DEFB 240,15,7,248,240,15,7,248
  DEFB 240,15,7,248,240,15,15,240
  DEFB 248,7,15,240,248,7,7,248
  DEFB 240,15,7,120,240,14,7,56
  DEFB 240,14,7,24,224,20,7,24
  DEFB 224,30,1,6,224,31,0,31
  DEFB 255,0,255,0,255,0,15,240
  DEFB 254,1,15,240,254,1,7,248
  DEFB 248,7,1,254,252,3,7,88
  DEFB 248,7,7,88,248,7,3,132
  DEFB 240,15,7,200,240,15,7,248
  DEFB 224,30,31,224,224,28,31,96
  DEFB 192,56,31,32,192,56,15,0
  DEFB 192,56,31,32,192,60,63,64
  DEFB 224,30,63,192,240,15,63,192
  DEFB 248,7,63,192,248,7,63,192
  DEFB 248,7,63,224,240,15,63,224
  DEFB 240,15,63,224,240,15,63,224
  DEFB 248,7,63,192,248,7,63,192
  DEFB 240,15,127,128,240,15,255,0
  DEFB 241,14,255,0,241,10,255,0
  DEFB 248,7,127,128,252,3,63,192
  DEFB 255,0,255,0,255,0,255,0
  DEFB 255,0,15,240,254,1,15,240
  DEFB 254,1,7,248,248,7,1,254
  DEFB 252,3,7,216,252,3,7,24
  DEFB 248,7,3,132,248,7,7,232
  DEFB 240,15,7,232,240,14,15,112
  DEFB 224,28,31,32,224,28,15,0
  DEFB 224,30,31,32,240,15,31,96
  DEFB 248,7,31,224,248,7,31,224
  DEFB 248,7,15,240,248,7,15,240
  DEFB 240,15,15,240,240,15,15,240
  DEFB 224,31,7,248,192,63,7,248
  DEFB 240,15,7,248,224,31,7,248
  DEFB 128,127,199,56,129,94,199,56
  DEFB 159,96,231,24,159,96,231,24
  DEFB 191,64,249,6,255,0,224,31
  DEFB 0,0,0,0,0,0,53,148
  DEFB 57,148,69,148,61,148,197,148
  DEFB 65,148,69,149,53,148,197,149
  DEFB 254,1,31,224,254,0,31,0
  DEFB 252,3,15,240,252,3,31,160
  DEFB 252,3,15,144,254,1,31,160
  DEFB 253,2,255,0,248,7,255,0
  DEFB 240,15,103,152,240,9,64,191
  DEFB 224,17,7,232,224,19,15,208
  DEFB 224,23,15,144,224,19,31,160
  DEFB 240,11,63,64,240,11,255,0
  DEFB 248,7,127,128,248,7,127,128
  DEFB 248,7,63,192,252,3,63,192
  DEFB 252,3,63,192,252,3,63,192
  DEFB 248,6,63,64,248,6,63,64
  DEFB 240,11,31,32,225,26,31,160
  DEFB 193,34,31,160,131,108,143,80
  DEFB 15,240,143,80,31,224,143,112
  DEFB 63,192,135,120,159,96,163,92
  DEFB 254,1,31,224,254,0,31,0
  DEFB 252,3,15,240,252,3,31,160
  DEFB 252,3,15,144,254,1,31,160
  DEFB 253,2,255,0,248,7,255,0
  DEFB 248,7,103,152,240,9,64,175
  DEFB 240,9,7,232,240,9,15,208
  DEFB 240,13,31,224,240,13,63,192
  DEFB 240,13,127,128,240,9,255,0
  DEFB 240,11,255,0,240,15,127,128
  DEFB 248,7,127,128,248,7,127,128
  DEFB 252,3,63,192,254,1,31,96
  DEFB 252,3,15,80,252,2,15,144
  DEFB 248,6,31,160,240,14,63,192
  DEFB 240,13,255,0,240,13,255,0
  DEFB 243,12,255,0,241,10,255,0
  DEFB 248,7,255,0,248,7,127,128
  DEFB 252,3,63,192,252,0,63,0
  DEFB 248,7,31,224,248,7,63,64
  DEFB 248,7,31,32,248,7,63,64
  DEFB 254,1,255,0,253,2,255,0
  DEFB 248,7,103,152,248,7,64,175
  DEFB 240,9,7,232,224,17,15,208
  DEFB 224,19,31,224,224,23,127,128
  DEFB 224,23,255,0,224,19,255,0
  DEFB 225,26,255,0,225,26,255,0
  DEFB 225,30,255,0,224,31,255,0
  DEFB 240,15,255,0,240,15,127,128
  DEFB 248,7,127,128,248,4,127,128
  DEFB 240,8,63,192,192,51,63,64
  DEFB 130,117,63,64,135,120,31,160
  DEFB 159,96,31,160,159,96,31,224
  DEFB 191,64,15,240,255,0,71,184
  DEFB 252,3,63,192,252,0,63,0
  DEFB 248,7,31,224,248,7,63,64
  DEFB 248,7,31,32,254,1,63,64
  DEFB 253,2,255,0,248,7,255,0
  DEFB 240,15,127,128,240,9,115,140
  DEFB 224,17,32,215,192,39,3,228
  DEFB 192,47,7,200,192,39,15,176
  DEFB 224,23,63,192,224,19,255,0
  DEFB 240,15,255,0,240,15,127,128
  DEFB 240,15,127,128,240,15,127,128
  DEFB 240,15,127,128,248,7,127,128
  DEFB 248,4,127,128,252,2,127,128
  DEFB 252,2,127,128,248,4,127,128
  DEFB 224,27,255,0,192,53,255,0
  DEFB 192,57,255,0,192,42,255,0
  DEFB 192,47,255,0,240,15,127,128
  DEFB 63,63,199,199,255,0,255,0
  DEFB 255,0,15,15,199,199,255,0
  DEFB 255,0,255,0,3,3,227,227
  DEFB 255,128,255,0,255,0,0,0
  DEFB 251,251,255,128,255,0,255,0
  DEFB 0,0,61,61,255,192,255,0
  DEFB 255,0,0,0,14,14,255,192
  DEFB 255,0,255,0,0,0,7,7
  DEFB 127,96,255,0,255,0,128,128
  DEFB 1,1,255,224,255,0,255,0
  DEFB 240,240,0,0,255,240,255,0
  DEFB 255,0,254,254,0,0,63,56
  DEFB 255,0,255,0,255,255,224,224
  DEFB 31,28,255,0,255,0,255,255
  DEFB 252,252,7,6,255,0,255,0
  DEFB 255,255,255,255,1,1,255,128
  DEFB 255,0,255,255,255,255,192,192
  DEFB 255,192,255,0,255,255,255,255
  DEFB 240,240,63,32,255,0,255,255
  DEFB 255,255,252,252,31,24,255,224
  DEFB 255,255,255,255,254,254,7,6
  DEFB 255,0,255,255,255,255,255,255
  DEFB 129,129,255,0,255,255,255,255
  DEFB 143,143,224,224,255,128,255,255
  DEFB 255,255,143,143,248,248,127,64
  DEFB 255,255,255,255,15,15,252,252
  DEFB 63,32,255,255,255,255,15,15
  DEFB 254,254,31,16,255,255,254,254
  DEFB 7,7,255,255,143,136,255,255
  DEFB 254,254,7,7,255,255,199,196
  DEFB 255,255,254,254,7,7,255,255
  DEFB 255,252,255,255,254,254,7,7
  DEFB 255,255,255,248,255,255,252,252
  DEFB 15,15,255,255,255,240,255,255
  DEFB 252,252,15,15,255,255,255,128
  DEFB 255,255,240,240,31,31,255,224
  DEFB 255,0,255,255,224,224,31,24
  DEFB 255,0,255,0,255,255,224,224
  DEFB 31,24,255,0,255,0,252,252
  DEFB 224,224,31,24,255,0,255,0
  DEFB 0,0,0,0,0,0,0,63
  DEFB 255,255,192,0,0,0,0,0
  DEFB 0,0,7,255,255,255,240,0
  DEFB 0,0,0,0,0,0,127,255
  DEFB 255,255,252,0,0,0,0,0
  DEFB 0,3,255,255,255,255,255,0
  DEFB 0,0,0,0,0,31,255,255
  DEFB 255,255,140,0,0,0,0,0
  DEFB 0,127,254,0,3,142,4,0
  DEFB 0,0,0,0,0,63,249,192
  DEFB 7,206,6,0,0,0,0,0
  DEFB 0,63,247,224,15,230,6,0
  DEFB 0,0,0,0,0,63,255,128
  DEFB 7,198,6,0,0,0,248,0
  DEFB 0,63,159,192,7,231,7,0
  DEFB 0,0,16,0,0,63,207,128
  DEFB 7,199,27,255,255,255,252,0
  DEFB 0,63,231,255,255,247,231,255
  DEFB 255,255,246,96,0,63,243,255
  DEFB 255,246,31,255,255,255,243,160
  DEFB 0,64,24,0,0,15,255,255
  DEFB 255,255,229,160,0,127,255,255
  DEFB 255,255,255,255,255,255,233,160
  DEFB 0,127,255,255,255,255,255,255
  DEFB 255,255,233,160,0,127,254,127
  DEFB 231,255,255,255,255,255,229,224
  DEFB 0,127,255,255,255,255,255,255
  DEFB 255,255,231,152,0,63,255,255
  DEFB 255,255,255,255,255,255,255,140
  DEFB 0,63,255,255,255,255,255,255
  DEFB 255,255,7,230,0,31,192,127
  DEFB 255,255,255,192,0,12,1,242
  DEFB 0,31,0,31,255,255,255,255
  DEFB 255,240,0,249,0,254,124,15
  DEFB 255,255,255,192,0,33,240,126
  DEFB 0,157,255,7,255,255,255,255
  DEFB 255,199,254,124,0,139,225,135
  DEFB 255,255,255,192,0,159,195,63
  DEFB 0,155,128,67,255,255,255,255
  DEFB 255,127,0,190,0,215,0,35
  DEFB 255,255,255,255,254,254,0,99
  DEFB 0,102,30,17,255,255,255,255
  DEFB 253,252,60,35,0,49,222,238
  DEFB 0,0,0,0,12,3,189,194
  DEFB 0,99,191,118,255,255,255,255
  DEFB 240,23,126,239,0,3,191,118
  DEFB 0,0,0,0,0,103,126,238
  DEFB 0,27,191,119,255,255,255,255
  DEFB 255,135,126,236,0,3,191,112
  DEFB 0,0,0,0,0,7,126,224
  DEFB 0,1,222,224,0,0,0,0
  DEFB 0,3,189,192,0,1,225,224
  DEFB 0,0,0,0,0,3,195,192
  DEFB 0,0,255,192,0,0,0,0
  DEFB 0,1,255,128,0,0,127,128
  DEFB 0,0,0,0,0,0,255,0
  DEFB 0,0,30,0,0,0,0,0
  DEFB 0,0,60,0,0,255,192,127
  DEFB 255,255,255,192,0,12,1,243
  DEFB 255,255,0,31,255,255,255,255
  DEFB 255,240,0,249,255,139,225,135
  DEFB 255,255,255,192,0,159,195,63
  DEFB 255,143,248,127,15,252,63,15
  DEFB 254,31,7,255,143,7,255,199
  DEFB 7,7,15,15,31,31,31,31
  DEFB 15,15,7,7,7,7,7,15
  DEFB 15,15,15,15,15,15,31,31
  DEFB 63,245,0,255,63,239,0,255
  DEFB 63,253,0,255,63,235,0,255
  DEFB 15,250,192,255,15,255,192,127
  DEFB 15,251,192,255,15,253,192,127
  DEFB 3,255,240,95,3,254,240,255
  DEFB 3,255,240,223,3,254,240,191
  DEFB 0,255,252,175,0,255,252,247
  DEFB 0,255,252,191,0,255,252,215
  DEFB 126,235,0,255,126,223,0,255
  DEFB 126,251,0,255,126,215,0,255
  DEFB 31,245,128,255,31,254,128,255
  DEFB 31,247,128,255,31,250,128,255
  DEFB 7,254,224,191,7,253,224,255
  DEFB 7,255,224,191,7,253,224,127
  DEFB 1,255,248,95,1,255,248,239
  DEFB 1,255,248,127,1,255,248,175
  DEFB 31,154,47,154,32,16,48,48
  DEFB 40,24,12,12,12,8,255,255
  DEFB 255,207,63,154,0,0,8,24
  DEFB 16,48,8,16,24,28,255,255
  DEFB 255,239,79,154,0,16,16,24
  DEFB 8,8,12,14,22,20,255,255
  DEFB 255,239,95,154,0,12,24,24
  DEFB 8,60,28,14,0,2,255,255
  DEFB 255,239,111,154,0,16,16,48
  DEFB 96,96,24,8,24,12,255,255
  DEFB 255,239,127,154,0,16,24,12
  DEFB 4,24,8,24,96,56,255,255
  DEFB 255,239,143,154,0,24,4,8
  DEFB 4,24,48,48,32,32,255,255
  DEFB 255,239,31,154,0,16,24,12
  DEFB 4,24,8,24,96,56,255,255
  DEFB 255,239,161,154,182,154,6,224
  DEFB 0,56,156,0,124,126,0,254
  DEFB 248,0,124,252,0,126,248,0
  DEFB 124,203,154,6,224,0,0,143
  DEFB 0,56,31,128,124,15,0,254
  DEFB 143,0,124,206,128,126,224,154
  DEFB 6,224,0,0,143,0,56,31
  DEFB 128,124,15,0,254,143,112,124
  DEFB 206,224,126,245,154,6,224,0
  DEFB 0,143,0,56,31,128,124,15
  DEFB 0,254,143,96,124,206,224,126
  DEFB 10,155,6,224,0,0,143,0
  DEFB 56,31,128,124,15,128,254,143
  DEFB 128,124,207,192,126,31,155,6
  DEFB 224,0,0,135,128,56,15,192
  DEFB 124,7,128,254,135,128,124,207
  DEFB 128,126,52,155,6,224,0,0
  DEFB 135,128,56,15,192,124,7,128
  DEFB 254,183,128,124,223,128,126,161
  DEFB 154,6,224,0,0,143,0,56
  DEFB 31,128,124,15,0,254,143,0
  DEFB 124,206,128,126,75,155,79,155
  DEFB 107,155,83,155,128,155,87,155
  DEFB 149,155,91,155,149,155,95,155
  DEFB 149,155,99,155,149,155,103,155
  DEFB 128,155,75,155,107,155,10,130
  DEFB 1,160,7,240,7,248,31,248
  DEFB 63,240,7,248,15,232,15,224
  DEFB 7,240,7,10,130,1,224,15
  DEFB 224,15,240,31,248,63,224,15
  DEFB 224,15,224,15,224,7,240,3
  DEFB 10,130,25,240,61,240,127,252
  DEFB 127,254,63,248,63,240,79,240
  DEFB 7,224,3,224,3,172,155,176
  DEFB 155,156,64,180,155,89,64,184
  DEFB 155,152,64,188,155,148,64,192
  DEFB 155,19,72,196,155,240,64,200
  DEFB 155,76,72,204,155,137,72,208
  DEFB 155,198,72,172,155,229,72,0
  DEFB 4,0,4,1,136,3,248,34
  DEFB 216,30,140,12,4,24,6,24
  DEFB 15,16,28,32,40,252,12,6
  DEFB 62,7,225,0,64,0,0,246
  DEFB 155,15,33,156,10,108,156,2
  DEFB 183,156,10,15,156,10,108,156
  DEFB 2,183,156,10,24,156,1,33
  DEFB 156,0,241,68,2,48,0,0
  DEFB 16,0,0,15,72,2,3,0
  DEFB 0,6,0,0,164,72,24,216
  DEFB 64,0,192,64,0,128,64,0
  DEFB 0,128,0,0,128,0,0,128
  DEFB 0,0,128,0,129,0,0,185
  DEFB 0,0,70,0,0,64,0,0
  DEFB 192,0,0,128,0,0,128,0
  DEFB 0,64,0,0,64,0,0,126
  DEFB 0,0,127,240,0,127,159,0
  DEFB 127,136,224,127,8,24,127,0
  DEFB 6,127,16,193,255,16,57,164
  DEFB 72,24,216,64,1,192,64,7
  DEFB 128,64,30,0,128,120,0,128
  DEFB 244,0,129,116,0,129,120,129
  DEFB 2,104,185,2,8,70,4,48
  DEFB 64,24,64,192,34,128,128,65
  DEFB 128,128,241,0,65,250,0,67
  DEFB 254,0,127,254,0,127,252,0
  DEFB 127,248,0,127,240,0,127,192
  DEFB 0,127,0,0,248,0,0,192
  DEFB 0,0,164,72,24,216,70,0
  DEFB 192,70,0,128,78,0,0,142
  DEFB 0,0,156,0,0,156,0,0
  DEFB 158,0,129,25,0,185,44,128
  DEFB 70,78,128,64,65,0,192,66
  DEFB 0,128,132,0,128,196,0,67
  DEFB 148,0,78,8,0,95,8,0
  DEFB 127,144,0,127,160,0,127,192
  DEFB 0,127,128,0,127,128,0,254
  DEFB 0,0,248,0,0,4,157,57
  DEFB 157,25,4,192,15,192,29,96
  DEFB 29,96,63,248,127,252,127,252
  DEFB 63,248,30,240,8,32,9,224
  DEFB 15,248,63,252,127,254,254,255
  DEFB 254,255,254,255,254,255,254,255
  DEFB 254,255,255,255,248,30,124,60
  DEFB 60,60,28,0,4,157,25,6
  DEFB 128,13,96,29,96,63,248,127
  DEFB 252,127,252,63,248,30,240,8
  DEFB 32,9,160,9,224,15,248,63
  DEFB 252,127,254,255,255,255,255,255
  DEFB 255,254,255,254,255,254,255,127
  DEFB 255,0,30,0,60,0,60,0
  DEFB 0,112,157,177,157,31,14,0
  DEFB 15,0,31,192,57,6,13,122
  DEFB 15,154,14,174,251,63,51,64
  DEFB 48,64,48,64,25,128,31,128
  DEFB 31,128,60,128,51,0,111,0
  DEFB 127,0,95,0,31,0,31,0
  DEFB 30,0,30,0,30,0,30,0
  DEFB 14,0,14,0,14,0,14,0
  DEFB 9,0,15,192,112,157,31,28
  DEFB 0,30,0,63,128,115,0,27
  DEFB 12,31,244,29,52,255,127,103
  DEFB 64,98,64,96,64,48,128,63
  DEFB 128,31,128,30,0,25,0,55
  DEFB 0,63,0,47,0,15,0,14
  DEFB 0,14,0,14,0,14,0,14
  DEFB 0,14,0,14,0,14,0,14
  DEFB 0,9,192,15,128,244,157,55
  DEFB 158,32,14,0,31,192,31,0
  DEFB 115,128,24,128,9,128,23,64
  DEFB 40,48,48,8,48,8,49,8
  DEFB 25,4,57,4,74,4,34,8
  DEFB 116,8,124,8,62,8,26,8
  DEFB 1,8,1,8,1,136,1,232
  DEFB 1,240,1,240,1,240,1,240
  DEFB 0,240,0,240,0,240,1,240
  DEFB 7,224,244,157,32,7,0,15
  DEFB 224,15,192,25,192,12,64,5
  DEFB 192,11,32,28,16,16,16,16
  DEFB 8,16,136,40,136,72,136,97
  DEFB 8,242,16,252,16,244,16,102
  DEFB 16,6,16,7,16,7,16,3
  DEFB 144,3,224,3,192,1,192,1
  DEFB 192,1,224,0,224,0,240,0
  DEFB 240,1,240,7,224,124,158,185
  DEFB 158,29,0,16,6,16,5,56
  DEFB 29,16,31,152,13,220,4,156
  DEFB 31,156,58,40,123,104,123,232
  DEFB 251,232,251,228,255,103,63,98
  DEFB 31,233,63,233,63,237,63,111
  DEFB 63,110,63,109,63,109,59,233
  DEFB 59,249,59,249,59,241,123,242
  DEFB 154,124,243,208,124,158,29,0
  DEFB 16,6,16,5,56,29,16,31
  DEFB 144,13,216,4,156,15,156,26
  DEFB 56,59,40,59,232,123,232,123
  DEFB 100,255,231,63,226,31,233,31
  DEFB 105,63,109,63,111,63,110,63
  DEFB 109,63,109,59,233,59,249,59
  DEFB 249,123,241,155,242,242,124,3
  DEFB 208,248,158,55,159,20,0,6
  DEFB 224,0,31,192,0,255,128,0
  DEFB 127,0,0,63,224,0,254,128
  DEFB 1,13,0,1,5,0,2,2
  DEFB 0,2,2,0,2,2,0,4
  DEFB 1,0,4,65,60,4,48,164
  DEFB 8,24,228,8,23,252,16,16
  DEFB 128,32,112,128,64,252,128,33
  DEFB 254,128,248,158,20,0,0,224
  DEFB 0,6,192,0,31,128,0,255
  DEFB 0,0,63,0,0,255,224,1
  DEFB 62,128,2,13,0,2,5,32
  DEFB 4,2,80,4,1,136,4,66
  DEFB 136,8,32,208,8,25,224,16
  DEFB 22,128,16,16,128,16,16,128
  DEFB 32,112,128,64,252,128,33,254
  DEFB 128,120,159,168,159,15,0,14
  DEFB 0,0,17,0,0,249,248,129
  DEFB 7,128,224,253,0,240,58,0
  DEFB 248,204,248,249,152,228,249,252
  DEFB 227,251,227,195,251,224,12,251
  DEFB 240,255,251,252,248,251,251,192
  DEFB 251,248,160,120,159,15,0,7
  DEFB 0,0,8,128,0,124,252,128
  DEFB 131,192,224,126,128,240,29,0
  DEFB 248,39,184,248,76,64,248,254
  DEFB 160,248,249,112,248,240,48,248
  DEFB 240,240,249,254,224,249,249,64
  DEFB 249,248,160,218,159,13,160,16
  DEFB 224,255,0,112,255,0,56,255
  DEFB 192,3,249,0,1,131,0,1
  DEFB 255,1,25,63,227,25,159,247
  DEFB 56,191,239,56,255,223,56,127
  DEFB 191,60,255,127,31,255,127,15
  DEFB 255,127,7,255,127,0,255,127
  DEFB 218,159,16,225,254,0,113,254
  DEFB 0,121,255,128,119,242,0,115
  DEFB 6,0,59,254,1,58,127,131
  DEFB 59,63,199,29,127,239,31,255
  DEFB 223,31,255,191,15,255,127,15
  DEFB 255,127,7,255,127,7,255,127
  DEFB 3,255,127,66,160,129,160,20
  DEFB 0,3,128,0,7,192,0,31
  DEFB 240,0,59,184,0,28,112,0
  DEFB 15,224,0,15,96,0,9,160
  DEFB 0,63,216,0,123,252,0,127
  DEFB 254,0,239,254,0,223,255,0
  DEFB 190,223,1,127,206,1,253,127
  DEFB 248,224,0,224,0,0,224,0
  DEFB 0,192,0,0,66,160,20,0
  DEFB 3,128,0,7,192,0,31,240
  DEFB 0,59,184,0,28,112,0,15
  DEFB 224,0,15,96,0,9,160,0
  DEFB 12,88,0,27,188,0,62,126
  DEFB 0,62,254,0,126,255,0,126
  DEFB 239,0,239,231,0,253,127,248
  DEFB 227,254,224,227,248,224,97,192
  DEFB 192,112,0,194,160,10,50,64
  DEFB 62,161,10,50,64,111,161,10
  DEFB 50,66,217,161,10,50,69,22
  DEFB 162,10,50,71,85,162,10,50
  DEFB 71,152,162,10,82,66,227,162
  DEFB 10,82,69,48,163,20,114,64
  DEFB 127,163,0,20,114,68,200,163
  DEFB 20,114,64,127,163,20,114,68
  DEFB 200,163,20,114,64,127,163,0
  DEFB 20,114,68,200,163,20,114,64
  DEFB 127,163,3,114,68,200,163,0
  DEFB 3,82,69,48,163,3,82,66
  DEFB 227,162,3,50,71,152,162,3
  DEFB 50,71,85,162,3,50,69,22
  DEFB 162,3,50,66,217,161,3,50
  DEFB 64,111,161,1,50,64,160,161
  DEFB 0,24,0,0,3,128,243,247
  DEFB 243,247,243,247,243,247,243,247
  DEFB 243,247,243,247,243,247,229,247
  DEFB 247,247,243,247,243,247,243,247
  DEFB 243,247,243,247,243,247,240,119
  DEFB 0,7,255,255,0,7,255,255
  DEFB 0,3,24,0,16,0,16,241
  DEFB 23,243,151,247,215,244,87,243
  DEFB 215,242,119,241,183,243,247,231
  DEFB 215,247,247,255,215,253,215,233
  DEFB 215,243,215,243,247,247,119,247
  DEFB 119,3,103,251,175,5,103,247
  DEFB 127,0,3,28,0,32,0,48
  DEFB 240,55,240,55,240,55,240,55
  DEFB 240,55,240,55,240,55,224,247
  DEFB 224,183,224,119,240,55,240,55
  DEFB 240,55,240,55,240,55,240,55
  DEFB 240,23,0,7,255,255,0,7
  DEFB 255,255,0,3,0,3,255,255
  DEFB 0,1,0,1,30,240,55,240
  DEFB 55,240,55,244,55,238,247,223
  DEFB 55,209,119,239,55,233,55,230
  DEFB 55,223,183,189,87,189,215,111
  DEFB 55,79,55,105,55,47,23,15
  DEFB 135,239,191,29,135,221,191,9
  DEFB 131,1,131,253,191,2,129,3
  DEFB 129,255,255,0,0,0,0,255
  DEFB 255,31,240,55,240,55,242,55
  DEFB 245,55,247,183,232,215,231,183
  DEFB 228,183,227,55,223,183,190,215
  DEFB 190,231,183,247,183,247,55,215
  DEFB 167,175,0,135,247,127,7,131
  DEFB 15,131,237,223,13,193,12,129
  DEFB 236,255,12,0,20,0,220,255
  DEFB 255,255,255,224,0,0,0,15
  DEFB 33,243,55,246,183,231,183,236
  DEFB 87,231,183,244,183,242,183,243
  DEFB 183,247,231,238,119,222,119,159
  DEFB 231,63,231,183,247,55,251,215
  DEFB 155,4,67,7,131,247,191,7
  DEFB 129,15,193,237,223,13,192,5
  DEFB 192,253,191,253,191,253,160,1
  DEFB 64,0,239,255,255,255,255,255
  DEFB 240,0,0,37,240,55,240,55
  DEFB 224,247,227,55,229,183,247,215
  DEFB 232,103,247,215,244,183,245,183
  DEFB 239,215,239,215,28,231,220,247
  DEFB 63,235,191,247,55,243,119,227
  DEFB 103,191,104,129,15,129,239,191
  DEFB 31,128,29,192,221,223,221,223
  DEFB 237,192,12,128,12,15,238,255
  DEFB 238,255,210,240,28,0,0,15
  DEFB 255,255,255,255,255,255,38,224
  DEFB 183,224,119,240,55,243,55,246
  DEFB 183,239,215,220,39,239,215,244
  DEFB 151,2,135,251,191,7,231,239
  DEFB 247,30,115,30,99,191,239,119
  DEFB 241,87,249,167,219,7,128,0
  DEFB 128,247,191,239,191,239,192,31
  DEFB 192,29,207,221,223,221,223,233
  DEFB 208,1,128,1,143,253,191,253
  DEFB 95,254,239,255,248,0,0,0
  DEFB 7,255,248,39,240,55,240,55
  DEFB 240,55,243,55,245,183,247,215
  DEFB 8,103,247,223,4,135,244,191
  DEFB 15,195,63,195,191,239,126,105
  DEFB 118,117,119,253,103,240,39,224
  DEFB 247,191,247,191,232,160,15,0
  DEFB 15,143,239,191,223,223,221,208
  DEFB 29,192,29,207,220,191,236,255
  DEFB 238,255,238,248,14,0,18,7
  DEFB 220,248,0,0,0,0,0,0
  DEFB 0,0,36,240,55,240,55,240
  DEFB 23,0,7,191,127,125,135,239
  DEFB 223,216,99,207,195,228,191,118
  DEFB 129,127,129,191,239,31,240,14
  DEFB 112,238,123,239,221,247,220,7
  DEFB 206,7,158,247,251,232,239,239
  DEFB 176,15,128,15,143,223,223,221
  DEFB 223,221,223,221,216,61,224,57
  DEFB 231,184,232,56,224,48,192,80
  DEFB 160,240,240,32,143,191,127,71
  DEFB 247,223,204,115,195,227,226,95
  DEFB 114,129,123,129,191,239,63,240
  DEFB 30,112,222,123,239,221,247,220
  DEFB 7,206,7,158,247,251,232,239
  DEFB 239,176,15,128,15,143,223,223
  DEFB 221,223,221,223,221,216,61,224
  DEFB 57,231,184,232,56,224,48,192
  DEFB 80,160,240,240,220,5,10,0

; Delay for BC units, B times
  PUSH BC                 ; Save the repeat count
  CALL 42026              ; Play the shootout sound effect
  LD BC,(41993)           ; BC=the delay length
  DEC BC                  ; Count the delay down
  LD A,B                  ; Test BC...
  OR C                    ; ...for zero
  JR NZ,42005             ; Loop until it is zero
  POP BC                  ; Restore the repeat count
  DJNZ 41997              ; Repeat B times
  RET                     ; Return

; Short delay (length at 41995)
  PUSH BC                 ; Save BC
  LD BC,(41995)           ; BC=the short delay length
  DEC BC                  ; Count down
  LD A,B                  ; Test BC...
  OR C                    ; ...for zero
  JR NZ,42019             ; Loop until it is zero
  POP BC                  ; Restore BC
  RET                     ; Return

; Play the shootout sound effect
;
; Plays the bit pattern at 42057 through the speaker.
  LD HL,42057             ; HL=the sound data
  LD DE,40                ; DE=40: the number of bytes
  LD C,(HL)               ; C=the next byte of the pattern
  LD B,8                  ; B=8 bits
  LD A,0                  ; A=0: the speaker and border low
  RLC C                   ; Rotate the next bit out
  JR NC,42043             ; Zero: leave the speaker low
  LD A,24                 ; A=24: speaker on (bit 4) and MIC (bit 3)
  OUT (254),A             ; Output it
  CALL 42014              ; Wait a short time
  DJNZ 42035              ; Next bit
  INC HL                  ; Next byte
  DEC DE                  ; One fewer left
  LD A,D                  ; Test DE...
  OR E                    ; ...for zero
  JR NZ,42032             ; Loop until all are played
  RET                     ; Return

; Shootout: sound effect data
;
; Played by 42026.
  DEFB 12,225,227,28,57,206,65,188
  DEFB 195,206,71,28,248,102,114,75
  DEFB 184,247,56,179,199,153,156,227
  DEFB 49,238,38,39,138,49,195,230
  DEFB 98,199,29,27,28,230,60,124
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0

; Shootout with the hit man from Detroit
;
; An arcade sequence. Mugsy (controlled with Q/Z up/down, I/P left/right and
; B/N/M to fire) must shoot the hit man in a restaurant before the hit man
; shoots him. Installs its own IM2 interrupt routine (ISR2), sets Mugsy's hit
; points to (A AND 7)+1 (42301; the hit man always has 4, at 42302), runs the
; game and restores IM1 on exit.
;
;  Input:A Value from the handout: Mugsy gets (A AND 7)+1 hit points (8 if A is
;          255)
; Output:A Result: bit 0 set if Mugsy was killed; bits 2-3 set if bystanders
;          were hit
SHOOTOUT:
  DI                      ; Interrupts off while the IM2 handler is installed
  PUSH AF                 ; Save the strength value passed in A (it is needed
                          ; again below)
  LD HL,ISR2              ; HL=address of the shootout's interrupt routine
  LD (53457),HL           ; Patch it into the JP at 53457 that the IM2 vector
                          ; table (53504) leads to
  LD A,209                ; A=209: the high byte of the vector table address,
                          ; which is filled with 208
  LD I,A                  ; Set the interrupt vector register: IM 2 interrupts
                          ; now vector through 53504
  IM 2                    ; Select interrupt mode 2
  LD A,0                  ; A=0: black border, speaker off
  OUT (254),A             ; Set the border colour and speaker
  POP AF                  ; Get the strength value back
  AND 7                   ; Keep the low 3 bits (0-7)
  INC A                   ; Add 1 to make 1-8
  LD (42301),A            ; Store it as Mugsy's hit points (the hit man's
                          ; bullets take one off each time they hit him)
  CALL 42639              ; Draw the restaurant and put the figures in place
  CALL 42977              ; Main loop: let any figure whose timer says it is
                          ; ready decide what to do next
  CALL 44766              ; Deal with Mugsy's and the hit man's bullets landing
  CALL 44884              ; Deal with anyone who has been hit
  LD A,(42335)            ; A=the "shootout over" flag (set when Mugsy or the
                          ; hit man has fallen over)
  AND A                   ; Test it
  JR Z,42140              ; Keep going until it is set
  LD BC,65535             ; BC=65535: a pause of about a second and a half so
                          ; the player can see the result
  DEC BC                  ; Count BC down
  LD A,B                  ; A=B
  OR C                    ; Combine with C to test for zero
  JR NZ,42158             ; Loop until BC is zero
  LD A,63                 ; A=63: the high byte of the ROM's interrupt table
                          ; address
  LD I,A                  ; Put the interrupt vector register back as the ROM
                          ; expects it
  IM 1                    ; Back to interrupt mode 1
  LD A,(42334)            ; A=the result bits (bit 0 Mugsy killed, bit 1 hit
                          ; man killed, bit 2 bystander 1 hit, bit 3 bystander
                          ; 2 hit)
  DI                      ; Leave with interrupts disabled (the caller restores
                          ; the ROM's FLAGS)
  RET                     ; Return to the VM's native-call routine

; Shootout: animation frame tables
;
; Four bytes per frame: a direction mask, the graphic height in pixel rows, and
; the address of the graphic. Mugsy, the hit man and the bystanders each use a
; table (42174, 42194, 42206, 42222 ...).
  DEFB 4,32,170,186,4,32,234,186
  DEFB 4,32,42,187,4,32,106,187
  DEFB 4,32,170,187,4,32,234,185
  DEFB 4,32,42,186,4,32,106,186
  DEFB 4,32,234,183,4,32,42,184
  DEFB 4,32,106,184,4,32,170,184
  DEFB 4,32,234,184,4,32,42,185
  DEFB 4,32,106,185,4,32,170,185

; Shootout: figure handlers
;
; One handler per figure slot, called by 42977.
  DEFW 43018,43246,43471,43814
  DEFW 44294,44416

; Shootout: figure timers
;
; 0 = counting down, 1 = ready for orders, 2 and 3 = waiting/parked. One byte
; per figure slot (the seventh is the furniture slot).
  DEFB 3,3,3,3,3,3,3

; Shootout: countdown pointers
;
; The address of each figure slot's countdown record, used by the interrupt
; routine ISR2.
  DEFW 42271,42274,42277,42280
  DEFW 42283,42286,42289

; Shootout: figure countdowns
;
; Three bytes per figure slot: the number of interrupts left before the next
; frame is drawn, and the address of the figure's record plus 3 (where the
; drawing job begins).
  DEFB 0,138,165,0,177,165,0,216
  DEFB 165,0,255,165,0,38,166,0
  DEFB 77,166,0,113,166

; Shootout: variables
;
; +-------------+-------------------------------------------------------------+
; | Address     | Meaning                                                     |
; +-------------+-------------------------------------------------------------+
; | 42292-42297 | Route script pointers for bystander 1, bystander 2 and the  |
; |             | hit man                                                     |
; | 42298       | Upper limit on the screen for Mugsy and the hit man         |
; | 42300       | Set once the sprite graphics have been inverted             |
; | 42301       | Mugsy's remaining hit points (from the handout)             |
; | 42302       | The hit man's remaining hit points (4)                      |
; | 42303-42306 | Saved stack pointer and temporary                           |
; | 42307       | Frame buffer address                                        |
; | 42309       | Frame table address                                         |
; | 42311       | Number of figure slots in use                               |
; | 42312-42313 | Number of frames in the current animation and delay between |
; |             | frames                                                      |
; | 42314       | Left limit for the current figure                           |
; | 42315       | Direction code from the keyboard                            |
; | 42316-42317 | Firing state of Mugsy and the hit man                       |
; | 42318-42321 | Steps left for the two bullets and bullet cancel flags      |
; | 42322       | Set when a figure could not move                            |
; | 42323-42326 | Bystander 1, bystander 2, Mugsy and the hit man have gone   |
; |             | down                                                        |
; | 42327-42328 | A bullet touches bystander 1 or bystander 2                 |
; | 42329-42330 | Mugsy or the hit man has run out of hit points              |
; | 42331-42332 | Mugsy's or the hit man's bullet has landed                  |
; | 42333       | Somebody has gone down in this pass of the main loop        |
; | 42334       | The result: bit 0 Mugsy killed, bit 1 hit man killed, bits  |
; |             | 2-3 bystanders hit                                          |
; | 42335       | The shootout is over                                        |
; +-------------+-------------------------------------------------------------+
  DEFB 53,182,233,182,186,183,128,64
  DEFB 0,0,4,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0

; Shootout: figure workspace
;
; A 39-byte copy of the figure being worked on, made by 45693 and copied back
; by 45702.
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0

; Shootout: figure records
;
; Six 39-byte records (bystander 1 at 42375, bystander 2 at 42414, Mugsy at
; 42453, the hit man at 42492, Mugsy's bullet at 42531 and the hit man's bullet
; at 42570) and a seventh, shorter one at 42609 for the furniture. Byte 0 is
; the state (4 facing right, 64 left, other values diagonals), 1 and 2 are
; counters, 3-10 hold the registers for the drawing job (screen address,
; graphic address, routine address), 17-18 is the screen address and 29-30 the
; attribute address.
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,16,0,16,0,1
  DEFB 141,179,0,16,0,16,0,1
  DEFB 84,72,146,188,8,8,0,16
  DEFB 207,179,0,16,84,89,2,34

; Shootout: set up the restaurant
  CALL 46305              ; Clear the screen and draw the walls, door and
                          ; window
  LD HL,42303             ; HL=start of the flag area (42303-42335)
  LD B,33                 ; B=33 bytes to clear
  XOR A                   ; A=0
  LD (HL),A               ; Clear a flag
  INC HL                  ; Move on
  DJNZ 42648              ; Loop for all 33 bytes
  LD HL,42250             ; HL=the figure timers (one byte per figure, from
                          ; 42250)
  LD B,7                  ; B=7 timers
  LD (HL),3               ; Set a timer to 3: "idle" (1 means ready for orders,
                          ; 0 means a countdown is running)
  INC HL                  ; Next timer
  DJNZ 42657              ; Loop for all seven
  LD BC,405               ; BC=405
  LD HL,24575             ; HL=24575, the top of a work area below the code
  LD DE,24574             ; DE=24574
  XOR A                   ; A=0
  LD (HL),A               ; Clear the first byte of the work area
  LDDR                    ; Clear 405 more, working backwards (24170-24575):
                          ; the sprite frame buffers are cleaned out
  LD BC,60                ; BC=60
  LD HL,24115             ; HL=24115
  LD DE,24114             ; DE=24114
  LD A,56                 ; A=56: white paper, black ink
  LD (HL),A               ; Store the first attribute
  LDDR                    ; Fill 60 attribute bytes (24055-24115) with white
                          ; paper
  LD A,(42300)            ; A=has the walls graphic been inverted already?
                          ; (42300)
  AND A                   ; Test it
  JR NZ,42715             ; Skip the inversion if it has
  LD A,1                  ; A=1
  LD (42300),A            ; Mark the sprite data as inverted (it is stored
                          ; inverted in the file and flipped once, on first
                          ; use)
  LD HL,47082             ; HL=start of the sprite data (47082)
  LD BC,1326              ; BC=1326 bytes
  LD A,(HL)               ; Fetch a byte of sprite data
  CPL                     ; Invert it
  LD (HL),A               ; Store it back
  INC HL                  ; Next byte
  DEC BC                  ; Count down
  LD A,C                  ; A=C
  OR B                    ; Combine with B
  JR NZ,42706             ; Loop until all 1326 bytes are done
  LD A,7                  ; A=7
  LD (42311),A            ; Seven figure slots to service while the furniture
                          ; is drawn (the seventh draws furniture)
  LD A,1                  ; A=1
  LD (42289),A            ; Make the furniture slot's timer expire at once
  LD HL,45711             ; HL=first furniture descriptor (45711)
  CALL 42940              ; Load it into the furniture slot's record
  CALL 42931              ; Wait for the interrupt routine to draw it
  LD HL,18633             ; HL=screen address of the next piece
  LD DE,22985             ; DE=its attribute address
  CALL 42970              ; Request a redraw and wait
  LD HL,20564             ; HL=screen address
  LD DE,23124             ; DE=attribute address
  CALL 42970              ; Request a redraw and wait
  LD HL,18653             ; HL=screen address
  LD DE,23005             ; DE=attribute address
  CALL 42970              ; Request a redraw and wait
  LD A,1                  ; A=1
  LD (42289),A            ; Re-arm the furniture slot's timer
  LD HL,45721             ; HL=second furniture descriptor (45721)
  CALL 42940              ; Load it into the furniture slot's record
  CALL 42931              ; Wait for the interrupt routine to draw it
  LD HL,18599             ; HL=screen address of a copy
  LD DE,22951             ; DE=its attribute address
  CALL 42970              ; Redraw and wait
  LD HL,20530             ; HL=screen address
  LD DE,23090             ; DE=attribute address
  CALL 42970              ; Redraw and wait
  LD HL,18619             ; HL=screen address
  LD DE,22971             ; DE=attribute address
  CALL 42970              ; Redraw and wait
  LD HL,48354             ; HL=address of the third furniture graphic (48354)
  LD (42625),HL           ; Patch it into the furniture slot's record
  LD HL,18455             ; HL=screen address
  LD DE,22807             ; DE=attribute address
  CALL 42970              ; Redraw and wait
  LD HL,18603             ; HL=screen address
  LD DE,22955             ; DE=attribute address
  CALL 42970              ; Redraw and wait
  LD HL,20534             ; HL=screen address
  LD DE,23094             ; DE=attribute address
  CALL 42970              ; Redraw and wait
  LD HL,45731             ; HL=initial records of the six real figures (45731)
  LD DE,42375             ; DE=the first figure's record (42375)
  LD BC,234               ; BC=234 bytes (6 records of 39)
  LDIR                    ; Copy the figure records into place
  LD A,6                  ; A=6
  LD (42311),A            ; From now on only six slots are serviced (the
                          ; furniture slot is retired)
  LD HL,23875             ; HL=23875: a sprite frame buffer
  LD (42307),HL           ; Use it for the next figure drawn
  LD HL,42492             ; HL=42492: the hit man's record
  PUSH HL                 ; Save it
  CALL 45693              ; Copy the record into the workspace
  CALL 45079              ; Work out where to draw him
  CALL 45201              ; Draw him
  POP DE                  ; DE=the record again
  CALL 45702              ; Copy the workspace back into the record
  LD HL,42253             ; HL=42253: the timer for figure 3 (the hit man)
  LD (HL),0               ; Set it to 0: his countdown starts running
  LD A,1                  ; A=1
  LD (42280),A            ; The hit man waits one tick before first acting
  EI                      ; Enable interrupts
  HALT                    ; Let one interrupt happen
  DI                      ; Disable interrupts again
  LD HL,42527             ; HL=42527: the hit man's record, byte +35
  LD (HL),1               ; Set it to 1
  LD HL,42253             ; HL=42253 (the hit man's timer)
  LD (HL),3               ; Set it to 3: idle
  LD HL,42250             ; HL=42250: the timers again
  LD (HL),1               ; Set the first timer to 1: bystander 1 may act at
                          ; once
  INC HL                  ; Next timer
  LD (HL),1               ; Set the second timer to 1: bystander 2 may act at
                          ; once
  LD HL,46645             ; HL=bystander 1's route script (46645)
  LD (42292),HL           ; Store it as that figure's script pointer
  LD HL,46825             ; HL=bystander 2's route script (46825)
  LD (42294),HL           ; Store it
  LD HL,47058             ; HL=the hit man's route script (47058)
  LD (42296),HL           ; Store it
  LD HL,16512             ; HL=16512: the top row of the playing area on the
                          ; screen
  LD (42298),HL           ; Store it as the upper limit for Mugsy and the hit
                          ; man
  EI                      ; Enable interrupts: the shootout is live
  RET                     ; Return

; Shootout: wait for an interrupt
  LD HL,42256             ; HL=the furniture slot's timer
  LD (HL),0               ; Set it to 0 so that the interrupt routine runs its
                          ; countdown
  EI                      ; Enable interrupts
  HALT                    ; Wait for the next interrupt
  DI                      ; Disable interrupts
  RET                     ; Return

; Shootout: load a furniture descriptor into the furniture slot
;
; Copies the 10-byte descriptor at HL: 6 bytes (screen address and graphic
; data) and then 4 bytes (attribute address and colour) into the seventh figure
; record, which the interrupt routine draws.
  LD DE,42623             ; DE=where the furniture slot keeps its first six
                          ; data bytes (42623)
  LD BC,6                 ; BC=6 bytes
  LDIR                    ; Copy the screen position and graphic data
  LD DE,42635             ; DE=where it keeps the attribute data (42635)
  LD BC,4                 ; BC=4 bytes
  LDIR                    ; Copy them
  RET                     ; Return

; Shootout: place a piece of furniture (HL=screen address, DE=attribute
; address)
  LD A,1                  ; A=1
  LD (42289),A            ; Re-arm the furniture slot's timer
  LD (42623),HL           ; Store the screen address
  LD (42635),DE           ; Store the attribute address
  RET                     ; Return

; Shootout: draw a piece of furniture and wait for the interrupt
  CALL 42957              ; Set the new position
  CALL 42931              ; Let the interrupt routine draw it
  RET                     ; Return

; Shootout: main loop (the figure dispatcher)
;
; The shootout is a small cooperative scheduler. Each of the six figures
; (bystander 1, bystander 2, Mugsy, the hit man, Mugsy's bullet and the hit
; man's bullet) has a timer byte at 42250+n and a handler address in the table
; at 42238. A timer of 0 means that the figure's countdown is running; the
; interrupt routine ISR2 ticks the countdown and, when it reaches zero, draws
; the figure's next frame and sets the timer to 1. A timer of 1 tells this
; routine that the figure is ready for new orders: it runs the handler, which
; reads the next byte of the figure's route script (or the keyboard, for
; Mugsy), moves it, and leaves the timer to be decremented back to 0. A timer
; of 3 parks a figure for good.
  XOR A                   ; A=0
  LD (42333),A            ; Clear the "somebody is down" flag for this pass of
                          ; the loop
  LD A,(42311)            ; A=number of figure slots in use (7 while the
                          ; furniture is drawn, then 6)
  LD B,A                  ; B=the slot count
  LD C,0                  ; C=0: the slot number
  LD HL,42250             ; HL=the slot timers (42250...)
  LD A,1                  ; A=1: a timer of 1 means the figure is ready for new
                          ; orders
  CP (HL)                 ; Is this slot's timer 1?
  JR NZ,43013             ; No: leave this figure alone for now
  PUSH BC                 ; Save the loop counter and slot number
  PUSH HL                 ; Save the timer pointer
  LD B,0                  ; B=0
  RL C                    ; C=slot number*2: the offset into the handler table
  LD HL,42238             ; HL=handler table (42238)
  ADD HL,BC               ; Point at this slot's entry
  LD E,(HL)               ; E=low byte of the handler address
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  EX DE,HL                ; HL=handler address
  JP (HL)                 ; Run the handler (it ends with JP 43010)
  POP HL                  ; Restore the timer pointer
  POP BC                  ; Restore the loop counter and slot number
  DEC (HL)                ; Timer 1 becomes 0: the interrupt routine now counts
                          ; this figure's next move down
  INC HL                  ; Next slot's timer
  INC C                   ; Next slot number
  DJNZ 42990              ; Loop for all slots
  RET                     ; Return

; Shootout: handler for bystander 1
;
; Route script bytes are direction codes (4 right, 64 left, 2 up-right, 128
; up-left, 8 down-right, 32 down-left), 0 for "stand still for a tick", 80, 81
; and 82 for standing for 25, 1 or 128 ticks, 255 to hand over to the next
; figure and 254 to leave the restaurant and end the shootout.
  LD A,(42323)            ; Handler for slot 0 (bystander 1): A=has he already
                          ; gone down or left?
  AND A                   ; Test it
  JR Z,43032              ; No: carry on
  LD HL,42250             ; HL=his timer
  LD (HL),3               ; Park the timer at 3 so he is never serviced again
  JP 43010                ; Back to the dispatcher
  LD A,(42327)            ; A=has a bullet hit him?
  AND A                   ; Test it
  JR NZ,43074             ; Yes: make him fall over
  LD HL,(42292)           ; HL=his script pointer
  LD A,(HL)               ; A=the next script byte
  CP 254                  ; 254: end of the script
  JP Z,43183              ; Handle that below
  CP 255                  ; 255: hand over to the hit man
  JR Z,43170              ; Handle that below
  CP 80                   ; 80: stand still for a long time
  JR Z,43143              ; Handle that below
  CP 81                   ; 81: stand still for one tick
  JR Z,43152              ; Handle that below
  CP 82                   ; 82: stand still for a very long time
  JR Z,43161              ; Handle that below
  CP 0                    ; 0: a plain animation step
  JR Z,43098              ; Handle that with the moves
  AND 238                 ; Keep only the bits that are not 1 or 16
  JR NZ,43098             ; A real direction code: make the move
  JP 43010                ; Anything else (1, 16 or 17) is ignored this time
  LD HL,42334             ; HL=the result byte (42334)
  SET 2,(HL)              ; Set bit 2: bystander 1 has been hit
  LD (42323),A            ; Remember that he is down (A is non-zero)
  LD A,30                 ; A=30
  LD (42271),A            ; He lies there for 30 ticks before his countdown
                          ; ends
  LD A,8                  ; A=8: the falling animation length
  LD BC,48250             ; BC=48250: the falling-over graphic
  LD HL,42375             ; HL=his record (42375)
  JP 44558                ; Set up the falling animation
  PUSH HL                 ; Save the script pointer
  LD A,4                  ; A=4
  LD (42312),A            ; Four animation frames in the cycle
  DEC A                   ; A=3
  LD (42313),A            ; The frame delay is 3
  DEC A                   ; A=2
  LD (42271),A            ; His countdown is 2 ticks
  LD HL,42174             ; HL=the walking frame table (42174)
  LD (42309),HL           ; Use it
  LD HL,23575             ; HL=23575: the frame buffer for this figure
  LD (42307),HL           ; Use it
  XOR A                   ; A=0
  LD (42314),A            ; Reset the left limit
  POP HL                  ; Get the script pointer back
  LD A,(HL)               ; A=the direction code from the script
  INC HL                  ; Move the pointer on
  LD (42292),HL           ; Store the new script pointer
  LD HL,42375             ; HL=his record
  CALL 44953              ; Move him and redraw
  JP 43010                ; Back to the dispatcher
  EX DE,HL                ; 80: swap pointer and frame table
  LD HL,42190             ; HL=standing frame table (42190)
  LD A,25                 ; A=25: stand for 25 ticks
  JP 43220                ; Carry on
  EX DE,HL                ; 81: swap pointer and frame table
  LD HL,42174             ; HL=walking frame table (42174)
  LD A,1                  ; A=1: one tick
  JP 43220                ; Carry on
  EX DE,HL                ; 82: swap pointer and frame table
  LD HL,42174             ; HL=walking frame table
  LD A,128                ; A=128: a long wait
  JP 43220                ; Carry on
  LD HL,42250             ; 255: HL=his timer
  LD (HL),3               ; Park him at 3
  INC HL                  ; Move to the next timer
  INC HL                  ; And the next
  INC HL                  ; And the hit man's timer
  LD (HL),1               ; Make the hit man ready for orders
  JP 43010                ; Back to the dispatcher
  LD HL,42375             ; 254: HL=his record
  PUSH HL                 ; Save it
  CALL 45693              ; Copy it to the workspace
  CALL 45155              ; Copy his coordinates
  LD HL,1000              ; HL=1000: off the screen
  LD (42353),HL           ; Move him off the screen
  LD (42365),HL           ; And his attribute address
  POP DE                  ; DE=the record
  CALL 45702              ; Copy the workspace back
  LD A,1                  ; A=1
  LD (42323),A            ; He is gone
  LD (42271),A            ; His countdown is 1
  LD (42335),A            ; Set the "shootout over" flag
  JP 43010                ; Back to the dispatcher
  INC DE                  ; Point past the script byte
  LD (42292),DE           ; Store the new script pointer
  LD (42271),A            ; Set the countdown
  LD (42309),HL           ; Set the frame table
  LD HL,23575             ; HL=frame buffer
  LD (42307),HL           ; Use it
  LD HL,42375             ; HL=his record
  CALL 44726              ; Redraw him
  JP 43010                ; Back to the dispatcher

; Shootout: handler for bystander 2
  LD A,(42324)            ; Handler for slot 1 (bystander 2): has he gone down?
  AND A                   ; Test it
  JR Z,43260              ; No: carry on
  LD HL,42251             ; HL=his timer
  LD (HL),3               ; Park it
  JP 43010                ; Back to the dispatcher
  LD A,(42328)            ; Has a bullet hit him?
  AND A                   ; Test it
  JR NZ,43302             ; Yes: make him fall over
  LD HL,(42294)           ; HL=his script pointer
  LD A,(HL)               ; A=the next script byte
  CP 254                  ; 254: end of script
  JP Z,43408              ; Handle that below
  CP 255                  ; 255: hand over
  JR Z,43397              ; Handle that below
  CP 80                   ; 80: stand still for a long time
  JR Z,43370              ; Handle that below
  CP 81                   ; 81: stand still for one tick
  JR Z,43379              ; Handle that below
  CP 82                   ; 82: stand still for a while
  JR Z,43388              ; Handle that below
  CP 0                    ; 0: plain step
  JR Z,43326              ; Handle that with the moves
  AND 238                 ; Keep only the bits that are not 1 or 16
  JR NZ,43326             ; A real direction code: move
  JP 43010                ; Ignore 1, 16 and 17
  LD HL,42334             ; HL=the result byte
  SET 3,(HL)              ; Set bit 3: bystander 2 has been hit
  LD (42324),A            ; Remember he is down
  LD A,30                 ; A=30
  LD (42274),A            ; His countdown is 30
  LD A,16                 ; A=16: the falling animation length
  LD BC,48154             ; BC=48154: the falling-over graphic
  LD HL,42414             ; HL=his record (42414)
  JP 44558                ; Set up the falling animation
  PUSH HL                 ; Save the script pointer
  LD A,2                  ; A=2
  LD (42312),A            ; Two animation frames in the cycle
  LD (42313),A            ; Frame delay 2
  INC A                   ; A=3
  LD (42274),A            ; Countdown 3
  LD HL,42194             ; HL=his walking frame table (42194)
  LD (42309),HL           ; Use it
  LD HL,23675             ; HL=frame buffer (23675)
  LD (42307),HL           ; Use it
  XOR A                   ; A=0
  LD (42314),A            ; Reset the left limit
  POP HL                  ; Get the script pointer back
  LD A,(HL)               ; A=the direction code
  INC HL                  ; Advance the pointer
  LD (42294),HL           ; Store it
  LD HL,42414             ; HL=his record
  CALL 44953              ; Move him and redraw
  JP 43010                ; Back to the dispatcher
  EX DE,HL                ; 80: swap
  LD HL,42202             ; HL=standing frame table (42202)
  LD A,25                 ; A=25
  JP 43445                ; Carry on
  EX DE,HL                ; 81: swap
  LD HL,42194             ; HL=walking frame table (42194)
  LD A,1                  ; A=1
  JP 43445                ; Carry on
  EX DE,HL                ; 82: swap
  LD HL,42194             ; HL=walking frame table
  LD A,100                ; A=100: wait
  JP 43445                ; Carry on
  LD HL,42251             ; 255: HL=his timer
  LD (HL),3               ; Park it
  INC HL                  ; Next timer
  LD (HL),1               ; Make slot 2 (Mugsy) ready
  JP 43010                ; Back to the dispatcher
  LD HL,42414             ; 254: HL=his record
  PUSH HL                 ; Save it
  CALL 45693              ; Copy to workspace
  CALL 45155              ; Copy coordinates
  LD HL,1000              ; HL=1000: off screen
  LD (42353),HL           ; Move him off the screen
  LD (42365),HL           ; And his attributes
  POP DE                  ; DE=the record
  CALL 45702              ; Copy back
  LD A,1                  ; A=1
  LD (42324),A            ; He is gone
  LD (42274),A            ; Countdown 1
  LD (42335),A            ; Set the "shootout over" flag
  JP 43010                ; Back to the dispatcher
  INC DE                  ; Point past the script byte
  LD (42294),DE           ; Store the pointer
  LD (42274),A            ; Set the countdown
  LD (42309),HL           ; Set the frame table
  LD HL,23675             ; HL=frame buffer
  LD (42307),HL           ; Use it
  LD HL,42414             ; HL=his record
  CALL 44726              ; Redraw him
  JP 43010                ; Back to the dispatcher

; Shootout: handler for Mugsy
;
; Takes the direction code from CONTROLS, handles firing (state 0 idle, 1 and 2
; raising the gun, 3 firing a bullet) and Mugsy's death.
  LD A,(42325)            ; Handler for slot 2 (Mugsy): is he dead?
  AND A                   ; Test it
  JR Z,43509              ; No: carry on
  LD HL,42252             ; HL=his timer
  LD (HL),3               ; Park it at 3
  LD A,(42333)            ; A=the "somebody is down" flag
  AND A                   ; Test it
  JR NZ,43493             ; Already set: skip
  LD A,1                  ; A=1
  LD (42333),A            ; Tell the other figures that a gunfight has ended
  LD IX,42453             ; IX=his record (42453)
  LD HL,18576             ; HL=18576: where he lies
  LD (IX+17),L            ; Put him there (low byte)
  LD (IX+18),H            ; And the high byte
  JP 43010                ; Back to the dispatcher
  LD A,(42329)            ; Has the hit man's bullet used up his hit points?
  AND A                   ; Test it
  JR NZ,43541             ; Yes: he dies
  LD A,(42316)            ; A=is Mugsy's gun being fired (his fire state)?
  AND A                   ; Test it
  JP NZ,43639             ; Yes: continue the firing sequence
  LD A,(42315)            ; A=the direction code from the keyboard
  LD B,A                  ; B=the code
  CP 10                   ; 10 means fire
  JR Z,43608              ; Start firing
  CP 0                    ; 0 means no key pressed
  JR Z,43565              ; Stand still
  AND 238                 ; Keep only the bits that are not 1 or 16
  JR NZ,43565             ; A real direction: move
  JP 43010                ; Otherwise do nothing
  LD HL,42334             ; HL=the result byte
  SET 0,(HL)              ; Set bit 0: Mugsy has been killed
  LD (42325),A            ; Remember he is dead
  LD A,30                 ; A=30
  LD (42277),A            ; His countdown is 30
  LD A,16                 ; A=16: the falling animation length
  LD BC,48106             ; BC=48106: the falling-over graphic
  LD HL,42453             ; HL=his record (42453)
  JP 44558                ; Set up the falling animation
  LD A,2                  ; A=2
  LD (42312),A            ; Mugsy's animation has two frames
  LD (42277),A            ; Countdown 2
  LD A,4                  ; A=4
  LD (42313),A            ; Frame delay 4
  LD HL,42206             ; HL=Mugsy's walking frame table (42206)
  LD (42309),HL           ; Use it
  LD DE,23775             ; DE=frame buffer (23775)
  LD (42307),DE           ; Use it
  LD IX,42453             ; IX=his record
  CALL 44612              ; Work out the limits of his movement
  LD HL,42453             ; HL=his record
  LD A,B                  ; A=the direction code
  CALL 44953              ; Move him
  JP 43010                ; Back to the dispatcher
  LD HL,42316             ; He is firing: HL=his fire state
  INC (HL)                ; Raise it to 1
  INC (HL)                ; And to 2
  LD HL,42214             ; HL=Mugsy's firing frame table (42214)
  LD (42309),HL           ; Use it
  LD HL,23775             ; HL=frame buffer (23775)
  LD (42307),HL           ; Use it
  LD A,5                  ; A=5
  LD (42277),A            ; Countdown 5
  LD HL,42453             ; HL=his record
  CALL 44726              ; Draw the gun being raised
  JP 43010                ; Back to the dispatcher
  CP 2                    ; Is the fire state 2?
  JP NZ,43779             ; No: end of the firing sequence
  LD IX,42453             ; IX=Mugsy's record
  LD A,(IX+0)             ; A=his state byte
  AND 224                 ; Which way is he facing (bits 5-7)?
  JR NZ,43666             ; Facing left: use that branch
  LD A,(IX+17)            ; A=his screen address, low byte
  AND 31                  ; Column
  CP 28                   ; Is he at column 28, the right wall?
  JR Z,43697              ; Yes: no room for a bullet
  JR 43678                ; Fire the bullet
  LD A,(IX+17)            ; Facing left: A=screen address low byte
  AND 31                  ; Column
  LD B,A                  ; B=column
  LD A,(42314)            ; A=the left limit
  CP B                    ; Same column?
  JR Z,43697              ; Yes: no room for a bullet
  LD IY,42531             ; IY=the bullet's record (42531)
  LD B,11                 ; B=11: the bullet starts 11 pixel rows down
  CALL 43709              ; Position the bullet next to the gun
  LD A,10                 ; A=10
  LD (42318),A            ; The bullet flies for 10 steps
  LD HL,42254             ; HL=the bullet's timer
  LD (HL),1               ; Make the bullet ready to move
  LD HL,42316             ; HL=fire state
  INC (HL)                ; Raise it to 3
  LD A,5                  ; A=5
  LD (42277),A            ; Countdown 5
  JP 43010                ; Back to the dispatcher

; Shootout: place a bullet in front of its owner (B=rows down from the top of
; the figure)
  LD A,(IX+0)             ; A=the owner's state byte
  LD (IY+0),A             ; Give the bullet the same facing
  LD L,(IX+17)            ; L=the owner's screen address, low byte
  LD H,(IX+18)            ; H=high byte
  INC H                   ; Move down one pixel row...
  CALL 45651              ; (using this subroutine)
  DJNZ 43721              ; ...B times
  LD A,(IY+0)             ; A=the bullet's state
  AND 224                 ; Which way?
  JR NZ,43743             ; Left: handle that
  INC L                   ; Facing right: move the bullet two cells right of
                          ; the gun
  INC L                   ; Another one
  LD A,4                  ; A=4: right
  LD (IY+0),A             ; Set the bullet's direction
  JR 43749                ; Carry on
  DEC L                   ; Facing left: one cell to the left
  LD A,64                 ; A=64: left
  LD (IY+0),A             ; Set the direction
  LD (IY+17),L            ; Set the bullet's screen address
  LD (IY+18),H            ; And high byte
  EX DE,HL                ; DE=screen address
  CALL 45626              ; Convert to an attribute address
  LD (IY+29),E            ; Store it
  LD (IY+30),D            ; And high byte
  XOR A                   ; A=0
  LD (IY+3),A             ; Clear some counters
  LD (IY+4),A             ; And another
  LD (IY+13),A            ; And another
  LD (IY+14),A            ; And another
  RET                     ; Return
  LD HL,42218             ; HL=Mugsy's standing frame table (42218)
  LD (42309),HL           ; Use it
  LD HL,23775             ; HL=frame buffer (23775)
  LD (42307),HL           ; Use it
  LD A,6                  ; A=6
  LD (42277),A            ; Countdown 6
  XOR A                   ; A=0
  LD (42316),A            ; Reset the fire state
  LD HL,42453             ; HL=his record
  CALL 44726              ; Redraw him standing
  LD HL,42488             ; HL=42488
  LD (HL),1               ; Set the flag
  JP 43010                ; Back to the dispatcher

; Shootout: handler for the hit man
;
; Follows short move fragments (47034-47081). At the end of each fragment he
; compares his position with Mugsy's and picks a new one that moves him towards
; Mugsy, firing when they are on the same row.
  LD A,(42326)            ; Handler for slot 3 (the hit man): has Mugsy's
                          ; bullet used up his hit points?
  AND A                   ; Test it
  JR Z,43839              ; No: carry on
  LD HL,42253             ; HL=his timer
  LD (HL),3               ; Park it at 3
  LD A,(42333)            ; A=the "somebody is down" flag
  AND A                   ; Test it
  JR NZ,43836             ; Already set: skip
  LD A,1                  ; A=1
  LD (42333),A            ; Set it
  JP 43010                ; Back to the dispatcher
  LD A,(42330)            ; Has Mugsy's bullet used up the hit man's hit
                          ; points?
  AND A                   ; Test it
  JR NZ,43875             ; Yes: he dies
  LD A,(42317)            ; A=the hit man's fire state
  AND A                   ; Test it
  JP NZ,44190             ; Yes: continue the firing sequence
  LD HL,(42296)           ; HL=his script pointer
  LD A,(HL)               ; A=the next script byte
  CP 255                  ; 255: end of the fragment
  JR Z,43977              ; Choose a new one
  CP 10                   ; 10: fire
  JR Z,43938              ; Fire
  CP 0                    ; 0: standing step
  JR Z,43899              ; Do that
  AND 238                 ; Keep only the bits that are not 1 or 16
  JR NZ,43899             ; A real direction: move
  JP 43010                ; Ignore the rest
  LD HL,42334             ; HL=the result byte
  SET 1,(HL)              ; Set bit 1: the hit man has been killed
  LD (42326),A            ; Remember he is dead
  LD A,30                 ; A=30
  LD (42280),A            ; His countdown is 30
  LD A,16                 ; A=16: the falling animation length
  LD BC,48202             ; BC=48202: the falling-over graphic
  LD HL,42492             ; HL=his record (42492)
  JP 44558                ; Set up the falling animation
  PUSH HL                 ; Save the script pointer
  LD A,2                  ; A=2
  LD (42312),A            ; Two frames in the cycle
  LD (42313),A            ; Frame delay 2
  LD (42280),A            ; Countdown 2
  LD HL,42222             ; HL=the hit man's walking frame table (42222)
  LD (42309),HL           ; Use it
  LD HL,23875             ; HL=frame buffer (23875)
  LD (42307),HL           ; Use it
  POP HL                  ; Get the pointer back
  LD A,(HL)               ; A=the direction code
  INC HL                  ; Advance the pointer
  LD (42296),HL           ; Store it
  LD HL,42492             ; HL=his record
  CALL 44953              ; Move him
  JP 43010                ; Back to the dispatcher
  INC HL                  ; Fire: skip the script byte
  LD (42296),HL           ; Store the pointer
  LD HL,42317             ; HL=his fire state
  INC (HL)                ; Raise it to 1
  INC (HL)                ; And to 2
  LD HL,42230             ; HL=the hit man's firing frame table (42230)
  LD (42309),HL           ; Use it
  LD HL,23875             ; HL=frame buffer (23875)
  LD (42307),HL           ; Use it
  LD IX,42492             ; IX=his record
  LD A,8                  ; A=8
  LD (42280),A            ; Countdown 8
  LD HL,42492             ; HL=his record
  CALL 44726              ; Draw the gun being raised
  JP 43010                ; Back to the dispatcher
  XOR A                   ; End of the fragment: work out where Mugsy is
  LD B,A                  ; B=0
  LD C,A                  ; C=0: the direction bits
  LD IX,42453             ; IX=Mugsy's record
  LD IY,42492             ; IY=the hit man's record
  LD A,(IX+17)            ; A=Mugsy's column (low byte)
  AND 31                  ; Keep the column bits
  LD L,A                  ; L=Mugsy's column
  LD A,(IY+17)            ; A=the hit man's address low byte
  AND 31                  ; Column bits
  LD H,A                  ; H=the hit man's column
  LD A,(IX+18)            ; A=Mugsy's address high byte
  AND 24                  ; Which third of the screen?
  LD E,A                  ; E=Mugsy's third
  LD A,(IY+18)            ; A=the hit man's address high byte
  AND 24                  ; Which third?
  LD D,A                  ; D=the hit man's third
  LD A,H                  ; A=the hit man's column
  SUB L                   ; Compare with Mugsy's
  JR C,44021              ; Hit man is to the left
  SET 2,C                 ; Bit 2: hit man at or right of Mugsy
  JP 44023                ; Carry on
  SET 3,C                 ; Bit 3: hit man left of Mugsy
  LD A,D                  ; A=the hit man's third
  SUB E                   ; Compare with Mugsy's
  JR Z,44039              ; Same third
  JR C,44034              ; Hit man is higher
  SET 0,C                 ; Bit 0: hit man is lower
  JP 44075                ; Choose a fragment
  SET 1,C                 ; Bit 1: hit man is higher
  JP 44075                ; Choose a fragment
  LD A,(IX+17)            ; Same third: A=Mugsy's row bits
  AND 224                 ; Row within the third
  LD L,A                  ; L=it
  LD A,(IY+17)            ; A=the hit man's row bits
  AND 224                 ; Row within the third
  CP L                    ; Compare
  JR C,44058              ; Hit man is higher
  SET 0,C                 ; Bit 0: hit man is lower
  JP 44060                ; Carry on
  SET 1,C                 ; Bit 1: hit man is higher
  SUB L                   ; Difference in rows
  JR NZ,44075             ; Different rows: choose a fragment
  LD A,(42325)            ; Same row: is Mugsy already dead?
  AND A                   ; Test it
  JR NZ,44075             ; Yes: just move
  RES 0,C                 ; Same row and Mugsy alive: clear bit 0
  RES 1,C                 ; And bit 1
  LD B,10                 ; B=10: fire
  CALL 44153              ; Is there furniture beside the hit man?
  JR NZ,44086             ; No: carry on
  LD A,12                 ; A=12
  XOR C                   ; Flip the horizontal bits: go the other way
  LD C,A                  ; C=the new direction bits
  LD B,0                  ; B=0: do not fire
  LD A,C                  ; A=the direction bits
  CP 4                    ; Right (4)?
  JR NZ,44097             ; No
  LD HL,47042             ; Fragment 47042
  JP 44137                ; Use it
  CP 8                    ; Left (8)?
  JR NZ,44107             ; No
  LD HL,47034             ; Fragment 47034
  JP 44137                ; Use it
  CP 5                    ; Right and lower (5)?
  JR NZ,44116             ; No
  LD HL,47058             ; Fragment 47058
  JR 44137                ; Use it
  CP 6                    ; Left and higher (6)?
  JR NZ,44125             ; No
  LD HL,47074             ; Fragment 47074
  JR 44137                ; Use it
  CP 9                    ; Left and lower (9)?
  JR NZ,44134             ; No
  LD HL,47050             ; Fragment 47050
  JR 44137                ; Use it
  LD HL,47066             ; Otherwise fragment 47066
  LD (42296),HL           ; Store the new script pointer
  INC HL                  ; Skip two bytes
  INC HL                  ; Poke B (fire or not) into the fragment
  LD (HL),B               ; Next byte
  INC HL                  ; Poke it again
  LD (HL),B               ; Next byte of the fragment
  LD HL,42253             ; HL=his timer
  LD (HL),2               ; Wait two ticks
  JP 43010                ; Back to the dispatcher

; Shootout: check for furniture next to a figure
  PUSH BC                 ; Save BC
  LD E,(IY+29)            ; E=the figure's attribute address, low byte
  LD D,(IY+30)            ; D=high byte
  LD A,(IY+0)             ; A=the figure's state byte
  AND 224                 ; Which way is he facing?
  JR NZ,44172             ; Left: use the left offset
  LD HL,96                ; Facing right: look 96 bytes ahead
  JR 44175                ; Carry on
  LD HL,95                ; Facing left: look 95 bytes ahead
  ADD HL,DE               ; HL=the attribute cell to inspect
  LD A,58                 ; A=58: the attribute of a piece of furniture
  LD BC,4                 ; BC=4: look at four cells
  CPI                     ; Compare A with a cell
  JR Z,44188              ; Found: stop
  JP PE,44181             ; Keep looking
  POP BC                  ; Restore BC
  RET                     ; Return (zero flag set if there is furniture)
  CP 2                    ; Is the hit man's fire state 2?
  JR NZ,44259             ; No: finish the firing sequence below
  LD IX,42492             ; IX=the hit man's record
  LD A,(IX+0)             ; A=his state byte
  AND 224                 ; Which way is he facing?
  JR NZ,44216             ; Left: use that branch
  LD A,(IX+17)            ; Facing right: A=screen address low byte
  AND 31                  ; Column
  CP 28                   ; At column 28, the right wall?
  JR Z,44247              ; Yes: no bullet
  JR 44228                ; Fire the bullet
  LD A,(IX+17)            ; Facing left: A=screen address low byte
  AND 31                  ; Column
  LD B,A                  ; B=column
  LD A,(42314)            ; A=the left limit
  CP B                    ; Same column?
  JR Z,44247              ; Yes: no bullet
  LD IY,42570             ; IY=the hit man's bullet record (42570)
  LD B,13                 ; B=13: the bullet starts 13 pixel rows down
  CALL 43709              ; Position the bullet next to the gun
  LD A,15                 ; A=15
  LD (42320),A            ; The bullet flies for 15 steps
  LD HL,42255             ; HL=the bullet's timer
  LD (HL),1               ; Make the bullet ready to move
  LD HL,42317             ; HL=the hit man's fire state
  INC (HL)                ; Raise it to 3
  LD A,4                  ; A=4
  LD (42280),A            ; Countdown 4
  JP 43010                ; Back to the dispatcher
  LD HL,42234             ; HL=the hit man's standing frame table (42234)
  LD (42309),HL           ; Use it
  LD HL,23875             ; HL=frame buffer (23875)
  LD (42307),HL           ; Use it
  LD A,8                  ; A=8
  LD (42280),A            ; Countdown 8
  XOR A                   ; A=0
  LD (42317),A            ; Reset the fire state
  LD HL,42492             ; HL=his record
  CALL 44726              ; Redraw him standing
  LD HL,42527             ; HL=42527
  LD (HL),1               ; Set the flag
  JP 43010                ; Back to the dispatcher

; Shootout: handler for Mugsy's bullet
  LD A,(42319)            ; Handler for slot 4 (Mugsy's bullet): was a bullet
                          ; just cancelled?
  AND A                   ; Test it
  JR Z,44312              ; No: carry on
  XOR A                   ; A=0
  LD (42319),A            ; Clear the flag
  LD HL,42254             ; HL=the bullet's timer
  LD (HL),3               ; Park it at 3
  JP 43010                ; Back to the dispatcher
  LD HL,42531             ; HL=the bullet's record (42531)
  PUSH HL                 ; Save it
  CALL 45693              ; Copy it to the workspace
  LD HL,42318             ; HL=the bullet's remaining flight
  DEC (HL)                ; One step less
  JP Z,44376              ; Used up: remove it
  LD A,9                  ; A=9
  CP (HL)                 ; Is this the first step?
  JR Z,44364              ; Yes: it has only just been drawn
  CALL 45155              ; Copy its coordinates
  EX DE,HL                ; HL=screen address
  CALL 45423              ; Move it a cell in its direction
  EX DE,HL                ; DE=new screen address
  CALL 44403              ; Get the next route byte
  AND A                   ; Test it
  JR Z,44353              ; Nothing in the way
  LD A,1                  ; A=1
  LD (42318),A            ; The bullet has hit something: stop it next time
  LD (42331),A            ; Tell the hit tests that Mugsy's bullet has landed
  LD (42353),DE           ; Store the new position
  CALL 45626              ; Convert to an attribute address
  LD (42365),DE           ; Store it
  POP DE                  ; DE=the record
  CALL 45702              ; Copy the workspace back
  LD A,1                  ; A=1
  LD (42283),A            ; Redraw the bullet at the next tick
  JP 43010                ; Back to the dispatcher
  CALL 45155              ; Copy the coordinates
  LD HL,1000              ; HL=1000: off the screen
  LD (42353),HL           ; Move the bullet off the screen
  LD (42365),HL           ; And its attributes
  POP DE                  ; DE=the record
  CALL 45702              ; Copy back
  LD A,1                  ; A=1
  LD (42283),A            ; Redraw
  LD (42319),A            ; Flag the bullet as cancelled
  JP 43010                ; Back to the dispatcher

; Shootout: get the next byte of a figure's route
  LD A,(42336)            ; A=the figure's state byte
  AND 224                 ; Which way is it moving?
  JR Z,44412              ; Left
  LD A,(DE)               ; Moving right: A=the byte at DE
  RET                     ; Return
  INC DE                  ; Moving left: next byte
  LD A,(DE)               ; A=the byte there
  DEC DE                  ; Back to DE
  RET                     ; Return

; Shootout: handler for the hit man's bullet
  LD A,(42321)            ; Handler for slot 5 (the hit man's bullet): was a
                          ; bullet just cancelled?
  AND A                   ; Test it
  JR Z,44434              ; No: carry on
  XOR A                   ; A=0
  LD (42321),A            ; Clear the flag
  LD HL,42255             ; HL=the bullet's timer
  LD (HL),3               ; Park it at 3
  JP 43010                ; Back to the dispatcher
  LD HL,42570             ; HL=the bullet's record (42570)
  PUSH HL                 ; Save it
  CALL 45693              ; Copy it to the workspace
  LD HL,42320             ; HL=the bullet's remaining flight
  DEC (HL)                ; One step less
  JP Z,44498              ; Used up: remove it
  LD A,14                 ; A=14
  CP (HL)                 ; Is this the first step?
  JR Z,44486              ; Yes
  CALL 45155              ; Copy its coordinates
  EX DE,HL                ; HL=screen address
  CALL 45423              ; Move it a cell
  EX DE,HL                ; DE=new address
  CALL 44403              ; Get the next route byte
  AND A                   ; Test it
  JR Z,44475              ; Nothing in the way
  LD A,1                  ; A=1
  LD (42320),A            ; The bullet has hit something
  LD (42332),A            ; Tell the hit tests that the hit man's bullet has
                          ; landed
  LD (42353),DE           ; Store the new position
  CALL 45626              ; Convert to an attribute address
  LD (42365),DE           ; Store it
  POP DE                  ; DE=the record
  CALL 45702              ; Copy back
  LD A,1                  ; A=1
  LD (42286),A            ; Redraw at the next tick
  JP 43010                ; Back to the dispatcher
  CALL 45155              ; Copy the coordinates
  LD HL,1000              ; HL=1000: off the screen
  LD (42353),HL           ; Move the bullet off the screen
  LD (42365),HL           ; And its attributes
  POP DE                  ; DE=the record
  CALL 45702              ; Copy back
  LD A,1                  ; A=1
  LD (42286),A            ; Redraw
  LD (42321),A            ; Flag the bullet as cancelled
  JP 43010                ; Back to the dispatcher

; Shootout: look for a bullet touching a figure
;
; Returns A=1 if any of the 4x3 attribute cells at the figure's attribute
; address has the bullet colour (57).
  LD L,(IX+29)            ; L=the target's attribute address, low byte
  LD H,(IX+30)            ; H=high byte
  LD DE,32                ; DE=32: one row of attributes
  LD C,3                  ; C=3: three rows to examine
  PUSH HL                 ; Save the row start
  LD B,4                  ; B=4: four cells per row
  LD A,57                 ; A=57: the attribute of a bullet
  CP (HL)                 ; Is this cell a bullet?
  JR Z,44554              ; Yes: it is in the target
  INC HL                  ; Next cell
  DJNZ 44541              ; Loop for four cells
  POP HL                  ; Restore the row start
  ADD HL,DE               ; Move down one row
  DEC C                   ; Count the rows
  JR NZ,44536             ; Loop for three rows
  XOR A                   ; A=0: no bullet near the target
  RET                     ; Return
  LD A,1                  ; A=1: a bullet is touching the target
  POP HL                  ; Tidy the stack
  RET                     ; Return

; Shootout: start a falling-over animation
  PUSH HL                 ; Save the record address
  PUSH AF                 ; Save the animation length
  PUSH BC                 ; Save the graphic address
  CALL 45693              ; Copy the record to the workspace
  POP BC                  ; Get the graphic address back
  LD (42355),BC           ; Store it as the figure's frame pointer
  CALL 45155              ; Copy the coordinates
  POP AF                  ; Get the animation length
  LD (42373),A            ; Store it
  RRA                     ; Divide by 8...
  RRA                     ; ...by shifting right...
  RRA                     ; ...three times
  LD (42367),A            ; Store the number of cells
  EX DE,HL                ; HL=the screen address
  LD B,20                 ; B=20: drop the figure 20 pixel rows
  INC H                   ; Down one row
  CALL 45651              ; Fix up the address across character boundaries
  DJNZ 44585              ; Repeat 20 times
  LD (42353),HL           ; Store the new screen address
  EX DE,HL                ; DE=the screen address
  CALL 45182              ; Compute the pixel shift
  CALL 45626              ; Convert to an attribute address
  LD (42365),DE           ; Store it
  POP DE                  ; DE=the record
  CALL 45702              ; Copy the workspace back
  JP 43010                ; Back to the dispatcher

; Shootout: work out the left and upper limits for a figure
  LD A,(IX+18)            ; A=the figure's screen address, high byte
  CP 72                   ; Is it in the top part of the screen?
  JR NC,44714             ; No: use the default limit
  LD A,(IX+17)            ; A=the screen address, low byte
  LD C,A                  ; C=it
  AND 31                  ; Column bits
  LD D,A                  ; D=column
  LD A,C                  ; A=the full byte
  AND 224                 ; Row bits
  LD C,A                  ; C=row bits
  CP 128                  ; Row 4 (128)?
  JR NZ,44646             ; No
  LD A,D                  ; A=column
  CP 4                    ; Column 4?
  JR NZ,44714             ; No: default
  LD A,4                  ; A=4: left limit
  LD HL,16512             ; HL=16512
  JR 44719                ; Store it
  LD A,C                  ; A=row bits
  CP 160                  ; Row 5 (160)?
  JR NZ,44663             ; No
  LD A,D                  ; A=column
  CP 3                    ; Column below 3?
  JR C,44714              ; Yes: default
  LD A,3                  ; A=3: left limit
  LD HL,16544             ; HL=16544
  JR 44719                ; Store it
  LD A,C                  ; A=row bits
  CP 192                  ; Row 6 (192)?
  JR NZ,44680             ; No
  LD A,D                  ; A=column
  CP 2                    ; Column below 2?
  JR C,44714              ; Yes: default
  LD A,2                  ; A=2: left limit
  LD HL,16576             ; HL=16576
  JR Z,44719              ; Store it
  LD A,C                  ; A=row bits
  CP 224                  ; Row 7 (224)?
  JR NZ,44697             ; No
  LD A,D                  ; A=column
  AND 3                   ; Low two bits of the column
  JR Z,44714              ; Zero: default
  LD A,1                  ; A=1: left limit
  LD HL,16608             ; HL=16608
  JR 44719                ; Store it
  LD A,C                  ; A=row bits
  CP 0                    ; Row 0?
  JR NZ,44714             ; No: default
  LD A,D                  ; A=column
  CP 0                    ; Column 0?
  JR NZ,44714             ; No: default
  LD A,0                  ; A=0: left limit
  LD HL,18432             ; HL=18432
  JR 44719                ; Store it
  LD A,0                  ; A=0: no left limit
  LD HL,16512             ; HL=16512: the top of the playing area
  LD (42298),HL           ; Store the upper limit
  LD (42314),A            ; Store the left limit
  RET                     ; Return

; Shootout: move and redraw the current figure
  PUSH HL                 ; Save the record address
  CALL 45693              ; Copy it to the workspace
  CALL 45155              ; Copy the coordinates
  LD HL,(42309)           ; HL=the frame table
  LD (42369),HL           ; Store it in the workspace
  CALL 45079              ; Update the figure's position and animation
  LD (42353),DE           ; Store the new screen address
  LD A,(42336)            ; A=the state byte
  AND 224                 ; Facing left?
  JR NZ,44758             ; Yes: erase and redraw leftwards
  CALL 45201              ; Draw facing right
  JR 44761                ; Done
  CALL 45276              ; Draw facing left
  POP DE                  ; DE=the record
  CALL 45702              ; Copy the workspace back
  RET                     ; Return

; Shootout: deal with Mugsy firing
  LD A,(42331)            ; A=has Mugsy's bullet landed?
  AND A                   ; Test it
  JR Z,44802              ; No: check the hit man's
  XOR A                   ; A=0
  LD (42331),A            ; Clear the flag
  LD IX,42492             ; IX=the hit man's record
  CALL 44525              ; Is the bullet touching him?
  AND A                   ; Test it
  JR Z,44797              ; No
  XOR A                   ; A=0
  LD HL,42302             ; HL=the hit man's hit points (42302)
  DEC (HL)                ; One hit
  JR NZ,44797             ; Still alive
  LD (HL),4               ; Reset the counter (he has taken 4 hits)
  LD A,1                  ; A=1: he is dead
  LD (42330),A            ; Record whether he is dead
  JR 44834                ; Carry on
  LD A,(42332)            ; A=has the hit man's bullet landed?
  AND A                   ; Test it
  JR Z,44883              ; No: finished
  XOR A                   ; A=0
  LD (42332),A            ; Clear the flag
  LD IX,42453             ; IX=Mugsy's record
  CALL 44525              ; Is the bullet touching him?
  AND A                   ; Test it
  JR Z,44831              ; No
  XOR A                   ; A=0
  LD HL,42301             ; HL=Mugsy's hit points (42301)
  DEC (HL)                ; One hit
  JR NZ,44831             ; Still alive
  LD A,1                  ; A=1: Mugsy is dead
  LD (42329),A            ; Record whether Mugsy is dead
  LD IX,42375             ; IX=bystander 1's record
  CALL 44525              ; Is a bullet touching him?
  LD (42327),A            ; Record it
  LD IX,42414             ; IX=bystander 2's record
  CALL 44525              ; Is a bullet touching him?
  LD (42328),A            ; Record it
  AND A                   ; Test it
  JR Z,44867              ; No
  LD HL,42251             ; HL=bystander 2's timer
  LD A,(HL)               ; A=his timer
  CP 2                    ; Is it 2?
  JR NZ,44867             ; No
  LD (HL),1               ; Make him ready
  LD A,(42327)            ; A=is bystander 1 hit?
  AND A                   ; Test it
  JR Z,44883              ; No
  LD HL,42250             ; HL=his timer
  LD A,(HL)               ; A=his timer
  CP 2                    ; Is it 2?
  JR NZ,44883             ; No
  LD (HL),1               ; Make him ready
  RET                     ; Return

; Shootout: deal with a hit
  LD A,(42323)            ; A=has bystander 1 gone down?
  AND A                   ; Test it
  JP NZ,44909             ; Yes: look at bystander 2
  LD A,(42333)            ; A=the "somebody is down" flag
  AND A                   ; Test it
  RET Z                   ; Return if not
  LD HL,(42292)           ; HL=his script pointer
  INC HL                  ; Skip a byte
  LD (42292),HL           ; Store it
  LD HL,42250             ; HL=his timer
  LD (HL),1               ; Make him ready
  RET                     ; Return
  LD A,(42324)            ; A=has bystander 2 gone down?
  AND A                   ; Test it
  JP NZ,44934             ; Yes: look at the main figures
  LD A,(42333)            ; A=the "somebody is down" flag
  AND A                   ; Test it
  RET Z                   ; Return if not
  LD HL,(42294)           ; HL=his script pointer
  INC HL                  ; Skip a byte
  LD (42294),HL           ; Store it
  LD HL,42251             ; HL=his timer
  LD (HL),1               ; Make him ready
  RET                     ; Return
  LD A,(42325)            ; A=has Mugsy been killed?
  AND A                   ; Test it
  JR Z,44944              ; No
  LD (42335),A            ; Set the "shootout over" flag
  RET                     ; Return
  LD A,(42326)            ; A=has the hit man been killed?
  AND A                   ; Test it
  RET Z                   ; No: return
  LD (42335),A            ; Set the "shootout over" flag
  RET                     ; Return

; Shootout: move a figure
  PUSH HL                 ; Save the record address
  PUSH AF                 ; Save the direction code
  CALL 45693              ; Copy the record to the workspace
  CALL 45155              ; Copy the coordinates
  LD HL,42336             ; HL=the workspace
  POP AF                  ; Get the direction code back
  LD B,A                  ; B=it
  AND A                   ; Zero?
  JR Z,44970              ; Then keep the old direction
  LD (HL),B               ; Store the new one
  INC HL                  ; Next workspace byte (the animation delay)
  DEC (HL)                ; One tick less
  JR NZ,44981             ; Not time to change frame
  LD A,(42313)            ; A=the frame delay
  LD (HL),A               ; Reload it
  CALL 45122              ; Move to the next frame of the animation
  INC HL                  ; Next workspace byte (the step counter)
  DEC (HL)                ; One tick less
  JR NZ,45007             ; Not time to step
  LD A,(42372)            ; A=the step delay
  LD (HL),A               ; Reload it
  CALL 45044              ; Is there a gun flash to remove?
  JR NZ,45002             ; Yes
  LD A,1                  ; A=1
  LD (42338),A            ; Mark the figure as standing
  JP 45007                ; Carry on
  EX DE,HL                ; DE=screen address
  CALL 45423              ; Step the figure
  EX DE,HL                ; Back
  CALL 45079              ; Update the position
  LD (42353),DE           ; Store the screen address
  CALL 45182              ; Compute the pixel shift
  CALL 45626              ; Convert to an attribute address
  LD (42365),DE           ; Store it
  LD A,(42336)            ; A=the state byte
  AND 224                 ; Facing left?
  JR NZ,45036             ; Yes
  CALL 45201              ; Draw it facing right
  JR 45039                ; Done
  CALL 45276              ; Draw it facing left
  POP DE                  ; DE=the record
  CALL 45702              ; Copy back
  RET                     ; Return

; Shootout: remove the gun flash
  PUSH DE                 ; Save DE
  CALL 45626              ; Convert to an attribute address
  LD A,(42336)            ; A=the state byte
  AND 224                 ; Facing left?
  JR NZ,45061             ; Yes
  LD HL,96                ; HL=96
  JP 45064                ; Carry on
  LD HL,95                ; HL=95
  ADD HL,DE               ; HL=the cell ahead
  LD A,58                 ; A=58: furniture
  LD BC,4                 ; BC=4
  CPI                     ; Look for it
  JR Z,45077              ; Found
  JP PE,45070             ; Keep looking
  POP DE                  ; Restore DE
  RET                     ; Return

; Shootout: update a figure's position
  PUSH DE                 ; Save DE
  LD HL,(42369)           ; HL=the frame table position
  LD A,(42336)            ; A=the state byte
  LD B,A                  ; B=it
  AND 224                 ; Facing left?
  JR NZ,45099             ; Yes
  LD A,(HL)               ; A=the old state byte
  AND 224                 ; Facing left?
  LD (HL),B               ; Store the new state
  JR NZ,45105             ; It was facing left
  JR 45111                ; Carry on
  LD A,(HL)               ; A=the old state
  AND 224                 ; Facing left?
  LD (HL),B               ; Store the new state
  JR NZ,45111             ; Same direction
  INC HL                  ; Next byte
  LD A,(HL)               ; A=the frame count
  DEC HL                  ; Back to the first byte
  CALL 45353              ; Move to the next frame
  INC HL                  ; Skip a byte
  INC HL                  ; And another
  LD E,(HL)               ; E=graphic address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  LD (42355),DE           ; Store the graphic address
  POP DE                  ; Restore DE
  RET                     ; Return

; Shootout: move to the next figure slot
  PUSH HL                 ; Save HL
  LD A,(42371)            ; A=frame counter
  LD HL,(42369)           ; HL=the frame table pointer
  DEC A                   ; One frame less
  JR Z,45141              ; None left: wrap round
  INC HL                  ; Next frame (4 bytes)
  INC HL                  ; ...
  INC HL                  ; ...
  INC HL                  ; ...
  LD (42369),HL           ; Store the pointer
  JR 45150                ; Carry on
  LD HL,(42309)           ; HL=the start of the table
  LD (42369),HL           ; Store the pointer
  LD A,(42312)            ; A=the number of frames
  LD (42371),A            ; Store the counter
  POP HL                  ; Restore HL
  RET                     ; Return

; Shootout: copy the current figure's coordinates
  LD HL,(42365)           ; HL=the figure's attribute address
  LD (42349),HL           ; Store it
  LD DE,(42353)           ; DE=the figure's screen address
  LD (42339),DE           ; Store it
  LD A,(42358)            ; A=the pixel shift
  LD (42344),A            ; Store it
  LD A,(42357)            ; A=the pixel width
  LD (42343),A            ; Store it
  RET                     ; Return

; Shootout: compute a figure's pixel shift
  LD A,D                  ; A=the high byte of the screen address
  AND 7                   ; Pixel row within a character (0-7)
  LD B,A                  ; B=it
  LD A,8                  ; A=8
  SUB B                   ; A=8 minus the row
  LD (42358),A            ; Store the pixel shift
  LD B,A                  ; B=it
  LD A,(42373)            ; A=the figure's height in pixels
  SUB B                   ; A=height minus the shift
  LD (42357),A            ; Store it
  RET                     ; Return

; Shootout: draw a figure (masked)
  LD B,0                  ; B=0
  LD A,255                ; A=255
  EX AF,AF'               ; Keep it in A'
  LD A,32                 ; A=32: 32 rows to copy
  LD HL,(42355)           ; HL=the figure's graphic
  LD DE,(42307)           ; DE=the frame buffer
  EX AF,AF'               ; Get the row counter
  LD C,2                  ; C=2: two bytes per row
  LDI                     ; Copy a row of two bytes
  JP PE,45218             ; Loop for each byte
  LD (DE),A               ; Add a blank byte
  INC DE                  ; Next byte in the buffer
  EX AF,AF'               ; Save the counter
  DEC A                   ; One row less
  JR NZ,45215             ; Loop for 32 rows
  LD HL,(42307)           ; HL=the frame buffer
  LD (42355),HL           ; The buffer is the graphic now
  LD A,(42373)            ; A=the number of cells
  LD E,A                  ; E=it
  LD A,(42374)            ; A=the width in bytes
  LD C,A                  ; C=it
  LD A,(42338)            ; A=the pixel shift
  LD B,A                  ; B=it
  LD A,4                  ; A=4
  SUB B                   ; 4 minus the shift
  ADD A,A                 ; Double it
  JR Z,45275              ; Nothing to shift
  SCF                     ; Set the carry flag
  LD D,A                  ; D=the shift count
  LD B,C                  ; B=the width
  PUSH HL                 ; Save the row start
  RR (HL)                 ; Shift a byte right
  INC HL                  ; Next byte
  DJNZ 45257              ; Repeat for the whole row
  LD (42305),HL           ; Remember the position reached
  POP HL                  ; Restore the row start
  DEC D                   ; One shift less
  JR NZ,45255             ; Repeat
  LD HL,(42305)           ; HL=the position reached
  DEC E                   ; One row less
  JR NZ,45254             ; Repeat
  RET                     ; Return

; Shootout: erase a figure
  LD B,0                  ; B=0
  LD A,255                ; A=255
  EX AF,AF'               ; Keep it in A'
  LD A,32                 ; A=32: 32 rows to copy
  LD HL,(42355)           ; HL=the figure's graphic
  LD DE,(42307)           ; DE=the frame buffer
  EX AF,AF'               ; Get the row counter
  LD (DE),A               ; Start with a blank byte
  INC DE                  ; Next byte
  LD C,2                  ; C=2: two bytes per row
  LDI                     ; Copy a row of two bytes
  JP PE,45295             ; Loop for each byte
  EX AF,AF'               ; Save the counter
  DEC A                   ; One row less
  JR NZ,45290             ; Loop for 32 rows
  LD HL,(42307)           ; HL=the frame buffer
  LD (42355),HL           ; The buffer is the graphic now
  DEC DE                  ; Back one byte
  EX DE,HL                ; HL=the end of the buffer
  LD A,(42373)            ; A=the number of cells
  LD E,A                  ; E=it
  LD A,(42374)            ; A=the width in bytes
  LD C,A                  ; C=it
  LD A,(42338)            ; A=the pixel shift
  LD B,A                  ; B=it
  LD A,4                  ; A=4
  SUB B                   ; 4 minus the shift
  ADD A,A                 ; Double it
  JR Z,45352              ; Nothing to shift
  SCF                     ; Set the carry flag
  LD D,A                  ; D=the shift count
  LD B,C                  ; B=the width
  PUSH HL                 ; Save the row end
  RL (HL)                 ; Shift a byte left
  DEC HL                  ; Previous byte
  DJNZ 45334              ; Repeat for the whole row
  LD (42305),HL           ; Remember the position reached
  POP HL                  ; Restore the row end
  DEC D                   ; One shift less
  JR NZ,45332             ; Repeat
  LD HL,(42305)           ; HL=the position reached
  DEC E                   ; One row less
  JR NZ,45331             ; Repeat
  RET                     ; Return

; Shootout: get the next animation frame
  PUSH HL                 ; Save the record address
  INC HL                  ; Skip the state and counters...
  INC HL                  ; ...to the frame table pointer
  LD E,(HL)               ; E=the frame table address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  EX DE,HL                ; HL=the frame table address
  LD C,A                  ; C=the number of frames
  LD D,(HL)               ; D=a byte of the frame table
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  LD B,A                  ; B=the reversed byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=the next byte
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  RR D                    ; Shift the next bit out of D
  RLA                     ; and into A (this reverses the bits)
  LD (HL),B               ; Store the second byte
  DEC HL                  ; Back one byte
  LD (HL),A               ; Store the first
  INC HL                  ; Forward
  INC HL                  ; And on to the next pair
  DEC C                   ; One frame less
  JR NZ,45361             ; Loop for every frame
  POP HL                  ; Restore the record address
  RET                     ; Return

; Shootout: step a figure in its current direction
  LD A,L                  ; A=the figure's screen address, low byte
  AND 31                  ; Column bits
  LD E,A                  ; E=the column
  LD A,L                  ; A=the low byte again
  AND 224                 ; Row bits
  LD D,A                  ; D=the row
  LD A,(42336)            ; A=the direction code
  CP 4                    ; Right?
  JR NZ,45454             ; No

; Shootout: move right one cell (unless at column 28)
  LD A,28                 ; A=28: the right-hand column limit
  CP E                    ; Is the figure there?
  JR NZ,45452             ; No
  LD A,1                  ; A=1
  LD (42338),A            ; Stop the figure
  LD (42322),A            ; Report that it could not move
  RET                     ; Return
  INC L                   ; Move one column right
  RET                     ; Return
  CP 64                   ; Left?
  JR NZ,45475             ; No

; Shootout: move left one cell (unless at the left limit)
  LD A,(42314)            ; A=the left limit
  CP E                    ; Is the figure there?
  JR NZ,45473             ; No
  LD A,1                  ; A=1
  LD (42338),A            ; Stop the figure
  LD (42322),A            ; Report that it could not move
  RET                     ; Return
  DEC L                   ; Move one column left
  RET                     ; Return
  CP 1                    ; Up?
  JR NZ,45511             ; No

; Shootout: move up one pixel row (unless at the top limit)
  PUSH HL                 ; Save the address
  PUSH DE                 ; Save the row
  LD L,D                  ; L=the row
  LD DE,(42298)           ; DE=the upper limit
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Compare with the limit
  POP DE                  ; Restore the row
  POP HL                  ; Restore the address
  JR NZ,45494             ; Not at the limit
  RET                     ; At the top: no move
  DEC H                   ; Up a pixel row
  CALL 45636              ; Fix up across character boundaries
  DEC H                   ; Up another
  CALL 45636              ; Fix up
  DEC H                   ; Up another
  CALL 45636              ; Fix up
  DEC H                   ; Up another
  CALL 45636              ; Fix up
  RET                     ; Return
  CP 16                   ; Down?
  JR NZ,45547             ; No

; Shootout: move down one pixel row (unless at the bottom limit)
  PUSH HL                 ; Save the address
  PUSH DE                 ; Save the row
  LD L,D                  ; L=the row
  EX DE,HL                ; DE=the row
  LD HL,20576             ; HL=the lower limit (20576)
  AND A                   ; Clear the carry flag
  SBC HL,DE               ; Compare
  POP DE                  ; Restore the row
  POP HL                  ; Restore the address
  JR NZ,45530             ; Not at the limit
  RET                     ; At the bottom: no move
  INC H                   ; Down a pixel row
  CALL 45651              ; Fix up across character boundaries
  INC H                   ; Down another
  CALL 45651              ; Fix up
  INC H                   ; Down another
  CALL 45651              ; Fix up
  INC H                   ; Down another
  CALL 45651              ; Fix up
  RET                     ; Return
  CP 128                  ; Up and left?
  JR NZ,45567             ; No
  XOR A                   ; A=0
  LD (42322),A            ; Clear the "could not move" flag
  CALL 45458              ; Move left
  LD A,(42322)            ; A=the flag
  AND A                   ; Test it
  RET NZ                  ; Could not move: return
  CALL 45479              ; Move up
  RET                     ; Return
  CP 2                    ; Up and right?
  JR NZ,45587             ; No
  XOR A                   ; A=0
  LD (42322),A            ; Clear the flag
  CALL 45438              ; Move right
  LD A,(42322)            ; A=the flag
  AND A                   ; Test it
  RET NZ                  ; Could not move: return
  CALL 45479              ; Move up
  RET                     ; Return
  CP 32                   ; Down and left?
  JR NZ,45607             ; No
  XOR A                   ; A=0
  LD (42322),A            ; Clear the flag
  CALL 45458              ; Move left
  LD A,(42322)            ; A=the flag
  AND A                   ; Test it
  RET NZ                  ; Could not move: return
  CALL 45515              ; Move down
  RET                     ; Return
  CP 8                    ; Down and right?
  RET NZ                  ; No: return
  XOR A                   ; A=0
  LD (42322),A            ; Clear the flag
  CALL 45438              ; Move right
  LD A,(42322)            ; A=the flag
  AND A                   ; Test it
  RET NZ                  ; Could not move: return
  CALL 45515              ; Move down
  RET                     ; Return

; Convert a display file address in DE into an attribute address
  LD A,D                  ; A=the high byte of the display address
  AND 24                  ; Which third of the screen (0-2)?
  RRA                     ; Divide by 8...
  RRA                     ; ...to...
  RRA                     ; ...get it into bits 0-1
  OR 88                   ; Add the base of the attribute file (88*256=22528)
  LD D,A                  ; D=the high byte of the attribute address
  RET                     ; Return

; Move HL up one pixel row
  LD A,H                  ; A=the high byte
  CPL                     ; Invert it
  AND 7                   ; Pixel row within a character (inverted)
  RET NZ                  ; Return if not at the top of a character
  LD A,L                  ; A=the low byte
  SUB 32                  ; Up one character row
  LD L,A                  ; L=it
  RET C                   ; Return if that did not cross a third
  LD A,H                  ; A=the high byte
  ADD A,8                 ; Up one third
  LD H,A                  ; H=it
  RET                     ; Return

; Move HL down one pixel row
  LD A,H                  ; A=the high byte
  AND 7                   ; Pixel row within a character
  RET NZ                  ; Return if still inside a character
  LD A,32                 ; A=32
  ADD A,L                 ; Down one character row
  LD L,A                  ; L=it
  RET C                   ; Return if that did not cross a third
  LD A,H                  ; A=the high byte
  SUB 8                   ; Down one third
  LD H,A                  ; H=it
  RET                     ; Return

; Shootout: clear the screen
  LD HL,16384             ; HL=the start of the display file
  LD DE,16385             ; DE=the next byte
  LD BC,6143              ; BC=6143
  XOR A                   ; A=0
  LD (HL),A               ; Clear the first byte
  LDIR                    ; Clear the rest of the pixels
  LD HL,22528             ; HL=the start of the attributes
  LD DE,22529             ; DE=the next byte
  LD BC,767               ; BC=767
  LD A,56                 ; A=56: white paper, black ink
  LD (HL),A               ; Set the first attribute
  LDIR                    ; Set the rest of the attributes
  RET                     ; Return

; Shootout: copy a figure's 39-byte record into the workspace at 42336
  LD DE,42336             ; DE=the workspace (42336)
  LD BC,39                ; BC=39 bytes
  LDIR                    ; Copy the record into the workspace
  RET                     ; Return

; Shootout: copy the workspace at 42336 back into a figure's record
  LD HL,42336             ; HL=the workspace (42336)
  LD BC,39                ; BC=39 bytes
  LDIR                    ; Copy it back into the record
  RET                     ; Return

; Shootout: furniture descriptors
;
; Two 10-byte descriptors loaded by 42940.
  DEFB 52,72,146,188,8,8,52,89
  DEFB 2,34,18,72,178,188,16,8
  DEFB 18,89,3,32

; Shootout: initial figure records
;
; Six 39-byte records copied to 42375 by 42639.
  DEFB 4,4,4,224,64,255,95,0
  DEFB 0,39,180,51,94,0,0,0
  DEFB 4,224,64,0,0,24,8,255
  DEFB 95,116,180,51,94,224,88,4
  DEFB 56,190,164,4,4,32,3,4
  DEFB 4,4,224,64,155,95,0,0
  DEFB 39,180,38,94,0,0,0,4
  DEFB 224,64,0,0,24,8,155,95
  DEFB 116,180,38,94,224,88,4,56
  DEFB 210,164,2,4,32,3,4,4
  DEFB 4,0,72,55,95,0,0,39
  DEFB 180,25,94,0,0,0,4,0
  DEFB 72,0,0,24,8,55,95,116
  DEFB 180,25,94,0,89,4,56,222
  DEFB 164,2,4,32,3,4,1,4
  DEFB 0,0,211,94,1,1,39,180
  DEFB 12,94,0,0,0,4,155,72
  DEFB 0,0,24,8,211,94,116,180
  DEFB 12,94,155,89,4,56,218,164
  DEFB 2,4,32,3,4,1,4,0
  DEFB 72,111,94,0,1,141,179,254
  DEFB 93,0,0,0,1,0,72,18
  DEFB 189,0,1,111,94,207,179,254
  DEFB 93,0,89,1,57,0,0,1
  DEFB 4,1,3,4,1,4,0,72
  DEFB 106,94,0,1,141,179,251,93
  DEFB 0,0,0,1,0,72,18,189
  DEFB 0,1,106,94,207,179,251,93
  DEFB 0,89,1,57,0,0,1,4
  DEFB 1,3

; Shootout: XOR a sprite onto the screen
  LD A,(DE)               ; Fetch a byte of the graphic (the graphic is read
                          ; backwards, from DE)
  XOR (HL)                ; Combine it with the screen byte
  LD (HL),A               ; Draw it
  DEC DE                  ; Back one byte in the graphic
  INC L                   ; Next screen byte to the right
  LD A,(DE)               ; Fetch the next graphic byte
  XOR (HL)                ; Combine it with the screen
  LD (HL),A               ; Draw it
  DEC DE                  ; Back one byte in the graphic
  DEC L                   ; Back to the left-hand column
  INC H                   ; Down a pixel row (within the character)
  DJNZ 45965              ; Loop for B pixel rows
  LD A,C                  ; A=C: pixel rows left to do
  AND A                   ; Test it
  JR Z,46007              ; None left: finish the job
  SUB 8                   ; Subtract eight rows (one character row)
  LD B,8                  ; B=8: a full character
  LD C,A                  ; C=the rows left
  JR NC,45994             ; At least eight were left
  ADD A,8                 ; Add the eight back
  LD B,A                  ; B=what is left
  LD C,0                  ; C=0: that is the last block
  LD A,32                 ; A=32
  ADD A,L                 ; Move down one character row
  LD L,A                  ; L=the new low byte
  JR C,45965              ; Still in the same third: draw the next block
  LD A,H                  ; Crossed into the next third: A=the high byte
  SUB 8                   ; Down 8 in the high byte
  LD H,A                  ; H=it
  JP 45965                ; Draw the next block
  POP DE                  ; Restore the attribute address
  POP HL                  ; Restore the screen address
  POP AF                  ; Restore the attribute count
  LD BC,32                ; BC=32: one row of attributes
  EX AF,AF'               ; Save the row counter
  LD A,(DE)               ; A=an attribute byte (the attributes are read
                          ; backwards too)
  LD (HL),A               ; Set it
  DEC DE                  ; Back one byte
  INC L                   ; Next cell
  LD A,(DE)               ; A=the next attribute
  LD (HL),A               ; Set it
  DEC DE                  ; Back one byte
  EX AF,AF'               ; Get the row counter
  DEC A                   ; One row less
  JP Z,48601              ; All done: go on to the second half of the job
  DEC L                   ; Back to the first column
  ADD HL,BC               ; Down one attribute row
  JP 46013                ; Next row
  EXX                     ; Use the alternate registers for the mask pointers
  LD A,(DE)               ; A=a mask byte
  OR (HL)                 ; Combine with the screen byte
  CPL                     ; Invert it (this gives the screen bits to keep)
  LD B,A                  ; B=the bits that will be changed
  OR (HL)                 ; Combine with the screen byte again
  LD (HL),A               ; Put the byte back with the mask bits set to 1
  INC DE                  ; Next mask byte
  INC L                   ; Next screen byte
  LD A,(DE)               ; A=the next mask byte
  OR (HL)                 ; Combine with the screen byte
  CPL                     ; Invert it
  LD C,A                  ; C=the bits that will be changed
  OR (HL)                 ; Combine with the screen byte
  LD (HL),A               ; Set the mask bits
  INC DE                  ; Next mask byte
  PUSH BC                 ; Save the old screen bits on the stack
  DEC L                   ; Back to the first column
  INC H                   ; Down a pixel row
  EXX                     ; Back to the main registers
  DJNZ 46031              ; Loop for B pixel rows
  LD A,C                  ; A=C: pixel rows left
  AND A                   ; Test it
  JR Z,46083              ; None left: restore the attributes
  SUB 8                   ; Subtract eight rows
  LD B,8                  ; B=8
  LD C,A                  ; C=the rows left
  JR NC,46069             ; At least eight were left
  ADD A,8                 ; Add the eight back
  LD B,A                  ; B=what is left
  LD C,0                  ; C=0
  EXX                     ; Alternate registers again
  LD A,32                 ; A=32
  ADD A,L                 ; Down one character row
  LD L,A                  ; L=the new low byte
  JR C,46032              ; Same third: continue
  LD A,H                  ; A=the high byte
  SUB 8                   ; Down one third
  LD H,A                  ; H=it
  JP 46032                ; Continue
  LD SP,(42303)           ; Restore the stack pointer used by the background
                          ; buffer
  POP HL                  ; HL=where the saved screen bytes begin
  POP DE                  ; DE=the attribute address
  POP BC                  ; BC=the attribute colour and count
  LD SP,HL                ; SP=the saved-background pointer
  INC SP                  ; Step past the last byte saved
  EX DE,HL                ; HL=the attribute address
  LD A,(HL)               ; A=an attribute byte
  LD D,A                  ; D=it
  AND 248                 ; Keep the paper, bright and flash bits and clear the
                          ; ink
  OR B                    ; Set the ink colour from B
  LD (HL),A               ; Store it
  INC L                   ; Next cell
  LD A,(HL)               ; A=the next attribute
  LD E,A                  ; E=it
  AND 248                 ; Keep the paper, bright and flash bits and clear the
                          ; ink
  OR B                    ; Set the ink colour from B
  LD (HL),A               ; Store it
  PUSH DE                 ; Save the old attributes on the stack
  DEC C                   ; One row less
  JP Z,48617              ; All done: finish the job
  DEC L                   ; Back a column
  LD DE,32                ; DE=32
  ADD HL,DE               ; Down one row
  JP 46093                ; Next row
  LD A,(DE)               ; Fetch a byte of the graphic
  XOR (HL)                ; Combine with the screen
  LD (HL),A               ; Draw it
  DEC DE                  ; Back a byte
  INC L                   ; Next column
  LD A,(DE)               ; Fetch the next byte
  XOR (HL)                ; Combine with the screen
  LD (HL),A               ; Draw it
  DEC DE                  ; Back a byte
  INC L                   ; Next column
  LD A,(DE)               ; Fetch the third byte
  XOR (HL)                ; Combine with the screen
  LD (HL),A               ; Draw it
  DEC DE                  ; Back a byte
  DEC L                   ; Back to the first column
  DEC L                   ; (two columns)
  INC H                   ; Down a pixel row
  DJNZ 46119              ; Loop for B pixel rows
  LD A,C                  ; A=C: pixel rows left
  AND A                   ; Test it
  JR Z,46167              ; None left: restore the attributes
  SUB 8                   ; Subtract eight rows
  LD B,8                  ; B=8
  LD C,A                  ; C=the rows left
  JR NC,46154             ; At least eight were left
  ADD A,8                 ; Add the eight back
  LD B,A                  ; B=what is left
  LD C,0                  ; C=0
  LD A,32                 ; A=32
  ADD A,L                 ; Down one character row
  LD L,A                  ; L=the new low byte
  JR C,46119              ; Same third: continue
  LD A,H                  ; A=the high byte
  SUB 8                   ; Down one third
  LD H,A                  ; H=it
  JP 46119                ; Continue
  POP DE                  ; Restore the attribute address
  POP HL                  ; Restore the screen address
  POP AF                  ; Restore the attribute count
  LD BC,32                ; BC=32
  EX AF,AF'               ; Save the row counter
  LD A,(DE)               ; A=an attribute byte
  LD (HL),A               ; Set it
  DEC DE                  ; Back one byte
  INC L                   ; Next cell
  LD A,(DE)               ; A=the next attribute
  LD (HL),A               ; Set it
  DEC DE                  ; Back one byte
  INC L                   ; Next cell
  LD A,(DE)               ; A=the third attribute
  LD (HL),A               ; Set it
  DEC DE                  ; Back one byte
  EX AF,AF'               ; Get the row counter
  DEC A                   ; One row less
  JP Z,48601              ; All done: go on to the second half of the job
  DEC L                   ; Back a cell
  DEC L                   ; Back another
  ADD HL,BC               ; Down one attribute row
  JP 46173                ; Next row
  EXX                     ; Alternate registers
  LD A,(DE)               ; A=a mask byte
  OR (HL)                 ; Combine with the screen
  CPL                     ; Invert it
  LD B,A                  ; B=the bits that will change
  OR (HL)                 ; Combine with the screen
  LD (HL),A               ; Draw it
  INC DE                  ; Next mask byte
  INC L                   ; Next column
  LD A,(DE)               ; A=the next mask byte
  OR (HL)                 ; Combine with the screen
  CPL                     ; Invert it
  LD C,A                  ; C=the bits that will change
  OR (HL)                 ; Combine with the screen
  LD (HL),A               ; Draw it
  INC DE                  ; Next mask byte
  INC L                   ; Next column
  PUSH BC                 ; Save the old bits on the stack
  LD A,(DE)               ; A=the third mask byte
  OR (HL)                 ; Combine with the screen
  CPL                     ; Invert it
  LD B,A                  ; B=the bits that will change
  OR (HL)                 ; Combine with the screen
  LD (HL),A               ; Draw it
  INC DE                  ; Next mask byte
  PUSH BC                 ; Save the old bits on the stack
  INC SP                  ; Move the stack pointer back a byte
  DEC L                   ; Back a column
  DEC L                   ; And another
  INC H                   ; Down a pixel row
  EXX                     ; Main registers again
  DJNZ 46196              ; Loop for B pixel rows
  LD A,C                  ; A=C: pixel rows left
  AND A                   ; Test it
  JR Z,46259              ; None left: restore the attributes
  SUB 8                   ; Subtract eight rows
  LD B,8                  ; B=8
  LD C,A                  ; C=the rows left
  JR NC,46245             ; At least eight were left
  ADD A,8                 ; Add the eight back
  LD B,A                  ; B=what is left
  LD C,0                  ; C=0
  EXX                     ; Alternate registers
  LD A,32                 ; A=32
  ADD A,L                 ; Down one character row
  LD L,A                  ; L=the new low byte
  JR C,46197              ; Same third: continue
  LD A,H                  ; A=the high byte
  SUB 8                   ; Down one third
  LD H,A                  ; H=it
  JP 46197                ; Continue
  LD SP,(42303)           ; Restore the stack pointer used by the background
                          ; buffer
  POP HL                  ; HL=where the saved screen bytes begin
  POP DE                  ; DE=the attribute address
  POP BC                  ; BC=the attribute colour and count
  LD SP,HL                ; SP=the saved-background pointer
  INC SP                  ; Step past the last byte saved
  EX DE,HL                ; HL=the attribute address
  LD A,(HL)               ; A=an attribute byte
  LD D,A                  ; D=it
  AND 248                 ; Keep the paper, bright and flash bits and clear the
                          ; ink
  OR B                    ; Set the ink colour from B
  LD (HL),A               ; Store it
  INC L                   ; Next cell
  LD A,(HL)               ; A=the next attribute
  LD E,A                  ; E=it
  AND 248                 ; Keep the paper, bright and flash bits and clear the
                          ; ink
  OR B                    ; Set the ink colour from B
  LD (HL),A               ; Store it
  INC L                   ; Next cell
  PUSH DE                 ; Save the old attributes on the stack
  LD A,(HL)               ; A=the third attribute
  LD D,A                  ; D=it
  AND 248                 ; Keep the paper, bright and flash bits and clear the
                          ; ink
  OR B                    ; Set the ink colour from B
  LD (HL),A               ; Store it
  PUSH DE                 ; Save the old attributes on the stack
  INC SP                  ; Move the stack pointer back a byte
  DEC C                   ; One row less
  JP Z,48617              ; All done: finish the job
  DEC L                   ; Back a column
  DEC L                   ; And another
  LD DE,32                ; DE=32
  ADD HL,DE               ; Down one row
  JP 46269                ; Next row

; Shootout: draw the walls of the restaurant
  CALL 45665              ; Clear the screen to white paper
  LD A,95                 ; A=95: the starting y coordinate
  LD C,0                  ; C=0: the starting x coordinate
  LD D,255                ; D=255: y changes by -1 each step
  LD E,1                  ; E=1: x changes by +1 each step
  LD B,41                 ; B=41 points
  CALL 46428              ; Plot a diagonal line (the left wall in perspective)
  LD B,27                 ; B=27 bytes
  CALL 46454              ; Draw a horizontal line (the back wall's base) along
                          ; the row HL points at
  LD A,54                 ; A=54: the starting y
  LD C,40                 ; C=40: the starting x
  LD D,255                ; D=255: y changes by -1
  LD E,0                  ; E=0: x does not change
  LD B,54                 ; B=54 points
  CALL 46428              ; Plot a vertical line (a wall edge)
  LD A,90                 ; A=90: the starting y
  LD C,5                  ; C=5: the starting x
  LD D,255                ; D=255: y -1
  LD E,0                  ; E=0: x constant
  LD B,42                 ; B=42 points
  CALL 46428              ; Plot a vertical line
  LD A,80                 ; A=80: the starting y
  LD C,15                 ; C=15: the starting x
  LD D,255                ; D=255: y -1
  LD E,0                  ; E=0: x constant
  LD B,42                 ; B=42 points
  CALL 46428              ; Plot a vertical line
  LD A,39                 ; A=39: the starting y
  LD C,15                 ; C=15: the starting x
  LD D,1                  ; D=1: y +1
  LD E,255                ; E=255: x -1
  LD B,10                 ; B=10 points
  CALL 46428              ; Plot a short diagonal
  LD A,24                 ; A=24: 24 pixel rows for the door
  LD DE,16435             ; DE=16435: the door's position on the screen
  PUSH DE                 ; Save it
  LD HL,48404             ; HL=the door graphic (48404)
  LD BC,5                 ; BC=5 bytes per row
  PUSH DE                 ; Save the row's address
  LDIR                    ; Copy a row of the door onto the screen
  POP DE                  ; Get the row's address back
  INC D                   ; Next pixel row
  EX DE,HL                ; HL=the address
  PUSH AF                 ; Save the row counter
  CALL 45651              ; Fix up the address across character boundaries
  POP AF                  ; Restore the row counter
  EX DE,HL                ; DE=the address
  DEC A                   ; One row less
  JR NZ,46387             ; Loop for 24 rows
  POP DE                  ; DE=the door's screen address
  CALL 45626              ; Convert it to an attribute address
  LD A,3                  ; A=3: three attribute rows
  LD BC,5                 ; BC=5 cells per row
  PUSH DE                 ; Save the row's address
  LDIR                    ; Set the door's attributes
  POP DE                  ; Restore the address
  LD BC,32                ; BC=32
  EX DE,HL                ; HL=the address
  ADD HL,BC               ; Down one attribute row
  EX DE,HL                ; DE=the address
  DEC A                   ; One row less
  JR NZ,46411             ; Loop for 3 rows
  RET                     ; Return

; Shootout: plot a pixel
  PUSH AF                 ; Save the counter
  PUSH BC                 ; Save the coordinates
  CALL 8880               ; Get the display address for the point from the ROM
                          ; (the PIXEL-ADD routine, skipping its range check)
  LD B,A                  ; B=the bit position
  INC B                   ; One more than the bit position
  LD A,254                ; A=%11111110
  RRCA                    ; Rotate it to line up with the pixel...
  DJNZ 46437              ; ...for B steps
  CPL                     ; Make it the single pixel mask
  OR (HL)                 ; Combine with the screen byte
  LD (HL),A               ; Plot the pixel
  POP BC                  ; Restore the coordinates
  POP AF                  ; Restore the counter
  ADD A,D                 ; Add the y step
  PUSH AF                 ; Save it
  LD A,C                  ; A=x
  ADD A,E                 ; Add the x step
  LD C,A                  ; C=the new x
  POP AF                  ; Restore y
  DJNZ 46428              ; Plot B points
  RET                     ; Return

; Shootout: draw a horizontal line
  LD (HL),255             ; Set a screen byte to 255
  INC L                   ; Next byte
  DJNZ 46454              ; Loop for B bytes
  RET                     ; Return

; Shootout: read the controls
;
; Reads Q (up), Z (down), I (left), P (right) and B/N/M (fire) and converts
; them to a direction code. Opposite directions pressed together cancel out.
;
; Output:A Direction code
CONTROLS:
  LD HL,42453             ; HL=Mugsy's record (the figure the keys move)
  LD C,0                  ; C=0: the direction bits
  LD A,223                ; Read the half-row Y U I O P
  IN A,(254)              ; Read the keyboard
  LD B,A                  ; B=the key states
  AND 1                   ; Is P pressed?
  JR NZ,46476             ; No
  SET 2,C                 ; Set bit 2: right
  LD A,B                  ; A=the key states
  AND 4                   ; Is I pressed?
  JR NZ,46483             ; No
  SET 6,C                 ; Set bit 6: left
  LD A,254                ; Read the half-row CAPS Z X C V
  IN A,(254)              ; Read the keyboard
  AND 2                   ; Is Z pressed?
  JR NZ,46493             ; No
  SET 4,C                 ; Set bit 4: down
  LD A,251                ; Read the half-row Q W E R T
  IN A,(254)              ; Read the keyboard
  AND 1                   ; Is Q pressed?
  JR NZ,46503             ; No
  SET 0,C                 ; Set bit 0: up
  LD A,127                ; Read the half-row SPACE SYM M N B
  IN A,(254)              ; Read the keyboard
  LD B,A                  ; B=the key states
  AND 4                   ; Is M pressed?
  JR NZ,46514             ; No
  SET 7,C                 ; Set bit 7: fire
  LD A,B                  ; A=the key states
  AND 8                   ; Is N pressed?
  JR NZ,46521             ; No
  SET 7,C                 ; Set bit 7: fire
  LD A,B                  ; A=the key states
  AND 16                  ; Is B pressed?
  JR NZ,46528             ; No
  SET 7,C                 ; Set bit 7: fire
  LD A,C                  ; A=the combined bits
  AND A                   ; Test them
  JR Z,46640              ; No key pressed: no movement
  LD B,A                  ; B=the bits
  AND 17                  ; Up and down together?
  CP 17                   ; Compare
  JR Z,46640              ; Yes: they cancel
  LD A,B                  ; A=the bits
  AND 68                  ; Left and right together?
  CP 68                   ; Compare
  JR Z,46640              ; Yes: they cancel
  LD A,B                  ; A=the bits
  AND 128                 ; Is fire pressed?
  LD A,10                 ; A=10: the code for fire
  JR NZ,46641             ; Yes: use it
  LD A,B                  ; A=the bits
  AND 127                 ; Drop the fire bit
  LD B,A                  ; B=the direction bits
  CP 4                    ; Right?
  JR Z,46641              ; Use the code
  CP 64                   ; Left?
  JR Z,46641              ; Use the code
  CP 5                    ; Up and right?
  LD A,2                  ; A=2
  JR Z,46641              ; Use the code
  LD A,B                  ; A=the bits
  CP 20                   ; Down and right?
  LD A,8                  ; A=8
  JR Z,46641              ; Use the code
  LD A,B                  ; A=the bits
  CP 65                   ; Up and left?
  LD A,128                ; A=128
  JR Z,46641              ; Use the code
  LD A,B                  ; A=the bits
  CP 80                   ; Down and left?
  LD A,32                 ; A=32
  JR Z,46641              ; Use the code
  LD A,B                  ; A=the bits
  CP 1                    ; Up only?
  JR NZ,46616             ; No: try down
  LD A,(HL)               ; A=Mugsy's state byte
  LD D,A                  ; D=it
  AND 14                  ; Is he facing right?
  JR Z,46607              ; No
  LD A,2                  ; A=2: up and right
  JR 46641                ; Use the code
  LD A,D                  ; A=his state
  AND 224                 ; Is he facing left?
  JR Z,46616              ; No
  LD A,128                ; A=128: up and left
  JR 46641                ; Use the code
  LD A,B                  ; A=the bits
  CP 16                   ; Down only?
  JR NZ,46640             ; No: no movement
  LD A,(HL)               ; A=Mugsy's state byte
  AND 14                  ; Is he facing right?
  JR Z,46630              ; No
  LD A,8                  ; A=8: down and right
  JR 46641                ; Use the code
  LD A,D                  ; A=his state
  AND 224                 ; Is he facing left?
  JR Z,46640              ; No: no movement
  LD A,32                 ; A=32: down and left
  JR 46641                ; Use the code

; Unused: a stray byte
;
; Nothing can reach this byte: the JR at 46637 jumps over it and the JR Z at
; 46633 lands just after it. It is 120, the instruction LD A,B, probably the
; remains of an earlier version of this routine.
  DEFB 120                ; LD A,B: never executed

; Shootout: no movement
  LD A,(HL)               ; A=Mugsy's current state (no new direction)
  LD (42315),A            ; Store the direction code for the main loop
  RET                     ; Return

; Shootout: bystander 1 route script
;
; One byte per step: a direction code, 0 to stand still, 80/81/82 for long
; pauses, 255 to wake the hit man and 254 to leave. See 43018.
  DEFB 4,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,80
  DEFB 82,81,64,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,32
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,8,0,0,0
  DEFB 0,0,4,0,0,0,80,255
  DEFB 81,128,0,0,0,0,0,0
  DEFB 2,0,0,0,0,0,0,128
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 64,0,0,254

; Shootout: bystander 2 route script
;
; Used by 43246.
  DEFB 4,0,0,0,0,0,0,0
  DEFB 0,0,0,2,0,0,0,0
  DEFB 0,0,0,0,4,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,8,0,0,0,0,0,0
  DEFB 0,0,0,0,64,0,0,0
  DEFB 82,80,255,81,8,0,0,0
  DEFB 0,0,0,0,0,64,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,32,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,82,128,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,64,0,0,0,0,0,0
  DEFB 254

; Shootout: the hit man's move fragments
;
; Six fragments of eight bytes: a direction code, two bytes that 43977 sets to
; 10 when the hit man should fire, a pause and the end marker 255.
  DEFB 4,0,0,0,0,0,0,255
  DEFB 64,0,0,0,0,0,0,255
  DEFB 2,0,0,0,0,0,0,255
  DEFB 128,0,0,0,0,0,0,255
  DEFB 8,0,0,0,0,0,0,255
  DEFB 32,0,0,0,0,0,0,255

; Shootout: graphics
;
; Sprites for Mugsy, the hit man, the bystanders, the furniture and the
; bullets. Inverted in place the first time the shootout runs (42700). Each
; figure frame is 16 pixels wide and 32 rows tall (two bytes per row). Left to
; right: the woman at the bar (four walking frames and one standing), the
; second bystander (three frames), Mugsy (two walking, two kneeling) and the
; hit man (two walking, two kneeling):
  DEFB 0,56,0,120,1,128,1,255
  DEFB 0,212,0,226,0,196,0,224
  DEFB 1,240,1,248,3,248,3,240
  DEFB 3,247,3,254,3,252,3,248
  DEFB 3,224,3,224,3,224,3,192
  DEFB 1,192,1,192,1,192,1,192
  DEFB 3,192,3,192,3,128,7,128
  DEFB 7,0,5,128,2,64,1,224
  DEFB 0,240,1,240,6,0,7,254
  DEFB 1,168,1,196,1,8,1,192
  DEFB 3,224,7,240,7,240,15,224
  DEFB 31,224,31,231,31,254,15,252
  DEFB 7,248,7,224,7,224,3,224
  DEFB 3,240,7,240,7,240,7,112
  DEFB 15,112,126,48,188,48,160,48
  DEFB 160,56,64,60,0,34,0,31
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,30,0,62,0
  DEFB 192,0,255,192,53,0,56,129
  DEFB 17,15,28,12,63,252,63,248
  DEFB 63,0,63,0,63,0,63,0
  DEFB 63,0,62,0,62,0,63,240
  DEFB 63,248,63,248,31,176,239,48
  DEFB 191,96,191,112,223,72,134,124
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,60,0,124,0
  DEFB 128,64,255,64,106,96,113,112
  DEFB 34,48,24,112,125,224,127,192
  DEFB 127,0,126,0,124,0,124,0
  DEFB 124,0,62,0,62,0,63,240
  DEFB 63,248,31,248,15,176,239,48
  DEFB 191,96,191,112,223,72,134,124
  DEFB 0,240,1,248,7,248,1,254
  DEFB 1,168,1,164,1,8,2,8
  DEFB 3,144,3,240,3,208,7,208
  DEFB 7,208,7,208,7,208,6,208
  DEFB 7,208,3,240,3,240,1,240
  DEFB 1,240,1,240,1,224,1,224
  DEFB 3,224,3,192,3,192,7,128
  DEFB 7,0,3,0,5,128,3,192
  DEFB 1,224,3,240,15,240,3,252
  DEFB 3,80,3,72,2,8,2,16
  DEFB 7,160,15,224,31,160,31,176
  DEFB 63,176,63,176,57,160,29,160
  DEFB 15,160,7,224,3,240,7,240
  DEFB 7,240,7,240,7,112,7,112
  DEFB 7,112,94,112,94,48,96,48
  DEFB 96,48,64,56,0,12,0,62
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,15,0,31,128
  DEFB 127,128,31,224,26,128,26,64
  DEFB 16,64,16,128,28,247,31,14
  DEFB 31,254,31,240,29,0,29,0
  DEFB 61,0,58,0,63,224,63,248
  DEFB 31,248,15,248,15,48,167,112
  DEFB 191,96,255,96,207,24,134,124
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,15,0,31,0
  DEFB 63,200,253,8,60,140,52,156
  DEFB 17,28,16,40,60,216,63,56
  DEFB 63,240,63,224,58,192,58,0
  DEFB 58,0,52,0,63,224,63,248
  DEFB 31,248,15,248,15,48,167,112
  DEFB 191,96,255,96,207,24,134,124
  DEFB 0,0,0,240,1,240,1,248
  DEFB 7,254,3,88,7,88,7,132
  DEFB 15,200,15,248,30,224,28,96
  DEFB 56,32,56,0,56,32,60,64
  DEFB 30,192,15,192,7,192,7,192
  DEFB 7,224,15,224,15,224,15,224
  DEFB 7,192,7,192,15,128,15,0
  DEFB 14,0,10,0,7,128,3,192
  DEFB 0,0,0,0,0,240,1,240
  DEFB 1,248,7,254,3,88,3,24
  DEFB 7,132,7,232,15,232,14,112
  DEFB 28,32,28,0,30,32,15,96
  DEFB 7,224,7,224,7,240,7,240
  DEFB 15,240,15,240,31,248,63,248
  DEFB 15,248,31,248,127,56,94,56
  DEFB 96,24,96,24,64,6,0,31
  DEFB 0,0,0,0,0,0,15,0
  DEFB 31,0,31,128,127,224,21,128
  DEFB 17,184,8,70,28,193,30,193
  DEFB 62,129,62,130,60,194,123,194
  DEFB 127,196,127,132,127,228,127,24
  DEFB 126,0,127,192,63,224,31,240
  DEFB 3,240,7,240,15,112,30,48
  DEFB 60,56,88,56,108,38,30,31
  DEFB 1,224,0,0,3,240,3,160
  DEFB 3,144,1,160,2,0,7,0
  DEFB 15,152,9,191,17,232,19,208
  DEFB 23,144,19,160,11,64,11,0
  DEFB 7,128,7,128,7,192,3,192
  DEFB 3,192,3,192,6,64,6,64
  DEFB 11,32,26,160,34,160,108,80
  DEFB 240,80,224,112,192,120,96,92
  DEFB 1,224,0,0,3,240,3,160
  DEFB 3,144,1,160,2,0,7,0
  DEFB 7,152,9,175,9,232,9,208
  DEFB 13,224,13,192,13,128,9,0
  DEFB 11,0,15,0,15,128,7,128
  DEFB 7,128,3,192,2,192,6,160
  DEFB 5,32,13,64,29,128,26,0
  DEFB 26,0,20,0,14,0,15,0
  DEFB 3,192,0,0,7,224,7,64
  DEFB 7,32,7,64,1,0,2,0
  DEFB 7,152,7,175,9,232,17,208
  DEFB 19,224,23,128,23,0,19,0
  DEFB 26,0,26,0,30,0,31,0
  DEFB 15,0,15,128,7,128,4,128
  DEFB 8,192,51,64,117,64,120,160
  DEFB 96,160,96,224,64,240,0,184
  DEFB 3,192,0,0,7,224,7,64
  DEFB 7,32,1,64,2,0,7,0
  DEFB 15,128,9,140,17,215,39,228
  DEFB 47,200,39,176,23,192,19,0
  DEFB 15,0,15,128,15,128,15,128
  DEFB 15,128,7,128,4,128,2,128
  DEFB 2,128,4,128,27,0,53,0
  DEFB 57,0,42,0,47,0,15,128
  DEFB 0,0,0,0,0,0,0,0
  DEFB 7,128,0,0,15,192,14,128
  DEFB 14,64,26,128,44,0,68,0
  DEFB 142,0,70,128,49,0,30,0
  DEFB 30,0,30,24,31,228,31,228
  DEFB 31,164,15,36,1,52,0,212
  DEFB 0,94,0,87,0,144,0,160
  DEFB 0,160,0,224,0,240,0,184
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,14,209,142,61,238,189,251
  DEFB 239,253,251,239,243,255,223,224
  DEFB 61,255,248,12,97,252,2,158
  DEFB 178,1,56,146,0,199,12,124
  DEFB 62,0,240,28,0,192,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,56,0,28,199,0,19
  DEFB 187,254,31,189,241,31,189,254
  DEFB 63,221,216,249,227,132,254,62
  DEFB 84,24,12,120,32,48,0,56
  DEFB 192,0,255,0,0,0,0,0
  DEFB 0,96,32,0,240,112,0,119
  DEFB 128,0,62,112,0,253,184,3
  DEFB 251,188,15,251,190,63,251,91
  DEFB 127,28,145,62,7,21,25,0
  DEFB 14,5,240,0,3,128,0,0
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,0,0,0,59,193
  DEFB 224,190,243,240,188,127,248,248
  DEFB 127,244,129,255,142,126,15,119
  DEFB 15,240,49,28,68,70,145,17
  DEFB 196,71,177,29,159,241,196,69
  DEFB 145,17,212,69,145,21,213,69
  DEFB 145,21,213,69,49,22,31,248
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,24,0,248,0,248,0
  DEFB 248,0,248,0,232,0,200,0
  DEFB 200,0,223,224,127,192,127,192
  DEFB 127,64,105,64,81,32,81,32
  DEFB 144,160,128,128,128,128,128,128
  DEFB 0,0,0,0,0,0,0,0
  DEFB 0,0,0,24,0,31,0,31
  DEFB 0,31,0,31,0,23,0,19
  DEFB 0,19,7,251,3,254,3,254
  DEFB 2,254,2,150,4,138,4,138
  DEFB 5,9,1,1,1,1,1,0
  DEFB 172,251,0,0,239,0,252,0
  DEFB 0,191,0,239,0,0,239,0
  DEFB 212,0,0,191,0,255,0,0
  DEFB 253,0,212,0,0,191,255,237
  DEFB 0,0,239,255,216,0,0,191
  DEFB 255,247,0,0,239,219,32,0
  DEFB 3,191,0,0,0,31,239,219
  DEFB 0,0,126,191,0,16,0,123
  DEFB 239,219,42,0,111,191,0,16
  DEFB 255,254,239,11,43,255,251,255
  DEFB 0,0,32,16,120,1,35,0
  DEFB 1,128,0,0,32,2,91,48
  DEFB 35,6,33,128,0,16,96,2
  DEFB 89,176,42,4,145,128,0,0
  DEFB 0,2,89,176,43,54,209,128
  DEFB 1,16,16,16,16,16,56,16
  DEFB 16,56,7,7,6,7,7,7
  DEFB 7

; Interrupt routine for the shootout: the sprite scheduler
;
; Runs fifty times a second. For each figure whose timer is 0 it counts down
; the figure's countdown; when that reaches zero it points SP at the figure's
; record and uses POP to load HL, DE, BC and IY from it, then jumps to IY: a
; sprite drawing routine (45965, 46031, 46119 or 46196) that draws the figure
; with the registers already set up. The drawing routines pass control on
; through 48601 and finish at 48617, which restores the real stack and sets the
; timer to 1. The routine ends by reading the keyboard.
ISR2:
  PUSH AF                 ; Save AF
  PUSH BC                 ; Save BC
  PUSH DE                 ; Save DE
  PUSH HL                 ; Save HL
  PUSH IX                 ; Save IX
  PUSH IY                 ; Save IY
  LD HL,42250             ; HL=the figure timers
  LD A,(42311)            ; A=the number of figures in use
  LD B,A                  ; B=the count
  LD C,0                  ; C=0: the figure number
  LD A,(HL)               ; A=this figure's timer
  AND A                   ; Test it
  JR NZ,48622             ; Not zero: the figure is idle or waiting for orders
  PUSH BC                 ; Save the counters
  PUSH HL                 ; Save the timer pointer
  LD HL,42257             ; HL=the table of countdown pointers (42257)
  LD B,0                  ; B=0
  RL C                    ; C=the figure number*2
  ADD HL,BC               ; HL=its entry
  LD E,(HL)               ; E=the countdown address, low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=high byte
  EX DE,HL                ; HL=the countdown address
  DEC (HL)                ; One tick less
  JR Z,48582              ; Reached zero: draw the figure
  POP HL                  ; Restore the timer pointer
  LD (HL),255             ; Set the timer to 255 so that the INC below leaves
                          ; it at 0
  JR 48620                ; Next figure
  INC HL                  ; Next byte: the sprite job pointer
  LD E,(HL)               ; E=the low byte
  INC HL                  ; Next byte
  LD D,(HL)               ; D=the high byte
  EX DE,HL                ; HL=the sprite job (a block of register values)
  LD IX,0                 ; IX=0
  ADD IX,SP               ; IX=the stack pointer
  LD SP,HL                ; SP=the sprite job
  POP HL                  ; HL=the first register pair from the job
  POP DE                  ; DE=the second pair
  POP BC                  ; BC=the third pair
  POP IY                  ; IY=the address of the drawing routine
  JP (IY)                 ; Run the drawing routine (it finishes with a jump to
                          ; 48601 or 48617)
  EXX                     ; Switch to the alternate registers
  POP HL                  ; HL'=the next value from the job
  POP DE                  ; DE'=the next value
  EXX                     ; Back to the main registers
  POP BC                  ; BC=the next value
  POP HL                  ; HL=the next value
  POP IY                  ; IY=the next routine
  LD (42303),SP           ; Remember the stack pointer
  LD SP,HL                ; SP=the job's saved-background area
  INC SP                  ; Step past the last byte
  JP (IY)                 ; Run the second routine (it finishes with a jump to
                          ; 48617)
  LD SP,IX                ; Restore the real stack pointer
  POP HL                  ; Restore the timer pointer
  POP BC                  ; Restore the counters
  INC (HL)                ; Timer: 0 becomes 1 (the figure is ready for orders)
  INC HL                  ; Next timer
  INC C                   ; Next figure
  DJNZ 48556              ; Loop for all the figures
  CALL CONTROLS           ; Read the keyboard
  POP IY                  ; Restore IY
  POP IX                  ; Restore IX
  POP HL                  ; Restore HL
  POP DE                  ; Restore DE
  POP BC                  ; Restore BC
  POP AF                  ; Restore AF
  EI                      ; Enable interrupts
  RET                     ; Return from the interrupt

; Padding before the dictionary
;
; A single zero byte (a NOP) after the interrupt routine. It brings the
; dictionary to 48640, which is 190 x 256, so that the dictionary starts on a
; page boundary; dictionary references are a page number plus an offset (see
; DICTWORD).
  DEFB 0                  ; Padding

; Dictionary
;
; The 225 words that Louey's messages are built from, 1006 bytes in all, in
; alphabetical order. A message refers to a word by a page number (0-4) and an
; offset (DICTWORD adds them to 48640), or, for the 32 commonest, by a single
; byte (the table at 49710). The block starts with a letter index of 32
; two-byte entries (64 bytes); the words follow.
;
; Each letter takes one byte: the low five bits are the letter (1 = a to 26 =
; z; 27 to 31 are the punctuation marks ' - ! ? and ") and the top bits are
; mostly ignored. Bit 7 marks the last letter of a word, but only from the
; third letter on, so no word is cut short at two letters. A short word is
; closed by a byte whose letter is 0. Each line below is one word, with its
; offset from 48640 (the number a message uses; the page is the offset divided
; by 256).
;
; The game never reads the letter index: it finds words only through the
; references. It looks like a by-product of the tool that built the dictionary.
; 9 words are never referred to by any message: "fin", "fun", "lea", "liv",
; "min", "per", "pre", "some", "the".
  DEFB 0,0                ; Index: unused
  DEFB 64,0               ; Index: offset 64, the first word beginning with "a"
                          ; ("a")
  DEFB 140,0              ; Index: offset 140, the first word beginning with
                          ; "b" ("bad")
  DEFB 189,0              ; Index: offset 189, the first word beginning with
                          ; "c" ("can")
  DEFB 255,0              ; Index: offset 255, the first word beginning with
                          ; "d" ("da")
  DEFB 45,1               ; Index: offset 301, the first word beginning with
                          ; "e" ("each")
  DEFB 49,1               ; Index: offset 305, the first word beginning with
                          ; "f" ("fin")
  DEFB 84,1               ; Index: offset 340, the first word beginning with
                          ; "g" ("g")
  DEFB 156,1              ; Index: offset 412, the first word beginning with
                          ; "h" ("had")
  DEFB 224,1              ; Index: offset 480, the first word beginning with
                          ; "i" ("i")
  DEFB 239,1              ; Index: offset 495, the first word beginning with
                          ; "j" ("jack")
  DEFB 253,1              ; Index: offset 509, the first word beginning with
                          ; "k" ("keep")
  DEFB 9,2                ; Index: offset 521, the first word beginning with
                          ; "l" ("las")
  DEFB 44,2               ; Index: offset 556, the first word beginning with
                          ; "m" ("made")
  DEFB 111,2              ; Index: offset 623, the first word beginning with
                          ; "n" ("need")
  DEFB 140,2              ; Index: offset 652, the first word beginning with
                          ; "o" ("of")
  DEFB 193,2              ; Index: offset 705, the first word beginning with
                          ; "p" ("pay")
  DEFB 228,2              ; Index: offset 740, the first word beginning with
                          ; "q" ("quentin")
  DEFB 235,2              ; Index: offset 747, the first word beginning with
                          ; "r" ("rackets")
  DEFB 255,2              ; Index: offset 767, the first word beginning with
                          ; "s" ("safe")
  DEFB 122,3              ; Index: offset 890, the first word beginning with
                          ; "t" ("ta")
  DEFB 212,3              ; Index: offset 980, the first word beginning with
                          ; "u" ("up")
  DEFB 218,3              ; Index: offset 986, the first word beginning with
                          ; "v" ("vegas")
  DEFB 223,3              ; Index: offset 991, the first word beginning with
                          ; "w" ("wanna")
  DEFB 0,0                ; Index: no words begin with "x"
  DEFB 22,4               ; Index: offset 1046, the first word beginning with
                          ; "y" ("ya")
  DEFB 0,0                ; Index: no words begin with "z"
  DEFB 0,0                ; Index: unused
  DEFB 0,0                ; Index: unused
  DEFB 0,0                ; Index: unused
  DEFB 0,0                ; Index: unused
  DEFB 0,0                ; Index: unused
  DEFB 97,32,128          ; 64: "a" (also the single-byte token 106)
  DEFB 97,34,133          ; 67: "abe"
  DEFB 97,34,15,21,148    ; 70: "about"
  DEFB 97,39,1,9,142      ; 75: "again"
  DEFB 97,41,14,148       ; 80: "aint" (also the single-byte token 114)
  DEFB 97,44,3,1,20,18,1,154 ; 84: "alcatraz"
  DEFB 97,44,140          ; 92: "all"
  DEFB 97,46,128          ; 95: "an"
  DEFB 97,46,132          ; 98: "and" (also the single-byte token 108)
  DEFB 97,46,15,20,8,5,146 ; 101: "another"
  DEFB 97,46,19,23,5,146  ; 108: "answer"
  DEFB 97,46,153          ; 114: "any"
  DEFB 97,46,25,23,1,153  ; 117: "anyway"
  DEFB 97,46,25,23,1,25,147 ; 123: "anyways"
  DEFB 97,50,133          ; 130: "are"
  DEFB 97,51,128          ; 133: "as"
  DEFB 97,55,1,153        ; 136: "away"
  DEFB 98,33,132          ; 140: "bad"
  DEFB 98,33,8,1,13,1,147 ; 143: "bahamas"
  DEFB 98,37,128          ; 150: "be" (also the single-byte token 125)
  DEFB 98,37,14,14,153    ; 153: "benny"
  DEFB 98,37,20,20,5,146  ; 158: "better"
  DEFB 98,47,19,147       ; 164: "boss"
  DEFB 98,47,153          ; 168: "boy"
  DEFB 98,47,25,147       ; 171: "boys" (also the single-byte token 105)
  DEFB 98,53,3,11,147     ; 175: "bucks"
  DEFB 98,53,148          ; 180: "but"
  DEFB 98,53,153          ; 183: "buy"
  DEFB 98,57,128          ; 186: "by"
  DEFB 99,33,142          ; 189: "can"
  DEFB 99,40,9,3,1,7,143  ; 192: "chicago"
  DEFB 99,41,20,153       ; 199: "city"
  DEFB 99,44,9,5,14,148   ; 203: "client"
  DEFB 99,44,9,5,14,20,147 ; 209: "clients" (also the single-byte token 120)
  DEFB 99,47,14,20,18,1,3,148 ; 216: "contract"
  DEFB 99,47,16,147       ; 224: "cops" (also the single-byte token 127)
  DEFB 99,47,19,148       ; 228: "cost"
  DEFB 99,47,21,12,132    ; 232: "could"
  DEFB 99,50,9,16,5,147   ; 237: "cripes"
  DEFB 99,53,19,20,15,13,5,18,147 ; 243: "customers"
  DEFB 99,53,148          ; 252: "cut"
  DEFB 100,33,128         ; 255: "da" (also the single-byte token 99)
  DEFB 100,33,148         ; 258: "dat"
  DEFB 100,37,20,18,15,9,148 ; 261: "detroit"
  DEFB 100,41,132         ; 268: "did"
  DEFB 100,41,135         ; 271: "dig"
  DEFB 100,41,147         ; 274: "dis"
  DEFB 100,41,19,14,5,25,12,1,14,132 ; 277: "disneyland"
  DEFB 100,47,128         ; 287: "do" (also the single-byte token 124)
  DEFB 100,47,9,142       ; 290: "doin"
  DEFB 100,47,142         ; 294: "don"
  DEFB 100,53,13,130      ; 297: "dumb"
  DEFB 101,33,3,136       ; 301: "each"
  DEFB 102,41,142         ; 305: "fin" (not used by any message)
  DEFB 102,44,15,18,9,4,129 ; 308: "florida"
  DEFB 102,47,146         ; 315: "for" (also the single-byte token 107)
  DEFB 102,47,18,7,5,148  ; 318: "forget"
  DEFB 102,50,1,3,20,9,15,14,147 ; 324: "fractions"
  DEFB 102,50,15,141      ; 333: "from"
  DEFB 102,53,142         ; 337: "fun" (not used by any message)
  DEFB 103,32,128         ; 340: "g"
  DEFB 103,37,133         ; 343: "gee"
  DEFB 103,37,5,154       ; 346: "geez"
  DEFB 103,37,148         ; 350: "get"
  DEFB 103,37,20,20,9,142 ; 353: "gettin"
  DEFB 103,41,13,13,133   ; 359: "gimme"
  DEFB 103,41,22,133      ; 364: "give"
  DEFB 103,47,5,147       ; 368: "goes"
  DEFB 103,47,9,142       ; 372: "goin"
  DEFB 103,47,14,14,129   ; 376: "gonna" (also the single-byte token 115)
  DEFB 103,47,15,132      ; 381: "good"
  DEFB 103,47,148         ; 385: "got" (also the single-byte token 103)
  DEFB 103,47,20,20,129   ; 388: "gotta"
  DEFB 103,50,1,14,132    ; 393: "grand" (also the single-byte token 98)
  DEFB 103,50,5,1,148     ; 398: "great"
  DEFB 103,50,5,5,139     ; 403: "greek"
  DEFB 103,53,25,147      ; 408: "guys"
  DEFB 104,33,132         ; 412: "had"
  DEFB 104,33,12,140      ; 415: "hall"
  DEFB 104,33,14,132      ; 419: "hand"
  DEFB 104,33,18,132      ; 423: "hard"
  DEFB 104,33,147         ; 427: "has"
  DEFB 104,33,22,133      ; 430: "have"
  DEFB 104,33,23,1,9,137  ; 434: "hawaii"
  DEFB 104,37,128         ; 440: "he"
  DEFB 104,37,1,18,132    ; 443: "heard"
  DEFB 104,37,18,133      ; 448: "here"
  DEFB 104,41,128         ; 452: "hi"
  DEFB 104,41,148         ; 455: "hit"
  DEFB 104,47,15,132      ; 458: "hood"
  DEFB 104,47,151         ; 462: "how"
  DEFB 104,47,23,5,22,5,146 ; 465: "however"
  DEFB 104,47,23,147      ; 472: "hows"
  DEFB 104,53,18,148      ; 476: "hurt"
  DEFB 105,32,128         ; 480: "i"
  DEFB 105,38,128         ; 483: "if"
  DEFB 105,46,128         ; 486: "in" (also the single-byte token 101)
  DEFB 105,51,128         ; 489: "is" (also the single-byte token 111)
  DEFB 105,52,128         ; 492: "it" (also the single-byte token 110)
  DEFB 106,33,3,139       ; 495: "jack"
  DEFB 106,53,13,16,9,142 ; 499: "jumpin"
  DEFB 106,53,19,148      ; 505: "just"
  DEFB 107,37,5,144       ; 509: "keep"
  DEFB 107,41,12,140      ; 513: "kill"
  DEFB 107,46,15,151      ; 517: "know"
  DEFB 108,33,147         ; 521: "las"
  DEFB 108,33,19,148      ; 524: "last"
  DEFB 108,37,129         ; 528: "lea" (not used by any message)
  DEFB 108,37,6,148       ; 531: "left"
  DEFB 108,37,148         ; 535: "let"
  DEFB 108,41,150         ; 538: "liv" (not used by any message)
  DEFB 108,47,21,5,153    ; 541: "louey"
  DEFB 108,47,21,19,153   ; 546: "lousy"
  DEFB 108,53,3,11,153    ; 551: "lucky"
  DEFB 109,33,4,133       ; 556: "made"
  DEFB 109,33,11,133      ; 560: "make"
  DEFB 109,33,142         ; 564: "man"
  DEFB 109,33,14,153      ; 567: "many" (also the single-byte token 109)
  DEFB 109,37,128         ; 571: "me" (also the single-byte token 123)
  DEFB 109,37,1,14,147    ; 574: "means"
  DEFB 109,41,142         ; 579: "min" (not used by any message)
  DEFB 109,41,14,21,19,5,147 ; 582: "minuses"
  DEFB 109,41,19,147      ; 589: "miss"
  DEFB 109,47,130         ; 593: "mob" (also the single-byte token 126)
  DEFB 109,47,2,147       ; 596: "mobs"
  DEFB 109,53,3,136       ; 600: "much"
  DEFB 109,53,7,19,153    ; 604: "mugsy"
  DEFB 109,53,19,3,12,133 ; 609: "muscle"
  DEFB 109,53,19,20,129   ; 615: "musta"
  DEFB 109,57,128         ; 620: "my"
  DEFB 110,37,5,132       ; 623: "need"
  DEFB 110,37,7,1,20,9,22,5,147 ; 627: "negatives"
  DEFB 110,41,3,139       ; 636: "nick"
  DEFB 110,47,128         ; 640: "no"
  DEFB 110,47,151         ; 643: "now"
  DEFB 110,53,20,8,9,142  ; 646: "nuthin"
  DEFB 111,38,128         ; 652: "of" (also the single-byte token 104)
  DEFB 111,38,134         ; 655: "off"
  DEFB 111,43,1,153       ; 658: "okay"
  DEFB 111,46,128         ; 662: "on" (also the single-byte token 118)
  DEFB 111,46,133         ; 665: "one"
  DEFB 111,46,12,153      ; 668: "only" (also the single-byte token 116)
  DEFB 111,50,128         ; 672: "or"
  DEFB 111,50,7,1,14,9,19,1,20,9,15,142 ; 675: "organisation"
  DEFB 111,52,8,5,146     ; 687: "other"
  DEFB 111,53,146         ; 692: "our"
  DEFB 111,53,148         ; 695: "out"
  DEFB 111,53,20,129      ; 698: "outa"
  DEFB 111,55,133         ; 702: "owe"
  DEFB 112,33,153         ; 705: "pay"
  DEFB 112,37,146         ; 708: "per" (not used by any message)
  DEFB 112,50,133         ; 711: "pre" (not used by any message)
  DEFB 112,50,15,20,5,3,148 ; 714: "protect"
  DEFB 112,50,15,20,5,3,20,9,15,142 ; 721: "protection"
  DEFB 112,53,148         ; 731: "put"
  DEFB 112,53,20,20,9,142 ; 734: "puttin"
  DEFB 113,53,5,14,20,9,142 ; 740: "quentin"
  DEFB 114,33,3,11,5,20,147 ; 747: "rackets"
  DEFB 114,37,1,140       ; 754: "real"
  DEFB 114,41,4,133       ; 758: "ride"
  DEFB 114,47,3,3,143     ; 762: "rocco"
  DEFB 115,33,6,133       ; 767: "safe"
  DEFB 115,33,142         ; 771: "san"
  DEFB 115,33,153         ; 774: "say"
  DEFB 115,33,25,9,142    ; 777: "sayin"
  DEFB 115,35,1,18,5,132  ; 782: "scared"
  DEFB 115,35,1,18,6,1,3,133 ; 788: "scarface"
  DEFB 115,35,8,13,21,3,139 ; 796: "schmuck"
  DEFB 115,37,12,140      ; 803: "sell"
  DEFB 115,40,15,15,20,15,21,148 ; 807: "shootout"
  DEFB 115,41,2,5,18,9,129 ; 815: "siberia"
  DEFB 115,41,14,135      ; 822: "sing"
  DEFB 115,47,128         ; 826: "so" (also the single-byte token 121)
  DEFB 115,47,13,133      ; 829: "some"
  DEFB 115,47,13,133      ; 833: "some" (not used by any message)
  DEFB 115,47,18,18,153   ; 837: "sorry"
  DEFB 115,49,21,5,5,26,133 ; 842: "squeeze"
  DEFB 115,52,9,12,140    ; 849: "still"
  DEFB 115,52,15,15,16,9,132 ; 854: "stoopid"
  DEFB 115,52,15,15,16,9,4,9,20,153 ; 861: "stoopidity"
  DEFB 115,53,18,133      ; 871: "sure"
  DEFB 115,53,18,22,9,150 ; 875: "surviv"
  DEFB 115,57,14,4,9,3,1,20,133 ; 881: "syndicate"
  DEFB 116,33,128         ; 890: "ta" (also the single-byte token 122)
  DEFB 116,33,11,9,142    ; 893: "takin"
  DEFB 116,37,12,140      ; 898: "tell"
  DEFB 116,37,18,18,137   ; 902: "terri"
  DEFB 116,40,1,142       ; 907: "than"
  DEFB 116,40,1,148       ; 911: "that" (also the single-byte token 113)
  DEFB 116,40,133         ; 915: "the" (also the single-byte token 96)
  DEFB 116,40,133         ; 918: "the" (not used by any message)
  DEFB 116,40,5,9,18,19,5,12,22,5,147 ; 921: "theirselves"
  DEFB 116,40,5,141       ; 932: "them"
  DEFB 116,40,5,18,133    ; 936: "there"
  DEFB 116,40,5,153       ; 941: "they"
  DEFB 116,40,9,14,139    ; 945: "think"
  DEFB 116,40,9,14,11,9,142 ; 950: "thinkin"
  DEFB 116,40,9,147       ; 957: "this"
  DEFB 116,40,15,21,19,1,14,132 ; 961: "thousand"
  DEFB 116,47,128         ; 969: "to" (also the single-byte token 112)
  DEFB 116,47,143         ; 972: "too"
  DEFB 116,47,21,7,136    ; 975: "tough"
  DEFB 117,48,128         ; 980: "up"
  DEFB 117,51,128         ; 983: "us"
  DEFB 118,37,7,1,147     ; 986: "vegas"
  DEFB 119,33,14,14,129   ; 991: "wanna"
  DEFB 119,33,14,148      ; 996: "want"
  DEFB 119,33,147         ; 1000: "was"
  DEFB 119,33,19,136      ; 1003: "wash"
  DEFB 119,33,20,3,136    ; 1007: "watch"
  DEFB 119,37,128         ; 1012: "we" (also the single-byte token 102)
  DEFB 119,37,12,140      ; 1015: "well"
  DEFB 119,40,1,148       ; 1019: "what"
  DEFB 119,41,12,140      ; 1023: "will"
  DEFB 119,41,148         ; 1027: "wit"
  DEFB 119,47,142         ; 1030: "won"
  DEFB 119,47,18,132      ; 1033: "word"
  DEFB 119,47,18,11,9,142 ; 1037: "workin"
  DEFB 119,53,154         ; 1043: "wuz"
  DEFB 121,33,128         ; 1046: "ya" (also the single-byte token 100)
  DEFB 121,37,1,136       ; 1049: "yeah"
  DEFB 121,37,1,146       ; 1053: "year" (also the single-byte token 117)
  DEFB 121,37,1,18,147    ; 1057: "years"
  DEFB 121,47,149         ; 1062: "you" (also the single-byte token 97)
  DEFB 121,47,21,146,0    ; 1065: "your" (also the single-byte token 119)

; Common words
;
; The 32 words that the game uses most, each reachable through a single byte in
; a message (96-127) instead of the two bytes of an ordinary dictionary
; reference. 29907 takes the byte minus 96 as an index into this table; each
; entry is two bytes, the offset of the word in the dictionary at 48640 (which
; also gives the page), and the page number in the low four bits of the second
; byte (the routine adds 80 to it to make the word type 5, an ordinary word).
; The table is in order of use, commonest first, which is why the low token
; numbers are the busiest. The counts below are the number of times each token
; appears in the messages.
;
; The commonest are "the" (49), "you" (36), "grand" (22), "da" (19), "ya" (19).
  DEFB 147,3              ; Token 96: "the" (dictionary offset 915), used 49
                          ; times
  DEFB 38,4               ; Token 97: "you" (dictionary offset 1062), used 36
                          ; times
  DEFB 137,1              ; Token 98: "grand" (dictionary offset 393), used 22
                          ; times
  DEFB 255,0              ; Token 99: "da" (dictionary offset 255), used 19
                          ; times
  DEFB 22,4               ; Token 100: "ya" (dictionary offset 1046), used 19
                          ; times
  DEFB 230,1              ; Token 101: "in" (dictionary offset 486), used 17
                          ; times
  DEFB 244,3              ; Token 102: "we" (dictionary offset 1012), used 17
                          ; times
  DEFB 129,1              ; Token 103: "got" (dictionary offset 385), used 16
                          ; times
  DEFB 140,2              ; Token 104: "of" (dictionary offset 652), used 14
                          ; times
  DEFB 171,0              ; Token 105: "boys" (dictionary offset 171), used 14
                          ; times
  DEFB 64,0               ; Token 106: "a" (dictionary offset 64), used 14
                          ; times
  DEFB 59,1               ; Token 107: "for" (dictionary offset 315), used 14
                          ; times
  DEFB 98,0               ; Token 108: "and" (dictionary offset 98), used 13
                          ; times
  DEFB 55,2               ; Token 109: "many" (dictionary offset 567), used 13
                          ; times
  DEFB 236,1              ; Token 110: "it" (dictionary offset 492), used 12
                          ; times
  DEFB 233,1              ; Token 111: "is" (dictionary offset 489), used 12
                          ; times
  DEFB 201,3              ; Token 112: "to" (dictionary offset 969), used 11
                          ; times
  DEFB 143,3              ; Token 113: "that" (dictionary offset 911), used 10
                          ; times
  DEFB 80,0               ; Token 114: "aint" (dictionary offset 80), used 10
                          ; times
  DEFB 120,1              ; Token 115: "gonna" (dictionary offset 376), used 10
                          ; times
  DEFB 156,2              ; Token 116: "only" (dictionary offset 668), used 10
                          ; times
  DEFB 29,4               ; Token 117: "year" (dictionary offset 1053), used 9
                          ; times
  DEFB 150,2              ; Token 118: "on" (dictionary offset 662), used 9
                          ; times
  DEFB 41,4               ; Token 119: "your" (dictionary offset 1065), used 8
                          ; times
  DEFB 209,0              ; Token 120: "clients" (dictionary offset 209), used
                          ; 8 times
  DEFB 58,3               ; Token 121: "so" (dictionary offset 826), used 8
                          ; times
  DEFB 122,3              ; Token 122: "ta" (dictionary offset 890), used 8
                          ; times
  DEFB 59,2               ; Token 123: "me" (dictionary offset 571), used 8
                          ; times
  DEFB 31,1               ; Token 124: "do" (dictionary offset 287), used 8
                          ; times
  DEFB 150,0              ; Token 125: "be" (dictionary offset 150), used 8
                          ; times
  DEFB 81,2               ; Token 126: "mob" (dictionary offset 593), used 7
                          ; times
  DEFB 224,0              ; Token 127: "cops" (dictionary offset 224), used 7
                          ; times

; Messages
;
; All of Louey's lines. Placeholders in parentheses are filled in from VM
; variables given after the SAY instruction; [a/b/c] marks a random choice.
  DEFB 243,58,32,76,79,78,71,242 ; Message: "So long Mugsy."
  DEFB 92,21                     ;
  DEFB 240,64,117,129,112,128,186,32 ; Message: "A year goes by ......"
  DEFB 46,46,46,46,46,21             ;
  DEFB 241,196,240,164,44,110,39,83 ; Message: "Hi Boss, it's Louey your
  DEFB 242,29,119,32,83,73,68,69    ; sidekick here wit' da lowdown on da
  DEFB 75,73,67,75,129,192,132,3    ; mob..."
  DEFB 39,99,32,76,79,87,68,79      ;
  DEFB 87,78,118,99,126,46,46,21    ;
  DEFB 242,12,117,4,129,152,103,32  ; Message: "Last year (v0) guys got rubbed
  DEFB 82,85,66,66,69,68,130,183    ; out by other mobs and (v1) hoods wuz
  DEFB 128,186,130,175,130,84,108,4 ; recruited by the organisation."
  DEFB 209,202,83,132,19,32,82,69   ;
  DEFB 67,82,85,73,84,69,68,128     ;
  DEFB 186,96,178,163               ;
  DEFB 240,199,241,159,131,177,97,32 ; Message: "City Hall think you stink"
  DEFB 83,84,73,78,75,20             ; (only reached through the random choice
                                     ; at 49917)
  DEFB 243,61,104,99,105,111,131,9 ; Message: "Some of da boys is sayin' you're
  DEFB 39,97,39,82,69,128,92,211   ; all washed up" (only reached through the
  DEFB 235,69,68,227,212           ; random choice at 49917)
  DEFB 10,2,11,219,11,231,44,240 ; Message: a random choice of the messages at
  DEFB 164,21                    ; 49882 or 49896 (25 or 46 characters)
  DEFB 240,180,131,61,131,232,32,85 ; Message: "But some was undercover feds
  DEFB 78,68,69,82,67,79,86,69      ; and (v0) got killed in the shootout."
  DEFB 82,32,70,69,68,83,108,4      ;
  DEFB 103,210,1,69,68,101,96,179   ;
  DEFB 39                           ;
  DEFB 243,58,99,126,130,131,32,67 ; Message: "So da mob now contains (v0)
  DEFB 79,78,84,65,73,78,83,4      ; (msg1) hoodlums."
  DEFB 5,209,202,76,85,77,83,21    ;
  DEFB 242,59,108,96,105,111,129,97 ; Message: "Me and the boys is gettin' out
  DEFB 39,130,183,32,80,82,79,78    ; pronto."
  DEFB 84,79,21                     ;
  DEFB 243,251,106,243,28,97,128,130 ; Message: "What a Schmuck you are,
  DEFB 44,242,92,33,20               ; Mugsy!"
  DEFB 243,244,32,68,73,68,78,39  ; Message: "We didn't run no rackets, Boss."
  DEFB 84,32,82,85,78,130,128,130 ;
  DEFB 235,44,240,164,21          ;
  DEFB 243,244,210,202,69,68,4,104  ; Message: "We protected (v0) of your (v1)
  DEFB 119,4,120,130,12,117,108,211 ; clients last year and squeezed them for
  DEFB 74,68,131,164,107,128,95,32  ; an average of $(v2), so we made (v3)
  DEFB 65,86,69,82,65,71,69,104     ; thousand bucks."
  DEFB 1,44,121,102,130,44,4,131    ;
  DEFB 193,176,175                  ;
  DEFB 128,180,242,250,39,83,126,103 ; Message: "but Rocco's mob got half of
  DEFB 32,72,65,76,70,104,113,32     ; that when they jumped us last winter."
  DEFB 87,72,69,78,131,173,32,74     ;
  DEFB 85,77,80,69,68,131,215,130    ;
  DEFB 12,32,87,73,78,84,69,82       ;
  DEFB 21                            ;
  DEFB 5,44,102,32,75,69,80,84   ; Message: "(msg0), we kept our noses clean
  DEFB 130,180,32,78,79,83,69,83 ; wit' da inmates of da precint house,"
  DEFB 32,67,76,69,65,78,132,3   ;
  DEFB 39,99,32,73,78,77,65,84   ;
  DEFB 69,83,104,99,32,80,82,69  ;
  DEFB 67,73,78,84,32,72,79,85   ;
  DEFB 83,69,44,20               ;
  DEFB 5,96,127,32,82,65,73,68    ; Message: "(msg0) the cops raided us and
  DEFB 69,68,131,215,108,32,84,79 ; took (v1) grand from our safe, Boss."
  DEFB 79,75,4,98,129,77,130,180  ;
  DEFB 130,255,44,240,164,21      ;
  DEFB 244,38,39,86,69,103,32,69     ; Message: "You've got exactly (v0) grand
  DEFB 88,65,67,84,76,89,4,98        ; in the safe, Boss. Anyways, dat's less
  DEFB 101,96,130,255,44,240,164,46  ; than da (v1) grand ya owe Nick the
  DEFB 240,123,44,129,2,39,83,32     ; Greek, so he's takin' over."
  DEFB 76,69,83,83,131,139,99,4      ;
  DEFB 98,100,130,190,242,124,96,241 ;
  DEFB 147,44,121,129,184,39,83,131  ;
  DEFB 125,39,32,79,86,69,82,21      ;
  DEFB 242,124,96,241,147,129,171,103 ; Message: "Nick the Greek has got the
  DEFB 96,4,98,100,32,79,87,69        ; (v0) grand ya owed him."
  DEFB 68,32,72,73,77,21              ;
  DEFB 243,58,100,114,103,96,32,68 ; Message: "So ya aint got the dough ta buy
  DEFB 79,85,71,72,122,128,183,32  ; rods and bullets so da boys can defend
  DEFB 82,79,68,83,108,32,66,85    ; theirselves. Sorry, Boss,- you're goin'
  DEFB 76,76,69,84,83,121,99,105   ; for a ride."
  DEFB 128,189,32,68,69,70,69,78   ;
  DEFB 68,131,153,46,243,69,44,240 ;
  DEFB 164,44,45,97,39,82,69,129   ;
  DEFB 116,39,107,106,178,246      ;
  DEFB 244,38,103,4,131,193,176,175 ; Message: "You got (v0) thousand bucks."
  DEFB 244,38,39,82,69,32,84,72    ; Message: "You're through, Boss, the hit
  DEFB 82,79,85,71,72,44,240,164   ; man from Detroit is on his way in,"
  DEFB 44,96,129,199,130,52,129,77 ;
  DEFB 241,5,111,118,32,72,73,83   ;
  DEFB 32,87,65,89,101,44,20       ;
  DEFB 241,90,44,121,130,88,107,96 ; Message: "Geez, so much for the contract,
  DEFB 128,216,44,97,39,86,69,32   ; you've eliminated their hit man."
  DEFB 69,76,73,77,73,78,65,84     ;
  DEFB 69,68,32,84,72,69,73,82     ;
  DEFB 129,199,178,52              ;
  DEFB 243,207,32,76,85,67,75,240  ; Message: "Tough luck Boss, me and the
  DEFB 164,44,123,108,96,105,39,76 ; boys'll give ya a decent funeral."
  DEFB 76,129,108,100,106,32,68,69 ;
  DEFB 67,69,78,84,32,70,85,78     ;
  DEFB 69,82,65,76,21              ;
  DEFB 240,180,32,73,84,83,115,128 ; Message: "But its gonna cost ya (v0) grand
  DEFB 228,100,4,98,112,129,253,96 ; to keep the cops quiet about all the
  DEFB 127,32,81,85,73,69,84,128   ; people what got wasted in the shootout."
  DEFB 70,128,92,96,32,80,69,79    ;
  DEFB 80,76,69,131,251,103,32,87  ;
  DEFB 65,83,84,69,68,101,96,179   ;
  DEFB 39                          ;
  DEFB 244,41,32,67,79,85,83,73     ; Message: "Your cousin Abe has muscled in
  DEFB 78,240,67,129,171,210,97,68  ; on your territory. You've had it."
  DEFB 101,118,119,211,134,84,79,82 ;
  DEFB 89,46,244,38,39,86,69,129    ;
  DEFB 156,110,21                   ;
  DEFB 243,247,44,100,32,76,73,86 ; Message: "Well, ya lived for another year."
  DEFB 69,68,107,128,101,117,21   ; (only reached through the random choice at
                                  ; 50670)
  DEFB 242,39,97,39,82,69,131,81 ; Message: "Lucky you're still in charge."
  DEFB 101,32,67,72,65,82,71,69  ; (only reached through the random choice at
  DEFB 21                        ; 50670)
  DEFB 241,224,129,132,129,163,110,112 ; Message: "I gotta hand it to ya,
  DEFB 100,44,240,164,21               ; Boss." (only reached through the
                                       ; random choice at 50670)
  DEFB 241,224,129,249,129,38,39,84 ; Message: "I just don't know how ya do it,
  DEFB 130,5,129,206,100,124,110,44 ; Boss." (only reached through the random
  DEFB 240,164,21                   ; choice at 50670)
  DEFB 244,22,131,103,128,130,106,211 ; Message: "Ya sure are a survivor,
  DEFB 107,79,82,44,240,164,21        ; Boss." (only reached through the random
                                      ; choice at 50670)
  DEFB 241,87,44,244,38,39,82,69    ; Message: "Gee, You're still da boss,
  DEFB 131,81,99,128,164,44,240,164 ; Boss." (only reached through the random
  DEFB 21                           ; choice at 50670)
  DEFB 240,237,44,97,39,82,69,131 ; Message: "Cripes, you're still hangin' on."
  DEFB 81,32,72,65,78,71,73,78    ; (only reached through the random choice at
  DEFB 39,118,21                  ; 50670)
  DEFB 10,7,11,139,11,152,11,167   ; Message: a random choice of the messages
  DEFB 11,178,11,195,11,208,11,223 ; at 50555 or 50570 or 50587 or 50600 or
  DEFB 20                          ; 50619 or 50634 or 50651 (32 or 29 or 28 or
                                   ; 37 or 29 or 32 or 32 characters)
  DEFB 5,131,61,104,99,105,101,96     ; Message: "(msg0) some of da boys in the
  DEFB 126,111,131,9,39,97,39,82      ; mob is sayin' you're past it and
  DEFB 69,32,80,65,83,84,110,108      ; they're talkin about puttin' out a
  DEFB 131,173,39,82,69,32,84,65      ; contract on you. If it goes any
  DEFB 76,75,73,78,128,70,130,222     ; further, how many grand ( if any) will
  DEFB 39,130,183,106,128,216,118,97  ; you pay to keep the good guys
  DEFB 46,241,227,110,129,112,128,114 ; faithful?"
  DEFB 32,70,85,82,84,72,69,82        ;
  DEFB 44,129,206,109,98,32,40,129    ;
  DEFB 227,128,114,41,131,255,97,130  ;
  DEFB 193,112,129,253,96,129,125,129 ;
  DEFB 152,32,70,65,73,84,72,70       ;
  DEFB 85,76,63,20                    ;
  DEFB 240,164,44,96,105,39,76,76 ; Message: "Boss, the boys'll gun ya down."
  DEFB 32,71,85,78,100,32,68,79   ;
  DEFB 87,78,21                   ;
  DEFB 241,206,109,98,107,96,209,163 ; Message: "How many grand for the
  DEFB 79,85,84,63,21                ; handout?."
  DEFB 244,38,39,76,76,130,1,131     ; Message: "You'll kill us wit' kindness,
  DEFB 215,132,3,39,32,75,73,78      ; Boss.....( you've only got (v0) grand).
  DEFB 68,78,69,83,83,44,240,164     ; Tell me that again, Boss."
  DEFB 46,46,46,46,46,40,97,39       ;
  DEFB 86,69,116,103,4,98,41,46      ;
  DEFB 243,130,123,113,128,75,44,240 ;
  DEFB 164,21                        ;
  DEFB 242,146,44,240,164,44,130,108 ; Message: "Okay, Boss, my guys will help
  DEFB 129,152,131,255,32,72,69,76   ; ya."
  DEFB 80,100,21                     ;
  DEFB 241,236,208,228,83,130,153,98  ; Message: "It costs one grand to put the
  DEFB 112,130,219,96,131,74,118,129  ; squeeze on each client, and the
  DEFB 45,128,203,44,108,96,32,71     ; godfather made the rule that our
  DEFB 79,68,70,65,84,72,69,82        ; gangsters each get one client to
  DEFB 130,44,96,32,82,85,76,69       ; protect for theirselves."
  DEFB 113,130,180,32,71,65,78,71     ;
  DEFB 83,84,69,82,83,129,45,129      ;
  DEFB 94,130,153,128,203,112,130,202 ;
  DEFB 107,179,153                    ;
  DEFB 243,147,132,9,111,113,242,250 ; Message: "The word is that Rocco's
  DEFB 39,83,129,97,39,32,85,80      ; gettin' uppity. They say he wants ta
  DEFB 80,73,84,89,46,243,173,131    ; muscle in on your patch, Boss."
  DEFB 6,129,184,211,228,83,122,130  ;
  DEFB 97,101,118,119,32,80,65,84    ;
  DEFB 67,72,44,240,164,21           ;
  DEFB 241,18,128,232,125,131,207,44   ; Message: "Dis could be tough, but
  DEFB 128,180,32,77,65,89,66,69       ; maybe we can buy off Rocco's mob. How
  DEFB 102,128,189,128,183,130,143,242 ; many grand ( if any) can you pay?"
  DEFB 250,39,83,126,46,241,206,109    ;
  DEFB 98,32,40,129,227,128,114,41     ;
  DEFB 128,189,97,130,193,63,20        ;
  DEFB 242,250,114,32,85,83,85,65  ; Message: "Rocco aint usually regarded as a
  DEFB 76,76,89,32,82,69,71,65     ; philanthropist, Boss. He don't give
  DEFB 82,68,69,68,128,133,106,32  ; nuthin' away."
  DEFB 80,72,73,76,65,78,84,72     ;
  DEFB 82,79,80,73,83,84,44,240    ;
  DEFB 164,46,241,184,129,38,39,84 ;
  DEFB 129,108,130,134,39,176,136  ;
  DEFB 241,206,109,131,193,44,240,164 ; Message: "How many thousand, Boss?"
  DEFB 63,20                          ;
  DEFB 244,38,32,77,85,83,84,125  ; Message: "You must be off ya rocker, Boss,
  DEFB 130,143,100,32,82,79,67,75 ; we've only got (v0) grand."
  DEFB 69,82,44,240,164,44,102,39 ;
  DEFB 86,69,116,103,4,98,21      ;
  DEFB 240,158,32,84,82,89,128,75  ; Message: "Better try again - how many
  DEFB 32,45,129,206,109,241,84,39 ; G's?"
  DEFB 83,63,20                    ;
  DEFB 241,90,44,240,164,44,102,39  ; Message: "Geez, Boss, we're gonna need
  DEFB 82,69,115,130,111,131,61,32  ; some ourselves. Ya wanna think again?"
  DEFB 79,85,82,83,69,76,86,69      ;
  DEFB 83,46,244,22,131,223,131,177 ;
  DEFB 128,75,63,20                 ;
  DEFB 242,146,44,240,164,44,102,39 ; Message: "Okay, Boss, we'll see if it
  DEFB 76,76,32,83,69,69,129,227    ; works."
  DEFB 110,32,87,79,82,75,83,21     ;
  DEFB 243,189,117,102,128,189,128,183 ; Message: "This year we can buy or sell
  DEFB 130,160,131,35,120,107,4,98     ; clients for (v0) grand each."
  DEFB 177,45                          ;
  DEFB 243,147,105,111,132,13,39,130   ; Message: "The boys is workin' real
  DEFB 242,129,167,46,242,131,44,129   ; hard. Now, how many clients do we buy
  DEFB 206,109,120,124,102,128,183,129 ; from the syndicate?"
  DEFB 77,96,131,113,63,20             ;
  DEFB 32,40,243,147,32,80,82,73 ; Message: "( The price is right!)"
  DEFB 67,69,111,32,82,73,71,72  ;
  DEFB 84,33,41,20               ;
  DEFB 20                 ; Message: ""
  DEFB 241,206,109,124,102,128,183,129 ; Message: "How many do we buy from the
  DEFB 77,96,131,113,131,189,117,44    ; syndicate this year, Boss?"
  DEFB 240,164,63,20                   ;
  DEFB 11,236,11,213,21   ; Message: "How many do we buy from the syndicate
                          ; this year, Boss? ( The price is right!)."
  DEFB 242,70,132,6,39,84,131,235   ; Message: "Minuses won't wash here, Mugsy.
  DEFB 129,192,44,242,92,46,241,206 ; How many do we buy?"
  DEFB 109,124,102,128,183,63,20    ;
  DEFB 240,237,44,240,164,44,97,129 ; Message: "Cripes, Boss, you gotta be outa
  DEFB 132,125,130,186,100,32,77,73 ; ya mind, we aint made of money."
  DEFB 78,68,44,102,114,130,44,104  ;
  DEFB 32,77,79,78,69,89,21         ;
  DEFB 241,206,109,124,100,131,223,131 ; Message: "How many do ya wanna sell?"
  DEFB 35,63,20                        ;
  DEFB 11,245,11,143,21   ; Message: "How many do ya wanna sell? ( The price is
                          ; right!)."
  DEFB 241,90,44,240,164,44,102,39   ; Message: "Geez, Boss, we've only got
  DEFB 86,69,116,103,4,128,243,46    ; (v0) customers. If the boys think you
  DEFB 241,227,96,105,131,177,97,131 ; wanna make a fast buck and then skip,
  DEFB 223,130,48,106,32,70,65,83    ; you could be takin' an unexpected ride!"
  DEFB 84,32,66,85,67,75,108,32      ;
  DEFB 84,72,69,78,32,83,75,73       ;
  DEFB 80,44,97,128,232,125,131,125  ;
  DEFB 39,128,95,32,85,78,69,88      ;
  DEFB 80,69,67,84,69,68,130,246     ;
  DEFB 33,20                         ;
  DEFB 240,252,96,32,77,73,78,85 ; Message: "Cut the minus garbage, Mugsy!"
  DEFB 83,32,71,65,82,66,65,71   ;
  DEFB 69,44,242,92,33,20        ;
  DEFB 241,243,39,32,74,69,76,76     ; Message: "Jumpin' jellyfish, Boss,- how
  DEFB 89,70,73,83,72,44,240,164     ; do ya expect us ta survive if ya sell
  DEFB 44,45,129,206,124,100,32,69   ; all our clients to the syndicate?"
  DEFB 88,80,69,67,84,131,215,122    ;
  DEFB 211,107,69,129,227,100,131,35 ;
  DEFB 128,92,130,180,120,112,96,131 ;
  DEFB 113,63,20                     ;
  DEFB 240,133,97,130,5,44,242,92    ; Message: "As you know, Mugsy, that means
  DEFB 44,113,130,62,102,114,103,130 ; we aint got nuthin' left."
  DEFB 134,39,178,19                 ;
  DEFB 240,133,97,130,5,44,240,164    ; Message: "As you know, Boss, that
  DEFB 44,113,32,76,69,65,86,69       ; leaves (v0) thousand bucks in the safe.
  DEFB 83,4,131,193,128,175,101,96    ; How many grand are ya gonna give the
  DEFB 130,255,46,241,206,109,98,128  ; boys for artillery and ammo?"
  DEFB 130,100,115,129,108,96,105,107 ;
  DEFB 32,65,82,84,73,76,76,69        ;
  DEFB 82,89,108,32,65,77,77,79       ;
  DEFB 63,20                          ;
  DEFB 244,38,114,131,182,39,32,83  ; Message: "You aint thinkin' straight,
  DEFB 84,82,65,73,71,72,84,44      ; Boss. There's only (v0) grand left in the
  DEFB 240,164,46,243,168,39,83,116 ; safe."
  DEFB 4,98,130,19,101,96,178,255   ;
  DEFB 241,90,44,131,168,39,76,76    ; Message: "Geez, there'll be nuthin'
  DEFB 125,130,134,39,130,19,46,243  ; left. Tell me that again, Boss, I musta
  DEFB 130,123,113,128,75,44,240,164 ; misheard you."
  DEFB 44,241,224,130,103,32,77,73   ;
  DEFB 83,72,69,65,82,68,97,21       ;
  DEFB 240,252,96,130,115,44,32,83 ; Message: "Cut the negatives, sucker!"
  DEFB 85,67,75,69,82,33,20        ;
  DEFB 241,87,44,99,105,111,115,125 ; Message: "Gee, da boys is gonna be
  DEFB 32,72,79,80,80,73,78,39      ; hoppin' mad, Boss- you sure got guts!"
  DEFB 32,77,65,68,44,240,164,45    ;
  DEFB 97,131,103,103,32,71,85,84   ;
  DEFB 83,33,20                     ;
  DEFB 244,22,115,129,94,99,129,152 ; Message: "Ya gonna get da guys bumped
  DEFB 32,66,85,77,80,69,68,178     ; off."
  DEFB 143                          ;
  DEFB 244,25,44,240,164,44,129,253 ; Message: "Yeah, Boss, keep'em scared,
  DEFB 39,69,77,131,14,44,32,69     ; eh!"
  DEFB 72,33,20                     ;
  DEFB 240,237,44,240,164,44,131,173 ; Message: "Cripes, Boss, they could fight
  DEFB 128,232,32,70,73,71,72,84     ; a war with the hardware that'll buy."
  DEFB 106,32,87,65,82,32,87,73      ;
  DEFB 84,72,96,209,167,87,65,82     ;
  DEFB 69,113,39,76,76,176,183       ;
  DEFB 243,244,103,121,32,70,69,87  ; Message: "We got so few clients left that
  DEFB 120,130,19,113,32,83,81,85   ; squeezin' them aint gonna pay your moll's
  DEFB 69,69,90,73,78,39,131,164    ; hooch bills."
  DEFB 114,115,130,193,119,32,77,79 ;
  DEFB 76,76,39,83,32,72,79,79      ;
  DEFB 67,72,32,66,73,76,76,83      ;
  DEFB 21                           ;
  DEFB 243,244,103,4,120,101,130,111  ; Message: "We got (v0) clients in need
  DEFB 104,130,209,44,240,164,46,241  ; of protection, Boss. How many do we put
  DEFB 206,109,124,102,130,219,96,131 ; the squeeze on this year?"
  DEFB 74,118,131,189,117,63,20       ;
  DEFB 241,62,96,130,115,44,242,92    ; Message: "Forget the negatives, Mugsy-
  DEFB 45,129,249,131,130,123,129,206 ; just tell me how many customers to lean
  DEFB 109,128,243,112,32,76,69,65    ; on this year."
  DEFB 78,118,131,189,117,21          ;
  DEFB 240,164,44,131,168,39,83,116 ; Message: "Boss, there's only (v0)
  DEFB 4,120,44,108,99,129,152,129  ; clients, and da guys gotta make an honest
  DEFB 132,130,48,128,95,32,72,79   ; livin'........ How many clients, Mugsy?"
  DEFB 78,69,83,84,32,76,73,86      ;
  DEFB 73,78,39,46,46,46,46,46      ;
  DEFB 46,46,46,241,206,109,120,44  ;
  DEFB 242,92,63,20                 ;
  DEFB 244,38,131,103,129,38,39,84 ; Message: "You sure don't dig da protection
  DEFB 129,15,99,130,209,32,82,65  ; racket, - do ya, Boss?"
  DEFB 67,75,69,84,44,32,45,124    ;
  DEFB 100,44,240,164,63,20        ;
  DEFB 240,180,102,39,86,69,116,103 ; Message: "But we've only got (v0) grand."
  DEFB 4,98,21                      ; (only reached through the random choice
                                    ; at 52074)
  DEFB 241,174,100,32,76,79,83,84 ; Message: "Have ya lost ya marbles, Mugsy?
  DEFB 100,32,77,65,82,66,76,69   ; We've only $(v0) thousand left." (only
  DEFB 83,44,242,92,63,243,244,39 ; reached through the random choice at 52074)
  DEFB 86,69,116,1,131,193,178,19 ;
  DEFB 240,252,96,32,75,73,68,68  ; Message: "Cut the kiddin', Boss. You know
  DEFB 73,78,39,44,240,164,46,244 ; there's only (v0) grand in the safe." (only
  DEFB 38,130,5,131,168,39,83,116 ; reached through the random choice at 52074)
  DEFB 4,98,101,96,178,255        ;
  DEFB 10,3,11,181,11,190,11,220 ; Message: a random choice of the messages at
  DEFB 20                        ; 52001 or 52012 or 52044 (30 or 63 or 68
                                 ; characters)
  DEFB 243,251,132,19,129,2,44,240  ; Message: "What wuz dat, Boss? I could've
  DEFB 164,63,241,224,128,232,39,86 ; swore you said (v0)."
  DEFB 69,32,83,87,79,82,69,97      ;
  DEFB 32,83,65,73,68,4,21          ;
  DEFB 241,142,32,78,79,79,83,44   ; Message: "Great noos, Boss!...... I set up
  DEFB 240,164,33,46,46,46,46,46   ; this deal wit' Nick the Greek. He's gonna
  DEFB 46,241,224,32,83,69,84,131  ; lend you the other (v0) grand at only (v1)
  DEFB 212,131,189,32,68,69,65,76  ; percent interest."
  DEFB 132,3,39,242,124,96,241,147 ;
  DEFB 46,241,184,39,83,115,32,76  ;
  DEFB 69,78,68,97,96,130,175,4    ;
  DEFB 98,32,65,84,116,4,32,80     ;
  DEFB 69,82,67,69,78,84,32,73     ;
  DEFB 78,84,69,82,69,83,84,21     ;
  DEFB 243,239,130,183,44,240,164,44 ; Message: "Watch out, Boss, the boys aint
  DEFB 96,105,114,115,32,76,73,75    ; gonna like workin' that hard."
  DEFB 69,132,13,39,113,177,167      ;
  DEFB 242,186,97,4,98,44,129,206   ; Message: "Outa you (v0) grand, how much
  DEFB 130,88,128,130,97,210,222,71 ; are you putting aside for the annual
  DEFB 32,65,83,73,68,69,107,96     ; kickback to the cops?"
  DEFB 32,65,78,78,85,65,76,32      ;
  DEFB 75,73,67,75,66,65,67,75      ;
  DEFB 112,96,127,63,20             ;
  DEFB 241,227,129,2,130,62,97,131    ; Message: "If dat means you want the
  DEFB 228,96,127,112,130,193,131,215 ; cops to pay us, forget it. How much?"
  DEFB 44,129,62,110,46,241,206,130   ;
  DEFB 88,63,20                       ;
  DEFB 240,168,128,130,97,131,14,104 ; Message: "Boy are you scared of da cops!
  DEFB 99,127,33,243,247,131,173,39  ; Well they're gonna get a dissy dis
  DEFB 82,69,115,129,94,106,32,68    ; year'cos there aint no funds left. ( Ya
  DEFB 73,83,83,89,129,18,117,39     ; stoopid wally )."
  DEFB 67,79,83,131,168,114,130,128  ;
  DEFB 32,70,85,78,68,83,130,19      ;
  DEFB 46,32,40,244,22,131,86,32     ;
  DEFB 87,65,76,76,89,32,41,21       ;
  DEFB 241,90,44,240,164,44,97,131  ; Message: "Geez, Boss, you sure are scared
  DEFB 103,128,130,131,14,104,32,84 ; of these cops. But you musta forgot you
  DEFB 72,69,83,69,127,46,240,180   ; only have (v0) grand...... Anyway, I
  DEFB 97,130,103,32,70,79,82,71    ; guess you want I should let da cops have
  DEFB 79,84,97,116,129,174,4,98    ; the whole lot. ( Ya stoopid jerk )."
  DEFB 46,46,46,46,46,46,240,117    ;
  DEFB 44,241,224,32,71,85,69,83    ;
  DEFB 83,97,131,228,241,224,32,83  ;
  DEFB 72,79,85,76,68,130,23,99     ;
  DEFB 127,129,174,96,32,87,72,79   ;
  DEFB 76,69,32,76,79,84,46,32      ;
  DEFB 40,244,22,131,86,32,74,69    ;
  DEFB 82,75,32,41,21               ;
  DEFB 243,6,44,240,164,44,96,132 ; Message: "Say, Boss, the word is you're
  DEFB 9,111,97,39,82,69,129,34   ; doin' okay!" (only reached through the
  DEFB 39,130,146,33,20           ; random choice at 52535)
  DEFB 243,173,39,82,69,131,9,39   ; Message: "They're sayin' you're doin' a
  DEFB 97,39,82,69,129,34,39,106   ; good job here, Boss." (only reached
  DEFB 129,125,32,74,79,66,129,192 ; through the random choice at 52535)
  DEFB 44,240,164,21               ;
  DEFB 243,147,240,192,130,84,129,174 ; Message: "The Chicago mobs have heard
  DEFB 129,187,104,97,130,131,46,243  ; of you now. They think you might be
  DEFB 173,131,177,97,32,77,73,71     ; another Scarface." (only reached
  DEFB 72,84,125,128,101,243,20,21    ; through the random choice at 52535)
  DEFB 10,3,11,173,11,192,11,218 ; Message: a random choice of the messages at
  DEFB 20                        ; 52454 or 52475 or 52503 (41 or 50 or 81
                                 ; characters)
  DEFB 244,38,114,129,34,39,131,204  ; Message: "You aint doin' too good,
  DEFB 129,125,44,242,92,33,243,147  ; Mugsy! The organisation is gettin' a bad
  DEFB 130,163,111,129,97,39,106,128 ; reputation an some of da boys is
  DEFB 140,32,82,69,80,85,84,65      ; thinkin' of gettin' out while they can."
  DEFB 84,73,79,78,128,95,131,61     ;
  DEFB 104,99,105,111,131,182,39,104 ;
  DEFB 129,97,39,130,183,32,87,72    ;
  DEFB 73,76,69,131,173,176,189      ;
  DEFB 242,146,44,242,92,44,123,128 ; Message: "Okay, Mugsy, me an the (v0)
  DEFB 95,96,4,105,44,20            ; boys,"
  DEFB 243,147,240,143,20 ; Message: "The Bahamas" (only reached through the
                          ; random choice at 52631)
  DEFB 242,9,243,218,20   ; Message: "Las Vegas" (only reached through the
                          ; random choice at 52631)
  DEFB 129,171,129,156,32,69,78,79  ; Message: "has had enough of your crazy
  DEFB 85,71,72,104,119,32,67,82    ; mob for the last (v0) years. So we're off
  DEFB 65,90,89,126,107,96,130,12   ; ta find some better rackets in [The
  DEFB 4,132,33,46,243,58,102,39    ; Bahamas/Florida/Disneyland/Hawaii/Las
  DEFB 82,69,130,143,122,32,70,73   ; Vegas]."
  DEFB 78,68,131,61,128,158,130,235 ;
  DEFB 101,10,5,11,195,241,52,241   ;
  DEFB 21,241,178,11,192,21         ;
  DEFB 243,54,32,45,243,54,20 ; Message: "Sing - Sing" (only reached through
                              ; the random choice at 52705)
  DEFB 243,3,242,228,20   ; Message: "San Quentin" (only reached through the
                          ; random choice at 52705)
  DEFB 129,171,32,68,79,78,69,32   ; Message: "has done pretty good in the mob
  DEFB 80,82,69,84,84,89,129,125   ; for the last (v0) years. So we're goin' ta
  DEFB 101,96,126,107,96,130,12,4  ; invest in some new rackets in
  DEFB 132,33,46,243,58,102,39,82  ; [Alcatraz/Sing - Sing/San
  DEFB 69,129,116,39,122,32,73,78  ; Quentin/Siberia]."
  DEFB 86,69,83,84,101,131,61,32   ;
  DEFB 78,69,87,130,235,101,10,4   ;
  DEFB 240,84,11,186,11,191,243,47 ;
  DEFB 21                          ;
  DEFB 244,38,32,87,69,82,69,5   ; Message: "You were (msg0). You scored (v1)%.
  DEFB 46,244,38,32,83,67,79,82  ; Hows about another game, Mugsy?"
  DEFB 69,68,4,37,46,241,216,128 ;
  DEFB 70,128,101,32,71,65,77,69 ;
  DEFB 44,242,92,63,20           ;
  DEFB 243,251,132,19,129,2,44,240 ; Message: "What wuz dat, Boss? I missed it"
  DEFB 164,63,241,224,210,77,69,68 ; (only reached through the random choice at
  DEFB 110,20                      ; 52861)
  DEFB 241,236,39,83,130,146,44,240 ; Message: "It's okay, Boss - this line
  DEFB 164,32,45,131,189,32,76,73   ; aint tapped. Let's have the answer" (only
  DEFB 78,69,114,32,84,65,80,80     ; reached through the random choice at
  DEFB 69,68,46,242,23,39,83,129    ; 52861)
  DEFB 174,96,224,108               ;
  DEFB 10,2,11,200,11,216,21 ; Message: a random choice of the messages at
                             ; 52807 or 52825 (31 or 62 characters)
  DEFB 241,90,44,240,164,44,129,68  ; Message: "Geez, Boss, fractions makes my
  DEFB 210,48,83,130,108,32,72,69   ; head hurt. Gimme a good answer." (only
  DEFB 65,68,129,220,46,241,103,106 ; reached through the random choice at
  DEFB 129,125,176,108              ; 52957)
  DEFB 240,237,44,240,164,44,129,38 ; Message: "Cripes, Boss, don't make wit'
  DEFB 39,84,130,48,132,3,39,99     ; da fractions. I never did learn to dig
  DEFB 129,68,46,241,224,32,78,69   ; them. Let's have it in good numbers!"
  DEFB 86,69,82,129,12,32,76,69     ; (only reached through the random choice
  DEFB 65,82,78,112,129,15,131,164  ; at 52957)
  DEFB 46,242,23,39,83,129,174,110  ;
  DEFB 101,129,125,32,78,85,77,66   ;
  DEFB 69,82,83,33,20               ;
  DEFB 10,2,11,165,11,191,20 ; Message: a random choice of the messages at
                             ; 52868 or 52896 (62 or 105 characters)
  DEFB 241,38,39,84,129,94,32,83  ; Message: "Don't get smart wit' me, Mugsy!
  DEFB 77,65,82,84,132,3,39,123   ; Just " yeah" or " nope" is fine."
  DEFB 44,242,92,33,241,249,32,34 ;
  DEFB 132,25,34,130,160,32,34,32 ;
  DEFB 78,79,80,69,34,111,32,70   ;
  DEFB 73,78,69,21                ;
  DEFB 241,2,131,232,130,242,131,86   ; Message: "Dat was real stoopid, Boss!
  DEFB 44,240,164,33,241,227,119,105  ; If your boys heard about it you wud get
  DEFB 129,187,128,70,110,97,32,87    ; more laughs than Jack Benny. However,
  DEFB 85,68,129,94,32,77,79,82       ; for one crummy grand I guarantee ta
  DEFB 69,32,76,65,85,71,72,83        ; keep my trap shut." (only reached
  DEFB 131,139,241,239,240,153,46,241 ; through the random choice at 53164)
  DEFB 209,44,107,130,153,32,67,82    ;
  DEFB 85,77,77,89,98,241,224,32      ;
  DEFB 71,85,65,82,65,78,84,69        ;
  DEFB 69,122,129,253,130,108,32,84   ;
  DEFB 82,65,80,32,83,72,85,84        ;
  DEFB 21                             ;
  DEFB 240,237,44,240,164,44,211,61  ; Message: "Cripes, Boss, sometimes you're
  DEFB 84,73,77,69,83,97,39,82       ; real dumb. But for a lousy grand I can
  DEFB 69,130,242,129,41,46,240,180  ; be persuaded not to spill da beans about
  DEFB 107,106,130,34,98,241,224,128 ; your stoopidity." (only reached through
  DEFB 189,125,32,80,69,82,83,85     ; the random choice at 53164)
  DEFB 65,68,69,68,32,78,79,84       ;
  DEFB 112,32,83,80,73,76,76,99      ;
  DEFB 32,66,69,65,78,83,128,70      ;
  DEFB 119,179,93                    ;
  DEFB 10,2,11,98,11,185,20 ; Message: a random choice of the messages at 53008
                            ; or 53097 (160 or 127 characters)
  DEFB 244,41,131,93,32,84,65,75   ; Message: "Your stoopidity takes my breath
  DEFB 69,83,130,108,32,66,82,69   ; away, Mugsy. But for a mere (v0) grand I
  DEFB 65,84,72,128,136,44,242,92  ; won't tell nobody." (only reached through
  DEFB 46,240,180,107,106,32,77,69 ; the random choice at 53256)
  DEFB 82,69,4,98,241,224,132,6    ;
  DEFB 39,84,131,130,32,78,79,66   ;
  DEFB 79,68,89,21                 ;
  DEFB 242,92,33,244,38,39,82,69    ; Message: "Mugsy! You're so dumb. It's
  DEFB 121,129,41,46,241,236,39,83  ; gonna cost you (v0) G's ta make me forget
  DEFB 115,128,228,97,4,241,84,39   ; it." (only reached through the random
  DEFB 83,122,130,48,123,129,62,110 ; choice at 53256)
  DEFB 21                           ;
  DEFB 10,2,11,169,11,219,20 ; Message: a random choice of the messages at
                             ; 53171 or 53223 (91 or 73 characters)
  DEFB 241,87,122,44,240,164,33,242 ; Message: "Gee ta, Boss! Now tell
  DEFB 131,131,130,123,46,46,46,46  ; me........."
  DEFB 46,46,46,46,21               ;
  DEFB 227,14             ; Message: "scared"
  DEFB 32,76,79,89,65,76,20 ; Message: "loyal"
  DEFB 108,20             ; Message: "and"
  DEFB 224,180            ; Message: "but"
  DEFB 226,131            ; Message: "now"
  DEFB 224,75             ; Message: "again"
  DEFB 226,34             ; Message: "lousy"
  DEFB 130,242,224,140    ; Message: "real bad"
  DEFB 211,134,66,76,69,20 ; Message: "terrible"
  DEFB 32,71,72,65,83,84,76,89 ; Message: "ghastly"
  DEFB 20                      ;
  DEFB 32,80,79,79,82,20  ; Message: "poor"
  DEFB 121,45,121,20      ; Message: "so- so"
  DEFB 32,70,65,73,82,20  ; Message: "fair"
  DEFB 225,125            ; Message: "good"
  DEFB 226,146            ; Message: "okay"
  DEFB 225,142            ; Message: "great"
  DEFB 32,83,87,69,76,76,20 ; Message: "swell"
  DEFB 211,134            ; Message: "terrificld(hl),3  +ld(regenfl)... (runs
                          ; on: see the bugs page)"

; Leftover assembler source
;
; Fragments of the original Z80 source code, left in memory by the assembler.
; See the trivia page.
  DEFB 70,73,67,9,76,68,9,40,72,76,41,44,51,32,32,43,16,9,76,68,9,40,82,69,71,69,78,70,76,41,44,65 ; "FIC.LD.(HL),3
                                                                                                   ; +..LD.(REGENFL),A"
  DEFB 32,42,43,11,9,74,80,9,67,79,77,69,66,75,32,52,43,2,59,32,62,43,12,72,73,84,79,75,9,69,81,85 ; "
                                                                                                   ; *+..JP.COMEBK
                                                                                                   ; 4+.;
                                                                                                   ; >+.HITOK.EQU"
  DEFB 9,36,32,72,43,14,9,76,68,9,65,44,40,72,73,84,83,84,41,32,82,43,7,9,65,78,68,9,65,32,92,43 ; ".$
                                                                                                 ; H+..LD.A,(HITST)
                                                                                                 ; R+..AND.A
                                                                                                 ; \+"
  DEFB 14,9,74,82,9,78,90 ; "..JR.NZ"

; Interrupt jump
;
; The IM2 vector table at 53504 is filled with 208, so every interrupt jumps
; here (53456=208*257). The address is set to ISR1 or ISR2 when interrupts are
; enabled. Note that these three bytes sit in the middle of leftover assembler
; source text (see the trivia page).
INTJUMP:
  JP 0                    ; Jump back

; Leftover assembler source
  DEFB 84,68,69,68,32,102,43,2,59,32,112,43,15,9,76,68,9,65,44,40,72,84,83,84,65,84,41,32,122,43,7,9 ; "TDED f+.;
                                                                                                     ; p+..LD.A,(HTSTAT)
                                                                                                     ; z+.."
  DEFB 65,78,68,9,65,32,132,43,14,9,74,80,9 ; "AND.A .+..JP."

; Interrupt vector table
;
; 257 bytes of 208 (only 256 are needed), so that an IM2 interrupt with I=209
; always jumps to INTJUMP. The table is placed over more leftover source code.
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208,208,208,208,208,208,208,208
  DEFB 208

; Leftover assembler source
  DEFB 72,65,80,69,51,41,44,65,32,66,44,9,9,76,68,9,65,44,49,54,32,76,44,14,9,76,68,9,66,67,44,68 ; "HAPE3),A
                                                                                                  ; B,..LD.A,16
                                                                                                  ; L,..LD.BC,D"

; Picture: the Partridge Club (compressed)
;
; Drawn by DRAWCPIC for the bar-room animation.
  DEFB 251,5,0,123,6,4,3,4
  DEFB 4,128,16,148,66,12,136,64
  DEFB 209,10,97,72,44,168,145,8
  DEFB 11,54,134,164,136,162,139,34
  DEFB 141,16,161,34,20,36,66,132
  DEFB 136,80,145,10,225,16,14,73
  DEFB 100,219,104,33,90,75,197,25
  DEFB 161,185,171,96,37,247,149,152
  DEFB 50,20,67,184,78,67,17,234
  DEFB 198,162,37,89,85,200,137,112
  DEFB 229,87,146,33,66,232,133,11
  DEFB 161,20,46,132,80,191,38,114
  DEFB 30,98,72,137,9,161,34,20
  DEFB 36,70,136,69,21,16,138,130
  DEFB 173,118,125,74,45,105,15,102
  DEFB 66,77,56,244,56,164,46,136
  DEFB 137,16,145,50,18,38,69,163
  DEFB 56,163,175,93,154,213,140,237
  DEFB 10,137,134,117,46,48,229,208
  DEFB 145,50,18,38,66,68,216,156
  DEFB 226,145,168,231,161,35,159,6
  DEFB 41,94,197,75,216,169,19,131
  DEFB 163,51,175,250,58,82,28,218
  DEFB 2,116,36,75,57,69,73,93
  DEFB 11,44,96,213,132,136,128,145
  DEFB 145,54,157,54,76,110,212,6
  DEFB 68,43,12,231,67,142,53,99
  DEFB 23,128,252,225,219,126,66,59
  DEFB 24,139,125,211,19,46,187,33
  DEFB 190,27,154,199,15,94,232,156
  DEFB 116,80,223,209,8,242,162,98
  DEFB 148,78,8,137,243,10,59,218
  DEFB 76,4,30,172,56,122,242,127
  DEFB 249,157,57,68,57,131,168,66
  DEFB 68,40,72,136,16,37,123,29
  DEFB 0,74,29,42,18,33,66,68
  DEFB 40,140,11,240,229,208,146,29
  DEFB 66,18,36,254,249,44,169,87
  DEFB 141,151,145,200,172,196,37,201
  DEFB 16,172,196,34,120,144,245,228
  DEFB 66,132,136,95,254,131,249,225
  DEFB 195,87,145,207,172,199,23,47
  DEFB 98,229,206,188,142,188,100,7
  DEFB 191,255,94,116,220,179,219,8
  DEFB 208,145,56,114,212,215,97,127
  DEFB 246,176,229,214,242,117,168,86
  DEFB 137,144,151,242,172,191,251,53
  DEFB 172,14,131,240,19,129,18,33
  DEFB 255,126,183,37,236,108,6,254
  DEFB 184,71,161,107,47,188,47,98
  DEFB 213,236,90,189,139,151,178,37
  DEFB 72,233,28,27,232,86,73,81
  DEFB 170,71,3,68,227,225,243,235
  DEFB 171,157,97,36,16,192,109,47
  DEFB 233,109,196,75,137,96,174,17
  DEFB 147,92,225,171,89,13,220,137
  DEFB 121,17,47,36,66,52,8,217
  DEFB 26,23,249,182,55,253,55,130
  DEFB 125,119,67,125,215,115,92,196
  DEFB 43,197,115,5,17,46,21,236
  DEFB 109,11,20,223,210,10,59,216
  DEFB 34,51,94,109,141,197,221,18
  DEFB 22,19,228,109,183,116,102,134
  DEFB 254,136,65,60,213,161,13,176
  DEFB 140,56,175,200,40,207,101,16
  DEFB 67,127,68,35,150,189,141,205
  DEFB 17,19,163,52,44,94,189,151
  DEFB 221,87,55,165,180,161,61,88
  DEFB 179,174,153,2,180,230,144,187
  DEFB 22,1,114,20,33,190,20,47
  DEFB 191,161,110,169,139,70,75,133
  DEFB 123,116,123,161,191,107,184,34
  DEFB 37,228,111,134,226,136,117,177
  DEFB 191,174,17,53,92,225,235,132
  DEFB 33,123,23,34,84,194,136,64
  DEFB 82,153,27,95,113,71,92,161
  DEFB 235,149,123,23,243,11,240,12
  DEFB 81,13,90,18,228,72,8,136
  DEFB 116,224,136,81,8,255,217,120
  DEFB 236,174,16,253,174,136,86,24
  DEFB 66,214,47,199,38,46,2,220
  DEFB 192,53,193,196,75,141,20,165
  DEFB 124,188,9,16,130,165,66,133
  DEFB 238,176,67,138,12,151,40,146
  DEFB 174,18,212,47,182,64,58,228
  DEFB 232,132,127,254,164,45,89,46
  DEFB 53,176,164,46,132,137,23,186
  DEFB 225,90,43,24,61,24,129,36
  DEFB 137,175,21,140,28,184,96,224
  DEFB 177,67,183,42,17,216,192,41
  DEFB 161,234,226,105,34,232,163,164
  DEFB 232,204,48,25,26,46,112,210
  DEFB 164,209,96,212,172,6,176,181
  DEFB 138,226,94,248,83,28,55,123
  DEFB 145,174,53,196,136,94,180,57
  DEFB 230,197,222,172,57,105,47,20
  DEFB 203,173,117,71,192,117,73,119
  DEFB 9,50,17,246,4,184,117,138
  DEFB 33,5,66,254,157,151,141,22
  DEFB 185,94,213,4,66,75,13,64
  DEFB 140,110,249,56,14,182,66,110
  DEFB 77,198,125,81,12,114,198,88
  DEFB 43,201,25,130,34,113,155,68
  DEFB 233,197,9,46,16,213,194,168
  DEFB 70,49,115,170,117,236,145,129
  DEFB 117,14,201,138,211,8,94,248
  DEFB 89,16,130,161,125,44,136,124
  DEFB 92,132,103,113,201,72,124,164
  DEFB 61,17,46,37,204,133,208,142
  DEFB 152,81,141,12,217,133,12,110
  DEFB 40,46,230,34,196,216,220,141
  DEFB 107,165,100,102,8,189,128,75
  DEFB 195,215,158,245,15,90,107,20
  DEFB 49,105,173,117,204,188,145,185
  DEFB 18,69,15,142,200,122,8,105
  DEFB 136,87,8,114,225,13,49,191
  DEFB 39,5,174,243,194,94,137,200
  DEFB 241,41,24,104,50,245,35,198
  DEFB 177,217,92,203,188,28,22,183
  DEFB 91,153,119,102,139,108,45,81
  DEFB 240,29,162,28,68,184,209,74
  DEFB 87,203,146,16,42,84,40,94
  DEFB 235,4,59,41,18,174,18,212
  DEFB 47,134,94,136,64,145,56,34
  DEFB 99,2,94,197,232,152,192,76
  DEFB 193,19,24,0,58,40,33,18
  DEFB 35,113,98,99,104,132,103,17
  DEFB 72,16,201,6,37,12,125,11
  DEFB 34,17,157,246,240,3,39,68
  DEFB 32,196,225,106,140,181,115,24
  DEFB 9,152,46,99,0,9,93,4
  DEFB 67,10,51,3,1,88,227,4
  DEFB 186,8,102,8,230,137,69,16
  DEFB 128,162,17,156,68,224,40,156
  DEFB 5,19,128,164,151,164,19,0
  DEFB 4,239,98,102,9,157,17,1
  DEFB 34,16,20,66,2,136,70,113
  DEFB 19,128,162,112,20,78,6,68
  DEFB 144,65,145,55,119,128,68,153
  DEFB 58,225,10,94,197,66,188,74
  DEFB 99,137,162,169,93,73,173,48
  DEFB 245,236,94,217,97,202,98,169
  DEFB 225,232,157,96,174,42,205,238
  DEFB 70,184,215,18,17,66,250,161
  DEFB 219,149,8,236,96,20,208,245
  DEFB 113,52,145,116,81,210,116,102
  DEFB 24,12,141,23,56,110,185,49
  DEFB 112,22,230,1,218,123,132,153
  DEFB 8,225,50,20,68,44,40,219
  DEFB 171,68,227,187,20,46,9,89
  DEFB 46,53,176,164,46,132,137,23
  DEFB 186,225,90,43,24,61,24,129
  DEFB 36,137,175,21,140,28,184,122
  DEFB 60,0,201,209,8,49,56,66
  DEFB 242,33,94,68,44,226,156,162
  DEFB 172,160,195,87,8,128,113,123
  DEFB 120,114,171,170,147,87,125,34
  DEFB 90,64,104,73,97,17,22,163
  DEFB 48,52,102,70,188,136,215,145
  DEFB 32,72,132,161,21,194,28,184
  DEFB 67,151,14,29,18,17,93,167
  DEFB 66,40,89,114,226,195,239,93
  DEFB 233,194,159,43,132,175,20,134
  DEFB 68,143,18,143,26,141,215,170
  DEFB 220,34,214,2,66,249,175,121
  DEFB 16,7,18,236,90,229,166,144
  DEFB 210,10,167,92,235,201,33,46
  DEFB 53,152,5,206,30,184,67,150
  DEFB 162,23,68,32,72,93,115,135
  DEFB 175,116,78,4,136,81,138,213
  DEFB 68,224,121,238,27,237,97,203
  DEFB 199,146,32,122,228,68,224,40
  DEFB 213,16,145,175,36,36,68,188
  DEFB 136,151,26,199,93,116,67,120
  DEFB 38,94,71,48,38,12,159,64
  DEFB 179,72,66,184,136,87,138,231
  DEFB 15,92,226,28,185,194,151,187
  DEFB 31,204,6,161,101,89,4,132
  DEFB 88,133,138,208,177,98,22,67
  DEFB 121,45,89,111,88,232,145,114
  DEFB 23,35,175,166,80,36,166,132
  DEFB 116,225,192,81,98,200,80,145
  DEFB 42,44,185,197,35,81,74,66
  DEFB 68,75,73,32,129,21,33,116
  DEFB 36,114,64,69,8,157,41,156
  DEFB 168,17,198,35,84,88,211,175
  DEFB 16,1,127,43,86,75,75,155
  DEFB 234,16,235,184,254,47,173,218
  DEFB 1,9,247,90,80,159,66,148
  DEFB 145,174,152,43,158,173,161,44
  DEFB 163,41,53,130,168,88,152,136
  DEFB 74,231,9,174,0,174,75,174
  DEFB 120,174,145,174,166,174,252,173
  DEFB 245,167,202,165,0,144,24,141
  DEFB 85,140,200,129,33,128,50,128
  DEFB 64,128,96,128,120,128,125,128
  DEFB 134,128,161,128,204,128,230,128
  DEFB 244,127,12,126,230,120,16,114
  DEFB 246,111,255,110,154,107,29,106
  DEFB 94,106,166,94,203,92,209,89
  DEFB 0,51,140,49,114,49,181,47
  DEFB 212,45,141,44,86,44,136,44
  DEFB 156,44,198,43,98,43,210,40
  DEFB 142,38,90,38,94,38,202,38
  DEFB 206,33,89,33,201,30,92,30
  DEFB 204,25,142,21,213,15,95,15
  DEFB 207,11,91,11,203,4,136,0
  DEFB 128,0,167,40,132,17,32,128
  DEFB 66,36,131,9,130,4,68,36
  DEFB 131,9,130,4,68,1,33,132
  DEFB 9,224,130,11,32,225,33,128
  DEFB 9,224,33,14,224,12,224,31
  DEFB 31,31,31,31,31,0,227,19
  DEFB 65,19,224,1,224,4,227,18
  DEFB 224,8,226,18,224,8,226,64
  DEFB 5,224,31,28,224,1,224,27
  DEFB 224,1,224,27,224,1,224,31
  DEFB 224,15,64,1,65,9,224,31
  DEFB 31,31,200,36,225,196,225,40
  DEFB 200,36,232,40,200,36,232,33
  DEFB 0,37,200,36,232,40,200,33
  DEFB 225,32,232,33,225,36,200,224
  DEFB 0,235,32,0,225,36,199,247
  DEFB 199,247,198,248,198,255,255,242
  DEFB 99,251,99,233,67,228,67,228
  DEFB 99,233,65,224,64,228,67,228
  DEFB 98,234,66,229,67,228,98,226
  DEFB 192,226,219,227,192,230,192,230
  DEFB 192,228,99,229,192,230,192,230
  DEFB 192,228,97,192,96,225,69,229
  DEFB 192,230,192,228,97,192,96,225
  DEFB 69,229,192,230,192,229,96,192
  DEFB 97,224,73,225,192,226,65,225
  DEFB 192,229,96,192,97,255,255,224
  DEFB 71,23,71,23,71,23,71,23
  DEFB 72,22,72,22,71,23,71,23
  DEFB 70,24,70,63,63,63,63,63
  DEFB 63,63,63

; Picture: the street (compressed)
;
; Drawn by DRAWCPIC for the getaway car animation.
  DEFB 32,6,4,149,6,4,4,4
  DEFB 4,166,17,19,39,16,12,198
  DEFB 36,84,252,226,72,20,165,18
  DEFB 3,85,88,212,46,52,48,132
  DEFB 34,34,68,18,83,67,196,19
  DEFB 78,94,229,194,72,69,10,2
  DEFB 92,244,98,94,30,61,62,44
  DEFB 17,21,227,66,34,20,68,33
  DEFB 72,116,131,66,227,67,67,82
  DEFB 100,166,72,240,208,77,162,76
  DEFB 108,117,97,95,220,80,93,193
  DEFB 35,237,15,33,194,192,40,66
  DEFB 76,172,2,214,192,93,203,2
  DEFB 212,50,213,193,13,66,34,45
  DEFB 41,37,13,5,201,75,1,174
  DEFB 3,220,224,26,224,42,44,132
  DEFB 2,137,216,202,224,26,224,42
  DEFB 224,44,174,1,208,157,238,1
  DEFB 218,32,29,238,174,1,222,224
  DEFB 60,201,2,218,226,76,101,12
  DEFB 33,200,79,0,98,68,97,66
  DEFB 35,79,88,32,115,66,88,213
  DEFB 175,181,0,28,213,191,48,47
  DEFB 81,82,28,124,175,34,200,50
  DEFB 93,142,34,216,18,63,115,79
  DEFB 2,200,255,143,68,10,34,7
  DEFB 220,205,205,142,163,214,221,194
  DEFB 220,28,77,220,252,142,202,232
  DEFB 44,66,133,76,52,109,11,29
  DEFB 149,108,70,20,33,90,99,97
  DEFB 95,73,54,16,205,148,226,31
  DEFB 168,157,141,53,69,193,197,64
  DEFB 35,92,16,236,234,220,165,225
  DEFB 198,128,20,34,33,249,44,1
  DEFB 216,58,45,206,220,58,172,77
  DEFB 196,44,108,2,194,178,100,65
  DEFB 2,95,55,94,68,107,88,64
  DEFB 245,131,247,41,214,74,42,45
  DEFB 207,216,248,237,193,196,61,194
  DEFB 196,29,194,216,221,207,94,26
  DEFB 45,142,66,244,33,202,229,195
  DEFB 12,70,48,64,165,226,72,33
  DEFB 174,26,4,207,220,66,29,109
  DEFB 68,17,174,66,37,130,28,193
  DEFB 168,94,210,32,148,45,245,131
  DEFB 90,242,228,33,90,64,149,239
  DEFB 242,116,84,97,66,34,69,225
  DEFB 94,226,229,174,47,245,83,156
  DEFB 77,196,42,44,141,196,221,204
  DEFB 196,221,207,196,253,205,196,234
  DEFB 221,207,196,252,165,200,218,205
  DEFB 205,196,216,205,99,142,196,189
  DEFB 206,196,221,207,220,224,117,225
  DEFB 248,71,196,28,67,216,44,132
  DEFB 142,220,60,68,220,42,60,142
  DEFB 170,198,176,44,107,1,212,160
  DEFB 36,34,33,194,221,46,220,28
  DEFB 76,220,253,193,196,184,236,142
  DEFB 194,224,131,23,9,249,48,128
  DEFB 36,34,37,194,208,44,48,3
  DEFB 49,68,18,68,161,92,228,83
  DEFB 213,99,54,23,180,241,239,51
  DEFB 131,119,66,35,151,4,90,223
  DEFB 254,64,194,37,226,74,87,237
  DEFB 152,70,37,206,252,181,132,195
  DEFB 3,180,117,226,92,101,196,203
  DEFB 63,9,53,65,239,223,60,30
  DEFB 67,87,30,253,18,242,28,138
  DEFB 51,80,50,229,238,41,14,136
  DEFB 51,80,82,224,229,238,66,229
  DEFB 238,70,229,207,13,5,34,205
  DEFB 26,30,66,81,239,80,17,239
  DEFB 211,23,218,35,6,30,245,15
  DEFB 30,253,227,9,49,129,239,222
  DEFB 128,148,38,42,70,34,109,176
  DEFB 224,111,247,0,55,112,79,107
  DEFB 76,220,224,36,68,74,228,97
  DEFB 88,55,138,244,46,92,240,192
  DEFB 100,47,92,240,181,225,155,36
  DEFB 65,94,36,65,1,78,197,207
  DEFB 14,94,20,65,209,66,219,75
  DEFB 223,50,220,237,194,200,184,237
  DEFB 207,196,252,79,140,247,35,132
  DEFB 243,241,82,36,33,245,16,5
  DEFB 226,49,69,80,117,239,90,34
  DEFB 37,226,94,85,226,94,101,226
  DEFB 93,36,93,44,93,52,93,60
  DEFB 93,68,93,76,93,84,94,66
  DEFB 54,250,64,238,201,72,194,194
  DEFB 64,67,63,23,35,77,22,149
  DEFB 244,35,75,199,65,236,75,3
  DEFB 235,147,21,161,68,64,224,52
  DEFB 46,92,240,228,46,216,52,46
  DEFB 15,47,1,141,37,88,178,84
  DEFB 45,68,50,237,110,141,35,196
  DEFB 29,171,3,66,69,129,94,226
  DEFB 237,79,4,94,34,48,226,189
  DEFB 197,12,43,2,37,212,178,80
  DEFB 34,176,237,101,45,70,50,176
  DEFB 245,101,43,1,66,28,100,140
  DEFB 216,145,96,53,129,46,67,72
  DEFB 53,85,244,181,207,9,41,102
  DEFB 19,129,96,18,243,70,50,253
  DEFB 51,128,77,50,226,93,110,4
  DEFB 227,83,194,32,34,229,225,214
  DEFB 242,32,37,238,210,213,226,94
  DEFB 197,206,2,72,112,37,227,72
  DEFB 33,32,98,207,18,6,42,21
  DEFB 225,225,115,85,226,34,66,34
  DEFB 20,148,66,20,135,97,11,14
  DEFB 92,240,229,207,180,224,68,65
  DEFB 74,20,65,1,68,20,161,99
  DEFB 197,78,68,164,1,66,21,193
  DEFB 15,92,16,197,193,10,69,108
  DEFB 34,94,33,239,99,161,30,241
  DEFB 28,36,88,98,210,84,45,46
  DEFB 200,193,238,199,0,55,116,65
  DEFB 7,57,112,213,107,55,141,176
  DEFB 3,39,29,243,56,30,255,145
  DEFB 0,53,164,65,238,178,48,29
  DEFB 173,3,209,22,5,208,80,69
  DEFB 226,34,218,34,45,100,4,200
  DEFB 66,64,164,51,161,113,94,194
  DEFB 144,131,56,66,141,12,4,94
  DEFB 34,45,49,229,175,92,21,143
  DEFB 70,245,238,66,21,195,15,220
  DEFB 252,46,45,21,243,8,21,3
  DEFB 31,21,245,240,144,213,225,66
  DEFB 35,20,70,33,80,66,98,198
  DEFB 178,20,97,68,253,194,66,28
  DEFB 41,236,240,194,44,134,12,35
  DEFB 238,112,130,52,79,2,208,210
  DEFB 61,41,3,238,237,54,1,45
  DEFB 23,180,142,113,45,25,116,66
  DEFB 26,116,65,27,116,65,28,100
  DEFB 65,7,66,226,245,207,243,176
  DEFB 4,68,94,36,36,49,52,66
  DEFB 34,68,16,67,72,5,68,194
  DEFB 181,230,42,67,71,68,16,36
  DEFB 46,46,7,66,21,226,68,17
  DEFB 203,237,89,144,194,228,164,92
  DEFB 32,213,193,12,92,240,229,239
  DEFB 198,193,82,34,6,94,254,190
  DEFB 224,116,196,36,88,33,92,90
  DEFB 226,196,143,5,45,206,29,88
  DEFB 254,177,94,33,214,192,62,152
  DEFB 34,45,111,33,218,192,45,67
  DEFB 33,233,213,2,192,20,33,94
  DEFB 20,34,200,194,64,28,76,36
  DEFB 1,212,194,77,76,15,94,34
  DEFB 20,65,46,232,110,66,21,194
  DEFB 68,18,240,29,174,214,50,192
  DEFB 20,33,94,20,34,214,196,34
  DEFB 34,92,226,34,221,143,36,2
  DEFB 47,94,244,47,94,253,108,33
  DEFB 222,225,96,90,49,49,53,65
  DEFB 94,52,158,123,43,3,211,34
  DEFB 37,18,109,204,94,34,52,65
  DEFB 19,116,47,232,104,38,4,202
  DEFB 213,226,35,68,17,95,66,254
  DEFB 169,25,142,232,194,3,209,17
  DEFB 2,194,210,92,78,208,112,78
  DEFB 155,7,49,92,80,96,76,172
  DEFB 12,36,22,19,39,20,229,238
  DEFB 67,6,50,17,97,232,176,64
  DEFB 62,168,222,190,242,62,83,23
  DEFB 19,117,230,42,92,16,245,225
  DEFB 66,34,36,65,2,229,49,81
  DEFB 55,95,9,49,85,174,41,94
  DEFB 228,79,3,229,15,49,241,55
  DEFB 48,129,40,220,229,242,99,7
  DEFB 67,33,19,147,6,18,110,56
  DEFB 162,62,29,15,16,2,114,132
  DEFB 79,16,245,236,13,94,36,65
  DEFB 3,224,196,70,48,245,194,92
  DEFB 224,244,78,216,100,47,68,37
  DEFB 227,94,36,33,218,49,16,218
  DEFB 213,237,66,245,206,33,70,208
  DEFB 253,163,212,34,30,33,40,92
  DEFB 17,0,206,96,92,37,227,146
  DEFB 18,61,145,112,62,1,8,16
  DEFB 243,31,16,14,57,99,66,197
  DEFB 236,47,92,240,245,166,34,88
  DEFB 66,69,173,15,92,34,37,226
  DEFB 94,101,226,34,90,37,101,15
  DEFB 2,220,96,36,142,3,72,32
  DEFB 20,66,34,68,52,34,33,70
  DEFB 84,102,33,68,34,20,66,33
  DEFB 68,36,36,33,70,68,36,68
  DEFB 17,255,16,14,49,142,34,22
  DEFB 33,23,223,135,194,147,140,94
  DEFB 194,68,129,30,226,49,100,31
  DEFB 14,71,168,31,254,57,101,94
  DEFB 45,76,216,101,164,34,94,34
  DEFB 21,226,72,34,244,46,47,66
  DEFB 226,244,46,45,211,117,33,92
  DEFB 16,174,0,160,92,160,255,154
  DEFB 89,150,241,150,247,143,25,124
  DEFB 0,118,252,117,15,96,208,95
  DEFB 199,90,234,87,47,83,232,81
  DEFB 27,80,132,79,169,79,175,79
  DEFB 183,79,190,79,198,75,23,74
  DEFB 16,74,46,73,50,71,21,69
  DEFB 163,69,194,66,19,62,208,59
  DEFB 16,57,15,54,208,53,59,53
  DEFB 63,53,69,53,74,53,92,52
  DEFB 51,52,55,52,228,52,236,40
  DEFB 0,40,36,40,76,30,0,30
  DEFB 14,30,41,30,90,25,91,23
  DEFB 236,21,81,20,6,20,41,16
  DEFB 166,13,0,13,232,17,34,3
  DEFB 96,25,32,2,224,96,25,32
  DEFB 0,224,0,224,96,25,32,0
  DEFB 226,96,25,32,0,226,96,25
  DEFB 32,227,96,1,193,21,32,227
  DEFB 96,1,193,21,32,227,27,128
  DEFB 65,224,96,31,31,31,31,31
  DEFB 31,8,250,193,2,250,193,2
  DEFB 250,193,29,193,31,31,31,31
  DEFB 31,243,36,228,193,243,35,0
  DEFB 228,195,241,33,0,32,0,228
  DEFB 195,231,129,231,33,2,228,193
  DEFB 243,33,2,228,193,243,32,3
  DEFB 226,33,193,229,165,224,64,229
  DEFB 32,3,226,33,193,225,161,226
  DEFB 64,224,64,224,64,231,32,3
  DEFB 228,193,230,64,224,64,224,64
  DEFB 227,160,227,3,228,193,229,165
  DEFB 227,160,228,160,192,229,193,229
  DEFB 165,241,193,253,193,253,193,253
  DEFB 193,253,193,226,28,226,28,226
  DEFB 28,226,218,1,226,200,224,210
  DEFB 227,219,227,219,255,255,63,63
  DEFB 63,5,133,26,64,0,64,0
  DEFB 64,26,64,0,64,0,64,8
  DEFB 67,29,64,63,63,63,63,63
  DEFB 63,63,63

; Picture: a man in a hat at a table
;
; Command list drawn by DRAWPIC; used by the bubble layout at 33921 (first
; table).
  DEFB 8,158,16,137,14,129,74,130
  DEFB 205,131,84,171,20,8,190,18
  DEFB 135,212,8,186,27,130,79,131
  DEFB 149,8,164,37,132,75,135,11
  DEFB 135,139,139,147,8,138,25,134
  DEFB 80,135,88,8,168,30,143,225
  DEFB 8,168,30,130,71,135,154,8
  DEFB 157,33,143,99,8,157,33,134
  DEFB 72,139,223,64,152,15,64,170
  DEFB 15,64,188,3,8,138,24,132
  DEFB 12,134,75,135,136,131,72,8
  DEFB 113,31,149,95,8,255,39,212
  DEFB 235,8,192,39,158,76,8,148
  DEFB 39,174,19,8,113,39,214,169
  DEFB 135,115,8,145,39,149,93,8
  DEFB 148,54,133,155,8,188,39,141
  DEFB 16,137,165,8,114,14,138,69
  DEFB 8,129,33,165,218,129,92,8
  DEFB 198,48,134,6,8,192,42,131
  DEFB 200,130,134,128,201,129,199,8
  DEFB 212,40,133,69,132,138,8,208
  DEFB 46,145,42,133,95,132,146,134
  DEFB 204,8,194,44,161,229,132,71
  DEFB 8,136,16,143,86,64,136,5
  DEFB 8,149,143,145,8,128,5,130
  DEFB 68,131,204,135,70,134,139,132
  DEFB 75,141,73,129,71,128,67,130
  DEFB 71,8,137,142,130,139,128,74
  DEFB 129,70,8,164,146,130,197,131
  DEFB 69,8,172,139,135,71,134,144
  DEFB 140,137,132,73,133,133,128,7
  DEFB 8,148,133,137,69,64,151,136
  DEFB 8,166,130,143,200,135,140,142
  DEFB 74,133,9,141,139,64,141,59
  DEFB 64,188,59,8,211,0,132,3
  DEFB 8,214,0,132,8,8,217,0
  DEFB 132,13,8,220,0,132,17,8
  DEFB 223,0,132,38,8,226,0,132
  DEFB 38,8,229,0,132,38,8,232
  DEFB 0,132,32,8,235,0,132,31
  DEFB 8,238,0,132,31,8,241,0
  DEFB 132,32,8,244,0,132,33,8
  DEFB 247,0,132,35,8,250,0,132
  DEFB 37,8,199,21,132,18,8,193
  DEFB 24,132,9,8,143,114,134,81
  DEFB 135,172,8,147,110,134,142,136
  DEFB 206,8,144,106,134,80,135,87
  DEFB 8,116,69,128,71,8,123,72
  DEFB 135,80,8,118,60,151,154,8
  DEFB 156,108,131,8,8,164,101,137
  DEFB 146,130,77,8,181,113,133,7
  DEFB 130,214,131,95,8,190,94,135
  DEFB 82,134,72,8,173,70,128,202
  DEFB 8,183,72,134,79,128,140,131
  DEFB 198,134,74,138,135,135,4,134
  DEFB 142,136,19,131,74,8,190,85
  DEFB 129,73,151,9,129,5,135,71
  DEFB 130,7,132,69,155,94,8,210
  DEFB 83,143,164,8,156,107,135,71
  DEFB 133,9,8,161,103,139,34,143
  DEFB 211,133,5,149,48,8,162,95
  DEFB 128,142,8,177,99,134,78,8
  DEFB 163,46,140,81,8,164,48,140
  DEFB 83,64,148,42,8,178,81,135
  DEFB 11,8,178,81,134,76,64,171
  DEFB 70,64,169,59,8,159,66,134
  DEFB 73,8,159,63,134,201,64,158
  DEFB 64,8,160,58,142,73,8,160
  DEFB 54,132,201,64,157,55,8,157
  DEFB 80,134,69,8,151,78,129,3
  DEFB 134,200,128,8,134,198,129,72
  DEFB 134,204,128,72,140,202,135,19
  DEFB 64,144,101,64,154,84,8,116
  DEFB 69,129,72,128,12,135,79,130
  DEFB 197,134,134,131,4,140,69,131
  DEFB 69,140,4,143,92,64,121,63
  DEFB 64,121,74,64,124,69,64,138
  DEFB 106,8,202,32,137,199,8,206
  DEFB 32,129,198,8,198,32,141,71
  DEFB 8,118,14,133,71,8,122,17
  DEFB 133,69,8,126,20,133,131,8
  DEFB 131,22,133,131,8,139,26,132
  DEFB 9,8,139,29,132,10,8,140
  DEFB 31,132,8,8,141,33,132,7
  DEFB 8,143,34,132,5,8,144,36
  DEFB 132,3,8,165,49,133,70,137
  DEFB 140,141,101,8,163,97,132,136
  DEFB 64,159,101,64,159,83,8,153
  DEFB 126,132,8,8,155,127,132,7
  DEFB 8,157,128,132,7,8,159,129
  DEFB 132,12,8,161,130,132,14,8
  DEFB 164,130,132,17,8,167,130,132
  DEFB 20,8,168,132,132,20,8,170
  DEFB 133,132,22,8,170,136,132,18
  DEFB 8,171,138,132,18,8,171,141
  DEFB 132,16,8,116,7,142,3,143
  DEFB 202,70,114,5,8,253,0,133
  DEFB 38,8,255,1,133,38,8,255
  DEFB 4,133,35,8,255,7,133,32
  DEFB 8,255,10,133,29,8,255,13
  DEFB 133,26,8,255,16,133,23,8
  DEFB 255,19,133,20,8,255,22,133
  DEFB 17,8,255,25,133,13,8,255
  DEFB 28,133,11,8,255,31,133,8
  DEFB 8,255,34,133,5,8,255,37
  DEFB 133,1,38,90,40,17,2,23
  DEFB 2,21,2,1,31,2,29,255
  DEFB 8,125,54,147,18,8,125,50
  DEFB 135,207,64,125,42,8,48,0
  DEFB 249,254,242,55,249,254,193,96
  DEFB 250,190,8,167,159,170,215,8
  DEFB 191,159,179,23,178,23,251,254
  DEFB 195,96,32,88,0,249,49,2
  DEFB 79,2,77,2,79,9,2,65
  DEFB 2,67,2,65,2,67,2,65
  DEFB 2,67,2,65,2,67,2,37
  DEFB 2,39,2,37,2,39,17,2
  DEFB 17,2,19,10,17,0,19,255
  DEFB 37,88,213,13,2,15,13,2
  DEFB 3,1,2,1,2,3,1,18
  DEFB 24,11,30,3,16,6,3,10
  DEFB 0,255,64,173,130,64,152,157
  DEFB 8,152,157,131,64,64,130,157
  DEFB 16,177,68,4,25,0,0,0
  DEFB 4,0,0,0,60,0,0,3
  DEFB 244,0,0,15,242,31,128,127
  DEFB 218,19,255,246,218,19,219,118
  DEFB 218,18,219,127,148,8,126,127
  DEFB 148,8,126,127,24,8,60,127
  DEFB 152,8,56,127,152,8,30,127
  DEFB 144,8,3,255,144,4,7,255
  DEFB 144,2,14,3,160,1,29,253
  DEFB 160,0,131,252,192,0,71,254
  DEFB 192,0,35,255,128,0,17,255
  DEFB 192,0,8,249,224,0,4,1
  DEFB 112,0,2,14,48,0,1,240
  DEFB 0,0

; Picture: a figure in a doorway between headlights
;
; Command list drawn by DRAWPIC; used by the bubble layout at 33913 (first
; table).
  DEFB 8,192,120,177,89,8,192,146
  DEFB 134,136,255,254,171,215,8,183
  DEFB 56,144,73,128,150,8,216,65
  DEFB 129,0,134,152,8,183,133,198
  DEFB 226,255,254,155,141,142,62,142
  DEFB 62,142,190,8,187,56,132,4
  DEFB 8,190,56,132,6,8,192,57
  DEFB 132,8,8,192,60,132,8,8
  DEFB 192,63,132,8,8,192,66,132
  DEFB 8,8,192,69,132,8,8,192
  DEFB 72,132,8,8,192,75,132,8
  DEFB 8,192,78,132,8,8,192,81
  DEFB 132,8,8,192,84,132,8,8
  DEFB 192,87,132,8,8,192,90,132
  DEFB 8,8,192,93,132,8,8,192
  DEFB 108,132,8,8,192,111,132,8
  DEFB 8,192,114,132,8,8,192,117
  DEFB 132,8,8,192,120,132,8,8
  DEFB 192,123,132,8,8,192,126,132
  DEFB 8,8,192,129,132,8,8,192
  DEFB 132,132,8,8,192,135,132,8
  DEFB 8,192,138,132,6,8,192,141
  DEFB 132,4,8,192,144,132,2,8
  DEFB 183,56,138,62,138,62,8,192
  DEFB 59,253,190,8,175,55,142,134
  DEFB 139,125,8,176,55,130,126,130
  DEFB 126,8,158,55,135,188,8,158
  DEFB 55,142,134,134,126,134,126,64
  DEFB 103,8,64,199,34,8,183,111
  DEFB 130,73,8,183,114,130,5,64
  DEFB 186,107,8,0,55,250,254,240
  DEFB 120,241,120,201,166,8,120,151
  DEFB 250,254,194,31,251,254,171,153
  DEFB 8,216,63,202,232,64,216,59
  DEFB 64,208,85,32,88,0,249,185
  DEFB 42,55,36,49,34,47,28,41
  DEFB 26,39,20,33,18,31,12,25
  DEFB 10,23,4,17,2,39,16,15
  DEFB 38,13,32,11,30,5,24,3
  DEFB 26,255,38,89,232,249,249,249
  DEFB 105,43,28,255,38,89,242,0
  DEFB 2,13,0,6,255,16,178,67
  DEFB 5,77,0,0,0,0,110,0
  DEFB 0,0,0,217,0,0,0,3
  DEFB 216,0,0,0,4,216,0,0
  DEFB 0,9,144,0,0,0,19,145
  DEFB 0,0,0,19,195,0,0,0
  DEFB 17,255,0,0,0,8,254,0
  DEFB 0,0,14,56,0,0,0,9
  DEFB 0,0,0,0,9,199,0,0
  DEFB 0,4,255,0,0,0,4,127
  DEFB 0,0,0,4,31,0,0,0
  DEFB 4,126,0,0,0,254,254,0
  DEFB 0,3,3,60,0,0,7,195
  DEFB 136,0,0,8,31,126,0,0
  DEFB 16,0,63,0,0,32,14,125
  DEFB 0,0,96,124,120,0,0,192
  DEFB 4,120,0,0,129,252,248,0
  DEFB 1,15,252,252,0,2,30,248
  DEFB 254,0,2,127,249,255,0,4
  DEFB 251,249,254,0,5,243,241,252
  DEFB 0,15,243,241,248,0,15,231
  DEFB 225,248,0,15,199,195,240,0
  DEFB 15,231,195,240,0,15,239,195
  DEFB 240,0,7,255,195,240,0,7
  DEFB 243,199,224,0,3,240,255,224
  DEFB 0,3,240,127,224,0,3,224
  DEFB 47,224,0,1,224,111,192,0
  DEFB 1,224,79,192,0,0,192,223
  DEFB 128,0,0,192,190,128,0,1
  DEFB 129,254,128,0,1,1,254,128
  DEFB 0,2,67,238,128,0,2,195
  DEFB 220,128,0,2,195,220,128,0
  DEFB 2,195,188,128,0,2,135,188
  DEFB 128,0,2,135,253,128,0,2
  DEFB 143,249,0,0,4,141,249,0
  DEFB 0,4,141,249,0,0,4,29
  DEFB 249,0,0,8,29,243,0,0
  DEFB 8,56,227,0,0,8,184,227
  DEFB 0,0,8,240,227,0,0,8
  DEFB 240,195,0,0,8,240,195,0
  DEFB 0,16,240,207,0,0,17,224
  DEFB 142,0,0,17,224,142,0,0
  DEFB 17,224,142,0,0,17,224,142
  DEFB 0,0,17,192,206,0,0,33
  DEFB 192,206,0,0,33,192,206,0
  DEFB 0,127,128,126,0,0,3,128
  DEFB 134,0,0,252,0,255,0,1
  DEFB 143,0,231,128,3,63,0,241
  DEFB 128,3,255,0,255,128,1,254
  DEFB 0,127,0,0

; Picture: two hoods at a table
;
; Command list drawn by DRAWPIC; used by the bubble layout at 33917 (first
; table).
  DEFB 8,194,0,133,91,135,72,142
  DEFB 161,132,75,129,202,128,10,128
  DEFB 83,129,78,128,75,130,207,128
  DEFB 207,128,6,128,135,130,140,131
  DEFB 19,8,186,16,198,190,254,190
  DEFB 159,82,8,60,14,129,25,8
  DEFB 188,74,129,68,168,150,128,73
  DEFB 131,3,8,222,87,137,134,129
  DEFB 69,145,7,133,69,132,69,142
  DEFB 4,133,74,132,134,134,70,132
  DEFB 69,134,67,135,71,135,200,134
  DEFB 72,143,138,131,7,130,72,138
  DEFB 206,128,206,129,9,8,175,71
  DEFB 133,77,132,135,132,202,137,71
  DEFB 128,3,129,135,133,67,132,197
  DEFB 133,135,132,70,135,4,133,69
  DEFB 134,72,135,134,134,70,135,134
  DEFB 130,6,138,19,128,141,8,150
  DEFB 88,143,72,134,7,150,7,133
  DEFB 7,133,74,142,74,134,73,135
  DEFB 154,143,146,8,119,90,133,201
  DEFB 8,193,110,133,77,143,74,130
  DEFB 71,8,177,107,131,202,130,139
  DEFB 136,143,129,6,141,140,135,137
  DEFB 134,134,140,69,8,255,24,133
  DEFB 85,130,12,8,255,0,132,88
  DEFB 130,24,8,245,34,131,88,8
  DEFB 245,34,131,165,8,166,31,128
  DEFB 81,129,9,135,77,128,154,134
  DEFB 90,130,77,132,148,142,141,8
  DEFB 141,71,131,134,135,132,139,208
  DEFB 8,78,32,254,254,254,254,8
  DEFB 15,0,129,31,8,31,0,129
  DEFB 32,8,46,0,129,13,8,0
  DEFB 1,129,31,8,0,16,129,16
  DEFB 8,0,24,250,254,146,72,8
  DEFB 0,15,250,254,8,0,5,250
  DEFB 124,8,116,40,141,84,8,113
  DEFB 60,134,70,135,145,8,104,39
  DEFB 202,100,8,136,71,135,201,159
  DEFB 21,8,106,36,133,6,134,141
  DEFB 8,87,39,139,10,130,204,129
  DEFB 71,8,103,29,136,5,133,69
  DEFB 8,99,25,141,7,8,95,26
  DEFB 141,7,8,92,28,133,134,8
  DEFB 126,14,162,190,8,116,14,158
  DEFB 185,64,44,3,64,11,3,64
  DEFB 3,11,64,34,11,64,57,9
  DEFB 64,57,19,64,27,19,64,2
  DEFB 19,64,17,30,64,50,30,8
  DEFB 191,71,131,20,136,141,134,18
  DEFB 128,80,131,80,130,27,8,89
  DEFB 28,130,13,8,109,31,130,77
  DEFB 129,5,132,8,8,93,27,130
  DEFB 11,8,96,27,130,11,8,100
  DEFB 26,130,11,8,103,26,130,11
  DEFB 8,103,29,130,13,8,106,29
  DEFB 130,13,8,108,30,130,14,8
  DEFB 111,30,130,14,8,116,28,130
  DEFB 14,8,122,25,130,10,8,124
  DEFB 26,130,10,8,127,26,130,10
  DEFB 8,127,29,130,4,8,128,31
  DEFB 130,4,8,123,39,130,8,8
  DEFB 127,39,130,6,8,131,39,130
  DEFB 4,8,135,39,130,2,8,142
  DEFB 69,130,4,129,141,143,209,135
  DEFB 2,131,203,8,135,70,134,5
  DEFB 131,72,8,146,56,130,7,8
  DEFB 147,58,130,8,8,148,60,130
  DEFB 9,8,150,61,130,9,8,150
  DEFB 64,130,11,8,150,67,130,12
  DEFB 8,151,69,130,12,8,151,72
  DEFB 130,13,8,151,75,130,14,8
  DEFB 151,78,130,16,8,151,81,130
  DEFB 16,8,151,84,130,18,8,151
  DEFB 87,130,18,8,153,88,130,18
  DEFB 8,156,88,130,18,8,160,87
  DEFB 130,16,8,164,86,130,8,8
  DEFB 180,97,130,15,64,132,63,64
  DEFB 145,63,64,145,46,8,15,0
  DEFB 248,254,248,254,248,254,248,254
  DEFB 248,254,249,190,249,190,149,72
  DEFB 252,254,252,254,230,112,251,254
  DEFB 203,165,8,255,63,133,13,8
  DEFB 242,76,132,78,64,231,92,64
  DEFB 182,20,64,115,43,8,198,82
  DEFB 132,12,8,200,83,132,10,8
  DEFB 203,83,132,9,8,206,83,132
  DEFB 9,8,208,84,132,9,8,198
  DEFB 102,139,134,8,198,95,140,15
  DEFB 133,74,65,204,98,8,200,106
  DEFB 133,144,128,69,130,4,139,72
  DEFB 134,6,64,203,116,64,188,116
  DEFB 64,208,82,8,211,84,133,8
  DEFB 8,214,84,133,13,8,216,85
  DEFB 133,13,8,216,85,133,19,8
  DEFB 219,85,133,22,8,219,88,133
  DEFB 22,8,222,88,133,27,8,225
  DEFB 88,133,31,8,225,91,133,32
  DEFB 8,225,94,133,32,8,225,97
  DEFB 133,30,8,228,97,133,31,8
  DEFB 228,100,133,29,8,228,103,133
  DEFB 27,8,228,106,133,16,64,228
  DEFB 71,64,185,33,64,244,2,32
  DEFB 88,0,249,249,169,46,35,40
  DEFB 29,38,27,32,21,30,19,24
  DEFB 13,22,11,16,5,14,3,12
  DEFB 255,64,72,6,8,201,102,132
  DEFB 206,8,202,100,132,142,8,120
  DEFB 113,131,71,130,207,128,72,141
  DEFB 8,135,133,142,9,8,136,107
  DEFB 132,143,65,136,105,8,127,63
  DEFB 133,206,8,108,61,128,9,135
  DEFB 71,131,74,141,140,8,118,64
  DEFB 128,68,134,141,64,117,63,65
  DEFB 113,65,8,135,117,131,68,129
  DEFB 136,134,5,64,137,116,8,139
  DEFB 115,135,0,37,89,121,1,0
  DEFB 3,12,3,5,2,1,2,3
  DEFB 2,1,2,1,255,32,89,207
  DEFB 255,32,89,207,255,38,90,64
  DEFB 29,3,2,27,2,21,2,1
  DEFB 31,255,16,46,77,5,29,3
  DEFB 224,0,0,0,3,127,0,0
  DEFB 28,3,48,248,0,228,3,48
  DEFB 63,199,228,3,48,244,57,232
  DEFB 1,48,56,31,232,1,56,2
  DEFB 31,232,1,152,28,31,232,0
  DEFB 128,1,15,232,0,192,2,15
  DEFB 248,0,64,6,11,252,0,96
  DEFB 6,1,252,0,32,11,131,252
  DEFB 0,16,48,231,252,0,16,195
  DEFB 255,252,0,8,14,31,252,0
  DEFB 8,56,193,248,0,4,1,63
  DEFB 248,0,4,2,19,248,0,2
  DEFB 1,201,248,0,2,0,124,240
  DEFB 0,1,0,62,96,0,0,128
  DEFB 15,32,0,0,64,7,144,0
  DEFB 0,32,7,72,0,0,16,14
  DEFB 36,0,0,8,124,18,0,0
  DEFB 7,248,10,0,0,0,0,6
  DEFB 0

; Picture: the getaway car from above
;
; Command list drawn by DRAWPIC; used by the bubble layout at 33929 (second
; table).
  DEFB 8,255,104,220,238,131,126,131
  DEFB 126,8,208,104,145,31,220,108
  DEFB 131,153,143,134,133,97,8,166
  DEFB 136,164,210,133,69,129,72,8
  DEFB 136,151,248,254,176,23,159,206
  DEFB 150,203,8,136,151,159,207,8
  DEFB 215,112,177,24,8,172,104,139
  DEFB 102,8,172,104,222,44,132,62
  DEFB 132,62,8,255,72,188,223,8
  DEFB 255,70,142,207,8,239,69,140
  DEFB 79,8,136,136,144,202,8,145
  DEFB 142,248,254,152,206,8,220,136
  DEFB 129,69,8,223,143,133,72,8
  DEFB 215,112,140,199,8,207,111,196
  DEFB 32,8,207,104,196,32,8,176
  DEFB 72,254,254,166,16,249,125,8
  DEFB 55,175,255,254,215,39,238,249
  DEFB 8,54,72,142,83,156,101,8
  DEFB 96,71,154,33,176,174,226,48
  DEFB 8,177,72,226,114,8,127,104
  DEFB 139,31,8,0,105,184,222,253
  DEFB 254,253,190,8,127,152,166,210
  DEFB 133,14,138,199,131,7,144,203
  DEFB 130,7,8,124,156,132,10,156
  DEFB 12,8,30,105,132,96,8,21
  DEFB 69,135,254,64,15,108,8,0
  DEFB 103,186,93,8,5,7,135,136
  DEFB 64,140,87,64,229,87,64,252
  DEFB 64,8,127,104,185,222,180,23
  DEFB 149,7,148,7,149,7,148,7
  DEFB 149,7,140,199,157,207,64,76
  DEFB 160,64,140,139,64,222,149,64
  DEFB 222,137,64,212,120,64,5,60
  DEFB 8,30,103,135,222,64,21,94
  DEFB 8,104,160,133,130,8,104,160
  DEFB 130,130,64,105,161,8,207,111
  DEFB 153,25,8,193,124,134,67,8
  DEFB 189,123,132,131,8,186,125,128
  DEFB 67,8,190,126,130,131,8,24
  DEFB 69,133,130,69,29,70,69,134
  DEFB 70,8,175,47,159,206,166,210
  DEFB 8,175,39,166,210,8,175,47
  DEFB 166,210,159,143,8,154,31,150
  DEFB 226,133,202,129,202,146,100,8
  DEFB 120,50,129,68,232,247,8,177
  DEFB 55,131,68,134,3,8,179,50
  DEFB 175,85,133,3,8,179,28,135
  DEFB 3,238,246,133,133,8,137,63
  DEFB 138,133,139,199,8,180,69,139
  DEFB 62,139,62,8,137,63,131,199
  DEFB 64,140,59,8,176,69,159,77
  DEFB 8,176,56,138,134,8,159,33
  DEFB 141,69,8,159,40,141,70,8
  DEFB 118,31,134,195,131,68,8,117
  DEFB 25,130,130,139,27,8,123,47
  DEFB 138,75,139,75,150,12,149,15
  DEFB 8,159,47,128,135,136,139,8
  DEFB 121,54,134,194,135,69,8,116
  DEFB 48,130,195,34,88,0,26,1
  DEFB 24,1,30,1,28,1,255,32
  DEFB 89,177,13,2,15,255,32,88
  DEFB 10,5,2,7,1,2,9,2
  DEFB 7,1,2,5,12,61,30,19
  DEFB 1,8,1,6,5,20,3,18
  DEFB 3,16,47,2,41,43,22,1
  DEFB 8,1,10,1,8,2,1,6
  DEFB 5,255,64,178,66,130,0,35
  DEFB 88,7,46,1,44,1,46,1
  DEFB 32,1,38,17,55,2,57,11
  DEFB 2,47,2,3,45,2,47,2
  DEFB 49,2,51,2,3,57,0,6
  DEFB 59,1,255,64,127,15,32,90
  DEFB 14,6,255,71,119,51,71,117
  DEFB 28,32,89,239,21,2,23,2
  DEFB 21,2,27,255,71,127,41,8
  DEFB 122,53,144,141,71,126,54,8
  DEFB 151,54,130,2,8,154,52,136
  DEFB 11,71,154,54,71,158,43,8
  DEFB 190,111,145,11,8,189,111,149
  DEFB 204,8,189,126,141,10,8,190
  DEFB 126,33,88,180,17,2,15,2
  DEFB 17,255,71,164,131,8,191,126
  DEFB 145,73,71,190,125,37,89,189
  DEFB 9,255,8,119,161,153,144,8
  DEFB 104,167,153,144,64,110,173,16
  DEFB 87,75,6,69,0,112,0,0
  DEFB 0,0,0,143,192,0,0,0
  DEFB 1,119,224,0,0,0,2,219
  DEFB 240,0,0,0,2,139,112,0
  DEFB 0,0,2,219,184,0,0,0
  DEFB 1,123,248,0,0,0,1,143
  DEFB 252,0,0,0,1,255,255,0
  DEFB 0,0,1,255,255,128,0,0
  DEFB 1,239,254,96,0,0,0,255
  DEFB 254,32,0,0,0,127,255,224
  DEFB 0,0,0,123,255,240,0,0
  DEFB 0,1,255,248,0,0,0,1
  DEFB 247,248,0,0,0,0,231,252
  DEFB 0,0,0,0,231,252,0,0
  DEFB 0,0,255,254,0,0,0,0
  DEFB 255,254,0,0,0,0,255,255
  DEFB 0,0,0,0,255,255,0,0
  DEFB 0,0,255,255,128,0,0,240
  DEFB 255,255,128,0,1,255,255,255
  DEFB 192,0,63,255,207,255,192,0
  DEFB 67,223,143,255,224,0,153,255
  DEFB 223,255,224,0,165,255,255,255
  DEFB 240,0,173,255,255,255,240,0
  DEFB 185,255,255,255,248,0,155,223
  DEFB 255,255,248,0,71,191,31,255
  DEFB 252,0,63,255,63,255,252,0
  DEFB 15,247,255,255,254,0,15,225
  DEFB 255,255,254,0,7,255,255,255
  DEFB 255,0,3,255,255,255,255,128
  DEFB 0,255,255,255,255,192,0,255
  DEFB 255,255,255,192,0,255,255,255
  DEFB 255,224,0,255,255,255,255,192
  DEFB 0,127,255,255,255,192,0,127
  DEFB 255,255,255,192,0,127,255,255
  DEFB 255,128,0,127,255,255,255,128
  DEFB 0,127,255,255,255,192,0,127
  DEFB 255,255,255,224,0,63,255,255
  DEFB 255,240,0,63,255,255,255,248
  DEFB 0,63,255,255,255,248,0,63
  DEFB 255,254,255,248,0,63,255,254
  DEFB 127,248,0,31,255,254,31,240
  DEFB 0,31,255,254,31,240,0,31
  DEFB 255,252,15,240,0,31,255,248
  DEFB 7,224,0,31,255,240,0,224
  DEFB 0,15,255,224,0,0,0,15
  DEFB 255,248,0,0,0,15,255,252
  DEFB 0,0,0,15,255,254,0,0
  DEFB 0,7,255,254,0,0,0,0
  DEFB 255,254,0,0,0,0,63,254
  DEFB 0,0,0,0,31,252,0,0
  DEFB 0,0,15,248,0,0,0,0
  DEFB 15,248,0,0,0,0,3,240
  DEFB 0,0,0

; Picture: two figures at the waterfront
;
; Command list drawn by DRAWPIC; used by the bubble layout at 33933 (second
; table).
  DEFB 8,255,130,142,133,159,141,134
  DEFB 195,141,68,148,7,151,7,142
  DEFB 133,157,76,140,4,167,80,140
  DEFB 3,149,72,140,3,151,202,134
  DEFB 195,151,203,146,234,8,214,95
  DEFB 230,242,165,145,142,69,153,141
  DEFB 142,198,159,141,142,134,173,19
  DEFB 142,199,147,7,150,138,153,206
  DEFB 148,8,175,149,142,4,141,3
  DEFB 142,4,141,134,150,72,147,73
  DEFB 8,95,119,150,138,135,130,140
  DEFB 198,197,226,148,7,175,214,148
  DEFB 203,8,56,128,139,198,182,219
  DEFB 209,39,172,19,187,27,150,26
  DEFB 8,163,95,150,99,8,214,98
  DEFB 228,243,8,39,31,133,215,153
  DEFB 77,128,68,130,68,139,102,8
  DEFB 223,31,129,153,149,139,132,199
  DEFB 143,148,143,18,8,223,31,131
  DEFB 126,8,215,31,155,62,8,50
  DEFB 31,135,62,8,38,31,134,126
  DEFB 8,49,38,128,190,128,154,129
  DEFB 197,134,190,134,156,8,139,73
  DEFB 148,142,8,141,82,133,131,132
  DEFB 131,135,205,8,137,67,143,203
  DEFB 142,69,137,202,8,125,74,134
  DEFB 254,134,208,8,34,52,134,226
  DEFB 8,125,74,145,17,8,54,57
  DEFB 153,36,8,66,93,170,254,8
  DEFB 66,93,166,115,128,24,8,60
  DEFB 93,132,22,138,190,146,16,8
  DEFB 19,91,171,97,152,13,8,20
  DEFB 57,142,157,8,20,61,134,221
  DEFB 64,237,103,64,3,50,8,216
  DEFB 37,193,97,8,216,71,154,207
  DEFB 8,231,71,207,231,8,139,73
  DEFB 129,200,8,130,56,166,210,143
  DEFB 199,190,93,8,130,92,132,13
  DEFB 8,0,79,144,82,8,42,68
  DEFB 139,157,8,34,62,131,222,8
  DEFB 34,62,129,66,8,36,64,139
  DEFB 29,64,36,57,8,36,57,8
  DEFB 37,54,139,88,8,38,64,139
  DEFB 14,8,221,45,137,81,8,222
  DEFB 45,137,81,8,222,45,129,204
  DEFB 8,219,36,129,141,8,222,41
  DEFB 129,141,8,223,49,143,18,8
  DEFB 228,63,143,143,8,137,83,135
  DEFB 201,8,138,84,143,11,8,20
  DEFB 91,129,20,64,38,95,64,131
  DEFB 109,8,188,99,128,74,8,187
  DEFB 99,132,74,8,176,95,145,138
  DEFB 8,175,95,145,202,8,199,95
  DEFB 145,138,8,200,95,145,138,8
  DEFB 164,99,128,74,8,211,99,132
  DEFB 75,8,173,99,141,69,8,171
  DEFB 99,133,195,8,169,99,133,65
  DEFB 8,167,99,133,194,8,178,99
  DEFB 137,69,8,180,99,137,4,8
  DEFB 182,99,129,195,8,197,99,141
  DEFB 69,8,195,99,141,4,8,193
  DEFB 99,133,195,8,202,99,141,4
  DEFB 8,204,99,141,4,8,206,99
  DEFB 133,195,8,208,99,133,130,8
  DEFB 116,91,142,252,8,54,59,133
  DEFB 87,132,150,64,42,87,64,62
  DEFB 87,8,110,109,131,11,8,107
  DEFB 109,131,15,8,105,109,131,11
  DEFB 8,101,109,131,16,8,98,109
  DEFB 131,10,8,96,109,131,14,8
  DEFB 90,109,131,14,8,88,109,131
  DEFB 18,8,85,109,131,18,8,83
  DEFB 109,131,18,8,82,109,131,18
  DEFB 8,76,109,131,12,8,69,113
  DEFB 131,18,8,68,113,131,18,8
  DEFB 66,113,131,18,8,65,113,131
  DEFB 18,8,61,113,131,16,8,59
  DEFB 113,131,16,8,59,113,131,16
  DEFB 8,59,113,131,19,8,56,113
  DEFB 131,19,8,55,113,131,19,8
  DEFB 52,113,131,19,8,50,113,131
  DEFB 19,8,49,113,131,19,8,47
  DEFB 113,131,19,8,46,113,131,19
  DEFB 8,45,113,131,19,8,43,113
  DEFB 131,19,8,41,113,131,19,8
  DEFB 22,89,139,158,8,19,89,139
  DEFB 158,8,21,89,147,222,8,24
  DEFB 89,147,222,8,26,89,147,222
  DEFB 8,27,89,147,222,8,29,89
  DEFB 191,161,8,23,89,191,161,8
  DEFB 31,89,191,161,8,33,89,151
  DEFB 97,8,35,89,151,97,8,35
  DEFB 89,167,148,8,37,89,159,84
  DEFB 8,39,89,167,19,8,40,89
  DEFB 139,211,8,43,89,135,211,8
  DEFB 45,89,147,222,8,47,89,147
  DEFB 224,8,49,89,147,225,8,31
  DEFB 89,135,223,8,37,89,135,223
  DEFB 8,43,89,175,20,8,43,91
  DEFB 151,20,8,55,89,8,52,89
  DEFB 151,33,8,49,89,151,33,8
  DEFB 48,89,151,33,8,87,84,151
  DEFB 84,8,87,86,148,140,151,151
  DEFB 8,71,85,159,88,8,70,85
  DEFB 159,88,8,69,85,159,88,8
  DEFB 68,87,159,88,8,89,88,159
  DEFB 88,8,86,84,159,84,8,86
  DEFB 84,159,84,8,85,84,159,84
  DEFB 8,84,84,159,84,8,84,83
  DEFB 150,138,8,84,82,150,138,8
  DEFB 84,81,150,138,8,84,79,142
  DEFB 7,8,84,78,142,200,8,84
  DEFB 76,134,135,8,84,74,142,71
  DEFB 8,84,71,142,73,8,84,70
  DEFB 134,137,8,84,68,134,201,8
  DEFB 84,66,134,201,8,84,65,134
  DEFB 201,8,84,69,134,201,8,116
  DEFB 88,148,83,8,116,88,143,9
  DEFB 142,14,145,206,8,98,75,145
  DEFB 206,8,97,75,145,206,8,96
  DEFB 75,145,206,8,96,74,128,210
  DEFB 8,96,73,128,210,8,96,73
  DEFB 128,210,8,102,85,136,203,135
  DEFB 198,8,113,86,135,198,8,112
  DEFB 86,135,198,8,112,80,134,201
  DEFB 141,199,8,111,84,142,71,8
  DEFB 111,83,142,135,8,111,81,142
  DEFB 135,8,58,89,143,221,8,60
  DEFB 89,151,216,8,62,89,143,27
  DEFB 8,61,89,8,63,89,159,30
  DEFB 8,64,89,171,30,8,66,89
  DEFB 171,30,8,91,89,159,212,8
  DEFB 91,89,159,212,8,93,89,151
  DEFB 76,8,96,89,151,87,8,98
  DEFB 89,159,213,8,99,75,143,70
  DEFB 8,101,75,143,4,135,195,8
  DEFB 104,76,135,195,8,107,76,135
  DEFB 195,8,109,76,135,130,8,110
  DEFB 76,135,130,8,112,76,135,130
  DEFB 8,114,76,135,0,8,108,91
  DEFB 135,130,8,111,91,135,130,8
  DEFB 112,91,135,130,8,114,91,135
  DEFB 130,8,116,91,135,130,8,118
  DEFB 91,135,201,8,118,91,151,10
  DEFB 8,120,91,131,198,8,122,91
  DEFB 143,4,8,124,91,143,4,65
  DEFB 218,57,8,135,66,143,140,8
  DEFB 133,66,135,138,8,215,93,146
  DEFB 43,8,216,92,143,134,130,195
  DEFB 139,8,130,195,141,140,136,4
  DEFB 155,142,138,3,137,136,130,196
  DEFB 139,69,138,4,8,245,75,137
  DEFB 68,136,68,163,20,138,148,64
  DEFB 236,88,8,162,93,142,227,8
  DEFB 162,93,147,73,142,70,151,73
  DEFB 134,195,8,151,72,141,74,140
  DEFB 69,8,216,90,246,121,8,200
  DEFB 93,147,8,8,175,93,147,8
  DEFB 8,145,83,159,155,140,199,64
  DEFB 140,60,8,0,76,136,147,64
  DEFB 7,69,8,136,52,142,71,139
  DEFB 83,8,136,52,163,85,8,131
  DEFB 47,164,220,8,129,43,134,11
  DEFB 65,119,59,65,228,70,64,133
  DEFB 61,8,195,7,196,32,8,162
  DEFB 7,135,76,8,195,7,143,200
  DEFB 64,184,3,35,88,0,249,249
  DEFB 249,133,2,91,45,2,29,2
  DEFB 35,255,33,89,128,9,255,33
  DEFB 89,80,57,26,3,20,3,22
  DEFB 20,3,2,3,0,3,22,24
  DEFB 27,21,27,26,15,4,9,255
  DEFB 33,89,241,2,11,255,8,41
  DEFB 31,250,254,8,208,31,216,239
  DEFB 65,228,38,64,222,15,64,32
  DEFB 21,8,103,31,242,56,64,103
  DEFB 37,64,134,37,8,134,37,128
  DEFB 0,33,89,115,26,255,8,154
  DEFB 83,16,116,72,6,80,0,255
  DEFB 255,254,255,0,0,255,255,249
  DEFB 31,0,0,255,255,242,31,0
  DEFB 0,242,127,242,23,0,0,227
  DEFB 63,218,55,0,0,199,63,204
  DEFB 231,0,0,226,47,207,199,0
  DEFB 0,240,103,231,143,0,0,249
  DEFB 231,248,63,0,0,240,231,239
  DEFB 223,0,0,120,207,239,191,0
  DEFB 0,127,30,119,63,0,0,62
  DEFB 239,255,63,0,0,63,255,255
  DEFB 95,0,0,127,255,255,135,0
  DEFB 0,255,251,255,3,0,1,191
  DEFB 253,255,73,0,3,191,253,255
  DEFB 201,0,7,191,253,255,217,0
  DEFB 7,223,254,255,217,0,15,224
  DEFB 126,255,185,0,15,255,254,255
  DEFB 176,128,31,255,254,255,180,128
  DEFB 31,255,255,127,244,128,31,255
  DEFB 255,127,244,127,31,127,255,127
  DEFB 222,127,31,127,255,191,222,127
  DEFB 31,63,255,191,223,63,15,191
  DEFB 255,191,217,63,15,255,239,127
  DEFB 220,127,15,255,159,127,178,127
  DEFB 7,224,62,255,184,255,7,240
  DEFB 254,255,110,128,3,255,255,255
  DEFB 53,0,3,255,255,255,27,0
  DEFB 1,253,255,255,27,0,1,253
  DEFB 255,255,7,0,1,249,255,255
  DEFB 63,0,1,249,247,255,127,0
  DEFB 1,249,247,255,95,0,1,249
  DEFB 247,255,252,0,1,252,247,255
  DEFB 252,0,1,188,247,255,240,0
  DEFB 1,188,247,251,240,0,1,188
  DEFB 247,251,240,0,1,190,247,243
  DEFB 224,0,1,190,247,243,224,0
  DEFB 1,190,247,243,224,0,1,190
  DEFB 231,243,224,0,1,191,103,243
  DEFB 224,0,1,191,39,243,224,0
  DEFB 1,159,39,243,240,0,1,159
  DEFB 55,243,240,0,3,159,183,243
  DEFB 240,0,3,159,151,251,240,0
  DEFB 3,159,211,251,240,0,255,143
  DEFB 211,251,255,255,7,143,211,255
  DEFB 240,0,7,143,219,255,240,0
  DEFB 7,7,219,255,240,0,6,7
  DEFB 235,255,240,0,15,135,237,255
  DEFB 240,0,3,227,247,255,224,0
  DEFB 0,120,127,255,224,0,0,63
  DEFB 255,255,240,0,0,62,127,63
  DEFB 240,0,0,62,124,60,112,0
  DEFB 0,126,121,248,240,0,0,126
  DEFB 127,255,240,0,0,126,127,255
  DEFB 240,0,0,124,127,255,240,0
  DEFB 0,124,127,255,240,0,0,127
  DEFB 255,255,240,0,0,255,255,255
  DEFB 240,0,0,255,255,255,240,0
  DEFB 1,255,191,255,240,0,1,199
  DEFB 199,255,240,0,3,255,255,255
  DEFB 240,0,3,255,255,255,240,0
  DEFB 7,255,255,255,240,0,16,116
  DEFB 89,6,10,8,57,57,57,57
  DEFB 8,8,8,56,56,57,8,8
  DEFB 56,56,56,56,8,8,8,56
  DEFB 56,56,57,8,56,56,56,56
  DEFB 8,8,56,56,8,8,8,8
  DEFB 56,56,8,8,8,56,56,56
  DEFB 56,56,56,56,56,56,56,56
  DEFB 56,56,56,56,56,56,56,0

; Picture: hoods and a car in the city
;
; Command list drawn by DRAWPIC; used by the bubble layout at 33925 (second
; table).
  DEFB 8,255,23,182,126,150,190,142
  DEFB 190,8,66,8,142,187,137,190
  DEFB 137,142,129,7,137,190,137,190
  DEFB 8,242,135,134,82,133,143,132
  DEFB 205,133,150,132,212,134,14,175
  DEFB 190,132,211,134,81,159,24,132
  DEFB 142,197,254,132,148,134,17,143
  DEFB 181,132,149,134,84,8,255,88
  DEFB 134,88,139,245,8,230,75,130
  DEFB 202,128,82,8,238,74,139,243
  DEFB 64,177,10,8,247,113,133,254
  DEFB 8,248,112,134,126,139,140,134
  DEFB 98,8,151,68,131,3,129,3
  DEFB 132,3,135,3,8,147,60,129
  DEFB 71,8,146,60,133,136,71,237
  DEFB 50,64,245,81,36,89,159,22
  DEFB 3,24,255,38,89,179,0,7
  DEFB 6,255,8,16,76,249,254,249
  DEFB 254,8,242,136,136,4,213,49
  DEFB 66,242,149,8,159,24,150,158
  DEFB 133,130,8,154,24,134,2,150
  DEFB 24,133,2,141,10,132,3,134
  DEFB 68,135,201,139,8,130,2,8
  DEFB 122,16,129,131,8,153,16,129
  DEFB 72,8,146,16,133,133,8,126
  DEFB 19,132,135,141,11,8,116,32
  DEFB 134,68,8,159,28,141,11,132
  DEFB 70,8,151,43,137,143,140,75
  DEFB 8,141,60,142,12,134,78,8
  DEFB 110,25,132,131,145,78,8,108
  DEFB 41,136,210,8,127,44,141,8
  DEFB 134,138,143,73,8,113,50,143
  DEFB 73,8,132,44,141,9,8,131
  DEFB 54,144,17,143,10,150,14,8
  DEFB 160,24,129,66,158,97,8,111
  DEFB 17,142,9,133,2,141,70,134
  DEFB 66,129,68,128,66,131,1,131
  DEFB 198,131,130,128,199,8,94,24
  DEFB 147,74,131,68,8,103,12,129
  DEFB 196,8,141,27,128,69,129,133
  DEFB 8,148,36,133,67,132,66,134
  DEFB 131,134,66,135,132,8,134,34
  DEFB 131,132,130,68,8,139,40,134
  DEFB 134,8,132,37,135,130,134,7
  DEFB 8,143,67,132,3,135,3,130
  DEFB 3,128,3,64,153,21,8,151
  DEFB 45,135,70,64,152,36,64,132
  DEFB 29,64,121,49,8,143,69,128
  DEFB 131,130,132,8,36,16,129,2
  DEFB 132,2,135,2,131,2,8,33
  DEFB 19,135,70,8,33,19,132,66
  DEFB 143,8,8,30,19,133,2,134
  DEFB 2,130,2,129,2,38,90,100
  DEFB 0,3,2,1,255,8,109,25
  DEFB 145,141,136,78,8,125,41,143
  DEFB 10,64,121,37,64,135,51,8
  DEFB 113,28,147,73,8,114,28,147
  DEFB 7,8,96,22,147,7,71,22
  DEFB 123,8,123,25,142,5,143,8
  DEFB 64,121,22,64,120,18,8,96
  DEFB 29,197,226,8,96,64,244,56
  DEFB 8,39,64,247,56,33,88,4
  DEFB 97,2,99,2,101,2,107,2
  DEFB 105,3,2,103,2,105,39,2
  DEFB 67,2,65,2,67,2,53,2
  DEFB 55,2,3,53,2,55,4,10
  DEFB 255,34,88,31,42,7,1,20
  DEFB 18,4,3,42,3,36,7,10
  DEFB 1,4,34,3,32,3,34,3
  DEFB 28,3,30,3,20,3,22,3
  DEFB 16,3,10,1,6,19,2,7
  DEFB 2,11,1,8,10,7,4,6
  DEFB 7,0,11,2,5,19,255,8
  DEFB 39,8,134,218,64,34,36,16
  DEFB 197,72,7,64,255,255,255,255
  DEFB 255,255,255,255,255,255,255,255
  DEFB 199,255,255,255,255,255,255,227
  DEFB 255,255,255,255,255,255,243,255
  DEFB 255,255,255,255,255,224,255,255
  DEFB 255,255,225,253,159,255,255,255
  DEFB 255,248,255,255,255,255,255,255
  DEFB 252,255,127,255,255,255,255,143
  DEFB 63,191,255,255,255,255,253,255
  DEFB 187,255,255,255,255,248,255,214
  DEFB 127,255,255,255,249,255,255,63
  DEFB 255,255,255,246,255,255,63,255
  DEFB 255,255,249,255,255,159,255,255
  DEFB 255,240,255,255,159,255,255,255
  DEFB 241,255,255,207,255,255,255,217
  DEFB 255,191,239,255,255,255,209,127
  DEFB 191,231,255,255,255,179,127,191
  DEFB 247,255,255,255,179,127,191,251
  DEFB 255,255,255,163,127,191,247,255
  DEFB 255,255,179,127,191,231,255,255
  DEFB 255,57,127,191,207,255,255,255
  DEFB 24,255,191,207,255,255,255,28
  DEFB 255,191,159,255,255,255,28,255
  DEFB 191,183,255,255,255,13,255,189
  DEFB 227,255,255,255,134,255,124,195
  DEFB 255,255,255,196,255,126,231,255
  DEFB 255,255,192,255,254,255,255,255
  DEFB 255,192,255,251,255,255,255,255
  DEFB 192,254,248,255,255,255,255,192
  DEFB 254,248,255,255,255,255,192,190
  DEFB 124,255,255,255,255,129,190,108
  DEFB 255,255,255,255,129,30,78,255
  DEFB 255,255,255,128,30,78,248,255
  DEFB 255,255,134,62,102,192,255,255
  DEFB 255,143,62,98,192,255,255,255
  DEFB 143,126,98,192,255,255,255,31
  DEFB 255,112,192,255,255,255,31,255
  DEFB 49,192,255,255,255,63,227,49
  DEFB 192,255,255,255,63,131,49,192
  DEFB 255,255,255,127,129,49,192,255
  DEFB 255,255,127,129,56,192,255,255
  DEFB 255,127,129,56,192,255,255,241
  DEFB 255,129,60,192,255,255,128,255
  DEFB 129,28,128,255,252,0,255,1
  DEFB 156,128,255,224,0,255,1,156
  DEFB 192,255,0,0,255,1,253,192
  DEFB 248,0,0,255,31,255,255,192
  DEFB 0,0,255,255,156,255,0,0
  DEFB 0,255,255,49,255,0,0,63
  DEFB 152,255,128,255,0,3,255,220
  DEFB 31,255,255,1,255,255,255,255
  DEFB 255,255,255,255,255,255,255,255
  DEFB 255,255,255,255,255,255,255,255
  DEFB 255,255,255,255,255,255,255,255
  DEFB 255,255,255,255,255,255,255,255
  DEFB 255,255,255,255,255,255,255,255
  DEFB 255,255,255,255,0

; Picture: close-up of a hood
;
; Command list drawn by DRAWPIC; used by the fixed "answer" bubble layout at
; 33909.
  DEFB 8,255,13,132,157,135,68,130
  DEFB 233,8,202,0,133,71,134,91
  DEFB 8,183,21,135,14,132,82,132
  DEFB 15,129,78,130,8,130,97,8
  DEFB 133,31,142,111,240,56,8,255
  DEFB 162,134,181,132,254,132,110,8
  DEFB 144,158,135,68,139,17,132,73
  DEFB 133,75,134,8,131,159,130,70
  DEFB 139,175,131,70,130,82,8,164
  DEFB 49,131,142,130,72,130,9,144
  DEFB 147,8,238,43,133,23,128,67
  DEFB 130,23,134,3,8,236,51,137
  DEFB 150,173,150,128,73,149,8,129
  DEFB 218,133,5,134,72,8,243,142
  DEFB 133,142,8,207,21,128,26,8
  DEFB 223,64,133,78,142,80,132,208
  DEFB 135,10,130,76,130,12,136,205
  DEFB 128,9,8,130,138,132,74,8
  DEFB 130,137,139,82,133,149,8,156
  DEFB 155,131,23,128,4,139,24,128
  DEFB 136,130,71,133,79,130,144,132
  DEFB 10,138,74,132,74,136,138,129
  DEFB 2,132,3,138,9,135,68,128
  DEFB 209,135,12,140,199,131,5,139
  DEFB 72,132,70,131,72,8,163,148
  DEFB 134,202,130,4,129,69,8,160
  DEFB 137,130,71,128,70,8,167,145
  DEFB 134,67,131,130,130,1,128,69
  DEFB 8,164,125,135,10,135,146,129
  DEFB 90,8,193,96,136,6,129,4
  DEFB 128,70,8,192,96,132,74,132
  DEFB 201,133,71,129,5,8,167,112
  DEFB 134,9,135,76,8,175,102,131
  DEFB 19,136,15,130,136,131,148,8
  DEFB 211,108,139,71,8,211,107,131
  DEFB 10,139,160,8,153,93,128,83
  DEFB 64,162,99,64,156,145,64,166
  DEFB 142,64,199,91,64,199,68,64
  DEFB 154,113,8,195,83,132,207,134
  DEFB 139,128,8,138,73,64,176,90
  DEFB 8,190,50,130,12,143,202,128
  DEFB 72,129,90,8,222,59,135,77
  DEFB 134,203,132,72,64,205,39,8
  DEFB 240,141,133,143,8,224,109,131
  DEFB 151,165,164,129,83,64,229,122
  DEFB 64,229,145,8,230,83,131,208
  DEFB 135,203,8,243,134,128,137,8
  DEFB 243,134,135,209,143,161,131,73
  DEFB 8,238,109,130,197,145,137,129
  DEFB 208,64,242,118,64,237,85,8
  DEFB 242,129,133,203,8,245,129,133
  DEFB 141,64,242,136,8,129,112,133
  DEFB 0,8,131,113,133,6,8,135
  DEFB 112,133,14,8,130,120,133,5
  DEFB 8,130,123,133,6,8,130,126
  DEFB 133,8,8,129,130,133,6,8
  DEFB 253,135,133,7,8,253,132,133
  DEFB 10,8,252,130,133,10,8,251
  DEFB 128,133,10,8,250,126,133,5
  DEFB 8,250,123,133,3,8,249,121
  DEFB 133,5,8,248,119,133,4,8
  DEFB 247,117,133,3,8,248,113,133
  DEFB 4,8,247,111,133,3,8,248
  DEFB 107,133,6,8,248,104,133,7
  DEFB 8,248,101,133,8,8,245,101
  DEFB 133,7,8,243,100,133,3,8
  DEFB 242,98,133,4,8,240,97,133
  DEFB 2,8,239,137,133,3,8,237
  DEFB 136,133,4,8,236,135,133,5
  DEFB 8,235,133,133,5,8,233,132
  DEFB 133,8,8,233,129,133,7,8
  DEFB 230,129,133,7,8,230,126,133
  DEFB 9,8,227,126,133,8,8,227
  DEFB 123,133,11,8,228,119,133,16
  DEFB 8,228,116,133,18,8,228,113
  DEFB 133,18,8,228,110,133,18,8
  DEFB 228,107,133,18,8,228,104,133
  DEFB 18,8,228,101,133,25,8,228
  DEFB 98,133,29,8,229,94,133,29
  DEFB 8,230,90,133,29,8,242,75
  DEFB 133,29,8,239,75,133,29,8
  DEFB 239,72,133,29,8,238,70,133
  DEFB 29,8,238,67,133,29,8,237
  DEFB 65,133,29,8,237,62,133,23
  DEFB 8,237,59,133,14,8,236,57
  DEFB 133,10,8,236,54,133,10,8
  DEFB 232,46,133,10,8,230,45,133
  DEFB 8,8,229,43,133,9,8,227
  DEFB 41,133,8,8,226,39,133,9
  DEFB 8,224,38,133,7,8,222,37
  DEFB 133,5,8,221,35,133,7,8
  DEFB 220,33,133,7,8,218,32,133
  DEFB 10,8,216,31,133,10,8,215
  DEFB 29,133,10,8,213,28,133,12
  DEFB 8,212,26,133,6,8,210,25
  DEFB 133,6,8,209,23,133,7,8
  DEFB 207,22,133,7,8,205,21,133
  DEFB 6,8,202,21,133,5,8,199
  DEFB 21,133,4,8,197,20,133,4
  DEFB 8,194,20,133,3,8,191,20
  DEFB 133,2,64,129,135,8,127,135
  DEFB 132,8,8,158,58,141,153,151
  DEFB 144,131,72,64,155,71,8,104
  DEFB 175,251,254,162,15,251,254,151
  DEFB 137,214,39,207,231,32,88,0
  DEFB 45,2,47,2,45,2,47,2
  DEFB 45,2,47,2,45,2,47,2
  DEFB 53,2,55,2,53,2,55,2
  DEFB 53,2,55,2,53,2,55,2
  DEFB 53,19,2,35,2,33,2,35
  DEFB 2,33,2,35,1,255,64,113
  DEFB 159,0

