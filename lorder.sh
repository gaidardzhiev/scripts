#!/bin/sh
#resolve symbol dependencies and properly order object files

symdef=$(mktemp) || exit 1
symref=$(mktemp) || { rm -f "$symdef"; exit 1; }

trap 'rm -f "$symdef" "$symref"; exit' INT TERM HUP EXIT

[ "$#" -eq 0 ] && {
	echo "usage: $0 file ..."
	exit 1
}

[ "$#" -eq 1 ] && {
	case "$1" in
		*.o) set -- "$1" "$1" ;;
	esac;
}

nm -g -- "$@" | sed -n '
	/^$/d
	/:$/ {
		/\.o:/!d
		s/://
		h
		s/.*/& &/
		p
		d
	}
	/[TD] / {
		s/.* //
		G
		s/\n/ /
		w '"$symdef"'
		d
	}
	{
		s/.* //
		G
		s/\n/ /
		w '"$symref"'
		d
	}
'

sort "$symdef" -o "$symdef"
sort "$symref" -o "$symref"

join "$symref" "$symdef" | sed 's/^[^ ]* //'
