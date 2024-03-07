#!/usr/bin/env bash
# set -euxo pipefail
set -x
helm repo add connect https://1password.github.io/connect-helm-charts || true
helm repo add external-secrets https://charts.external-secrets.io || true
helm repo update

kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/kube-system/external-secrets | kubectl apply --server-side -f -
# echo "waiting for external-secrets"
# kubectl -n kube-system wait deployment external-secrets-cert-controller --for condition=Available=True --timeout=300s
# kubectl -n kube-system wait deployment external-secrets-webhook --for condition=Available=True --timeout=300s
# kubectl -n kube-system wait deployment external-secrets --for condition=Available=True --timeout=300s
# kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/database/cloudnative-pg | kubectl apply --server-side -f -
