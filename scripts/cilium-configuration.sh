# SOURCE: https://github.com/nfsouzaj/k3d-cilium/blob/main/install.sh
# #!/bin/bash
# # set -o errexit   # abort on nonzero exitstatus
# # set -o nounset   # abort on unbound variable
# # set -o pipefail  # don't hide errors within pipes

# set -uo pipefail

export SERVERS=3
export AGENTS=2
export CILIUM_VERSION=1.14.0
export MEM_SERVER=4G
export MEM_AGENT=8G

#### -z string
####  True if the length of string is zero.

if [ -z "$1" ]; then
  echo ""
  echo "#################################################################################################"
  echo "looks like you didn't write anything when calling this script so lemme try creating a cluster..."
  echo "#################################################################################################"
  echo ""
  echo "#######################################"
  echo "checking cluster:"
  k3d cluster list k3s
  echo "#######################################"
  echo ""
  if [[ $? -eq 0 ]]; then
    echo ""
    sl
    cowsay "ops....moooo"
    echo "\033[31m"
    echo "ops..."
    echo "looks like a cluster already exist, you need to pass delete when calling the script in order to recreate it..."
    echo "exiting script"
    echo "\033[00m"
    echo ""
    exit 1
  fi
else
  if [ "$1" = "delete" ]; then
    k3d cluster list k3s
    if [[ $? -eq 0 ]]; then
      echo "Deleting exiting cluster k3s..."
      k3d cluster delete k3s
      sleep 3
    else
      echo "k3s cluster doesn't exist... creating one, now!"
    fi
  fi
fi

echo ""
echo "#######################################################"
echo "########### Deploying k3d with k3s and cilium #########"
echo "############### creating cluster with: ################"
echo "############### servers: ${SERVERS} ${MEM_SERVER} ##########################"
echo "############### agents: ${AGENTS} ${MEM_AGENT} ###########################"
echo "#######################################################"
echo ""
sleep 5

k3d cluster create k3s \
  --servers ${SERVERS} \
  --servers-memory ${MEM_SERVER} \
  --agents ${AGENTS} \
  --agents-memory ${MEM_AGENT} \
  --k3s-arg="--disable=traefik@server:*" \
  --k3s-arg="--disable-network-policy@server:*" \
  --k3s-arg="--flannel-backend=none@server:*" \
  --k3s-arg=feature-gates="NamespaceDefaultLabelName=true@server:*"

echo ""
echo "#######################################################"
echo "########## starting  docker exec mounts... ############"
echo "#######################################################"
echo ""

sleep 5
counts=0
counta=0
## le - less than or equal
## lt - less than

echo "#######################################################"
echo "################ mounting servers #####################"
echo "#######################################################"
echo ""

while [ $counts -lt ${SERVERS} ]; do
  echo "working on docker exec for server:" $counts
  docker exec k3d-k3s-server-$counts sh -c "mount bpffs /sys/fs/bpf -t bpf && mount --make-shared /sys/fs/bpf"
  ((counts++))
  sleep 3
done

echo ""
echo "#######################################################"
echo "################# mounting agents #####################"
echo "#######################################################"
echo ""

while [ $counta -lt ${AGENTS} ]; do
  echo "working on docker exec for agent:" $counta
  docker exec k3d-k3s-agent-$counta sh -c "mount bpffs /sys/fs/bpf -t bpf && mount --make-shared /sys/fs/bpf"
  ((counta++))
  sleep 3
done

echo ""
echo "############################################################"
echo "#### tainting nodes to allow pods to land on ready only ####"
echo "############################################################"
echo ""
sleep 5
kubectl taint node -l beta.kubernetes.io/instance-type=k3s node.cilium.io/agent-not-ready=true:NoSchedule --overwrite=true
sleep 5

echo ""
echo "#######################################################"
echo "############# deploying cilium via helm ###############"
echo "#######################################################"
echo ""
sleep 5
helm repo add cilium https://helm.cilium.io/

helm install cilium cilium/cilium --version=${CILIUM_VERSION} \
  --set global.tag="v${CILIUM_VERSION}" \
  --set externalIPs.enabled=true \
  --set nodePort.enabled=true \
  --set hostPort.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set global.kubeProxyReplacement="strict" --namespace kube-system

echo ""
echo "#######################################################"
echo "############# waiting pods to be ok.... ###############"
echo "#######################################################"
echo ""

until bash -c "kubectl get pods -n kube-system -l k8s-app=cilium | grep -q 'Init:CreateContainerError'"; do
  kubectl get pods -n kube-system -l k8s-app=cilium | grep "Running"
  if [[ ${?} -eq 0 ]]; then
    echo "time to jump into the next task:"
    break
  else
    echo "waiting for pods to be in the right state..."
    sleep 5
  fi
done

counts=0
counta=0

echo ""
echo "##############################################################"
echo "######## starting  docker exec mounts for servers... #########"
echo "##############################################################"
echo ""
sleep 3

while [ $counts -lt ${SERVERS} ]; do
  echo "working on docker exec for node:" $counts
  # If you want an empty string and nonnumeric values to be evaluated as zero (0), use the following syntax.
  while [[ $(docker exec k3d-k3s-server-"${counts}" sh -c "mount --make-shared /run/cilium/cgroupv2") -eq 1 ]]; do
    echo "Houston, we have a problem. Result is no good:" $?
    echo "trying mount again"
    sleep 5
  done
  ((counts++))
  sleep 3
done

echo ""
echo "##############################################################"
echo "######## starting  docker exec mounts for agents... ##########"
echo "##############################################################"
echo ""

while [ $counta -lt ${AGENTS} ]; do
  echo "working on docker exec for agent:" $counta
  while [[ $(docker exec k3d-k3s-agent-"${counta}" sh -c "mount --make-shared /run/cilium/cgroupv2") -eq 1 ]]; do
    echo "Houston, we have a problem. Result is no good:"$?
    echo "trying mount again"
    sleep 5
  done

  ((counta++))
  sleep 3
done

echo ""
echo "##############################################################"
echo "######## labeling agents as workers to look good... ##########"
echo "##############################################################"
echo ""

counta=0
while [ $counta -lt ${AGENTS} ]; do
  kubectl label --overwrite node k3d-k3s-agent-$counta node-role.kubernetes.io/worker=true
  ((counta++))
done

echo ""
echo "##############################################################"
echo "###### kubectl get nodes to check current status... ##########"
echo "##############################################################"
echo ""

kubectl get nodes
sleep 5
echo ""
echo "##############################################################"
echo "###### kubectl getting pods to check where we are... #########"
echo "##############################################################"
echo ""
kubectl get po -A

####

# SOURCE: https://github.com/nxy7/k3d-cilium/blob/master/k3ds.nu
# export def mount-cgroupv2 [] {
#   try {
#     do {
#       sudo mkdir /run/cilium/cgroupv2
#       sudo mount --bind -t cgroup2 /run/cilium/cgroupv2 /run/cilium/cgroupv2
#       sudo mount --make-shared /run/cilium/cgroupv2
#       print "Done mounting cgroupv2"
#     } | complete
#   }
# }
