set	shell := ["zsh", "-cu"]
LOCATION_PYTHON := `python -c "import sys;print(sys.executable)"`

# just manual: https://github.com/casey/just/#readme

# Ignore the .env file that	is only	used by the	web	service
set	dotenv-load	:= false

K3D_VERSION := `k3d	version`
CURRENT_DIR := "$(pwd)"
PATH_TO_TRAEFIK_CONFIG := CURRENT_DIR / "mounts/var/lib/rancer/k3s/server/manifests/traefik-config.yaml"

_default:
	@just --list

info:
    print "Python location: {{LOCATION_PYTHON}}"
    print "PATH_TO_TRAEFIK_CONFIG: {{PATH_TO_TRAEFIK_CONFIG}}"

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

setup-cluster:
  mkdir -p /tmp/k3dvol || true
  k3d --verbose cluster create \
  --volume {{PATH_TO_TRAEFIK_CONFIG}}:/var/lib/rancer/k3s/server/manifests/traefik-config.yaml@all \
  --volume /tmp/k3dvol:/var/lib/rancher/k3s/storage@all \
  --api-port 6550 \
  -p "80:80@loadbalancer" \
  -p "443:443@loadbalancer" \
  -p "8900:30080@agent:0" -p "8901:30081@agent:0" -p "8902:30082@agent:0" \
  --agents 2 k3d-playground \
  --runtime-ulimit "nofile=26677:26677" \
  --runtime-ulimit "nproc=26677:26677" \
  --image rancher/k3s:v1.29.0-k3s1
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

reset-cluster: delete-cluster setup-cluster

create-cluster-with-config:
  k3d cluster create --config /home/me/my-awesome-config.yaml

autocomplete:
  k3d completion zsh > ~/.zsh/completions/_k3d
  k3d completion zsh > ~/.zsh/completion/_k3d

vendor:
  bash scripts/helm.sh

weave:
  kubectl apply -f "https://github.com/weaveworks/scope/releases/download/v1.13.2/k8s-scope.yaml?k8s-service-type=LoadBalancer&k8s-version=$(kubectl version | base64 | tr -d '\n')"
  kubectl apply -f vendor/local-chats/charts/scope/manifests/

open-ports:
  ss -tlnp

install:
  bash scripts/install.sh
