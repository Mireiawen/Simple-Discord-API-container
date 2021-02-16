#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Determine the directory with files
SCRIPT_DIR="$(realpath "$(dirname "${0}")")"

# Do the build
docker build "${SCRIPT_DIR}" --tag 'mireiawen/ostoslista-webhook'
