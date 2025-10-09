#!/bin/sh

SERVER_DIR="/home/src/llm/llama.cpp/build/bin"

MODELS_DIR="/home/src/llm/llama.cpp/build/bin/models"

MODEL=$(find "${MODELS_DIR}" -type f | fzf --prompt="select a model: ")

[ -z "${MODEL}" ] && { 
	printf "no model selected...\n"
	exit 1
}

"${SERVER_DIR}"/llama-server -m "${MODEL}" --host 127.0.0.1 --port 8080
