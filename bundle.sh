#!/bin/sh
#the script writes on its standard output a POSIX shell script archive of files which when executed will recreate the original files

[ "$#" -lt 1 ] && {
	printf "usage: $0 [files] >> [archive]\n";
	exit 1;
}

printf "#!/bin/sh\n"

for f in "$@";
do
	[ -e "$f" ] && {
		printf "cat > \"$f\" << 'EOF'\n";
		cat "$f";
		printf "EOF\n";
	} || printf "$f does not exist...\n"
done
