#!/usr/bin/env bash

cd ~/dev/bossjones/k3d-playground

mkdir vendor/prometheus-community || true
cd vendor/prometheus-community
git clone https://github.com/prometheus-community/helm-charts || git pull --rebase
cd -
mkdir vendor/grafana || true
cd vendor/grafana
git clone https://github.com/grafana/helm-charts || git pull --rebase
cd -
mkdir vendor/vectordotdev || true
cd vendor/vectordotdev
git clone https://github.com/vectordotdev/helm-charts || git pull --rebase
cd -
