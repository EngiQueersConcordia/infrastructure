#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."
source script/.config

echo "==Upgrading ENA=="
talosctl upgrade --nodes ena.engiqueersconcordia.ca --image "factory.talos.dev/metal-installer/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba:$TALOS_VERSION"

echo "Sleeping 5 minutes to let the system settle"
sleep 5m

echo "==Upgrading Jenny=="
talosctl upgrade --nodes jenny.engiqueersconcordia.ca --image "factory.talos.dev/metal-installer/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba:$TALOS_VERSION"
