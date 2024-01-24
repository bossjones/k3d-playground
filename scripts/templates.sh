#!/usr/bin/env bash
set -euxo pipefail

export GIT_URI=$(git config --get remote.origin.url)

kubectx k3d-demo

# - task: argocd
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: core
  source:
    repoURL: '$GIT_URI'
    path: apps/argocd
    targetRevision: main
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
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: core
  source:
    repoURL: '$GIT_URI'
    path: apps/argocd
    targetRevision: main
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
kubectl apply -f - <<EOF
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
    targetRevision: main
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

# example
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: example-app
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: apps
  source:
    repoURL: '$GIT_URI'
    path: apps/example
    targetRevision: main
  destination:
    namespace: example
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

# # monitoring
# kubectl apply -f - <<EOF
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: example-app
#   finalizers:
#     - resources-finalizer.argocd.argoproj.io
# spec:
#   project: apps
#   source:
#     repoURL: '$GIT_URI'
#     path: apps/monitoring/kube-prometheus-stack
#     targetRevision: main
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

# ####################################
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: kube-prometheus-stack
#   finalizers:
#     - resources-finalizer.argocd.argoproj.io
# spec:
#   project: monitoring
#   sources:
#     - repoURL: https://prometheus-community.github.io/helm-charts
#       chart: kube-prometheus-stack
#       targetRevision: 48.2.2
#       helm:
#         releaseName: kube-prometheus-stack
#         # Helm values files for overriding values in the helm chart
#         # The path is relative to the spec.source.path directory defined above
#         valueFiles:
#           - apps/argocd/base/monitoring/kube-prometheus-stack/values.yaml
#     - repoURL: 'https://github.com/bossjones/k3d-playground.git' # Can point to either a Helm chart repo or a git repo.
#       targetRevision: main # For Helm, this refers to the chart version.
#       path: apps/argocd/base/monitoring/kube-prometheus-stack # This has no meaning for Helm charts pulled directly from a Helm repo instead of git.
#       ref: values # For Helm, acts as a reference to this source for fetching values files from this source. Has no meaning when under `source` field
#   destination:
#     namespace: monitoring
#     name: in-cluster
#   syncPolicy:
#     automated:
#       prune: true
#       selfHeal: true
#       allowEmpty: true
#     syncOptions:
#     - Validate=false
#     - CreateNamespace=true
#     - PrunePropagationPolicy=foreground
#     - PruneLast=false
#     - ApplyOutOfSyncOnly=false
#     - Prune=true
#     retry:
#       limit: -1
#       backoff:
#         duration: 20s
#         factor: 2
#         maxDuration: 15m

# EOF
