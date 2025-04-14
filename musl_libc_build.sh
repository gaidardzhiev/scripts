#!/bin/sh

export PREFIX=/opt/musl
export EXEC=$PREFIX/bin
export LIB=$PREFIX/lib
export GETNUMCPUS=`grep -c '^processor' /proc/cpuinfo`
export JOBS='-j '$GETNUMCPUS''
export MUSL=musl-1.2.5
export DIR=/home/src/

[ -d "$PREFIX" ] && { printf "$PREFIX exists...\n"; exit 0; }

fget() {
	if cd $DIR; then
		wget https://musl.libc.org/releases/$MUSL.tar.gz
		tar xf $MUSL.tar.gz
		rm $MUSL.tar.gz
		cd $MUSL
		return 0
	else
		return 1
	fi
}

fbuild() {
	if ./configure \
		--prefix=$PREFIX \
		--exec-prefix=$EXEC \
		--syslibdir=$LIB \
		--disable-shared; then
		make
		make install
		cp $EXEC/bin/musl-gcc /usr/bin/
		return 0
	else
		return 1
	fi
}

ftry() {
	if cd $TMP; then
		cat > hello.c << EOF
#include <stdio.h>
int main(int argc, char **argv)
{ printf("hello %d\n", argc); }
EOF
		musl-gcc -static -Os hello.c
		./a.out
		file a.out
		size a.out
		ldd a.out
		rm hello.c a.out
		return 0
	else
		return 1
	fi
}

fget && fbuild && ftry || { printf "something's wrong in here somewhere...\n"; exit 1}
