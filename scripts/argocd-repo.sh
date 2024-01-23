#!/usr/bin/env bash
set -euxo pipefail

kubectx k3d-demo

export GIT_URI=$(git config --get remote.origin.url | sed -e 's/:/\//g' | sed -e 's/ssh\/\/\///g' | sed -e 's/git@/https:\/\//g' | sed 's/.git$//')

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: main-repository
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: ${GIT_URI}
  password: ${GH_PASS}
  username: ${GH_USER}
EOF
