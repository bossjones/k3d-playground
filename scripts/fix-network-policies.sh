#!/usr/bin/env bash
# set -euxo pipefail

kubectx k3d-demo

# Produce ENV for all pods, assuming you have a default container for the pods, default namespace and the `env` command is supported.
# Helpful when running any supported command across all pods, not just `env`
for ns in $(kubectl get ns --output=jsonpath={.items..metadata.name}); do echo $ns && kubectl -n $ns apply -f generic-allow-all-egress.yaml; done
