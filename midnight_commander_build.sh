#!/bin/sh
#the script builds statically linked midnight commander

export MC_VER=4.7.5.6
export NUMCPUS=$(grep -c '^processor' /proc/cpuinfo)
export JOBS="-j $NUMCPUS"
export DIR=/opt/mc

fexit() {
	printf "error: $1\n"
	exit 1
}

get_build_mc() {
	mkdir -p "$DIR" || fexit "failed to create directory $DIR"
	cd "$DIR" || fexit "failed to change directory to $DIR"
	wget "http://ftp.midnight-commander.org/mc-$MC_VER.tar.xz" || fexit "failed to download"
	tar xf "mc-$MC_VER.tar.xz" || fexit "failed to extract"
	cd "mc-$MC_VER" || fexit "failed to change directory to mc-$MC_VER"
	./configure --without-x --disable-shared --enable-static || fexit "configuration failed"
	CC='gcc -static -static-libgcc -fno-exceptions' \
	CXX='g++ -static -static-libgcc -fno-exceptions' \
	LDFLAGS='-Wl,-static -static -lc' \
	LIBS='-lc' \
	make $JOBS || fexit "build failed"
	cp "$DIR/mc-$MC_VER/src/mc" /usr/bin/mc || fexit "failed to copy mc to /usr/bin"
	printf "build completed successfully\n"
	rm -r "$DIR" || fexit "failed to remove directory $DIR"
}

get_build_mc
