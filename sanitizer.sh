#!/bin/sh

IN="$1"                                  OUT="$2"

if [ "$#" -ne 2 ]; then
	echo "usage: $0 <in.c> <out.c>"
	exit 1
fi

awk 'NF {sub(/^[ \t]+/, ""); print}' "$IN" | awk 'NF' > "$OUT"
