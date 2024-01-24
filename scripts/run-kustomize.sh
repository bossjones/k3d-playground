#!/usr/bin/env bash
set -euxo pipefail

kubectx k3d-demo

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

cd kubernetes/"${1}"
kustomize build | kubectl apply -f -
sleep 10
kustomize build | kubectl apply -f -
echo ""
cd -

sleep 30

# takes a second for everything to come up, so lets run this twice

kubectx k3d-demo

cd kubernetes/"${1}"
kustomize build | kubectl apply -f -
sleep 10
kustomize build | kubectl apply -f -
echo ""
cd -