%include "asm_io.inc"

global asm_main

section .data
  argError: db "Wrong number of arguments",0
  capsError: db " was not a lowercase letter",0
  lenError: db "Incorrect length of input",0
  py: db "Printing int", 0
  px: db "Printing chars", 0

section .bss
  X: resb 20
  input: resd 1
  charCount: resd 1
  counter: resd 1
  Y: resb 80
  p: resd 1
  i: resd 1
  k: resd 1
  n: resd 1
  flag: resd 1
section .text

asm_main:
  enter 0,0
  pusha
  
  mov eax, dword [ebp+8]
  cmp eax,2
  jne argumentError
  mov ebx, dword [ebp+12]  ; address of argv[]
  mov ecx, dword [ebx+4]     ; get the argument
  mov [input], dword ecx
  mov [charCount], dword 0
  mov edx, 0
  jmp loop1
loop1:
  mov ecx, dword[input]
	cmp byte[ecx], 0
	je finishedReadString
  add [input], dword 1
	inc edx
	jmp loop1
finishedReadString:
  cmp edx, 1
  jb lengthError
  cmp edx, 20
  ja lengthError
  sub [input], dword edx      ;resetting input to beginning
  jmp checkLowerCase
checkLowerCase:
  mov ebx, dword [input]
  cmp byte[ebx], 0
  je goodInput
  cmp byte[ebx], 'a'
  jb capitalError
  cmp byte[ebx], 'z'
  ja capitalError
  mov ecx, X
  add ecx, dword[charCount]
  mov al, byte[ebx]
  mov [ecx], al
  add [input], dword 1
  add [charCount], dword 1
  jmp checkLowerCase
goodInput:
  mov [flag], dword 0
  push dword[flag]
  push dword[charCount]
  push X
  call display
  add esp, 8
  mov [counter], dword 0
  mov edx, dword[charCount]
  mov ebx, Y
getLynarr:
  cmp edx, dword[counter]
  je gotLynarr
  push dword[counter]
  push edx
  push X
  call maxLyn
  add esp, 12
  mov [ebx], eax
  add ebx, dword 4
  add [counter], dword 1
  jmp getLynarr
gotLynarr:
  mov [flag], dword 1
  push dword[flag]
  push edx
  push Y
  call display
  add esp, 12
  jmp end


; code breaks
capitalError:
  mov al, byte[ebx]
  call print_char
  mov eax, capsError
  call print_string
  call print_nl
  jmp end
argumentError:
  mov eax, argError
  call print_string
  call print_nl
  jmp end
lengthError:
  mov eax, lenError
  call print_string
  call print_nl
  jmp end
end:
  leave
  ret

display:
  enter 0,0
  pusha
  
  mov ebx, dword[ebp+16]
  mov edx, dword[ebp+12]
  mov ecx, dword[ebp+8]
  mov [flag], ebx
  mov [i], dword 0
  sub edx, 1
  cmp ebx, 0
  je print_X
  jne print_Y
  print_X:
    cmp byte[ecx], 0
    je RETURN_char
    mov al, byte[ecx]
    call print_char
    inc ecx
    jmp print_X
  print_Y:
    cmp [i], edx
    je RETURN_int
    mov eax, [ecx]
    call print_int
    mov al, ' '
    call print_char
    add ecx, dword 4
    add [i], dword 1
    jmp print_Y
  RETURN_char:
    call read_char
    popa
    leave
    ret
  RETURN_int:
    mov eax, [ecx]
    call print_int
    call print_nl
    popa
    leave
    ret

maxLyn:
    enter 0,0
    pusha
    ; init
    mov [p], dword 1                ;p
    mov ebx, dword[ebp+8]           ;X
    mov ecx, dword[ebp+12]          ;N-1
    mov edx, dword[ebp+16]          ;k
    mov [k], edx
    mov [n], ecx

    cmp [k], ecx                 ;if k=n-1
    je quickFinish
    mov [i], edx
    loop2:
      add [i], dword 1
      mov eax, dword [i]
      cmp edx, eax           ;if i = n-1
      jae RETURN2

      mov eax, dword [ebp+8]  
      mov ebx, dword [ebp+8]

      add ebx, dword[i]
      mov ecx, dword[i]
      sub ecx, dword[p]
      add eax, ecx
      mov al, byte[eax]
      mov bl, byte[ebx]
      cmp al, bl
      je loop2
      jle alter
      jmp RETURN2
    alter:
      mov eax, [i]
      add eax, 1
      sub eax, [k]
      mov [p], eax
      jmp loop2
    quickFinish:
      mov [p], dword 1
      jmp RETURN2
    RETURN2:
      popa
      mov eax, dword[p]
      leave
      ret
