#!/usr/bin/env bash
# set -euxo pipefail

echo ""
#echo "# arguments called with ---->  ${@}     "
#echo "# \$1 ---------------------->  $1       "
#echo "# \$2 ---------------------->  $2       "
echo "# path to me --------------->  ${0}     "
echo "# parent path -------------->  ${0%/*}  "
echo "# my name ------------------>  ${0##*/} "



kubectl create namespace identity 2>/dev/null || true
helm repo add authentik-redis https://bjw-s.github.io/helm-charts 2>/dev/null || true
helm repo update 2>/dev/null || true
# helm template --version 2.6.0 --values apps/argocd/base/identity/authentik-redis/app/values.yaml authentik-redis authentik-redis/authentik-redis -n identity | kubectl apply --server-side -f -

set -x
kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/identity/authentik-redis | kubectl apply --server-side -f -

# # https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
# yes | pv -SL1 -F 'Resuming in %e' -s 120 > /dev/null
# echo ""

kubectl create namespace databases 2>/dev/null || true
kubectl -n databases apply --server-side -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/v1.22.1/config/crd/bases/postgresql.cnpg.io_backups.yaml 2>/dev/null || true
kubectl -n databases apply --server-side -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/v1.22.1/config/crd/bases/postgresql.cnpg.io_clusters.yaml 2>/dev/null || true
kubectl -n databases apply --server-side -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/v1.22.1/config/crd/bases/postgresql.cnpg.io_poolers.yaml 2>/dev/null || true
kubectl -n databases apply --server-side -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/v1.22.1/config/crd/bases/postgresql.cnpg.io_scheduledbackups.yaml 2>/dev/null || true
helm repo add cloudnative-pg https://cloudnative-pg.github.io/charts 2>/dev/null || true
helm repo update 2>/dev/null || true
# helm template --version 0.20.1 --values apps/argocd/base/database/cloudnative-pg/app/operator/values.yaml cloudnative-pg cloudnative-pg/cloudnative-pg -n databases | kubectl apply --server-side -f -

set +ex
kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/database/cloudnative-pg | kubectl apply --server-side -f -

# https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
yes | pv -SL1 -F 'Resuming in %e' -s 120 > /dev/null
echo ""
# https://charts.goauthentik.io

# kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/kube-system/external-secrets apps/argocd/base/identity/authentik-redis | kubectl apply --server-side -f -
# kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/kube-system/external-secrets apps/argocd/base/database/cloudnative-pg | kubectl apply --server-side -f -

# helm repo add authentik https://charts.goauthentik.io 2>/dev/null || true
# helm repo update
# helm template --version 2023.10.7 --values apps/argocd/base/identity/authentik/app/values.yaml authentik authentik/authentik -n identity | kubectl apply --server-side -f -


set +x
echo "END ------------------>  ${0##*/} "
echo ""
