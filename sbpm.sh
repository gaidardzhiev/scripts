#!/bin/sh
#very crude source based package manager
#boasting only two essential dependencies:
#POSIX compliant shell and wget

ARG=$1
PKG=$2
GET=$2
UPD=$2
DIR="/opt/spm"
SRC="/opt/spm/src"
BIN="/opt/spm/bin"
LIB="/opt/spm/lib"
ETC="/opt/spm/etc"
SBIN="/opt/spm/sbin"
VAR="/opt/spm/var"
INC="/opt/spm/include"
CROSS="/opt/spm/cross"
SHR="/opt/spm/share"
NATIVE="/opt/spm/native"
MNT="/opt/spm/mnt"
USR="/opt/spm/usr"
TARGET=$(uname -m)
GETNUMCPUS=`grep -c '^processor' /proc/cpuinfo`
JOBS='-j '$GETNUMCPUS''
GCC="12.2.0"
BINUTILS="2.40"
MAKE="4.4"
STRONGSWAN="5.9.14"
MC="4.7.5.6"
TCC="0.9.27"
MUSL="1.2.5"
BINUTILS="2.40"
GIT="2.9.5"
GREP="3.11"
QEMU="9.2.0"
P9="plan9"
CFG="configure config.ac Makefile.am"
BASH="5.3-beta"
GNUPG="2.4.7"
GO="1.4"
PHONE="compal_e88"
FIRMWARE="layer1"
AIR="1.7"
GDB="12.1"
ZSH="5.9"
GZIP="1.13"
LINUX="6.13.1"
DIFF="3.11"
TCSH="6.24.15"

fusage() {
	printf "usage: $0 <operation> <package>\n"
	printf "\n"
	printf "operations:\n"
	printf "		<build-src|get-bin|delete-src|delete-bin|update-src>\n"
	printf "\n"
	printf "packages:\n"
	printf "		<tcc|gcc|make|musl|glibc|mc|git|strongswan|dietlibc|zsh|bash|dash|ash|linux-kernel|awk|grep|sed|toolbox|busybox|toybox|qbe|curl|wget|tmux|qemu|i3wm|dmenu|grub|coreboot|flashrom|cross-compiler|uclibc|john|nmap|lambda-delta|tmg|subc|cc500|scc|c|cproc|9base|airgeddon|masscan|kexec|otcc|hping|esp|aboriginal|qemu|interceptor|gnupg|go|oyacc|libosmocore|libosmo-gprs|gapk|osmocom-bb|aircrack-ng|smartmontools|gdb|kmod|gzip|rsync|xz|bc|lzip|pahole|tar|bzip2|initramfs|vim|native-compiler|mkroot|avr-toolchain|diff|tcsh|jfsutils|squashfs-tools|iptables|pcmciautils|shkd>\n"
	exit 1
}

mkdir -p "$DIR" "$SRC" "$BIN" "$LIB" "$ETC" "$SBIN" "$INC" "$CROSS" "$SHR" "$NATIVE" "$MNT" "$USR"

