#!/usr/bin/env bash
# set -euxo pipefail
set -x


docker logs $(docker inspect --format='{{.Id}}' k3d-demo-server-0) | ccze -A
