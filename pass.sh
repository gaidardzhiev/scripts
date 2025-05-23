#!/bin/sh

x() {
	X=$(tr -dc '[:graph:]' < /dev/urandom | head -c 32)
	printf "%s\n" "$X" && return 0 || return 2
}

y() {
	Y=$(head -c 32 /dev/urandom | md5sum | awk '{print $1}')
	printf "%s\n" "$Y" && return 0 || return 3
}

z() {
	Z=$(openssl rand -base64 64 | head -c 32)
	printf "%s\n" "$Z" && return 0 || return 4
}

{ x || y || z; R=$?; } && exit 0 || exit 1

[ "$R" -eq 0 ] 2>/dev/null || printf "%s\n" "$R"
