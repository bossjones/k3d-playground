#!/usr/bin/env bash
# set -euxo pipefail

kubectx k3d-demo

kubectl get serviceaccounts --all-namespaces --output=custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name" | awk '{ print $1":"$2 }'

# Produce ENV for all pods, assuming you have a default container for the pods, default namespace and the `env` command is supported.
# Helpful when running any supported command across all pods, not just `env`
for sa in $(kubectl get serviceaccounts --all-namespaces --output=custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name" | awk '{ print $1":"$2 }'); do echo "$sa" && audit2rbac -f audit/logs/audit.log --serviceaccount="$sa" --generate-labels="" --generate-annotations="" --generate-name=$(echo "${sa}" | cut -d":" -f2) >generated/sa-$(echo "${sa}" | cut -d":" -f1)-$(echo "${sa}" | cut -d":" -f2).yaml; done

# Specify the directory you want to check
a_directory="./generated"

# Loop through files in the a_directory
for afile in "$a_directory"/*; do
  # Check if the file is empty
  if [ ! -s "$afile" ]; then
    echo "$afile is empty. nuking..."
    cat "$afile"
    rm -vf $afile
  fi
done
