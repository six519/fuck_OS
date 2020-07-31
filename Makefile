all: fuckos.img

clean:
	@rm -fv boot.bin
	@rm -fv fuckos.img
	@rm -fv fuckos.bin

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

fuckos.bin: fuckos.asm
	nasm -f bin fuckos.asm -o fuckos.bin

fuckos.img: boot.bin fuckos.bin
	mkdosfs -C fuckos.img 1440
	dd conv=notrunc if=boot.bin of=fuckos.img
	mkdir tempdir
	sudo mount -o loop -t vfat fuckos.img tempdir
	sudo cp fuckos.bin tempdir/
	sudo umount tempdir
	rm -rf tempdir