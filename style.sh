#!/bin/sh

fdepcheck() {
	command -v "$1" >/dev/null 2>&1 || {
		echo >&2 "error: $1 is not installed..."
		exit 1
	}
}

fastyle() {
	astyle --style=linux -T8 *.c && \
		echo "formatting completed successfully" || \
		echo "astyle encountered an issue while formatting" && \
		exit 1
}

fdepcheck astyle && fastyle
