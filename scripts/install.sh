#!/usr/bin/env bash

cd ~/dev/bossjones/k3d-playground || exit

cd vendor/local-chats/charts/echoserver || exit
make install
cd - || exit

cd vendor/local-chats/charts/kube-prometheus-stack || exit
make install
cd - || exit

cd vendor/local-chats/charts/loki-distributed || exit
make install
cd - || exit

cd vendor/local-chats/charts/promtail || exit
make install
cd - || exit

cd vendor/local-chats/charts/ranc || exither
make install
cd -

cd ~/dev/bossjones/k3d-playground
