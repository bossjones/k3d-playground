#!/usr/bin/env bash

cd ~/dev/bossjones/k3d-playground

cd vendor/local-chats/charts/echoserver
make install
cd -

cd vendor/local-chats/charts/kube-prometheus-stack
make install
cd -

cd vendor/local-chats/charts/loki-distributed
make install
cd - || exit

cd vendor/local-chats/charts/promtail
make install
cd -

cd vendor/local-chats/charts/rancher
make install
cd - || exit

cd ~/dev/bossjones/k3d-playground || exit