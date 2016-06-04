TITLE tictactoe.asm
; Program Description:
; Author: Joseph Dodson
; Creation Date: 

INCLUDE Irvine32.inc

StatP TYPEDEF PTR Statistics
Stats TEXTEQU <Statistics PTR>

PlayerP TYPEDEF PTR PlayerInfo
Player TEXTEQU <PlayerInfo PTR>

MainMenu PROTO, grid1:PTR BYTE, gridRow:DWORD, :StatP, P1:PlayerP, P2:PlayerP
PlayComp PROTO, grid1:PTR BYTE, gridRow:DWORD, :StatP, P1:PlayerP, P2:PlayerP
CompComp PROTO, grid1:PTR BYTE, gridRow:DWORD, :StatP, P1:PlayerP, P2:PlayerP
ChooseFirst PROTO, first:BYTE
ChooseRandom PROTO, :PlayerP
SimulateWait PROTO
TakeTurn PROTO, grid1:PTR BYTE, gridRow:DWORD, :PlayerP
ValidMove PROTO, grid1:PTR BYTE, gridRow:DWORD, :PlayerP
SetBoard PROTO, grid1:PTR BYTE, gridRow:DWORD, :PlayerP
PrintBoard PROTO, grid1:PTR BYTE, gridRow:DWORD
ClearBoard PROTO, grid1:PTR BYTE, gridRow:DWORD
CheckWinner PROTO, grid1:PTR BYTE, gridRow:DWORD
HighlightPath PROTO, grid1:PTR BYTE, gridRow:DWORD
PrintStats PROTO, :StatP


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

Grid BYTE '-', '-', '-'
Rowsize = ($ - Grid)
	 BYTE '-', '-', '-'
	 BYTE '-', '-', '-'

GameStats Statistics <10,2,3,4,5>
Player1 PlayerInfo <>
Player2 PlayerInfo <>


.code ; start code segment
main PROC

Invoke MainMenu, ADDR Grid, Rowsize, ADDR GameStats, ADDR Player1, ADDR Player2
mov al, (Stats[esi]).GamesPlayed


exit
main ENDP ; end of main procedure




;--------------------------------------------------------------
; MainMenu
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;-------------------------------------------------------------- 
MainMenu PROC, grid1:PTR BYTE, gridRow:DWORD, stats1:StatP, P1:PlayerP, P2:PlayerP

.data

	menuPrompt BYTE "1. Player vs. Computer", 13, 10,
					"2. Computer vs. Computer", 13, 10,
					"3. Exit", 13, 10,
					"Please enter a choice: ", 0

.code
	mov esi, P1
	mov edi, P2
	mov edx, stats1
	mov ebx, grid1
	add ebx, gridRow


	mov edx, offset menuPrompt
	call WriteString
	call readint

	MENU:
		call clrscr
		mov edx, OFFSET MainPrompt
		call WriteString
		call ReadInt

		cmp eax, 1
		jl MENU
		je option1
		cmp eax, 2
		je option2
		cmp eax, 3
		jg MENU
		je option3


		option1:
		Invoke PlayComp, grid1, gridRow, stats1, P1, P2
		jmp MENU

		option2:
		Invoke CompComp, grid1, gridRow, stats1, P1, P2
		jmp MENU

	option3:
	Invoke PrintStats, stats1
	ret



ret
MainMenu ENDP




;--------------------------------------------------------------
; PlayComp
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
PlayComp PROC, grid1:PTR BYTE, gridRow:DWORD, stats1:StatP, P1:PlayerP, P2:PlayerP

	mov esi, P1
	mov edi, P2
	mov edx, stats1
	mov ebx, grid1
	add ebx, gridRow

ret
PlayComp ENDP




;--------------------------------------------------------------
; CompComp
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
CompComp PROC, grid1:PTR BYTE, gridRow:DWORD, stats1:StatP, P1:PlayerP, P2:PlayerP

	mov esi, P1
	mov edi, P2
	mov edx, stats1
	mov ebx, grid1
	add ebx, gridRow

ret
CompComp ENDP




;--------------------------------------------------------------
; ChooseFirst
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
ChooseFirst PROC, first:BYTE

mov al, first 

ret
ChooseFirst ENDP




;--------------------------------------------------------------
; ChooseRandom
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
ChooseRandom PROC, P:PlayerP

mov edi, P

ret
ChooseRandom ENDP




;--------------------------------------------------------------
; SimulateWait
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
SimulateWait PROC


ret
SimulateWait ENDP




;--------------------------------------------------------------
; TakeTurn
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
TakeTurn PROC, grid1:PTR BYTE, gridRow:DWORD, P:PlayerP

	mov ebx, grid1
	add ebx, gridRow
	mov edi, P

ret
TakeTurn ENDP




;--------------------------------------------------------------
; ValidMove
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
ValidMove PROC, grid1:PTR BYTE, gridRow:DWORD, P:PlayerP

	mov ebx, grid1
	add ebx, gridRow
	mov edi, P

ret
ValidMove ENDP




;--------------------------------------------------------------
; SetBoard
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
SetBoard PROC, grid1:PTR BYTE, gridRow:DWORD, P:PlayerP

	mov ebx, grid1
	add ebx, gridRow
	mov edi, P

ret
SetBoard ENDP




;--------------------------------------------------------------
; PrintBoard
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
PrintBoard PROC, grid1:PTR BYTE, gridRow:DWORD

	mov ebx, grid1
	add ebx, gridRow

ret
PrintBoard ENDP




;--------------------------------------------------------------
; ClearBoard
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
ClearBoard PROC, grid1:PTR BYTE, gridRow:DWORD

	mov ebx, grid1
	add ebx, gridRow

ret
ClearBoard ENDP




;--------------------------------------------------------------
; CheckWinner
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
CheckWinner PROC, grid1:PTR BYTE, gridRow:DWORD

	mov ebx, grid1
	add ebx, gridRow

ret
CheckWinner ENDP




;--------------------------------------------------------------
; HighlightPath
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
HighlightPath PROC, grid1:PTR BYTE, gridRow:DWORD

	mov ebx, grid1
	add ebx, gridRow


ret
HighlightPath ENDP




;--------------------------------------------------------------
; PrintStats
;
; 
;
; Receives:	N/A
;
; Returns:	N/A
;--------------------------------------------------------------
PrintStats PROC, stats1:StatP

mov esi, stats1

ret
PrintStats ENDP




Testp2 PROC, b:StatP

mov eax, 0
mov esi, b
mov al, (Stats[esi]).GamesPlayed
mov (Stats[esi]).GamesPlayed, 25

ret
Testp2 ENDP

end MAIN ; end of source code