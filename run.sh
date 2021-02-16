#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Determine the directory with files
SCRIPT_DIR="$(realpath "$(dirname "${0}")")"

docker run \
	--name 'ostoslista-api' \
	--detach \
	--restart 'always' \
	--label 'traefik.enable=true' \
	'mireiawen/ostoslista-webhook'
