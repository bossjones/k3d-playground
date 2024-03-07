#!/usr/bin/env bash
# set -euxo pipefail
set -x

# SOURCE: https://github.com/keunlee/k3d-metallb-starter-kit/blob/master/scripts/create-cluster.sh

# determine loadbalancer ingress range
cidr_block=$(docker network inspect demo-net | jq '.[0].IPAM.Config[0].Subnet' | tr -d '"')
cidr_base_addr=${cidr_block%???}
ingress_first_addr=$(echo "$cidr_base_addr" | awk -F'.' '{print $1,$2,255,0}' OFS='.')
ingress_last_addr=$(echo "$cidr_base_addr" | awk -F'.' '{print $1,$2,255,255}' OFS='.')
ingress_range=$ingress_first_addr-$ingress_last_addr

# deploy metallb
# kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.5/config/manifests/metallb-native.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.3/config/manifests/metallb-native.yaml
echo "waiting for metallb-system deployment.apps/controller"
# kubectl wait --timeout=150s --for=condition=ready pod -l app=metallb,component=controller -n metallb-system
kubectl -n metallb-system wait deployment controller --for condition=Available=True --timeout=300s
sleep 5
# external_cidr=$(docker network inspect "demo-net" -f '{{range .IPAM.Config}}{{println .Subnet}}{{end}}' | head -n1)
# external_gateway=${external_cidr%???}
# first_addr=$(echo "$external_gateway" | awk -F'.' '{ print $1,$2,1,2 }' OFS='.')
# last_addr=$(echo "$external_gateway" | awk -F'.' '{ print $1,$2,255,254 }' OFS='.')
# ingress_range="$first_addr-$last_addr"
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
# apiVersion: metallb.io/v1beta1
# kind: IPAddressPool
# metadata:
#   name: ip-pool
#   namespace: metallb-system
# spec:
#   addresses:
#   - $ingress_range # replace with your output
# ---
# apiVersion: metallb.io/v1beta1
# kind: L2Advertisement
# metadata:
#   name: l2advertisement
#   namespace: metallb-system
# spec:
#   ipAddressPools:
#   - ip-pool





# configure metallb ingress address range
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: cluster-pool
  namespace: metallb-system
spec:
  addresses:
    - $ingress_range # replace with your output
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: cluster-advertisement
  namespace: metallb-system
EOF



# validate the cluster master and worker nodes
kubectl get nodes
