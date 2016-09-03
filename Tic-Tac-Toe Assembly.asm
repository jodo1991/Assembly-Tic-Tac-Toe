TITLE Test3.asm
; Program Description: An assembly implementation of the game "Tic-Tac-Toe."
;						Allows the user to play against a computer as well as
;						watch two computers play each other.
; Author: Joseph Dodson
; Creation Date: 5/6/2016
; Last Modified: 5/11/2016 18:24
;
; What I found with structs is that when they are created, they become their own data type
; of sorts (much like C++) and must be referenced by their struct type. For example I had to pass
; pointers to the struct type for the program to be able to reference them correctly. I also 
; found that they must be dereferenced differently. Masm still lets you use indirect operands
; with them but they must be prefaced with the type of PTR it is first like:
; (Statistics PTR[ebx]). The data members could then be accessed like normal with the . operator.

INCLUDE Irvine32.inc

StatPtr TYPEDEF PTR Statistics		;to make passing statisitic structure easier
Stat TEXTEQU <Statistics PTR>		;to make referencing statistic structure easier

PlayerPtr TYPEDEF PTR PlayerInfo	;to make passing player structure easier
Player TEXTEQU <PlayerInfo PTR>		;to make referencing player structure easier

MainMenu PROTO, grid1:PTR BYTE, rowLength:DWORD, :StatPtr, :StatPtr, P1:PlayerPtr, P2:PlayerPtr
PvCMenu PROTO, grid1:PTR BYTE, rowLength:DWORD, :StatPtr, P1:PlayerPtr, P2:PlayerPtr
CvCMenu PROTO, grid1:PTR BYTE, rowLength:DWORD, :StatPtr, P1:PlayerPtr, P2:PlayerPtr
PlayComp PROTO, grid1:PTR BYTE, rowLength:DWORD, :StatPtr, P1:PlayerPtr, P2:PlayerPtr
CompComp PROTO, grid1:PTR BYTE, rowLength:DWORD, :StatPtr, P1:PlayerPtr, P2:PlayerPtr
ChooseFirst PROTO, first:PTR BYTE, P1 : PlayerPtr, P2 : PlayerPtr
ChooseRandom PROTO, :PlayerPtr, grid1:PTR BYTE, rowLength:DWORD
TakeTurn PROTO, grid1:PTR BYTE, rowLength:DWORD, :PlayerPtr, WinIndexNums:PTR BYTE
ValidMove PROTO, grid1:PTR BYTE, rowLength:DWORD, :PlayerPtr, IsValid:PTR BYTE
SetBoard PROTO, grid1:PTR BYTE, rowLength:DWORD, :PlayerPtr
PrintBoard PROTO, grid1:PTR BYTE, rowLength:DWORD, IndexBool:BYTE, WinIndexNums:PTR BYTE
ClearBoard PROTO, grid1:PTR BYTE, rowLength:DWORD
CheckWinner PROTO, grid1:PTR BYTE, rowLength:DWORD, winner:PTR BYTE, WinIndexNums:PTR BYTE
AddWinIndexes PROTO, checkIndexes:PTR BYTE, WinIndexNums:PTR BYTE
Check3Squares PROTO, grid1:PTR BYTE, rowLength:DWORD, checkIndexes:PTR BYTE, boolWin:PTR BYTE
ChangeSquareColor PROTO, WinIndexNums:PTR BYTE, indexCount:BYTE, indicator:BYTE
PrintStats PROTO, :StatPtr, P1:PlayerPtr
ClearStats PROTO, :StatPtr

Statistics STRUCT	
	GamesPlayed BYTE 0
	GamesWonP1 BYTE 0
	GamesWonC1 BYTE 0
	GamesWonC2 BYTE 0
	TotalDraws BYTE 0
Statistics ENDS

PlayerInfo STRUCT
	PlayerType BYTE 0
	PlayerSymbol BYTE 0
	MovToRow BYTE 0
	MovToCol BYTE 0
PlayerInfo ENDS

.data ; the data segment					

Grid BYTE '-', '-', '-'		;game board
	 BYTE '-', '-', '-'
	 BYTE '-', '-', '-'

row_length DWORD 3

PvCStats Statistics <>
CvCStats Statistics <>
Player1 PlayerInfo <>
Player2 PlayerInfo <>


.code ; start code segment
main PROC

call randomize

Invoke MainMenu, ADDR Grid, row_length, ADDR PvCStats, ADDR CvCStats, ADDR Player1, ADDR Player2


exit
main ENDP ; end of main procedure



;--------------------------------------------------------------
; MainMenu
;
; Main driver menu that calls sub-menus
;
; Receives:	N/A
;
; Returns:	N/A
;-------------------------------------------------------------- 
MainMenu PROC, grid1:PTR BYTE, rowLength:DWORD, Pstats:StatPtr, Cstats:StatPtr, P1:PlayerPtr, P2:PlayerPtr

.data
	PstatsHeader BYTE "Player Vs. Computer Stats", 13, 10,
						"------------------------------", 13, 10, 0
	CstatsHeader BYTE "Computer Vs. Computer Stats", 13, 10,
						"------------------------------", 13, 10, 0

	menuPrompt BYTE "1. Player Vs. Computer", 13, 10,
					"2. Computer Vs. Computer", 13, 10,
					"3. Show All Stats", 13, 10,
					"4. Clear All Stats", 13, 10,
					"5. Exit", 13, 10,
					"Please enter a choice: ", 0

