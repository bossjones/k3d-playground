#!/usr/bin/env bash

cd ~/dev/bossjones/k3d-playground || exit

mkdir vendor/prometheus-community || true
cd vendor/prometheus-community || exit
git clone https://github.com/prometheus-community/helm-charts || git pull --rebase
cd - || exit
mkdir vendor/grafana || true
cd vendor/grafana || exit
git clone https://github.com/grafana/helm-charts || git pull --rebase
cd - || exit
mkdir vendor/vectordotdev || true
cd vendor/vectordotdev || exit
git clone https://github.com/vectordotdev/helm-charts || git pull --rebase
cd - || exit
