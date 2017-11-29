.MODEL SMALL
.STACK 100h

.DATA

; Vars for getRandomNum
primeOne DW 47
primeTwo DW 13
randNum DB ?   
randRange DB ?

; Vars used for game levels
levelNum DB ?
levelArray DB 100 DUP(?)  

; Vars for drawTile
tileRow DB ?
tileCol DB ?
tileNum DB ?

; Vars for drawLevel
rowIter DB ?		     
colIter DB ?		     
temp DB ?
loopCounter DB ?	            

; Vars for drawSquare 
drawSquareClr DB 9
drawSquareRow DW 0
drawSquareCol DW 0
drawSquareSize DW 32

; Vars for drawString
drawStrRow DB ?
drawStrCol DB ? 
drawStrColor DB ?
 
; Vars for pixelToTile 
mouseColPx DW ?
mouseRowPx DW ?
boardTileRow DB ?
boardTileCol DB ?

; Vars for boxFill
mouseColStart DW ?
mouseRowStart DW ?
boxFillI DB ?
boxFillO DB ?

; Vars for boardTileToScreenTile
screenTileRow DB ?
screenTileCol DB ?
  
; Vars for storing tiles 
butOneRow DB ?
butOneCol DB ?
butOneIndex DB ?

butTwoRow DB ?
butTwoCol DB ? 
butTwoIndex DB ?
tempIndex DW ?
 
; Vars for boardTileToArrayIndex
arrIndex DW ?

; Vars for crushing
tempVar DB ?
tempVar2 DW ?
totalCols DB 10
totalRows DB 10
rowIndexCrush DB 0
colIndexCrush DB 0
isVerticalCrush DB 0
isHorizontalCrush DB 0
isBomb DB 0
bombNum DB ?
inPerpetualCrush DB 0

; Vars for dropNumbers
dropRow DB ?
dropCol DB ?
tempRow DB ?

; Vars for both removeBlockersHorizontally functions
startingIndex DW ?
endingIndex DW ?
comboLength DB ?

; Var for getLastColIndex
lastColIndex DB ?

; Vars for diplayMultiDigitNumber
quotient DB ?
remainder DB ?
displayNumCount DB ?
displayNumColor DB ? 
displayNumRow DB ?
displayNumCol DB ?

; Game vars
score DW 0
totalScore DW 0
moves DW 15

; Vars for displayInitialScreen
enterNameMSG db "Enter Your Name: ","$"
numberCrushMSG db "Number Crush Game","$"
enterLevelMSG db "Enter Level Number: ","$"
playerName db 20 DUP(?)
squareLength dw ?	; x-axis
squareWidth dw ?	; y-axis
initialSquarePixels dw ?

;Strings
userName DB "Name:","$"
userMoves DB "Moves:","$"
userScore DB "Score:","$"
levelScoreMSG DB "Your score for this level is", "$"
thankYouMSG DB "Thank you for playing!", "$"
endScoreMSG DB "Your final score is", "$"
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<<< MAIN >>>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
.CODE
main proc
  
    mov AX, @data
    mov DS, AX
				
	call displayInitialScreen	; Ask player name and starting level number
	
	startGame::			
				
	cmp levelNum, 1
	je startLevelOne
	
	cmp levelNum, 2
	je startLevelTwo
	
	cmp levelNum, 3
	je startLevelThree
	
	startLevelOne:
		call initializeLevelOne
		jmp removeInitialCombos
	
	startLevelTwo:
		call initializeLevelTwo
		jmp removeInitialCombos
	
	startLevelThree:
		call initializeLevelThree
		
	removeInitialCombos:
		call horizontalTraversal	; Remove initial horizontal and vertical combinations
		call verticalTraversal
		
		cmp isHorizontalCrush, 1	
		je cont
		cmp isVerticalCrush, 1
		je cont
		jmp beginGame				; If no combos exist, then the game begins
	
	cont:
		call dropNumbers			; Drop numbers to replace crushed numbers
		mov isHorizontalCrush, 0
		mov isVerticalCrush, 0
		jmp removeInitialCombos

	beginGame:	
		call drawLevel 
		mov score, 0				; Resetting score accumulated during preliminary crushing
	
	gameLoop:
		call displayGameInfo		; Display name, moves, score
		call checkforMouseClick		
	
		jmp gameLoop
	                   
    exitMain::
    mov AH, 4Ch
    int 21h

main endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| initializeLevelOne |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initializes levelArray by populating each index with a random number between 1-5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initializeLevelOne proc

push SI
push CX
push BX
    	
mov SI, 0
mov CX, 100

mov primeOne, 47
mov primeTwo, 13
mov randRange, 5		; To generate numbers upto 5
fillLoop:  
    call generateRandomNum
    mov BL, randNum
    mov levelArray[SI], BL  
    inc SI
    loop fillLoop      

mov ah, 0
mov al, 12h
int 10h
		   
pop BX
pop CX
pop SI
ret    
                                                                                                                                                                                                                                                                
initializeLevelOne endp                                                                                      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| initializeLevelTwo |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initializes levelArray by populating each index with a random number between 1-4 and leaving some empty spaces in-between
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initializeLevelTwo proc

push SI
push BX
push AX
PUSH DX
    
mov SI, 0

mov AX, 0	; ROW
mov DX, 0	; COL

mov randRange, 5
mov primeOne, 47
mov primeTwo, 13

fillLoop_Row:
	mov DL, 0
	
	fillLoop_Col:
		cmp AL, 2				; Check if row is 0,1,2 
		jbe checkCornerColumns
		cmp AL, 7				; Check if row is 7,8,9
		jae checkCornerColumns
		cmp AL, 4				; Check if row is 4
		je checkCentreColumns	
		cmp AL, 5				; Check if row is 5
		je checkCentreColumns	
		jmp genNum
	
		checkCornerColumns:	; Check if col is 0,1,2 or 7,8,9 
			cmp DL, 2
			jbe genBlankNum
			cmp DL, 7
			jae genBlankNum
			jmp genNum
		
		checkCentreColumns:	; Checks if col is between 3-7
			cmp DL, 3
			jb genNum
			cmp DL, 6
			ja genNum
	
		genBlankNum:
			push AX
			push DX
			
			mov DL, totalRows
			mul DL
			
			pop DX
			add AL, DL
			mov SI, AX
			pop AX
								
			mov levelArray[SI], 7  
			jmp cont
		
		genNum:
			push AX
			push DX
			
			mov DL, totalRows
			mul DL
			
			pop DX
			add AL, DL
			mov SI, AX
			pop AX
						
			call generateRandomNum
			cmp randNum, 1
			je fillN
			dec randNum
			
			fillN:
				mov BL, randNum		
				mov levelArray[SI], BL  

		cont:
			inc DL
			cmp DL, 10
			jne fillLoop_Col
		
		inc AL
		cmp AL, 10
		jne fillLoop_Row
  
pop DX
pop AX  
pop BX
pop SI
ret    
                                                                                                                                                                                                                                                                
initializeLevelTwo endp  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| initializeLevelThree |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initializes levelArray by populating each index with a random number between 1-5 and creating random blockers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initializeLevelThree proc

push SI
push CX
push BX
    
mov SI, 0
mov CX, 100

mov randRange, 6		; To generate numbers upto 5
mov primeOne, 47
mov primeTwo, 13
fillLoop:  
    call generateRandomNum
    mov BL, randNum
	cmp BL, 6
	jne normalNum
    mov levelArray[SI], 'X'		; If randNum = 6, generate a blocker
	jmp cont
	
	normalNum:		; Number between 1-5
		mov levelArray[SI], BL
	
	cont:
		inc SI
		loop fillLoop      
    
pop BX
pop CX
pop SI
ret    		  
initializeLevelThree endp    
         
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| generateRandomNum |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generates a random number between 1-5 and places it in randNum 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
generateRandomNum proc     
    
    push AX
    push BX
	push CX
    push DX
    
	genAgain:
		mov AX, primeOne  
		mov BX, 1
		mul BX
		
		add AX, primeTwo 
		mov BH, randRange
		div BH
				  
		mov randNum, AH
		inc randNum             
		
		cmp isBomb, 1		; If bomb blew, dont generate the bombed number
		jne cont
		mov CL, randNum
		cmp CL, bombNum
		jne cont
		mov primeOne, AX
		mov primeTwo, DX
		jmp genAgain
	
	cont:
		mov primeOne, AX
		mov primeTwo, DX

    pop DX
	pop CX
    pop BX
    pop AX 
    ret
        
