#!/bin/sh
#very crude source based package manager

ARG=$1
PKG=$2
GET=$2
UPD=$2
DIR=/opt/spm
SRC=/opt/spm/src
BIN=/opt/spm/bin
LIB=/opt/spm/lib
ETC=/opt/spm/etc
SBIN=/opt/spm/sbin
VAR=/opt/spm/var
INC=/opt/spm/include
CROSS=/opt/spm/cross
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
QEMU=9.2.0
P9=plan9

fusage() {
	printf "usage: $0 <operation> <package>\n"
	printf "\n"
	printf "operations:\n"
	printf "		<build-src|get-bin|delete-src|delete-bin|update-src>\n"
	printf "\n"
	printf "packages:\n"
	printf "		<tcc|gcc|make|musl|glibc|mc|git|strongswan|dietlibc|zsh|bash|dash|ash|kernel|awk|grep|sed|toolbox|busybox|toybox|qbe|curl|wget|tmux|qemu|i3wm|dmenu|grub2|coreboot|flashrom|cross|uclibc|john|nmap|lambda-delta|tmg|subc|cc500|scc|c|cproc|9base|airgeddon|masscan|kexec|otcc|hping|esp|aboriginal|qemu>\n"
	exit 1
}

mkdir -p "$DIR" "$SRC" "$BIN" "$LIB" "$ETC" "$SBIN" "$INC" "$CROSS"

