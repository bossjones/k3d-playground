#!/usr/bin/env bash
set -euxo pipefail

kubectx k3d-demo

echo -e "\nYour ArgoCD Admin user password is "
_PASS=$(kubectl --cluster=k3d-demo -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo $_PASS
