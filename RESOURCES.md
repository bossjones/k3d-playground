## Resources

- [What is the difference between Ingress and IngressRoute](https://community.traefik.io/t/what-is-the-difference-between-ingress-and-ingressroute/10864/10)
- https://github.com/ahmetb/kubernetes-network-policy-recipes/blob/master/05-allow-traffic-from-all-namespaces.md
- https://github.com/ahmetb/kubernetes-network-policy-recipes/blob/master/06-allow-traffic-from-a-namespace.md
- https://github.com/ahmetb/kubernetes-network-policy-recipes/blob/master/08-allow-external-traffic.md
- [cilium k3d](https://github.com/chainguard-images/images/blob/27d4487ab413d583101d015a0bb610424f953d38/images/cilium/tests/cilium-install.sh)


```
# SOURCE: https://github.com/chainguard-images/images/blob/27d4487ab413d583101d015a0bb610424f953d38/images/cilium/tests/cilium-install.sh
# These settings come from
# https://docs.cilium.io/en/latest/installation/rancher-desktop/#configure-rancher-desktop
for node in $(kubectl get --context=k3d-$CLUSTER_NAME nodes -o jsonpath='{.items[*].metadata.name}'); do
    echo "Configuring mounts for $node"
    docker exec -i $node /bin/sh <<-EOF
        mount bpffs -t bpf /sys/fs/bpf
        mount --make-shared /sys/fs/bpf
        mkdir -p /run/cilium/cgroupv2
        mount -t cgroup2 none /run/cilium/cgroupv2
        mount --make-shared /run/cilium/cgroupv2/
EOF
done
```
