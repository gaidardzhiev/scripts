#!/bin/sh
#the script builds binutils and gcc cross compiler for arm_v5 target

export TARGET="arm-none-eabi"
export PREFIX="/opt/arm_gcc_binutils"
export PATH="$PATH:$PREFIX/bin"
export GETNUMCPUS=`grep -c '^processor' /proc/cpuinfo`
export JOBS='-j '$GETNUMCPUS''
export GCC="12.2.0"
export BINUTILS="2.40"
export DIR="/home/src/compilers/arm_gcc_binutils"

fprep() {
	mkdir -p "$DIR"
	cd "$DIR"
	wget https://ftp.gnu.org/gnu/binutils/binutils-"$BINUTILS".tar.gz
	wget https://ftp.gnu.org/gnu/gcc/gcc-"$GCC"/gcc-"$GCC".tar.gz
	tar xf binutils-$BINUTILS.tar.gz
	tar xf gcc-$GCC.tar.gz
	ln -s binutils-$BINUTILS binutils-patch
	patch -p0 < arm-patch && return 0 || return 2
}

fbinutils() {
        mkdir build_binutils
        cd build_binutils
        ../binutils-$BINUTILS/configure \
                --targer=$TARGET \
                --prefix=$PREFIX
        echo "MAKEINFO = :" >> Makefile
        make $JOBS all
        make install && return 0 || return 3
}

fgcc() {
        mkdir ../build_gcc
        cd ../build_gcc
        ../gcc-$GCC/configure \
                --target=$TARGET \
                --prefix=$PREFIX \
                --without-headers \
                --with-newlib  \
                --with-gnu-as \
                --with-gnu-ld \
                --enable-languages='c' \
                --enable-frame-pointer=no
        make $JOBS all-gcc
        make install-gcc
        make $JOBS all-target-libgcc CFLAGS_FOR_TARGET="-g -02"
        make install-target-libgcc && return 0 || return 3
}

{ fprep && fbinutils && fgcc && exit 0 } || exit 1