generateRandomNum endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| drawTile |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generates a tile at tileRow, tileCol containing tileNum 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
drawTile proc
    
    push AX
    push BX
    push CX
    push DX
        
    mov DH, tileRow
    mov DL, tileCol
    
    mov AH, 02h		  ; Move cursor to tileRow, tileCol
    int 10h
    
    mov AL, tileNum   ; AL = Number to display    
	cmp AL, 0	   
	je drawZero
	
	cmp AL, 'B'
	je drawBomb
	
	cmp AL, 'X'
	jne cont
	
	mov BL, 0Fh		  ; Drawing blocker
	mov AL, 'X'
	mov BH, 0
	mov CX, 1
	jmp exit
		
	drawBomb:
		mov BL, 0Dh		  ; Drawing bomb
		mov AL, 'B'
		mov BH, 0
		mov CX, 1
		jmp exit
	
	drawZero:		
		mov BL,	0Eh
		jmp next
	
	cont:
		mov BL, AL        
	next:
		add AL, 48		  ; tileNum has number. Adding 48 to get ascii value of the number
		mov BH, 0		  ; Page number = 0
		mov CX, 1		  ; Display once
    
	exit:
    mov AH, 9h
    int 10h    
    
    pop DX
    pop CX
    pop BX
    pop AX
    ret
    
drawTile endp     
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| drawRedOutLine |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draws a red outline around restricted areas of levelTwo using drawSquare function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
drawRedOutLine proc

	push AX
	push BX
	push CX
	push DX

	; Top left
	mov drawSquareRow, 88
	mov drawSquareCol, 148
	mov drawSquareSize, 96
	mov drawSquareClr, 0Ch
	call drawSquare

	inc drawSquareCol
	call drawSquare

	inc drawSquareRow
	call drawSquare

	; Top right
	mov drawSquareRow, 88
	mov drawSquareCol, 370

	inc drawSquareCol
	call drawSquare

	inc drawSquareCol
	call drawSquare

	inc drawSquareRow
	call drawSquare

	; Bottom Left
	mov drawSquareRow, 311
	mov drawSquareCol, 147

	inc drawSquareCol
	call drawSquare

	inc drawSquareCol
	call drawSquare

	inc drawSquareRow
	call drawSquare

	;Bottom Right
	mov drawSquareRow, 311
	mov drawSquareCol, 370

	inc drawSquareCol
	call drawSquare

	inc drawSquareCol
	call drawSquare

	inc drawSquareRow
	call drawSquare
	
	;Middle
	mov CX, 243	; COL
	mov DX, 216	; ROW
	top:				; Top horizontal line
		cmp CX, 372
		ja next
	
		mov AH, 0ch
		mov BH, 0
		mov AL, 0ch
		int 10h
		
		dec DX
		mov AH, 0ch
		mov BH, 0
		mov AL, 0ch
		int 10h
		inc DX
		
		inc CX
		jmp top
		
	next:	
	mov CX, 244	; COL
	mov DX, 216	; ROW
	
	left:	; Left vertical line
		cmp DX, 280
		ja next2
	
		mov AH, 0ch
		mov BH, 0
		mov AL, 0ch
		int 10h
		
		dec CX
		mov AH, 0ch
		mov BH, 0
		mov AL, 0ch
		int 10h
		inc CX
		
		inc DX
		jmp left

	next2:
	mov CX, 244	; COL
	mov DX, 280	; ROW
	
	bottom:	; Bottom horizontal line
		cmp CX, 372
		ja next3
	
		mov AH, 0ch
		mov BH, 0
		mov AL, 0ch
		int 10h
		
		dec DX
		mov AH, 0ch
		mov BH, 0
		mov AL, 0ch
		int 10h
		inc DX
		
		inc CX
		jmp bottom
	
	next3:
	mov CX, 372	; COL
	mov DX, 216	; ROW
	
	right:	; Right vertical line
		cmp DX, 280
		ja finish
	
		mov AH, 0ch
		mov BH, 0
		mov AL, 0ch
		int 10h
		
		dec CX
		mov AH, 0ch
		mov BH, 0
		mov AL, 0ch
		int 10h
		inc CX
		
		inc DX
		jmp right
	
	finish:
		pop DX
		pop CX
		pop BX
		pop AX
		ret
drawRedOutLine endp   
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| drawBoardGrid |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draws grid surrounding numbers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;      
drawBoardGrid proc
	push AX
	push BX
	push CX
	push DX
	push SI
	
	mov drawSquareClr, 9
	mov drawSquareRow, 88
	mov drawSquareCol, 148
	mov drawSquareSize, 32
	mov loopCounter, 0
	mov DX, drawSquareSize

	mov SI, 0
	printLoop:
		cmp loopCounter, 10
		je finishPrint   
		
		mov CX, 10
		printRow:
			cmp levelArray[SI], 'B'
			je setBombTileColor
			cmp levelArray[SI], 'X'
			jne cont
			mov drawSquareClr, 0Fh	; Set tile color to white for blockers
			jmp cont
			
			setBombTileColor:
				mov drawSquareClr, 0Dh	; Set color for bomb
		
			cont:
				call drawSquare  
				add drawSquareCol, 32
				mov drawSquareClr, 9
				inc SI
				loop printRow
	 
		add drawSquareRow, 32
		mov drawSquareCol, 148
		inc loopCounter
		jmp printLoop
	 
	finishPrint:   
		cmp levelNum, 2
		jne finish
		call drawRedOutLine		; Draw red border around restricted areas for level 2

	finish:
		pop SI
		pop DX
		pop CX
		pop BX
		pop AX 
		ret   
          
drawBoardGrid endp 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| drawLevel |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Draws the levelArray on the screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;      
drawLevel proc 
   
   push SI
   
   mov AH, 0h            ; Set screen to 640x480
   mov AL, 12h
   int 10h     
   
   mov tileRow, 6		
   mov tileCol, 20
  
   mov SI, 0			; To access array elements
   mov rowIter, 0		; For outer loop over rows
   mov colIter, 0		; For inner loop over columns
   
   mov AL, tileCol		; Saving tileCol so it can be restored after looping over 10 cols of a row
   mov temp, AL
   
	rowLoop:
		mov colIter, 0
		
		colLoop:
			cmp levelNum, 2				; If level 2, restrict traversal to only accessible areas 
			jne draw
			
			cmp rowIter, 2				; Check if row is 0,1,2 
			jbe checkCornerColumns
			cmp rowIter, 7				; Check if row is 7,8,9
			jae checkCornerColumns
			cmp rowIter, 4				; Check if row is 4
			je checkCentreColumns	
			cmp rowIter, 5				; Check if row is 5
			je checkCentreColumns	
			jmp draw
	
		checkCornerColumns:				; Check if col is 0,1,2 or 7,8,9 
			cmp colIter, 2
			jbe nextIter
			cmp colIter, 7
			jae nextIter
			jmp draw
		
		checkCentreColumns:				; Checks if col is between 3-7
			cmp colIter, 3
			jb draw
			cmp colIter, 6
			ja draw		
			jmp nextIter
     
        draw:
            mov DH, levelArray[SI]		; Display extracted number from levelArray
			cmp DH, 7
			jb continue					; 7 is placed in restricted areas so is skipped
			cmp DH, 'B'
			je continue
			cmp DH, 'X'
			je continue
			jmp nextIter
			
		continue:	
			mov tileNum, DH
			call drawTile
	
		nextIter:
			add tileCol, 4
			inc SI
			
			inc colIter
			cmp colIter, 10
			jb ColLoop
    
		mov AL, temp
		mov tileCol, AL		; Restoring number of columns
		add tileRow, 2
		inc rowIter
		cmp rowIter, 10
		jb rowLoop
	
    call drawBoardGrid        ; Draws hollow squares around each number
    pop SI
	ret

