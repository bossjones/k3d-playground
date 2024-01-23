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
