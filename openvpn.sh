#!/bin/sh

DIR="/home/openvpn/"
CRED="/root/.openvpncred"
FILE=$(find "$DIR" -type f | shuf -n 1)

printf "enter the password to access credentials:\n"
read -s DEC

[ -f "$CRED" ] && {
	USERNAME=$(openssl enc -d -aes-256-cbc -in "$CRED" -pass pass:"$DEC" -pbkdf2 | head -n 1) || exit -1
	PASSWORD=$(openssl enc -d -aes-256-cbc -in "$CRED" -pass pass:"$DEC" -pbkdf2 | tail -n 1) || exit -2
} || {
	printf "credentials file not found...\n" && exit 1
}

#if [ -f "$CRED" ]; then
#	USERNAME=$(openssl enc -d -aes-256-cbc -in "$CRED" -pass pass:"$DEC" -pbkdf2 | head -n 1)
#	PASSWORD=$(openssl enc -d -aes-256-cbc -in "$CRED" -pass pass:"$DEC" -pbkdf2 | tail -n 1)
#else
#	printf "credentials file not found...\n"
#	exit 1
#fi

printf "starting openvpn with configuration: $FILE\n"
echo "$PASSWORD" | openvpn --config "$FILE" --auth-user-pass <(echo -e "$USERNAME\n$PASSWORD")
