#!/usr/bin/env bash
# set -euxo pipefail
set -x

kubectl create namespace monitoring || true
kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
kubectl -n kube-system apply --server-side -f https://raw.githubusercontent.com/external-secrets/external-secrets/v0.9.11/deploy/crds/bundle.yaml || true


helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx || true
helm repo update
helm template --version 4.9.0 --values apps/argocd/base/core/ingress-nginx/app/values.yaml ingress-nginx ingress-nginx/ingress-nginx -n kube-system | kubectl apply --server-side -f -

echo "waiting for ingress-nginx deployment.apps/ingress-nginx-controller"
kubectl -n kube-system wait deployment ingress-nginx-controller --for condition=Available=True --timeout=300s
