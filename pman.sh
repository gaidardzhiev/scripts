#!/bin/sh

DB=/root/.pdb
KEY=$3

fgen() {
	tr -dc '[:graph:]' < /dev/urandom | head -c 16
}

fenc() {
	echo "$1" | openssl enc -aes-256-cbc \
		-a -salt -pass pass:"$KEY" \
		-pbkdf2 -iter 100000
}

fdec() {
	echo "$1" | openssl enc -aes-256-cbc \
		-d -a -pass pass:"$KEY" \
		-pbkdf2 -iter 100000
}

fadd() {
	DPASS=$(fgen)
	EPASS=$(fenc "$DPASS")
	echo "$1:$EPASS" >> "$DB"
	echo "password for $1 added"
}

#fget() {
#	if grep -q "^$1:" "$DB"; then
#		EPASS=$(grep "^$1:" "$DB" | cut -d':' -f2)
#		DPASS=$(fdec "$EPASS")
#		echo "password for $1: $DPASS"
#	else

fget() {
	case $(grep -q "^$1:" "$DB"; echo $?) in #capture exit status
		0)
			EPASS=$(grep "^$1:" "$DB" | cut -d':' -f2)
			DPASS=$(fdec "$EPASS")
			echo "password for $1: $DPASS"
			;;
		1)
			echo "no entry found for $1..."
			;;
	esac
}

case "$1" in
	add)
		fadd "$2"
		;;
	get)
		fget "$2"
		;;
	*)
		printf "usage: $0 <add|get> <name> <key>\n"
		;;
esac
