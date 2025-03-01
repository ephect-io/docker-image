ARCH = $(shell uname -m)
version ?= latest
package ?= apache
TAG = ephect/dev-php:$(package)-$(version)

# Default target
default: help

# Example of using architecture-specific logic
build:
	@echo "Building on $(ARCH) architecture"
	docker buildx build --platform linux/amd64,linux/arm64/v8 ./$(package) --build-arg VERSION=$(version) -t $(TAG) --push

push:
	@echo "Pushing the image on DockerHub"
	docker push $(TAG)

show:
	@echo "Show build command on $(ARCH) architecture:"
	@echo "> docker buildx build --platform linux/amd64,linux/arm64/v8 ./$(package) --build-arg VERSION=$(version) -t $(TAG) --push"

help:
	@echo "make <command> <package> <argument>"
	@echo
	@echo "Possible commands are:"
	@echo " - build: build the dev image for the given version and detected architecture,"
	@echo " - push: push the dev image on DockerHub."
	@echo
	@echo "Possible package are:"
	@echo " - apahce, fpm, zts."
	@echo
	@echo "Possible argument is:"
	@echo " - version: any PHP version available in DockerHub at https://hub.docker.com/_/php/tags or nothing, default version is latest."
	@echo
	@echo "Example:"
	@echo "  make build package=apache version=8.2.27"

.PHONY: default help