drawLevel endp 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| drawSquare |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draws a square on drawSquareRow, Col of size equal to drawSquareSize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawSquare PROC

	push DX
	push CX
	push AX
	
	mov BX, 0
	mov AX, drawSquareSize              ; Length of line in pixels
	mov DX, drawSquareRow
	mov CX, drawSquareCol
	
	push CX
	push DX
	push AX
	call printHorizontalLine
	call printVerticalLine  
	
	pop AX
	pop DX
	add DX, AX
	dec DX
	push DX
	push AX
	call printHorizontalLine
	
	pop AX
	pop DX
	mov DX, drawSquareRow
	pop CX
	add CX, AX   
	dec CX
	push CX
	push DX
	push AX
	call printVerticalLine
	 
	pop AX
	pop DX 
	pop CX 
	pop AX
	pop CX 
	pop DX  
	ret
	
drawSquare ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| printHorizontalLine |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draws a horizontal line using values pushed on stack
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printHorizontalLine PROC   
    push bp     
    mov bp, sp
   
    mov BX, [bp + 4]	; drawSquareSize
    mov DX, [bp + 6]
    mov CX, [bp + 8]
    
	push AX
	
	mov AX, 0
	
	printLine:
		cmp AX, BX
		je exitPrintLine
		
		push AX
		mov AH, 0Ch 
		mov BH, 0
		mov AL, drawSquareClr
		int 10h
		         
	    pop AX	         
		inc AX
		inc CX
		jmp printLine
	
	exitPrintLine:
		pop AX    
		pop bp
		ret 
		
printHorizontalLine ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| printVerticalLine |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draws a vertical line using values pushed on stack
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printVerticalLine PROC
	push bp     
    mov bp, sp
   
    mov BX, [bp + 4]
    mov DX, [bp + 6]
    mov CX, [bp + 8]

	push AX
	
	mov AX, 0
	
	printLineA:
		cmp AX, BX
		je exitPrintLineA
		   
		push AX   
		mov AH, 0Ch
		mov BH, 0
		mov AL, drawSquareClr
		int 10h
		
		pop AX
		inc AX
		inc DX
		jmp printLineA
	
	exitPrintLineA:
		pop AX    
		pop bp
		ret
		
printVerticalLine ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| drawString |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draws a string on drawStrRow, Col where the string address is contained in SI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawString proc
	push AX
	push BX
	push DX
		
	mov DH, drawStrRow
	mov DL, drawStrCol
	
	drawLoop:
		mov AH, [SI]
		cmp AH, '$'
		je exit
		
		mov AH, 02h
		int 10h

		mov AH, 09h
		mov AL, [SI]
		mov BH, 0
		mov BL, drawStrColor 
		mov CX, 1
		int 10h
		
		inc DL
		inc SI
		jmp drawLoop
exit:
	pop DX
	pop BX
	pop AX
	ret
	
drawString endp  
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| displayGameInfo |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draws strings at the top of the board
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
displayGameInfo proc
    
    push SI
    
    mov drawStrRow, 0
    mov drawStrCol, 0
    mov drawStrColor, 4
    lea SI, userName
    call drawString  

	call printPlayerName
	
	; mov drawStrRow, 0
    ; mov drawStrCol, 6
    ; mov drawStrColor, 0Ch
    ; lea SI, playerName
    ; call drawString
	
    mov drawStrRow, 0			; Display moves string
    mov drawStrCol, 35 
    mov drawStrColor, 2
    lea SI, userMoves
    call drawString  

	mov ax, moves				; Displaying moves
	mov displayNumColor, 0Ah
	mov displayNumCol, 42
	mov displayNumRow, 0
	call diplayMultiDigitNumber
	
    mov drawStrRow, 0			; Displaying score string
    mov drawStrCol, 68
    mov drawStrColor, 3
    lea SI, userScore
    call drawString
	
	mov ax, score				; Displaying score
	mov displayNumColor, 0Bh
	mov displayNumCol, 75
	mov displayNumRow, 0
	call diplayMultiDigitNumber
	
    pop SI
    ret 

displayGameInfo endp 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| boardTileToScreenTile |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Converts board tiles to screen tiles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
boardTileToScreenTile proc
	push AX
	push BX

	mov AL, boardTileCol
	mov BL, 4
	mul BL
	add AL, 20
	mov screenTileCol, AL
	
	mov AL, boardTileRow
	mov BL, 2
	mul BL
	add AL, 6
	mov screenTileRow, AL
	
	pop BX
	pop AX
	ret
boardTileToScreenTile endp 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| pixelToTile |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Converts pixels to tiles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pixelToTile proc
	push AX
	push BX
	
	sub mouseColPx, 148				
	sub mouseRowPx, 88
    
    cmp mouseColPx, 0              
    jne next 
    mov boardTileCol, 0
    jmp cont
   
    next:  
	mov AX, 0
	mov AX, mouseColPx
	mov BL, 32
	div BL
	mov boardTileCol, AL
    
    cont:
    cmp mouseRowPx, 0
    jne next2
    mov boardTileRow, 0
    jmp retFN 
    
    next2:
	mov AX, 0
	mov AX, mouseRowPx
	div BL
	mov boardTileRow, AL
    
    retFN:
	pop BX
	pop AX
	ret

pixelToTile endp
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| tileToPixel |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Converts tiles to pixels contained in boardTileRow, boardTileCol
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tileToPixel proc
    push AX
    push DX
    
    mov AX, 0
    mov AL, 32
    mul boardTileCol
    
    add AX, 148
    mov mouseColPx,AX
    
    mov AX, 0
    mov AL, 32
    mul boardTileRow
    
    add AX, 88
    mov mouseRowPx, AX  
    
    pop DX
    pop AX
    ret
	
tileToPixel endp	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| checkforMouseClick |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main mouse function that continuously checks for mouse click
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkforMouseClick proc
	mov AX, 1			; Show cursor
	int 33h

	mov AX, 3			; Get button status and mouse cursor coordinates
	int 33h
	
	cmp BX, 1			; Check if left mouse button pressed
	je checkMousePix
	jmp exit
	
	checkMousePix:
		mov mouseColPx, CX
		mov mouseRowPx, DX
		
		cmp mouseColPx, 148		; Proceed only if mouse coordinates are within the game board
		jb exit
		
		cmp mouseColPx, 468
		ja exit
		
		cmp mouseRowPx, 88
		jb exit

		cmp mouseRowPx, 408
		ja exit
		
		cmp levelNum, 2
		jne cont
		
		; Ensuring mouse pointer is not within restricted areas of level 2
		
		cmp mouseRowPx, 184				; Check if row is equal to 2 or below 
		jbe checkCornerColumns
		
		cmp mouseRowPx, 312				; Check if row is equal to 7 or above
		jae checkCornerColumns
		
		cmp mouseRowPx, 216				; Check if row is equal to 4 or 5
		jb cont	
		
		cmp mouseRowPx, 280				
		ja cont	
		jmp checkCentreColumns
	
		checkCornerColumns:				; Check if col is 0,1,2 or 7,8,9 
			cmp mouseColPx, 244
			jbe exit
			
			cmp mouseColPx, 372
			jae exit
			jmp cont
		
		checkCentreColumns:				; Checks if col is between 3-7
			cmp mouseColPx, 244
			jna cont
			
			cmp mouseColPx, 372
			ja cont
			jmp exit
			
		cont:
			call pixelToTile		; Converts mouse coordinates to get boardTile
			call tileToPixel		; Gets the initial pixel coordinates of the above tile
				
			mov AX, mouseColPx		
			mov drawSquareCol, AX
			mov AX, mouseRowPx
			mov drawSquareRow, AX
			mov drawSquareClr, 10
			mov drawSquareSize, 32
			call drawSquare			; Draw border around relevant tile
			
			inc drawSquareCol		
			call drawSquare			; Thicken the border
			
			call boardTileToArrayIndex	; Get array index of the tile where first click occured
			mov AX, arrIndex
			mov butOneIndex, AL
			mov AH, boardTileCol		; Store data of the first click for later use
			mov butOneCol, AH
			mov AH, boardTileRow
			mov butOneRow, AH

			call checkForMouseRelease
				
	exit:
		ret

