#!/bin/bash

DATE=$(date +"%Y%m%d_%H")
DIR="${1}"
OUT="/home/src_${DATE}.tar.gz"

[ "${#}" -lt 1 ] && {
	printf "usage: %s <dir>\n" "${0}";
	exit 1;                                                 }

tar -czvf "${OUT}" "${DIR}" && exit 0 || exit 1
