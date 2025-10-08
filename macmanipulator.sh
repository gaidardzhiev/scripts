#!/bin/sh

DEVICE="enp0s25"

rand_byte_hex() {
	openssl rand -hex 1 2> /dev/null || head -c1 /dev/urandom | xxd -p
}

rand_mac_address() {
	echo "$(rand_byte_hex):$(rand_byte_hex):$(rand_byte_hex):$(rand_byte_hex):$(rand_byte_hex):$(rand_byte_hex)"
}

mac_addr_show() {
	ip addr show | grep -A 1 "${DEVICE}" | head --lines 2 | tail --lines 1 | sed 's/^ \+//' | cut -f2 -d ' '
}

#mac_addr_show() {
#	ip link show "${DEVICE}" | awk '/ether/ { print $2 }'
#}

change_mac_address() {
	local NEW_MAC
	NEW_MAC=$(rand_mac_address)
	ip link set dev "${DEVICE}" down && \
	ip link set dev "${DEVICE}" address "${NEW_MAC}" && \
	ip link set dev "${DEVICE}" up && \
	{ printf "MAC address changed to: %s\n" "${NEW_MAC}"; return 0; } || \ 
	{ printf "MAC address change failed...\n"; return 32; }
}

echo "old MAC address: $(mac_addr_show)"

{ change_mac_address; RET="${?}"; } || exit 1

[ "${RET}" -eq 0 ] 2>/dev/null || printf "%s\n" "${RET}"
