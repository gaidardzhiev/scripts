#!/bin/sh
#the script writes on its standard output a POSIX shell script archive of files which when executed will recreate the original files

[ "$#" -lt 1 ] && {
	printf "usage: $0 [files] >> [archive]\n";
	sed -n '2s/^.\(.*\)/\1/p' "$0"
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
