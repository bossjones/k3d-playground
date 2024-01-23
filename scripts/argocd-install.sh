#!/usr/bin/env bash
set -euxo pipefail

kubectx k3d-demo

cd apps/argocd
kubectl create namespace argocd
kustomize build | kubectl apply -f -
sleep 10
kustomize build | kubectl apply -f -
kubectl wait deploy/argocd-server -n argocd --for condition=available --timeout=600s
echo ""
cd -