checkforMouseClick endp 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| checkforMouseRelease |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks where mouse button is released after being clicked
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkForMouseRelease proc
	
	checkLoop:
		mov AX, 3			
		int 33h

		cmp BX, 0				; Keep looping until mouse release is detected
		jne checkLoop
		
		mov mouseColPx, CX
		mov mouseRowPx, DX
		
		cmp mouseColPx, 148		; Proceed only if mouse coordinates are within the game board
		jb exit
		
		cmp mouseColPx, 468
		ja exit
		
		cmp mouseRowPx, 88
		jb exit

		cmp mouseRowPx, 408
		ja exit
		
		cmp levelNum, 2
		jne cont
		
		; Ensuring mouse pointer is not within restricted areas of level 2
		
		cmp mouseRowPx, 184				; Check if row is equal to 2 or below 
		jbe checkCornerColumns
		
		cmp mouseRowPx, 312				; Check if row is equal to 7 or above
		jae checkCornerColumns
		
		cmp mouseRowPx, 216				; Check if row is equal to 4 or 5
		jb cont	
		
		cmp mouseRowPx, 280				
		ja cont	
		jmp checkCentreColumns
	
		checkCornerColumns:				; Check if col is 0,1,2 or 7,8,9 
			cmp mouseColPx, 244
			jbe exit
			
			cmp mouseColPx, 372
			jae exit
			jmp cont
		
		checkCentreColumns:				; Checks if col is between 3-7
			cmp mouseColPx, 244
			jna cont
			
			cmp mouseColPx, 372
			ja cont
			jmp exit
			
		cont:
		call pixelToTile		; Converts mouse coordinates to get boardTile's
		call tileToPixel		; Gets the initial pixel coordinates of the above tile
		
		mov AX, mouseColPx		
		mov drawSquareCol, AX
		mov AX, mouseRowPx
		mov drawSquareRow, AX
		mov drawSquareClr, 10
		mov drawSquareSize, 32
		call drawSquare

		inc drawSquareCol		; Draw border and thicken it around second tile
		call drawSquare
			
		call boardTileToArrayIndex
		mov AX, arrIndex
		mov butTwoIndex, AL
		mov AH, boardTileCol		; Storing data for mouse release
		mov butTwoCol, AH
		mov AH, boardTileRow
		mov butTwoRow, AH
		
		call isSwapPossible			; Checking if swap of clicked tiles is possible
		ret
		
	exit:   
		mov drawSquareClr, 9
		call drawBoardGrid
		ret
checkForMouseRelease endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| boardTileToArrayIndex |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Converts boardTile to array indexes of levelOne
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
boardTileToArrayIndex proc

	push AX
	push BX
 	
	mov AL, boardTileRow
	mov BL, 10
	mul BL
	
	mov BH, 0
	mov BL, boardTileCol
	
	add AX, BX 
	mov arrIndex, AX
	
	pop BX
	pop AX
	ret
	
boardTileToArrayIndex endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| boxFill |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Creates a filled square at mouseColStart and mouseRowStart
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
boxFill proc
	push CX
	push DX
	push AX
		
	mov boxFillO, 0
	mov CX, mouseColStart
	mov DX, mouseRowStart
	
	outerloop:
		mov boxFillI, 0
		
		innerloop:
			mov AH, 0ch
			mov AL, 09h
			int 10h
			inc boxFillI
			inc CX
			cmp boxFillI, 32
			jb innerloop
		
		mov CX, mouseColStart
		inc DX
		inc boxFillO
		cmp boxFillO, 32
		jb outerloop
	
	pop AX
	pop DX
	pop CX
	ret
boxFill endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| isSwapPossible |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks if swap is possible using button indexes and calls swapTiles if it is
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
isSwapPossible proc

	mov AH, butOneCol
	mov AL, butOneRow

	mov BH, butTwoCol
	mov BL, butTwoRow

	cmp AH, BH		; Check if columns are same
	jne sameRow
	
	sameCol:
		cmp BL, AL 			; Check if second row is larger
		ja secondRowLarger
		cmp BL, AL
		jb secondRowSmaller	 ; Check if second row is smaller
		jmp exit			 ; If rows are equal then exit since butOne and butTwo are the same tiles
		
		secondRowLarger:	; i.e Second tile is below the first tile	
			mov CL, BL		; CL = Larger row 
			mov DL, AL		; DL = Smaller row
			sub CL, DL
			cmp CL, 1		; Check if tile below is only at a single block distance
			jne exit
			cmp BL, 9		; Checking if tile is out of bounds
			ja exit			
			
			call swapTiles
			jmp exit
			
		secondRowSmaller:  ; i.e Second tile is above the first tile
			mov CL, BL		; CL = Smaller row 
			mov DL, AL		; DL = Larger row
			sub DL, CL
			cmp DL, 1		; Check if tile above is only at a single block distance
			jne exit
			cmp BL, 0		; Checking if tile is out of bounds
			jb exit			
			
			call swapTiles
			jmp exit
	
	sameRow:
		cmp AL, BL		; If rows are same
		je checkcol
		jmp exit
		
	checkcol:
		cmp BH,AH
		ja secondColLarger	;check if second row is larger
		cmp BH, AH
		jb secondColSmaller	;check if second row is smaller
		jmp exit
		
		secondColLarger:
			mov CL, BH		; CL = Larger col
			mov DL, AH		; DL = Smaller col
			sub CL, DL
			cmp CL, 1		; Check if tile below is only at a single block distance
			jne exit
			cmp BH, 9
			ja exit			; Checking if tile is out of bounds
			
			call swapTiles
			jmp exit
		
		secondColSmaller:
			mov CL, BH		; CL = Smaller col
			mov DL, AH		; DL = Larger col
			sub DL, CL
			cmp DL, 1		; Check if tile above is only at a single block distance
			jne exit
			cmp BL, 0
			jb exit			; Checking if tile is out of bounds
			
			call swapTiles
			jmp exit
	
	exit:				
		mov drawSquareClr, 9	; If swap not possible, redraw original border around highlighted tiles
		call drawBoardGrid		
		ret

isSwapPossible endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| swapTiles |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Swaps tiles contained in butOneIndex and butTwoIndex
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
swapTiles proc
	push AX
	push BX
	push CX
	push DX
	push SI

	mov BH, 0				
	mov BL, butOneIndex
	mov SI, BX
	mov tempIndex, BX
	
	mov DH, levelArray[SI]	; DH = Value of tile where mouse was clicked
	
	mov BH, 0
	mov BL, butTwoIndex		
	mov SI, BX
		
	mov CL, levelArray[SI]	; CL = Value of tile where mouse was released
	
	cmp DH, 'X'		; Blockers cannot be swapped
	je exitIfBlocker
	cmp CL, 'X'
	je exitIfBlocker
	
	cmp DH, 'B'			; Check if first tile is a bomb (first tile = initial click, second tile = mouse release)
	je checkBombFirst
	jmp checkBombSecond	; If first tile is number, check second tile for bomb
	
	checkBombFirst:		; Checking for bomb on first tile
		cmp CL, 'B'		; Cannot swap bombs
		je ifBomb
		
		mov AL, CL		; AL = Number to be bombed for blowBomb function, DH = Bomb, CL = Number
		call blowBomb
		call drawLevel
		call dropNumbers
		jmp normalFinish
		
		ifBomb:			; If both tiles contain bombs, simply redraw the grid to erase highlighted tiles
			mov drawSquareClr, 9
			call drawBoardGrid
			jmp normalFinish
	
	checkBombSecond:    ; Checking for bomb on second tile
		cmp CL, 'B'		
		jne swap		; Both are numbers so normal swap
		mov AL, DH		; DH = Number, CL = Bomb
		call blowBomb
		call drawLevel
		call dropNumbers
		jmp normalFinish
		
	swap:
		mov levelArray[SI], DH		; Swapping values
		mov SI, tempIndex
		mov levelArray[SI], CL
		
	normalFinish:	
		call perpetualCrushing
		dec moves				
		cmp moves, 0			; If user runs out of moves, go the next level if possible
		jne exitIfBlocker		
		cmp levelNum, 3			; If level 1 or 2, load the next level 
		jb goToNextLevel		
		call displayEndScreen	; If level 3, then display final score and end game
		
		goToNextLevel:
			call loadNextLevel
		
		; call horizontalTraversal	; Remove horizontal and vertical combinations
		; call verticalTraversal

		; mov drawSquareClr, 9		
		; call displayGameInfo
		; call drawLevel				; Draw level to show removed combinations which show up as blank tiles
		; call dropNumbers				; Replace blank tiles with new numbers
		; call drawLevel				; Draw array to show changes
		; mov isBomb, 0
		
	exitIfBlocker:	
	 	mov AX, 1
		int 33h

		pop SI
		pop DX
		pop CX
		pop BX
		pop AX
	ret	

