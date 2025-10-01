#!/bin/sh

[ "${#}" -ne 2 ] && {
	printf "usage: %s <file1> <file2>\n" "${1}";
	exit 1;
}

[ ! -f "${1}" ] && {
	printf "error: file %s does not exist...\n" "${1}";
	exit 2;
}

[ ! -f "${2}" ] && {
	printf "error: file %s does not exist....\n" "$2";
	exit 3;
}

diff <(hexdump -C "$1") <(hexdump -C "$2") | awk -v file1="$1" -v file2="$2" '
/^</ {print "\033[31m" file1 ": " $0 "\033[0m"} 
/^>/ {print "\033[32m" file2 ": " $0 "\033[0m"}'
