#!/bin/sh
#custom arch linux build

export DIR=~/arch_build
export HASH=~/openssl_user_passwd_hash

set -x

pacman -S archiso openssl

mkdir $DIR

cp -r /usr/share/archiso/configs/baseline/* $DIR

pacman -Q \
	| awk '{print $1}' \
	| sort -n > $DIR/packages.x86_64

cat > $DIR/airootfs/etc/passwd << EOF
root:x:0:0:root:/root:/usr/bin/zsh
user:x:1000:1000::/home/user:/usr/bin/zsh
EOF

openssl passwd -6 \
	| tee >(tail -n 1 > ~/$HASH)

cat $HASH \
	| tee -a $DIR/airootfs/etc/shadow

