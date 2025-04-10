.PHONY: buildx_container build_and_push

DOCKER_REGISTRY ?= ghcr.io/iakat/wireguard-go-docker

buildx_container:
	docker buildx create \
		--name container \
		--driver=docker-container

build_and_push:
	docker buildx build \
		--tag ${DOCKER_REGISTRY}:${TAG} \
		--platform linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/amd64 \
		--builder container \
		--push .
