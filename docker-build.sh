#!/bin/bash

# This builds the image and loads it locally.
# Optional: put a linux/amd64 massa-node you built at custom-bin/massa-node.
# It replaces the node binary from the VERSION release. Configs and massa-client stay from that release.
# For an arm64 image, also pass --platform linux/arm64/v8 and place the binary at custom-bin/massa-node-arm64.
DOCKER_BUILDKIT=1 docker buildx build --progress=plain --no-cache --platform linux/amd64 -t peterjah/massa-core --load --build-arg VERSION=MAIN.5.0  .