.code
	mov esi, P1
	mov edi, P2


	MENU:
		call clrscr						;display menu
		mov edx, OFFSET menuPrompt
		call WriteString
		call readint


		cmp eax, 1						;range error checking
		jl MENU
		je option1
		cmp eax, 2
		je option2
		cmp eax, 3
		je option3
		cmp eax, 4
		je option4
		cmp eax, 5
		jg MENU
		jmp option5


		option1:
		Invoke PvCMenu, grid1,  rowLength, Pstats, P1, P2		;start player vs computer game
		jmp MENU


		option2:
		Invoke CvCMenu, grid1, rowLength, Cstats, P1, P2		;start computer vs computer game
		jmp MENU


		option3:				;print stats
		call clrscr
		mov edx, OFFSET PstatsHeader
		call WriteString
		mov (Player[esi]).PlayerType, 'P'
		Invoke PrintStats, Pstats, P1

		mov edx, OFFSET CstatsHeader
		call WriteString
		mov (Player[esi]).PlayerType, 'C'
		Invoke PrintStats, Cstats, P1
		call waitmsg
		jmp MENU


		option4:			;clear stats for both game types
		Invoke ClearStats, Pstats
		Invoke ClearStats, Cstats
		jmp MENU


	option5:
	call clrscr
	ret

MainMenu ENDP




;--------------------------------------------------------------
; PvCMenu
;
; Player Vs. Computer menu.
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
PvCMenu PROC, grid1:PTR BYTE, rowLength:DWORD, stats:StatPtr, P1:PlayerPtr, P2:PlayerPtr

.data
	PvCHeader BYTE "Player Vs. Computer", 13, 10,
					"------------------------", 13, 10, 0
	repeatPrompt BYTE	"1. Play Again", 13, 10,
						"2. Show Statistics", 13, 10,
						"3. Clear PvC Statistics", 13, 10,
						"4. Return to Main Menu", 13, 10,
						"Please enter a choice: ", 0

.code
	mov esi, P1
	mov edi, P2
	mov edx, stats
	mov ebx, grid1
	add ebx, rowLength


	PlayAgain:
		Invoke ClearBoard, grid1, rowLength				;clear board from any previous games
		Invoke PlayComp, grid1, rowLength, stats, P1, P2

	MENU:						;player vs computer menu
		call clrscr
		mov edx, OFFSET PvCHeader
		call WriteString
		mov edx, OFFSET repeatPrompt
		call WriteString
		call readint
		
		cmp eax, 1			;range error checking
		jl MENU
		je option1
		cmp eax, 2
		je option2
		cmp eax, 3
		je option3
		cmp eax, 4
		jg MENU
		jmp option4


		option1:
		jmp PlayAgain

		option2:			;print stats for PvC
		call clrscr
		mov edx, OFFSET PvCHeader
		call WriteString
		Invoke PrintStats, stats, P1
		call waitmsg
		jmp MENU

		option3:			;clear PvC stats
		Invoke ClearStats, stats
		jmp MENU

		option4:
		call clrscr			;display PvC stats on exit
		Invoke PrintStats, stats, P1
		call waitmsg

	ret
PvCMenu ENDP





;--------------------------------------------------------------
; CvCMenu
;
; Computer Vs. Computer Menu
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
CvCMenu PROC, grid1:PTR BYTE, rowLength:DWORD, stats:StatPtr, P1:PlayerPtr, P2:PlayerPtr

.data
	CvCHeader BYTE "Computer Vs. Computer", 13, 10,
					"------------------------", 13, 10, 0
	repeatPrompt1 BYTE	"1. Play Again", 13, 10,
						"2. Show Statistics", 13, 10,
						"3. Clear CvC Statistics", 13, 10,
						"4. Return to Main Menu", 13, 10,
						"Please enter a choice: ", 0

.code
	mov esi, P1
	mov edi, P2
	mov edx, stats
	mov ebx, grid1
	add ebx, rowLength

	PlayAgain:
		Invoke ClearBoard, grid1, rowLength
		Invoke CompComp, grid1, rowLength, stats, P1, P2

	MENU:						;computer vs computer menu
		call clrscr
		mov edx, OFFSET CvCHeader
		call clrscr
		mov edx, OFFSET repeatPrompt1
		call WriteString
		call readint

		cmp eax, 1				;range error checking
		jl MENU
		je option1
		cmp eax, 2
		je option2
		cmp eax, 3
		je option3
		cmp eax, 4
		jg MENU
		jmp option4


		option1:
		jmp PlayAgain

		option2:			;print CvC stats
		call clrscr
		call clrscr
		mov edx, OFFSET CvCHeader
		call WriteString
		Invoke PrintStats, stats, P1
		call waitmsg
		jmp MENU

		option3:			;clear only CvC stats
		Invoke ClearStats, stats
		jmp MENU

		option4:			;display CvC stats on exit
		call clrscr
		Invoke PrintStats, stats, P1
		call waitmsg

	ret
CvCMenu ENDP





