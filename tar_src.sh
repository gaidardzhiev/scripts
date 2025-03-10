#!/bin/bash

DATE=$(date +"%Y%m%d_%H")
DIR=/home/src/1v4n/
FILE=$DIR/src_$DATE.tar.gz

[ ! -f "$FILE" ] && echo $? || rm "$FILE"
tar -czvf "$FILE" "$DIR"
