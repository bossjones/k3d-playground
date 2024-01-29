.PHONY: default help check-prereq format lint build push build-and-push

export RED=\033[0;31m
export GREEN=\033[0;32m
export ORNG=\033[38;5;214m
export BLUE=\033[38;5;81m
export CYAN=\033[36m
export NC=\033[0m

VERSION := $(shell cat VERSION | tr -d '\n')
username := index.docker.io/bossjones
container_name := argocd-custom-tools
IMAGE := $(username)/$(container_name)

default: help

help: ## Print this help text
	@awk 'BEGIN {FS = ":.*?## "}; ($$2 && !/@awk/){printf "${CYAN}%-30s${NC} %s\n", $$1, $$2}' $(lastword ${MAKEFILE_LIST})
	@printf "\n"


build: ## Build the ethos-core-tools image
	@DOCKER_BUILDKIT=1 docker build --rm -t $(IMAGE):$(VERSION) .
	@docker tag $(IMAGE):$(VERSION) $(IMAGE):latest

push: ## Push the ethos-core-tools image to the internal docker registry
	@docker push $(IMAGE):$(VERSION)
	@docker push $(IMAGE):latest

build-and-push: build push  ## Perform both build of the ethos-core-tools image and push it to the registry
