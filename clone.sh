#!/bin/sh

set -x

CLONE="git clone https://github.com/gaidardzhiev"

if ls -l $1; then
	exit 1
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
fi
