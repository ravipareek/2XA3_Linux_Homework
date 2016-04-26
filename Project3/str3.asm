%include "asm_io.inc"
global asm_main

section .data
	errorMsg: db "concatenation too long",0
section .bss

section .text
asm_main:
  enter 0,0
  pusha
  
  mov ebx, dword [ebp+12]  ; address of argv[]
  mov ecx, dword [ebx+4]     ; get the argument
  mov edx, 0
  loop:
	cmp byte[ecx], 0
	je done
	
	mov eax, [ecx]
	call print_char
	inc ecx
	inc edx
	jmp loop
  done:
  
  mov ecx, dword [ebx+8]     ; get the argument
 loop2:
	cmp byte[ecx], 0
	je done2
	
	mov eax, [ecx]
	call print_char
	inc ecx
	inc edx
	jmp loop2
  done2:
	call print_nl
	cmp edx, 6
	jle goodLength
  
	mov eax, errorMsg
	call print_string
	call print_nl
  goodLength:
	
  popa
  leave
  ret