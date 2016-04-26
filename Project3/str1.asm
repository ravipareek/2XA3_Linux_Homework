%include "asm_io.inc"
global asm_main

section .data
section .bss

section .text

asm_main:
  enter 0,0
  pusha
  
  mov ebx, dword [ebp+12]  ; address of argv[]
  mov ecx, dword [ebx+4]     ; get the argument
  mov edx, 0
  digit:
	cmp byte[ecx], '0'
	jb letter
	cmp byte[ecx], '9'
	jae letter
	cmp edx, 0
	je loop
	sub byte[ecx], '0'
	add byte[ecx], '1'
	jmp loop
	
  loop:
	cmp byte[ecx], 0
	je done
	cmp byte[ecx+1],0
	je done
	jmp print
  letter:
	mov edx, 1
	jmp print
  print:
	mov eax, [ecx]
	call print_char
	mov eax, ' '
	call print_char
	inc ecx
	jmp digit
  done:
	mov eax, [ecx]
	call print_char
  popa
  leave
  ret