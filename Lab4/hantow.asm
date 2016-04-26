%include "asm_io.inc"

SECTION .data

errargc: db "Incorrect number of arguments",10,0   
errarg: db "Incorrect argument",10,0
errsmall: db "Argument too small or not a number",10,0
errbig: db "Argument too big or not a number",10,0
done: db "                                    DONE",10,0
fmt: db "%d",10,0

SECTION .bss

level:  resd 1
peg:  resd 1
pegslot: resd 1
line: resb 80
disksymb: resb 1
peg1: resd 9
peg2: resd 9
peg3: resd 9

SECTION .text
   global  asm_main

; subroutine showp -- show peg; paramter 1, 2 or 3 on stack
showp:
   enter 0,0             ; setup routine
   pusha                 ; save all registers

   ; peg index on stack at address ebp+8
   mov eax, ebp
   add eax, 8
   mov edx, [eax]  ; edx is 1 or 2 or 3

   cmp edx, 1
   je P1
   cmp edx, 2
   je P2
   mov ebx, peg3
   jmp PP 
   P2: mov ebx, peg2
   jmp PP
   P1: mov ebx, peg1
   PP:

   ; ebx points to the beginning of the peg and subsequent entries
   ; counting loop conrolled by ecx

   mov ecx, 0
   LL: cmp ecx, 8
   je LL1
   mov eax, dword [ebx]
   call print_int
   mov eax, ','
   add ecx, 1
   add ebx, 4
   jmp LL
   LL1:
   mov eax, dword [ebx]
   call print_int
   call print_nl

   popa                  ; restore all registers
   mov eax, 0            ; return back to caller
   leave                     
   ret
; end subroutine showp



; subroutine set_pegs   one parameter on stack: n
set_pegs:
   enter 0,0             ; setup routine
   pusha                 ; save all registers

   ; pre-initilaize all pegs
   mov eax, peg1
   mov ebx, 1
   L1: cmp ebx, 27
   ja L11
   mov [eax], dword 0
   add eax, 4
   add ebx, 1
   jmp L1
   L11:

   mov eax, peg1
   add eax, 32
   mov [eax], dword 9

   mov eax, peg2
   add eax, 32
   mov [eax], dword 9

   mov eax, peg3
   add eax, 32
   mov [eax], dword 9

   ; n is at address ebp+8
   mov eax, ebp
   add eax, 8
   mov ebx, [eax]     ; ebx contains n

   ; values needed to be stored are 1, 2, ... ebx
   mov eax, peg1
   add eax, 28
   L12: cmp ebx, 0
   je L13
   mov [eax], dword ebx
   sub eax, 4
   sub ebx, 1
   jmp L12
   L13:
 
   popa                  ; restore all registers
   leave                     
   ret
; end of subroutine set_pegs

    

; subroutine show_pegs, no parameters uses globals
; peg1, peg2, peg3, level, peg, pegslot, line, disksymb
show_pegs:               ;
   enter 0,0             ; setup routine
   pusha                 ; save all registers

   mov [pegslot], dword peg1
   mov esi, line;

   ; for all levels
   mov [level], dword 0
   LEVEL_LOOP: cmp [level], dword 8
   ja LEVEL_LOOP_END

      ; for all pegs
      mov [peg], dword 1
      PEG_LOOP: cmp [peg], dword 3
      ja PEG_LOOP_END

         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ; number of left blanks: 3+9-[[pegslot]]=12-[[pegslot]]
         mov eax, dword 12
         mov ebx, dword [pegslot]
         sub eax, dword [ebx]
         mov ecx, eax            ; remember it for later in ecx

         mov eax, 1
         LBL: cmp eax, ecx
         ja ELBL

            mov [esi], byte ' '
            add esi, 1

         add eax, 1
         jmp LBL
         ELBL:

         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ; number of left disksymbs: [[pegslot]]
         mov ebx, dword [pegslot]
         mov eax, dword [ebx]
         mov edx, eax            ; remember it for later in edx

         cmp [level],dword 8
         je IF1
         mov [disksymb], byte '+'
         jmp IF2
         IF1: mov [disksymb], byte 'X'
         IF2:
         
         mov eax, 1
         LDL: cmp eax, edx
         ja ELDL

            cmp [level], dword 8
            je LDISK
            mov [esi], byte '+'
            jmp LDISK1
            LDISK: mov [esi], byte 'X'
            LDISK1: add esi, 1

         add eax, 1
         jmp LDL
         ELDL:

         ; center
         cmp [level], dword 8
         je BASE
         mov [esi], byte '|'
         jmp BASE1
         BASE: mov [esi], byte 'X'
         BASE1: add esi, 1

         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ; number of right disksymbs: remembered in edx
         mov eax, 1
         RDL: cmp eax, edx
         ja ERDL

            cmp [level], dword 8
            je RDISK
            mov [esi], byte '+'
            jmp RDISK1
            RDISK: mov [esi], byte 'X'
            RDISK1: add esi, 1

         add eax, 1
         jmp RDL
         ERDL:

         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ; number of right blanks: remembered in ecx
         mov eax, 1
         RBL: cmp eax, ecx
         ja ERBL

            mov [esi], byte ' '
            add esi, 1

         add eax, 1
         jmp RBL
         ERBL:

      add [peg], dword 1
      add [pegslot], dword 36
      jmp PEG_LOOP
      PEG_LOOP_END:

   ; print line
   mov eax, line
   call print_string
   call print_nl
   mov esi, line   ; get ready for next line

   add [level], dword 1
   sub [pegslot], dword 104  ; -36 to compensare, -36-36+4 to position to peg1 
   jmp LEVEL_LOOP
   LEVEL_LOOP_END:

   popa                  ; restore all registers
   leave                     
   ret