;--------------------------------------------------------------
; PlayComp
;
; Main driving function for a player vs. computer game. Calls 
; all other necessary game procedure.
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
PlayComp PROC, grid1:PTR BYTE, rowLength:DWORD, stats:StatPtr, P1:PlayerPtr, P2:PlayerPtr
LOCAL firstP:BYTE, isWinner:BYTE, WinIndexNums[7]:BYTE
	push ebx
	push ecx
	push esi
	push edi

.data
	drawMsg BYTE "The game is a draw.", 0
	P1Msg BYTE "You win!", 0
	P2Msg BYTE "The computer won...You got wrecked Diane! :)", 0
	ComChoosing BYTE "C3PO is choosing, please wait while it computes...", 0
	

.code
	mov esi, P1
	mov edi, P2
	mov isWinner, 0

	mov ecx, 7			;initialize winning game array to prevent random errors
	Initialize:
		mov [WinIndexNums+ecx-1], '-'
		loop Initialize


	mov	(Player[esi]).PlayerType, 'P'	;set player types for PvC game
	mov (Player[edi]).PlayerType, 'C'
	
	mov ecx, 9
	Invoke ChooseFirst, ADDR firstP, P1, P2		;pick first player and jump to 
	cmp firstP, 2								;correct place in loop
	je P2Turn

	P1Turn:
		Invoke TakeTurn, grid1, rowLength, P1, ADDR WinIndexNums					;player take turn and check for winner until draw
		Invoke CheckWinner, grid1, rowLength, ADDR isWinner, ADDR WinIndexNums
		cmp isWinner, 1
		je P1Winner
		dec ecx
		jnz P2Turn
		jmp Draw
	P2Turn:
		call clrscr													;computer take turn and check for winner until draw
		Invoke TakeTurn, grid1, rowLength, P2, ADDR WinIndexNums
		
		mov edx, OFFSET ComChoosing
		call WriteString										;simulate computer "choosing" a spot

		mov al, (Player[edi]).PlayerSymbol
		push eax												;display computers symbol in correct color to reference
		Invoke ChangeSquareColor, ADDR WinIndexNums, 0, al
		pop eax
		call writechar
		Invoke ChangeSquareColor, ADDR WinIndexNums, 0, 'B'

		mov eax, 750											;simulate time taken for computer to choose spot
		call delay

		call clrscr
		Invoke PrintBoard, grid1, rowLength, 0, ADDR WinIndexNums		;display new board
		call crlf
		
		mov edx, OFFSET ComMadeMove
		call WriteString					;tell user computer made move, leave board up for 1 second
		mov eax, 1000
		call delay

		Invoke CheckWinner, grid1, rowLength, ADDR isWinner, ADDR WinIndexNums		;check for winner
		cmp isWinner, 1
		je P2Winner
		dec ecx
		jnz P1Turn
	


	Draw:							;print filled board and indicate draw
	call clrscr
	mov edx, OFFSET drawMsg
	call WriteString
	call crlf
	call crlf
	Invoke PrintBoard, grid1, rowLength, 0, ADDR WinIndexNums
	call crlf
	mov ebx, stats
	add (Stat[ebx]).GamesPlayed, 1
	add (Stat[ebx]).TotalDraws, 1
	call waitmsg
	jmp GameEnd



	P1Winner:						;print board and indicate player won with highlighted winning path
	call clrscr
	mov edx, OFFSET P1Msg
	call WriteString
	call crlf
	call crlf
	Invoke PrintBoard, grid1, rowLength, 0, ADDR WinIndexNums
	call crlf
	mov ebx, stats
	add (Stat[ebx]).GamesPlayed, 1
	add (Stat[ebx]).GamesWonP1, 1
	call waitmsg
	jmp GameEnd


	P2Winner:						;print board and indicate computer won with highlighted winning path
	call clrscr
	mov edx, OFFSET P2Msg
	call WriteString
	call crlf
	call crlf
	Invoke PrintBoard, grid1, rowLength, 0, ADDR WinIndexNums
	call crlf
	mov ebx, stats
	add (Stat[ebx]).GamesPlayed, 1
	add (Stat[ebx]).GamesWonC1, 1
	call waitmsg
	jmp GameEnd


	GameEnd:
	pop edi
	pop esi
	pop ecx
	pop ebx
	ret
PlayComp ENDP




;--------------------------------------------------------------
; CompComp
;
; Main driving function for a simulated computer vs. computer game. 
; Calls all other necessary game procedure.
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
CompComp PROC, grid1:PTR BYTE, rowLength:DWORD, stats:StatPtr, P1:PlayerPtr, P2:PlayerPtr
LOCAL firstP:BYTE, isWinner:BYTE, WinIndexNums[7]:BYTE
	push ebx
	push ecx
	push esi
	push edi

.data
	drawMsgC BYTE "The game is a draw.", 0
	C1Msg BYTE "Computer 1 won!", 0
	C2Msg BYTE "Computer 2 won!", 0
	Com1Choosing BYTE "Computer 1 is choosing. Its symbol is: ", 0
	Com2Choosing BYTE "Computer 2 is choosing. Its symbol is: ", 0
	ComMadeMove BYTE "The Computer made his move.", 0
	

