#!/usr/bin/env bash
# set -euxo pipefail
set -x


docker exec -it $(docker inspect --format='{{.Id}}' netshoot) bash
