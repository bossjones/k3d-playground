#!/usr/bin/env bash
set -euxo pipefail

kubectx k3d-demo

echo -e "\nYour ArgoCD Admin user password is "
kubectl config set-context --current --namespace=argocd --cluster=k3d-demo
_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo $_PASS
