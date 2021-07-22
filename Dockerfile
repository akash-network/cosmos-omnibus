FROM golang:1.16-buster AS build

RUN apt-get update && \
  apt-get install --no-install-recommends --assume-yes curl unzip  && \
  apt-get clean

FROM build AS aws

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip -d /usr/src

FROM build AS project

ARG PROJECT=akash
ARG PROJECT_BIN=$PROJECT
ARG VERSION=v0.12.1
ARG REPOSITORY=https://github.com/ovrclk/akash.git
ARG USE_STARPORT=$USE_STARPORT
ARG STARPORT_REPO=$STARPORT_REPO

# RUN apt-get install -y git-lfs protobuf-compiler nodejs
RUN if [ "$USE_STARPORT" = "true" ]; then git clone $STARPORT_REPO /starport; fi
RUN if [ "$USE_STARPORT" = "true" ]; then apt-get install -y git-lfs protobuf-compiler nodejs; fi
WORKDIR /starport
RUN if [ "$USE_STARPORT" = "true" ]; then git checkout develop && make; fi
#RUN git checkout develop && make

RUN git clone $REPOSITORY /data
WORKDIR /data
RUN git checkout $VERSION
RUN starport chain build
RUN mv $GOPATH/bin/$PROJECT_BIN /bin/$PROJECT_BIN
RUN cp $GOPATH/pkg/mod/github.com/!cosm!wasm/wasmvm@v0.14.0/api/libwasmvm.so /lib/libwasmvm.so

FROM debian:buster
LABEL org.opencontainers.image.source https://github.com/ovrclk/cosmos-omnibus

RUN apt-get update && \
  apt-get install --no-install-recommends --assume-yes ca-certificates curl wget file unzip gnupg2 jq && \
  apt-get clean

ARG PROJECT=akash
ARG PROJECT_BIN=$PROJECT
ARG PROJECT_DIR=.$PROJECT_BIN
ARG VERSION=v0
ARG REPOSITORY=https://github.com/ovrclk/akash.git
ARG NAMESPACE

ENV PROJECT=$PROJECT
ENV PROJECT_BIN=$PROJECT_BIN
ENV PROJECT_DIR=$PROJECT_DIR
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
COPY --from=project /lib/libwasmvm.so /lib/libwasmvm.so
COPY --from=aws /usr/src/aws /usr/src/aws
RUN /usr/src/aws/install --bin-dir /usr/bin

COPY run.sh /usr/bin/
RUN chmod +x /usr/bin/run.sh
ENTRYPOINT ["run.sh"]

CMD $PROJECT_BIN start
