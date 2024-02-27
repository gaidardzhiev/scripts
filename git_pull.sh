#!/bin/sh

DIR=$HOME/src/1v4n/

for i in $(find $DIR -maxdepth 1 -type d)
do
        cd $i
        git pull
done
