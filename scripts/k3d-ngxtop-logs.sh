#!/usr/bin/env bash
# set -euxo pipefail
# set -x


_PATH=$(docker inspect --format='{{.LogPath}}' k3d-demo-serverlb)


tail -f "${_PATH}" | ngxtop -f common
