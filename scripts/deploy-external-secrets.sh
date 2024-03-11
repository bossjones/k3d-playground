#!/usr/bin/env bash
# set -euxo pipefail
echo ""
#echo "# arguments called with ---->  ${@}     "
#echo "# \$1 ---------------------->  $1       "
#echo "# \$2 ---------------------->  $2       "
echo "# path to me --------------->  ${0}     "
echo "# parent path -------------->  ${0%/*}  "
echo "# my name ------------------>  ${0##*/} "
echo ""


set -x
helm repo add connect https://1password.github.io/connect-helm-charts || true
helm repo add external-secrets https://charts.external-secrets.io || true
helm repo update
helm template --version 0.9.11 --values apps/argocd/base/kube-system/external-secrets/app/external-secrets/values.yaml external-secrets external-secrets/external-secrets -n kube-system | kubectl apply --server-side -f -
helm template --version 1.14.0 --values apps/argocd/base/kube-system/external-secrets/app/external-secrets/values.yaml connect connect/connect -n kube-system | kubectl apply --server-side -f -


# kubectl -n kube-system apply --server-side -f https://raw.githubusercontent.com/external-secrets/external-secrets/v0.9.11/deploy/crds/bundle.yaml 2>/dev/null || true


# set +ex
# kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/kube-system/external-secrets | kubectl apply --server-side -f -

# rm -rf apps/argocd/base/kube-system/external-secrets/app/connect/charts || true
# rm -rf apps/argocd/base/kube-system/external-secrets/app/external-secrets/charts || true
# rm -rf apps/argocd/base/kube-system/external-secrets/charts/ || true


# # https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
# yes | pv -SL1 -F 'Resuming in %e' -s 60 > /dev/null
# echo ""

set -euxo pipefail
# echo "waiting for external-secrets"
# kubectl -n kube-system wait deployment external-secrets-cert-controller --for condition=Available=True --timeout=300s
# kubectl -n kube-system wait deployment external-secrets-webhook --for condition=Available=True --timeout=300s
# kubectl -n kube-system wait deployment external-secrets --for condition=Available=True --timeout=300s
# kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/database/cloudnative-pg | kubectl apply --server-side -f -
retry -t 10 -- kubectl -n kube-system wait deployment external-secrets-webhook --for condition=Available=True --timeout=300s
retry -t 10 -- kubectl -n kube-system wait deployment external-secrets-cert-controller  --for condition=Available=True --timeout=300s

set +x
echo "END ------------------>  ${0##*/} "
echo ""
