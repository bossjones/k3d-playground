#!/usr/bin/env bash
set -euxo pipefail

# export GIT_URI=$(git config --get remote.origin.url)
export GIT_URI="https://github.com/bossjones/k3d-playground"

kubectx k3d-demo

# - task: argocd
kubectl -n argocd apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  # project: core
  project: cluster
  source:
    repoURL: '$GIT_URI'
    path: apps/argocd
    targetRevision: HEAD
  destination:
    namespace: argocd
    name: in-cluster
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: true
    syncOptions:
    - Validate=true
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
    - PruneLast=true
    - ApplyOutOfSyncOnly=false
    - Prune=true
    retry:
      limit: -1
      backoff:
        duration: 20s
        factor: 2
        maxDuration: 15m
EOF

# certificate
kubectl -n argocd apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  # project: core
  project: cluster
  source:
    repoURL: '$GIT_URI'
    path: apps/argocd
    targetRevision: HEAD
  destination:
    namespace: argocd
    name: in-cluster
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: true
    syncOptions:
    - Validate=true
    - CreateNamespace=false
    - PrunePropagationPolicy=foreground
    - PruneLast=true
    - ApplyOutOfSyncOnly=false
    - Prune=true
    retry:
      limit: -1
      backoff:
        duration: 20s
        factor: 2
        maxDuration: 15m
EOF

# zalando
kubectl -n argocd apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: postgres
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster
  source:
    repoURL: '$GIT_URI'
    path: apps/databases/zalando
    targetRevision: HEAD
  destination:
    namespace: databases
    name: in-cluster
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: true
    syncOptions:
    - Validate=false
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
    - PruneLast=true
    - ApplyOutOfSyncOnly=false
    - Prune=true
    retry:
      limit: -1
      backoff:
        duration: 20s
        factor: 2
        maxDuration: 15m
EOF

# # example
# kubectl -n argocd apply -f - <<EOF
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: example-app
#   finalizers:
#     - resources-finalizer.argocd.argoproj.io
# spec:
#   # project: apps
#   project: cluster
#   source:
#     repoURL: '$GIT_URI'
#     path: apps/example
#     targetRevision: HEAD
#   destination:
#     namespace: example
#     name: in-cluster
#   syncPolicy:
#     automated:
#       prune: true
#       selfHeal: true
#       allowEmpty: true
#     syncOptions:
#     - Validate=true
#     - CreateNamespace=true
#     - PrunePropagationPolicy=foreground
#     - PruneLast=true
#     - ApplyOutOfSyncOnly=false
#     - Prune=true
#     retry:
#       limit: -1
#       backoff:
#         duration: 20s
#         factor: 2
#         maxDuration: 15m
# EOF
