#!/bin/sh
#the script automates the proccess of uploading and downloading of files and text to paste.c-net.org

fusage() {
	sed -n '2s/^.\(.*\)/\1/p' "$0";
	printf "usage:\n"
	printf "        $0 <up>    <file>\n"
	printf "        $0 <down>  <name>\n"
	return 32
}

fup() {
	local URL='https://paste.c-net.org/'
	local FILE="$2"
	[ -r "$FILE" ] && {
		curl -s \
			--data-binary @"$FILE" \
			--header "X-FileName: ${FILE##*/}" \
			"$URL";
		return 0;
	} || {
		printf "'$FILE' is not readable or does not exist...\n";
		return 16;
	}
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
