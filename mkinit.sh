#!/bin/sh
#the script creates a minimal initramfs based on toybox

INIT="initramfs.cpio.gz"
DIR=$(mktemp -d)
TARGET=$(uname -m)
ARCH="armv7m" && [ "$TARGET" = "armv8l" ] || ARCH="$TARGET"

mkdir -p $DIR/bin
mkdir -p $DIR/dev
mkdir -p $DIR/etc
mkdir -p $DIR/proc
mkdir -p $DIR/sys
mkdir -p $DIR/lib
mkdir -p $DIR/lib64
mkdir -p $DIR/mnt/root
mkdir -p $DIR/root
mkdir -p $DIR/sbin
mkdir -p $DIR/run
mkdir -p $DIR/usr
wget https://landley.net/toybox/downloads/binaries/latest/toybox-$ARCH
chmod +x toybox-$ARCH
mv toybox-$ARCH $DIR/bin/toybox
$DIR/bin/toybox
cat << eof > $DIR/init
#!/bin/toybox
mount -t devtmpfs none /dev
mount -t proc proc none /proc
mount -t sysfs sysfs none /sys
exec /bin/toybox toysh
eof
chmod +x $DIR/init
mknod $DIR/dev/sda b 8 0
mknod $DIR/dev/console c 5 1
find $DIR | cpio -H newc -o | gzip > $INIT
rm -rf $DIR
printf "\n\ninitramfs for $ARCH created successfully: $INIT\n"
