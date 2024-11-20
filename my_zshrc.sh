#!/bin/sh

export RC="/root/.zshrc"
export HISTDIR="/root/.cache/zsh"
export HISTFILE="/root/.cache/zsh/history"
export SRC="/home/src/1v4n/"

touch $RC
mkdir $HISTDIR
touch $HISTFILE

cat <<'EOF' >> $RC
autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'
dircolors --print-database >! /root/.cache/zsh/dircolors.default
alias ls='ls --color=auto'
alias cat='ccat'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias tmux='tmux new-session \; \split-window -v \; \split-window -h \; \select-pane -t 0 \; \split-window -h'
alias clean='paccache -rk1'
alias yay-fzf='yay -Slq | fzf --multi --preview "yay -Si {1}" | xargs -ro yay -S'

export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -R '
export VISUAL=vim;
export EDITOR=vim;

(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
EOF
