#!/usr/bin/env bash
set -e

kubectx k3d-demo

kubectl create namespace argocd || true

set -x
# SOURCE: https://github.com/viaduct-ai/kustomize-sops/blob/master/scripts/install-ksops.sh

# Require $XDG_CONFIG_HOME to be set
if [[ -z "$XDG_CONFIG_HOME" ]]; then
  echo "You must define XDG_CONFIG_HOME to use a legacy kustomize plugin"
  echo "Add 'export XDG_CONFIG_HOME=\$HOME/.config' to your .bashrc or .zshrc"
  exit 1
fi

# Require $SOPS_AGE_KEY_FILE to be set
if [[ -z "$SOPS_AGE_KEY_FILE" ]]; then
  echo "You must define SOPS_AGE_KEY_FILE to use a legacy kustomize plugin"
  echo "Add 'exportSOPS_AGE_KEY_FILE\$HOME/.sops/key.txt' to your .bashrc or .zshrc"
  exit 1
fi

cat "${SOPS_AGE_KEY_FILE}" | kubectl create secret generic sops-age \
--namespace=argocd \
--from-file=key.txt=/dev/stdin || true