.code
	mov esi, P1
	mov edi, P2
	mov isWinner, 0

	mov ecx, 7
	Initialize:							;initialize winning index array to prevent random errors
		mov [WinIndexNums+ecx-1], '-'
		loop Initialize


	mov	(Player[esi]).PlayerType, 'C'	;set up player types for CvC
	mov (Player[edi]).PlayerType, 'C'
	
	mov ecx, 9
	Invoke ChooseFirst, ADDR firstP, P1, P2
	cmp firstP, 2								;pick a first computer to go
	je C2Turn

	C1Turn:								;repeats same process for C1 and C2
		call clrscr
		Invoke TakeTurn, grid1, rowLength, P1, ADDR WinIndexNums		;computer takes its turn
		
		mov edx, OFFSET Com1Choosing
		call WriteString

		mov al, (Player[esi]).PlayerSymbol
		push eax
		Invoke ChangeSquareColor, ADDR WinIndexNums, 0, al				;display computers symbol in appropriate color
		pop eax
		call writechar
		Invoke ChangeSquareColor, ADDR WinIndexNums, 0, 'B'

		mov eax, 750													;simulate wait for picking a spot
		call delay

		call clrscr
		Invoke PrintBoard, grid1, rowLength, 0, ADDR WinIndexNums		;print new board
		call crlf

		mov edx, OFFSET ComMadeMove
		call WriteString
		mov eax, 2000													;indicate computer made choice and leave for 2 seconds
		call delay

		Invoke CheckWinner, grid1, rowLength, ADDR isWinner, ADDR WinIndexNums
		cmp isWinner, 1
		je C1Winner
		dec ecx							;check winner
		jnz C2Turn
		jmp Draw

	C2Turn:				;repeat from C1
		call clrscr
		Invoke TakeTurn, grid1, rowLength, P2, ADDR WinIndexNums
		
		mov edx, OFFSET Com2Choosing
		call WriteString

		mov al, (Player[edi]).PlayerSymbol
		push eax
		Invoke ChangeSquareColor, ADDR WinIndexNums, 0, al
		pop eax
		call writechar
		Invoke ChangeSquareColor, ADDR WinIndexNums, 0, 'B'

		mov eax, 750
		call delay

		call clrscr
		Invoke PrintBoard, grid1, rowLength, 0, ADDR WinIndexNums
		call crlf
		
		mov edx, OFFSET ComMadeMove
		call WriteString
		mov eax, 2000
		call delay

		Invoke CheckWinner, grid1, rowLength, ADDR isWinner, ADDR WinIndexNums
		cmp isWinner, 1
		je C2Winner
		dec ecx
		jnz C1Turn
	


	Draw:			;incidicate draw, print board
	call clrscr
	mov edx, OFFSET drawMsg
	call WriteString
	call crlf
	call crlf
	Invoke PrintBoard, grid1, rowLength, 0, ADDR WinIndexNums
	call crlf
	mov ebx, stats
	add (Stat[ebx]).GamesPlayed, 1
	add (Stat[ebx]).TotalDraws, 1
	call waitmsg
	jmp GameEnd

	
	C1Winner:			;indicate computer 1 winner, print board with highlighted path
	call clrscr
	mov edx, OFFSET C1Msg
	call WriteString
	call crlf
	call crlf
	Invoke PrintBoard, grid1, rowLength, 0, ADDR WinIndexNums
	call crlf
	mov ebx, stats
	add (Stat[ebx]).GamesPlayed, 1
	add (Stat[ebx]).GamesWonC1, 1
	call crlf
	call waitmsg
	jmp GameEnd


	C2Winner:			;indicate computer 2 winner, print board with highlighted path
	call clrscr
	mov edx, OFFSET C2Msg
	call WriteString
	call crlf
	call crlf
	Invoke PrintBoard, grid1, rowLength, 0, ADDR WinIndexNums
	call crlf
	mov ebx, stats
	add (Stat[ebx]).GamesPlayed, 1
	add (Stat[ebx]).GamesWonC2, 1
	call crlf
	call waitmsg
	jmp GameEnd


	GameEnd:			
	pop edi
	pop esi
	pop ecx
	pop ebx
	ret

ret
CompComp ENDP




;--------------------------------------------------------------
; ChooseFirst
;
; Randomly choose a player to go first and initializes their
; symbol to X or O. Also sets a bool to indicate which is first.
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
ChooseFirst PROC, first:PTR BYTE, P1:PlayerPtr, P2:PlayerPtr
	push esi
	push edi

.data
	choosingFirst BYTE "Randomly choosing first player...", 0
	computerFirst BYTE "The computer will choose first.", 0
	playerFirst BYTE "You will go first!", 0
	c1First BYTE "Computer 1 will go first.", 0
	c2First BYTE "Computer 2 will go first.", 0

.code
	call clrscr
	mov edx, OFFSET choosingFirst
	call WriteString
	mov eax, 500				;simulate wait to display first player is being chosen randomly
	call delay

	mov esi, P1
	mov edi, P2

	mov eax, 2					;get random number
	call randomrange
	inc eax

	cmp eax, 1
	je P1First

	;player2 first
	call clrscr
	cmp (Player[esi]).PlayerType, 'P'
	je PvCGame
	mov edx, OFFSET c2First
	jmp WriteMsg

	PvCGame:						;change message for pvc game
	mov edx, OFFSET computerFirst

	WriteMsg:
	call WriteString
	call crlf
	call waitmsg
	mov (Player[edi]).PlayerSymbol, 'X'		;set symbols appropriately
	mov (Player[esi]).PlayerSymbol, 'O'
	mov edx, first
	mov byte ptr [edx], 2
	jmp End1

	P1First: 
	call clrscr
	cmp (Player[esi]).PlayerType, 'P'
	je PvCGame1
	mov edx, OFFSET c1First
	jmp WriteMsg1

	PvCGame1:						;change message for pvc game
	mov edx, OFFSET playerFirst

	WriteMsg1:
	call WriteString
	call crlf
	call waitmsg
	mov (Player[esi]).PlayerSymbol, 'X'		;set symbols appropriately
	mov (Player[edi]).PlayerSymbol, 'O'
	mov edx, first
	mov byte ptr [edx], 1
	

	End1:
	pop edi
	pop esi
	ret

