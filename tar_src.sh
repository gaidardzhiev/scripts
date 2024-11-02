#!/bin/bash

DATE=$(date +"%Y%m%d_%H")
DIR=/home/src/1v4n/
FILE=$DIR/src_$DATE.tar.gz

if ! [ -f "$FILE" ]
then
        echo $?
else
        rm "$FILE"
fi
tar -czvf "$FILE" "$DIR"
