set	shell := ["zsh", "-cu"]
LOCATION_PYTHON := `python -c "import sys;print(sys.executable)"`

# just manual: https://github.com/casey/just/#readme

# Ignore the .env file that	is only	used by the	web	service
set	dotenv-load	:= false

K3D_VERSION := `k3d	version`
CURRENT_DIR := "$(pwd)"
PATH_TO_TRAEFIK_CONFIG := CURRENT_DIR / "mounts/var/lib/rancer/k3s/server/manifests/traefik-config.yaml"

base64_cmd := if "{{os()}}" == "macos" { "base64 -w 0 -i cert.pem -o ca.pem" } else { "base64 -b 0 -i cert.pem -o ca.pem" }


_default:
	@just --list

info:
    print "Python location: {{LOCATION_PYTHON}}"
    print "PATH_TO_TRAEFIK_CONFIG: {{PATH_TO_TRAEFIK_CONFIG}}"
    print "OS: {{os()}}"

# verify python	is running under pyenv
which-python:
	python -c "import sys;print(sys.executable)"

# install all pre-commit hooks
pre-commit-install:
	pre-commit install -f --install-hooks

# install taplo	if not found
# https://github.com/mlops-club/awscdk-clearml/blob/3d47f23479dd18e864fda43e11ecc8d5624613a9/Justfile
# k3d cluster create --api-port 6550 -p "8888:80@loadbalancer" --agents 2 k3d-playground --image rancher/k3s:v1.29.0-k3s1
# 8900-8902 = https://medium.com/47billion/playing-with-kubernetes-using-k3d-and-rancher-78126d341d23
# SOURCE: https://www.sokube.io/blog/k3s-k3d-k8s-a-new-perfect-match-for-dev-and-test
# Ports mapping:

# --port 8080:80@loadbalancer will add a mapping of local host port 8080 to loadbalancer port 80, which will proxy requests to port 80 on all agent nodes
# --api-port 6443 : by default, no API-Port is exposed (no host port mapping). It's used to have k3s's API-Server listening on port 6443 with that port mapped to the host system. So that the load balancer will be the access point to the Kubernetes API, so even for multi-server clusters, you only need to expose a single api port. The load balancer will then take care of proxying your requests to the appropriate server node
# -p "32000-32767:32000-32767@loadbalancer": You may as well expose a NodePort range (if you want to avoid the Ingress Controller).
# FATA[0000] runtime ulimit "noproc" is not valid, allowed keys are: fsize, rss, rtprio, data, msgqueue, nofile, stack, core, rttime, cpu, memlock, nice, nproc, sigpending, locks
# error: Recipe `setup-cluster` failed on line 50 with exit code 1
# NOTE: Regarding disk pressure - https://github.com/k3d-io/k3d/issues/133

setup-cluster:
  mkdir -p /tmp/k3dvol || true
  k3d --verbose cluster create \
  --volume {{PATH_TO_TRAEFIK_CONFIG}}:/var/lib/rancer/k3s/server/manifests/traefik-config.yaml@all \
  --volume /tmp/k3dvol:/var/lib/rancher/k3s/storage@all \
  --api-port 6550 \
  -p "80:80@loadbalancer" \
  -p "443:443@loadbalancer" \
  -p "8900:30080@agent:0" -p "8901:30081@agent:0" -p "8902:30082@agent:0" \
  -p "4040:30083@agent:0" -p "9000:30084@agent:0" -p "8000:30085@agent:0" \
  --agents 2 k3d-playground \
  --runtime-ulimit "nofile=26677:26677" \
  --runtime-ulimit "nproc=26677:26677" \
  --runtime-ulimit "core=26677:26677" \
  --k3s-arg '--kubelet-arg=eviction-hard=imagefs.available<1%,nodefs.available<1%@agent:*' \
  --k3s-arg '--kubelet-arg=eviction-minimum-reclaim=imagefs.available=1%,nodefs.available=1%@agent:*' \
  --k3s-arg '--kubelet-arg=eviction-hard=imagefs.available<1%,nodefs.available<1%@server:0' \
  --k3s-arg '--kubelet-arg=eviction-minimum-reclaim=imagefs.available=1%,nodefs.available=1%@server:0' \
  --image rancher/k3s:v1.27.9-k3s1
# -p "32000-32767:32000-32767@loadbalancer" \
# --image rancher/k3s:v1.28.5+k3s1
# --image rancher/k3s:v1.27.9-k3s1
# The above command is creating another K3d cluster and mapping port 8888 on the host to port 80 on the containers that have a nodefilter of loadbalancer.

start-cluster:
  k3d cluster start k3d-playground || true

stop-cluster:
  k3d cluster stop k3d-playground || true

delete-cluster: stop-cluster
  k3d cluster delete k3d-playground || true

nuke-cluster: delete-cluster

reset-cluster: delete-cluster setup-cluster

simple-cluster-reset: reset-cluster install

create-cluster-with-config:
  k3d cluster create --config /home/me/my-awesome-config.yaml

autocomplete:
  k3d completion zsh > ~/.zsh/completions/_k3d
  k3d completion zsh > ~/.zsh/completion/_k3d

vendor:
  bash scripts/vendor.sh

helm:
  bash scripts/helm.sh

