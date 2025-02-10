#!/bin/sh

export ARG=$1
export TEXT=$2
export PASS=$3

fusage() {
	printf "usage: $0 <encrypt|decrypt> <text> <password>\n"
	printf "  encrypt: encrypts the provided <text> using the provided <password>\n"
	printf "  decrypt: decrypts the provided <text> using the provided <password>\n"
	exit 1
}

if [ "$#" -ne 3 ]; then
	fusage
fi

e() {
	echo "$TEXT" | openssl enc -e -aes-256-cbc -pbkdf2 -a -pass pass:"$PASS"
}

d() {
	echo "$TEXT" | openssl enc -d -aes-256-cbc -pbkdf2 -a -pass pass:"$PASS"
}

case "$ARG" in
	encrypt)
		e
		;;
	decrypt)
		d
		;;
	*)
		printf "error: invalid argument '$ARG'\n"
		fusage
		;;
esac
