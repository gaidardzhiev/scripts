#!/bin/sh

# ========================================== #
#                                            #
#                  WARNING                   #
# 	       work in progress              #
#     do not use or rely on this script      #
#                                            #
# ========================================== #


server_dir="/home/src/llm/llama.cpp/build/bin"

models_dir="/home/src/llm/llama.cpp/build/bin/models"

model=$(find "$models_dir" -type f | fzf --prompt="select a model: ")

[ -z "$model" ] && { echo "no model selected, exiting."; exit 1; }

workspace=$(find ~ -type d 2>/dev/null | fzf --prompt="select workspace directory: ")

[ -z "$workspace" ] && { echo "no workspace selected, exiting."; exit 1; }

cd "$workspace" || exit 1

# initialize git repo if needed
if [ ! -d .git ]; then
	echo "workspace is not a git repository, initializing..."
	git init
	echo "add your git remote now (e.g., 'git remote add origin <url>') and press enter when ready."
	read -r _
fi

# start llama server in background
"$server_dir"/llama-server -m "$model" --host 127.0.0.1 --port 8080 &
llama_pid=$!

echo "enter the program specification and requirements (end with ctrl+d):"
task_spec=$(cat)

# helper: build prompt for llm with spec, previous code, and errors
build_prompt() {
	errors="$1"
	last_code="$2"
	prompt="you are a c programming assistant assigned to accomplish the following specification exactly:
$task_spec

"
	[ -n "$last_code" ] && prompt="${prompt}here is the previous code submission across files:
\`\`\`c
$last_code
\`\`\`

"
	if [ -n "$errors" ]; then
		prompt="${prompt}the latest compilation and test attempt resulted in errors:
$errors

please fix all issues in the entire code and provide a complete, clean multi-file c project. for any testing code required, include an inline test script file named 'test.sh' that compiles and tests the project automatically. provide all code enclosed in markdown triple backticks for each file separately with filename comment headers like:
\`\`\`c
// filename.c
<file content>
\`\`\`
or for shell scripts:
\`\`\`sh
// test.sh
<shell script content>
\`\`\`

respond only with the source code blocks, nothing else."
	fi
	echo "$prompt"
}

# save llm response code files from stdout string
save_code_files() {
	llmsrc="$1"
	# for safety cleanup old generated files (excluding vcs and scripts)
	find . -maxdepth 1 -type f ! -name '.gitignore' ! -name 'test.sh' ! -name '*.c' -exec rm -f {} +
	# parse code blocks with filenames to separate files
	echo "$llmsrc" | awk '
	BEGIN {RS="```
	NR % 2 == 0 {
		split($0, lines, "\n");
		fname="unknown_file"
		if (match(lines[11], /^[\s\/]*([^\n\r]+\.c|test\.sh)/, m)) {
			fname = m;[11]
			sub(/^[\s\/]*[^\n\r]+\n/, "", $0)
		}
		out = ""
		for (i=2; i<=length(lines); i++) {
			out = out lines[i] "\n"
		}
		print out > fname
		print "" > fname
	}
	'
}

# compile and run test.sh
compile_and_test() {
	echo "compiling c files..."
	if ! gcc -o program ./*.c 2>compile_errors.txt; then
		cat compile_errors.txt
		return 1
	fi

	if [ -x test.sh ]; then
		echo "running test script test.sh..."
		if ! ./test.sh; then
			echo "test script failed."
			cat test_output.txt 2>/dev/null || true
			return 2
		fi
	else
		echo "no test.sh script found, running program output test..."
		if ! ./program >test_output.txt 2>&1; then
			echo "program failed during execution."
			cat test_output.txt
			return 3
		fi
	fi
	return 0
}

# commit and push changes
commit_and_push() {
	git add .
	if git diff --cached --quiet; then
		echo "no changes to commit."
		return 0
	fi
	git commit -m "$(date)"
	git push origin main
}

errors=""
last_code=""
loop_count=0
max_loops=10

while [ "$loop_count" -lt "$max_loops" ]; do
	loop_count=$((loop_count+1))
	echo "----- iteration $loop_count -----"
	prompt=$(build_prompt "$errors" "$last_code")
	response=$(curl -s -X POST http://127.0.0.1:8080/v1/completions -H 'content-type: application/json' -d "
{
	\"model\": \"$model\",
	\"prompt\": \"$prompt\",
	\"max_tokens\": 2048,
	\"temperature\": 0.2
}")
	raw_text=$(echo "$response" | grep -oP '"text":"\K.*?(?=")')
	raw_text=$(printf '%b' "$raw_text")
	save_code_files "$raw_text"
	# aggregate all .c files content for next prompt context
	last_code=$(cat ./*.c | head -c 8000) # limit to first 8k chars
	compile_and_test
	result=$?
	if [ $result -eq 0 ]; then
		echo "program compiled and passed all tests on iteration $loop_count!"
		commit_and_push
		break
	else
		if [ $result -eq 1 ]; then
			errors=$(cat compile_errors.txt)
			echo "compilation errors detected:"
		elif [ $result -eq 2 ]; then
			errors="test script test.sh failed."
			echo "$errors"
		else
			errors=$(cat test_output.txt)
			echo "runtime errors detected:"
		fi
		echo "$errors"
		echo "feeding back errors for next iteration fixes..."
	fi
done

if [ $loop_count -ge $max_loops ]; then
	echo "reached max iteration count ($max_loops) without successful build."
fi

echo "stopping llama server..."
kill $llama_pid
