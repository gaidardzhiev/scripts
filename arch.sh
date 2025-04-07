#!/bin/sh
#the script determines the type of CPU architecture that is running on and prints the appropriate value

ARCH=$(grep -m 1 'model name' /proc/cpuinfo | awk -F ': ' '{print $2}' | awk '{print $1}')

printf "$ARCH\n"

exit 0

#case `uname -m` in
#"ARMv7")
#	ARCH=armv7l
#	;;
#"ARMv8")
#	ARCH=armv8l
#	;;
#"x86_64")
#	ARCH=x86_64
#	;;
#"mips")
#	ARCH=mips
#	;;
#"i686")
#	ARCH=x86
#;;
#"alpha")
#	ARCH=alpha
#	;;
#"nios2")
#	ARCH=nios2
#	;;
#"hexagon")
#	ARCH=hexagon
#	;;
#"openrisc")
#	ARCH=openrisc
#	;;
#"riscv")
#	ARCH=riscv
#	;;
#"sparc")
#	ARCH=sparc
#	;;
#"microblaze")
#	ARCH=microblaze
#	;;
#*)
#	printf "unknown platform\n" >&2
#exit 1
#esac
#printf "$ARCH\n"
#exit 0
