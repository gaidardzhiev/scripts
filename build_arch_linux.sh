#!/bin/sh
#custom arch linux build

export DIR=/root/arch_build
export HASH=/root/hash
export USER_HASH=/root/user_hash

set -x
mkdir $DIR
pacman -S archiso openssl
cp -r /usr/share/archiso/configs/baseline/* $DIR
touch $HASH
touch $USER_HASH

pacman -Q \
	| awk '{print $1}' \
	| sort -n > $DIR/packages.x86_64

cat > $DIR/airootfs/etc/passwd << EOF
root:x:0:0:root:/root:/usr/bin/zsh
user:x:1000:1000::/home/user:/usr/bin/zsh
EOF

openssl passwd -6 \
	| tee >(tail -n 1 > $HASH)

sed -e 's|^|user:|; s|$|::::::|' $HASH > $USER_HASH

cat $USER_HASH \
	| tee -a $DIR/airootfs/etc/shadow

rm $HASH $USER_HASH

touch /root/arch_build/airootfs/etc/gshadow
cat > /root/arch_build/airootfs/etc/gshadow << EOF
root:!*::root
user:!*::
EOF


