#!/bin/sh
#very crude source based package manager

DIR=/opt/spm
BIN=$DIR/bin
TARGET=$(uname -m)
PKG=$1
GETNUMCPUS=`grep -c '^processor' /proc/cpuinfo`
JOBS='-j '$GETNUMCPUS''
GCC=12.2.0
BINUTILS=2.40
MAKE=4.4

fusage() {
	printf "usage: $0 <tcc|gcc|make|musl|glibc|git|zsh|bash|dash|ash|kernel|awk|grep|sed|toolbox|busybox|toybox|curl|wget|tmux|qemu|i3wm|dmenu|grub2|coreboot|flashrom>\n"
	exit 1
}

if [ ! -d $DIR ]; then
	mkdir -p $DIR
fi

if [ ! -d $BIN ]; then
	mkdir -p $BIN
fi

if [ $# -lt 1 ]; then
	fusage
fi

shift

case $PKG in
	make)
		cd $DIR
		wget https://ftp.gnu.org/gnu/make/make-$MAKE.tar.gz
		tar xf make-$MAKE.tar.gz
		rm make-$MAKE.tar.gz
		cd make-$MAKE
		./configure
		./build.sh
		cp make $BIN/make-$MAKE
		;;
	gcc)
		cd $DIR
		wget https://ftp.gnu.org/gnu/gcc/gcc-$GCC/gcc-$GCC.tar.gz
		tar xf gcc-$GCC.tar.gz
		rm gcc-$GCC.tar.gz
		cd gcc-$GCC
		./configure \
			--target=$TARGET-elf \
			--without-headers \
			--with-newlib \
			--with-gnu-as \
			--with-gnu-ld \
			--enable-languages='c' \
			--enable-frame-pointer=no
		make $JOBS all-gcc
		cp gcc $BIN/gcc-$GCC
		;;
	*)
		printf "unsupported package: '$PKG'\n"
		fusage
		;;
esac
