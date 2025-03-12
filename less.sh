#!/bin/sh
#colorizing less
#the script has to live in:
#/usr/share/source-highlight/src-hilite-lesspipe.sh

set -eu

SRCLANG=${SRCLANG:-}

guess_language() {
	lang=$(echo -e ${1:-} | file - | cut -d" " -f2)
	echo $(tr [A-Z] [a-z] <<< "$lang")
}

check_language_is_known() {
	fallback=""
	lang=$(source-highlight --lang-list | cut -d' ' -f1 | grep "${1:-}" || true)
	lang=${lang:-$fallback}
	echo $lang
}

for source in "$@"
do
	case $source in
		*ChangeLog|*changelog)
			source-highlight --failsafe -f esc --lang-def=changelog.lang --style-file=esc.style -i "$source" ;;
		*Makefile|*makefile)
			source-highlight --failsafe -f esc --lang-def=makefile.lang --style-file=esc.style -i "$source" ;;
		*.tar|*.tgz|*.gz|*.bz2|*.xz)
			lesspipe "$source" ;;
		*)
			if [[ "$source" != "-" && $(basename "$source") =~ \. ]]; then
				source-highlight --failsafe --infer-lang -f esc --style-file=esc.style -i "$source"
			else
				IFS= file=$([ "source" = "-" ] && cat || cat "$source")
				lang=$(guess_language $file)
				lang=$(check_language_is_known $lang)
				[ -n "$SRCLANG" ] && lang="$SRCLANG"
				if [ -n "$lang" ]; then
					echo $file | source-highlight --failsafe -f esc --src-lang=$lang --style-file=esc.style
				else
					echo $file
				fi
			fi
			;;
	esac
done
