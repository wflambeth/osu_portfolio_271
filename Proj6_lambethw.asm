TITLE String Primitives & Macros     (Proj6_lambethw.asm)

; Author: Will Lambeth
; Last Modified: 03/16/2023
; OSU email address: lambethw@oregonstate.edu
; Course number/section:			CS271 Section 400
; Project Number: 06                Due Date: 03/19/2023
; Description: Reads in exactly 10 signed integers from a user, and 
;			   outputs those integers along with their sum and average. 

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Outputs a provided prompt string, then takes a string from user input and stores.
;
; Receives:
;	prompt = address of prompt string
;	inpt = address to store user input string
;   inpt_len = address to store length of user input
;	MAXINPUTLEN is a global constant
;
; Returns:
;	inpt = string input by user
;	inpt_len = length of string in inpt
;
; ---------------------------------------------------------------------------------
mGetString MACRO prompt:REQ, inpt:REQ, inpt_len:REQ
	push	EAX
	push	ECX
	push	EDX

	; display prompt
	mov		EDX, prompt
	mDisplayString EDX
	
	; read string of <= max input length
	mov		ECX, MAXINPUTLEN + 1	; +1 to include null terminator
	mov		EDX, inpt
	call	ReadString
	
	; store input and length for use in calling procedure
	mov		inpt, EDX		 
	mov		inpt_len, EAX	

	pop		EDX
	pop		ECX
	pop		EAX
ENDM


; ---------------------------------------------------------------------------------
; Name: mDisplayString
; 
; Displays a provided string to standard output.
;
; Receives:
;	string = address of string to write
;
; ---------------------------------------------------------------------------------
mDisplayString MACRO string:REQ
	push	EDX

	mov		EDX, string
	call	WriteString

	pop		EDX
ENDM

	; global constant
	MAXINPUTLEN = 11

.data
	; text to be displayed to user
	progName	BYTE "---- Low-Level I/O ---- A MASM Experience by Will Lambeth ----",0
	intro_1		BYTE "Please provide ten signed decimal integers, between -2,147,483,648 and 2,147,483,647.",0
	intro_2		BYTE "Once you have, I'll read back the numbers, their sum, and their truncated average.",0

	prompt_1	BYTE "Please enter a signed number: ",0

	error_1		BYTE "ERROR: Integer invalid or out of range",0
	
	result_1	BYTE "You entered the following numbers:",0
	result_2	BYTE "Their sum is: ",0
	result_3	BYTE "And their truncated average is: ",0

	goodbye		BYTE "Thanks for a great term, enjoy your break!",0

	; storage for input string/length
	input		BYTE MAXINPUTLEN DUP(0)
	input_len	DWORD ?

	; storage for output string
	output		BYTE MAXINPUTLEN + 1 DUP(0)	; +1 so it can always be null-terminated

	; array for number storage
	int_array	SDWORD 10 DUP(?)

	; storage for calculated data
	array_sum	SDWORD ?
	array_avg	SDWORD ?

.code
main PROC
	; print introduction
	push	OFFSET progName
	push	OFFSET intro_1
	push	OFFSET intro_2
	call	Intro

	; initialize read loop and output ptr
	mov		ECX, 10
	mov		EDI, OFFSET int_array

_inputLoop:
	; take in integer from user
	push	OFFSET error_1
	push	OFFSET input_len
	push	EDI
	push	OFFSET input
	push	OFFSET prompt_1
	call	ReadVal
	
	; increment to next index in SDWORD array and loop
	add		EDI, 4
	loop	_inputLoop

	; initialize output loop
	mov		ECX, 9
	mov		EDI, offset int_array

	; Label output
	mov		EDX, OFFSET result_1
	call	CRLF
	mDisplayString EDX
	call	CRLF

