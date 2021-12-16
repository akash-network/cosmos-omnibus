ARG BUILD_IMAGE=default
ARG BUILD_METHOD=source
ARG GOLANG_VERSION=1.16-buster

#
# Default build environment for standard Tendermint chains
#
FROM golang:${GOLANG_VERSION} AS build_base

ARG PROJECT=akash
ARG PROJECT_BIN=$PROJECT
ARG APT_INSTALL_EXTRA_DEPS

RUN apt-get update && \
  apt-get install --no-install-recommends --assume-yes curl unzip ${APT_INSTALL_EXTRA_DEPS} && \
  apt-get clean

#
# Default build from source method
#
FROM build_base AS build_source

ARG VERSION=v0.12.1
ARG REPOSITORY=https://github.com/ovrclk/akash.git
ARG BUILD_COMMAND="make install"

RUN git clone $REPOSITORY /data
WORKDIR /data
RUN git checkout $VERSION

#
# Optional build environment for Starport chains
#
FROM build_source AS build_starport

ARG BUILD_COMMAND="starport chain build"

RUN curl https://get.starport.network/starport! | bash

#
# Final build environment
# Note optional `BUILD_METHOD` argument controls the base image
#
FROM build_${BUILD_METHOD} AS build

RUN $BUILD_COMMAND

RUN ldd $GOPATH/bin/$PROJECT_BIN | tr -s '[:blank:]' '\n' | grep '^/' | \
    xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'

RUN mv $GOPATH/bin/$PROJECT_BIN /bin/$PROJECT_BIN

#
# Default image
#
FROM debian:buster AS default

ARG PROJECT=akash
ARG PROJECT_BIN=$PROJECT

COPY --from=build /bin/$PROJECT_BIN /bin/$PROJECT_BIN
COPY --from=build /data/deps/ /

#
# Juno image to add wasmvm
#
FROM default AS juno

ARG WASMVM_VERSION=main
ENV WASMVM_VERSION=$WASMVM_VERSION

ADD https://raw.githubusercontent.com/CosmWasm/wasmvm/$WASMVM_VERSION/api/libwasmvm.so /lib/libwasmvm.so

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
  apt-get install --no-install-recommends --assume-yes ca-certificates curl wget file unzip gnupg2 jq && \
  apt-get clean

ARG PROJECT=akash
ARG PROJECT_BIN=$PROJECT
ARG PROJECT_DIR=.$PROJECT_BIN
ARG PROJECT_CMD="$PROJECT_BIN start"
ARG VERSION=v0.12.1
ARG REPOSITORY=https://github.com/ovrclk/akash.git
ARG NAMESPACE

ENV PROJECT=$PROJECT
ENV PROJECT_BIN=$PROJECT_BIN
ENV PROJECT_DIR=$PROJECT_DIR
ENV PROJECT_CMD=$PROJECT_CMD
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

CMD $PROJECT_CMD
