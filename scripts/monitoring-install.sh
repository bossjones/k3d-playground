#!/usr/bin/env bash
# set -euxo pipefail
set -x

kubectx k3d-demo

# # cd apps/argocd/base/monitoring/kube-prometheus-stack
# kubectl create namespace argocd || true
kustomize build --enable-alpha-plugins --enable-exec apps/argocd/base/monitoring/kube-prometheus-stack | kubectl apply -f -

# # SOURCE: https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
# yes | pv -SL1 -F 'Resuming in %e' -s 10 > /dev/null

kustomize build --enable-alpha-plugins --enable-exec apps/argocd/base/monitoring/kube-prometheus-stack | kubectl apply -f -
# kubectl wait deploy/argocd-server -n argocd --for condition=available --timeout=600s
echo ""
# cd -


# # sleep
# # SOURCE: https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
# yes | pv -SL1 -F 'Resuming in %e' -s 30 > /dev/null

# takes a second for everything to come up, so lets run this twice

kubectx k3d-demo

# cd apps/argocd/base/monitoring/kube-prometheus-stack

kubectl create namespace argocd 2>/dev/null || true
kustomize build --enable-alpha-plugins --enable-exec apps/argocd/base/monitoring/kube-prometheus-stack | kubectl apply -f -

# # sleep
# # SOURCE: https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
# yes | pv -SL1 -F 'Resuming in %e' -s 10 > /dev/null

kustomize build --enable-alpha-plugins --enable-exec apps/argocd/base/monitoring/kube-prometheus-stack | kubectl apply -f -
kubectl wait deploy/argocd-server -n argocd --for condition=available --timeout=600s
echo ""
# cd -
