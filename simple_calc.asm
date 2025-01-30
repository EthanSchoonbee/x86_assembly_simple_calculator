; AUTHOR: Ethan Schoonbee
; CREATED: 30-01-2025
; EDITED: 30-01-2025


;///////////////////////////////////////////////////////////////////////////////////////////////////


; declare entry point of code for assembly
global _start


;///////////////////////////////////////////////////////////////////////////////////////////////////


; section for storing variables (data)
section .data

	welcome db 0dh, 0ah, 0dh, 0ah, " ************************** Hello and welcome to my calculator **************************", 0dh, 0ah, 0dh, 0ah

	; 0dh >> end of line
	; 0ah >> go to next line

	welcome_length equ $-welcome

	; equ (equalize)
	; $-welcome >> length of variable

	choice db "Please make your choice: ", 0dh, 0ah
	choice_length equ $-choice

	operator db "1. Add", 0dh, 0ah, "2. Subtract", 0dh, 0ah, "3. Multiply", 0dh, 0ah, "4. Divide", 0dh, 0ah, "5. Exit",10
	operator_lenth equ $-operator

	; temorary variable to store the user input
	tmp: db 0,0;

	first_number db "Please enter your first number: ", 0dh, 0ah
	first_number_length db equ $-first_number

	; temporary variables to store the first and second numbers
	first_temp: db 0,0;
	second_temp: db 0,0;

	answer db "Answer of: "
	answer_length equ $-answer

	minus db " - "
	minus_length equ $-minus

	plus db " + "
	plus_length equ $-plus

	equals db " = "
	equals_length equ $-equals

;///////////////////////////////////////////////////////////////////////////////////////////////////


; section for program logic
section .text

