#!/bin/sh
#the script cross compiles Das U-Boot bootloader, Linux kernel and ARM based Debian rootfs for the Wandboard WB-EDm-iMX6

set -x

#set vars
export DIR=/home/src/wandboard
export DISK=/dev/mmcblk0
export TARGET=arm

#create and go to work directory
mkdir $DIR
cd $DIR

#get and test the Linaro ARM GCC cross compiler
wget -c https://releases.linaro.org/components/toolchain/binaries/6.5-2018.12/arm-linux-gnueabihf/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz
tar xf gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz
export CC=`pwd`/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
${CC}gcc --version

#get, patch, configure and build Das U-boot bootloader
git clone -b v2019.04 https://github.com/u-boot/u-boot --depth=1
cd u-boot/
wget -c https://github.com/eewiki/u-boot-patches/raw/master/v2019.04/0001-wandboard-uEnv.txt-bootz-n-fixes.patch
patch -p1 < 0001-wandboard-uEnv.txt-bootz-n-fixes.patch
make ARCH=$TARGET CROSS_COMPILE=${CC} distclean
make ARCH=$TARGET CROSS_COMPILE=${CC} wandboard_defconfig
make ARCH=$TARGET CROSS_COMPILE=${CC}

#build the kernel modules device tree binaries and copy them to the deploy directory
git clone https://github.com/RobertCNelson/armv7-multiplatform ./kernelbuildscripts
cd kernelbuildscripts/
git checkout origin/v5.15.x-rt -b tmp
./build_kernel.sh

#get the rootfs
wget -c https://rcn-ee.com/rootfs/eewiki/minfs/debian-11.3-minimal-armhf-2022-04-15.tar.xz
tar xf debian-11.3-minimal-armhf-2022-04-15.tar.xz

#setup the SD card
sudo dd if=/dev/zero of=${DISK} bs=1M count=10
sudo dd if=./u-boot/SPL of=${DISK} seek=1 bs=1k
sudo dd if=./u-boot/u-boot.img of=${DISK} seek=69 bs=1k
sfdisk ${DISK} <<-__EOF__
1M,,L,*
__EOF__
sudo mkfs.ext4 -L rootfs ${DISK}p1
sudo mkfs.ext4 -L rootfs ${DISK}1
mkdir -p /media/rootfs/
mount ${DISK}p1 /media/rootfs/
mount ${DISK}1 /media/rootfs/

#install the kernel and rootfs
export kernel_version=5.X.Y-Z
tar xfvp ./*-*-*-armhf-*/armhf-rootfs-*.tar -C /media/rootfs/
sync
sh -c "echo 'uname_r=${kernel_version}' >> /media/rootfs/boot/uEnv.txt"
sh -c "echo 'cmdline=video=HDMI-A-1:1024x768@60e' >> /media/rootfs/boot/uEnv.txt"
cp -v ./kernelbuildscripts/deploy/${kernel_version}.zImage /media/rootfs/boot/vmlinuz-${kernel_version}
mkdir -p /media/rootfs/boot/dtbs/${kernel_version}/
tar xfv ./kernelbuildscripts/deploy/${kernel_version}-dtbs.tar.gz -C /media/rootfs/boot/dtbs/${kernel_version}/
tar xfv ./kernelbuildscripts/deploy/${kernel_version}-modules.tar.gz -C /media/rootfs/
sh -c "echo '/dev/mmcblk2p1  /  auto  errors=remount-ro  0  1' >> /media/rootfs/etc/fstab"
wget -c https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/plain/brcm/brcmfmac4329-sdio.bin
wget -c https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/plain/brcm/brcmfmac4330-sdio.bin
wget -c https://rcn-ee.com/repos/git/meta-fsl-arm-extra/recipes-bsp/broadcom-nvram-config/files/wandboard/brcmfmac4329-sdio.txt
wget -c https://rcn-ee.com/repos/git/meta-fsl-arm-extra/recipes-bsp/broadcom-nvram-config/files/wandboard/brcmfmac4330-sdio.txt
mkdir -p /media/rootfs/lib/firmware/brcm/
cp -v ./brcmfmac43*-sdio.bin /media/rootfs/lib/firmware/brcm/
cp -v ./brcmfmac43*-sdio.txt /media/rootfs/lib/firmware/brcm/
dmesg | grep brcm
/sbin/ifconfig -a
sync
sudo umount /media/rootfs
echo "done..."
