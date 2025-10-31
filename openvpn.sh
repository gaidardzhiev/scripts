#!/bin/sh
#openssl enc -aes-256-cbc -in <in> -out /root/.openvpncred -pass pass:<?> -pbkdf2

CRED="/root/.openvpncred"
DIR="/home/openvpn"
LIST=("${DIR}"/*)
NUM=${#LIST[@]}
PRAND=$(od -An -N2 -i /dev/urandom | awk -v max="$NUM" '{print $1 % max}')

printf "do you want to manualy choose the openvpn configuration file:\n"

printf "(yes/no)\n"

read -r RSP

case "${RSP}" in
	[y]* )
		FILE=$(find "${DIR}" -type f | fzf)
		printf "%s configuration file choosed manualy...\n" "${FILE}"
		;;
	[n]* )
		FILE="${LIST[$PRAND]}"
		printf "%s configuration file choosed pseudo randomly...\n" "${FILE}"
		;;
	*)
		printf "invalid response...\n"
		printf "please choose (yes/no)\n"
		;;
esac

printf "enter the password to access the credentials:\n"

read -s DEC

[ -f "${CRED}" ] && {
	USER=$(openssl enc -d -aes-256-cbc -in "${CRED}" -pass pass:"${DEC}" -pbkdf2 | head -n 1) || exit -1
	PASS=$(openssl enc -d -aes-256-cbc -in "${CRED}" -pass pass:"${DEC}" -pbkdf2 | tail -n 1) || exit -2
} || {
	printf "credentials file not found...\n";
	printf "create them with: \n";
	sed -n '2s/^.\(.*\)/\1/p' "${0}";
	exit 1;
}

printf "starting openvpn with configuration: %s\n" "${FILE}"

PROTO=$(grep -E '^[ \t]*proto[ \t]+' "${FILE}" | awk '{print $2}' | head -n1)

[ -z "${PROTO}" ] && PROTO="udp"

PROTO4="${PROTO}4"

openvpn --config "${FILE}" --auth-user-pass <(echo -e "${USER}\n${PASS}") --proto "${PROTO4}"
