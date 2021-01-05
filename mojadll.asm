.data
.code
;macro definition that reads from the array at the position counter - array [counter] and loads into ECX - because a 32-bit integer
accesstoarray MACRO counter:REQ 
	mov RSI, RCX
	mov EAX, counter
	imul EAX, R13d
	add RSI, RAX
	xor RAX, RAX
	mov EAX, [RSI]
ENDM
;a macro definition that saves the array at the position counter - array [counter] = value - value 32-bit register
writetoarray MACRO counter:REQ, value:REQ 
	mov RSI, RCX
	mov EAX, counter
	imul EAX, R13d
	add RSI, RAX
	xor RAX, RAX
	mov EAX, value
	mov [RSI], EAX
ENDM
;macro definition that moves everything away from the current position and writes the array to the position counter - array [counter] = value - value 32-bit register
movallandsave MACRO counterlok:REQ, valuelok:REQ, currentposition:REQ
	mov R15d, currentposition
	@@: ;anonymous label because they can repeat themselves (several macro calls)
	dec R15d
	cmp R15d, counterlok
	je @f ; jump to next anonymous label @@
	dec R15d
	accesstoarray R15d
	mov R14d, EAX
	inc R15d
	writetoarray R15d, R14d
	jmp @b ; jump to the previous anonymous label @@
	@@:
		writetoarray counterlok, valuelok
ENDM
;two arguments are passed to the function 
InsertionSort proc 
xor R8d, R8d ; R8d to counter i
mov R13d, 4 ; foursome for comparison and multiplication for reads / writes
;embracing the first 4 elements
mainLoop:
	inc R8d ; I start with i = 1 because the array indices are from 0
	cmp R8d, R13d
	jge endMainLoop ;if i = 4 then it goes to the end of this part
	accesstoarray R8d
	mov R10d, EAX ; x=A[i]
	mov R9d, R8d
	dec R9d ;j=i-1
	whileLoop:
		cmp R9d, 0 ; while's first condition - j> = 0
		jl endWhile
		accesstoarray R9d ; while's second condition - x <A [j]
		mov R11d, EAX
		cmp R10d, R11d
		jge endWhile
		mov R12d, R9d ;I copy j to make j + 1
		inc R12d
		accesstoarray R9d
		mov R14d, EAX
		writetoarray R12d, R14d ; A[j+1] = A[j]
		dec R9d ; j= j-1
		jmp whileLoop
	endWhile:
	inc R9d ; j=j+1
	writetoarray R9d, R10d ; A[j+1] = x
	jmp mainLoop
endMainLoop:
;end of embracing the first 4 elements
;and now we will cover the rest, vectorially
contmainLoop:
	cmp R8d, EDX ; in RDX I passed the number of elements, but I take EDX because I need lower 32-bits - as i = array length is the end
	je ending
	accesstoarray R8d
	mov R10d, EAX ;x = A[i]
	mov R9d, R8d
	dec R9d ; j= j - 1
	mov R14d, R9d ; copy j for appropriate offset insertion
	inc R14d
	whileLoopCont:
		cmp R9d, 2 
		jle endWhileCont
		sub R9d, 3 ;I take each of the 4 previous elements and load it to the appropriate xmm0 position
		accesstoarray R9d
		pinsrd xmm0, EAX, 0
		inc R9d
		accesstoarray R9d
		pinsrd xmm0, EAX, 1
		inc R9d
		accesstoarray R9d
		pinsrd xmm0, EAX, 2
		inc R9d
		accesstoarray R9d
		pinsrd xmm0, EAX, 3
		; loaded to xmm0 in the correct order + restored initial j value
		inc R9d ; increment so that I can subtract the correct number in cases
		pinsrd xmm1, R10d, 0 ; loading the current analyzed array position to the first position xmm1
		shufps xmm1, xmm1, 00000000b ; and shuffling into all its positions
		pcmpgtd xmm1, xmm0 ;comparison for all items greater or equal - the result in xmm1
		movmskps EAX, xmm1 ; getting the first bit of each of the 4 positions and copying to eax
		;depending on how many 1s were there
		cmp EAX, 0
		je case0
		cmp EAX, 1
		je case1
		cmp EAX, 3
		je case3
		cmp EAX, 7
		je case7
		cmp EAX, 15
		je case15
		case0: ; as from all 4 it was smaller, we are going again but for 4 even earlier ones
			sub R9d, 4
			jmp whileLoopCont
		case1:
			sub R9d, 3 ;the appropriate subtraction of j to insert into the corresponding positions
			jmp saving
		case3:
			sub R9d, 2
			jmp saving
		case7:
			sub R9d, 1
			jmp saving
		case15:
			sub R9d, 0
			jmp saving
		saving:
		inc R14d ; the shift will extend us by one sorted fragment, so we have to increment it
		movallandsave R9d, R10d, R14d
		inc R8d ;i++
		jmp contmainLoop
	endWhileCont: ; I have to analyze what is happening as I need to pack on items 2, 1, 0
	dec R9d
	cmp R9d, 0
	jl insert
	accesstoarray R9d
	cmp R10d, EAX
	jge insert
	dec R9d
	cmp R9d, 0
	jl insert
	accesstoarray R9d
	cmp R10d, EAX
	jge insert
	dec R9d
	insert:
	inc R9d
	inc R14d ;i++
	movallandsave R9d, R10d, R14d
	inc R8d
	jmp contmainLoop
ending:
ret

InsertionSort endp



end