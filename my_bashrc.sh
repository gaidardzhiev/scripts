#!/bin/sh

RC=/etc/bash.bashrc

if [ -e "${RC}" ]; then
	printf "/etc/bash.bashrc exists...\n"
	exit 1
else
	touch "${RC}"
	cat <<'EOF' >> "${RC}"
# /etc/bash.bashrc
if [[ $- != *i* ]] ; then
	return
fi

shopt -s checkwinsize
shopt -s no_empty_cmd_completion
shopt -s histappend

case ${TERM} in
	[aEkx]term*|rxvt*|gnome*|konsole*|interix|tmux*)
		PS1='\[\033]0;\u@\h:\w\007\]'
		;;
	screen*)
		PS1='\[\033_\u@\h:\w\033\\\]'
		;;
	*)
		unset PS1
		;;
esac

use_color=false

if type -P dircolors >/dev/null ; then
	LS_COLORS=
	if [[ -f ~/.dir_colors ]] ; then
		eval "$(dircolors -b ~/.dir_colors)"
	elif [[ -f /etc/DIR_COLORS ]] ; then
		eval "$(dircolors -b /etc/DIR_COLORS)"
	else
		eval "$(dircolors -b)"
	fi
	if [[ -n ${LS_COLORS:+set} ]] ; then
		use_color=true
	else
		unset LS_COLORS
	fi
else
	case ${TERM} in
	[aEkx]term*|rxvt*|gnome*|konsole*|screen|tmux|cons25|*color) use_color=true;;
	esac
fi

if ${use_color} ; then
	if [[ ${EUID} == 0 ]] ; then
		PS1+='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
	else
		PS1+='\[\033[01;32m\]\u@\h\[\033[01;34m\] \W \$\[\033[00m\] '
	fi
	alias grep='grep --colour=auto'
else
	PS1+='\u@\h \w \$ '
fi

for sh in /etc/bash/bashrc.d/*
do
	[[ -r ${sh} ]] && source "${sh}"
done

unset use_color sh

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias tmux='tmux new-session \; \split-window -v \; \'
alias clean='paccache -rk1'
alias ego='cd /home/src/1v4n/ && find . -type f \( -name "*.c" -o -name "*.sh" -o -name "Makefile" \) | wc -l'
alias manfzf='man -k . | fzf | awk '\''{print $1}'\'' | xargs man'

show_files() {
	find . \
		-path '*/.*' -prune -o \
		-type f -exec sh -c 'echo "==> $1 <=="; cat "$1"' _ {} \;
}
alias flow='show_files'

export LESSOPEN="| /usr/bin/less.sh %s"
export LESS=' -R '
EOF
exit 0
fi
