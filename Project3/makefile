all: str1 str2 str3
str1: str1.o asm_io.o
	 gcc -m32 -o str1 str1.o driver.c asm_io.o
str1.o: str1.asm
	nasm -f elf32 -o str1.o str1.asm
str2: str2.o asm_io.o
	 gcc -m32 -o str2 str2.o driver.c asm_io.o
asm_io.o: asm_io.asm
	nasm -f elf32 -d ELF_TYPE asm_io.asm
str2.o: str2.asm
	nasm -f elf32 -o str2.o str2.asm
str3: str3.o asm_io.o
	 gcc -m32 -o str3 str3.o driver.c asm_io.o
str3.o: str3.asm
	nasm -f elf32 -o str3.o str3.asm
clean:
	rm *.o str1
	rm *.o str2
	rm *.o str3