SECTION .data
    fmt1: db "%s",10,0
SECTION .text
    global main
    extern printf
    extern strlen
     
    main:
      ; at this points, argc is on stack at address esp+4
      ; address of 1st argument is on stack at address esp+8
      enter 0,0    
      pusha

      ; at this points, argc is on stack at address ebp+8
      ; address of 1st argument is on stack at address ebp+12

      ; address of 1st argument = name of the program is at address ebp+12
      ; address of 2nd argument = address of 1st argument + 4
      ; address of 3rd argument = address of 1st argument + 8

      mov eax, dword [ebp+12]   ; eax holds address of 1st arg
      add eax, 4                ; eax holds address of 2nd arg
      mov ebx, dword [eax]      ; ebx holds 2nd arg, which is pointer to string
      ; print that string 
      push ebx
      push fmt1
      call printf
      add esp, 8                ; remove the 2 parameters

      ; we have to recompute eax as it was messed up by printf
      mov eax, dword [ebp+12]   ; eax holds address of 1st arg
      add eax, 8                ; eax holds address of 3rd arg
      mov ebx, dword [eax]      ; ebx holds 3rd arg, which is pointer to string
      ; print that string 
      push ebx
      push fmt1
      call printf
      add esp, 8                ; remove the 2 parameters

      popa
      leave
      ret
