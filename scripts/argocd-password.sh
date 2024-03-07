#!/usr/bin/env bash
echo
echo "# arguments called with ---->  ${@}     "
echo "# \$1 ---------------------->  $1       "
echo "# \$2 ---------------------->  $2       "
echo "# path to me --------------->  ${0}     "
echo "# parent path -------------->  ${0%/*}  "
echo ""# my "name ------------------>  ${0##*/} "
echo


set -euxo pipefail

kubectx k3d-demo

echo -e "\nYour ArgoCD Admin user password is "
_PASS=$(kubectl --cluster=k3d-demo -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo $_PASS
