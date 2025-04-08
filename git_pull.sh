#!/bin/sh

DIR=$(find /home/src -type d -name "1v4n")

for i in $(find $DIR -maxdepth 1 -type d)
do
        cd $i
        git pull
done
