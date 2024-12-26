#!/bin/sh
#read the first 16 bytes of a file in hex and ascii for magic signature file inspection

z()
{
	exec 3< "$1" || { echo "error opening file"; return; }
	read -n 16 -u 3 x
	echo -n "magic signature bytes: "
	i=0
	  while [ $i -lt 16 ];
	do
		printf "%02X " "'${x:i:1}"
		i=$((i + 1))
		  done
		  echo -n "human readable ASCII: "
		  i=0
		    while [ $i -lt 16 ];
	do
		c="${x:i:1}"
	     case "$c" in
			     [[:print:]]) printf "%s" "$c" ;;
			*) printf "." ;;
			esac
			i=$((i + 1))
			  done
			  echo
			  exec 3<&-
		}

if [ $# -ne 1 ]; then
echo "usage: $0 <file>" >&2
exit 1
fi

z "$1"
