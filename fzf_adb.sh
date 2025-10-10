#!/bin/bash
#TODO: get rid of the evil bashisms to ensure POSIX compatibility...

ADBD="${HOME}/.adb_device"

[[ -f "${ADBD}" ]] || adb devices -l | fzf | awk '{print $1}' > "${ADBD}"

DEVICE="$(head -n1 "${ADBD}")"

FILE="${1}"

[[ "${FILE}" ]] || FILE="$(fzf)"

[[ "${FILE}" ]] || exit 1

adb -s "${DEVICE}" push "${FILE}" "/sdcard"
