all: lynarr lyx
lynarr: lynarr.o asm_io.o
	 gcc -m32 -o lynarr lynarr.o driver.c asm_io.o
lynarr.o: lynarr.asm
	nasm -f elf32 -o lynarr.o lynarr.asm
asm_io.o: asm_io.asm
	nasm -f elf32 -d ELF_TYPE asm_io.asm
lyx: lyx.o asm_io.o
	 gcc -m32 -o lyx lyx.o driver.c asm_io.o
lyx.o: lyx.asm
	nasm -f elf32 -o lyx.o lyx.asm

clean:
	rm *.o lynarr