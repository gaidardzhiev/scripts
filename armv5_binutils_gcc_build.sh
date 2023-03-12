#!/bin/sh
#the script builds binutils and gcc for arm_v5

#set vars
export TARGET=arm-none-eabi
export PREFIX=/opt/gnuarm5
export PATH=$PATH:$PREFIX/bin
export NUMCPUS=`grep -c '^processor' /proc/cpuinfo`
export J='-j '$NUMCPUS''
export GCCVER=12.2.0
export BINUTILSVER=2.40

#create and go to work directory
mkdir /home/src/compilers/arm_v5
cd /home/src/compilers/arm_v5

#get archives
wget https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILSVER.tar.gz
wget https://ftp.gnu.org/gnu/gcc/gcc-$GCCVER/gcc-$GCCVER.tar.gz

#extract archives
tar xf binutils-$BINUTILSVER.tar.gz
tar xf gcc-$GCCVER.tar.gz

#patch
ln -s binutils-$BINUTILSVER binutils-patch
patch -p0 < arm-patch

#build binutils
mkdir build_binutils
cd build_binutils
../binutils-$BINUTILSVER/configure --targer=$TARGET --prefix=$PREFIX
echo "MAKEINFO = :" >> Makefile
make $J all
make install

#build gcc
mkdir ../build_gcc
cd ../build_gcc
../gcc-$GCCVER/configure --target=$TARGET --prefix=$PREFIX --without-headers --with-newlib  --with-gnu-as --with-gnu-ld --enable-languages='c' --enable-frame-pointer=no
make $J all-gcc
make install-gcc

#build libgcc.a
make $J all-target-libgcc CFLAGS_FOR_TARGET="-g -02"
make install-target-libgcc
