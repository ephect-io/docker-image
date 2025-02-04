ARCH := $(shell uname -m)
version ?= 8.4.3

ifeq ($(ARCH), arm64)
	version := "$(version)-$(ARCH)"
endif

TAG := "ephect/dev-image-php:$(version)"
# Default target
default:
	@echo "Build version: $(version)"

# Example of using architecture-specific logic
build:
ifeq ($(ARCH), x86_64)
	@echo "Building for X86_64 architecture"
	docker build --build-arg VERSION=$(version) -t $(TAG)
else ifeq ($(ARCH), arm64)
	@echo "Building for ARM64 architecture"
	docker build --build-arg VERSION=$(version) -t $(TAG)
else
	@echo "Unknown architecture: $(ARCH)"
endif

push:
ifeq ($(ARCH), x86_64)
	@echo "Pushing the image of DockerHub"
	docker push $(TAG)
else ifeq ($(ARCH), arm64)
	@echo "Pushing the image of DockerHub"
	docker push $(TAG)
else
	@echo "Unknown architecture: $(ARCH)"
endif

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
