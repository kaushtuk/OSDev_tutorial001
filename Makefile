source_path = ./src
build_path = ./build
isodir = ./isodir

all: clean iso
iso: iso_dir
	grub-mkrescue -o $(build_path)/MyOS.iso $(isodir)
	rm -rf $(isodir)
iso_dir: test_multiboot
	rm -rf $(isodir)
	mkdir -p $(isodir)/boot/grub
	cp $(build_path)/MyOS.bin $(isodir)/boot/MyOS.bin
	cp $(source_path)/grub.cfg $(isodir)/boot/grub/grub.cfg
	tree $(isodir)
test_multiboot: $(build_path)/MyOS.bin
	grub-file --is-x86-multiboot $(build_path)/MyOS.bin
	echo notBootable=$?
$(build_path)/MyOS.bin: $(source_path)/linker.ld $(build_path)/boot.o $(build_path)/kernel.o
	i686-elf-gcc -T $(source_path)/linker.ld -o $(build_path)/MyOS.bin \
		-ffreestanding -O2 -nostdlib $(build_path)/boot.o $(build_path)/kernel.o -lgcc
$(build_path)/boot.o: $(source_path)/boot.s
	i686-elf-as $(source_path)/boot.s -o $(build_path)/boot.o
$(build_path)/kernel.o: $(source_path)/kernel.c
	i686-elf-gcc -c $(source_path)/kernel.c -o $(build_path)/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

clean: 
	rm -rf $(build_path) $(isodir)
	mkdir $(build_path)
.PHONY: clean
