; 2XA3 Final Project - Dec-14-2015
; Kunal Shah 1419350

%include "asm_io.inc"

global  asm_main

SECTION .data
; Error Messages
err1: db "incorrect number of command line arguments, one argument expected",10,0
err2: db "argument must be between 1 and 20 characters long",10,0
err3: db "argument must be lowercase characters",10,0

SECTION .bss

X: resb 20		; Reserve 20 bytes for string input
N: resd 1		; Reserve 1 byte for char count
Y: resd 80		; Reserve 20 words for lyn substring lenghts

; Temparary variables
maxLynFlag: resd 1	; address of the input string
n: resd 1
k: resd 1
p: resd 1
i: resd 1

SECTION .text

asm_main:
	enter 0,0		; setup routine
	pusha			; save all registers

	mov eax, dword [ebp+8]	; argc
	cmp eax, dword 2	; Part 2 - checks if number of arguments is 2
	jne ERR1		; Jump to Error message 1 
	
	; Part 4 - checks that the input string is of length between 1 and 20
	; Part 5 - checks that input string are only the lower case char
	
	mov ebx, dword [ebp+12]	; address of argv[]
	mov ecx, dword [ebx+4]	; get argv[1] argument -- ptr to string
	mov edx, 0		; char counter
	mov eax, 0  		; Capital Flag - if 0 all lowercase

error_check_loop: 
	cmp byte [ecx], byte 0	; is there a null char, end of the string?
	je error_check_loop_end	; end loop because null char

        cmp byte [ecx], 'a'
        jl ERR3a		; found some char less than 'a'
        cmp byte [ecx], 'z'
        jg ERR3a		; found some char greater than 'z'
Continue:
	add edx, 1		; count++
	add ecx, 1		; increment to get to the next char in the string 
	jmp error_check_loop

error_check_loop_end:
	cmp edx,20		; is count > 20
	jg ERR2			; Jump to Error message 2 - input string is too larger
	cmp eax, 1		; if not lowercase
	je ERR3    		; there was invalid char in the string

	mov [N], dword edx	; save length of the input string in N

	mov ecx, X
	mov eax, dword [ebp+12]	; address of argv[]
	mov ebx, dword [eax+4]	; get argv[1] argument -- ptr to string
	mov [i], dword 0

part6_loop:
; edx = count of # characters in my string
; ebx = arg[1] original command
; eax = counter
; ecx = address of X[eax]
        cmp [i], edx		; if lenght of array is less than count
	jge part6_end_loop	; jmp to end loop
	mov al, byte [ebx]	; move byte to al for copy
	mov [ecx], al		; copy al to X[i]
	add ecx, dword 1	; increment adress by 1
	add ebx, dword 1	; increment original array 1
	add [i], dword 1	; i++
	jmp part6_loop

part6_end_loop:

;  Display string before processing 
	push dword 0	; flag = 0 to print string
      	push dword[N]  	; if display(Array X, int N, int flag), push N first
	push X		; address of the orginal string to print
	call display	; call display to print string
	add esp, 12

part9: 
	mov edx, Y 	; store lyn
	mov ebx, 0	; k = 0
part9_loop:
	mov ecx, dword [N]	; ebx is loop count 
	cmp ebx, ecx		; if count = n jump to part 10
	jge part10
        push ebx	; k
	push dword[N]	; n
	push X		; string
	call maxLyn 	
	add esp, 12
	mov [edx], eax 	; store substring of k
	add ebx, 1	; k = k++
	add edx, 4      ; increment address of the output string to next word
	jmp part9_loop	

part10:
; display the output array of integers that show maximum Lyndon strings
	push dword 1	; flag = 1 to print lyn sub-string values
      	push dword[N]  	; size of interger array to print
	push Y 		; address of the integer array
	call display	; call display to print integer array
	add esp, 12

	; All DONE
        jmp asm_main_end

ERR1:
	mov eax, err1 	; Error message 1: incorrect number of command line arguments
	call print_string
	jmp asm_main_end
