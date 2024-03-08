#!/usr/bin/env bash

echo
#echo "# arguments called with ---->  ${@}     "
#echo "# \$1 ---------------------->  $1       "
#echo "# \$2 ---------------------->  $2       "
echo "# path to me --------------->  ${0}     "
echo "# parent path -------------->  ${0%/*}  "
echo "# my name ------------------>  ${0##*/} "
echo


kubectx k3d-demo

kubectl create namespace argocd 2>/dev/null || true
yes | pv -SL1 -F 'Resuming in %e' -s 10 > /dev/null
echo

export GIT_URI=$(git config --get remote.origin.url | sed -e 's/:/\//g' | sed -e 's/ssh\/\/\///g' | sed -e 's/git@/https:\/\//g' | sed 's/.git$//')

set -euxo pipefail
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: git
  url: ${GIT_URI}
  password: ${GH_PASS}
  username: ${GH_USER}
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: git
  url: ${GIT_URI}
  password: ${GH_PASS}
  username: ${GH_USER}
EOF

echo ""
echo "END ------------------>  ${0##*/} "
echo
