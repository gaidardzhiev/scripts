#!/bin/sh
#the script checks if the system is vulnerable to Dirty Frag by checking for esp4 esp6 rxrpc modules and blacklist state, and you can undo it later by deleting the blacklist file and reloading the modules after the  update

fcheck() {
	grep -Eq '^[[:space:]]*blacklist[[:space:]]+(esp4|esp6|rxrpc)\b|^[[:space:]]*install[[:space:]]+(esp4|esp6|rxrpc)[[:space:]]+/bin/false\b' /etc/modprobe.d/*.conf 2>/dev/null && printf "the attack vector for Dirty Frag is NOT possible by modprobe loading\\n" || \
		{
			lsmod | grep -Eq '^(esp4|esp6|rxrpc)[[:space:]]' && \
				printf "the attack vector for Dirty Frag IS possible\\n" || \
				printf "the attack vector for Dirty Frag is NOT currently loaded\\n"
		}
}

fmitigate() {
	case "${1}" in
		y*)
			printf '%s\n' 'install esp4 /bin/false' 'install esp6 /bin/false' 'install rxrpc /bin/false' > /etc/modprobe.d/dirtyfrag.conf && \
			rmmod esp4 esp6 rxrpc 2>/dev/null && \
			echo 3 > /proc/sys/vm/drop_caches && \
			printf "mitigation applied\\n"
			;;
		n*)
			printf "mitigation skipped\\n"
			;;
		*)
			printf "please answer y or n\\n"
			;;
	esac
}

fcheck && {
	printf "do you want to mitigate it? [y/n] "
	read DEC
	fmitigate "${DEC}"
} && exit 0 || exit 1
