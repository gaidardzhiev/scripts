#!/bin/sh
#very crude source based package manager

PKG=$1
DIR=/opt/spm
SRC=/opt/spm/src
BIN=/opt/spm/bin
LIB=/opt/spm/lib
TARGET=$(uname -m)
GETNUMCPUS=`grep -c '^processor' /proc/cpuinfo`
JOBS='-j '$GETNUMCPUS''
GCC=12.2.0
BINUTILS=2.40
MAKE=4.4
STRONGSWAN=5.9.14
MC=4.7.5.6
TCC=0.9.27
MUSL=1.2.5
BINUTILS=2.40

fusage() {
	printf "usage: $0 <tcc|gcc|make|musl|glibc|mc|git|strongswan|dietlibc|zsh|bash|dash|ash|kernel|awk|grep|sed|toolbox|busybox|toybox|curl|wget|tmux|qemu|i3wm|dmenu|grub2|coreboot|flashrom>\n"
	exit 1
}

mkdir -p "$DIR" "$SRC" "$BIN" "$LIB"

[ $# -lt 1 ] && fusage

shift

case $PKG in
	make)
		cd $SRC
		wget https://ftp.gnu.org/gnu/make/make-$MAKE.tar.gz
		tar xf make-$MAKE.tar.gz
		rm make-$MAKE.tar.gz
		cd make-$MAKE
		./configure
		./build.sh
		cp make $BIN/make-$MAKE-$TARGET
		;;
	gcc)
		cd $SRC
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
		cp gcc $BIN/gcc-$GCC-$TARGET-elf
		;;
	strongswan)
		cd $SRC
		wget https://download.strongswan.org/strongswan-$STRONGSWAN.tar.bz2
		bzip2 -d strongswan-$STRONGSWAN.tar.bz2
		tar xf strongswan-$STRONGSWAN.tar
		rm strongswan-$STRONGSWAN.tar
		cd strongswan-$STRONGSWAN
		./configure \
			--enable-systemd \
			--enable-swanctl
		make $JOBS
		cp strongswan $BIN/strongswan-$STRONGSWAN-$TARGET
		;;
	mc)
		cd $SRC
		wget http://ftp.midnight-commander.org/mc-$MC.tar.xz
		tar xf mc-$MC.tar.xz
		rm mc-$MC.tar.xz
		cd mc-$MC
		./configure \
			--without-x \
			--disable-shared \
			--enable-static
		CC='gcc -static -static-libgcc -fno-exceptions'\
		CXX='g++ -static -static-libgcc -fno-exceptions' \
		LDFLAGS='-Wl,-static -static -lc' \
		LIBS='-lc' \
		make $JOBS
		cp src/mc $BIN/mc-$MC-$TARGET
		;;
	tcc)
		cd $SRC
		wget https://download.savannah.gnu.org/releases/tinycc/tcc-$TCC.tar.bz2
		bzip2 -d tcc-$TCC.tar.bz2
		tar xf tcc-$TCC.tar
		rm tcc-$TCC.tar
		cd tcc-$TCC
		./configure
		make $JOBS
		cp tcc $BIN/tcc-$TCC-$TARGET
		;;
	toolbox)
		cd $SRC
		git clone https://github.com/gaidardzhiev/toolbox
		cd toolbox
		sed -i 's|/home/src/1v4n/toolbox|/opt/toolbox/|g' toolbox.c
		./build_toolchain.sh
		make $JOBS
		cp toolbox $BIN/toolbox-$TARGET
		;;
	musl)
		cd $SRC
		wget https://musl.libc.org/releases/musl-$MUSL.tar.gz
		tar xf musl-$MUSL.tar.gz
		rm musl-$MUSL.tar.gz
		cd musl-$MUSL
		./configure \
			--exec-prefix=$BIN \
			--syslibdir=$LIB \
			--disable-shared
		make $JOBS
		cp bin/musl-gcc $BIN/musl-gcc-$TARGET
		;;
	sed)
		cd $SRC
		git clone git://git.sv.gnu.org/sed
		cd sed
		./bootstrap
		./configure \
			--quiet\
			--disable-gcc-warnings
		make $JOBS
		cp sed $BIN/sed-$TARGET
		;;
	binutils)
		cd $SRC
		wget https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS.tar.gz
		tar xf binutils-$BINUTILS.tar.gz
		rm binutils-$BINUTILS.tar.gz
		cd binutils-$BINUTILS
		make $JOBS
		;;
	dietlibc)
		cd $SRC
		cvs -d :pserver:cvs@cvs.fefe.de:/cvs -z9 co dietlibc
		cd dietlibc
		make
		;;
	*)
		printf "unsupported package: '$PKG'\n"
		fusage
		;;
esac
