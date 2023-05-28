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
	echo "unknown platform" >&2
	exit 1
esac
echo $OS
exit 0