[ $# -lt 1 ] && fusage

shift

fbuild_src(){
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
			make $JOBS all-gcc && cp gcc $BIN/gcc-$GCC-$TARGET-elf
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
			make $JOBS && cp strongswan $BIN/strongswan-$STRONGSWAN-$TARGET
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
			make $JOBS && cp src/mc $BIN/mc-$MC-$TARGET
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
			make $JOBS && cp tcc $BIN/tcc-$TCC-$TARGET
			;;
		toolbox)
			cd $SRC
			git clone https://github.com/gaidardzhiev/toolbox
			cd toolbox
			sed -i 's|/home/src/1v4n/toolbox|/opt/spm/src/toolbox|g' toolbox.c
			./build_toolchain.sh
			make $JOBS && cp toolbox $BIN/toolbox-$TARGET
			;;
		musl)
			cd $SRC
			wget https://musl.libc.org/releases/musl-$MUSL.tar.gz
			tar xf musl-$MUSL.tar.gz
			rm musl-$MUSL.tar.gz
			cd musl-$MUSL
			./configure && make $JOBS && make install && cp /usr/local/musl/bin/musl-gcc /usr/bin
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
			make $JOBS && cp sed $BIN/sed-$TARGET
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
			make $JOBS && install bin-$TARGET/diet /usr/local/bin
			;;
		dmenu)
			cd $SRC
			git clone git://git.suckless.org/dmenu
			cd dmenu
			make $JOBS && cp dmenu $BIN/dmenu-$TARGET
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
			make $JOBS && cp git $SRC/git
			;;
		dash)
			cd $SRC
			git clone https://github.com/danishprakash/dash
			cd dash
			make $JOBS && cp dash $BIN/dash-$TARGET
			;;
		awk)
			cd $SRC
			git clone https://github.com/onetrueawk/awk
			cd awk
			make $JOBS && mv a.out awk && cp awk $BIN/awk-$TARGET
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
			make $JOBS && cp busybox $BIN/busybox-$TARGET
			;;
		qbe)
			cd $SRC
			git clone https://github.com/8l/qbe
			cd qbe
			make $JOBS && cp obj/qbe $BIN/qbe-$TARGET
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
		toybox)
			cd $SRC
			git clone https://github.com/landley/toybox
			cd toybox
			make defconfig
			make $JOBS
			;;
		uclibc)
			cd $SRC
			wget https://uclibc.org/downloads/uClibc-snapshot.tar.bz2
			tar xf uClibc-snapshot.tar.bz2
			rm uClibc-snapshot.tar.bz2
			cd uClibc
			make defconfig
			make $JOBS
			;;
		john)
			cd $SRC
			git clone https://github.com/openwall/john
			cd john
			./configure
			make $JOBS
			;;
		nmap)
			cd $SRC
			git clone https://github.com/nmap/nmap
			cd nmap
			./configure
			make $JOBS
			make
			;;
		lambda-delta)
			cd $SRC
			git clone https://github.com/dseagrav/ld
			cd ld
			aclocal && autoheader && autoconf
			automake \
				--add-missing
			./configure || autoreconf -i
			make $JOBS
			;;
		tmg)
			cd $SRC
			git clone https://github.com/amakukha/tmg
			cd tmg
			cd src && ./build.sh
			./tmg.sh ../examples/hello_world.t
			touch input
			./a.out input
			cp tmgl1 tmgl2 $BIN
			;;
		subc)
			cd $SRC
			git clone https://github.com/DoctorWkt/SubC
			cd SubC
			./configure
			cd src
			make $JOBS && make scc && cp scc $BIN/subc-$TARGET
			;;
		cc500)
			cd $SRC
			git clone https://github.com/8l/cc500
			cd cc500
			tcc cc500.c -o cc500 && cp cc500 $BIN
			;;
		scc)
			cd $SRC
			git clone https://github.com/8l/scc
			cd scc
			make $JOBS && cp bin/scc $BIN/scc-$TARGET
			cd tests && make $JOBS
			;;
		c)
			[ "$TARGET" = x86_64 ] && {
				cd $SRC && git clone https://github.com/andrewchambers/c && cd c && make $JOBS && make test && make selfhost
			} || printf "unsupported CPU architecture...\n"
			;;
		cproc)
			cd $SRC
			git clone https://github.com/michaelforney/cproc
			cd cproc
			./configure && make $JOBS
			;;
		tinycc)
			cd $SRC
			git clone https://repo.or.cz/tinycc.git
			cd tinycc
			./configure \
				--prefix=$DIR \
				--bindir=$BIN \
				--libdir=$LIB \
				--includedir=$INC \
				--source-path=$SRC/tinycc \
				--cc=tcc \
				--disable-static \
				--enable-cross
			make $JOBS
			make install
			;;
		9base)
			cd $SRC
			git clone https://git.suckless.org/9base
			cd 9base
			make $JOBS
			cp ascii/ascii $BIN/ascii-$P9
			cp awk/awk $BIN/awk-$P9
			cp basename/basename $BIN/basename-$P9
			cp bc/bc $BIN/bc-$P9
			cp cat/cat $BIN/cat-$P9
			cp cmp/cmp $BIN/cmp-$P9
			cp date/date $BIN/date-$P9
			cp dd/dd $BIN/dd-$P9
			#cp diff/diff $BIN/diff-$P9
			cp du/du $BIN/du-$P9
			#cp echo/echo $BIN/echo-$P9
			;;
		airgeddon)
			cd $SRC
			git clone https://github.com/v1s1t0r1sh3r3/airgeddon
			cp airgeddon/airgeddon.sh $BIN
			;;
		masscan)
			cd $SRC
			git clone https://github.com/robertdavidgraham/masscan
			cd masscan
			make $JOBS
			cp bin/masscan $BIN/masscan-$TARGET
			;;
		kexec)
			cd $SRC
			git clone https://github.com/horms/kexec-tools
			cd kexec-tools
			./bootstrap
			./configure
			make $JOBS
			cp build/sbin/* $SBIN
			;;
		otcc)
			case $TARGET in
				x86)
					cd $SRC
					git clone https://github.com/8l/otcc
					cd otcc
					gcc -O2 otcc.c -o otcc -ldl gcc -O2 otccelf.c -o otccelf
					./otccelf otccelf.c otccelf1
					;;
				*)
					printf "unsupported architecture: $TARGET\n"
					;;
			esac
			;;
		hping)
			cd $SRC
			git clone https://github.com/antirez/hping
			cd hping
			./configure
			make $JOBS
			;;
		qemu)
			cd $SRC
			wget https://download.qemu.org/qemu-$QEMU.tar.xz
			tar xf qemu-$QEMU.tar.xz
			rm qemu-$QEMU.tar.xz
			cd $SRC/qemu-$QEMU
			./configure \
				--prefix=$DIR
				--target-list=aarch64_be-linux-user \
				aarch64-linux-user alpha-linux-user \
				armeb-linux-user arm-linux-user \
				hexagon-linux-user hppa-linux-user \
				i386-linux-user loongarch64-linux-user \
				m68k-linux-user microblazeel-linux-user \
				microblaze-linux-user mips64el-linux-user \
				mips64-linux-user mipsel-linux-user mips-linux-user \
				mipsn32el-linux-user mipsn32-linux-user \
				or1k-linux-user ppc64le-linux-user ppc64-linux-user \
				ppc-linux-user riscv32-linux-user riscv64-linux-user \
				s390x-linux-user sh4eb-linux-user sh4-linux-user \
				sparc32plus-linux-user sparc64-linux-user \
				sparc-linux-user x86_64-linux-user \
				xtensaeb-linux-user xtensa-linux-user \
				aarch64-softmmu alpha-softmmu arm-softmmu \
				avr-softmmu hppa-softmmu i386-softmmu \
				loongarch64-softmmu m68k-softmmu \
				microblazeel-softmmu microblaze-softmmu \
				mips64el-softmmu mips64-softmmu mipsel-softmmu \
				mips-softmmu or1k-softmmu ppc64-softmmu ppc-softmmu \
				riscv32-softmmu riscv64-softmmu rx-softmmu \
				s390x-softmmu sh4eb-softmmu sh4-softmmu \
				sparc64-softmmu sparc-softmmu tricore-softmmu \
				x86_64-softmmu xtensaeb-softmmu xtensa-softmmu \
				--enable-curl \
				--enable-tools \
				--enable-linux-user \
				--enable-bsd-user \
				--enable-libusb \
				--enable-kvm \
				--enable-fuse \
				--enable-libudev \
				--enable-libssh \
				--enable-debug
			make $JOBS
			;;
		esolangs)
			cd $SRC
			git clone https://github.com/gaidardzhiev/esolangs
			cd esolangs && make $JOBS
			cp brainf whitespace $BIN
			;;	
		*)
			printf "unsupported package: '$PKG'\n"
			fusage
			;;
	esac
}

fdelete_src() {
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

fbin() {
	case $GET in
		toybox)
			case $TARGET in
				armv8l)
					cd $BIN
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-armv7m
					chmod +x toybox-armv7m
					./toybox-armv7m
					;;
				x86_64)
					cd $BIN
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-x86_64
					chmod +x toybox-x86_64
					./toybox-x86_64
					;;
				x86)
					cd $BIN
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-i686
					chmod +x toybox-i686
					./toybox-i686
					;;
				mips)
					cd $BIN
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-mips
					chmod +x toybox-mips
					./toybox-mips
					;;
				aarch64)
					cd $BIN
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-aarch64
					chmod +x toybox-aarch64
					./toybox-aarch64
					;;
				armv4l)
					cd $BIN
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-armv4l
					chmod +x toybox-armv4l
					./toybox-armv4l
					;;
				armv5l)
					cd $BIN
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-armv5l
					chmod +x toybox-armv5l
					./toybox-armv5l
					;;
				powerpc)
					cd $BIN
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-powerpc
					chmod +x toybox-powerpc
					./toybox-powerpc
					;;
				*)
					printf "unsupported CPU architecture...\n"
					;;
			esac
			;;
		cross)
			case $TARGET in
				x86_64)
					cd $CROSS
					wget https://landley.net/toybox/downloads/binaries/toolchains/latest/x86_64-linux-musl-cross.tar.xz
					tar xf x86_64-linux-musl-cross.tar.xz
					rm x86_64-linux-musl-cross.tar.xz
					cd /x86_64-linux-musl-cross/bin
					ls -l
					printf "toochain currently built from:\n"
					printf "musl 1.2.5\n"
					printf "linux 6.8\n"
					printf "gcc 11.2.0\n"
					printf "binutils 2.33.1\n"
					;;
				x86)
					cd $CROSS
					wget https://landley.net/toybox/downloads/binaries/toolchains/latest/i686-linux-musl-cross.tar.xz
					tar xf i686-linux-musl-cross.tar.xz
					rm i686-linux-musl-cross.tar.xz
					cd i686-linux-musl-cross/bin
					ls -l
					printf "toochain currently built from:\n"
					printf "musl 1.2.5\n"
					printf "linux 6.8\n"
					printf "gcc 11.2.0\n"
					printf "binutils 2.33.1\n"
					;;
				aarch64)
					cd $CROSS
					wget https://landley.net/toybox/downloads/binaries/toolchains/latest/aarch64-linux-musleabi-cross.tar.xz
					tar xf aarch64-linux-musleabi-cross.tar.xz
					rm aarch64-linux-musleabi-cross.tar.xz
					cd aarch64-linux-musleabi-cross/bin
					ls -l
					printf "toochain currently built from:\n"
					printf "musl 1.2.5\n"
					printf "linux 6.8\n"
					printf "gcc 11.2.0\n"
					printf "binutils 2.33.1\n"
					;;
				armv7m)
					cd $CROSS
					wget https://landley.net/toybox/downloads/binaries/toolchains/latest/armv7m-linux-musleabi-cross.tar.xz
					tar xf armv7m-linux-musleabi-cross.tar.xz
					rm armv7m-linux-musleabi-cross.tar.xz
					cd armv7m-linux-musleabi-cross.tar/bin
					ls -l
					printf "toochain currently built from:\n"
					printf "musl 1.2.5\n"
					printf "linux 6.8\n"
					printf "gcc 11.2.0\n"
					printf "binutils 2.33.1\n"
					;;
				*)
					printf "unsupported CPU architecture...\n"
					;;
			esac
			;;
		esp)
			case $TARGET in
				x86_64)
					cd /opt
					wget https://dl.espressif.com/dl/xtensa-lx106-elf-gcc8_4_0-esp-2020r3-linux-amd64.tar.gz
					tar xf xtensa-lx106-elf-gcc8_4_0-esp-2020r3-linux-amd64.tar.gz
					rm xtensa-lx106-elf-gcc8_4_0-esp-2020r3-linux-amd64.tar.gz
					export PATH=$PATH:/opt/xtensa-lx106-elf/bin
					;;
				i686)
					cd /opt
					wget https://dl.espressif.com/dl/xtensa-lx106-elf-gcc8_4_0-esp-2020r3-linux-i686.tar.gz
					tar xf xtensa-lx106-elf-gcc8_4_0-esp-2020r3-linux-i686.tar.gz
					rm xtensa-lx106-elf-gcc8_4_0-esp-2020r3-linux-i686.tar.gz
					export PATH=$PATH:/opt/xtensa-lx106-elf/bin
					;;
				*)
					printf "unsupported architecture: $TARGET\n"
					;;
			esac
			;;
		aboriginal)
			case $TARGET in
				armv6l)
					cd $CROSS
					wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-armv6l.tar.gz
					tar xf cross-compiler-armv6l.tar.gz
					rm cross-compiler-armv6l.tar.gz
					ls -la cross-compiler-armv6l
					;;
				x86_64)
					cd $CROSS
					wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-x86_64.tar.gz
					tar xf cross-compiler-x86_64.tar.gz
					rm cross-compiler-x86_64.tar.gz
					ls -la cross-compiler-x86_64
					;;
				i686)
					cd $CROSS
					wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-i686.tar.gz
					tar xf cross-compiler-i686.tar.gz
					rm cross-compiler-i686.tar.gz
					ls -la cross-compiler-i686
					;;
				arm4tl)
					cd $CROSS
					wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-armv4tl.tar.gz
					tar xf cross-compiler-armv4tl.tar.gz
					rm cross-compiler-armv4tl.tar.gz
					ls -la cross-compiler-armv4tl
					;;
				*)
					printf "unsupported architecture: $TARGET\n"
					;;
			esac
			;;
		*)
			printf "unsupported command: '$GET'\n"
			fusage
			;;
	esac
}

fdelete_bin() {
	printf "you will delete all the bin's in $BIN\n"
	printf "are you sure? (yes/no)\n"
	read -r RSP
	case $RSP in
		[y]* )
			rm -r $BIN/*
			printf "$BIN deleted...\n"
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

fupdate_src() {
	case $UPD in 
		toolbox)
			cd $SRC/toolbox &&
				sed -i 's|/opt/spm/src/toolbox|/home/src/1v4n/toolbox|g' toolbox.c &&
				git pull &&
				./build_toolchain.sh
				sed -i 's|/home/src/1v4n/toolbox|/opt/spm/src/toolbox|g' toolbox.c &&
				make $JOBS &&
				cp toolbox $BIN/toolbox-$TARGET
			;;
		dash)
			cd $SRC/dash &&
				git pull &&
				make $JOBS &&
				cp dash $BIN/dash-$TARGET
			;;
		tinycc)
			cd $SRC/tinycc &&
				git pull &&
				./configure \
					--prefix=$DIR \
					--bindir=$BIN \
					--libdir=$LIB \
					--includedir=$INC \
					--source-path=$SRC/tinycc \
					--cc=tcc \
					--disable-static \
					--enable-cross
				make $JOBS &&
				make install
			;;
		*)
			printf "unsupported package $UPD...\n"
			fusage
			;;
	esac
}

case $ARG in
	build-src)
		fbuild_src $PKG
		;;
	delete-src)
		fdelete_src
		;;
	get-bin)
		fbin $GET
		;;
	delete-bin)
		fdelete_bin
		;;
	update-src)
		fupdate_src $UPD
		;;
	*)
		printf "unsupported command: '$ARG'\n"
		fusage
		;;
esac
