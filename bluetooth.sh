#!/bin/sh

STATUS=$(systemctl is-active bluetooth.service)

[ "${STATUS}" = "active" ] && printf "bluetooth service is currently: ACTIVE\n"

[ "${STATUS}" = "inactive" ] && printf "bluetooth service is currently: INACTIVE\n"

[ "${STATUS}" != "active" ] && [ "${STATUS}" != "inactive" ] && printf "bluetooth service status is: %s\n" "${STATUS}"

printf "\nplease choose an action for the bluetooth service:\n"
printf "[on] enable and start the bluetooth service\n"
printf "[off] disable and stop the bluetooth service\n"
printf "enter your choice (on/off):\n"

read ANSWER

case "${ANSWER}" in
	on)
		systemctl enable bluetooth.service
		systemctl start bluetooth.service
		printf "bluetooth service enabled and started...\n"
		;;
	off)
		systemctl stop bluetooth.service
		systemctl disable bluetooth.service
		printf "bluetooth service stopped and disabled...\n"
		;;
	*)
		printf "please enter 'on' or 'off'...\n"
		exit 1
		;;
esac
