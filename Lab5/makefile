all: prog2 prog3 prog4 prog5
prog2: prog2.o
	gcc -m32 -o prog2 prog2.o

prog2.o: prog2.asm
	nasm -f elf32 -o prog2.o prog2.asm
prog3: prog3.o
	gcc -m32 -o prog3 prog3.o

prog3.o: prog3.asm
	nasm -f elf32 -o prog3.o prog3.asm
prog4: prog4.o
	gcc -m32 -o prog4 prog4.o

prog4.o: prog4.asm
	nasm -f elf32 -o prog4.o prog4.asm
prog5: prog5.o
	gcc -m32 -o prog5 prog5.o

prog5.o: prog5.asm
	nasm -f elf32 -o prog5.o prog5.asm
clean:
	rm *.o
	rm prog2
	rm prog3
	rm prog4
	rm prog5