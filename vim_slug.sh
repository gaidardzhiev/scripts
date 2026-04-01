#!/bin/sh
#adds vim syntax highlighting for the slug interpreted programming language, for more information see https://github.com/gaidardzhiev/slug

mkdir -p ~/.vim/syntax ~/.vim/ftdetect

[ -f ~/.vim/ftdetect/slg.vim ] && {
	printf "~/.vim/ftdetect/slg.vim exists...\n";
	exit 1;
}

cat > ~/.vim/ftdetect/slg.vim << 'EOF'
autocmd BufRead,BufNewFile *.slg setfiletype slg
EOF

cat > ~/.vim/syntax/slg.vim << 'EOF'
" vim syntax file for .slg language
if exists("b:current_syntax")
    finish
endif

syntax keyword slgControl      if elif else while
syntax keyword slgDeclaration  var const
syntax keyword slgFunction     func
syntax keyword slgBoolean      true false
syntax keyword slgBuiltin      outn out

syntax match   slgNumber       "\<\d\+\(\.\d\+\)\?\>"
syntax region  slgString       start=+"+ skip=+\\"+ end=+"+
syntax region  slgString       start=+'+ skip=+\\'+ end=+'+
syntax region  slgComment      start="/\*" end="\*/" fold
syntax match   slgComment      "//.*$"
syntax match   slgArrow        "=>"
syntax match   slgCompare      "==\|!=\|<=\|>=\|<\|>"
syntax match   slgLogical      "&&\|\|\||\|!"
syntax match   slgArithmetic   "[+\-*/%]"
syntax match   slgAssign       "=\ze[^=>]"
syntax match   slgDelimiter    "[(){};,]"
syntax match   slgFuncCall     "\<\w\+\ze\s*("

highlight default link slgControl      Conditional
highlight default link slgDeclaration  Keyword
highlight default link slgFunction     Keyword
highlight default link slgBoolean      Boolean
highlight default link slgBuiltin      Function
highlight default link slgNumber       Number
highlight default link slgString       String
highlight default link slgComment      Comment
highlight default link slgArrow        Operator
highlight default link slgCompare      Operator
highlight default link slgLogical      Operator
highlight default link slgArithmetic   Operator
highlight default link slgAssign       Operator
highlight default link slgDelimiter    Delimiter
highlight default link slgFuncCall     Function

let b:current_syntax = "slg"
EOF
