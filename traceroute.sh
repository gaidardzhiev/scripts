#!/bin/sh

command -v curl >/dev/null 2>&1 || { printf "curl is not installed...\n"; exit 1; }

command -v traceroute >/dev/null 2>&1 || { printf "traceroute is not installed...\n"; exit 1; }

for ip in `curl -s https://ipv4.icanhazip.com`
do
	traceroute "${ip}"
done
