#!/usr/bin/env bash
# set -euxo pipefail

# docker logs k3d-demo-server-0  &> k3d-demo-server-0.log
# docker container ls --format "{{.Names}}"
# k3d-demo-tools
# k3d-demo-serverlb
# k3d-demo-agent-1
# k3d-demo-agent-0
# k3d-demo-server-0
# registry.localhost

kubectx k3d-demo

for container in $(docker container ls --format "{{.Names}}"); do echo "$container" && docker logs "$container" &>debugging/"$container".log; done
