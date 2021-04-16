from debian:buster
LABEL org.opencontainers.image.source https://github.com/ovrclk/cosmos-omnibus

RUN apt-get update && \
  apt-get install --no-install-recommends --assume-yes ca-certificates curl && \
  apt-get clean

EXPOSE 26656 \
       26657 \
       1317  \
       9090  \
       8080

ARG  PROJECT
ARG  PROJECT_BIN
ARG  PROJECT_VERSION

ENV COSMOS_OMNIBUS_PROJECT=$PROJECT
ENV COSMOS_OMNIBUS_PROJECT_VERSION=$PROJECT_VERSION

ENV NODE_HOME=/data

COPY dist/$PROJECT_BIN /bin/node

COPY run.sh /run.sh

WORKDIR /

ENTRYPOINT ["/run.sh"]
