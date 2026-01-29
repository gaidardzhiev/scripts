#!/bin/sh

SERVER_DIR="/home/src/llm/llama.cpp/build/bin"
MODELS_DIR="${SERVER_DIR}/models"
PORT=8080

lsof -ti:"${PORT}" | xargs -r kill

MODEL=$(find "${MODELS_DIR}" -type f -name "*.gguf" | fzf --prompt="select model: ")

[ -z "${MODEL}" ] && {
	printf "no model selected...\n"
	exit 1
}

THREADS=$(nproc --all)

[ "${THREADS}" -gt 4 ] && THREADS=4

printf "starting %s with %d threads...\n" "$(basename "${MODEL}")" "${THREADS}"

"${SERVER_DIR}/llama-server" \
	-m "${MODEL}" \
	--host 127.0.0.1 \
	--port "${PORT}" \
	--threads "${THREADS}" \
	--batch-size 512 \
	--ctx-size 16384 \
	--temp 0.7 \
	--top-p 0.9 || {
		printf "failed to start server...\n"
		exit 1
}
