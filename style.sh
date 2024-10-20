#!/bin/sh

fdepcheck() {
	command -v "$1" >/dev/null 2>&1 || {
		echo >&2 "error: $1 is not installed..."
		exit 1
	}
}

fdepcheck astyle

if astyle --style=linux -T8 *.c; then
	echo "formatting completed successfully"
else
	echo "astyle encountered an issue while formatting"
	exit 1
fi