; end of subroutine show_pegs




; subroutine move_disk, two parameters: to-peg
;                                       from-peg on the stack
move_disk:
   enter 0,0             ; setup routine
   pusha

   ; to-peg at address ebp+8
   ; from-peg at address ebp+12
   ; for debugging -- show parameters and return
   jmp move_disk_NOPARAMS
   mov ebx, ebp
   add ebx, 8
   mov eax, [ebx]
   call print_int
   mov eax, ','
   call print_char
   add ebx, 4
   mov eax, [ebx]
   call print_int
   call print_nl
   jmp move_disk_end
  
   move_disk_NOPARAMS:

   mov eax, ebp
   add eax, 12
   mov ebx, [eax]
   mov [peg], dword ebx    ; [peg] is 1 or 2 or 3, index of from-peg

   ; find top disk on from-peg
   cmp [peg], dword 1
   je FROM_1
   cmp [peg], dword 2
   je FROM_2
   FROM_3: mov edx, peg3
   jmp FROM_SELECTED
   FROM_2: mov edx, peg2
   jmp FROM_SELECTED
   FROM_1: mov edx, peg1
   FROM_SELECTED:
   
   ; edx points to the beginning of the array for from-peg
   ; find the first non-zero, remember it, make it zero
   F1: cmp [edx], dword 0
       jne F2
       add edx, 4
       jmp F1
   F2: mov ecx, [edx]      ; remember the value in ecx
       mov [edx], dword 0  ; zero the array entry

   mov eax, ebp
   add eax, 8
   mov ebx, [eax]
   mov [peg], dword ebx    ; [peg] is 1 or 2 or 3, index of to-peg

   ; find top empty slot to-peg
   cmp [peg], dword 1
   je TO_1
   cmp [peg], dword 2
   je TO_2
   TO_3: mov edx, peg3
   jmp TO_SELECTED
   TO_2: mov edx, peg2
   jmp TO_SELECTED
   TO_1: mov edx, peg1
   TO_SELECTED: add edx, 32
   
   ; edx points to the end of the array for to-peg
   ; find the first zero from the end
   T1: cmp [edx], dword 0
       je T2
       sub edx, dword 4
       jmp T1
   T2: mov [edx], ecx   ; put in the remembered value

move_disk_end:
   popa                  ; restore all registers
   leave                     
   ret
; end of subroutine move_disk




