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

just monitoring-crds

cd deploy/externalsecrets-with-hashicorp-vault-kubernetes-easy-install || exit

helmfile sync

echo "lets let the helmfile sync settle for a minute"
yes | pv -SL1 -F 'Resuming in %e' -s 20 > /dev/null
echo ""

kubectl apply -f extsecret-example.yaml

# vault kv put app/dev/test

set +x
echo "END ------------------>  ${0##*/} "
echo ""
