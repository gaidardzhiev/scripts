#!/bin/sh
#the script checks if openssh is directly linked to liblzma.so and therefore is the attack vector for CVE-2024-3094 possible

#if ldd "$(command -v sshd)" | grep liblzma.so; then
#        echo "the attack vector for CVE-2024-3094 IS possible"
#else
#        echo "the attack vector for CVE-2024-3094 is NOT possible"
#fi

fcheck() {
	ldd "$(command -v sshd)" | grep liblzma.so && \
		printf "the attack vector for CVE-2024-3094 IS possible\n" || \
		printf "the attack vector for CVE-2024-3094 is NOT possible\n"
}

fcheck && exit 0 || exit 1
