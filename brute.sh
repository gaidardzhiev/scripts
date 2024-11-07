#!/bin/sh

nmap -sS -sV $1 -vv -n -oA scan
brutespray --file scan.gnmap \
        -U /usr/share/brutespray/wordlist/user.txt \
        -P /usr/share/brutespray/wordlist/pass.txt \
        --threads 5 --hosts 5