swapTiles endp
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| oneSecDelay |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pauses program for one second
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
oneSecDelay proc
	push ax
	push cx
	push dx
	
	mov cx, 0Fh				; Add time delay of 1 sec
	mov dx, 4240h
	mov ah, 86h
	int 15h 		

	pop dx
	pop cx
	pop ax
	ret
oneSecDelay endp  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| loadNextLevel |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays the score of the particular level and loads the next level if possible
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loadNextLevel proc
	push ax
	mov ah, 0		; Clear the screen
	mov al, 12h
	int 10h
	
	call displayNumberBorder	; Display the border of numbers around game board
	call drawSquareBorder
	
	mov drawStrCol, 23			; Write "Your score for this level is"
	mov drawStrRow, 14
	mov drawStrColor, 0Eh
	lea SI, levelScoreMSG
	call drawString
	
	mov displayNumCol, 52		; Display the score
	mov displayNumRow, 14
	mov displayNumColor, 0Eh
	mov ax, score
	call diplayMultiDigitNumber	
	
	call oneSecDelay			; 3 sec delay to allow user to view score
	call oneSecDelay
	call oneSecDelay
	
	
	call drawBoardGrid
	cmp levelNum, 3				; Go to next level if available, else, exit the game
	je exitMain
	inc levelNum
	mov ax, score
	add totalScore, ax			; Add score to totalScore
	mov score, 0				; Reset score for the next level
	mov moves, 15				; Reset moves to 15 for next level
	jmp startGame
	
	pop ax
	ret

loadNextLevel endp 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| horizontalTraversal |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for horizontal combinations in the whole array and calls horizontalCrush if one occurs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
horizontalTraversal proc
	push BX
	push AX
	push SI
		
	mov BX, 0
	mov AX, 0
	mov SI, 0
	
	mov rowIndexCrush, 0
	RowLoop:
		
		mov colIndexCrush, 0
		
		fullColLoop:
			cmp levelNum, 2
			jne ColLoop
	
			cmp rowIndexCrush, 2				; Check if row is 0,1,2 
			jbe checkCornerColumns
			cmp rowIndexCrush, 7				; Check if row is 7,8,9
			jae checkCornerColumns
			cmp rowIndexCrush, 4				; Check if row is 4
			je checkCentreColumns	
			cmp rowIndexCrush, 5				; Check if row is 5
			je checkCentreColumns	
			jmp ColLoop
		
		checkCornerColumns:					; Check if col is 0,1,2 or 7,8,9 
			cmp colIndexCrush, 2
			jbe cont
			cmp colIndexCrush, 7
			jae cont
			jmp ColLoop
		
		checkCentreColumns:					; Checks if col is between 3-7
			cmp colIndexCrush, 3
			jb ColLoop
			cmp colIndexCrush, 6
			ja ColLoop
			jmp cont
			
		ColLoop:
			mov BL, rowIndexCrush
			mov AL, totalCols
			mul BL
			mov BX, AX
			mov DX, 0
			mov DL, colIndexCrush
			mov SI, DX
			
			call horizontalCrush		; Calling for every index to see if it makes a combination
			
		cont:
			inc colIndexCrush
			cmp colIndexCrush, 10
			jb fullColLoop
		
		inc rowIndexCrush
		cmp rowIndexCrush, 10
		jb RowLoop
		
	pop SI
	pop AX
	pop BX
	
	ret		
horizontalTraversal endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| horizontalCrush |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Crushes a horizontal combination of similar numbered tiles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
horizontalCrush proc
	mov di, SI
	cmp colIndexCrush, 8		; Index should be less than 8(3 number crush)
	jb checkCrush
	jmp exit

	checkCrush:
		push BX	
		add BX, SI
		mov startingIndex, BX		; Initializing var for removeBlockersHorizontally
		pop BX
		mov AL, levelArray[BX+SI]		; comparison with next value
		cmp AL, 'B'						
		je exit							; Dont check for combinations of bombs or blockers
		cmp AL, 'X'
		je exit
		
		inc SI
		cmp AL, levelArray[BX+SI]
		je checkNextValue		    ; if equal then compare the next
		jmp exit

	checkNextValue:
		inc SI
		cmp AL, levelArray[BX+SI]
		je fillZero					; if 3 are equal then replace their values by zero
		jmp exit

	fillZero:
		mov isHorizontalCrush, 1	; Signalling that a horizontal combination exists
		mov comboLength, 3			; Initializing var for removeBlockersHorizontally
		add score, 3
		
		cont:
			mov SI, di
			mov levelArray[BX+SI], 0
			inc SI
			mov levelArray[BX+SI], 0
			inc SI
			mov levelArray[BX+SI], 0
	
	crushAll:
		inc SI
		cmp SI, 10				; checking if value of SI is within the limits	
		jb checkAboveThreeCombo
		jmp endFN

	checkAboveThreeCombo:
		cmp AL, levelArray[BX+SI]	; checking if the other numbers match
		je placeBomb
		jmp endFN		
	
	placeBomb:							; Bomb is placed on the last tile of the combination
		inc comboLength
		inc score
		mov levelArray[BX+SI-1], 0		; Set previous tile to 0
		mov levelArray[BX+SI], 'B'		; Place bomb on current tile
		jmp crushAll

	endFN:
		push BX
		add BX, SI
		dec BX
		mov endingIndex, BX	; Initializing var for removeBlockersHorizontally
		pop BX
		
		cmp levelNum, 3
		jne exit
		call removeBlockersHorizontally	; If level 3, remove any blockers adjacent to the combination
		
		exit:
			mov SI, di
			ret

horizontalCrush endp	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| verticalTraversal |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for vertical combinations in the whole array and calls verticalCrush if one occurs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
verticalTraversal proc
	push BX
	push AX
	push SI
	push DX
		
	mov BX, 0
	mov AX, 0
	mov SI, 0
	
	mov colIndexCrush, 0
	ColLoop:
		
		mov DX, 0
		mov DL, colIndexCrush
		mov SI, DX
		mov rowIndexCrush, 0
			
		fullRowLoop:
			cmp levelNum, 2
			jne RowLoop
	
			cmp rowIndexCrush, 2				; Check if row is 0,1,2 
			jbe checkCornerColumns
			cmp rowIndexCrush, 7				; Check if row is 7,8,9
			jae checkCornerColumns
			cmp rowIndexCrush, 4				; Check if row is 4
			je checkCentreColumns	
			cmp rowIndexCrush, 5				; Check if row is 5
			je checkCentreColumns	
			jmp RowLoop
		
		checkCornerColumns:					; Check if col is 0,1,2 or 7,8,9 
			cmp colIndexCrush, 2
			jbe cont
			cmp colIndexCrush, 7
			jae cont
			jmp RowLoop
		
		checkCentreColumns:					; Checks if col is between 3-7
			cmp colIndexCrush, 3
			jb RowLoop
			cmp colIndexCrush, 6
			ja RowLoop
			jmp cont
		
		RowLoop:
			mov BL, rowIndexCrush
			mov AL, totalCols
			mul BL
			mov BX, AX
			call verticalCrush		; calling for every index to see if it makes a combination
			
		cont:	
			inc rowIndexCrush
			cmp rowIndexCrush, 10
			jb fullRowLoop
		
		inc colIndexCrush
		cmp colIndexCrush, 10
		jb ColLoop
	
	pop DX
	pop SI
	pop AX
	pop BX
	
	ret		
