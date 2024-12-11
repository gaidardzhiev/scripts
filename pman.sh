#!/bin/sh

DB=/root/.pdb
KEY=$3

generate() {
	tr -dc '[:graph:]' < /dev/urandom | head -c 16
}

encrypt() {
	echo "$1" | openssl enc -aes-256-cbc\
		-a -salt -pass pass:"$KEY"\
		-pbkdf2 -iter 100000
}

decrypt() {
	echo "$1" | openssl enc -aes-256-cbc\
		-d -a -pass pass:"$KEY"\
		-pbkdf2 -iter 100000
}

add() {
	DPASSWORD=$(generate)
	EPASSWORD=$(encrypt "$DPASSWORD")
	echo "$1:$EPASSWORD" >> "$DB"
	echo "password for $1 added"
}

get() {
	if grep -q "^$1:" "$DB"; then
		EPASSWORD=$(grep "^$1:" "$DB" | cut -d':' -f2)
		DPASSWORD=$(decrypt "$EPASSWORD")
		echo "password for $1: $DPASSWORD"
	else
		echo "no entry found for $1..."
	fi
}

case "$1" in
	add)
		add "$2"
		;;
	get)
		get "$2"
		;;
	*)
		echo "usage: $0 <add|get> <name> <key>"
		;;
esac
