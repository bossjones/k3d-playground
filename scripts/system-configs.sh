#!/usr/bin/env bash
set -euxo pipefail

mkdir -p /etc/systemd/system/kernel-tuning.service.d/

cat <<EOF >/etc/systemd/system/kernel-tuning.service
[Unit]
Description=Kernel tuning for Ethos hosts

[Service]
Type=oneshot
RemainAfterExit=true
ExecStartPre=/usr/lib/systemd/systemd-sysctl
ExecStartPre=/usr/lib/systemd/systemd-modules-load
ExecStart=/bin/bash -c "exit 0"

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl restart kernel-tuning.service
systemctl enable kernel-tuning.service



cat <<EOF >/etc/docker/daemon.json
{
  "log-driver": "journald",
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "metrics-addr": "0.0.0.0:9323",
  "log-opts": {
    "tag":"{{.ImageName}}/{{.Name}}/{{.ID}}"
  },
  "default-ulimits": {
    "memlock": {
      "Hard": -1,
      "Name": "memlock",
      "Soft": -1
    },
    "nofile": {
      "Hard": 1048576,
      "Name": "nofile",
      "Soft": 1048576
    }
  }
}

EOF

mkdir -p /etc/systemd/system/docker.service.d/

cat <<EOF >/etc/systemd/system/docker.service.d/perf.conf
[Service]
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
MemoryAccounting=yes
# native.cgroupdriver must be the same cgroup driver used by kubelet
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cgroup-drivers
# --default-limit nofile set to match /etc/security/limits.d/limits.conf
# Bridge disabled to prevent conflicts with Pod/Service IP ranges
# Log max size increased to mitigate lost logs on rotation
# Log max files increased to allow all log lines to be emitted, even if log shipping falls behind
# Environment="DOCKER_OPTS=--log-opt max-size=256m --log-opt max-file=2 --exec-opt native.cgroupdriver=cgroupfs --default-ulimit nofile=1048576:1048576 --bridge=none --iptables=false"
LimitMEMLOCK=infinity
EOF

systemctl daemon-reload
systemctl restart docker.service
systemctl enable docker.service