ChooseFirst ENDP




;--------------------------------------------------------------
; ChooseRandom
;
; Computer simulation helper procedure. Randomly chooses a spot
; on the board. Is verified later by ValidMove procedure
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
ChooseRandom PROC, P:PlayerPtr, grid1:PTR BYTE, rowLength:DWORD
LOCAL row_index:DWORD, col_index:DWORD
	
	push ebx
	push esi
	push edi

	mov row_index, 1			;set to center first to check
	mov col_index, 1
	mov edi, P
	mov ebx, grid1
	mov eax, rowLength

	mul row_index				;check center of board to see if empty
	add ebx, eax
	mov esi, col_index
	cmp BYTE PTR [ebx + esi], '-'			
	jne CenterFull
	mov (Player[edi]).MovToRow, 1		;if center is open, make computer move there
	mov (Player[edi]).MovTocol, 1
	jmp End1

	CenterFull:							;else pick a random spot
	mov eax, 3
	call randomrange
	mov (Player[edi]).MovToRow, al
	mov eax, 3
	call randomrange
	mov (Player[edi]).MovTocol, al


	End1:
	pop edi
	pop esi
	pop ebx
	ret

ChooseRandom ENDP






;--------------------------------------------------------------
; TakeTurn
;
; Procedure that handles the action of taking a turn. Gets a move,
; validates, and sets the board if valid. Adapts based on computer
; or human turn.
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
TakeTurn PROC, grid1:PTR BYTE, rowLength:DWORD, P:PlayerPtr, WinIndexNums:PTR BYTE
LOCAL valid:BYTE
	push ebx
	push esi

.data
	playerHeader BYTE "Player 1 - Your Symbol: ", 0
	userPrompt BYTE "Please choose a corresponding number: ", 0
	errorMove BYTE "Invalid index number. Please try again: ", 0
.code
	mov ebx, grid1
	add ebx, rowLength
	mov esi, P

	cmp (Player[esi]).PlayerType, 'C'
	je ComputerTurn


	;player taking turn
	call clrscr

	InvalidMove:												;loop until a valid move is made
		Invoke PrintBoard, grid1, rowLength, 1, WinIndexNums
		call crlf

		mov edx, OFFSET playerHeader
		call WriteString										;indicate players turn and player symbol
		mov al, (Player[esi]).PlayerSymbol
		push eax
		Invoke ChangeSquareColor, WinIndexNums, 0, al			;display players symbol in correct color
		pop eax
		call writechar
		Invoke ChangeSquareColor, WinIndexNums, 0, 'B'
		call crlf
		mov edx, OFFSET userPrompt
		call WriteString
		call readint

		cmp eax, 1					;check if within range first
		jae InRange
		jmp ErrorDisp
		cmp eax, 9
		jbe ErrorDisp


		InRange:

		dec eax

		mov edx, 0					;then check board to see if open
		div rowLength
		mov (Player[esi]).MovToRow, al
		mov (Player[esi]).MovToCol, dl

		Invoke ValidMove, grid1, rowLength, P, ADDR valid

		cmp valid, 1
		je Valid_Move

	ErrorDisp:
		call clrscr					;indicate a bad move was made and reprompt
		mov edx, OFFSET errorMove
		call WriteString
		call crlf
		call crlf
		jmp InvalidMove

	Valid_Move:
		Invoke SetBoard, grid1, rowLength, P		;if valid move, set the board
		ret



	ComputerTurn:
		Invoke PrintBoard, grid1, rowLength, 0, WinIndexNums		;print board for user
		call crlf

	InvalidMoveC:

		Invoke ChooseRandom, P, grid1, rowLength					;keep choosing random index numbers until
		Invoke ValidMove, grid1, rowLength, P, ADDR valid			;valid move is made

		cmp valid, 1
		je Valid_MoveC
		jmp InvalidMoveC

		Valid_MoveC:
		Invoke SetBoard, grid1, rowLength, P						;when valid move is made, set board


	pop esi
	pop ebx
	ret
TakeTurn ENDP




;--------------------------------------------------------------
; ValidMove
;
; Simple procedure to validate a move. Sets a bool to indicate
; validity.
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
ValidMove PROC, grid1:PTR BYTE, rowLength:DWORD, P:PlayerPtr, IsValid:PTR BYTE
	push ebx
	push esi

	mov ebx, grid1
	add ebx, rowLength
	mov esi, P
	mov edx, IsValid

	mov al, (Player[esi]).MovToRow

	mov ebx, grid1						;algorithm to change index number into grid offset
	mov eax, rowLength
	mul (Player[esi]).MovToRow
	add ebx, eax
	movzx esi, (Player[esi]).MovToCol
	mov al, [ebx + esi]

	cmp al, '-'						;if not empty, '-', indicate move is invalid
	jne InvalidMove
	mov BYTE PTR [edx], 1			;else, indicate valid move
	ret

	InvalidMove:
	mov BYTE PTR [edx], 0

	pop esi
	pop ebx
	ret
