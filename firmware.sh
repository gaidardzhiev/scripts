#!/bin/sh
#unpack/pack firmware

unpack() {
	exec 3< "$1"
	for part in "uimage_header:0:64" "uimage_kernel:64:2097152" "squashfs_1:2097152:350000" "squashfs_2:550040:65536" "jffs2:5f0040:11075648"; do
		IFS=':' read -r name offset size <<< "$part"
		exec 4> "$name"
		dd if=/dev/fd/3 bs=1 skip="$offset" count="$size" of=/dev/fd/4
		exec 4>&-
		echo "wrote $name - $(printf '%#x' $(stat -c%s "$name")) bytes"
	done
	exec 3<&-
}

pack() {
	exec 3> "$1"
	for part in "uimage_kernel" "squashfs_1" "squashfs_2" "jffs2"; do
		exec 4< "$part"
		size=$(stat -c%s "$part")
		dd if=/dev/fd/4 of=/dev/fd/3 bs=1 count="$size"
		padding=$(( $(echo "$size" | awk '{print $1}') - $(stat -c%s "$part") ))
		echo "wrote $part - $(printf '%#x' "$size") bytes"
		echo "padding: $(printf '%#x' "$padding")"
		printf '\0%.0s' $(seq 1 "$padding") >> "$1"
		exec 4<&-
	done
	exec 3>&-
}

usage() {
	echo "usage: $0 <pack|unpack> <file>"
	exit 1
}

if [ $# -ne 2 ]; then
	usage
fi

case "$1" in
	unpack)
		unpack "$2" || { echo "failed to unpack $2"; exit 1; }
		;;
	pack)
		pack "$2" || { echo "failed to pack $2"; exit 1; }
		;;
	*)
		usage
		;;
esac
