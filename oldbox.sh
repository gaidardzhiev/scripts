#!/bin/sh

DIR=/home/src/1v4n/oldbox
REPO=https://github.com/gaidardzhiev/oldbox
CMD=$1

fdir() {
	[ ! -d "$DIR" ] && {
		cd /home/src/1v4n/;
		git clone $REPO;
		cd oldbox;
		make;
	} || return 0
}

fusage() {
	printf "usage: $0 <echo|cat|cp|basename|kill|ln|mount|nice|printf|rev|sleep|sync|tee|touch|tr|true|tty|umount|wc|yes|shell|pwd|ps|grep|du|rm|ascii2hex|hexdump|false|replace|readelf|strings|ls|xoda|cc|id|cmp|tree|kmsg|file|magic|mem|test|clear|lsblk|systrace> <options>\n"
	exit 1
}

{ [ $# -lt 1 ] && fusage; fdir; }

shift

case "$CMD" in
	echo)
		"$DIR"/echo "$@"
		;;
	cat)
		"$DIR"/cat "$@"
		;;
	cp)
		"$DIR"/cp "$@"
		;;
	basename)
		"$DIR"/basename "$@"
		;;
	kill)
		"$DIR"/kill "$@"
		;;
	ln)
		"$DIR"/ln "$@"
		;;
	mount)
		"$DIR"/mount "$@"
		;;
	nice)
		"$DIR"/nice "$@"
		;;
	printf)
		"$DIR"/printf "$@"
		;;
	rev)
		"$DIR"/rev "$@"
		;;
	sleep)
		"$DIR"/sleep "$@"
		;;
	sync)
		"$DIR"/sync "$@"
		;;
	tee)
		"$DIR"/tee "$@"
		;;
	touch)
		"$DIR"/touch "$@"
		;;
	tr)
		"$DIR"/tr "$@"
		;;
	true)
		"$DIR"/true "$@"
		;;
	tty)
		"$DIR"/tty "$@"
		;;
	umount)
		"$DIR"/umount "$@"
		;;
	wc)
		"$DIR"/wc "$@"
		;;
	yes)
		"$DIR"/yes "$@"
		;;
	shell)
		"$DIR"/shell "$@"
		;;
	pwd)
		"$DIR"/pwd "$@"
		;;
	ps)
		"$DIR"/ps "$@"
		;;
	grep)
		"$DIR"/grep "$@"
		;;
	du)
		"$DIR"/du "$@"
		;;
	rm)
		"$DIR"/rm "$@"
		;;
	ascii2hex)
		"$DIR"/ascii2hex "$@"
		;;
	hexdump)
		"$DIR"/hexdump "$@"
		;;
	false)
		"$DIR"/false "$@"
		;;
	replace)
		"$DIR"/replace "$@"
		;;
	readelf)
		"$DIR"/readelf "$@"
		;;
	strings)
		"$DIR"/strings "$@"
		;;
	ls)
		"$DIR"/ls "$@"
		;;
	xoda)
		"$DIR"/xoda "$@"
		;;
	cc)
		/usr/local/bin/tcc "$@"
		;;
	id)
		"$DIR"/id "$@"
		;;
	cmp)
		"$DIR"/cmp "$@"
		;;
	tree)
		$DIR/tree "$@"
		;;
	kmsg)
		$DIR/kmsg "$@"
		;;
	file)
		$DIR/file "$@"
		;;
	magic)
		$DIR/magic "$@"
		;;
	mem)
		$DIR/mem "$@"
		;;
	test)
		$DIR/test "$@"
		;;
	clear)
		$DIR/clear "$@"
		;;
	lsblk)
		$DIR/lsblk "$@"
		;;
	systrace)
		$DIR/systrace "$@"
		;;
	*)
		printf "unsupported command: %s\n" "$CMD"
		fusage
		;;
esac
