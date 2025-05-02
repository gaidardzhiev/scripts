#!/bin/bash
#TODO: get rid of the evil bashisms to ensure POSIX compatibility...

adbd="$HOME/.adb_device"

[[ -f "adbd" ]] || adb devices -l | fzf | awk '{print $1}' > "$adbd"

device="$(head -n1 "$adbd")"

file="$1"

[[ "$file" ]] || file="$(fzf)"

[[ "$file" ]] || exit 1

adb -s "$device" push "$file" "/sdcard"
