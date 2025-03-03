#!/bin/sh
#openssl enc -aes-256-cbc -in <in> -out <out> -pass pass:<?> -pbkdf2

CRED="/root/.openvpncred"
DIR="/home/openvpn"
LIST=("$DIR"/*)
NUM=${#LIST[@]}
PRAND=$(od -An -N2 -i /dev/urandom | awk -v max="$NUM" '{print $1 % max}')

printf "do you want to manualy choose the openvpn configuration file:\n"
printf "(yes/no)\n"
read -r RSP
case $RSP in
	[y]* )
		FILE=$(find "$DIR" -type f | fzf)
		printf "$FILE configuration file choosed manualy...\n"
		;;
	[n]* )
		FILE="${LIST[$PRAND]}"
		printf "$FILE configuration file choosed pseudo randomly...\n"
		;;
	*)
		printf "invalid response...\n"
		printf "please choose (yes/no)\n"
		;;
esac

printf "enter the password to access the credentials:\n"
read -s DEC
[ -f "$CRED" ] && {
	USERNAME=$(openssl enc -d -aes-256-cbc -in "$CRED" -pass pass:"$DEC" -pbkdf2 | head -n 1) || exit -1
	PASSWORD=$(openssl enc -d -aes-256-cbc -in "$CRED" -pass pass:"$DEC" -pbkdf2 | tail -n 1) || exit -2
} || {
	printf "credentials file not found...\n" && exit 1
}

printf "starting openvpn with configuration: $FILE\n"
openvpn --config "$FILE" --auth-user-pass <(echo -e "$USERNAME\n$PASSWORD")