verticalTraversal endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| verticalCrush |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Crushes a vertical combination of similar numbered tiles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
verticalCrush proc
	mov di, BX
	mov DL, rowIndexCrush
	mov tempVar, DL
	cmp rowIndexCrush, 8		; index should be less than 8(3 number crush)
	jb checkCrush
	jmp exit

	checkCrush:
		push BX
		add BX, SI
		mov startingIndex, BX
		pop BX
		mov AL, levelArray[BX+SI]		; comparison with next value
		cmp AL, 'B'						; Dont check for combinations of bombs or blockers
		je exit
		cmp AL, 'X'
		je exit
		
		add BX, 10
		cmp AL, levelArray[BX+SI]
		je checkNextValue			; if equal then compare the next
		jmp exit

	checkNextValue:
		add BX, 10
		cmp AL, levelArray[BX+SI]
		je fillZero					; if 3 are equal then replace there values by zero
		jmp exit

	fillZero:
		mov isVerticalCrush, 1		; Signalling that a vertical combination exists
		mov comboLength, 3
		add score, 3
		
		cont:
			mov BX, di
			mov levelArray[BX+SI], 0
			inc tempVar
			add BX, 10
			mov levelArray[BX+SI], 0
			inc tempVar
			add BX, 10
			mov levelArray[BX+SI], 0

	crushAll:
		inc tempVar
		cmp tempVar, 10				; checking if bondaries are not crossed
		jb checkAboveThreeCombo
		jmp endFN

	checkAboveThreeCombo:
		add BX, 10
		cmp AL, levelArray[BX+SI]
		je makeZero
		jmp endFN		
	
	makeZero:
		inc comboLength
		inc score
		mov levelArray[BX+SI-10], 0		; Set previous index to 0
		mov levelArray[BX+SI], 'B'		; Set last index of combo to 'B' to indicate bomb
		jmp crushAll 

	endFN:
		push BX
		add BX, SI
		sub BX, 10
		mov endingIndex, BX	; Initializing var for removeBlockersHorizontally
		pop BX
		
		cmp levelNum, 3
		jne exit
		call removeBlockersVertically
		
	exit:
		ret

verticalCrush endp	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| blowBomb |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Removes all numbers from array that are equal to number in AL as well as all bombs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
blowBomb proc
	
	; AL = Value to be bombed
	
	mov SI, 0
	mov CX, 100
	bombLoop:
		cmp AL, levelArray[SI]		; If value to be crushed found, make it zero
		je makeZero
		cmp levelArray[SI], 'B'		; All other bombs are destroyed as well
		je makeZero
		jmp checkNext		
	
	makeZero:
		mov levelArray[SI], 0
		
	checkNext:
		inc SI
		loop bombLoop
	
	mov isBomb, 1	; To signal that bomb has blown so number in AL is not generated again for new board
	mov bombNum, AL ; bombNum is not generated again when the board is drawn
	ret
blowBomb endp 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| dropNumbers |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks array for values equal to 0 and calls moveUp on them
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
dropNumbers proc
	push BX
	push AX
	push SI
	push DX
	
	mov AX, 0
	mov DX, 0
	
	mov dropRow, 0
	RowLoop:
		
		mov dropCol, 0
		ColLoop:
			
			mov BL, dropRow
			mov AL, totalCols
			mul BL
			mov BX, AX
			mov DX, 0
			mov DL, dropCol
			mov SI, DX
			cmp levelArray[BX+SI], 0
			je callmoveUp
			jmp checkNext
			
			callMoveUp:
				call moveUp
			
			checkNext:
				inc dropCol
				cmp dropCol, 10
				jb ColLoop
			
			inc dropRow
			cmp dropRow, 10
			jb RowLoop
	
	pop DX
	pop SI
	pop AX
	pop BX		
	ret
dropNumbers endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| moveUp |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Moves zero value upwards and replaces it with a random value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
moveUp proc
	mov temp, 0
	mov DL, dropRow
	mov tempRow, DL
	
	upLoop:	
		cmp tempRow, 0		; if the row index is 0 (top) replace this value by rand number
		je getRand
		
		cmp levelArray[BX+SI-10], 7		; If tile above is in restricted area, don't move further
		je getRand
		
		cmp levelArray[BX+SI-10], 'X'	; If tile above is a blocker, don't move further
		je checkifXIsAtTopRow
 
		mov DL, levelArray[BX+SI]     ; DL = 0 
		mov DH, levelArray[BX+SI-10]  ; DH  = value in the upper row
		mov levelArray[BX+SI], DH		; swapping values
		mov levelArray[BX+SI-10], DL
		dec tempRow
		
	KeepMovingUp:
		mov BX, 0
		mov AX, 0
		mov BL, tempRow
		mov AL, totalCols
		mul BL
		mov BX, AX
		
		jmp upLoop
	
	checkifXIsAtTopRow:
		mov DL, tempRow
		mov temp, DL
		dec temp		
		cmp temp, 0 					; If blocker is at top of array, stop moving up
		je getRand	
		mov DL, levelArray[BX+SI]     	; DL = 0 
		mov DH, levelArray[BX+SI-20]  	; DH  = value in the upper row and skipping x
		mov levelArray[BX+SI], DH		; swapping values
		mov levelArray[BX+SI-20], DL
		sub tempRow, 2  					; moving two spots up
		jmp KeepMovingUp
	
	getRand:
		mov randRange, 5
		call generateRandomNum
		push DX
		mov DL, randNum
		mov levelArray[BX+SI], DL
		pop DX
		
	ret
moveUp endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| perpetualCrushing |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Keeps removing combinations and replacing them until none exist
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
perpetualCrushing proc
	
	continuousCrush:
		call horizontalTraversal	; Remove horizontal and vertical combinations
		call verticalTraversal
		
		cmp isHorizontalCrush, 1	; Check if horizontal crush occured
		je crushAgain
		cmp isVerticalCrush, 1		; Check if vertical crush occured
		je crushAgain
		jmp finish					; If no crushing occured, then exit
		
		crushAgain:
			mov drawSquareClr, 9		
			call displayGameInfo
			call drawLevel				; Draw level to show removed combinations which show up as blank tiles
			
			call dropNumbers			; Replace blank tiles with new numbers
			call drawLevel				; Draw array to show changes
		
			mov isHorizontalCrush, 0
			mov isVerticalCrush, 0
			jmp continuousCrush			; Check for combinations again

		finish:
			mov drawSquareClr, 9		
			call displayGameInfo
			call drawLevel	
			ret	
perpetualCrushing endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| removeBlockersHorizontally |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Called after a horizontal combination is made to check adjacent tiles and remove any blockers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Vars:
; 		startingIndex = Contains the array index of the tile from where the combo begins
; 		comboLength = Contains the length of the total combo
;		endingIndex = Contains the array index of the tile where the combo ends

removeBlockersHorizontally proc	
	mov AX, startingIndex
	mov BH, 10
	div BH				; Checking if startingIndex is a multiple of 10 which indicates that the combo starts from first column
	cmp AH, 0			; Comparing the mod
	jne startMiddle		; If not 0, combo starts from between column 2 to 7
	
		; -------Combo begins from the first column------------
		mov SI, startingIndex
		cmp SI, 9
		jna inFirstRow_First	; If in first row, only check the tile below
		
		cmp SI, 90				; If in last row, only check the tile above, else check both above and below
		jae inLastRow_First
		call checkAbove
		call checkBelow
		jmp middleTiles_First
		
		inFirstRow_First:		
			call checkBelow
			jmp middleTiles_First
			
		inLastRow_First:
			call checkAbove
		
		middleTiles_First:	; Checking middle tiles of combination, excluding first and last tiles
		xor CX, CX
		mov CL, comboLength 
		sub CL, 2
		inc SI
		
		checkBlockerLoop_First:
			cmp startingIndex, 9	; Don't check above if its the first row
			jna onlyBelow_First
			
			cmp SI, 90
			jae onlyAbove_First
			call checkAbove
			call checkBelow
			jmp nextLoopIter_First
			
			onlyAbove_First:
				call checkAbove
				jmp nextLoopIter_First
			
			onlyBelow_First:			; Not first row, need to check above and below of the tile
				call checkBelow
				
			nextLoopIter_First:
			inc SI
			loop checkBlockerLoop_First
		
		jmp checkLastTile
	
	; ----------Combinations begins in a middle column (i.e. not first or last)----------------
	startMiddle:
		mov SI, startingIndex
		cmp SI, 9
		jna inFirstRow_Middle	; If in first row, only check the tile below
		
		cmp SI, 90				; If in last row, only check the tile above, else check both above and below
		jae inLastRow_Middle
		call checkAbove
		call checkBelow
		call checkLeft
		jmp middleTiles_Middle
		
		inFirstRow_Middle:		
			call checkBelow
			call checkLeft
			jmp middleTiles_Middle
			
		inLastRow_Middle:
			call checkAbove
			call checkLeft
			
		middleTiles_Middle:	; Checking middle tiles of combination, excluding first and last tiles
		xor CX, CX
		mov CL, comboLength
		sub CL, 2
		inc SI
		
		checkBlockerLoop_Middle:
			cmp startingIndex, 9	; Don't check above if its the first row
			jna onlyBelow_Middle
			
			cmp SI, 90
			jae onlyAbove_Middle
			call checkAbove
			call checkBelow
			call checkLeft
			jmp nextLoopIter_Middle
			
			onlyAbove_Middle:
				call checkAbove
				call checkLeft
				jmp nextLoopIter_Middle
			
			onlyBelow_Middle:			; Not first row, need to check above and below of the tile
				call checkBelow
				call checkLeft
				
			nextLoopIter_Middle:
			inc SI
			loop checkBlockerLoop_Middle
			
	checkLastTile:
		mov SI, endingIndex
		call getLastColIndex
		xor DX, DX
		mov DL, lastColIndex	; lastColIndex contains the index of the last column in which combo was made
		
		cmp SI, 9
		jna	inFirstRow_Last
		
		cmp SI, 90
		jae inLastRow_Last
		
		cmp endingIndex, DX
		je inLastColC
		
		call checkAbove
		call checkBelow
		call checkRight
		ret
		
		inLastColC:
			call checkAbove
			call checkBelow
			ret
	
		inFirstRow_Last:
			cmp endingIndex, DX
			je inLastColA
			
			call checkBelow
			call checkRight
			ret
			
			inLastColA:
				call checkBelow
				ret
		
		inLastRow_Last:
			cmp endingIndex, DX
			je inLastColB
			
			call checkAbove
			call checkRight
			ret
			
		inLastColB:
			call checkAbove
				
	ret	
