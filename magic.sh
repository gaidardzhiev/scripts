#!/bin/sh
#read the first 16 bytes of a file in hex and ASCII for magic signature file inspection

z()
{
	exec 3< "$1" || { echo "error opening file"; return; }
#	x=$(dd if=/dev/fd/3 bs=1 count=16 2>/dev/null) || { echo "error reading file"; return; }
	x=$(dd if=/dev/fd/3 bs=1 count=16 2>/dev/null | hexdump -v -e '/1 "%02X "' || { echo "error reading file"; return; })
	echo -n "magic signature bytes: "
	i=0
	while [ $i -lt 16 ];
	do
		printf "%02X " "'${x:$i:1}"
		i=$((i + 1))
	done
	printf "\n"
	echo -n "human readable ASCII: "
	i=0
	while [ $i -lt 16 ];
	do
		c="${x:$i:1}"
		case "$c" in
			[[:print:]]) printf "%s" "$c" ;;
			*) printf "." ;;
		esac
		i=$((i + 1))
	done
	printf "\n"
	exec 3<&-
}

if [ $# -ne 1 ]; then
echo "usage: $0 <file>" >&2
exit 1
fi

z "$1"
