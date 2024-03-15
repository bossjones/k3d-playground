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


kubectl -n kube-system apply -f base/kube-system/dnsmasq/dnsmasq.yaml
kubectl -n kube-system apply -f base/kube-system/dnsmasq/dnsmasq-ha.yaml



set +x
echo "END ------------------>  ${0##*/} "
echo ""
