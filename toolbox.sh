#!/bin/sh

DIR=/home/src/1v4n/tools
REPO=https://github.com/gaidardzhiev/tools
CMD=$1

if [ ! -d "$DIR" ]; then
	cd /home/src/1v4n/
	git clone $REPO
	cd tools
	make
else
	printf "\n" > /dev/null
fi

fusage() {
	echo "usage: $0 <echo|cat|cp|basename|kill|ln|mount|nice|printf|rev|sleep|sync|tee|touch|tr|true|tty|umount|wc|yes|shell|pwd|ps|grep|du|rm|ascii2hex|hexdump|false|replace|readelf|strings|ls> <options>"
	exit 1
}

if [ $# -lt 1 ]; then
	fusage
fi

shift

case $CMD in
	echo)
		$DIR/echo "$@"
		;;
	cat)
		$DIR/cat "$@"
		;;
	cp)
		$DIR/cp "$@"
		;;
	basename)
		$DIR/basename "$@"
		;;
	kill)
		$DIR/kill "$@"
		;;
	ln)
		$DIR/ln "$@"
		;;
	mount)
		$DIR/mount "$@"
		;;
	nice)
		$DIR/nice "$@"
		;;
	printf)
		$DIR/printf "$@"
		;;
	rev)
		$DIR/rev "$@"
		;;
	sleep)
		$DIR/sleep "$@"
		;;
	sync)
		$DIR/sync "$@"
		;;
	tee)
		$DIR/tee "$@"
		;;
	touch)
		$DIR/touch "$@"
		;;
	tr)
		$DIR/tr "$@"
		;;
	true)
		$DIR/true "$@"
		;;
	tty)
		$DIR/tty "$@"
		;;
	umount)
		$DIR/umount "$@"
		;;
	wc)
		$DIR/wc "$@"
		;;
	yes)
		$DIR/yes "$@"
		;;
	shell)
		$DIR/shell "$@"
		;;
	pwd)
		$DIR/pwd "$@"
		;;
	ps)
		$DIR/ps "$@"
		;;
	grep)
		$DIR/grep "$@"
		;;
	du)
		$DIR/du "$@"
		;;
	rm)
		$DIR/rm "$@"
		;;
	ascii2hex)
		$DIR/ascii2hex "$@"
		;;
	hexdump)
		$DIR/hexdump "$@"
		;;
	false)
		$DIR/false "$@"
		;;
	replace)
		$DIR/replace "$@"
		;;
	readelf)
		$DIR/readelf "$@"
		;;
	strings)
		$DIR/strings "$@"
		;;
	ls)
		$DIR/ls "$@"
		;;
	*)
		echo "unsupported command: '$CMD'"
		fusage
		;;
esac
