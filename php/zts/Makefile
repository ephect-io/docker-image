ARCH = $(shell uname -m)
version ?= 8.4.3
TAG = ephect/dev-image-php:$(version)

# Default target
default: help

# Example of using architecture-specific logic
build:
	@echo "Building on $(ARCH) architecture"
	docker buildx build --platform linux/amd64,linux/arm64/v8 . --build-arg VERSION=$(version) -t $(TAG) --push

push:
	@echo "Pushing the image on DockerHub"
	docker push $(TAG)

show:
	@echo "Show build command on $(ARCH) architecture:"
	@echo "> docker buildx build --platform linux/amd64,linux/arm64/v8 . --build-arg VERSION=$(version) -t $(TAG) --push"

help:
	@echo "make <command> <argument>"
	@echo
	@echo "Possible commands are:"
	@echo " - build: build the dev image for the given version and detected architecture,"
	@echo " - push: push the dev image on DockerHub."
	@echo
	@echo "Possible argument is:"
	@echo " - version: 8.4.3, 8.3.16, 8.2.27 and 8.1.9 or nothing, default version is 8.4.3."
	@echo
	@echo "Example:"
	@echo "  make build version=8.2.27"

.PHONY: default help
