#!/bin/sh
#wrapper script for launching plan9 in qemu

disk=$1 && shift
if [ $(uname -s) = Linux ]; then
	kvm=-enable-kvm
fi
flags="-cdrom $disk -vga std"
qemu-system-x86_64 $kvm -m 4G $flags $*
