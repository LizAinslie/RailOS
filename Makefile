# $@ = target file
# $< = first dependency
# $^ = all dependencies

CC = /usr/local/i386elfgcc/bin/i386-elf-gcc
LD = /usr/local/i386elfgcc/bin/i386-elf-ld

# First rule is the one executed when no parameters are fed to the Makefile
all: run

# Notice how dependencies are built as needed
kernel.bin: kernel_entry.o kernel.o
	$(LD) -o $@ -Ttext 0x1000 $^ --oformat binary

kernel_entry.o: asm/kernel_entry.asm
	nasm $< -f elf -o $@

kernel.o: c/kernel.c
	$(CC) -ffreestanding -c $< -o $@

# Rule to disassemble the kernel - may be useful to debug
kernel.dis: kernel.bin
	ndisasm -b 32 $< > $@

boot_sect.bin: asm/boot_sect.asm
	nasm $< -f bin -o $@

os-image.bin: boot_sect.bin kernel.bin
	cat $^ > $@

run: os-image.bin
	qemu-system-i386 -fda $<

clean:
	rm *.bin *.o