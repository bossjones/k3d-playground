#!/usr/bin/env bash
# set -euxo pipefail
set -x


kubectl create namespace identity 2>/dev/null || true
helm repo add authentik-redis https://bjw-s.github.io/helm-charts 2>/dev/null || true
helm repo update
# helm template --version 2.6.0 --values apps/argocd/base/identity/authentik-redis/app/values.yaml authentik-redis authentik-redis/authentik-redis -n identity | kubectl apply --server-side -f -

kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/identity/authentik-redis | kubectl apply --server-side -f -

kubectl create namespace databases 2>/dev/null || true
helm repo add cloudnative-pg https://cloudnative-pg.github.io/charts 2>/dev/null || true
helm repo update
# helm template --version 0.20.1 --values apps/argocd/base/database/cloudnative-pg/app/operator/values.yaml cloudnative-pg cloudnative-pg/cloudnative-pg -n databases | kubectl apply --server-side -f -

kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/database/cloudnative-pg | kubectl apply --server-side -f -
# https://charts.goauthentik.io

# kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/kube-system/external-secrets apps/argocd/base/identity/authentik-redis | kubectl apply --server-side -f -
# kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/kube-system/external-secrets apps/argocd/base/database/cloudnative-pg | kubectl apply --server-side -f -

# helm repo add authentik https://charts.goauthentik.io 2>/dev/null || true
# helm repo update
# helm template --version 2023.10.7 --values apps/argocd/base/identity/authentik/app/values.yaml authentik authentik/authentik -n identity | kubectl apply --server-side -f -
