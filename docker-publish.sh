#!/bin/bash

# This builds the image  for all architectures an publish it on dockerhub
DOCKER_BUILDKIT=1 docker buildx build --platform linux/amd64,linux/arm64/v8 -t peterjah/massa-core --push --build-arg VERSION=MAIN.3.0 .
