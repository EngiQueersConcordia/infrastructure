#!/usr/bin/env bash

# This script decrypts and reencrypts all files to apply changes in .sops.yaml that aren't caught by sops updatekeys.

set -euo pipefail

if [ "$#" -eq 0 ]; then
  source "$(dirname "$0")"/.config
  "$0" "${SOPS_FILES[@]/#/$(dirname "$0")\/..\/}"
  exit 0
fi

for i in "$@"; do
  i=$(realpath -s "--relative-to=$PWD" -- "$i")
  echo "Re-encrypting $i..."

  sops exec-file "$i" "sh -c 'sops encrypt \"\$1\" --filename-override \"$i\" --output \"$i\"' _ {}"
done

