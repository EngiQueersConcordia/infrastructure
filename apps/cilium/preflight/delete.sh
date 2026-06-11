#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

kustomize build --enable-helm | kubectl delete -f -