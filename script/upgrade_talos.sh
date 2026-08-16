#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."
source script/.config

echo "==Upgrading ENA=="
talosctl upgrade --nodes ena.engiqueersconcordia.ca --image "ghcr.io/siderolabs/installer:$TALOS_VERSION"

echo "Sleeping 5 minutes to let the system settle"
sleep 5m

echo "==Upgrading Jenny=="
talosctl upgrade --nodes jenny.engiqueersconcordia.ca --image "ghcr.io/siderolabs/installer:$TALOS_VERSION"
