SHELL := /bin/bash
ARCH = $(shell uname -m)
version ?= 8.5.0
package ?= apache
repo ?= ephect/dev-php
ROCKER ?= localhost:5000
TAG = "$(ROCKER)/dev-php:$(package)-$(version)"
REMOTE_TAG = "docker.io/ephect/dev-php:$(package)-$(version)"

# Default target
default: help

# Example of using architecture-specific logic
build:
	@echo "Building for linux/amd64 and linux/arm64/v8 architectures"
	cd .. && ./bin/build.sh --package=$(package) --version=$(version) --full

local:
	@echo "Building for $(ARCH) architecture"
	cd .. && ./bin/build.sh --package=$(package) --version=$(version)

prepare:
	@echo "Building for $(ARCH) architecture"
	cd .. && ./bin/build.sh --package=$(package) --version=$(version) --prepare

manifest:
	@echo "Creating and pushing manifest for all architectures"
	cd .. && ./bin/make-manifest.sh --package=$(package) --version=$(version)

push:
	@echo "Pushing the image on remote DockerHub repository"
	docker tag $(TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)

overview:
	@echo "Generating README for all combinations..."
	@if [ -z "$(packages)" ] || [ -z "$(versions)" ]; then \
		echo "❌ Error: You must specify packages=apache,fpm and versions=8.4.15,8.5.0"; \
		exit 1; \
	fi
	cd .. && ./bin/make-overview.sh --packages=$(packages) --versions=$(versions)

publish:
	@echo "Updating the repository overview..."
	cd .. && ./bin/publish-overview.sh

show:
	@echo "Show build command for linux/amd64 and linux/arm64/v8 architectures:"
	@echo "> docker buildx build --platform linux/amd64,linux/arm64/v8 ./$(package) --build-arg VERSION=$(version) -t $(TAG) --push"

help:
	@echo "make <command> <package> <argument>"
	@echo
	@echo "Possible commands are:"
	@echo " - prepare: build the dev image for the given version and local architecture without pushing in local registry,"
	@echo " - build: build the dev image for the given version for all architectures and push in prepare registry,"
	@echo " - push: push the dev image on DockerHub,"
	@echo " - overview: generate DockerHub repository overview for one package/version,"
	@echo " - publish: update Docker Hub repository overview with README.md."
	@echo
	@echo "Possible package are:"
	@echo " - apache, fpm, zts."
	@echo
	@echo "Possible argument is:"
	@echo " - version: any PHP version available in DockerHub at https://hub.docker.com/_/php/tags or nothing, default version is latest."
	@echo
	@echo "Example:"
	@echo "  make build package=apache version=8.2.27"
	@echo "  make overview packages=apache,fpm versions=8.4.15,8.5.0"
	@echo "  make publish"

.PHONY: default prepare build push show help overview publish
