#!/bin/sh
#the script builds midnight commander

set -x

export MC_VER=4.7.5.6
export NUMCPUS=`grep -c '^processor' /proc/cpuinfo`
export JOBS='-j '$NUMCPUS''
export DIR=/home/mc

if 
	mkdir $DIR
	cd $DIR
	wget http://ftp.midnight-commander.org/mc-$MC_VER.tar.xz
	tar xf mc-$MC_VER.tar.xz
	cd mc-$MC_VER
	./configure
	make $JOBS
	cp $DIR/mc-$MC_VER/src/mc /usr/bin/mc; then
	echo "done"
	rm -r $DIR
else
	echo "failed"
fi
