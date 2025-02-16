#!/bin/sh
#the script checks if openssh is directly linked to liblzma.so and therefore is the attack vector for CVE-2024-3094 possible

if ldd "$(command -v sshd)" | grep liblzma.so; then
        echo "the attack vector for CVE-2024-3094 IS possible"
else
        echo "the attack vector for CVE-2024-3094 is NOT possible"
fi
