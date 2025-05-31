#!/bin/bash

DATE=$(date +"%Y%m%d_%H")
DIR="$1"
OUT="/home/src_$DATE.tar.gz"

[ "$#" -lt 1 ] && {
	printf "usage: $0 <dir>\n";
	exit 1;                                                        }

tar -czvf "$OUT" "$DIR" && exit 0
