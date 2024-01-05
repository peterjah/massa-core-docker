FROM ubuntu:22.04

# LABEL about the custom image
LABEL maintainers="benoit@alphatux.fr, ps@massa.org"
LABEL version=$VERSION
LABEL description="Massa node with massa-guard features"

# Build Arguments
ARG TARGETARCH
ARG VERSION

ENV VERSION=$VERSION

# Update and install packages dependencies
RUN apt-get update && apt install -y curl jq

RUN if [ "$TARGETARCH" = "amd64" ]; then \
        TOML_CLI_URL="https://github.com/gnprice/toml-cli/releases/download/v0.2.3/toml-0.2.3-x86_64-linux.tar.gz"; \
        curl -Ls -o toml-cli.tar.gz $TOML_CLI_URL; \
    else \
        ARM="_arm64"; \
        TOML_CLI_URL="bin/toml-cli-arm"; \
    fi; \
    FILENAME="massa_${VERSION}_release_linux${ARM}.tar.gz"; \
    NODE_URL="https://github.com/massalabs/massa/releases/download/${VERSION}/${FILENAME}"; \
    curl -Ls -o $FILENAME $NODE_URL; \
    tar -xf $FILENAME && rm $FILENAME

# Download and install toml cli tool
ADD "bin/toml-cli-arm" toml-cli-arm

RUN if [ "$TARGETARCH" = "amd64" ]; then tar -xzf toml-cli.tar.gz && cp toml-0.2.3-x86_64-linux/toml /usr/bin/toml; fi
RUN if [ "$TARGETARCH" != "amd64" ]; then cp toml-cli-arm /usr/bin/toml; fi
RUN rm -rf toml*

# Create massa-guard tree
RUN mkdir -p /massa-guard/sources \
&& mkdir -p /massa-guard/config

# Copy massa-guard sources
COPY massa-guard.sh /massa-guard/
COPY sources/cli.sh /cli.sh
COPY sources /massa-guard/sources
COPY config /massa-guard/config

# Conf rights
RUN chmod +x /massa-guard/massa-guard.sh \
&& chmod +x /massa-guard/sources/* \
&& chmod +x /cli.sh \
&& mkdir /massa_mount

# Add Massa cli binary
RUN ln -sf /cli.sh /usr/bin/massa-cli

# Node run then massa-guard
CMD [ "/massa-guard/sources/run.sh" ]
