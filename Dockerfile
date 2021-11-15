FROM golang:1.16-buster AS build

RUN apt-get update && \
  apt-get install --no-install-recommends --assume-yes curl unzip && \
  apt-get clean

FROM build AS aws

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip -d /usr/src

FROM build AS project

ARG PROJECT=akash
ARG PROJECT_BIN=$PROJECT
ARG VERSION=v0.12.1
ARG REPOSITORY=https://github.com/ovrclk/akash.git

# Clone and build project
RUN git clone $REPOSITORY /data
WORKDIR /data
RUN git checkout $VERSION
RUN make install
RUN mv $GOPATH/bin/$PROJECT_BIN /bin/$PROJECT_BIN

FROM debian:buster
LABEL org.opencontainers.image.source https://github.com/ovrclk/cosmos-omnibus

RUN apt-get update && \
  apt-get install --no-install-recommends --assume-yes ca-certificates curl wget file unzip gnupg2 jq && \
  apt-get clean

ARG PROJECT=akash
ARG PROJECT_BIN=$PROJECT
ARG PROJECT_DIR=.$PROJECT_BIN
ARG PROJECT_CMD="$PROJECT_BIN start"
ARG VERSION=v0.12.1
ARG WASMVM_VERSION=main
ARG REPOSITORY=https://github.com/ovrclk/akash.git
ARG NAMESPACE

ENV PROJECT=$PROJECT
ENV PROJECT_BIN=$PROJECT_BIN
ENV PROJECT_DIR=$PROJECT_DIR
ENV PROJECT_CMD=$PROJECT_CMD
ENV VERSION=$VERSION
ENV REPOSITORY=$REPOSITORY
ENV NAMESPACE=$NAMESPACE
ENV WASMVM_VERSION=$WASMVM_VERSION

ENV MONIKER=my-omnibus-node

EXPOSE 26656 \
       26657 \
       1317  \
       9090  \
       8080

COPY --from=project /bin/$PROJECT_BIN /bin/$PROJECT_BIN
COPY --from=aws /usr/src/aws /usr/src/aws
RUN /usr/src/aws/install --bin-dir /usr/bin
ADD https://raw.githubusercontent.com/CosmWasm/wasmvm/$WASMVM_VERSION/api/libwasmvm.so /lib/libwasmvm.so

COPY run.sh snapshot.sh /usr/bin/
RUN chmod +x /usr/bin/run.sh /usr/bin/snapshot.sh
ENTRYPOINT ["run.sh"]

CMD $PROJECT_CMD
