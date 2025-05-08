#!/bin/sh

fdepcheck() {
	command -v "$1" >/dev/null 2>&1 || {
		printf >&2 "error: $1 is not installed...\n";
		return 2;
	}
}

fastyle() {
	astyle --style=linux -T8 *.c && {
		printf "formatting completed successfully\n";
		return 0;
	} || {
		printf "astyle encountered an issue while formatting...\n";	
		return 3;
	}
}

{ fdepcheck astyle && fastyle; RET="$?" } || exit 1
