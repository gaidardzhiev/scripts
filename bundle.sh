#!/bin/sh
#the script outputs a POSIX shell script archive of files, when executed it reconstructs the original files from the archive

[ "${#}" -lt 1 ] && {
	printf "usage: %s [files] >> [archive]\n" "${0}";
	sed -n '2s/^.\(.*\)/\1/p' "${0}";
	exit 1;
}

printf "#!/bin/sh\n"

for f in "${@}";
do
	[ -e "${f}" ] && {
		printf "cat > \"${f}\" << 'HACK'\n";
		cat "${f}";
		printf "HACK\n";
	} || printf "%s does not exist...\n" "${f}"
done
