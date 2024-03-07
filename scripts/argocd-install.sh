#!/usr/bin/env bash
# set -euxo pipefail
set -x

kubectx k3d-demo


# cd apps/argocd
kubectl create namespace argocd 2>/dev/null || true
kustomize build --enable-alpha-plugins --enable-exec apps/argocd | kubectl apply --server-side -f -
sleep 10
kustomize build --enable-alpha-plugins --enable-exec apps/argocd/base/core/ingress-nginx | kubectl apply --server-side  -f -
kustomize build --enable-alpha-plugins --enable-exec apps/argocd | kubectl apply --server-side -f -
kubectl wait deploy/argocd-server -n argocd --for condition=available --timeout=600s
echo ""
# cd -

kubectl -n kube-system apply --server-side -f https://raw.githubusercontent.com/external-secrets/external-secrets/v0.9.11/deploy/crds/bundle.yaml || true
retry -t 4  -- kubectl -n kube-system apply --server-side -f apps/argocd/base/kube-system/external-secrets/app/connect/clusterStore.yaml

sleep 30

# takes a second for everything to come up, so lets run this twice

kubectx k3d-demo

# cd apps/argocd
kubectl create namespace argocd 2>/dev/null || true
kustomize build --enable-alpha-plugins --enable-exec apps/argocd | kubectl apply --server-side -f -
sleep 10
kustomize build --enable-alpha-plugins --enable-exec apps/argocd | kubectl apply --server-side -f -
kubectl wait deploy/argocd-server -n argocd --for condition=available --timeout=600s
echo ""
# cd -
