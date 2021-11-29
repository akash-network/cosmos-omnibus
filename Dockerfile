# Configurable arguments
ARG BUILD_ENV=default
ARG GOLANG_VERSION=1.16-buster

# Install build time dependencies
FROM golang:${GOLANG_VERSION} AS base

ARG APT_INSTALL_EXTRA_DEPS
ENV APT_INSTALL_EXTRA_DEPS=$APT_INSTALL_EXTRA_DEPS

RUN apt-get update && \
  apt-get install --no-install-recommends --assume-yes curl unzip && \
  apt-get clean

RUN echo ${APT_INSTALL_EXTRA_DEPS}
RUN apt-get install --no-install-recommends --assume-yes $APT_INSTALL_EXTRA_DEPS

FROM base AS aws

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip -d /usr/src

FROM base AS project

ARG PROJECT=akash
ARG PROJECT_BIN=$PROJECT
ARG VERSION=v0.12.1
ARG REPOSITORY=https://github.com/ovrclk/akash.git
ARG MAKE_ENV
ENV MAKE_ENV=$MAKE_ENV

# Clone and build project
RUN git clone $REPOSITORY /data
WORKDIR /data
RUN git checkout $VERSION
RUN export $MAKE_ENV; make install

RUN ldd $GOPATH/bin/$PROJECT_BIN | tr -s '[:blank:]' '\n' | grep '^/' | \
    xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'

RUN mv $GOPATH/bin/$PROJECT_BIN /bin/$PROJECT_BIN

FROM debian:buster AS build_default
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

COPY --from=project /bin/$PROJECT_BIN /bin/$PROJECT_BIN
COPY --from=project /data/deps/ /

COPY --from=aws /usr/src/aws /usr/src/aws
RUN /usr/src/aws/install --bin-dir /usr/bin

COPY run.sh snapshot.sh /usr/bin/
RUN chmod +x /usr/bin/run.sh /usr/bin/snapshot.sh
ENTRYPOINT ["run.sh"]

CMD $PROJECT_CMD

FROM build_default AS build_juno

ONBUILD ARG WASMVM_VERSION=main
ONBUILD ENV WASMVM_VERSION=$WASMVM_VERSION

ONBUILD ADD https://raw.githubusercontent.com/CosmWasm/wasmvm/$WASMVM_VERSION/api/libwasmvm.so /lib/libwasmvm.so

FROM build_${BUILD_ENV}
