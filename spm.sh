#!/bin/sh
#very crude source based package manager

DIR=/opt/spm
BIN=$DIR/bin
LIB=$DIR/lib
TARGET=$(uname -m)
PKG=$1
GETNUMCPUS=`grep -c '^processor' /proc/cpuinfo`
JOBS='-j '$GETNUMCPUS''
GCC=12.2.0
BINUTILS=2.40
MAKE=4.4
STRONGSWAN=5.9.14
MC=4.7.5.6
TCC=0.9.27
MUSL=1.2.5

fusage() {
	printf "usage: $0 <tcc|gcc|make|musl|glibc|mc|git|strongswan|zsh|bash|dash|ash|kernel|awk|grep|sed|toolbox|busybox|toybox|curl|wget|tmux|qemu|i3wm|dmenu|grub2|coreboot|flashrom>\n"
	exit 1
}

if [ ! -d $DIR ]; then
	mkdir -p $DIR
fi

if [ ! -d $BIN ]; then
	mkdir -p $BIN
fi

if [ ! -d $LIB ]; then
	mkdkr -p $LIB
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
		cp make $BIN/make-$MAKE-$TARGET
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
		cp gcc $BIN/gcc-$GCC-$TARGET-elf
		;;
	strongswan)
		cd $DIR
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
		cd $DIR
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
		cd $DIR
		wget https://download.savannah.gnu.org/releases/tinycc/tcc-$TCC.tar.bz2
		bzip2 -d tcc-$TCC.tar.bz2
		tar xf tcc-$TCC.tar
		rm tcc-$TCC.tar
		cd tcc-$TCC
		./configure
		make
		cp tcc $BIN/tcc-$TCC-$TARGET
		;;
	toolbox)
		cd $DIR
		git clone https://github.com/gaidardzhiev/toolbox
		cd toolbox
		./build_toolchain
		make
		cp toolbox $BIN/toolbox-$TARGET
		;;
	musl)
		cd $DIR
		wget https://musl.libc.org/releases/musl-$MUSL.tar.gz
		tar xf musl-$MUSL.tar.gz
		rm musl-$MUSL.tar.gz
		cd musl-$MUSL
		./configure \
			--exec-prefix=$BIN \
			--syslibdir=$LIB \
			--disable-shared
		make
		cp bin/musl-gcc $BIN/musl-gcc-$TARGET
		;;
	*)
		printf "unsupported package: '$PKG'\n"
		fusage
		;;
esac
