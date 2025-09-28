#!/bin/sh
#the script determines the type of operating system that is running on and echo the appropriate value
#it is intended to be used in Makefile's

case `uname -s` in
"Linux")
	OS="linux"
	;;
"FreeBSD")
	OS="freebsd"
	;;
"OpenBSD")
	OS="openbsd"
	;;
"Darwin")
	OS="macos"
	;;
*)
	printf "unknown platform\n" >&2
	exit 1
esac

{ printf "%s\n" "$OS" && exit 0; }
