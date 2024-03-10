#!/usr/bin/env bash

while getopts n:a:h:c: flag
do
    case "${flag}" in
        n) namespace=${OPTARG};;
        a) app_name=${OPTARG};;
        h) helm_repo=${OPTARG};;
        c) chart_version=${OPTARG};;
    esac
done
echo "Namespace: $namespace";
echo "App: $app_name";
echo "Helm Repo: $helm_repo";
echo "Chart Version: $chart_version";
exit 0

# source .envrc

# base folder structure
mkdir -p apps/argocd/base/"${namespace}"/"${app_name}"/app
touch apps/argocd/base/"${namespace}"/"${app_name}"/app/values.yaml
cat <<EOF >>apps/argocd/base/"${namespace}"/"${app_name}"/kustomization.yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - app

# SOURCE: https://www.innoq.com/en/blog/2022/07/advanced-kustomize-features/#limitlabelsandannotationstospecificresourcesorfields
labels:
- pairs:
    monitoring: prometheus
    prometheus: main
EOF

cat <<EOF >>apps/argocd/base/"${namespace}"/"${app_name}"/app/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ${namespace}
  labels:
    monitoring: prometheus
    prometheus: main
    goldilocks.fairwinds.com/enabled: "true"
EOF

cat <<EOF >>apps/argocd/base/"${namespace}"/"${app_name}"/app/kustomization.yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - namespace.yaml
  - app.yaml
EOF

cat <<EOF >>apps/argocd/base/"${namespace}"/"${app_name}"/app/app.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${app_name}
  namespace: ${namespace}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster
  sources:
  - repoURL: '${helm_repo}'
    chart: ${app_name}
    targetRevision: ${chart_version}
    helm:
      releaseName: ${app_name}
      valueFiles:
        - \$values/apps/argocd/base/${namespace}/${app_name}/app/values.yaml
  - repoURL: 'https://github.com/bossjones/k3d-playground.git'
    targetRevision: HEAD
    path: apps/argocd/base/${namespace}/${app_name}
    ref: values
  destination:
    # server: "https://kubernetes.default.svc"
    name: in-cluster
    namespace: ${app_name}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      # - PruneLast=true
      - SkipDryRunOnMissingResource=true
      # - CreateNamespace=true
      # Needed because our kubectl apply exceeds thresholds
      # EXAMPLE: CustomResourceDefinition.apiextensions.k8s.io "prometheuses.gitea.coreos.com" is invalid: metadata.annotations: Too long: must have at most 262144 bytes
      # SOURCE: https://github.com/prometheus-operator/prometheus-operator/issues/4355
      - ServerSideApply=true
      - Prune=true
    # NOTE: 2/12/2024 - IF THIS BREAKS, CONFIGURE IN THESE VALUES AND COMMENT OUT THE OTHER RETRY BLOCK
    retry:
      limit: -1  # Max number of allowed sync retries
      backoff:
        duration: 20s # Retry backoff base duration. Input needs to be a duration (e.g. 2m, 1h) (default 5s)
        factor: 2 # Factor multiplies the base duration after each failed retry (default 2)
        maxDuration: 15m # Max retry backoff duration. Input needs to be a duration (e.g. 2m, 1h) (default 3m0s)
  # SOURCE: https://github.com/home-prod/k8s-infra/blob/82cbe52ba47597b52a7fc03eee4d1b526beab836/kubernetes/charts/infra/charts/logging/charts/gitea/templates/gitea-application.yaml#L32
  ignoreDifferences:
  - group: apps
    kind: DaemonSet
    jsonPointers:
      - /metadata/annotations
  - kind: PersistentVolume
    jsonPointers:
      - /spec/claimRef/resourceVersion
      - /spec/claimRef/uid
      - /status/lastPhaseTransitionTime
  # SOURCE: https://github.com/home-prod/k8s-infra/blob/82cbe52ba47597b52a7fc03eee4d1b526beab836/kubernetes/charts/infra/charts/logging/charts/loki/templates/loki-application.yaml
  - group: apps
    kind: StatefulSet
    jsonPointers:
      - /spec/persistentVolumeClaimRetentionPolicy
  - group: apps
    kind: StatefulSet
    jqPathExpressions:
      - .spec.volumeClaimTemplates[]?.apiVersion
      - .spec.volumeClaimTemplates[]?.kind
  - group: monitoring.coreos.com
    kind: ServiceMonitor
    jqPathExpressions:
    - .spec.endpoints[]?.relabelings[]?.action
  - group: monitoring.coreos.com
    kind: ServiceMonitor
    jqPathExpressions:
    - .spec.endpoints[]?.metricRelabelings[]?.action
  # SOURCE: https://github.com/home-prod/k8s-infra/blob/82cbe52ba47597b52a7fc03eee4d1b526beab836/kubernetes/charts/infra/charts/monitoring/charts/kube-prometheus-stack/templates/kube-prometheus-stack-application.yaml
  - group: admissionregistration.k8s.io
    kind: ValidatingWebhookConfiguration
    jsonPointers:
      - /webhooks/0/failurePolicy
  - group: admissionregistration.k8s.io
    kind: MutatingWebhookConfiguration
    jsonPointers:
      - /webhooks/0/failurePolicy
EOF
