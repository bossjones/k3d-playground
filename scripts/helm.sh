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

# local-gitops
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo add hashicorp https://helm.releases.hashicorp.co
helm repo add lwolf-charts http://charts.lwolf.org
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo add keyporttech https://keyporttech.github.io/helm-charts/
helm repo add agones https://agones.dev/chart/stable
helm repo add drone https://charts.drone.io
helm repo add stakater https://stakater.github.io/stakater-charts
helm repo add ananace-charts https://ananace.gitlab.io/charts
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets

helm repo update

helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
