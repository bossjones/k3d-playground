#!/usr/bin/env bash
# set -euxo pipefail
set -x


docker exec -it $(docker inspect --format='{{.Id}}' k3d-demo-agent-0) sh
