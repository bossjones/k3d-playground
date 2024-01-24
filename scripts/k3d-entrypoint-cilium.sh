#!/bin/sh
# SOURCE: https://github.com/andrewmackrodt/k3d-boot/blob/main/scripts/k3d-entrypoint-cilium.sh
set -e

if ! mount | awk '$3 == "/sys/fs/bpf" && $5 == "bpf" { print $0 }' | grep -q .; then
  mount bpffs -t bpf /sys/fs/bpf
  mount --make-shared /sys/fs/bpf
fi

mkdir -p /run/cilium/cgroupv2
mount -t cgroup2 none /run/cilium/cgroupv2
mount --make-shared /run/cilium/cgroupv2
