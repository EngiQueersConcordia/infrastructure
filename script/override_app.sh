#!/bin/bash

# This script sets an ArgoCD application to point to a PR instead of HEAD, or HEAD if only an appname is specifed.

set -euo pipefail

usage() {
  echo "Usage:"
  echo "$0 <PR number> <appname>"
  echo "$0 <appname>"
  exit 1
}

if [ "$#" -eq 2 ]; then
  echo "Setting app $2 to PR $1"
  argocd app set "$2" --revision "refs/pull/$1/merge"
elif [ "$#" -eq 1 ]; then
  echo "Resetting app $1..."
  argocd app set "$1" --revision "HEAD"
else
  usage
fi


