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
  mov eax, ecx
  call print_string
  mov edx, 0
  loop:
	cmp byte[ecx], 0
	je done
	inc ecx
	inc edx
	jmp loop
  done:
  call print_nl
  mov eax, edx
  call print_int
  
  popa
  leave
  ret