_outputLoop:
	; output provided integers
	push	EDI
	push	OFFSET output
	call	WriteVal
	
	; add comma/space after all but last integer
	mov		AL, ','
	call	WriteChar
	mov		Al, ' '
	call	WriteChar

	; increment and loop
	add		EDI, 4
	loop	_outputLoop

	; final value output outside of loop, to avoid trailing comma
	push	EDI
	push	OFFSET output
	call	WriteVal
	call	CRLF

	; calculate sum/avg of stored integers
	push	OFFSET array_avg
	push	OFFSET array_sum
	push	OFFSET int_array
	call	GetSumAvg

	; label and output sum	
	mov		EDX, OFFSET result_2
	mDisplayString EDX
	push	OFFSET array_sum
	push	OFFSET output
	call	WriteVal
	call	CRLF

	; label and output avg
	mov		EDX, OFFSET result_3
	mDisplayString EDX
	push	OFFSET array_avg
	push	OFFSET output
	call	WriteVal
	call	CRLF
	call	CRLF

	; say goodnight, program! 
	mov		EDX, OFFSET goodbye
	mDisplayString EDX

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: Intro
;
; Greets user and outputs information about program and programmer.
;
; Receives:
;	[EBP + 20] progName = byte string containing program title and programmer name
;	[EBP + 16] intro_1 = byte string containing program instructions
;	[EBP + 12] intro_2 = byte string explaining program output
; ---------------------------------------------------------------------------------
Intro PROC USES EDX
	push	EBP
	mov		EBP, ESP

	mov		EDX, [EBP + 20]
	mDisplayString EDX
	call	CRLF

	mov		EDX, [EBP + 16]
	mDisplayString EDX
	call	CRLF

	mov		EDX, [EBP + 12]
	mDisplayString EDX
	call	CRLF
	call	CRLF

	pop		EBP
	ret		12
Intro ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Reads a string input from the user (via mGetString macro), then converts it
; to a signed integer value and stores the result. Validates input and throws
; errors to user if string does not represent a valid signed integer.
; 
; Receives: 
;	[EBP + 24] prompt_1 = byte string prompting user for input
;	[EBP + 28] input = address of byte array for storing input strings
;	[EBP + 32] = address of cell in integer array to store result
;	[EBP + 36] = address of DWORD to store length of input string
;	[EBP + 40] = byte string signaling input error to user
;	MAXINPUTLEN is a global constant
;
; Returns:
;	[EBP + 32] = Integer value of input string
; 
; ---------------------------------------------------------------------------------
ReadVal PROC USES EDX ECX EAX EBX
	push	EBP
	mov		EBP, ESP
_callGetString:
	; invoke macro to prompt/read input
	mGetString [EBP + 24], [EBP + 28], [EBP + 36]

	; check for invalid input length, output error if so
	mov		EAX, [EBP + 36]
	cmp		EAX, 0		 
	je		_error
	cmp		EAX, MAXINPUTLEN
	ja		_error

	; initialize registers for read loop
	mov		ECX, [EBP + 36]	; loop counter (uses input read length)
	mov		ESI, [EBP + 28]	; string read pointer (for use w/ LODSB)
	mov		EBX, 0			; running total of input integer

	; check for leading sign
	mov		EAX, [ESI]
	cmp		AL, 43
	je		_signPos
	cmp		AL, 45
	je		_signNeg

	mov		EDX, 1			; if number is not signed, we assume positive

_readLoop:
	mov		EAX, 0			; clear reg for use in integer calculations below
	lodsb					; Read in next char of string
	
	; Ensure it is a valid digit
	cmp		AL, 48
	jb		_error
	cmp		AL, 57
	ja		_error

	; Multiply current total by 10
	imul	EBX, 10
	jo		_error			; throw error in case of overflow
	
	; Add next digit in ones place
	sub		AL, 48
	imul	EAX, EDX		; multiply by 'sign' stored in EDX (+/- 1)
	add		EBX, EAX		
	jo		_error			; throw error in case of overflow

	loop	_readLoop
	jmp		_endRead

_error:
	; Display error message to user on invalid input
	mov		EDX, [EBP + 40]
	mDisplayString EDX
	call	CRLF
	; Return to start of procedure and re-prompt
	jmp		_callGetString

