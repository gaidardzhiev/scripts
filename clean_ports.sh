#!/bin/sh
#the script performs a search and cleans forgotten work subdirectory in the FreeBSD ports tree

for i in `find /usr/ports -name work -type d`
do
        cd `echo "${i}" | sed 's/\/[^\/]*$/\//'`
        make clean
done
