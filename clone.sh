#!/bin/sh

CLONE="git clone https://github.com/gaidardzhiev"

[ -d $1 ] && {
	printf "$1 exists...\n"
	exit 1
} || {
	mkdir -p $1 && cd $1 || exit 8
	for REPO in \
		shellcode \
		scripts \
		x86_kernel \
		networking \
		rw_file \
		boot_sect \
		on_the_metal \
		interceptor \
		libreverse \
		esolangs \
		toolbox \
		syscall \
		crt0trust \
		terminax \
		brainfunk \
		sbpm \
		latex \
		ocr \
		oldbox \
		isol8r \
		tmdv;
	do
		$CLONE/$REPO || {
			printf "failed to clone $REPO...\n"
			exit 16
		}
	done
}
