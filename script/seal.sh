#!/bin/bash

# This script uses kubeseal to convert a sops secrets file into a sealed secret

set -euo pipefail

usage() {
  echo "Usage: $0 <SOPS file> <kubeseal file>"
  exit 1
}

if [ "$#" -ne 2 ]; then
  usage
fi

input=$1
output=$2

# shellcheck disable=SC2016
sops exec-file "$input" 'sh -c "kubeseal --allow-empty-data -f \"\$1\"" _ {}' > "$output"