#!/bin/sh

set -xe

CLONE="git clone https://github.com/gaidardzhiev"

if ls -l $1; then
	printf "\n"
else
	mkdir -p $1
	cd $1
	$CLONE/shellcode
	$CLONE/scripts
	$CLONE/x86_kernel
	$CLONE/networking
	$CLONE/rw_file
	$CLONE/boot_sect
	$CLONE/on_the_metal
	$CLONE/interceptor
	$CLONE/libreverse
	$CLONE/esolangs
	$CLONE/toolbox
	printf "\n"
fi
