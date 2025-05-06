#!/bin/sh
#the script compiles binutils and gcc for armv7l in termux proot

export DIR=/home/src/binutils_gcc_av7l
export PREFIX=/opt/binutils_gcc_armv7l
export TARGET=armv7l-unknown-none
export PATH=$PATH:$PREFIX/bin
export GETNUMCPUS=`grep -c '^processor' /proc/cpuinfo`
export JOBS='-j '$GETNUMCPUS''
export BINUTILS=2.42
export GCC=13.2.0


binutils() {
        mkdir -p $DIR
        mkdir -p $PREFIX
        cd $DIR
        wget https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS.tar.bz2
        tar -xf binutils-$BINUTILS.tar.bz2
        cd binutils-$BINUTILS
        rm ../binutils-$BINUTILS.tar.bz2
        ./configure \
                --target=$TARGET \
                --prefix=$PREFIX
        make $JOBS all
        make install && return 0 || return 2
}

gcc() {
        cd $DIR
        wget https://ftp.gnu.org/gnu/gcc/gcc-$GCC/gcc-$GCC.tar.gz
        tar -xf gcc-$GCC.tar.gz
        cd gcc-$GCC
        rm ../gcc-$GCC.tar.gz
        ./contrib/download_prerequisites
        ./configure \
                --target=$TARGET \
                --prefix=$PREFIX \
                --without-headers \
                --with-newlib  \
                --with-gnu-as \
                --with-gnu-ld \
                --enable-languages='c' \
                --enable-frame-pointer=no
                --disable-shared \
                --disable-host-shared \
                --with-boot-ldflags=-static \
                --with-stage1-ldflags=-static
        make $JOBS all-gcc
        make install-gcc
        make $JOBS all-target-libgcc CFLAGS_FOR_TARGET="-g -02"
        make install-target-libgcc && return 0 || return 3
}

{ binutils && gcc } || { printf "something is wrong in here somewhere...\n" && exit 1 }