ValidMove ENDP




;--------------------------------------------------------------
; SetBoard
;
; Simple procedure that takes a move and sets the grid with the
; appropriate symbol
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
SetBoard PROC, grid1:PTR BYTE, rowLength:DWORD, P:PlayerPtr
	push esi
	push edi
	push ebx

	mov ebx, grid1				;algorithm to change index number into grid offset
	mov eax, rowLength
	mov edi, P
	mul (Player[edi]).MovToRow
	add ebx, eax
	movzx esi, (Player[edi]).MovToCol
	mov al, (Player[edi]).PlayerSymbol
	mov BYTE PTR [ebx + esi], al			;move player symbol to spot on grid

	pop ebx
	pop edi
	pop esi
	ret
SetBoard ENDP




;--------------------------------------------------------------
; PrintBoard
;
; Main print procedure for game board. Prints character symbols in
; a pre-set color. Also takes a bool to indicate if corresponding
; index numbers should be displayed in the empty spots.
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
PrintBoard PROC, grid1:PTR BYTE, rowLength:DWORD, IndexBool:BYTE, WinIndexNums:PTR BYTE
LOCAL row_index:DWORD, col_index:DWORD, displayIndex:BYTE, indexCount:BYTE
	push esi
	push edi
	push ebx
	push ecx

	mov row_index, 0
	mov col_index, 0
	mov displayIndex, '1'		;for displaying index numbers instead of '-'
	mov dl, indexBool
	mov indexCount, 0			;for passing to changecolor proc to check for winning indexes

	mov ecx, 9
	GridLoop:
		mov ebx, grid1			;algorithm to change index number into grid offset
		mov eax, rowLength
		mul row_index
		add ebx, eax
		mov esi, col_index
		mov al, [ebx + esi]
		
		cmp al, 'X'				;see which color to change to, if any
		je changeXcolor
		cmp al, 'O'
		je changeOcolor

		cmp IndexBool, 0		;no color change, see if index numbers should be displayed
		je DisplayChar

		mov al, displayIndex
		jmp DisplayChar

		changeOcolor:
		push eax
		Invoke ChangeSquareColor, WinIndexNums, indexCount, 'O'
		pop eax
		jmp DisplayChar

		changeXcolor:
		push eax
		Invoke ChangeSquareColor, WinIndexNums, indexCount, 'X'
		pop eax
		
		DisplayChar:
		call writechar			;display final character in appropriate character
		push eax
		Invoke ChangeSquareColor, WinIndexNums, indexCount, 'B'		;write character, change back to black and white if needed
		pop eax
		inc col_index
		inc displayIndex				;inc counter variables
		inc indexCount

		cmp col_index, 3			;indicate if new row is needed or '|' character
		je NewRow
		mov al, '|'
		call writechar
		dec ecx
		jnz GridLoop
		jmp FinishLoop

		NewRow:					;make new row 
		mov col_index, 0
		inc row_index
		call crlf
		dec ecx
		jnz GridLoop
		jmp FinishLoop


	FinishLoop:

	pop ecx
	pop ebx
	pop edi
	pop esi
	ret
PrintBoard ENDP




;--------------------------------------------------------------
; ClearBoard
;
; Simple clear procedure to set all spots on game board to '-'
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
ClearBoard PROC, grid1:PTR BYTE, rowLength:DWORD
LOCAL row_index:DWORD, col_index:DWORD
	push ebx
	push ecx
	push esi

	mov row_index, 0
	mov col_index, 0
	mov ecx, 9
	GridLoop:
		mov ebx, grid1				;algorithm to change index number into grid offset
		mov eax, rowLength
		mul row_index
		add ebx, eax
		mov esi, col_index
		mov BYTE PTR [ebx + esi], '-'
		inc col_index


		cmp col_index, 3			;need to keep track of row and col so proc can maintain use of base-index operands
		je NewRow
		loop GridLoop

		NewRow:
		mov col_index, 0
		inc row_index
		loop GridLoop
	

	pop esi
	pop ecx
	pop ebx
	ret
ClearBoard ENDP




