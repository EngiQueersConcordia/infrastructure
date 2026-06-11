#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/.."

readarray -t files < <(grep "^sops:" -Ri --files-with-matches | sort)

echo "SOPS_FILES=(" > script/.config
for file in "${files[@]}"; do
  :
  echo "  '$file'" >> script/.config
done
echo ")" >> script/.config
