#!/usr/bin/env bash
set -euxo pipefail

kubectx k3d-demo

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

cd "${1}"
kustomize build . --enable-helm >~/dev/bossjones/k3d-playground/dump/rendered/rendered.yaml
