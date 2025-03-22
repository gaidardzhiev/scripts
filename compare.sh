#!/bin/sh
#the script benchmarks the execution time of 'if' and 'case' statements in a POSIX shell

testif() {
	start=$(date +%s%N)
	for i in $(seq 1 100000);
	do
		if [ $((i % 2)) -eq 0 ] && [ $((i % 3)) -eq 0 ];
		then
			result="even and divisible by three"
		elif [ $((i % 2)) -eq 0 ];
		then
			result="even"
		elif [ $((i % 3)) -eq 0 ];
		then
			result="divisible by three"
		else
			result="odd"
		fi
	done
	end=$(date +%s%N)
	elapsed=$((end - start))
	echo "if statements execution time: $elapsed nanoseconds"
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
	echo "case statements execution time: $elapsed nanoseconds"
}

testif && testcase

z=$(testif | sed -n 's/[^0-9]*\([0-9]*\).*/\1/p')
x=$(testcase | sed -n 's/[^0-9]*\([0-9]*\).*/\1/p')

faster=$( [ "$z" -lt "$x" ] && echo "'if' is faster by $((x - z)) nanoseconds" || echo "'case' is faster by $((z - x)) nanoseconds" )

echo "in this benchmark $faster"
