#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/.."

readarray -t files < <(grep "^sops:" -Ri --files-with-matches | sort)

echo "SOPS_FILES=(" > script/.filelist
for file in "${files[@]}"; do
  :
  echo "  '$file'" >> script/.filelist
done
echo ")" >> script/.filelist
