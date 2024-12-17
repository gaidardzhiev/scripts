#!/bin/sh
#pseudo random string generator using RDRAND instruction that generates entropy directly from hardware using thermal noise and other physical phenomena to produce high-quality randomness...

OUT="prand"
EXEC="./$OUT"
CLEAN="rm -f $OUT"

if ! grep -q "rdrand" /proc/cpuinfo; then
	echo "rdrand instruction not supported..."
	exit 1
fi

gcc -x c -o "$OUT" - <<eof
#include <stdio.h>
int main() {
    printf("put the code here...\n");
    return 0;
}
eof

if eval $EXEC; then
	eval $CLEAN
	exit 0
fi
