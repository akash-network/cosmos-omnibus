ARG DEBIAN_VERSION=bookworm
ARG GOLANG_VERSION=1.21
ARG BUILD_IMAGE=golang:${GOLANG_VERSION}-${DEBIAN_VERSION}
ARG BUILD_METHOD=source
ARG BASE_IMAGE=debian:${DEBIAN_VERSION}-slim
ARG BASE_METHOD=copy_build

#
# Default build environment for standard Tendermint chains
#
FROM ${BUILD_IMAGE} AS build_base

ARG PROJECT
ARG PROJECT_BIN=$PROJECT
ARG BUILD_PACKAGES

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes curl unzip file ${BUILD_PACKAGES} && \
    apt-get clean && \
    mkdir -p /data/deps

WORKDIR /data

#
# Default build from source method
#
FROM build_base AS build_source

ARG VERSION
ARG REPOSITORY
ARG BUILD_CMD="make install"
ARG BUILD_PATH=.
ARG BUILD_REF=$VERSION
ARG BINARY_PATH=$GOPATH/bin/$PROJECT_BIN

RUN git clone --depth 1 --branch $BUILD_REF $REPOSITORY source && \
    cd /data/source/$BUILD_PATH && \
    $BUILD_CMD && \
    mv $BINARY_PATH /bin/$PROJECT_BIN

# copy dependencies to deps and move symlinked directories to usr
RUN ldd /bin/$PROJECT_BIN | tr -s '[:blank:]' '\n' | grep '^/' | \
    xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;' && \
    [ ! -d deps/lib ] || mkdir -p deps/usr && mv deps/lib deps/usr/lib && \
    [ ! -d deps/lib64 ] || mkdir -p deps/usr && mv deps/lib64 deps/usr/lib64

#
# Optional build image to install from binary
#
FROM build_base AS build_binary

ARG BINARY_URL
ARG BINARY_ZIP_PATH
ARG BINARY_PATH=$BINARY_ZIP_PATH

RUN curl -Lso /bin/$PROJECT_BIN $BINARY_URL && \
    bash -c 'file_description=$(file /bin/$PROJECT_BIN) && \
    case "${file_description,,}" in \
        *"gzip compressed data"*)   mv /bin/$PROJECT_BIN /bin/$PROJECT_BIN.tgz && tar -xvf /bin/$PROJECT_BIN.tgz -C /bin && rm /bin/$PROJECT_BIN.tgz;; \
        *"tar archive"*)            mv /bin/$PROJECT_BIN /bin/$PROJECT_BIN.tar && tar -xf /bin/$PROJECT_BIN.tar -C /bin && rm /bin/$PROJECT_BIN.tar;; \
        *"zip archive data"*)       mv /bin/$PROJECT_BIN /bin/$PROJECT_BIN.zip && unzip /bin/$PROJECT_BIN.zip -d /bin && rm /bin/$PROJECT_BIN.zip;; \
    esac' && \
    if [ -n "$BINARY_PATH" ]; then mv /bin/$BINARY_PATH /bin/$PROJECT_BIN; fi && \
    chmod +x /bin/$PROJECT_BIN

#
# Custom build image for injective
#
FROM build_base AS build_injective

ARG VERSION
ARG BUILD_REF=$VERSION

RUN curl -Lo release.zip https://github.com/InjectiveLabs/injective-chain-releases/releases/download/$BUILD_REF/linux-amd64.zip && \
    unzip -oj release.zip && \
    mv injectived /bin && \
    mkdir -p deps/usr/lib && \
    mv libwasmvm.x86_64.so deps/usr/lib && \
    chmod +x /bin/injectived

#
# Final build environment
# Note optional `BUILD_METHOD` argument controls the base image
#
FROM build_${BUILD_METHOD} AS build

#
# Base image
#
FROM ${BASE_IMAGE} AS base

RUN apt-get update && \
    apt-get install --no-install-recommends --assume-yes \
    ca-certificates curl wget file unzip zstd liblz4-tool gnupg2 jq s3cmd pv && \
    apt-get clean

# Install Storj DCS uplink client
RUN curl -L https://github.com/storj/storj/releases/latest/download/uplink_linux_amd64.zip -o uplink_linux_amd64.zip && \
    unzip -o uplink_linux_amd64.zip && \
    install uplink /usr/bin/uplink && \
    rm -f uplink uplink_linux_amd64.zip

# Install Google Cloud SDK (for gsutil/gcloud)
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
      | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
      | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get install --no-install-recommends --assume-yes google-cloud-sdk && \
    apt-get clean

# Copy scripts
COPY entrypoint.sh snapshot.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh /usr/bin/snapshot.sh

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
FROM ${BASE_METHOD} AS omnibus
LABEL org.opencontainers.image.source=https://github.com/akash-network/cosmos-omnibus

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

WORKDIR /root
ENTRYPOINT ["entrypoint.sh"]
CMD []
