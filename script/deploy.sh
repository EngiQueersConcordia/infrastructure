#!/usr/bin/env bash

# This script deploys talos config

set -euo pipefail

cd "$(dirname "$0")/.."
source script/.filelist

usage() {
  echo "Usage: $0 <ena | jenny | talosconfig> [extra args...]"
  exit 1
}

cleanup() {
  if [[ -n "$decrypted_dir" ]]; then
    rm -rf "$decrypted_dir"
  fi
  rm -f talos/controlplane.yaml talos/worker.yaml talos/talosconfig
}
trap 'cleanup' EXIT

if [ "$#" -eq 0 ]; then
  usage
fi

host=$1
extra_args=("${@:2}")

# Create folder to hold decrypted patches
decrypted_dir=$(readlink -f "talos/patches_decrypted")
rm -rf "$decrypted_dir"
cp -r talos/patches "$decrypted_dir"
for encrypted_file in "${SOPS_FILES[@]}"; do
  # Only consider files in patches
  if [[ "$encrypted_file" != talos/patches/* ]]; then
    continue
  fi

  encrypted_file="${encrypted_file/\/patches\//\/patches_decrypted\/}"
  echo "Decrypting $(basename "$encrypted_file")..."
  sops decrypt -i "$encrypted_file"
done

# shellcheck disable=SC2016
(
cd talos
sops exec-file secrets.yaml "sh -c 'talosctl gen config engiqueers https://cluster.engiqueersconcordia.ca:6443 --force --with-secrets \"\$1\" --kubernetes-version v1.36.0 --talos-version v1.13.2 --additional-sans cluster.engiqueersconcordia.ca' _ \"{}\""
)

case $host in
talosconfig)
  talosctl config merge talos/talosconfig
  talosctl config endpoint cluster.engiqueersconcordia.ca
  ;;
ena)
  patches=("$decrypted_dir"/ena/*.yaml "$decrypted_dir"/controlplane/*.yaml "$decrypted_dir"/all/*.yaml)
  # shellcheck disable=SC2068
  talosctl apply-config --nodes ena.engiqueersconcordia.ca --file talos/controlplane.yaml ${patches[@]/#/--config-patch } "${extra_args[@]}"
  ;;
jenny)
  patches=("$decrypted_dir"/jenny/*.yaml "$decrypted_dir"/controlplane/*.yaml "$decrypted_dir"/all/*.yaml)
  # shellcheck disable=SC2068
  talosctl apply-config --nodes jenny.engiqueersconcordia.ca --file talos/controlplane.yaml ${patches[@]/#/--config-patch } "${extra_args[@]}"
  ;;
*)
  echo "Unknown host $1"
  usage
  ;;
esac