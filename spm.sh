#!/bin/sh
#very crude source based package manager

ARG=$1
PKG=$2
DIR=/opt/spm
SRC=/opt/spm/src
BIN=/opt/spm/bin
LIB=/opt/spm/lib
ETC=/opt/spm/etc
SBIN=/opt/spm/sbin
VAR=/opt/spm/var
INC=/opt/spm/include
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
GIT=2.9.5
GREP=3.11

fusage() {
	printf "usage: $0 <build|delete-src> <tcc|gcc|make|musl|glibc|mc|git|strongswan|dietlibc|zsh|bash|dash|ash|kernel|awk|grep|sed|toolbox|busybox|toybox|qbe|curl|wget|tmux|qemu|i3wm|dmenu|grub2|coreboot|flashrom>\n"
	exit 1
}

mkdir -p "$DIR" "$SRC" "$BIN" "$LIB" "$ETC" "$SBIN" "$INC"

[ $# -lt 1 ] && fusage

shift

fbuild(){
	case $PKG in
		make)
			cd $SRC
			wget https://ftp.gnu.org/gnu/make/make-$MAKE.tar.gz
			tar xf make-$MAKE.tar.gz
			rm make-$MAKE.tar.gz
			cd make-$MAKE
			./configure \
				--prefix=$DIR
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
				--prefix=$DIR \
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
				--prefix=$DIR \
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
			./configure \
				--prefix=$DIR
			make $JOBS
			cp tcc $BIN/tcc-$TCC-$TARGET
			;;
		toolbox)
			cd $SRC
			git clone https://github.com/gaidardzhiev/toolbox
			cd toolbox
			sed -i 's|/home/src/1v4n/toolbox|/opt/spm/src/toolbox|g' toolbox.c
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
				--prefix=$DIR \
				--quiet \
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
		dmenu)
			cd $SRC
			git clone git://git.suckless.org/dmenu
			cd dmenu
			make $JOBS
			cp dmenu $BIN/dmenu-$TARGET
			;;
		git)
			cd $SRC
			wget https://www.kernel.org/pub/software/scm/git/git-$GIT.tar.gz
			tar xf git-$GIT.tar.gz
			rm git-$GIT.tar.gz
			cd git-$GIT
			make configure
			./configure \
				--prefix=$DIR
			make $JOBS
			cp git $SRC/git
			;;
		dash)
			cd $SRC
			git clone https://github.com/danishprakash/dash
			cd dash
			make $JOBS
			cp dash $BIN/dash-$TARGET
			;;
		awk)
			cd $SRC
			git clone https://github.com/onetrueawk/awk
			cd awk
			make $JOBS
			mv a.out awk
			cp awk $BIN/awk-$TARGET
			;;
		grep)
			cd $SRC
			wget https://ftp.gnu.org/gnu/grep/grep-$GREP.tar.gz
			tar xf grep-$GREP.tar.gz
			rm grep-$GREP.tar.gz
			cd grep-$GREP
			./configure \
				--prefix=$DIR
			make $JOBS
			cp src/grep $BIN/grep-$TARGET
			cp src/egrep $BIN/egrep-$TARGET
			cp src/fgrep $BIN/fgrep-$TARGET
			;;
		busybox)
			cd $SRC
			wget https://busybox.net/downloads/busybox-snapshot.tar.bz2
			bzip2 -d busybox-snapshot.tar.bz2
			tar xf busybox-snapshot.tar
			rm busybox-snapshot.tar
			cd busybox
			make defconfig
			make $JOBS
			cp busybox $BIN/busybox-$TARGET
			;;
		qbe)
			cd $SRC
			git clone https://github.com/8l/qbe
			cd qbe
			make $JOBS
			cp obj/qbe $BIN/qbe-$TARGET
			;;
		wget)
			cd $SRC
			curl https://ftp.gnu.org/gnu/wget/wget2-latest.tar.gz -o wget2-latest.tar.gz
			tar xf wget2-latest.tar.gz
			rm wget2-latest.tar.gz
			cd wget*
			./configure \
				--prefix=$DIR
			make $JOBS
			;;
		curl)
			cd $SRC
			git clone https://github.com/curl/curl.git
			cd curl
			autoreconf -fi >&2
			automake \
				--add-missing
			./configure \
				--prefix=$DIR \
				--without-ssl \
				--disable-shared
			make $JOBS
			;;
		coreboot)
			cd $SRC
			git clone https://review.coreboot.org/coreboot
			cd coreboot
			make crossgcc-i386 CPUS=$(nproc)
			make -C payloads/coreinfo olddefconfig
			make -C payloads/coreinfo
			make menuconfig
			make savedefconfig
			cat defconfig
			make $JOBS
			;;
		*)
			printf "unsupported package: '$PKG'\n"
			fusage
			;;
	esac
}

fdelete() {
	printf "you will delete all the source code in $SRC\n"
	printf "are you sure? (yes/no)\n"
	read -r RSP
	case $RSP in
		[y]* )
			rm -r $SRC/*
			printf "$SRC deleted...\n"
			;;
		[n]* )
			printf "deletion canceld...\n"
			;;
		*)
			printf "invalid response...\n"
			printf "(yes/no)\n"
			;;
	esac
}

case $ARG in
	build)
		fbuild $PKG
		;;
	delete-src)
		fdelete
		;;
	*)
		printf "unsupported command: '$ARG'\n"
		fusage
		;;
esac
