#!/bin/sh
#wrapper script for launching plan9 in qemu

disk=$1 && shift

[ $(uname -s) = Linux ] && kvm=-enable-kvm

flags="-cdrom $disk -vga std"

qemu-system-x86_64 $kvm -m 4G $flags $*
