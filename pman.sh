#!/bin/sh

DB=/root/.pdb
KEY="${3}"

fgen() {
	tr -dc '[:graph:]' < /dev/urandom | head -c 16
}

fenc() {
	echo "${1}" | openssl enc -aes-256-cbc \
		-a -salt -pass pass:"${KEY}" \
		-pbkdf2 -iter 100000
}

fdec() {
	echo "${1}" | openssl enc -aes-256-cbc \
		-d -a -pass pass:"${KEY}" \
		-pbkdf2 -iter 100000
}

fadd() {
	grep -q "^${1}:" "${DB}" && {
		printf "entry for %s already exists...\n" "${1}" >&2
		exit 1
	}
	DPASS=$(fgen)
	EPASS=$(fenc "${DPASS}")
	echo "${1}:${EPASS}" >> "${DB}"
	echo "password for ${1} added"
}

fget() {
	case $(grep -q "^${1}:" "${DB}"; echo ${?}) in
		0)
			EPASS=$(grep "^${1}:" "${DB}" | cut -d':' -f2)
			DPASS=$(fdec "${EPASS}")
			echo "password for ${1}: ${DPASS}"
			;;
		1)
			echo "no entry found for ${1}..."
			;;
	esac
}

case "${1}" in
	add)
		fadd "${2}"
		;;
	get)
		fget "${2}" #"${3}"
		;;
	*)
		printf "usage: %s <add|get> <name> <key>\n" "${0}"
		;;
esac
