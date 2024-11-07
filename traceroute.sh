#!/bin/sh

for i in `curl -s https://ipv4.icanhazip.com`
do
	traceroute "$i"
done
