#!/bin/sh
#the script creates an ARM debian filesystem image on an x86_64 arch Linux host and croots in it

create_image() {
	export DIR="/home/mnt"
	export VER="sid"
	mkdir -p "$DIR"
	dd if=/dev/zero of=/home/arm_debian_fs.img bs=512 count=5400000
	mkfs.ext4 /home/arm_debian_fs.img
	mount -o loop /home/arm_debian_fs.img "$DIR"
}

install_dependencies() {
	pacman -S --noconfirm qemu-user-static qemu-user-static-binfmt debootstrap
}

bootstrap_debian() {
	debootstrap --foreign --arch armel "$VER" "$DIR"
	cp /usr/bin/qemu-arm-static "$DIR/usr/bin"
	DEBIAN_FRONTEND=noninteractive \
	DEBCONF_NONINTERACTIVE_SEEN=true \
	LC_ALL=C \
	LANGUAGE=C \
	LANG=C \
	chroot "$DIR" /debootstrap/debootstrap --second-stage
	DEBIAN_FRONTEND=noninteractive \
	DEBCONF_NONINTERACTIVE_SEEN=true \
	LC_ALL=C \
	LANGUAGE=C \
	LANG=C \
	chroot "$DIR" dpkg --configure -a
}

enter_chroot() {
	printf "welcome to the chroot...\n"
	chroot "$DIR" bash
}

create_image && install_dependencies && bootstrap_debian && enter_chroot || printf "something's wrong in here somewhere...\n"
