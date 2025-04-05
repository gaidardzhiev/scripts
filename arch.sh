#!/bin/sh
#the script determines the type of CPU architecture that is running on and echo the appropriate value

case `uname -m` in
"armv7l")
	ARCH=armv7l
	;;
"armv8l")
	ARCH=armv8l
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
	printf "unknown platform\n" >&2
exit 1
esac

printf "$ARCH\n"

exit 0
