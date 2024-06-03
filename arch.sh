#!/bin/sh
#the script determines the type of CPU architecture that is running on and echo the appropriate value

case `uname -m` in
"armv7l")
	ARCH=armv7l
	;;
"x86_64")
	ARCH=x86_64
	;;
"mips")
	ARCH=mips
	;;
"i686")
	ARCH=x86
	;;
"alpha")
	ARCH=alpha
	;;
"nios2")
	ARCH=nios2
	;;
"hexagon")
	ARCH=hexagon
	;;
"openrisc")
	ARCH=openrisc
	;;
"riscv")
	ARCH=riscv
	;;
"sparc")
	ARCH=sparc
	;;
"microblaze")
	ARCH=microblaze
	;;
*)
	echo "unknown platform" >&2
exit 1
esac
echo $ARCH
exit 0
