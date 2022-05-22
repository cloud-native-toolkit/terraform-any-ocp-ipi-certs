#!/usr/bin/env bash

set -e

INPUT=$(tee)

# Get bin_dir to be able to use jq
BIN_DIR=$(echo "${INPUT}" | grep "bin_dir" | sed -E 's/.*"bin_dir": ?"([^"]+)".*/\1/g')

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if ! command -v jq 1> /dev/null 2> /dev/null; then
  echo "jq cli not found" >&2
  echo "bin_dir: ${BIN_DIR}" >&2
  ls -l "${BIN_DIR}" >&2
  exit 1
fi

if ! command -v oc 1> /dev/null 2> /dev/null; then
  echo "oc cli not found" >&2
  echo "bin_dir: ${BIN_DIR}" >&2
  ls -l "${BIN_DIR}" >&2
  exit 1
fi

export KUBE_CONFIG=$(echo "${INPUT}" | jq -r '.config_file_path')

SERVER=$(oc whoami --show-server | sed -e 's|^[^/]*//||' -e 's|/.*$||' -e 's|:.*$||')
echo "{\"status\": \"success\", \"message\": \"success\", \"server\": \"${SERVER}\"}"
