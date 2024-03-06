#!/usr/bin/env bash
# set -euxo pipefail
set -x


docker logs $(docker inspect --format='{{.Id}}'  kine-db) | ccze -A
