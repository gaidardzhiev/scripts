#!/bin/sh
#git config --global credential.helper store

ferror() {
	printf "error: %s\n" "${1}"
	sed -n '2s/^.\(.*\)/\1/p' "${0}"
	exit 1
}

DATE=$(date)

while :; do
	printf "would you like to leave a meaningful commit message? (yes/no): "
	read -r ANSWER
	case "${ANSWER}" in
		y*)
			echo "enter your meaningful commit message:"
			read -r MESSAGE
			COMMIT="${MESSAGE}"
			break
			;;
		n*)
			COMMIT="${DATE}"
			break
			;;
		*)
			printf "invalid input...\nplease type yes or no...\n"
			;;
	esac
done

git add . || ferror "failed to add changes"

git commit -m "${COMMIT}" || ferror "failed to commit changes"

git push origin main || ferror "failed to push changes"
