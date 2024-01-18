set	shell := ["zsh", "-cu"]
LOCATION_PYTHON := `python -c "import sys;print(sys.executable)"`

# just manual: https://github.com/casey/just/#readme

# Ignore the .env file that	is only	used by the	web	service
set	dotenv-load	:= false

K3D_VERSION := `k3d	version`

_default:
	@just --list

info:
    print "Python location: {{LOCATION_PYTHON}}"

# verify python	is running under pyenv
which-python:
	python -c "import sys;print(sys.executable)"

# install all pre-commit hooks
pre-commit-install:
	pre-commit install -f --install-hooks

# install taplo	if not found
# https://github.com/mlops-club/awscdk-clearml/blob/3d47f23479dd18e864fda43e11ecc8d5624613a9/Justfile


setup-cluster:
  k3d cluster create --api-port 6550 -p "8888:80@loadbalancer" --gpus "all" --agents 2 k3d-playground --image rancher/k3s:v1.29.0-k3s1

start-cluster:
  k3d cluster start

rm-cluster:
  k3d cluster rm k3d-playground || true

reset-cluster: rm-cluster setup-cluster

create-cluster-with-config:
  k3d cluster create --config /home/me/my-awesome-config.yaml

autocomplete:
  k3d completion zsh > ~/.zsh/completions/_k3d
  k3d completion zsh > ~/.zsh/completion/_k3d
