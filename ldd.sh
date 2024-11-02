#!/bin/sh

objdump -p $1 | grep NEEDED