ERR2:
        mov eax, err2	; Error message 2: input stirng lenght
        call print_string
        jmp asm_main_end
ERR3a:
	mov eax, 1	; if the char is UpperCase
	jmp Continue	; jump back to error checking and input string counting
ERR3:
        mov eax, err3	; Error message 3: only lowercase char
        call print_string
        jmp asm_main_end

; Program ending
asm_main_end:
	popa                  ; restore all registers
	leave                     
	ret

; display string or interger array, depending on flag
; INPUT: 1) pointer to string or integer array
;        2) size of string or integer array
;        3) flag=0 to display string.  flag=1 to display integer array  
display:
        enter 0, 0
	pusha                 ; save all registers

        mov ecx, dword[ebp+8]	; ecx = string to print
        mov ebx, dword[ebp+12]	; ebx = N
	mov eax, dword[ebp+16]	; flag for either string or int
	mov [i], dword ebx      ; save length to loop counter i
	mov [maxLynFlag], eax   ; save flag 

display_loop:
	cmp ebx, dword 0        
        jbe display_return	; end loop, if counter reaches zero
	mov eax, dword [maxLynFlag]  ; retrive saved flag 
	cmp eax, 1		; flag = 1 mean, print integer
	je display_int		; jump to display integer array
        mov al, byte[ecx]	; continue to display next char of the string
        call print_char		; print one character stored in al register
        add ecx, dword 1	; increment array to next byte
	jmp display_cont	; jump over the next section to continue to display `
display_int:
        mov eax, [ecx]		; load interger value from integrage array
	call print_int		; print integer
	mov al, ' '		; print space after interger
	call print_char	
        add ecx, dword 4  	; since we are printing words, increment address by 4 more
display_cont:
	mov ebx, dword [i]	; reload saved counter value
        sub ebx, dword 1	; decrement counter since one char/int is printed
        mov dword  [i], ebx	; save counter 
        jmp display_loop	; continue loop
display_return:
	call read_char		; the subroutine waits for theuser to hit enter before terminating
	call print_nl		; print next line
	popa			; restore all registers
        leave
        ret


; Function maxLyn
; INPUT:1) Pointer to array Z
;	2) n - size of array
;	3) k - position in array

maxLyn:
	enter 0, 0
	pusha                 ; save all registers

	mov ebx, dword[ebp+8]	; ebx = Z
	mov ecx, dword[ebp+12]  ; ecx = n
	mov edx, dword[ebp+16]  ; edx = k
	mov [k],  edx	; store k in variable
	mov [n],  ecx	; store n in variable
	mov eax, 1		; p = 1
	mov [p], eax		; store p into variable
	mov eax, [n]		; eax = n
	sub eax, 1		; n - 1
	cmp [k], eax		; if k = (n - 1)
	je  maxLyn_RETURN	; return p (1)

	mov edx, [k]		; edx will be our i for the loop
	; edx is the value of k to start with
maxLyn_loop:
	add edx, 1		; i = i+1 (first time this is (k+1)
	cmp edx, [n]		; exit loop, if done
	jge maxLyn_RETURN	; loop completed
 	mov eax, dword [ebp+8]	; load address of our input string
 	mov ebx, dword [ebp+8]	; load address of our input string
	add ebx, edx		; Z[i]	
	mov ecx, edx		; ecx = i
	sub ecx, [p]		; ecx = (i - p)
	add eax, ecx		; Z[i-p]
	mov al, byte [eax]	; al is now byte at Z[i-p]
	cmp al, byte [ebx]	; if Z[i-p] = Z[i]
	je maxLyn_loop		; jump if two char are equal
	jg maxLyn_RETURN	; Z[i-p] > Z[i] 
	mov eax, edx		; p = i
	add eax, 1		; p = i + 1
	sub eax, [k]		; p = i + 1 - k
	mov [p], eax		; store p
	jmp maxLyn_loop		; continue with the loop for next char

maxLyn_RETURN:
	popa			; restore all registers
	mov eax, dword [p]	; return value (p) should be in eax	
	leave
	ret
