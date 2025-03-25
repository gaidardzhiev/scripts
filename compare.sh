#!/bin/sh
#this script benchmarks the execution time of 'if' and 'case' statements in a POSIX shell
#the arithmetic λόγος employed in testif() and testcase() is fundamentally identical
#both functions evaluate the divisibility of integers by 2 and 3 iterating through a sequence of numbers from 1 to 100000 applying the modulus operator to classify each number as 'even' 'divisible by three' or 'odd'

testif() {
	start=$(date +%s%N)
	for i in $(seq 1 100000);
	do
		if [ $((i % 2)) -eq 0 ] && [ $((i % 3)) -eq 0 ]; then
			result="even and divisible by three"
		elif [ $((i % 2)) -eq 0 ]; then
			result="even"
		elif [ $((i % 3)) -eq 0 ]; then
			result="divisible by three"
		else
			result="odd"
		fi
	done
	end=$(date +%s%N)
	elapsed=$((end - start))
	printf "'if'   statements execution time: $elapsed nanoseconds\n"
}

testcase() {
	start=$(date +%s%N)
	for i in $(seq 1 100000);
	do
		case $((i % 6)) in
			0)
				result="even and divisible by three"
				;;
			2|4)
				result="even"
				;;
			3)
				result="divisible by three"
				;;
			*)
				result="odd"
				;;
		esac
	done
	end=$(date +%s%N)
	elapsed=$((end - start))
	printf "'case' statements execution time: $elapsed nanoseconds\n"
}

logos() {
	sed -n '2s/^.\(.*\)/\1/p' "$0"
	sed -n '3s/^.\(.*\)/\1/p' "$0"
	sed -n '4s/^.\(.*\)/\1/p' "$0"
	printf "\n"
}

logos
p=$(testif) && printf "$p\n"
q=$(testcase) && printf "$q\n"

z=$(echo "$p" | sed -n 's/[^0-9]*\([0-9]*\).*/\1/p')
x=$(echo "$q" | sed -n 's/[^0-9]*\([0-9]*\).*/\1/p')

f=$( [ "$z" -lt "$x" ] && printf "'if' is faster by $((x - z)) nanoseconds" || printf "'case' is faster by $((z - x)) nanoseconds" )

printf "\nin this test  $f\n"
