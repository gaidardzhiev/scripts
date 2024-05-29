#!/bin/sh

set -xe

if ls -l $1; then
	printf "1\n"
else
	mkdir -p $1
	cd $1
	git clone https://github.com/gaidardzhiev/shellcode
	git clone https://github.com/gaidardzhiev/scripts
	git clone https://github.com/gaidardzhiev/x86_kernel
	git clone https://github.com/gaidardzhiev/networking
	git clone https://github.com/gaidardzhiev/rw_file
	git clone https://github.com/gaidardzhiev/boot_sect
	git clone https://github.com/gaidardzhiev/on_the_metal
	git clone https://github.com/gaidardzhiev/interceptor
	git clone https://github.com/gaidardzhiev/libreverse
	printf "0\n"
fi
