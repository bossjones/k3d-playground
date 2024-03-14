#!/usr/bin/env bash

docker ps --format "table {{.Image}}\t{{.Names}}\t{{.Ports}}\t{{.Status}}" | grep k3s
