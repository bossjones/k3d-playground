#!/usr/bin/env bash
# set -euxo pipefail
echo
echo "# arguments called with ---->  ${@}     "
echo "# \$1 ---------------------->  $1       "
echo "# \$2 ---------------------->  $2       "
echo "# path to me --------------->  ${0}     "
echo "# parent path -------------->  ${0%/*}  "
echo "# my name ------------------>  ${0##*/} "
echo


set -x

# crds
kubectl create namespace cert-manager 2>/dev/null || true
kubectl -n cert-manager apply --server-side -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml 2>/dev/null || true

helm repo add cert-manager https://charts.jetstack.io || true
helm repo update

# https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
yes | pv -SL1 -F 'Resuming in %e' -s 25 > /dev/null

kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/monitoring/cert-manager | kubectl apply --server-side -f -

echo ""
echo ""
# sleep
# SOURCE: https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
yes | pv -SL1 -F 'Resuming in %e' -s 10 > /dev/null
echo

echo -e "waiting for cert-manager\n"
kubectl wait deploy/cert-manager -n cert-manager --for condition=available --timeout=600s
echo ""

echo -e "waiting for cert-manager-cainjector\n"
kubectl wait deploy/cert-manager-cainjector -n cert-manager --for condition=available --timeout=600s
echo ""

echo -e "waiting for cert-manager-webhook\n"
kubectl wait deploy/cert-manager-webhook -n cert-manager --for condition=available --timeout=600s
echo ""

# deployment.apps/cert-manager              1/1     1            1           12m
# deployment.apps/cert-manager-cainjector   1/1     1            1           12m
# deployment.apps/cert-manager-webhook      1/1     1            1           12m


echo "END ------------------>  ${0##*/} "
echo
