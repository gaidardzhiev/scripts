#!/bin/sh
#the script builds statically linked midnight commander

set -e
set -x

export MC_VER=4.7.5.6
export NUMCPUS=$(grep -c '^processor' /proc/cpuinfo)
export JOBS="-j $NUMCPUS"
export DIR=/opt/mc

error_exit() {
	echo "Error: $1"
	exit 1
}

get_build_mc() {
	mkdir -p "$DIR" || error_exit "failed to create directory $DIR"
	cd "$DIR" || error_exit "failed to change directory to $DIR"
	wget "http://ftp.midnight-commander.org/mc-$MC_VER.tar.xz" || error_exit "failed to download"
	tar xf "mc-$MC_VER.tar.xz" || error_exit "failed to extract"
	cd "mc-$MC_VER" || error_exit "failed to change directory to mc-$MC_VER"
	./configure --without-x --disable-shared --enable-static || error_exit "configuration failed"
	CC='gcc -static -static-libgcc -fno-exceptions' \
	CXX='g++ -static -static-libgcc -fno-exceptions' \
	LDFLAGS='-Wl,-static -static -lc' \
	LIBS='-lc' \
	make $JOBS || error_exit "build failed"
	cp "$DIR/mc-$MC_VER/src/mc" /usr/bin/mc || error_exit "failed to copy mc to /usr/bin"
	echo "build completed successfully"
	rm -r "$DIR" || error_exit "failed to remove directory $DIR"
}

get_build_mc