;--------------------------------------------------------------
; CheckWinner
;
; Procedure that checks every possible winning combination and 
; adds the winning index numbers to an array, if any. Also sets
; a bool to indicate if a winner was found.
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
CheckWinner PROC, grid1:PTR BYTE, rowLength:DWORD, winner:PTR BYTE, WinIndexNums:PTR BYTE
LOCAL checkIndexes[3]:BYTE, ThreeinRow:BYTE
	push ebx
	push edi


	mov ebx, grid1
	add ebx, rowLength
	mov eax, winner
	mov edi, WinIndexNums
	
									;repeated for each possible winning direction
	;//check row1
	mov checkIndexes, 0			;set three index numbers
	mov checkIndexes+1, 1
	mov checkIndexes+2, 2
	Invoke Check3Squares, grid1, rowLength, ADDR checkIndexes, ADDR ThreeinRow
	cmp ThreeinRow, 0			;see if 3 index numbers contain three non empty symbols in a row
	je NoWinnerR1
	Invoke AddWinIndexes, ADDR checkIndexes, WinIndexNums		;add to winning array if needed
	mov eax, winner
	mov BYTE PTR [eax], 1		;indicate a winner was found
	NoWinnerR1:

	;//check row2
	mov checkIndexes, 3
	mov checkIndexes+1, 4
	mov checkIndexes+2, 5
	Invoke Check3Squares, grid1, rowLength, ADDR checkIndexes, ADDR ThreeinRow
	cmp ThreeinRow, 0
	je NoWinnerR2
	Invoke AddWinIndexes, ADDR checkIndexes, WinIndexNums
	mov eax, winner
	mov BYTE PTR [eax], 1
	NoWinnerR2:

	;//check row3
	mov checkIndexes, 6
	mov checkIndexes+1, 7
	mov checkIndexes+2, 8
	Invoke Check3Squares, grid1, rowLength, ADDR checkIndexes, ADDR ThreeinRow
	cmp ThreeinRow, 0
	je NoWinnerR3
	Invoke AddWinIndexes, ADDR checkIndexes, WinIndexNums
	mov eax, winner
	mov BYTE PTR [eax], 1
	NoWinnerR3:

	;//check col1
	mov checkIndexes, 0
	mov checkIndexes+1, 3
	mov checkIndexes+2, 6
	Invoke Check3Squares, grid1, rowLength, ADDR checkIndexes, ADDR ThreeinRow
	cmp ThreeinRow, 0
	je NoWinnerC1
	Invoke AddWinIndexes, ADDR checkIndexes, WinIndexNums
	mov eax, winner
	mov BYTE PTR [eax], 1
	NoWinnerC1:

	;//check col2
	mov checkIndexes, 1
	mov checkIndexes+1, 4
	mov checkIndexes+2, 7
	Invoke Check3Squares, grid1, rowLength, ADDR checkIndexes, ADDR ThreeinRow
	cmp ThreeinRow, 0
	je NoWinnerC2
	Invoke AddWinIndexes, ADDR checkIndexes, WinIndexNums
	mov eax, winner
	mov BYTE PTR [eax], 1
	NoWinnerC2:

	;//check col3
	mov checkIndexes, 2
	mov checkIndexes+1, 5
	mov checkIndexes+2, 8
	Invoke Check3Squares, grid1, rowLength, ADDR checkIndexes, ADDR ThreeinRow
	cmp ThreeinRow, 0
	je NoWinnerC3
	Invoke AddWinIndexes, ADDR checkIndexes, WinIndexNums
	mov eax, winner
	mov BYTE PTR [eax], 1
	NoWinnerC3:

	;//check diag1
	mov checkIndexes, 0
	mov checkIndexes+1, 4
	mov checkIndexes+2, 8
	Invoke Check3Squares, grid1, rowLength, ADDR checkIndexes, ADDR ThreeinRow
	cmp ThreeinRow, 0
	je NoWinnerD1
	Invoke AddWinIndexes, ADDR checkIndexes, WinIndexNums
	mov eax, winner
	mov BYTE PTR [eax], 1
	NoWinnerD1:

	;//check diag2
	mov checkIndexes, 2
	mov checkIndexes+1, 4
	mov checkIndexes+2, 6
	Invoke Check3Squares, grid1, rowLength, ADDR checkIndexes, ADDR ThreeinRow
	cmp ThreeinRow, 0
	je NoWinnerD2
	Invoke AddWinIndexes, ADDR checkIndexes, WinIndexNums
	mov eax, winner
	mov BYTE PTR [eax], 1
	NoWinnerD2:


	pop edi
	pop ebx
	ret
CheckWinner ENDP





;--------------------------------------------------------------
; Check3Squares
;
; Helper procedure for CheckWinner. Takes 3 index numbers and 
; checks to see if it contains 3 consecutive player symbols.
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
Check3Squares PROC, grid1:PTR BYTE, rowLength:DWORD, checkIndexes:PTR BYTE, boolWin:PTR BYTE
	push ebx
	push esi
	push edi
	push ecx

	mov edi, checkIndexes
	mov ecx, 2
	Check3:
		;index 1
		movzx eax, BYTE PTR [edi]		;get row in ax, col in dl
		mov edx, 0
		div rowLength
		movzx esi, dl

		mul rowLength				;set position on grid
		mov ebx, grid1
		add ebx, eax
		mov al, [ebx + esi]
		cmp al, '-'
		je NoWinner
		inc edi

		;index 2 
		push eax
		movzx eax, BYTE PTR [edi]		;get row in ax, col in dl
		mov edx, 0
		div rowLength
		movzx esi, dl

		mul rowLength				;set position on grid
		mov ebx, grid1
		add ebx, eax
		mov dl, [ebx + esi]
		pop eax

		cmp al, dl
		jne NoWinner
		loop Check3

	;found 3 in a row
	mov esi, boolWin
	mov BYTE PTR [esi], 1
	je Winner

	NoWinner:
	mov esi, boolWin
	mov BYTE PTR [esi], 0

	Winner:
	pop ecx
	pop edi
	pop esi
	pop ebx
	ret
