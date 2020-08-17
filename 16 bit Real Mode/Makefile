all: fuckos.img

clean:
	@rm -fv boot.fuk
	@rm -fv fuckos.img
	@rm -fv fuckos.fuk

boot.fuk: boot.asm
	nasm -f bin boot.asm -o boot.fuk

fuckos.fuk: fuckos.asm
	nasm -f bin fuckos.asm -o fuckos.fuk

fuckos.img: boot.fuk fuckos.fuk
	mkdosfs -C fuckos.img 1440
	dd conv=notrunc if=boot.fuk of=fuckos.img
	mkdir tempdir
	sudo mount -o loop -t vfat fuckos.img tempdir
	sudo cp fuckos.fuk tempdir/
	sudo umount tempdir
	rm -rf tempdir