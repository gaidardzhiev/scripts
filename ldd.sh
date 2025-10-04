#!/bin/sh

fusage() {
	printf "usage: %s <binary_file>\n" "${1}";
	exit 1;
}

fldd() {
	i=$(objdump -p "${1}" | grep NEEDED)
	[ -z "${i}" ] && \
		printf "%s is not a dynamic executable...\n" "${1}" || \
		printf "%s\n" "${i}" 
}

[ "${#}" -ne 1 ] && fusage

{ fldd "${1}" && exit 0; }
