#!/bin/sh

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
RESET="\033[0m"

print_info() {
	printf "${CYAN}%-15s${RESET} : ${GREEN}%s\n" "$1" "$2"
}

hostname=$(hostname) && print_info "hostname" "$hostname" || print_info "hostname" "unknown"

os_name=$(uname -s)

os_release=$(uname -r)

distro="unknown OS"

pkg_manager="unknown"

case "$os_name" in
	Linux)
		distro=$(grep -E '^NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
		;;
	FreeBSD)
		distro="FreeBSD"
		;;
	OpenBSD)
		distro="OpenBSD"
		;;
	Plan9)
		distro="Plan9"
		;;
	Darwin)
		distro="macOS"
		pkg_manager="brew"
		;;
	*)
		distro="$os_name"
		;;
esac

print_info "OS" "$distro"

print_info "kernel" "$os_release"

case "$distro" in
	*Ubuntu*|*Debian*)
		pkg_manager="apt"
		;;
	*Fedora*|*CentOS*|*Red*Hat*)
		command -v dnf >/dev/null 2>&1 && pkg_manager="dnf" || pkg_manager="yum"
		;;
	*Arch*)
		pkg_manager="pacman"
		;;
	*Alpine*)
		pkg_manager="apk"
		;;
	Dar*)
		pkg_manager="brew"
		;;
	FreeBSD)
		pkg_manager="pkg"
		;;
	OpenBSD)
		pkg_manager="pkg_add"
		;;
	Plan9)
		pkg_manager="none"
		;;
	*)
		pkg_manager="Unknown"
		;;
esac

print_info "package manager" "$pkg_manager"

count_packages() {
	case "$1" in
		apt)
			dpkg -l 2>/dev/null | grep '^ii' | wc -l
			;;
		dnf)
			dnf list installed 2>/dev/null | tail -n +2 | wc -l
			;;
		yum)
			yum list installed 2>/dev/null | tail -n +1 | wc -l
			;;
		pacman)
			pacman -Q 2>/dev/null | wc -l
			;;
		apk)
			apk info 2>/dev/null | wc -l
			;;
		brew)
			brew list 2>/dev/null | wc -l
			;;
		pkg)
			pkg info 2>/dev/null | wc -l
			;;
		pkg_add)
			pkg_info 2>/dev/null | wc -l
			;;
		none)
			echo "N/A"
			;;
		*)
			echo "N/A"
			;;
	esac
}

installed_pkgs=$(count_packages "$pkg_manager")

[ -n "$installed_pkgs" ] && print_info "packages" "$installed_pkgs" || print_info "packages" "unavailable"

uptime_info=""

uptime_seconds=""

case "$os_name" in
	Linux|Darwin)
		uptime_info=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
		uptime_seconds=$(awk '{print int($1)}' /proc/uptime 2>/dev/null)
		;;
	FreeBSD|OpenBSD)
		uptime_info=$(uptime | awk -F, '{print $1}' | sed 's/.*up //')
		uptime_seconds=$(expr "$(date +%s)" - "$(sysctl -n kern.boottime | awk '{print $4}' | sed 's/,//')")
		;;
	Plan9)
		uptime_info="N/A"
		uptime_seconds=""
		;;
esac

print_info "uptime" "$uptime_info"

[ -n "$uptime_seconds" ] && {
	uptime_minutes=$((uptime_seconds / 60));
	print_info "uptime (min)" "$uptime_minutes";
} || print_info "uptime (min)" "N/A"

cpu_model=""

case "$os_name" in
	Linux)
		cpu_model=$(awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo 2>/dev/null | sed 's/^ //')
		[ -z "$cpu_model" ] && cpu_model=$(uname -p)
		;;
	FreeBSD|OpenBSD)
		cpu_model=$(sysctl -n hw.model 2>/dev/null)
		[ -z "$cpu_model" ] && cpu_model=$(uname -p)
		;;
	Plan9)
		cpu_model="Unavailable"
		;;
	*)
		cpu_model="Unknown"
		;;
esac

print_info "CPU" "${cpu_model:-Unknown}"

mem_total=""

mem_free=""

