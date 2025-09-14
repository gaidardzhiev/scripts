#!/bin/sh
#the script builds the qemu emulator for stm32

export DIR=/opt/qemu_stm32
export NUMCPUS='grep -c '^processor' /proc/cpuinfo'
export JOBS='-j '$NUMCPUS''

mkdir "$DIR"

cd "$DIR"

git clone https://github.com/beckus/qemu_stm32

cd qemu_stm32

./configure \
	--enable-debug \
	--disable-xen \
	--disable-werror \
	--target-list="arm-softmmu" \
	--extra-cflags=-DDEBUG_CLKTREE \
	--extra-cflags=-DDEBUG_STM32_RCC \
	--extra-cflags=-DDEBUG_STM32_UART \
	--extra-cflags=-DDEBUG_STM32_TIMER \
	--extra-cflags=-DSTM32_UART_NO_BAUD_DELAY \
	--extra-cflags=-DSTM32_UART_ENABLE_OVERRUN \
	--extra-cflags=-DDEBUG_GIC \
	--python=/usr/bin/python2.7

{ make "$JOBS" && make install; } || exit 1
