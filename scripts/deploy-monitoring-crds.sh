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

# set -x

# SOURCE: https://github.com/keunlee/k3d-metallb-starter-kit/blob/master/scripts/create-cluster.sh

kubectx k3d-demo

_API_RESOURCES=$(kubectl api-resources)

# shellcheck disable=SC3010
if [[ $_API_RESOURCES != *"monitoring.coreos.com"* ]]; then
    kubectl create namespace monitoring 2>/dev/null || true
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

    echo "lets let the crds settle for a minute"
    yes | pv -SL1 -F 'Resuming in %e' -s 60 > /dev/null
    echo ""
fi





set +x
echo "END ------------------>  ${0##*/} "
echo ""
