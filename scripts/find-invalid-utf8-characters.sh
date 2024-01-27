#!/usr/bin/env bash
# set -euxo pipefail

for aFile in $(fd -t f); do grep -axv '.*' "$aFile" && echo "file contains ascii $aFile" || echo ""; done
