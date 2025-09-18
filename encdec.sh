#!/bin/sh

export ARG="$1"
export TEXT="$2"
export PASS="$3"

fusage() {
	printf "usage: %s <encrypt|decrypt> <text> <password>\n" "$0"
	printf "  encrypt: encrypts the provided <text> using the provided <password>\n"
	printf "  decrypt: decrypts the provided <text> using the provided <password>\n"
	exit 1
}

[ "$#" -ne 3 ] && fusage

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
		printf "error: invalid argument %s\n" "$ARG"
		fusage
		;;
esac
