#!/bin/sh

fusage() {
	printf "usage: $0 <binary_file>\n";
	exit 1;
}

fldd() {
	objdump -p "$1" | grep NEEDED
}

[ "$#" -ne 1 ] && fusage

{ fldd "$1" && exit 0; }
