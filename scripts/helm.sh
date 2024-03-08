#!/usr/bin/env bash
echo
#echo "# arguments called with ---->  ${@}     "
#echo "# \$1 ---------------------->  $1       "
#echo "# \$2 ---------------------->  $2       "
echo "# path to me --------------->  ${0}     "
echo "# parent path -------------->  ${0%/*}  "
echo "# my name ------------------>  ${0##*/} "
echo

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
# helm repo add hashicorp https://helm.releases.hashicorp.co
helm repo add lwolf-charts http://charts.lwolf.org
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo add keyporttech https://keyporttech.github.io/helm-charts/
helm repo add agones https://agones.dev/chart/stable
helm repo add drone https://charts.drone.io
helm repo add stakater https://stakater.github.io/stakater-charts
helm repo add ananace-charts https://ananace.gitlab.io/charts
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo add cilium https://helm.cilium.io

helm repo add portainer https://portainer.github.io/k8s/

helm repo update

set +x
echo "END ------------------>  ${0##*/} "
echo