Check3Squares ENDP





;--------------------------------------------------------------
; AddWinIndexes
;
; Simple helper function that adds winning index numbers to master
; winning index array. Checks to make sure the new index numbers 
; arent already in array. Allows game to overcome possible issue
; of overlapping winning paths.
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
AddWinIndexes PROC, checkIndexes:PTR BYTE, WinIndexNums:PTR BYTE
	push esi
	push edi
	push ecx


	mov esi, checkIndexes
	mov edi, WinIndexNums

	mov ecx, 3
	L1:
		mov al, [esi]			;index to check in al
		push ecx
		push edi
		mov ecx, 7
		L2:						;loop through all winning indexes
			mov dl, [edi]		;existing winning indexes in dl
			cmp al, dl
			je AlreadyExists	;if already in array, continue loop with next index to check
			inc edi
			loop L2

		mov edi, WinIndexNums
		mov ecx, 7
		L3:						;find the next empty spot in the array to put winning index
			mov dl, [edi]
			cmp dl, '-'
			je FoundEmpty
			inc edi
			loop L3

		FoundEmpty:
		mov [edi], al			;move the number into the winning array

		AlreadyExists:
		pop edi					
		pop ecx					;restore L1 counter
		inc esi
		loop L1


	pop ecx
	pop edi
	pop esi
	ret
AddWinIndexes ENDP





;--------------------------------------------------------------
; ChangeSquareColor
;
; Helper procedure that takes a number to indicate what color to
; change to. B-white on black, X-white on blue, O-white on red.
; Automatically changes to white on yellow if "indexCount" is in
; winning number array.
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
ChangeSquareColor PROC, WinIndexNums:PTR BYTE, indexCount:BYTE, indicator:BYTE
	push esi
	push ecx
	push ebx

	mov esi, WinIndexNums
	mov bl, indexCount
	mov ecx, 7

	cmp indicator, 'B'		;change to white on black
	je Reset

	L1:
		mov dl, [esi]
		cmp dl, bl
		je WinnerSquare
		inc esi
		loop L1
	
	cmp indicator, 'X'		;change to white on blue
	je changeX
	


	;changeO					
	mov eax, white + (red * 16)		;change to white on red
	call SetTextColor
	jmp ReturnF

	changeX:
	mov eax, white + (blue * 16)
	call SetTextColor
	jmp ReturnF

	Reset:
	mov eax, white + (black * 16)
	call SetTextColor
	jmp ReturnF
	
	WinnerSquare:
	mov eax, black + (yellow * 16)
	call SetTextColor


	ReturnF:
	pop ebx
	pop ecx
	pop esi
	ret
ChangeSquareColor ENDP




;--------------------------------------------------------------
; PrintStats
;
; Simple helper procedure to print statistics of games.
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
PrintStats PROC, stats:StatPtr, P1:PlayerPtr

.data
	NumGames BYTE "Number of Games Played: ", 0
	PlayWins BYTE "Player Wins: ", 0
	ComputerWins BYTE "Computer Wins: ", 0
	Computer1Wins BYTE "Computer 1 Wins: ", 0
	Computer2Wins BYTE "Computer 2 Wins: ", 0
	TotalDraws BYTE "Draws: ", 0

.code
	mov esi, P1
	mov ebx, stats

	cmp (Player[esi]).PlayerType, 'P'		;move to display appropriate headers for game type
	je PvC



	;CvC	
	mov edx, OFFSET NumGames				;display computer vs computer stats
	call WriteString
	movzx eax, (Stat[ebx]).GamesPlayed
	call writedec
	call crlf

	mov edx, OFFSET Computer1Wins
	call WriteString
	movzx eax, (Stat[ebx]).GamesWonC1
	call writedec
	call crlf

	mov edx, OFFSET Computer2Wins
	call WriteString
	movzx eax, (Stat[ebx]).GamesWonC2
	call writedec
	call crlf

	mov edx, OFFSET TotalDraws
	call WriteString
	movzx eax, (Stat[ebx]).TotalDraws
	call writedec
	call crlf
	call crlf

	ret




	PvC:
	mov edx, OFFSET NumGames					;display player vs computer stats
	call WriteString
	movzx eax, (Stat[ebx]).GamesPlayed
	call writedec
	call crlf

	mov edx, OFFSET PlayWins
	call WriteString
	movzx eax, (Stat[ebx]).GamesWonP1
	call writedec
	call crlf

	mov edx, OFFSET ComputerWins
	call WriteString
	movzx eax, (Stat[ebx]).GamesWonC1
	call writedec
	call crlf

	mov edx, OFFSET TotalDraws
	call WriteString
	movzx eax, (Stat[ebx]).TotalDraws
	call writedec
	call crlf
	call crlf

	ret

PrintStats ENDP



;--------------------------------------------------------------
; ClearStats
;
; Simple helper procedure to clear the statistics.
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
ClearStats PROC, stats:StatPtr
	push esi

	mov esi, stats

	mov (Stat[esi]).GamesPlayed, 0
	mov (Stat[esi]).GamesWonP1, 0
	mov (Stat[esi]).GamesWonC1, 0
	mov (Stat[esi]).GamesWonC2, 0
	mov (Stat[esi]).TotalDraws, 0

	pop esi
	ret
ClearStats ENDP

end MAIN ; end of source code