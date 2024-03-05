#!/usr/bin/env bash
# set -euxo pipefail
set -x


docker exec -it $(docker inspect --format='{{.Id}}' k3d-demo-server-0) sh
