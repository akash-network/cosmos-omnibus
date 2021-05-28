FROM golang:1.16-buster
LABEL org.opencontainers.image.source https://github.com/ovrclk/cosmos-omnibus

EXPOSE 26656 \
       26657 \
       1317  \
       9090  \
       8080

ARG PROJECT=akash
ARG PROJECT_BIN=$PROJECT
ARG VERSION=v0.12.1
ARG REPOSITORY=https://github.com/ovrclk/akash.git

ENV PROJECT=$PROJECT
ENV PROJECT_BIN=$PROJECT_BIN
ENV PROJECT_DIR=.$PROJECT_BIN
ENV VERSION=$VERSION

ENV MONIKER=my-omnibus-node
ENV NETWORK_VARIANT=mainnet
ENV METADATA_URL=https://raw.githubusercontent.com/ovrclk/cosmos-omnibus/master/$PROJECT/$NETWORK_VARIANT
ENV DENOM=uakt

RUN apt-get update && \
  apt-get install --no-install-recommends --assume-yes ca-certificates curl file && \
  apt-get clean

RUN git clone -b $VERSION $REPOSITORY /data
WORKDIR /data

RUN make install
RUN mv $GOPATH/bin/$PROJECT_BIN /bin/$PROJECT_BIN

COPY run.sh /usr/bin/
RUN chmod +x /usr/bin/run.sh
ENTRYPOINT ["run.sh"]

CMD $PROJECT_BIN start
