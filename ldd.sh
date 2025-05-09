#!/bin/sh

fusage() {
	printf "usage: $0 <binary_file>\n";
	exit 1;
}

fldd() {
	i=$(objdump -p "$1" | grep NEEDED)
	[ -z "$i" ] && \
		printf "not a dynamic executable\n" || \
		printf "%s\n" "$i" 
}

[ "$#" -ne 1 ] && fusage

{ fldd "$1" && exit 0; }
