#!/bin/sh
#custom arch linux build

export DIR=/root/arch
export HASH=/root/hash
export USER_HASH=/root/user_hash

set -x
mkdir $DIR
pacman -S archiso openssl
cp -r /usr/share/archiso/configs/releng/ $DIR
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

touch /root/arch/airootfs/etc/gshadow
cat > /root/arch/airootfs/etc/gshadow << EOF
root:!*::root
user:!*::
EOF

cat <<'EOF' >> /root/arch/profiledef.sh
!/usr/bin/env bash
# shellcheck disable=SC2034
iso_name="1v4n_arch_linux"
iso_label="1v4n_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="1v4n <https://github.com/gaidardzhiev>"
iso_application="Arch Linux Live/Rescue CD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-ia32.grub.esp' 'uefi-x64.grub.esp'
           'uefi-ia32.grub.eltorito' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)
EOF

#mkarchiso -v -w $DIR/work -o $DIR/out $DIR