removeBlockersHorizontally endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| Various check functions |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Four functions to check in each direction of the array index stored in SI for a blocker and to remove it
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
checkBelow proc
	cmp levelArray[SI + 10], 'X'
	jne exit
	mov levelArray[SI + 10], 0

	exit:
		ret
checkBelow endp

checkAbove proc
	cmp levelArray[SI - 10], 'X'
	jne exit
	mov levelArray[SI - 10], 0

	exit:
		ret
checkAbove endp

checkLeft proc
	cmp levelArray[SI - 1], 'X'
	jne exit
	mov levelArray[SI - 1], 0

	exit:
		ret
checkLeft endp

checkRight proc
	cmp levelArray[SI + 1], 'X'
	jne exit
	mov levelArray[SI + 1], 0

	exit:
		ret
checkRight endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| getLastColIndex |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Returns the index of the last column of the row in which the array index (stored in AX) is contained
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
getLastColIndex proc
	push AX
	push BX

	mov AX, SI
	mov BH, 10
	div BH
	
	mov AH, 0
	mul BH
	add AL, 9
	
	mov lastColIndex, AL
	
	pop BX
	pop AX
	ret
getLastColIndex endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| removeBlockersVertically |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Called after a vertical combination is made to check adjacent tiles and remove any blockers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Vars:
; 		startingIndex = Contains the array index of the tile from where the combo begins
; 		comboLength = Contains the length of the total combo
;		endingIndex = Contains the array index of the tile where the combo ends

removeBlockersVertically proc	
	cmp startingIndex, 9	; If startingIndex <= 9, then combo begins from the first row
	ja startMiddle			; If startingIndex > 9, combo begins from some middle row
	
		; -------Combo begins from the first row------------
		mov SI, startingIndex
		cmp SI, 0
		je inFirstCol_First		; If in first col, only check the right tile
		cmp SI, 9				; If in last col, only check the left tile, else check both right and left
		je inLastCol_First
		call checkRight
		call checkLeft
		jmp middleTiles_First
		
		inFirstCol_First:		
			call checkRight
			jmp middleTiles_First
			
		inLastCol_First:
			call checkLeft
		
		middleTiles_First:	; Checking middle tiles of combination, excluding first and last tiles
		xor CX, CX
		mov CL, comboLength 
		sub CL, 2
		add SI, 10
		
		checkBlockerLoop_First:
			cmp startingIndex, 0	; Check left if first col
			je onlyRight_First
			cmp SI, 9
			je onlyLeft_First
			call checkRight
			call checkLeft
			jmp nextLoopIter_First
			
			onlyLeft_First:
				call checkLeft
				jmp nextLoopIter_First
			
			onlyRight_First:			; Not first row, need to check above and below of the tile
				call checkRight
				
			nextLoopIter_First:
			add SI, 10
			loop checkBlockerLoop_First
		
		jmp checkLastTile
	
	; ----------Combinations begins in a middle row (i.e. not first or last rows)----------------
	startMiddle:
		mov SI, startingIndex
		mov AX, SI				
		mov BH, 10
		div BH
		cmp AH, 0
		je inFirstCol_Middle	; If startingIndex is multiple of 10, then combo begins from first col
		
		call getLastColIndex
		xor DX, DX
		mov DL, lastColIndex	; Getting last col number of the row startingIndex is in
		cmp SI, DX				; If startingIndex is equal to last col, then combo begins from the last column
		je inLastCol_Middle		
		
		call checkAbove			; In middle col
		call checkRight
		call checkLeft
		jmp middleTiles_Middle
		
		inFirstCol_Middle:		
			call checkAbove
			call checkRight
			jmp middleTiles_Middle
			
		inLastCol_Middle:
			call checkAbove
			call checkLeft
			
		middleTiles_Middle:	; Checking middle tiles of combination, excluding first and last tiles
		xor CX, CX
		mov CL, comboLength
		sub CL, 2
		add SI, 10
		
		checkBlockerLoop_Middle:
			mov AX, startingIndex					
			mov BH, 10
			div BH
			cmp AH, 0			
			je checkRight_Middle	; If combo begin in first col, check only to the right of the middle tiles
			
			call getLastColIndex
			xor DX, DX
			mov DL, lastColIndex	; Getting last col number of the row startingIndex is in
			cmp SI, DX				; If startingIndex is equal to last col, then combo begins from the last column
			je checkLeft_Middle		
			
			call checkLeft
			call checkRight
			jmp nextLoopIter_Middle
			
			checkLeft_Middle:
				call checkLeft
				jmp nextLoopIter_Middle
			
			checkRight_Middle:			; Not first row, need to check above and below of the tile
				call checkRight
				
			nextLoopIter_Middle:
			add SI, 10
			loop checkBlockerLoop_Middle
			
	checkLastTile:
		mov SI, endingIndex
		mov AX, SI				
		mov BH, 10
		div BH
		cmp AH, 0
		je inFirstCol_Last	; If startingIndex is multiple of 10, then combo begins from first col
		
		call getLastColIndex
		xor DX, DX
		mov DL, lastColIndex	; Getting last col number of the row startingIndex is in
		cmp SI, DX				; If startingIndex is equal to last col, then combo begins from the last column
		je inLastCol_Last	
		
		cmp SI, 90
		ja inMiddleColLastRow
		call checkBelow		; In middle col
		call checkRight
		call checkLeft
		ret
		
		inMiddleColLastRow:
			call checkRight
			call checkLeft
			ret
		
		inFirstCol_Last:
			cmp SI, 90
			je tileNum90
			call checkRight
			call checkBelow
			ret
			
			tileNum90:
				call checkRight
				ret
		
		inLastCol_Last:
			cmp SI, 99
			je tileNum99
			call checkLeft
			call checkBelow
			ret
			
			tileNum99:
				call checkLeft
				
	ret	
