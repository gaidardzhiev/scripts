#!/bin/sh
#the script determines the type of CPU architecture that is running on and prints the appropriate value

ARCH=$(grep -m 1 'model name' /proc/cpuinfo | awk -F ': ' '{print $2}' | awk '{print $1}')

printf "$ARCH\n" && exit 0 || exit 1