weave:
  kubectl apply -f "https://github.com/weaveworks/scope/releases/download/v1.13.2/k8s-scope.yaml?k8s-service-type=LoadBalancer&k8s-version=$(kubectl version | base64 | tr -d '\n')"
  kubectl apply -f vendor/local-chats/charts/scope/manifests/
  # kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

open-ports:
  ss -tlnp

install: weave
  bash scripts/install.sh

portainer-install:
  helm repo add portainer https://portainer.github.io/k8s/
  helm repo update
  helm upgrade --install --create-namespace -n portainer portainer portainer/portainer --set tls.force=false
  echo "open: https://localhost:30779/ or http://localhost:30777/ to access portainer"

proxy-weave:
  kubectl port-forward -n weave "$(kubectl get -n weave pod --selector=weave-scope-component=app -o jsonpath='{.items..metadata.name}')" 4040

proxy-traefik:
  echo "open up: http://localhost:9000/dashboard/#/ in your browser"
  kubectl port-forward -n kube-system "$(kubectl get pods -n kube-system| grep '^traefik-' | awk '{print $1}')" 9000:9000

proxy-grafana:
	kubectl port-forward service/monitoring-stack-grafana 8081:80 -n monitoring

# Generate argocd jsonschema
argocd-schema:
  python3 ./scripts/openapi2jsonschema.py https://raw.githubusercontent.com/argoproj/argo-cd/v2.8.0/manifests/crds/application-crd.yaml
  python3 ./scripts/openapi2jsonschema.py https://raw.githubusercontent.com/argoproj/argo-cd/v2.8.0/manifests/crds/applicationset-crd.yaml
  python3 ./scripts/openapi2jsonschema.py https://raw.githubusercontent.com/argoproj/argo-cd/v2.8.0/manifests/crds/appproject-crd.yaml

# Starts your local k3d cluster.
k3d-demo:
  k3d cluster delete demo
  k3d cluster create --config config/cluster.yaml
  echo -e "\nYour cluster has been created. Type 'k3d cluster list' to confirm."

# delete k3d demo cluster
demo-down:
  k3d cluster delete demo

# Creates the DNS entry required for the local domain to work.
dns:
  sudo hostctl add k8s -q < config/.etchosts
  echo -e "Added 'k8s.localhost' and related domains to your hosts file!"

# Initial cert creation steps
pre-certs:
  #!/usr/bin/env bash
  cd config/tls
  pwd
  rm cert.pem key.pem base/tls-secret.yaml ca.pem 2> /dev/null
  set -euxo pipefail
  mkcert -install
  mkcert -cert-file cert.pem -key-file key.pem -p12-file p12.pem "*.k8s.localhost" k8s.localhost "*.localhost" ::1 127.0.0.1 localhost 127.0.0.1 "*.internal.localhost" "*.local" 2> /dev/null
  cd -

# Post cert creation steps
post-certs:
  #!/usr/bin/env bash
  set -euxo pipefail
  cd config/tls
  pwd
  echo -e 'running eval "{{base64_cmd}}"\n'
  eval "{{base64_cmd}}"
  cd -

# generate certs
certs: pre-certs post-certs
  #!/usr/bin/env bash
  set -euxo pipefail
  cd config/tls
  pwd
  echo -e "Creating certificate secrets on Kubernetes for local TLS enabled by default\n"
  kubectl config set-context --current --namespace=kube-system --cluster=k3d-demo
  kubectl create secret tls tls-secret --cert=cert.pem --key=key.pem --dry-run=client -o yaml >base/tls-secret.yaml
  kubectl apply -k ./
  echo -e "\nCertificate resources have been created.\n"
  cd -

# generate certs ONLY
certs-only:
  #!/usr/bin/env bash
  set -euxo pipefail
  cd config/tls
  pwd
  echo -e "Creating certificate secrets on Kubernetes for local TLS enabled by default\n"
  kubectl config set-context --current --namespace=kube-system --cluster=k3d-demo
  kubectl create secret tls tls-secret --cert=cert.pem --key=key.pem --dry-run=client -o yaml >base/tls-secret.yaml
  kubectl apply -k ./
  echo -e "\nCertificate resources have been created.\n"
  cd -

# generate argocd templates
templates:
  bash scripts/templates.sh

# install argocd
argocd-install:
  bash scripts/argocd-install.sh

# install argocd secrets
argocd-secret:
  bash scripts/argocd-secret.sh

# get argocd password
argocd-password:
  bash scripts/argocd-password.sh

# port forward to argocd
argocd-bridge:
  kubectl port-forward -n argocd svc/argocd-server 8832:80

argocd-proxy: argocd-bridge

# Add apps to argocd
monitoring-install:
  ./scripts/run-kustomize.sh manifests/monitoring/kube-prometheus-stack

# bring up k3d-demo cluster
demo: nuke-cluster helm k3d-demo argocd-install certs argocd-secret templates argocd-password argocd-bridge

# bring up k3d-demo cluster but skip some steps
demo-prebuilt: nuke-cluster k3d-demo argocd-install certs-only argocd-secret templates monitoring-install argocd-password argocd-bridge

# fix network policies in all namespaces
fix-network-policies:
  bash scripts/fix-network-policies.sh

fix-np: fix-network-policies

demo-update: argocd-install certs-only argocd-secret templates argocd-password install fix-np argocd-bridge
