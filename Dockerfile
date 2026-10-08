FROM debian:trixie-slim

# LABEL about the custom image
LABEL maintainers="benoit@alphatux.fr, ps@massa.org"
LABEL description="Massa node with massa-guard features"

# Build Arguments
ARG TARGETARCH
ARG VERSION
LABEL version=$VERSION

ENV VERSION=$VERSION

ENV PATH_MOUNT=/massa_mount
ENV PATH_CLIENT=/massa/massa-client
ENV PATH_NODE=/massa/massa-node
ENV PATH_NODE_CONF=/massa/massa-node/config

# Update and install packages dependencies
RUN apt-get update && apt-get install -y --no-install-recommends curl jq ca-certificates procps \
    && rm -rf /var/lib/apt/lists/*

COPY bin /massa-guard/bin

RUN if [ "$TARGETARCH" = "amd64" ]; then \
        TOML_CLI_BIN="/massa-guard/bin/toml-cli"; \
    else \
        ARM="_arm64"; \
        TOML_CLI_BIN="/massa-guard/bin/toml-cli-arm"; \
    fi; \
    cp $TOML_CLI_BIN /usr/bin/toml && rm -rf /massa-guard/bin; \
    FILENAME="massa_${VERSION}_release_linux${ARM}.tar.gz"; \
    NODE_URL="https://github.com/massalabs/massa/releases/download/${VERSION}/${FILENAME}"; \
    curl -Ls -o $FILENAME $NODE_URL; \
    tar -xf $FILENAME && rm $FILENAME

# Optional locally built node. Drop the binary at custom-bin/massa-node (amd64)
# or custom-bin/massa-node-arm64 (arm64). Absent files keep the release binary.
# Configs and massa-client still come from the VERSION release above.
COPY custom-bin/ /tmp/custom-bin/
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        CUSTOM="/tmp/custom-bin/massa-node"; \
    else \
        CUSTOM="/tmp/custom-bin/massa-node-arm64"; \
    fi; \
    if [ -f "$CUSTOM" ]; then \
        cp "$CUSTOM" /massa/massa-node/massa-node; \
        chmod +x /massa/massa-node/massa-node; \
        echo "Embedded custom massa-node ($TARGETARCH)"; \
    else \
        echo "Using massa-node from release $VERSION"; \
    fi; \
    rm -rf /tmp/custom-bin

# Create massa-guard tree
RUN mkdir -p /massa-guard/sources

# Copy massa-guard sources
COPY massa-guard.sh /massa-guard/
COPY sources/cli.sh /cli.sh
COPY sources /massa-guard/sources

# Conf rights
RUN chmod +x /massa-guard/massa-guard.sh \
&& chmod +x /massa-guard/sources/* \
&& chmod +x /cli.sh \
&& mkdir /massa_mount

# Add Massa cli binary
RUN ln -sf /cli.sh /usr/bin/massa-cli

# Node run then massa-guard
CMD [ "/massa-guard/sources/run.sh" ]
