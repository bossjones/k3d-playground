#!/usr/bin/env bash
# set -euxo pipefail
set -x

# SOURCE: https://github.com/keunlee/k3d-metallb-starter-kit/blob/master/scripts/create-cluster.sh

# determine loadbalancer ingress range
cidr_block=$(docker network inspect k3d-demo | jq '.[0].IPAM.Config[0].Subnet' | tr -d '"')
cidr_base_addr=${cidr_block%???}
ingress_first_addr=$(echo "$cidr_base_addr" | awk -F'.' '{print $1,$2,255,0}' OFS='.')
ingress_last_addr=$(echo "$cidr_base_addr" | awk -F'.' '{print $1,$2,255,255}' OFS='.')
ingress_range=$ingress_first_addr-$ingress_last_addr

# deploy metallb
# kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.5/config/manifests/metallb-native.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.3/config/manifests/metallb-native-prometheus.yaml

kubectl wait --timeout=150s --for=condition=ready pod -l app=metallb,component=controller -n metallb-system
sleep 5
# # configure metallb ingress address range
# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   namespace: metallb-system
#   name: config
# data:
#   config: |
#     address-pools:
#     - name: default
#       protocol: layer2
#       addresses:
#       - $ingress_range
# EOF

# configure metallb ingress address range
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: ip-pool
  namespace: metallb-system
spec:
  addresses:
  - $ingress_range # replace with your output
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
  - ip-pool
EOF



# validate the cluster master and worker nodes
kubectl get nodes
