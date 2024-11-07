#!/bin/bash

adb_device="$HOME/.adb_device"

[[ -f "adb_device" ]] || adb devices -l | fzf | awk '{print $1}' > "$adb_device"

device="$(head -n1 "$adb_device")"

file="$1"
[[ "$file" ]] || file="$(fzf)"
[[ "$file" ]] || exit 1

adb -s "$device" push "$file" "/sdcard"
