#!/bin/sh
#the scripts creates ARM debian filesystem image on x86_64 arch linux host

export DIR="/home/mnt"
export VER="sid"

mkdir $DIR

dd if=/dev/zero of=/home/arm_debian_fs.img bs=512 count=5400000

mkfs.ext4 /home/arm_debian_fs.img

mount -o loop /home/arm_debian_fs.img $DIR

pacman -S qemu-user-static qemu-user-static-binfmt debootstrap

debootstrap --foreign --arch armel $VER $DIR

cp /usr/bin/qemu-arm-static /home/mnt/usr/bin

DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C \
	LANGUAGE=C LANG=C chroot $DIR /debootstrap/debootstrap --second-stage

DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C \
	LANGUAGE=C LANG=C chroot $DIR dpkg --configure -a

echo "welcome to the chroot"

chroot $DIR bash
