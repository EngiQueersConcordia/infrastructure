#!/usr/bin/env bash

# This script updates all encrypted files to reflect the new keys in .sops.yaml

set -euo pipefail

if [ "$#" -eq 0 ]; then
  source "$(dirname "$0")"/.filelist
  "$0" "${SOPS_FILES[@]/#/$(dirname "$0")\/..\/}"
  exit 0
fi

for i in "$@"; do
  i=$(realpath -s "--relative-to=$PWD" -- "$i")
  echo "Updating $i..."

  sops updatekeys -y "$i"
done

