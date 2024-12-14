#!/bin/sh

case "$(uname)" in
	Linux) p=__NR_ ;;
	*) p=SYS_ ;;
esac

if ! command -v cpp > /dev/null; then
	echo "preprocessor not found..." >&2
	exit 1
fi

if ! cpp -include sys/syscall.h -dM </dev/null | sed -n "s/^#define $p//p" | sort -k1; then
	echo "error..." >&2
	exit 1
fi
