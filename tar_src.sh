#!/bin/bash

DIR=$HOME/src/1v4n/
FILE=$DIR/src.tar.gz

if ! [ -f "$FILE" ]
then
        echo $?
else
        rm $FILE
fi
tar -czvf $FILE $DIR
