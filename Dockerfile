ARG BUILD_IMAGE=default
ARG BUILD_METHOD=source
ARG GOLANG_VERSION=1.17-buster
ARG BASE_IMAGE=golang:${GOLANG_VERSION}

#
# Default build environment for standard Tendermint chains
#
FROM ${BASE_IMAGE} AS build_base

ARG PROJECT
ARG PROJECT_BIN=$PROJECT
ARG INSTALL_PACKAGES

RUN apt-get update && \
  apt-get install --no-install-recommends --assume-yes curl unzip ${INSTALL_PACKAGES} && \
  apt-get clean

#
# Optional build environment when libwasmvm.so is required
#
FROM build_base AS build_wasmvm

ARG WASMVM_VERSION=v0.16.7
ARG WASMVM_URL=https://raw.githubusercontent.com/CosmWasm/wasmvm/${WASMVM_VERSION}/api/libwasmvm.so
ADD ${WASMVM_URL} /lib/libwasmvm.so

#
# Default build from source method
#
FROM build_base AS build_source

ARG VERSION
ARG REPOSITORY
ARG BUILD_CMD="make install"

RUN git clone $REPOSITORY /data
WORKDIR /data
RUN git checkout $VERSION

#
# Optional build environment for Starport chains
#
FROM build_source AS build_starport

ARG BUILD_CMD="starport chain build"

RUN curl https://get.starport.network/starport! | bash

#
# Final build environment
# Note optional `BUILD_METHOD` argument controls the base image
#
FROM build_${BUILD_METHOD} AS build

ARG BUILD_PATH=$GOPATH/bin
RUN $BUILD_CMD

RUN ldd $BUILD_PATH/$PROJECT_BIN | tr -s '[:blank:]' '\n' | grep '^/' | \
    xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'

RUN mv $BUILD_PATH/$PROJECT_BIN /bin/$PROJECT_BIN

#
# Default image
#
FROM debian:buster AS default

ARG PROJECT
ARG PROJECT_BIN=$PROJECT

COPY --from=build /bin/$PROJECT_BIN /bin/$PROJECT_BIN
COPY --from=build /data/deps/ /

#
# Optional image to install from binary
#
FROM build_base AS binary

ARG BINARY_URL

RUN curl -Lo /bin/$PROJECT_BIN $BINARY_URL
RUN chmod +x /bin/$PROJECT_BIN

#
# Final Omnibus image
# Note optional `BUILD_IMAGE` argument controls the base image
#
FROM ${BUILD_IMAGE} AS omnibus
LABEL org.opencontainers.image.source https://github.com/ovrclk/cosmos-omnibus

RUN apt-get update && \
  apt-get install --no-install-recommends --assume-yes ca-certificates curl wget file unzip liblz4-tool gnupg2 jq && \
  apt-get clean

ARG PROJECT
ARG PROJECT_BIN
ARG PROJECT_DIR
ARG CONFIG_DIR
ARG START_CMD
ARG INIT_CMD
ARG VERSION
ARG REPOSITORY
ARG NAMESPACE

ENV PROJECT=$PROJECT
ENV PROJECT_BIN=$PROJECT_BIN
ENV PROJECT_DIR=$PROJECT_DIR
ENV CONFIG_DIR=$CONFIG_DIR
ENV START_CMD=$START_CMD
ENV INIT_CMD=$INIT_CMD
ENV VERSION=$VERSION
ENV REPOSITORY=$REPOSITORY
ENV NAMESPACE=$NAMESPACE

ENV MONIKER=my-omnibus-node

EXPOSE 26656 \
       26657 \
       1317  \
       9090  \
       8080

# Install AWS
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip -d /usr/src && rm -f awscliv2.zip \
  && /usr/src/aws/install --bin-dir /usr/bin

# Copy scripts
COPY run.sh snapshot.sh /usr/bin/
RUN chmod +x /usr/bin/run.sh /usr/bin/snapshot.sh
ENTRYPOINT ["run.sh"]

CMD $START_CMD
