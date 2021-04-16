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

ENV  PROJECT=$PROJECT
ENV  PROJECT_BIN=$PROJECT_BIN

COPY dist/$PROJECT_BIN /bin/$PROJECT_BIN
