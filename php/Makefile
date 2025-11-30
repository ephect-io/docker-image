SHELL := /bin/bash
ARCH = $(shell uname -m)
version ?= 8.5.0
package ?= apache
repo ?= ephect/dev-php
TAG = "localhost:5000/dev-php:$(package)-$(version)"
REMOTE_TAG = "docker.io/ephect/dev-php:$(package)-$(version)"

# Default target
default: help

# Example of using architecture-specific logic
build:
	@echo "Building on $(ARCH) architecture"
	docker buildx build --platform linux/amd64,linux/arm64/v8 ./$(package) --build-arg VERSION=$(version) -t $(TAG) --push

push:
	@echo "Pushing the image on DockerHub"
	docker push $(TAG)

push-remote:
	@echo "Pushing the image on remote DockerHub repository"
	docker tag $(TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)

overview:
	@echo "Generating README for all combinations..."
	@if [ -z "$(packages)" ] || [ -z "$(versions)" ]; then \
		echo "❌ Error: You must specify packages=apache,fpm and versions=8.4.15,8.5.0"; \
		exit 1; \
	fi
	cd .. && ./bin/make-overview.sh $(packages) $(versions)

publish:
	@echo "Updating the repository overview..."
	cd .. && ./bin/publish-overview.sh $(repo) $(package)

show:
	@echo "Show build command on $(ARCH) architecture:"
	@echo "> docker buildx build --platform linux/amd64,linux/arm64/v8 ./$(package) --build-arg VERSION=$(version) -t $(TAG) --push"

help:
	@echo "make <command> <package> <argument>"
	@echo
	@echo "Possible commands are:"
	@echo " - build: build the dev image for the given version and detected architecture,"
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
	@echo "  make publish repo=ephectio/dev-php package=apache"

.PHONY: default help log overview publish
