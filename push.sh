#!/bin/sh
#git config --global credential.helper store

ferror() {
	echo "error: $1"
	sed -n '2s/^.\(.*\)/\1/p' "$0"
	exit 1
}

DATE=$(date)

git add . || ferror "failed to add changes"

git commit -m "$DATE" || ferror "failed to commit changes"

git push origin main || ferror "failed to push changes"
