#!/bin/sh
#the script creates an ARM debian filesystem image on an x86_64 arch Linux host and croots in it

fimg() {
	export DIR="/home/mnt"
	export VER="sid"
	mkdir -p "${DIR}"
	dd if=/dev/zero of=/home/arm_debian_fs.img bs=512 count=5400000
	mkfs.ext4 /home/arm_debian_fs.img
	mount -o loop /home/arm_debian_fs.img "${DIR}" && return 0 || return 2
}

fdep() {
	pacman -S \
		--noconfirm \
		qemu-user-static \
		qemu-user-static-binfmt \
		debootstrap && return 0 || return 3
}

fstrap() {
	debootstrap --foreign --arch armel "${VER}" "${DIR}"
	cp /usr/bin/qemu-arm-static "${DIR}/usr/bin"
	DEBIAN_FRONTEND=noninteractive \
	DEBCONF_NONINTERACTIVE_SEEN=true \
	LC_ALL=C \
	LANGUAGE=C \
	LANG=C \
	chroot "${DIR}" /debootstrap/debootstrap --second-stage
	DEBIAN_FRONTEND=noninteractive \
	DEBCONF_NONINTERACTIVE_SEEN=true \
	LC_ALL=C \
	LANGUAGE=C \
	LANG=C \
	chroot "${DIR}" dpkg --configure -a && return 0 || return 4
}

fchroot() {
	printf "welcome to the chroot...\n"
	chroot "${DIR}" bash && return 0 || return 5
}

{ fimg && fdep && fstrap && fchroot; RET="${?}"; } || { 
	printf "something's wrong in here somewhere...\n";
	exit 1;
}

[ "${RET}" -eq 0 ] 2>/dev/null || printf "%s\n" "${RET}"
