#!/usr/bin/env bash
set -euxo pipefail

kubectx k3d-demo

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

cd "${1}"
kustomize build --enable-alpha-plugins --enable-exec | kubectl apply -f -
# sleep
# SOURCE: https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
yes | pv -SL1 -F 'Resuming in %e' -s 10 > /dev/null
kustomize build --enable-alpha-plugins --enable-exec | kubectl apply -f -
echo ""
cd -

# sleep
# SOURCE: https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
yes | pv -SL1 -F 'Resuming in %e' -s 30 > /dev/null

# takes a second for everything to come up, so lets run this twice

kubectx k3d-demo

cd "${1}"
kustomize build --enable-alpha-plugins --enable-exec | kubectl apply -f -
# sleep
# SOURCE: https://unix.stackexchange.com/questions/600868/verbose-sleep-command-that-displays-pending-time-seconds-minutes/600871#600871
yes | pv -SL1 -F 'Resuming in %e' -s 10 > /dev/null
kustomize build --enable-alpha-plugins --enable-exec | kubectl apply -f -
echo ""
cd -
