ARG DEBIAN_VERSION=bookworm
ARG GOLANG_VERSION=1.21
ARG BUILD_IMAGE=golang:${GOLANG_VERSION}-${DEBIAN_VERSION}
ARG DEBIAN_IMAGE=debian:${DEBIAN_VERSION}-slim
ARG BUILD_METHOD=source
ARG BASE_IMAGE=copy_build

#
# Default build environment for standard Tendermint chains
#
FROM ${BUILD_IMAGE} AS build_base

ARG PROJECT
ARG PROJECT_BIN=$PROJECT
ARG BUILD_PACKAGES

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes curl unzip file ${BUILD_PACKAGES} && \
    apt-get clean

WORKDIR /data

RUN mkdir deps

#
# Default build from source method
#
FROM build_base AS build_source

ARG VERSION
ARG REPOSITORY
ARG BUILD_CMD="make install"
ARG BUILD_DIR=.
ARG BUILD_REF=$VERSION

RUN git clone $REPOSITORY source
WORKDIR /data/source/$BUILD_DIR
RUN git checkout $BUILD_REF
RUN $BUILD_CMD

WORKDIR /data
RUN mv $GOPATH/bin/$PROJECT_BIN /bin/$PROJECT_BIN
# copy dependencies
RUN ldd /bin/$PROJECT_BIN | tr -s '[:blank:]' '\n' | grep '^/' | \
    xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'
# move symlinked directories to usr
RUN [ ! -d deps/lib ] || mkdir -p deps/usr && mv deps/lib deps/usr/lib
RUN [ ! -d deps/lib64 ] || mkdir -p deps/usr && mv deps/lib64 deps/usr/lib64

#
# Optional build image to install from binary
#
FROM build_base AS build_binary

ARG BINARY_URL
ARG BINARY_ZIP_PATH

RUN curl -Lso /bin/$PROJECT_BIN $BINARY_URL
RUN bash -c 'file_description=$(file /bin/$PROJECT_BIN) && \
  case "${file_description,,}" in \
    *"gzip compressed data"*)   mv /bin/$PROJECT_BIN /bin/$PROJECT_BIN.tgz && tar -xvf /bin/$PROJECT_BIN.tgz -C /bin && rm /bin/$PROJECT_BIN.tgz;; \
    *"tar archive"*)            mv /bin/$PROJECT_BIN /bin/$PROJECT_BIN.tar && tar -xf /bin/$PROJECT_BIN.tar -C /bin && rm /bin/$PROJECT_BIN.tar;; \
    *"zip archive data"*)       mv /bin/$PROJECT_BIN /bin/$PROJECT_BIN.zip && unzip /bin/$PROJECT_BIN.zip -d /bin && rm /bin/$PROJECT_BIN.zip;; \
  esac'
RUN if [ -n "$BINARY_ZIP_PATH" ]; then mv /bin/$BINARY_ZIP_PATH /bin/$PROJECT_BIN; fi
RUN chmod +x /bin/$PROJECT_BIN

#
# Custom build image for injective
#
FROM build_base AS build_injective

ARG VERSION
ARG BUILD_REF=$VERSION

RUN curl -Lo release.zip https://github.com/InjectiveLabs/injective-chain-releases/releases/download/$BUILD_REF/linux-amd64.zip
RUN unzip -oj release.zip
RUN mv injectived /bin
RUN mkdir -p deps/usr/lib
RUN mv libwasmvm.x86_64.so deps/usr/lib
RUN chmod +x /bin/injectived

#
# Final build environment
# Note optional `BUILD_METHOD` argument controls the base image
#
FROM build_${BUILD_METHOD} AS build

#
# Base debian image
#
FROM ${DEBIAN_IMAGE} AS base

#
# Base image copying build artifacts
#
FROM base AS copy_build

ARG PROJECT
ARG PROJECT_BIN=$PROJECT

COPY --from=build /bin/$PROJECT_BIN /bin/$PROJECT_BIN
COPY --from=build /data/deps/ /

#
# Final Omnibus image
#
FROM ${BASE_IMAGE} AS omnibus
LABEL org.opencontainers.image.source=https://github.com/akash-network/cosmos-omnibus

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes \
    ca-certificates curl wget file unzip zstd liblz4-tool gnupg2 jq s3cmd pv && \
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
ARG POLKACHU_CHAIN_ID

ENV PROJECT=$PROJECT
ENV PROJECT_BIN=$PROJECT_BIN
ENV PROJECT_DIR=$PROJECT_DIR
ENV CONFIG_DIR=$CONFIG_DIR
ENV START_CMD=$START_CMD
ENV INIT_CMD=$INIT_CMD
ENV VERSION=$VERSION
ENV REPOSITORY=$REPOSITORY
ENV NAMESPACE=$NAMESPACE
ENV POLKACHU_CHAIN_ID=$POLKACHU_CHAIN_ID

EXPOSE 26656 \
       26657 \
       1317  \
       9090  \
       8080

# Install Storj DCS uplink client
RUN curl -L https://github.com/storj/storj/releases/latest/download/uplink_linux_amd64.zip -o uplink_linux_amd64.zip && \
    unzip -o uplink_linux_amd64.zip && \
    install uplink /usr/bin/uplink && \
    rm -f uplink uplink_linux_amd64.zip

# Copy scripts
COPY run.sh snapshot.sh /usr/bin/
RUN chmod +x /usr/bin/run.sh /usr/bin/snapshot.sh

WORKDIR /root
ENTRYPOINT ["run.sh"]
CMD []
