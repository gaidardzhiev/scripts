#!/bin/sh
#the script outputs a POSIX shell script archive, when it is executed it reconstructs the original files from the archive

[ "$#" -lt 1 ] && {
	printf "usage: $0 [files] >> [archive]\n";
	sed -n '2s/^.\(.*\)/\1/p' "$0";
	exit 1;
}

printf "#!/bin/sh\n"

for f in "$@";
do
	[ -e "$f" ] && {
		printf "cat > \"$f\" << 'HACK'\n";
		cat "$f";
		printf "HACK\n";
	} || printf "$f does not exist...\n"
done
