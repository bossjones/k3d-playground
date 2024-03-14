#!/usr/bin/env bash
echo ""
#echo "# arguments called with ---->  ${@}     "
#echo "# \$1 ---------------------->  $1       "
#echo "# \$2 ---------------------->  $2       "
echo "# path to me --------------->  ${0}     "
echo "# parent path -------------->  ${0%/*}  "
echo ""# my "name ------------------>  ${0##*/} "
echo ""

set -x
# set -euxo pipefail

# Stop the container(s) using the following command:
docker-compose down || true

# Delete all containers using the following command:
docker rm -f $(docker ps -a -q) || true

# Delete all volumes using the following command:
docker volume rm $(docker volume ls -q) || true

# # Restart the containers using the following command:
# docker-compose up -d