case "$os_name" in
	Linux)
		mem_total=$(awk '/MemTotal:/ {print $2}' /proc/meminfo 2>/dev/null)
		mem_free=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo 2>/dev/null)
		;;
	FreeBSD|OpenBSD)
		mem_total=$(sysctl -n hw.physmem 2>/dev/null)
		mem_free="N/A"
		;;
	Plan9)
		mem_total="N/A"
		mem_free="N/A"
		;;
esac

if [ -n "$mem_total" ] && [ "$mem_total" != "N/A" ] && [ "$mem_free" != "N/A" ] && [ -n "$mem_free" ]; then
	mem_used=$((mem_total - mem_free))
	mem_used_mb=$((mem_used / 1024 / 1024))
	mem_total_mb=$((mem_total / 1024 / 1024))
	print_info "memory" "$mem_used_mb MB / $mem_total_mb MB"
elif [ -n "$mem_total" ] && [ "$mem_total" != "N/A" ]; then
	mem_total_mb=$((mem_total / 1024 / 1024))
	print_info "memory" "total $mem_total_mb MB"
else
	print_info "memory" "unavailable"
fi

case "$os_name" in
	Linux|Darwin)
		disk_usage=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2}')
		;;
	FreeBSD|OpenBSD)
		disk_usage=$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2}')
		;;
	Plan9)
		disk_usage="N/A"
		;;
	*)
		disk_usage="unavailable"
		;;
esac

print_info "disk" "$disk_usage"

shell_name=$(basename "$SHELL")

print_info "shell" "$shell_name"

users_count=$(who | wc -l)

print_info "users logged in" "$users_count"

print_info "terminal" "${TERM:-Unknown}"

case "$os_name" in
	Linux)
		kernel_stats=$(head -20 /proc/stat 2>/dev/null | grep -v '^btime' | grep -v '^intr' | grep -v '^ctxt')
		[ -n "$kernel_stats" ] && {
			print_info "kernel stats" "see below"
			printf "\t%-8s %-7s %-5s %-6s %-5s %-7s %-4s %-7s %-6s %-5s %-10s\n" label user nice system idle iowait irq softirq steal guest guest_nice
			echo "$kernel_stats" | while read -r line; do
				label=$(echo "$line" | awk '{print $1}')
				values=$(echo "$line" | cut -d' ' -f2-)
				printf "\t%-8s %7s %5s %6s %5s %7s %4s %7s %6s %5s %10s\n" "$label" $values
			done
		}
		load_avg=$(cat /proc/loadavg 2>/dev/null)
		[ -n "$load_avg" ] && print_info "load average" "$load_avg" || print_info "load average" "unavailable"

		lsblk_out=$(lsblk 2>/dev/null)
		[ -n "$lsblk_out" ] && print_info "block devices" "see below"
		echo "$lsblk_out" | while IFS= read -r line; do
			printf "\t%s\n" "$line"
		done
		interrupts=$(head -20 /proc/interrupts 2>/dev/null)
		[ -n "$interrupts" ] && print_info "interrupts" "see below"
		echo "$interrupts" | while IFS= read -r line; do
			printf "\t%s\n" "$line"
		done
		pci_devices=$(lspci 2>/dev/null)
		[ -n "$pci_devices" ] && print_info "PCI devices" "see below"
		echo "$pci_devices" | while IFS= read -r line; do
			printf "\t%s\n" "$line"
		done
		;;
	FreeBSD|OpenBSD)
		sysctl kern | head -20 | while IFS= read -r line; do
			print_info "kernel stat" "$line"
		done
		load_avg=$(sysctl vm.loadavg 2>/dev/null | awk -F'=' '{print $2}' | sed 's/^[[:space:]]*//')
		[ -n "$load_avg" ] && print_info "load average" "$load_avg" || print_info "load average" "unavailable"
		geom_disk=$(geom disk list 2>/dev/null)
		[ -n "$geom_disk" ] && print_info "geom disks" "see below"
		echo "$geom_disk" | while IFS= read -r line; do
			printf "\t%s\n" "$line"
		done
		interrupts=$(sysctl kern.intr 2>/dev/null)
		[ -n "$interrupts" ] && print_info "interrupts" "$interrupts"
		;;
	Plan9)
		print_info "kernel stats" "not supported"
		print_info "load average" "not supported"
		print_info "device info" "limited support"
		;;
	*)
		print_info "kernel stats" "unknown OS"
		print_info "load average" "unknown OS"
		print_info "device info" "unknown OS"
		;;
esac
