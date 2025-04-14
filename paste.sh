#!/bin/sh

fusage() {
	printf "usage:\n"
	printf "        $0 <up>    <file>\n"
	printf "        $0 <down>  <name>\n"
	return 32
}

fup() {
	local URL='https://paste.c-net.org/'
	local FILE="$2"
	if [ -r "$FILE" ]; then
		curl -s \
			--data-binary @"$FILE" \
			--header "X-FileName: ${FILE##*/}" \
			"$URL"
	else
		printf "'$FILE' is not readable or does not exist...\n"
	fi
}

fdown() {
	local URL='https://paste.c-net.org/'
	local NAME="$2"
	curl -s "${URL}${NAME##*/}"
}

case "$1" in
	up)
		fup "$@"
		;;
	down)
		fdown "$@"
		;;
	*)
		fusage
		exit 1
		;;
esac
