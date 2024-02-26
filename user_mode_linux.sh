#!/bin/bash

SSH=~/.ssh/id_ed25519
SLIRP=~/.slirprc
DIR=$HOME/src/uml
export TMPDIR=/tmp

if ! [ -f "$SSH" ]
then
    ssh-keygen -t ed25519 -N "$1" -f $SSH
fi
mkdir -p $DIR
cd $DIR
wget https://deb.debian.org/debian/pool/main/u/user-mode-linux/user-mode-linux_5.10um3+b1_amd64.deb
ar x user-mode-linux_5.10um3+b1_amd64.deb
rm      user-mode-linux_5.10um3+b1_amd64.deb \
        control.tar.xz \
        debian-binary
tar -xf data.tar.xz
rm data.tar.xz
mv usr/bin/linux.uml .
mv usr/lib/uml/modules .
rm -r usr
if ! [ -f "$SLIRP" ]
then
        echo "redir tcp 2222 22" > $SLIRP
fi
wget -O debian.img https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-nocloud-amd64.raw
truncate -s 8G debian.img
./linux.uml \
    mem=1024M \
    root=/dev/ubda1 rw \
    ubd0=debian.img \
    systemd.unit=emergency.target
sed '/boot\/efi/d' -i /etc/fstab
cat >launch.sh <<-'EOF'
#! /bin/sh
cd "$(dirname "$0")" || exit
export TMPDIR=/tmp
exec ./linux.uml mem=1024M root=/dev/ubda1 ubd0=debian.img eth0=slirp,52:54:00:00:01,/usr/bin/slirp-fullbolt
EOF
chmod +x launch.sh
cat << EOF
echo "none /lib/modules/$(uname -r) hostfs /sec/root/uml/modules/$(uname -r) 0 2" >>/etc/fstab
mkdir -p /lib/modules/$(uname -r)
echo "none /mnt/host-fs hostfs / 0 2" >>/etc/fstab
mkdir -p /mnt/host-fs
ln -s /mnt/host-fs/sec /sec
systemctl mask systemd-binfmt.service
systemctl disable getty@tty1
systemctl enable getty@tty0
ssh-keygen -A
cat > /etc/netplan/90-default.yaml <<-'EOF'
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses: [10.0.2.15/24]
      routes:
        - to: default
          via: 10.0.2.2
          on-link: true
      nameservers:
        addresses: [10.0.2.3]
'EOF'
growpart /dev/ubda 1
resize2fs /dev/ubda1
systemctl daemon-reload
mount /mnt/host-fs
cp /mnt/host-fs/root/.ssh/id_ed25519.pub ~/.ssh/authorized_keys
poweroff
EOF
