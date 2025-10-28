#!/bin/sh

IN="${1}"
OUT="${2}"

[ "${#}" -ne 2 ] && {
	printf "usage: %s <in.c> <out.c>\n" "${0}";
	exit 1;
}

awk 'NF {sub(/^[ \t]+/, ""); sub(/[ \t]+$/, ""); gsub(/[ \t]*\(\s*/,"("); gsub(/\s*\)/,")"); gsub(/[ \t]*\*\s*/,"*"); gsub(/\s*=\s*/, "="); gsub(/\s*==\s*/, "=="); gsub(/[ \t]*{\s*/, "{"); gsub(/\s*}/,"}"); gsub(/""/,"\"\""); print}' "${IN}" | awk 'NF' > "${OUT}"
