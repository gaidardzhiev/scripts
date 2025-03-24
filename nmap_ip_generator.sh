#!/bin/sh
#the script generates 25M unique IPs to scan later

fgen() {
	nmap -iR 25200000 -sL -n \
		| awk '{print $5}' \
		| sort -n \
		| uniq > tmp_IPs; \
		head -n 25000000 tmp_IPs > 25M_IPs;\
		rm tmp_IPs
}

fgen && exit 0 || exit 1
