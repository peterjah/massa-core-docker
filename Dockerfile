FROM ubuntu:22.04

# Build Arguments
ARG TARGETARCH
ARG VERSION

ENV VERSION=$VERSION

RUN if [ "$TARGETARCH" == "amd64" ]; \
    then export ARM=""; \
    else export ARM="_arm64"; \
    fi

ENV FILENAME="massa_${VERSION}_release_linux$ARM.tar.gz"
ENV NODE_URL="https://github.com/massalabs/massa/releases/download/$VERSION/$FILENAME"

# Download and extract the Massa node archive
ADD $NODE_URL $FILENAME
RUN tar -xf $FILENAME
RUN rm $FILENAME

# LABEL about the custom image
LABEL maintainers="benoit@alphatux.fr, ps@massa.org"
LABEL version=$VERSION
LABEL description="Massa node with massa-guard features"

# Update and install packages dependencies
RUN apt-get update \
&& apt install -y curl jq python3-pip \
&& python3 -m pip install -U toml-cli


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
