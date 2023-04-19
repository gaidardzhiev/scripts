#!/bin/sh

nc -hnvz $1 1-65535 2>&1 | tee -a $1.scan 
