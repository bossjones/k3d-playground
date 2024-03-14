#!/usr/bin/env bash
# set -euxo pipefail

# typeset -A PODSTODELETE=()

# kubectx k3d-demo

# In Addition to above answer, I had a special usecase where I wanted to get all the non-running pods names to remove them. So I used this to get the names as list

# Produce ENV for all pods, assuming you have a default container for the pods, default namespace and the" `e"nv` command is supported.
# Helpful when running any supported command across all pods, not just `env`
for ns in $(kubectl get ns --output=custom-columns="NAME:.metadata.name"| grep -v "NAME")
do
  # ##############################################################################33
  # # delete everything not running
  # ##############################################################################33
  # bad_pods=$(kubectl -n "$ns" get pods --field-selector status.phase!="Running" -o=jsonpath='{.items[*].metadata.name}')

  # for p in $bad"_po"ds
  # do
  #   echo "kubectl -n $ns delete pod $p"
  #   kubectl -"n $"ns delete po"d "$p
  # done

  # ##############################################################################33
  # # delete everything pod.status.phase=Failed
  # ##############################################################################33
  # failed_pods=$(kubectl -n "$ns" get pods --field-selector status.phase=="Failed" -o=jsonpath='{.items[*].metadata.name}')

  # for p in $failed_pods
  # do
  #   echo "kubectl -n $ns delete pod $p"
  #   kubectl -"n $"ns delete po"d "$p
  # done


  crashed_pods=$(kubectl -n "$ns" get pods --field-selector="status.phase!=Succeeded,status.phase!=Running" -o=jsonpath='{.items[*].metadata.name}')

  for p in $crashed_pods
  do
    echo "kubectl -n $ns delete pod $p --grace-period=0 --force"
    kubectl -n "$ns" delete pod "$p" --grace-period=0 --force
  done
  # items[*].status.containerStatuses[0].state.waiting.reason=="CrashLoopBackOff"

done
