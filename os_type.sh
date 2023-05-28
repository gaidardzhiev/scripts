#!/bin/sh
#the script determines the type of operating system that is running on and echo the appropriate value
#it is intended to be used in Makefile's

case `uname -s` in
"Linux")
	PLATFORM="linux"
	;;
"FreeBSD")
	PLATFORM="freebsd"
	;;
"OpenBSD")
	PLATFORM="openbsd"
	;;
"Darwin")
	PLATFORM="macos"
	;;
*)
	echo "unknown platform" >&2
	exit 1
esac
echo $PLATFORM
exit 0
