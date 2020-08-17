all: fuckos.iso

clean:
	@rm -fv boot.fuk
	@rm -fv fuckos.o
	@rm -fv fuckos.fuk
	@rm -fv fuckos.iso
	@rm -fv isodir/boot/fuckos.fuk

boot.fuk: boot.asm
	nasm -f elf32 boot.asm -o boot.fuk

fuckos.o: fuckos.c
	gcc -m32 -c fuckos.c -o fuckos.o

fuckos.iso: boot.fuk fuckos.o
	ld -m elf_i386 -T link.ld -o fuckos.fuk fuckos.o boot.fuk
	cp fuckos.fuk isodir/boot/
	grub2-mkrescue -o fuckos.iso isodir/