removeBlockersVertically endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| diplayMultiDigitNumber |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Displays a multidigit number at displayNumRow, Col. Displayed number must be in AX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
diplayMultiDigitNumber proc
	push DX
	push CX
	mov displayNumCount, 0 
	mov BL, 10
	
	pushingNumberIntoStack:
		div BL
		mov remainder, AH
		mov quotient, AL
		mov AH, 0
		mov AL, remainder
		push AX					; pushing remainder to the stack
		inc displayNumCount
		mov AL, quotient		; moving the quotient value in the AL
		mov AH, 0
		cmp AL, 0				; checking if the all numbers are pushed into the stack
		jne pushingNumberIntoStack
		mov DH, displayNumRow
		mov DL, displayNumCol
		
		popingAndPrintingNumber:
		pop AX
		mov remainder, AL 	;temp. storing the value
		add remainder, 48
		mov AH, 02			;moving cursor to the position where char should be printed
		int 10h
		
		mov AH, 09
		mov AL, remainder
		mov BL, displayNumColor
		mov CX, 1
		mov BH, 0
		int 10h
		
		inc DL					;inc column
		dec displayNumCount
		cmp displayNumCount, 0
		ja popingAndPrintingNumber
	
	pop CX
	pop DX
	ret
diplayMultiDigitNumber endp	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| displayInitialScreen |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Displays the initial screen when game begins
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
displayInitialScreen proc
	push ax
	
	mov ah, 0		; Set video mode 640x480
	mov al, 12h
	int 10h
	
	call displayNumberBorder	; Display the border of numbers around game board
	call drawSquareBorder
	call displayEnterName
	call inputPlayerName
	call displayEnterLevel
	call inputLevel
	
	pop ax
	ret
displayInitialScreen endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| displayNumberBorder |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Displays a border of numbers around the screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
displayNumberBorder proc
	push ax
	push bx
	push cx
	push dx
	push si

	mov dh, 0
	mov cx, 7
	top:
		push cx
		call drawHorizontalNumberLine		; Prints a horizontal number line in rows 0-7
		inc dh
		pop cx
		loop top
		
	mov dh, 23
	mov cx, 7
	bottom:
		push cx
		call drawHorizontalNumberLine		; Prints a horizontal number line in rows 7-23
		inc dh
		pop cx
		loop bottom	
	
	mov dl, 0
	mov cx, 5
	left:
		push cx
		call drawVerticalNumberLine
		inc dl
		pop cx
		loop left
	
	mov dl, 75
	mov cx, 5
	right:
		push cx
		call drawVerticalNumberLine
		inc dl
		pop cx
		loop right
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax	
	ret
displayNumberBorder endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| displayEndScreen |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Displays screen when the game ends
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
displayEndScreen proc
	push ax
	mov ah, 0		; Set video mode 640x480
	mov al, 12h
	int 10h
	
	call displayNumberBorder	; Display the border of numbers around game board
	call drawSquareBorder
	
	mov drawStrCol, 27			; "Thank you for playing"
	mov drawStrRow, 13
	mov drawStrColor, 0Eh
	lea SI, thankYouMSG
	call drawString 
	
	mov drawStrRow, 14			; "Your final score is"
	mov drawStrCol, 26
	mov drawStrColor, 0Eh
	lea SI, endScoreMSG
	call drawString
	
	mov displayNumCol, 46		; Display the score
	mov displayNumRow, 14
	mov displayNumColor, 0Eh
	add ax, score
	mov ax, totalScore
	
	call diplayMultiDigitNumber
	jmp exitMain
	
	pop ax
	ret
displayEndScreen endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| inputLevel |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Takes starting level as user input
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inputLevel proc
	push ax
	push dx
	
	mov dl, 33
	mov dh, 14
	mov ah, 02
	int 10h
	
	mov ah, 01
	int 21h
	sub al, 48
	mov levelNum, al
	
	pop dx
	pop ax
	ret	
inputLevel endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| displayEnterLevel |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Displays "Enter level" during initial loading screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
displayEnterLevel proc
	push dx
	push ax
	push si
	push cx
	push bx
	
	mov dh, 14
	mov dl, 13
	mov si, 0
	printingEnterLevel:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, enterLevelMSG[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp enterLevelMSG[si], "$"
		jne printingEnterLevel	
	
	pop bx
	pop cx
	pop si
	pop ax
	pop dx
	ret

displayEnterLevel endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| inputPlayerName |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Takes player name as input and stores it in playerName
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inputPlayerName proc
	push ax
	push dx
	
	mov dl, 30
	mov dh, 13
	mov ah, 02
	int 10h
		
	lea SI, playerName
	mov ah, 01h

	inputChar:
		int 21h
		mov [si], al
		inc si
		cmp al, 13
		jne inputChar
			
	pop dx
	pop ax
	ret	
inputPlayerName endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| displayEnterName |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Displays "Enter your name" in initial loading screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
displayEnterName proc
	push dx
	push ax
	push si
	push cx
	push bx
	
	mov dh, 13
	mov dl, 13
	mov si, 0
	
	printingEnterName:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, enterNameMSG[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		
		inc dl
		inc si
		cmp enterNameMSG[si], "$"
		jne printingEnterName 	
	
	pop bx
	pop cx
	pop si
	pop ax
	pop dx
	
	ret
displayEnterName endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| printPlayerName |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Prints the name given by the player
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printPlayerName proc
	push dx
	push ax
	push si
	push cx
	push bx
	
	mov dh, 0
	mov dl, 6
	mov si, 0
	
	printingName:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, playerName[si]
		mov bl, 0Ch
		mov cx, 1
		mov bh, 0
		int 10h	
		
		inc dl
		inc si
		cmp playerName[si], 13
		jne printingName 	
	
	pop bx
	pop cx
	pop si
	pop ax
	pop dx
	
	ret
printPlayerName endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| drawHorizontalNumberLine |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  ; Draw a horizontal line of random numbers at DH = Row
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawHorizontalNumberLine proc
	
	push dx

	mov randRange, 6	  ; Set range of random numbers
	mov cx, 80
	mov DL, 0			  ; Line printed from first till last row
	print:
		mov AH, 02h		  ; Move cursor to tileRow, tileCol
		int 10h
		
		call generateRandomNum
		mov AL, randNum   		; AL = Number to display    
		add AL, 48			 	
		mov BH, 0		 	 	; Page number = 0
		mov BL, randNum	     	; Seting color
		push cx
		mov CX, 1		  		; Display once
		mov AH, 9h				; Display number
		int 10h    
		pop cx
		inc dl
		loop print
		
	pop dx	
	ret	
drawHorizontalNumberLine endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| drawVerticalNumberLine |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Draw a vertical line of random numbers at DL = Col
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawVerticalNumberLine proc
	push dx

	mov randRange, 6	  ; Set range of random numbers
	mov cx, 16
	mov DH, 7			  ; Line printed from first till last row
	print:
		mov AH, 02h		  ; Move cursor to tileRow, tileCol
		int 10h
		
		call generateRandomNum
		mov AL, randNum   		; AL = Number to display    
		add AL, 48			 	
		mov BH, 0		 	 	; Page number = 0
		mov BL, randNum	     	; Seting color
		push cx
		mov CX, 1		  		; Display once	
		mov AH, 9h				; Display number
		int 10h    
		pop cx
		inc dh
		loop print
		
	pop dx	
	ret	
drawVerticalNumberLine endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| drawSquareBorder |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draws a border around the horizontal and vertical number borders used in screens(loading, initial, ending)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawSquareBorder proc
	push bx
	push dx
	push cx
	
	mov bx, 0
	mov cx, 42
	mov dx, 112
	topLine:
		mov ah, 0Ch
		mov al, 0eh
		push bx
		mov bh, 0
		int 10h
		pop bx
		
		inc cx
		inc bx
		cmp bx, 555
		jb topLine

	mov bx, 0
	mov cx, 42
	mov dx, 366
	bottomLine:
		mov ah, 0Ch
		mov al, 0eh
		push bx
		mov bh, 0
		int 10h
		pop bx
		
		inc cx
		inc bx
		cmp bx, 555
		jb bottomLine	
	
	mov bx, 0
	mov cx, 597
	mov dx, 112
	rightLine:
		mov ah, 0Ch
		mov al, 0eh
		push bx
		mov bh, 0
		int 10h
		pop bx
		
		inc dx
		inc bx
		cmp bx, 255
		jb rightLine	
		
	mov bx, 0
	mov cx, 42
	mov dx, 112
	leftLine:
		mov ah, 0Ch
		mov al, 0Eh
		push bx
		mov bh, 0
		int 10h
		pop bx
		
		inc dx
		inc bx
		cmp bx, 255
		jb leftLine	
		
	pop cx
	pop dx
	pop bx
	ret
drawSquareBorder endp

end
