#!/bin/sh

x() {
	X=$(tr -dc '[:graph:]' < /dev/urandom | head -c 32)
	echo $X
}

y() {
	Y=$(head -c 32 /dev/urandom | md5sum)
	echo $Y
}

z() {
	Z=$(openssl rand -base64 64 | head -c 32)
	echo $Z
}

x || y || z
