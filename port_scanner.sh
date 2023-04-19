#!/bin/sh

nc -nvz $1 1-1000 2>&1 | tee -a $1.scan 
