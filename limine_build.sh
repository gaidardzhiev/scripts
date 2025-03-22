#! /bin/sh

export DIR=limine_build

mkdir $DIR
cd $DIR
touch kernel.c
touch link.ld
touch limine.cfg

cat > kernel.c << eof
#include <stdint.h>
#include <stddef.h>
#include <limine.h>

static volatile struct limine_terminal_request terminal_request = {
    .id = LIMINE_TERMINAL_REQUEST,
    .revision = 0
};

static void done(void) {
    for (;;) {
        __asm__("hlt");
    }
}

//kernel entry point

void _start(void) {
    if (terminal_request.response == NULL
     || terminal_request.response->terminal_count < 1) {
        done();
    }
        struct limine_terminal *terminal = terminal_request.response->terminals[0];
    terminal_request.response->write(terminal, "booting....", 11);
    done();
}
eof

cat > link.ld << eof
OUTPUT_FORMAT(elf64-x86-64)
OUTPUT_ARCH(i386:x86-64)

ENTRY(_start)

PHDRS
{
    text    PT_LOAD    FLAGS((1 << 0) | (1 << 2)) ; /* rx */
    rodata  PT_LOAD    FLAGS((1 << 2)) ;            /* r */
    data    PT_LOAD    FLAGS((1 << 1) | (1 << 2)) ; /* rw */
}

SECTIONS
{
	. = 0xffffffff80000000;

    .text : {
        *(.text .text.*)
    } :text
     . += CONSTANT(MAXPAGESIZE);

     .rodata : {
        *(.rodata .rodata.*)
    } :rodata

     . += CONSTANT(MAXPAGESIZE);

     .data : {
        *(.data .data.*)
    } :data

    .bss : {
        *(COMMON)
        *(.bss .bss.*)
    } :data

        /DISCARD/ : {
        *(.eh_frame)
        *(.note .note.*)
    }
}
eof

cat > limine.cfg << eof
TIMEOUT=5

:limine_os
    PROTOCOL=limine
 
    KERNEL_PATH=boot:///limine_os.elf
eof

git clone https://github.com/limine-bootloader/limine.git --branch=v4.x-branch-binary --depth=1
cd limine
make -C limine
make install
cd ../

if cc  -g \
	-O2 \
	-pipe \
	-Wall \
	-Wextra \
	-std=c11 \
	-ffreestanding \
	-fno-stack-protector \
	-fno-stack-check \
	-fno-lto \
	-fno-pie \
	-fno-pic \
	-m64 \
	-march=x86-64 \
	-mabi=sysv \
	-mno-80387 \
	-mno-mmx \
	-mno-sse \
	-mno-sse2 \
	-mno-red-zone \
	-mcmodel=kernel \
	-MMD -I. -c kernel.c -o kernel.o; then
	printf "the kernel IS compiled\n"
else
	printf "the kernel is NOT compiled\n"
fi

if ld ./kernel.o \
		-nostdlib \
		-static \
		-m elf_x86_64 \
		-z max-page-size=0x1000 \
		-T link.ld \
		-no-pie \
		-o limine_os.elf; then
	printf "the linking is done\n"
else
	printf "the linking is not done\n"
fi

mkdir -p iso_root
cp -v limine_os.elf limine.cfg limine/limine.sys \
	limine/limine-cd.bin limine/limine-cd-efi.bin iso_root/

xorriso -as mkisofs -b limine-cd.bin \
	-no-emul-boot -boot-load-size 4 -boot-info-table \
	--efi-boot limine-cd-efi.bin -efi-boot-part --efi-boot-image \
	--protective-msdos-label iso_root -o image.iso

./limine/limine-deploy image.iso

qemu-system-x86_64 -cdrom image.iso
