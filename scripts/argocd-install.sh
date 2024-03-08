#!/usr/bin/env bash
# set -euxo pipefail
# shellcheck disable=SC3036

echo
echo "# arguments called with ---->  ${@}     "
echo "# \$1 ---------------------->  $1       "
echo "# \$2 ---------------------->  $2       "
echo "# path to me --------------->  ${0}     "
echo "# parent path -------------->  ${0%/*}  "
echo "# my name ------------------>  ${0##*/} "
echo


set -x

kubectx k3d-demo


# cd apps/argocd
kubectl create namespace argocd 2>/dev/null || true

# install crds first for argocd
kubectl -n argocd apply --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.8.9/manifests/crds/application-crd.yaml
kubectl -n argocd apply --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.8.9/manifests/crds/applicationset-crd.yaml
kubectl -n argocd apply --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.8.9/manifests/crds/appproject-crd.yaml

echo ""
echo ""

kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd | kubectl apply --server-side -f -

echo ""
echo ""
# sleep
# SOURCE: https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
yes | pv -SL1 -F 'Resuming in %e' -s 10 > /dev/null

kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/core/ingress-nginx | kubectl apply --server-side -f -
echo ""
echo ""
# kustomize build --enable-alpha-plugins --enable-exec apps/argocd/base/core/ingress-nginx | kubectl apply --server-side  -f -
kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd | kubectl apply --server-side -f -
echo ""
echo ""

echo -e "waiting for argocd-server\n"
kubectl wait deploy/argocd-server -n argocd --for condition=available --timeout=600s
echo ""

echo -e "waiting for argocd-repo-server\n"
kubectl wait deploy/argocd-repo-server -n argocd --for condition=available --timeout=600s
echo ""

echo -e "waiting for argocd-repo-server\n"
kubectl wait deploy/argocd-redis -n argocd --for condition=available --timeout=600s
echo ""

echo -e "waiting for argocd-repo-server\n"
kubectl wait deploy/argocd-dex-server -n argocd --for condition=available --timeout=600s
echo ""


echo -e "waiting for argocd-repo-server\n"
kubectl wait deploy/argocd-applicationset-controller -n argocd --for condition=available --timeout=600s
echo ""


# cd -

# kubectl -n kube-system apply --server-side -f https://raw.githubusercontent.com/external-secrets/external-secrets/v0.9.11/deploy/crds/bundle.yaml || true
# retry -t 4  -- kubectl -n kube-system apply --server-side -f apps/argocd/base/kube-system/external-secrets/app/connect/clusterStore.yaml


# kustomize build --enable-alpha-plugins --enable-exec --enable-helm apps/argocd/base/kube-system/external-secrets | kubectl apply --server-side -f -
just deploy-external-secrets


# sleep
# SOURCE: https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
yes | pv -SL1 -F 'Resuming in %e' -s 60 > /dev/null

# external-secrets-webhook           1/1     1            1           2m10s
# external-secrets-cert-controller   1/1     1            1           2m10s

# kustomize build --enable-alpha-plugins --enable-exec apps/argocd/base/kube-system/external-secrets | kubectl apply --server-side -f -
# echo "waiting for external-secrets"
# kubectl -n kube-system wait deployment external-secrets-cert-controller --for condition=Available=True --timeout=300s
# kubectl -n kube-system wait deploy/external-secrets-webhook --for condition=Available=True --timeout=300s
# kubectl -n kube-system wait deploy/external-secrets-cert-controller  --for condition=Available=True --timeout=300s

# # sleep
# # SOURCE: https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
# yes | pv -SL1 -F 'Resuming in %e' -s 30 > /dev/null

# takes a second for everything to come up, so lets run this twice

kubectx k3d-demo

# commenting out the 2nd apply, as it's not needed
# # cd apps/argocd
# kubectl create namespace argocd 2>/dev/null || true
# kustomize build --enable-alpha-plugins --enable-exec apps/argocd | kubectl apply --server-side -f -

# kustomize build --enable-alpha-plugins --enable-exec apps/argocd | kubectl apply --server-side -f -
# kubectl wait deploy/argocd-server -n argocd --for condition=available --timeout=600s
# echo ""
# # cd -

set +x
echo "END ------------------>  ${0##*/} "
echo
