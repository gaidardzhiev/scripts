#!/bin/sh

fusage() {
	printf "usage:\n"
	printf "        $0 <up>    <file>\n"
	printf "        $0 <down>  <name>\n"
	return 32
}

fup() {
	local url='https://paste.c-net.org/'
	local file="$2"
	if [ -r "$file" ]; then
		curl -s \
			--data-binary @"$file" \
			--header "X-FileName: ${file##*/}" \
			"$url"
	else
		printf "'$file' is not readable or does not exist...\n"
	fi
}

fdown() {
	local url='https://paste.c-net.org/'
	local arg="$2"
	curl -s "${url}${arg##*/}"
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
