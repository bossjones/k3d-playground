#!/usr/bin/env bash
# set -euxo pipefail
set -x

kubectx k3d-demo

# cd apps/argocd
kubectl create namespace argocd || true
kustomize build --enable-alpha-plugins --enable-exec apps/argocd | kubectl apply -f -
sleep 10
kustomize build --enable-alpha-plugins --enable-exec apps/argocd/base/core/ingress-nginx | kubectl apply --server-side  -f -
kustomize build --enable-alpha-plugins --enable-exec apps/argocd | kubectl apply -f -
kubectl wait deploy/argocd-server -n argocd --for condition=available --timeout=600s
echo ""
# cd -

sleep 30

# takes a second for everything to come up, so lets run this twice

kubectx k3d-demo

# cd apps/argocd
kubectl create namespace argocd || true
kustomize build --enable-alpha-plugins --enable-exec apps/argocd | kubectl apply -f -
sleep 10
kustomize build --enable-alpha-plugins --enable-exec apps/argocd | kubectl apply -f -
kubectl wait deploy/argocd-server -n argocd --for condition=available --timeout=600s
echo ""
# cd -


retry -t 4  -- kubectl -n kube-system apply -f apps/argocd/base/kube-system/external-secrets/app/connect/clusterStore.yaml
