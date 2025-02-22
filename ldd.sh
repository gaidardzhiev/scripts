#!/bin/sh

fusage() {
	printf "usage: $0 <binary_file>\n"
	exit 1
}

fcheck() {
	if [ ! -f "$1" ]; then
		printf "error: file '$1' does not exist or is not a regular file...\n"
		exit 2
	fi
}

fldd() {
	objdump -p "$1" | grep NEEDED
	exit 0
}

if [ "$#" -ne 1 ]; then
	fusage
fi

fcheck "$1" && fldd "$1"
