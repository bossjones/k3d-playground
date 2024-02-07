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
IMAGE_SHORT := bossjones/$(container_name)

# Shortcut for building the local development container
# DOCKER_BUILD=DOCKER_BUILDKIT=1 docker buildx build --push --rm --platform linux/arm64,linux/amd64
DOCKER_BUILD=DOCKER_BUILDKIT=1 docker buildx build --push --rm --platform linux/arm64

ifndef IS_TTY
	DOCKER_BUILD+= --progress=plain
endif

ifneq ($(DOCKERFILE_LOC),)
	DOCKER_BUILD+= -f $(DOCKERFILE_LOC) -t $(IMAGE):latest $$(dirname $$DOCKERFILE_LOC)
else
	DOCKER_BUILD+= -t $(IMAGE):latest -t  $(IMAGE):$(VERSION) .
endif

TARGETARCH := arm64

default: help

help: ## Print this help text
	@awk 'BEGIN {FS = ":.*?## "}; ($$2 && !/@awk/){printf "${CYAN}%-30s${NC} %s\n", $$1, $$2}' $(lastword ${MAKEFILE_LIST})
	@printf "\n"

build: ## Builds the local Docker container for development
	$(DOCKER_BUILD)

push: ## Push the ethos-core-tools image to the internal docker registry
	@docker push $(IMAGE):$(VERSION)
	@docker push $(IMAGE):latest

build-and-push: build push  ## Perform both build of the ethos-core-tools image and push it to the registry

cli:
	docker run --rm -it --entrypoint /bin/bash $(IMAGE):latest

push-private-registry:
	docker tag $(IMAGE):$(VERSION) localhost:5002/$(IMAGE_SHORT):$(VERSION)
	docker tag $(IMAGE):latest localhost:5002/$(IMAGE_SHORT):latest
	docker push localhost:5002/$(IMAGE_SHORT):$(VERSION)
	docker push localhost:5002/$(IMAGE_SHORT):latest
