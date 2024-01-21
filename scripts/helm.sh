#!/usr/bin/env bash

cd ~/dev/bossjones/k3d-playground || exit

mkdir vendor/prometheus-community || true
cd vendor/prometheus-community || exit
git clone https://github.com/prometheus-community/helm-charts || git pull --rebase
cd - || exit
mkdir vendor/grafana || true
cd vendor/grafana || exit
git clone https://github.com/grafana/helm-charts || git pull --rebase
cd - || exit
mkdir vendor/vectordotdev || true
cd vendor/vectordotdev || exit
git clone https://github.com/vectordotdev/helm-charts || git pull --rebase
cd - || exit

helm repo add influxdata https://helm.influxdata.com/
helm repo add bitnami https://charts.bitnami.com/bitnami
# helm install my-release oci://registry-1.docker.io/bitnamicharts/memcached
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