; subroutine hanoi  parameters on stack:
;                           help peg
;                           dest peg
;                           orig peg
;                           n -- number of disks to move 
hanoi:
   enter 0,0             ; setup routine
   pusha                 ; save all registers

   ; help at address ebp+8
   ; dest at address ebp+12
   ; orig at address ebp+16
   ; n at address ebp+20

   ; for debugging -- show parameters and return
   jmp hanoi_NOPARAMS
   mov ebx, ebp
   add ebx, 8
   mov eax, [ebx]
   call print_int
   mov eax, ','
   call print_char
   add ebx, 4
   mov eax, [ebx]
   call print_int
   mov eax, ','
   call print_char
   add ebx, 4
   mov eax, [ebx]
   call print_int
   mov eax, ','
   call print_char
   add ebx, 4
   mov eax, [ebx]
   call print_int
   call print_nl
   jmp hanoi_end
  
   hanoi_NOPARAMS:

   ; determine base case or non-base case
   mov eax, ebp
   add eax, 20   ; eax address of n
   cmp [eax], dword 2
   ja NOT_BASE_CASE

   ; doing base case: move disk from orig to help
   mov ebx, ebp           ; push orig
   add ebx, 16
   mov eax, dword [ebx]
   push eax
   mov ebx, ebp           ; push help
   add ebx, 8
   mov eax, dword [ebx]
   push eax

   ;     stack  help
   ;            orig
  
   call move_disk         ; move disk from orig to help
   add esp, 4             ; normally undo 2 pushes, but we want orig to stay
   call show_pegs
   call read_char

   ; now move disk from orig to dest, orig is already on top of the stack
   mov ebx, ebp
   add ebx, 12
   mov eax, dword [ebx]
   push eax               ; now we have dest on stack

   ;     stack  dest
   ;            orig
  
   call move_disk         ; move disk from orig to dest
                          ; normally undo 2 pushes, but we will just override
                          ; orig by help
   call show_pegs
   call read_char
   
   ; now move disk from help to dest and return
   mov ebx, ebp
   add ebx, 8
   mov eax, dword [ebx]
   mov ebx, esp
   add ebx, 4
   mov [ebx], dword eax   

   ; stack   dest
   ;         help

   call move_disk         ; move disk from help to dest
   add esp, 8             ; undo 2 pushes
   call show_pegs
   call read_char
   jmp hanoi_end      ; end of base case

   NOT_BASE_CASE:

   ;hanoi(n-1,orig,help,dest)
   ;move_disk(orig,dest)
   ;hanoi(n-1,help,dest,orig)

   ;hanoi(n-1,orig,help,dest)
   mov ebx, ebp
   add ebx, 20
   mov eax, [ebx]
   sub eax, 1
   push eax       ; push n-1
   mov ebx, ebp
   add ebx, 16
   mov eax, [ebx]
   push eax       ; push orig
   mov ebx, ebp
   add ebx, 8
   mov eax, [ebx]
   push eax       ; push help
   mov ebx, ebp
   add ebx, 12
   mov eax, [ebx]
   push eax       ; push dest
   call hanoi
   add esp, 16

   ;move_disk(orig,dest)
   mov ebx, ebp
   add ebx, 16
   mov eax, [ebx]
   push eax       ; push orig
   mov ebx, ebp
   add ebx, 12
   mov eax, [ebx]
   push eax       ; push dest
   call move_disk
   add esp, 8
   call show_pegs
   call read_char

   ;hanoi(n-1,help,dest,orig)
   mov ebx, ebp
   add ebx, 20
   mov eax, [ebx]
   sub eax, 1
   push eax       ; push n-1
   mov ebx, ebp
   add ebx, 8
   mov eax, [ebx]
   push eax       ; push help
   mov ebx, ebp
   add ebx, 12
   mov eax, [ebx]
   push eax       ; push dest
   mov ebx, ebp
   add ebx, 16
   mov eax, [ebx]
   push eax       ; push orig
   call hanoi
   add esp, 16
   
   hanoi_end: 
   popa                  ; restore all registers
   leave                     
   ret
; end of subroutine hanoi

asm_main:
   enter 0,0             ; setup routine
   pusha                 ; save all registers

   ; check argc
   mov eax, dword [ebp+8] 
   ; check that it has value 2
   cmp eax, dword 2
   je argcok
   mov eax, errargc
   call print_string
   jmp main_end

   argcok:
   ; check argv[1]
   mov ebx, dword [ebp+12]   ; ebx points to argv[]
   mov ecx, dword [ebx+4]    ; ecx points to argv[1]

   ; byte [ecx+1] must be 0
   mov eax, dword 0
   mov al, byte [ecx+1]
   cmp eax, dword 0
   je byte1_big_enough_test
   mov eax, errarg
   call print_string
   jmp main_end

   ; byte [ecx] must be a digit between '2' and '8'S

   byte1_big_enough_test:

   mov eax, dword 0
   mov al, byte [ecx]
   cmp al, '2'
   jae byte1_small_enough_test
   mov eax, errsmall            ; argument too small
   call print_string
   jmp main_end

   byte1_small_enough_test:

   cmp al, '8'
   jbe argok
   mov eax, errbig              ; argument too big
   call print_string
   jmp main_end
   
   argok:
   sub al, '0'           ; eax = no of disks

   push eax              ; number of disks
   call set_pegs
   ; normally we would undo push, but we want to leave n on stack
   ; for hanoi
 
   call show_pegs
   call read_char

   ; n already on the stack
   push 1 ; orig
   push 2 ; dest
   push 3 ; help
   call hanoi
   add esp, 16

   mov eax, done
   call print_string

main_end:
   popa                  ; restore all registers
   mov eax, 0            ; return back to caller
   leave                     
   ret