_signPos:
	; Sets sign to positive if leading '+' exists
	mov		EDX, 1
	jmp		_signCleanup

_signNeg:
	; Sets sign to positive if leading '-' exists
	mov		EDX, -1

_signCleanup:
	; If leading sign, increment ESI/decrement ECX to skip
	inc		ESI			
	loop	_readLoop	
	jmp		_error		; if sign is only character, not a valid number

_endRead:
	; stash output in the output var
	mov		EAX, [EBP + 32]
	mov		[EAX], EBX		
		
	pop		EBP
	ret		20
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
; 
; Converts a stored 32-bit signed integer to a string, and writes to stdout.
; 
; Receives:
;	[EBP + 32] = address of SDWORD integer value to write
;	[EBP + 36] = address of output BYTE string to write to
;
; Preconditions:
;	Output string is filled with 0 values for each BYTE.
;
; Postconditions:
;	Value of integer is printed to stdout as a string. 
;	Output strings is cleared/returned to 0 values.
; 
; ---------------------------------------------------------------------------------
WriteVal PROC USES EDX ECX EAX EBX ESI EDI
	push	EBP
	mov		EBP, ESP
	
	; load output pointer to final index of string, set direction flag
	mov		EDI, [EBP + 32]
	add		EDI, 10
	std	
	
	; load integer value
	mov		EDX, [EBP + 36] 
	mov		EAX, [EDX]

	; load loop counter and divisor
	mov		ECX, 11		
	mov		ESI, 10	

_writeLoop:
	; divide current value by 10
	cdq						
	idiv	ESI	

	; check for negative value and convert to positive if needed
	cmp		EDX, 0
	jge		_continueWriteLoop
	imul	EDX, -1
	imul	EAX, -1

_continueWriteLoop:
	; convert remainder to ASCII char
	add		EDX, 48			

	; shuffle values to put char in AL (for use with STOSB)
	mov		EBX, EAX
	mov		EAX, EDX

	; store in current place on string and iterate backward
	stosb

	; restore remaining value for next IDIV
	mov		EAX, EBX

	; check if remaining value is zero and terminate if so
	cmp		EAX, 0
	je		_negCheck
	loop	_writeLoop


_negCheck:
	; check for negative input value and append minus sign if so
	mov		EDX, [EBP + 36]
	mov		EBX, [EDX]
	cmp		EBX, 0
	jge		_endWrite
	mov		AL, 45
	stosb

_endWrite:
	; invoke macro to output string
	inc		EDI
	mDisplayString EDI

	; zero out string for next usage
	mov		EDI, [EBP + 32]
	mov		AL, 0
	mov		ECX, 11
	cld
_zeroLoop:
	stosb
	loop _zeroLoop

	pop		EBP
	ret		8
WriteVal ENDP

; ---------------------------------------------------------------------------------
; Name: GetSumAvg
;
; Calculates the sum and average of a provided array of 32-bit signed integers,
; storing the results at provided addresses
;
; Receives:
;	[EBP + 28] int_array = array of integers to be summed/averaged
;
; Returns:
;   [EBP + 32] array_sum = sum of the provided integers
;	[EBP + 36] array_avg = average of the provided integers
; ---------------------------------------------------------------------------------
GetSumAvg	PROC USES EAX EBX ECX ESI EDX
	push	EBP
	mov		EBP, ESP

	; Initialize array pointer, sum value, loop counter
	mov		ESI, [EBP + 28]
	mov		EAX, 0
	mov		ECX, 10

_loopSum:
	; add value at current index and increment array pointer
	add		EAX, [ESI]
	add		ESI, 4
	loop	_loopSum

	; store sum
	mov		EBX, [EBP + 32]
	mov		[EBX], EAX
	
	; calculate and store average
	mov		EBX, 10
	cdq
	idiv	EBX
	mov		EBX, [EBP + 36]
	mov		[EBX], EAX
	
	pop		EBP
	ret		12
GetSumAvg	ENDP


END main
