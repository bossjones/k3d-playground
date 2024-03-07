#!/usr/bin/env bash
# set -euxo pipefail
set -x

kustomize build --enable-alpha-plugins --enable-exec apps/argocd/base/kube-system/external-secrets | kubectl apply --server-side -f -
# echo "waiting for external-secrets"
# kubectl -n kube-system wait deployment external-secrets-cert-controller --for condition=Available=True --timeout=300s
# kubectl -n kube-system wait deployment external-secrets-webhook --for condition=Available=True --timeout=300s
# kubectl -n kube-system wait deployment external-secrets --for condition=Available=True --timeout=300s