[ $# -lt 1 ] && fusage

shift

fbuild_src(){
	case "$PKG" in
		make)
			cd "$SRC"
			wget https://ftp.gnu.org/gnu/make/make-"$MAKE".tar.gz
			tar xfv make-"$MAKE".tar.gz
			rm make-"$MAKE".tar.gz
			cd make-"$MAKE"
			./configure \
				--prefix="$DIR"
			./build.sh
			cp make "$BIN"/make-"$MAKE"-"$TARGET"
			;;
		gcc)
			cd "$SRC"
			wget https://ftp.gnu.org/gnu/gcc/gcc-"$GCC"/gcc-"$GCC".tar.gz
			tar xf gcc-"$GCC".tar.gz
			rm gcc-"$GCC".tar.gz
			cd gcc-"$GCC"
			./configure \
				--prefix="$DIR" \
				--target="$TARGET"-elf \
				--without-headers \
				--with-newlib \
				--with-gnu-as \
				--with-gnu-ld \
				--enable-languages='c' \
				--enable-frame-pointer=no
			make "$JOBS" all-gcc && \
				cp gcc "$BIN"/gcc-"$GCC"-"$TARGET"-elf
			make "$JOBS" all-target-libgcc CFLAGS_FOR_TARGET="-g -02"
			;;
		strongswan)
			cd "$SRC"
			wget https://download.strongswan.org/strongswan-"$STRONGSWAN".tar.bz2
			bzip2 -d strongswan-"$STRONGSWAN".tar.bz2
			tar xfv strongswan-"$STRONGSWAN".tar
			rm strongswan-"$STRONGSWAN".tar
			cd strongswan-"$STRONGSWAN"
			./configure \
				--prefix="$DIR" \
				--enable-systemd \
				--enable-swanctl
			make "$JOBS" && \
				cp strongswan "$BIN"/strongswan-"$STRONGSWAN"-"$TARGET"
			;;
		mc)
			cd "$SRC"
			wget http://ftp.midnight-commander.org/mc-"$MC".tar.xz
			tar xfv mc-"$MC".tar.xz
			rm mc-"$MC".tar.xz
			cd mc-"$MC"
			./configure \
				--without-x \
				--disable-shared \
				--enable-static
			CC='gcc -static -static-libgcc -fno-exceptions'\
			CXX='g++ -static -static-libgcc -fno-exceptions' \
			LDFLAGS='-Wl,-static -static -lc' \
			LIBS='-lc' \
			make "$JOBS" && \
				cp src/mc "$BIN"/mc-"$MC"-"$TARGET"
			;;
		tcc)
			cd "$SRC"
			wget https://download.savannah.gnu.org/releases/tinycc/tcc-"$TCC".tar.bz2
			bzip2 -d tcc-"$TCC".tar.bz2
			tar xfv tcc-"$TCC".tar
			rm tcc-"$TCC".tar
			cd tcc-"$TCC"
			./configure \
				--prefix="$DIR"
			make "$JOBS" && \
				cp tcc "$BIN"/tcc-"$TCC"-"$TARGET"
			;;
		toolbox)
			cd "$SRC"
			git clone https://github.com/gaidardzhiev/toolbox
			cd toolbox
			sed -i 's|/home/src/1v4n/toolbox|/opt/spm/src/toolbox|g' toolbox.c
			./build_toolchain.sh
			make "$JOBS" && \
				cp toolbox "$BIN"/toolbox-"$TARGET"
			;;
		musl)
			cd "$SRC"
			wget https://musl.libc.org/releases/musl-"$MUSL".tar.gz
			tar xfv musl-"$MUSL".tar.gz
			rm musl-"$MUSL".tar.gz
			cd musl-"$MUSL"
			./configure && {
				make "$JOBS";
				make install;
				cp /usr/local/musl/bin/musl-gcc /usr/bin;
			}
			;;
		sed)
			cd "$SRC"
			git clone --depth=1 git://git.sv.gnu.org/sed
			cd sed
			./bootstrap
			./configure \
				--prefix="$DIR" \
				--quiet \
				--disable-gcc-warnings
			make "$JOBS" && \
				cp sed "$BIN"/sed-"$TARGET"
			;;
		binutils)
			cd "$SRC"
			wget https://ftp.gnu.org/gnu/binutils/binutils-"$BINUTILS".tar.gz
			tar xfv binutils-"$BINUTILS".tar.gz
			rm binutils-"$BINUTILS".tar.gz
			cd binutils-"$BINUTILS"
			make "$JOBS"
			;;
		dietlibc)
			cd "$SRC"
			cvs -d :pserver:cvs@cvs.fefe.de:/cvs -z9 co dietlibc
			cd dietlibc
			make "$JOBS" && \
				install bin-"$TARGET"/diet /usr/local/bin
			;;
		dmenu)
			cd "$SRC"
			git clone --depth=1 git://git.suckless.org/dmenu
			cd dmenu
			make "$JOBS" && \
				cp dmenu "$BIN"/dmenu-"$TARGET"
			;;
		git)
			cd "$SRC"
			wget https://www.kernel.org/pub/software/scm/git/git-"$GIT".tar.gz
			tar xfv git-"$GIT".tar.gz
			rm git-"$GIT".tar.gz
			cd git-"$GIT"
			make configure
			./configure \
				--prefix="$DIR"
			make "$JOBS" && \
				cp git "$SRC"/git
			;;
		dash)
			cd "$SRC"
			git clone --depth=1 https://github.com/danishprakash/dash
			cd dash
			make "$JOBS" && \
				cp dash "$BIN"/dash-"$TARGET"
			;;
		awk)
			cd "$SRC"
			git clone --depth=1 https://github.com/onetrueawk/awk
			cd awk
			make "$JOBS" && {
				mv a.out awk;
				cp awk "$BIN"/awk-"$TARGET";
			}
			;;
		grep)
			cd "$SRC"
			wget https://ftp.gnu.org/gnu/grep/grep-"$GREP".tar.gz
			tar xfv grep-"$GREP".tar.gz
			rm grep-"$GREP".tar.gz
			cd grep-"$GREP"
			./configure \
				--prefix="$DIR"
			make "$JOBS" && {
				cp src/grep "$BIN"/grep-"$TARGET";
				cp src/egrep "$BIN"/egrep-"$TARGET";
				cp src/fgrep "$BIN"/fgrep-"$TARGET";
			}
			;;
		busybox)
			cd "$SRC"
			wget https://busybox.net/downloads/busybox-snapshot.tar.bz2
			bzip2 -d busybox-snapshot.tar.bz2
			tar xfv busybox-snapshot.tar
			rm busybox-snapshot.tar
			cd busybox
			make defconfig
			make "$JOBS" && \
				cp busybox "$BIN"/busybox-"$TARGET"
			;;
		qbe)
			cd "$SRC"
			git clone --depth=1 https://github.com/8l/qbe
			cd qbe
			make "$JOBS" && \
				cp obj/qbe "$BIN"/qbe-"$TARGET"
			;;
		wget)
			cd "$SRC"
			curl https://ftp.gnu.org/gnu/wget/wget2-latest.tar.gz -o wget2-latest.tar.gz
			tar xfv wget2-latest.tar.gz
			rm wget2-latest.tar.gz
			cd wget*
			./configure \
				--prefix="$DIR"
			make "$JOBS"
			;;
		curl)
			cd "$SRC"
			git clone --depth=1 https://github.com/curl/curl.git
			cd curl
			autoreconf -fi >&2
			automake \
				--add-missing
			./configure \
				--prefix="$DIR" \
				--without-ssl \
				--disable-shared
			make "$JOBS" && \
				cp src/curl "$BIN"/curl-"$TARGET"
			;;
		coreboot)
			cd "$SRC"
			git clone --depth=1 https://review.coreboot.org/coreboot
			cd coreboot
			make crossgcc-i386 CPUS=$(nproc)
			make -C payloads/coreinfo olddefconfig
			make -C payloads/coreinfo
			make menuconfig
			make savedefconfig
			cat defconfig
			make "$JOBS"
			;;
		toybox)
			cd $SRC
			git clone --depth=1 https://github.com/landley/toybox
			cd toybox
			make defconfig
			make $JOBS && \
				cp toybox $BIN/toybox
			;;
		uclibc)
			cd $SRC
			wget https://uclibc.org/downloads/uClibc-snapshot.tar.bz2
			tar xfv uClibc-snapshot.tar.bz2
			rm uClibc-snapshot.tar.bz2
			cd uClibc
			make defconfig
			make $JOBS
			;;
		john)
			cd $SRC
			git clone --depth=1 https://github.com/openwall/john
			cd john
			./configure
			make $JOBS
			;;
		nmap)
			cd $SRC
			git clone --depth=1 https://github.com/nmap/nmap
			cd nmap
			./configure
			make $JOBS
			;;
		lambda-delta)
			cd $SRC
			git clone --depth=1 https://github.com/dseagrav/ld
			cd ld
			aclocal && {
				autoheader;
				autoconf;
			}
			automake \
				--add-missing
			./configure || \
				autoreconf -i
			make $JOBS
			;;
		tmg)
			cd $SRC
			git clone https://github.com/amakukha/tmg
			cd tmg
			cd src && \
				./build.sh
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
			make $JOBS && {
				make scc;
				cp scc $BIN/subc-$TARGET;
			}
			;;
		cc500)
			cd $SRC
			git clone https://github.com/8l/cc500
			cd cc500
			tcc cc500.c -o cc500 && \
				cp cc500 $BIN
			;;
		scc)
			cd $SRC
			git clone https://github.com/8l/scc
			cd scc
			make $JOBS && \
				cp bin/scc $BIN/scc-$TARGET
			cd tests && \
				make $JOBS
			;;
		c)
			[ "$TARGET" = x86_64 ] && {
				cd $SRC;
				git clone https://github.com/andrewchambers/c;
				cd c;
				make $JOBS;
				make test;
				make selfhost;
			} || {
				printf "unsupported CPU architecture...\n";
				exit 1;
			}
			;;
		cproc)
			cd $SRC
			git clone https://github.com/michaelforney/cproc
			cd cproc
			./configure && \
				make $JOBS
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
			make $JOBS && \
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
			git clone --depth=1 https://github.com/robertdavidgraham/masscan
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
					exit 1
					;;
			esac
			;;
		hping)
			cd $SRC
			git clone --depth=1 https://github.com/antirez/hping
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
				aarch64-linux-user \
				alpha-linux-user \
				armeb-linux-user \
				arm-linux-user \
				hexagon-linux-user \
				hppa-linux-user \
				i386-linux-user \
				loongarch64-linux-user \
				m68k-linux-user \
				microblazeel-linux-user \
				microblaze-linux-user \
				mips64el-linux-user \
				mips64-linux-user \
				mipsel-linux-user \
				mips-linux-user \
				mipsn32el-linux-user \
				mipsn32-linux-user \
				or1k-linux-user \
				ppc64le-linux-user \
				ppc64-linux-user \
				ppc-linux-user \
				riscv32-linux-user \
				riscv64-linux-user \
				s390x-linux-user \
				sh4eb-linux-user \
				sh4-linux-user \
				sparc32plus-linux-user \
				sparc64-linux-user \
				sparc-linux-user \
				x86_64-linux-user \
				xtensaeb-linux-user \
				xtensa-linux-user \
				aarch64-softmmu \
				alpha-softmmu \
				arm-softmmu \
				avr-softmmu \
				hppa-softmmu \
				i386-softmmu \
				loongarch64-softmmu \
				m68k-softmmu \
				microblazeel-softmmu \
				microblaze-softmmu \
				mips64el-softmmu \
				mips64-softmmu \
				mipsel-softmmu \
				mips-softmmu \
				or1k-softmmu \
				ppc64-softmmu \
				ppc-softmmu \
				riscv32-softmmu \
				riscv64-softmmu \
				rx-softmmu \
				s390x-softmmu \
				sh4eb-softmmu \
				sh4-softmmu \
				sparc64-softmmu \
				sparc-softmmu \
				tricore-softmmu \
				x86_64-softmmu \
				xtensaeb-softmmu \
				xtensa-softmmu \
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
			cd esolangs && \
				make $JOBS
			cp brainf $BIN/brainf-$TARGET
			cp whitespace $BIN/whitespace-$TARGET
			;;
		interceptor)
			cd $SRC
			git clone https://github.com/gaidardzhiev/interceptor
			cd interceptor && {
				make;
				cp intercept.so $LIB;
				printf "usage: LD_PRELOAD=$LIB/intercept.so /bin/brave\n";
			}
			;;
		bash)
			cd $SRC
			wget wget https://fosszone.csd.auth.gr/gnu/bash/bash-$BASH.tar.gz
			tar xfv bash-$BASH.tar.gz
			rm bash-$BASH.tar.gz
			cd bash-$BASH
			./configure \
				--enable-directory-stack=yes \
				--enable-strict-posix-default=yes \
				--enable-static-link=yes \
				--enable-net-redirections=yes \
				--enable-cond-command=yes \
				--enable-cond-regexp=yes
			make $JOBS
			cp bash $BIN/bash-$TARGET
			;;
		gnupg)
			cd $SRC
			wget https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-$GNUPG.tar.bz2
			bzip2 -d https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-$GNUPG.tar.bz2
			tar xfv gnupg-$GNUPG.tar
			rm gnupg-$GNUPG.tar
			cd gnupg-$GNUPG
			mkdir build
			cd build
			../configure && {
				make $JOBS;
				make check;
			}
			;;
		go)
			cd $SRC
			wget https://dl.google.com/go/go$GO-bootstrap-20171003.tar.gz
			tar xfv go$GO-bootstrap-20171003.tar.gz
			rm go$GO-bootstrap-20171003.tar.gz
			cd go/src
			./make.bash
			cp ../bin/go $BIN/go-$GO
			cp ../bin/gofmt $BIN/gofmt-$GO
			;;
		oyacc)
			cd $SRC
			git clone https://github.com/ibara/yacc oyacc
			cd oyacc && {
				./configure;
				make $JOBS;
				cp oyacc $BIN/oyacc-$TARGET;
			}
			;;
		libosmocore)
			cd $SRC
			git clone --depth=1 https://gitea.osmocom.org/osmocom/libosmocore.git
			cd libosmocore
			autoreconf -i
			./configure \
				--disable-pcsc
			make $JOBS && \
				make install
			ldconfig -i
			;;
		libosmo-gprs)
			cd $SRC
			git clone --depth=1 https://gitea.osmocom.org/osmocom/libosmo-gprs.git
			cd libosmo-gprs
			autoreconf -i
			./configure
			make $JOBS && \
				make install
			ldconfig -i
			;;
		gapk)
			cd $SRC
			git clone --depth=1 https://gitea.osmocom.org/osmocom/gapk
			cd gapk
			autoreconf -i
			./configure \
				--enable-gsmhr
			make $JOBS && \
				make install
			ldconfig
			;;
		osmocom-bb)
			cd $SRC
			git clone --depth=1 https://gitea.osmocom.org/phone-side/osmocom-bb.git
			cd osmocom-bb
			git pull --rebase
			cd src
			make $JOBS -e CROSS_TOOL_PREFIX=arm-none-eabi-
			cd host/osmocon
			./osmocon -p /dev/ttyUSB0 -m c123xor ../../target/firmware/board/$PHONE/$FIRMWARE.compalram.bin
			;;
		aircrack-ng)
			cd $SRC
			wget https://download.aircrack-ng.org/aircrack-ng-$AIR.tar.gz
			tar -zxvf aircrack-ng-$AIR.tar.gz
			rm aircrack-ng-$AIR.tar.gz
			cd aircrack-ng-$AIR
			autoreconf -i
			./configure --with-experimental
			make $JOBS && \
				make install
			ldconfig
			;;
		smartmontools)
			cd $SRC
			svn co https://svn.code.sf.net/p/smartmontools/code/trunk/smartmontools smartmontools
			cd smartmontools
			./autogen.sh
			./configure
			make $JOBS && \
				make install
			;;
		gdb)
			cd $SRC
			wget https://ftp.gnu.org/gnu/gdb/gdb-$GDB.tar.gz
			tar xfv gdb-$GDB.tar.gz
			rm gdb-$GDB.tar.gz
			cd gdb-$GDB
			./configure \
				--target=$TARGET \
				--disable-werror
			make all-gdb
			;;
		zsh)
			cd $SRC
			wget https://www.zsh.org/pub/zsh-$ZSH.tar.xz
			tar xfv zsh-$ZSH.tar.xz
			rm zsh-$ZSH.tar.xz
			cd zsh-$ZSH
			./configure \
				--prefix=$DIR
			make $JOBS && \
				make install
			;;
		kmod)
			cd $SRC
			git clone https://github.com/kmod-project/kmod
			cd kmod
			./autogen.sh
			./configure \
				CFLAGS='-g -O2' \
				--prefix=/usr \
				--sysconfdir=/etc \
				--libdir=/usr/lib  \
				--enable-debug \
				--enable-gtk-doc \
				--with-zstd \
				--with-xz \
				--with-zlib \
				--with-openssl \
				--disable-manpages
			make $JOBS && \
				make install
			;;
		gzip)
			cd $SRC
			wget https://ftp.gnu.org/gnu/gzip/gzip-$GZIP.tar.gz
			tar xfv gzip-$GZIP.tar.gz
			rm gzip-$GZIP.tar.gz
			cd gzip-$GZIP
			./configure
			make $JOBS && \
				cp gzip $BIN/gzip-$TARGET
			;;
		rsync)
			cd $SRC
			git clone --depth=1 https://github.com/rsyncproject/rsync
			cd rsync
			./configure \
				--disable-md2man
			make $JOBS && \
				cp rsync $BIN/rsync-$TARGET
			;;
		xz)
			cd $SRC
			git clone --depth=1 https://github.com/tukaani-project/xz
			cd xz
			./autogen.sh
			./configure \
				--enable-debug \
				--disable-shared
			make $JOBS
			;;
		bc)
			cd $SRC
			git clone --depth=1 https://github.com/gavinhoward/bc
			cd bc
			./configure.sh
			make $JOBS && \
				cp bin/bc $BIN/bc-$TARGET
			;;
		lzip)
			cd $SRC
			wget https://download.savannah.gnu.org/releases/lzip/lzip-1.25.tar.gz
			tar xfv lzip-1.25.tar.gz
			rm lzip-1.25.tar.gz
			cd lzip-1.25
			./configure && {
				make check;
				make install;
			}
			;;
		elfutils)
			cd $SRC
			git clone --depth=1 git://sourceware.org/git/elfutils.git
			cd elfutils
			autoreconf -i -f && {
				./configure \
					--enable-maintainer-mode;
				make $JOBS;
				make check;
				make install;
			}
			;;
		pahole)
			cd $SRC
			git clone --depth=1 https://github.com/acmel/dwarves
			cd dwarves
			mkdir build && {
				cd build;
				cmake ..;
				make install;
			}
			;;
		tar)
			cd $SRC
			git clone --depth=1 https://git.savannah.gnu.org/git/tar.git
			cd tar
			./bootstrap
			;;
		bzip2)
			cd $SRC
			git clone --depth=1 https://gitlab.com/bzip2/bzip2
			cd bzip2
			mkdir build && {
				cd build;
				cmake ..;
			}
			;;
		linux-kernel)
			cd $SRC
			wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$LINUX.tar.xz
			tar xfv linux-$LINUX.tar.xz
			rm linux-$LINUX.tar.xz
			cd linux-$LINUX
			make tinyconfig
			sed -i 's/^# CONFIG_TTY is not set/CONFIG_TTY=y/' .config
			sed -i 's/^# CONFIG_64BIT is not set/CONFIG_64BIT=y/' .config
			sed -i 's/^# CONFIG_PRINTK is not set/CONFIG_PRINTK=y/' .config
			sed -i 's/^# CONFIG_PROC_FS is not set/CONFIG_PROC_FS=y/' .config
			sed -i 's/^# CONFIG_DEVTMPFS is not set/CONFIG_DEVTMPFS=y/' .config
			sed -i 's/^# CONFIG_BINFMT_ELF is not set/CONFIG_BINFMT_ELF=y/' .config
			sed -i 's/^# CONFIG_KERNEL_GZIP is not set/CONFIG_KERNEL_GZIP=y/' .config
			#sed -i 's/^# CONFIG_RANDOMIZE_BASE is not set/CONFIG_RANDOMIZE_BASE=y/' .config
			#sed -i 's/^# CONFIG_RANDOMIZE_KASLR is not set/CONFIG_RANDOMIZE_KASLR=y/' .config
			sed -i 's/^# CONFIG_BLK_DEV_INITRD is not set/CONFIG_BLK_DEV_INITRD=y/' .config
			sed -i 's/^# CONFIG_INITRAMFS_PRESERVE_MTIME is not set/CONFIG_INITRAMFS_PRESERVE_MTIME=y/' .config
			grep "CONFIG_TTY=y" .config || exit 1
			grep "CONFIG_PRINTK=y" .config || exit 1
			grep "CONFIG_PROC_FS=y" .config || exit 1
			grep "CONFIG_DEVTMPFS=y" .config || exit 1
			grep "CONFIG_BINFMT_ELF=y" .config || exit 1
			grep "CONFIG_KERNEL_GZIP=y" .config || exit 1
			grep "CONFIG_BLK_DEV_INITRD=y" .config || exit 1
			grep "CONFIG_INITRAMFS_PRESERVE_MTIME=y" .config || exit 1
			grep "=y" .config | wc -l
			grep "=m" .config | wc -l
			time make $JOBS
			;;
		initramfs)
			cd $SRC
			wget https://busybox.net/downloads/busybox-1.26.2.tar.bz2
			tar -xvf busybox-1.26.2.tar.bz2
			rm busybox-1.26.2.tar.bz2
			cd busybox-1.26.2
			make defconfig
			make menuconfig
			make $JOBS && {
				file busybox;
				make install;
				cd _install;
				mkdir -p {bin,dev,etc,lib,lib64,mnt/root,proc,root,sbin,sys,run};
				cd dev;
				mknod sda b 8 0;
				mknod console c 5 1;
				cd ../;
			}
			touch init
			chmod +x init
			printf "#!/bin/sh\n" > init
			printf "mount -t devtmpfs none /dev\n" >> init
			printf "mount -t proc none /proc\n" >> init
			printf "mount -t sysfs none /sys\n" >> init
			printf "exec /bin/sh\n" >> init
			find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
			;;
		vim)
			cd $SRC
			wget https://ftp.nluug.nl/pub/vim/unix/vim-9.0.tar.bz2
			cd vim90
			./configure \
				--prefix=$SPM \
				--disable-darwin \
				--disable-smack \
				--disable-selinux \
				--disable-xsmp \
				--disable-xsmp-interact \
				--disable-gtktest \
				--disable-icon-cache-update \
				--disable-desktop-database-update \
				--disable-largefile \
				--disable-canberra \
				--disable-libsodium \
				--disable-acl \
				--disable-sysmouse \
				--disable-nls
			(make || (cd $SRC/vim90/src && make)) && make install
			;;
		avr-toolchain)
			PREFIX=$SPM
			export PREFIX
			PATH=$PATH:$PREFIX/bin
			export PATH
			mkdir $SRC/avr && cd $SRC/avr
			binutils() {
				wget https://ftp.gnu.org/gnu/binutils/binutils-2.44.tar.gz
				tar xfv binutils-2.44.tar.gz
				rm binutils-2.44.tar.gz
				cd binutils-2.44
				mkdir binutils-2.44-avr
				cd binutils-2.44-avr
				../configure \
				 	--prefix=$PREFIX \
					--target=avr \
					--disable-nls \
					--disable-sim \
					--disable-gdb \
					--disable-werror && {
						make $JOBS;
						make install;
					}
			}
			gcc() {
				cd $SRC/avr
				wget https://ftp.cc.uoc.gr/mirrors/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.gz
				tar xfv gcc-14.2.0.tar.gz
				rm gcc-14.2.0.tar.gz
				cd gcc-14.2.0
				./contrib/download_prerequisites
				mkdir gcc-14.2.0-avr
				cd gcc-14.2.0
				../configure \
					--prefix=$PREFIX \
					--target=avr \
					--enable-languages=c \
					--disable-nls \
					--disable-libssp \
					--disable-libcc1 \
					--with-gnu-as \
					--with-gnu-ld \
					--with-dwarf2 && {
						make $JOBS;
						make install-strip;
					}
			}
			avr_libc() {
				cd $SRC/avr
				git clone https://github.com/avrdudes/avr-libc
				cd avr-libc
				./bootstrap
				mkdir avr-libc-2.2.0
				cd avr-libc-2.2.0
				./configure \
					--prefix=$PREFIX \
					--build=$TARGET-pc-linux-gnu \
					--host=avr && {
						make $JOBS;
						make install;
					}
			}
			{ binutils && gcc && avr_libc; } || exit 1
			;;
		diff)
			cd $SRC
			wget https://ftp.gnu.org/gnu/diffutils/diffutils-$DIFF.tar.xz
			tar xfv diffutils-$DIFF.tar.xz
			rm diffutils-$DIFF.tar.xz
			cd diffutils-$DIFF
			./configure \
				--prefix=$SPM \
				--host=$TARGET \
				--enable-threads=isoc+posix \
				--disable-threads && {
					make $JOBS;
					cp src/diff $BIN/diff-$TARGET;
				}
			;;
		tcsh)
			cd $SRC
			wget https://astron.com/pub/tcsh/tcsh-$TCSH.tar.gz
			tar xfv tcsh-$TCSH.tar.gz
			rm tcsh-$TCSH.tar.gz
			cd tcsh-$TCSH
			./configure && {
				make;
				cp tcsh $BIN/tcsh-$TARGET;
				printf "tcsh is not POSIX compliant...\n";
			}
			;;
		jfsutils)
			cd $SRC
			git clone --depth=1 https://github.com/cwuensch/jfsutils
			cd jfsutils
			./configure && \
				make $JOBS
			;;
		squashfs-tools)
			cd $SRC
			git clone --depth=1 https://github.com/plougher/squashfs-tools
			cd squashfs-tools/squashfs-tools
			make $JOBS && {
				cp mksquashfs $BIN/mksquashfs-$TARGET;
				cp unsquashfs $BIN/unsquashfs-$TARGET;
			}
			;;
		iptables)
			cd $SRC
			git clone --depth=1 https://git.netfilter.org/iptables
			cd iptables
			autoreconf -fi
			./configure \
				--enable-static \
				--disable-shared
			make $JOBS
			;;
		grub)
			cd $SRC
			git clone --depth=1 https://git.savannah.gnu.org/git/grub.git
			cd grub
			autoreconf -if
			./configure \
				--build=x86_64-linux-gnu \
				--host=x86_64-linux-gnu \
				--target=arm-linux-gnueabihf \
				--with-platform=efi \
				BUILD_CC=gcc \
				BUILD_PKG_CONFIG=pkg-config \
				HOST_CC=x86_64-linux-gnu-gcc \
				HOST_CFLAGS='-g -O2' \
				PKG_CONFIG=x86_64-linux-gnu-pkg-config \
				TARGET_CC=arm-linux-gnueabihf-gcc \
				TARGET_CFLAGS='-Os -march=armv8.3-a' \
				TARGET_CCASFLAGS='-march=armv8.3-a' \
				TARGET_OBJCOPY=arm-linux-gnueabihf-objcopy \
				TARGET_STRIP=arm-linux-gnueabihf-strip \
				TARGET_NM=arm-linux-gnueabihf-nm \
				TARGET_RANLIB=arm-linux-gnueabihf-ranlib \
				LEX=flex
			make $JOBS
			;;
		pcmciautils)
			cd $SRC
			git clone https://github.com/retroprom/pcmciautils
			cd pcmciautils 
			make && {
				cp pccardctl $BIN/pccardctl;
				cp pcmcia-check-broken-cis $BIN/pcmcia-check-broken-cis;
				cp pcmcia-socket-startup $BIN/pcmcia-socket-startup;
			}
			;;
		shkd)
			cd $SRC
			git clone https://github.com/baskerville/shkd
			cd shkd
			sed -i 's/CC *= *gcc/CC = tcc/' Makefile && {
				sed 's|/usr/local|/opt/spm/bin|g' Makefile;
				make;
				make install;
			}
			;;
		riscv32-gnu)
			cd $SRC
			git clone https://github.com/riscv-collab/riscv-gnu-toolchain
			cd riscv-gnu-toolchain
			./configure \
				--prefix=$CROSS/riscv \
				--with-arch=rv32gc \
				--with-abi=ilp32d
			make linux
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
	case "$GET" in
		toybox)
			case "$TARGET" in
				armv8l)
					cd "$BIN"
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-armv7m
					chmod +x toybox-armv7m
					./toybox
					;;
				x86_64)
					cd "$BIN"
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-x86_64
					chmod +x toybox-x86_64
					./toybox-x86_64
					;;
				x86)
					cd "$BIN"
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-i686
					chmod +x toybox-i686
					./toybox-i686
					;;
				mips)
					cd "$BIN"
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-mips
					chmod +x toybox-mips
					./toybox-mips
					;;
				aarch64)
					cd "$BIN"
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-aarch64
					chmod +x toybox-aarch64
					./toybox-aarch64
					;;
				armv4l)
					cd "$BIN"
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-armv4l
					chmod +x toybox-armv4l
					./toybox-armv4l
					;;
				armv5l)
					cd "$BIN"
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-armv5l
					chmod +x toybox-armv5l
					./toybox-armv5l
					;;
				powerpc)
					cd "$BIN"
					wget https://landley.net/toybox/downloads/binaries/latest/toybox-powerpc
					chmod +x toybox-powerpc
					./toybox-powerpc
					;;
				*)
					printf "unsupported "$TARGET" CPU architecture...\n"
					;;
			esac
			;;
		cross-compiler)
			case $TARGET in
				x86_64)
					cd $CROSS
					wget https://landley.net/toybox/downloads/binaries/toolchains/latest/x86_64-linux-musl-cross.tar.xz
					tar xfv x86_64-linux-musl-cross.tar.xz
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
					tar xfv i686-linux-musl-cross.tar.xz
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
					tar xfv aarch64-linux-musleabi-cross.tar.xz
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
					tar xfv armv7m-linux-musleabi-cross.tar.xz
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
					printf "unsupported $TARGET CPU architecture...\n"
					;;
			esac
			;;
		esp)
			case $TARGET in
				x86_64)
					cd /opt
					wget https://dl.espressif.com/dl/xtensa-lx106-elf-gcc8_4_0-esp-2020r3-linux-amd64.tar.gz
					tar xfv xtensa-lx106-elf-gcc8_4_0-esp-2020r3-linux-amd64.tar.gz
					rm xtensa-lx106-elf-gcc8_4_0-esp-2020r3-linux-amd64.tar.gz
					export PATH=$PATH:/opt/xtensa-lx106-elf/bin
					;;
				i686)
					cd /opt
					wget https://dl.espressif.com/dl/xtensa-lx106-elf-gcc8_4_0-esp-2020r3-linux-i686.tar.gz
					tar xfv xtensa-lx106-elf-gcc8_4_0-esp-2020r3-linux-i686.tar.gz
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
					tar xfv cross-compiler-armv6l.tar.gz
					rm cross-compiler-armv6l.tar.gz
					ls -la cross-compiler-armv6l
					;;
				x86_64)
					cd $CROSS
					wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-x86_64.tar.gz
					tar xfv cross-compiler-x86_64.tar.gz
					rm cross-compiler-x86_64.tar.gz
					ls -la cross-compiler-x86_64
					;;
				i686)
					cd $CROSS
					wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-i686.tar.gz
					tar xfv cross-compiler-i686.tar.gz
					rm cross-compiler-i686.tar.gz
					ls -la cross-compiler-i686
					;;
				arm4tl)
					cd $CROSS
					wget https://landley.net/aboriginal/downloads/binaries/cross-compiler-armv4tl.tar.gz
					tar xfv cross-compiler-armv4tl.tar.gz
					rm cross-compiler-armv4tl.tar.gz
					ls -la cross-compiler-armv4tl
					;;
				*)
					printf "unsupported architecture: $TARGET\n"
					;;
			esac
			;;
		native-compiler)
			case $TARGET in
				i686)
					cd $NATIVE
					wget https://landley.net/toybox/downloads/binaries/toolchains/latest/i686-linux-musl-native.sqf
					#mount -t squashfs -o loop i686-linux-musl-native.sqf $MNT
					unsquashfs i686-linux-musl-native.sqf
					rm i686-linux-musl-native.sqf
					mv squashfs-root/* . && rm -r squashfs-root
					cd bin && ./gcc -v
					;;
				i486)
					cd $NATIVE
					wget https://landley.net/toybox/downloads/binaries/toolchains/latest/i486-linux-musl-native.sqf
					unsquashfs i486-linux-musl-native.sqf
					rm i486-linux-musl-native.sqf
					mv squashfs-root/* . && rm -r squashfs-root
					cd bin && ./gcc -v
					;;
				x86_64)
					cd $NATIVE
					wget https://landley.net/toybox/downloads/binaries/toolchains/latest/x86_64-linux-musl-native.sqf
					unsquashfs x86_64-linux-musl-native.sqf
					rm x86_64-linux-musl-native.sqf
					mv squashfs-root/* . && rm -r squashfs-root
					cd bin && ./gcc -v
					;;
				armv8l)
					cd $NATIVE
					wget https://landley.net/toybox/downloads/binaries/toolchains/latest/armv7l-linux-musleabihf-native.sqf
					unsquashfs armv7l-linux-musleabihf-native.sqf
					rm armv7l-linux-musleabihf-native.sqf
					mv squashfs-root/* . && rm -r squashfs-root
					cd bin && ./gcc -v
					;;
				aarch64)
					cd $NATIVE
					wget https://landley.net/toybox/downloads/binaries/toolchains/latest/aarch64-linux-musleabi-native.sqf
					unsquashfs aarch64-linux-musleabi-native.sqf
					rm aarch64-linux-musleabi-native.sqf
					mv squashfs-root/* . && rm -r squashfs-root
					cd bin && ./gcc -v
					;;
				mips)
					cd $NATIVE
					wget https://landley.net/toybox/downloads/binaries/toolchains/latest/mips-linux-musl-native.sqf
					unsquashfs mips-linux-musl-native.sqf
					rm mips-linux-musl-native.sqf
					mv squashfs-root/* . && rm -r squashfs-root
					cd bin && ./gcc -v
					;;
				*)
					printf "unsupported architecture: $TARGET\n"
					;;
			esac
			;;
		mkroot)
			cd $USR
			wget https://landley.net/toybox/downloads/binaries/mkroot/latest/$TARGET.tgz && {
					tar xfv $TARGET.tgz;
					rm $TARGET.tgz;
					cat $TARGET/docs/README;
				} || {
					printf "unsupported architecture: '$TARGET'\n";
					exit 1;
				}
			;;
		*)
			printf "unsupported command: '$GET'\n"
			fusage
			;;
	esac
}

fdelete_bin() {
	printf "you will delete all the bin's in $BIN $CROSS $NATIVE\n"
	printf "are you sure? (yes/no)\n"
	read -r RSP
	case $RSP in
		[y]* )
			rm -r $BIN/*
			printf "$BIN deleted...\n"
			rm -r $CROSS/*
			printf "$CROSS deleted...\n"
			rm -r $NATIVE/*
			printf "$NATIVE deleted...\n"
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
			cd $SRC/toolbox && {
				sed -i 's|/opt/spm/src/toolbox|/home/src/1v4n/toolbox|g' toolbox.c;
				git pull;
				sed -i 's|/home/src/1v4n/toolbox|/opt/spm/src/toolbox|g' toolbox.c;
				make $JOBS;
				cp toolbox $BIN/toolbox-$TARGET;
			}
			;;
		dash)
			cd $SRC/dash && {
				git pull;
				make $JOBS;
				cp dash $BIN/dash-$TARGET;
			}
			;;
		tinycc)
			cd $SRC/tinycc && {
				git pull;
				./configure \
					--prefix=$DIR \
					--bindir=$BIN \
					--libdir=$LIB \
					--includedir=$INC \
					--source-path=$SRC/tinycc \
					--cc=tcc \
					--disable-static \
					--enable-cross;
				make $JOBS;
				make install;
			}
			;;
		esolangs)
			cd $SRC/esolangs && {
				git pull;
				make $JOBS;
				cp brainf $BIN/brainf-$TARGET;
				cp whitespace $BIN/whitespace-$TARGET;
			}
			;;
		dash)
			cd $SRC/dash && {
				git pull;
				make $JOBS;
				cp dash $BIN/dash-$TARGET;
			}
			;;
		nmap)
			cd $SRC/nmap && \
				git diff --name-only HEAD origin/main -- $CFG > /tmp/before.txt && \
				git pull && \
				git diff --name-only HEAD@{1} HEAD -- $CFG > /tmp/after.txt
				[ -s /tmp/config_changes_after.txt ] && {
					printf "running ./configure...\n"
					./configure
				} || printf "no configuration changes detected...\n"
				rm -f /tmp/before.txt /tmp/after.txt
				make $JOBS && \
					cp nmap $BIN/nmap-$TARGET
			;;
		kexec)
			cd $SRC/kexec-tools
			git pull && \
				./bootstrap && \
				./configure && \
				make $JOBS && \
				cp build/sbin/* $SBIN
			;;
		interceptor)
			cd $SRC/interceptor && \
				git pull && \
				make && \
				cp intercept.so $LIB && \
				printf "usage: LD_PRELOAD=$LIB/intercept.so /bin/brave\n"
			;;
		smartmontools)
			cd $SRC/smartmontools && \
				svn update && \
				./autogen.sh && \
				./configure && \
				make $JOBS && \
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
