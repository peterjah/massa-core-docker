#!/bin/bash

# This builds the image an load it locally. you can build for different architectures with --platform option like linux/amd64,linux/arm/v7,linux/arm64/v8
DOCKER_BUILDKIT=1 docker buildx build --progress=plain --no-cache --platform linux/amd64 -t peterjah/massa-core --load --build-arg VERSION=MAIN.2.0  .
