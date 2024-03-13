#!/bin/sh

set -xe

export DIR=/home/src/1v4n/syscall
export VER=$(uname -r | cut -d '-' -f1)
export TABLE=arch/x86/entry/syscalls/syscall_64.tbl
export SYS=kernel/sys.c
export GETNUMCPUS=`grep -c '^processor' /proc/cpuinfo`
export JOBS='-j '$GETNUMCPUS''
export SUFFIX="-V4N"

mkdir -p $DIR
cd $DIR
wget https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/linux-$VER.tar.xz
tar xf linux-$VER.tar.xz
cd linux-$VER
zcat /proc/config.gz > .config
sed -i 's/CONFIG_LOCALVERSION=""/CONFIG_LOCALVERSION="-V4N"/g' .config
sed -i '381i 457	common	print_kernel		sys_print_kernel' $TABLE
echo "SYSCALL_DEFINE1(print_kernel, char *, msg)
{
  char buf[256];
  long copied = strncpy_from_user(buf, msg, sizeof(buf));
  if (copied < 0 || copied == sizeof(buf))
    return -EFAULT;
  printk(KERN_INFO " \"%s\"\n", buf);
  return 0;
}" >> $DIR/linux-$VER/$SYS
make
make modules_install
cp arch/x86_64/boot/bzImage /boot/vmlinuz-linux$SUFFIX
sed s/linux/linux$SUFFIX/g \
    </etc/mkinitcpio.d/linux.preset \
    >/etc/mkinitcpio.d/linux$SUFFIX.preset
mkinitcpio -p linux$SUFFIX
grub-mkconfig -o /boot/grub/grub.cfg
