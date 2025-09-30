#!/bin/sh

export IP="${1}"
export FILE="scan.gnmap"
export USR="/usr/share/brutespray/wordlist/user.txt"
export PASS="/usr/share/brutespray/wordlist/pass.txt"


[ -z "${IP}" ] && {
	printf "usage: "${0}" <target>\n";
	exit 1;
}

fscan() {
	nmap -sS -sV "${IP}" -vv -n -oA "${FILE}"
	return 0
}

fspray() {
	brutespray \
		--file "${FILE}" \
		-U "${USR}" \
		-P "${PASS}" \
		--threads 5 \
		--hosts 5
	return 0
}

{ fscan && fspray && exit 0; } || { printf "something's wrong in here somewhere...\n" && exit 1; }