; entry point for code
_start:

	; create a loop for calculator
	LOOP:

		call welcome_message	; func to display welcome message
		call get_choice			; func to display choice message
		call operators			; func to let the user choose an operator

		; compare input to list of valid operators and jump to the relevant funcition
		cmp byte[rsi], '1' 		; compare (cmp) the input to 1, if true, jump to the Add func
		je Add					; jump if equal (je) to Add func

		cmp byte[rsi], '2'
		je Subtract				; jump if equal (je) to Subtract func

		cmp byte[rsi], '3'
		je Multiply				; jump if equal (je) to Multiply func

		cmp byte[rsi], '4'
		je Divide				; jump if equal (je) to Divide func

		cmp byte[rsi], '5'
		je Exit					; jump if equal (je) to Exit func

		; func to diplay welcom message
		welcome_message:
			mov rax, 0x1			; set sys_call to sys_write
			mov rdi, 1  			; 1 = stdout (console)
			mov rsi, welcome  		; generate welcome message
			mov rdx, welcome_length ; reserve bits for welcome message
			syscall					; syscall to output the message
			ret						; return back to the main loop

		; func to display choice message
		get_choice:
			mov rax, 0x1			; set sys_call to sys_write
			mov rdi, 1  			; 1 = stdout (console)
			mov rsi, choice  		; generate choice message
			mov rdx, choice_length  ; reserve bits for message length 
			syscall					; syscall to output the message
			ret						; return back to the main loop

		; func to diplay choice message
		operators:
			mov rax, 0x1
			mov rdi, 1
			mov rsi, operator
			mov rdx, operator_lenth
			syscall
			ret

		; func to get the user input for operation choice
		get_input:
			mov rax, 0  			; set sys_call to sys_read
			mov rdi, 0  			; 0 = stdin
			mov rsi, tmp 			; @ tmp
			mov rdx, 2  			; 2 bytes >> 1 for input number, 1 for newline
			syscall					; syscall to output the message

		; func to handle additon operations
		Add:
			; capture first number

			mov rax, 0x1					; set sys_call to sys_write
			mov rdi, 1  					; 1 = stdout (console)
			mov rsi, first_number  			; generate first_number message
			mov rdx, first_number_length	; reserve bits for message length 
			syscall							; syscall to output the message

			mov rax, 0 						; set sys_call to sys_read
			mov rdi, 0  					; 0 = stdin
			mov rsi, first_temp 			; @ tmp
			mov rdx, 2						; 2 bytes >> 1 for input number, 1 for newline
			syscall							; syscall to output the message

			mov r8, first_temp				; store the first temporary number memory address into register 8
											; 	>> registers are faster to access than memory
											;	>> allows cpu to perform arithmetic directly on them
											;	   instead of needing to access memory repeatedly
											;	>> regiters are not volitile like memory

			; capture second number

			mov rax, 0x1					; set sys_call to sys_write
			mov rdi, 1  					; 1 = stdout (console)
			mov rsi, second_number  			; generate second_number message
			mov rdx, second_number_length	; reserve bits for message length 
			syscall							; syscall to output the message

			mov rax, 0 						; set sys_call to sys_read
			mov rdi, 0  					; 0 = stdin
			mov rsi, second_temp 			; @ tmp
			mov rdx, 2						; 2 bytes >> 1 for input number, 1 for newline
			syscall							; syscall to output the message

			mov r9, second_temp				; store the second temporary number memory address into register 9

			push r8							; push r8 memory address onto the stack 
											; 	>> so we can restore the orginal memory locations later
			push r9							; push r9 memory address onto the stack

			mov r8, [first_temp]			; move the actual contents of the first_temp value into r8
			mov r9, [second_temp]			; move the actual contents of the second_temp value into r9

			sub r8, 48						; subtract 48 of the content to get the actual (numeric) value in ASCII
			sub r9, 48						; subtract 48 of the content to get the actual (numeric) value in ASCII

			mov r10, r8						; move r8 into register r10
			add r10, r9						; add r9 to r10 and store it in r10

			pop r9							; remove r9 from the stack (restores original memory address)
			pop r8							; remove r8 from the stack (restores original memory address)

			add r10, 48						; add 48 to r10 to display in ASCII

			; display answer message
			mov rax, 0x1
			mov rdi, 1
			mov rsi, answer
			mov rdx, answer_length
			syscall

			; display r8 content
			mov rax, 0x1
			mov rdi, 1
			mov rsi, r8
			mov rdx, 1
			syscall

			; display plus sign
			mov rax, 0x1
			mov rdi, 1
			mov rsi, plus
			mov rdx, plus_length
			syscall

			; display r9 content
			mov rax, 0x1
			mov rdi, 1
			mov rsi, r9
			mov rdx, 1
			syscall

			; display equals sign
			mov rax, 0x1
			mov rdi, 1
			mov rsi, equals
			mov rdx, equals_length
			syscall

			; display r10 content (answer)
			mov rax, 0x1
			mov rdi, 1
			mov rsi, r10
			mov rdx, 1
			syscall

			jmp LOOP		; jump back to the main program loop

		; func to handle subtraction operations
		Subtract:
			; capture first number

			mov rax, 0x1					; set sys_call to sys_write
			mov rdi, 1  					; 1 = stdout (console)
			mov rsi, first_number  			; generate first_number message
			mov rdx, first_number_length	; reserve bits for message length 
			syscall							; syscall to output the message

			mov rax, 0 						; set sys_call to sys_read
			mov rdi, 0  					; 0 = stdin
			mov rsi, first_temp 			; @ tmp
			mov rdx, 2						; 2 bytes >> 1 for input number, 1 for newline
			syscall							; syscall to output the message

			mov r8, first_temp				; store the first temporary number memory address into register 8
											; 	>> registers are faster to access than memory
											;	>> allows cpu to perform arithmetic directly on them
											;	   instead of needing to access memory repeatedly
											;	>> regiters are not volitile like memory

			; capture second number

			mov rax, 0x1					; set sys_call to sys_write
			mov rdi, 1  					; 1 = stdout (console)
			mov rsi, second_number  			; generate second_number message
			mov rdx, second_number_length	; reserve bits for message length 
			syscall							; syscall to output the message

			mov rax, 0 						; set sys_call to sys_read
			mov rdi, 0  					; 0 = stdin
			mov rsi, second_temp 			; @ tmp
			mov rdx, 2						; 2 bytes >> 1 for input number, 1 for newline
			syscall							; syscall to output the message

			mov r9, second_temp				; store the second temporary number memory address into register 9

			push r8							; push r8 memory address onto the stack 
											; 	>> so we can restore the orginal memory locations later
			push r9							; push r9 memory address onto the stack

			mov r8, [first_temp]			; move the actual contents of the first_temp value into r8
			mov r9, [second_temp]			; move the actual contents of the second_temp value into r9

			sub r8, 48						; subtract 48 of the content to get the actual (numeric) value in ASCII
			sub r9, 48						; subtract 48 of the content to get the actual (numeric) value in ASCII

			mov r10, r8						; move r8 into register r10
			sub r10, r9						; subtract r9 to r10 and store it in r10

			pop r9							; remove r9 from the stack (restores original memory address)
			pop r8							; remove r8 from the stack (restores original memory address)

			add r10, 48						; add 48 to r10 to display in ASCII

			; display answer message
			mov rax, 0x1
			mov rdi, 1
			mov rsi, answer
			mov rdx, answer_length
			syscall

			; display r8 content
			mov rax, 0x1
			mov rdi, 1
			mov rsi, r8
			mov rdx, 1
			syscall

			; display plus sign
			mov rax, 0x1
			mov rdi, 1
			mov rsi, minus
			mov rdx, minus_length
			syscall

			; display r9 content
			mov rax, 0x1
			mov rdi, 1
			mov rsi, r9
			mov rdx, 1
			syscall

			; display equals sign
			mov rax, 0x1
			mov rdi, 1
			mov rsi, equals
			mov rdx, equals_length
			syscall

			; display r10 content (answer)
			mov rax, 0x1
			mov rdi, 1
			mov rsi, r10
			mov rdx, 1
			syscall

			jmp LOOP		; jump back to the main program loop


;///////////////////////////////////////////////////////////////////////////////////////////////////