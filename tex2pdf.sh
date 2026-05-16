#!/bin/sh

flatex() {
	printf "do you want to build the LaTeX document form source? (y/n)\n"
	read X
	case "${X}" in
		[y]*)
			printf "building LaTeX from source...\n"
			printf "please choose pdflatex or xelatex\n"
			while :; do
				read Y
				case "${Y}" in
					xelatex)
						xelatex "${1}" || return 8
						cp latex.pdf /home/tower/Downloads || return 32
						break
						;;
					pdflatex)
						pdflatex "${1}" || return 16
						cp latex.pdf /home/tower/Downloads || return 32
						break
						;;
					*)
						printf "invalid response...\nchoose: xelatex/pdflatex\n"
						;;
				esac
			done
			;;
		[n]*)
			printf "you chose NOT to build LaTeX from source...\n"
			;;
		*)
			printf "invalid response...\n"
			printf "(yes/no)\n"
			;;
	esac
}

{ flatex; RET="${?}"; } || exit 1

[ "${RET}" -eq 0 ] 2>/dev/null || printf "%s\n" "${RET}"
