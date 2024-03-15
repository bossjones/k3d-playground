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

just monitoring-crds
kubectl -n kube-system apply --server-side -f https://raw.githubusercontent.com/external-secrets/external-secrets/v0.9.11/deploy/crds/bundle.yaml || true


helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx || true
helm repo update
helm template --version 4.9.0 --values apps/argocd/base/core/ingress-nginx/app/values.yaml ingress-nginx ingress-nginx/ingress-nginx -n kube-system | kubectl apply --server-side -f -

just certs-only

# kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/core/ingress-nginx | kubectl apply --server-side -f -

# rm -rf apps/argocd/base/core/ingress-nginx/charts || true

echo ""
echo ""

echo "waiting for ingress-nginx deployment.apps/ingress-nginx-controller"
kubectl -n kube-system wait deployment ingress-nginx-controller --for condition=Available=True --timeout=300s

set +x
echo "END ------------------>  ${0##*/} "
echo ""
