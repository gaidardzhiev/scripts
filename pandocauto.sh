#!/bin/sh

fpdf() {
	pandoc book.md -o book.pdf \
		-V geometry:paperwidth=6in,paperheight=9in \
		-V geometry:margin=0.75in \
		-V fontsize=10pt \
		-V mainfont="Times New Roman"
}

fdocx() {
	pandoc book.md -o book.docx \
		--variable geometry:paperwidth=6in \
		--variable geometry:paperheight=9in \
		--variable geometry:margin=0.75in \
		--variable fontsize=12pt \
		--variable mainfont="Times New Roman"
}

fepub() {
	pandoc book.md -o book.epub \
		--toc --toc-depth=3 \
		--epub-chapter-level=2 \
		--metadata title="From malloc() to Gödel" \
		--metadata author="Ivan Gaydardzhiev"
}

fprompt() {
	printf "choose output format [pdf/docx/epub]: "
	read fmt
	case "$fmt" in
		pdf)
			fpdf 
			;;
		docx)
			fdocx
			;;
		epub)	fepub
			;;
		*)	printf "unknown format '%s'...\n" "$fmt" && fprompt
			;;
	esac
}

fprompt
