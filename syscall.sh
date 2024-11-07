#!/bin/sh
 
set -xe
 
export DIR=/home/src/1v4n/syscall
export VER=$(uname -r | cut -d '-' -f1)
export TABLE=arch/x86/entry/syscalls/syscall_64.tbl
export SYS=kernel/sys.c
export GETNUMCPUS=`grep -c '^processor' /proc/cpuinfo`
export JOBS='-j '$GETNUMCPUS''
export SUFFIX="-V4N"
 
before(){
mkdir -p $DIR
cd $DIR
wget https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/linux-$VER.tar.xz
tar xf linux-$VER.tar.xz
cd linux-$VER
zcat /proc/config.gz > .config
sed -i 's/CONFIG_LOCALVERSION=""/CONFIG_LOCALVERSION="-V4N"/g' .config
sed -i '381i 457        common  print_kernel sys_print_kernel' $TABLE
echo "SYSCALL_DEFINE1(print_kernel, char *, msg)
{
        char buf[256];
        long copied = strncpy_from_user(buf, msg, sizeof(buf));
        if (copied < 0 || copied == sizeof(buf))
        return -EFAULT;
        printk(KERN_INFO "print_kernel syscall called with \"%s\"\n", buf);
        return 0;
}" >> $DIR/linux-$VER/$SYS
make $JOBS
make modules_install
cp arch/x86_64/boot/bzImage /boot/vmlinuz-linux$SUFFIX
sed s/linux/linux$SUFFIX/g \
</etc/mkinitcpio.d/linux.preset \
>/etc/mkinitcpio.d/linux$SUFFIX.preset
mkinitcpio -p linux$SUFFIX
grub-mkconfig -o /boot/grub/grub.cfg
kexec -l /boot/vmlinuz-linux$SUFFIX \
    --initrd=/boot/initramfs-linux.img \
    --resuse-cmdline
kexec -e
}
 
after(){
cd $DIR
touch test.c
cat > $DIR/test.c << EOF
#define _GNU_SOURCE
#include <unistd.h>
#include <sys/syscall.h>
#include <stdio.h>
 
#define SYS_print_kernel 457
 
int main(int argc, char **argv)
{
  if (argc <= 1) {
    printf("provide me a string to give to system call...\n");
    return -1;
}
  char *arg = argv[1];
  printf("making system call with \"%s\".\n", arg);
  long res = syscall(SYS_print_kernel, arg);
  printf("system call returned %ld.\n", res);
  return res;
}"
EOF
gcc test.c -o the_test
./the_test 'this is a test'
if dmesg | tail -n 1 | grep -q 'print_kernel syscall'; then
        echo 'success'
else
        echo 'error'
fi
}
 
if ! uname -r | grep -q '$SUFFIX'
then
        before
        after
fi
