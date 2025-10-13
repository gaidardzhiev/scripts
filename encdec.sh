#!/bin/sh

export ARG="${1}"
export TEXT="${2}"
export FILE="${2}"
export PASS="${3}"

fusage() {
	printf "usage: %s <encrypt|decrypt> <text|file> <password>\n" "${0}"
	printf "  encrypt: encrypts the provided <text> using the provided <password>\n"
	printf "  decrypt: decrypts the provided <file> using the provided <password>\n"
	exit 1
}

[ "${#}" -ne 3 ] && fusage

fenc() {
	echo "${TEXT}" | openssl enc -e -aes-256-cbc -pbkdf2 -a -pass pass:"${PASS}"
}

fdec() {
	cat "${FILE}" | openssl enc -d -aes-256-cbc -pbkdf2 -a -pass pass:"${PASS}"
}

case "${ARG}" in
	encrypt)
		fenc
		;;
	decrypt)
		fdec
		;;
	*)
		printf "error: invalid argument %s\n" "${ARG}"
		fusage
		;;
esac
