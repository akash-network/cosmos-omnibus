KAVA_VERSION  ?= v0.14.1
GAIAD_VERSION ?= v4.2.1
DVPN_VERSION  ?= v0.5.0
AKASH_VERSION ?= v0.12.1

BUILD_DIR := $(PWD)/build
DIST_DIR  := $(PWD)/dist

.PHONY: all
all: build-kava build-gaia build-dvpn build-akash

.PHONY: build-kava
build-kava: build-init
	git clone https://github.com/Kava-Labs/kava.git "$(BUILD_DIR)/kava"
	cd "$(BUILD_DIR)/kava" && \
	git checkout "$(KAVA_VERSION)" && \
	GOBIN="$(DIST_DIR)" make install

.PHONY: build-gaiad
build-gaiad: build-init
	curl -sL "https://github.com/cosmos/gaia/releases/download/$(GAIAD_VERSION)/gaiad-$(GAIAD_VERSION)-linux-amd64" \
		> "$(DIST_DIR)/gaiad"
	chmod a+x "$(DIST_DIR)/gaiad"

.PHONY: build-dvpn
build-dvpn: build-init
	git clone https://github.com/sentinel-official/hub.git "$(BUILD_DIR)/dvpn-hub"
	cd "$(BUILD_DIR)/dvpn-hub" && \
		mkdir -p dist && \
		PATH=$$PATH:./dist GOBIN=$$PWD/dist make tools install && \
		cp dist/sentinelhub "$(DIST_DIR)"

.PHONY: build-akash
build-akash: build-init
	curl -sL "https://raw.githubusercontent.com/ovrclk/akash/$(AKASH_VERSION)/godownloader.sh" | \
		sh -s -- -b "$(DIST_DIR)" "$(AKASH_VERSION)"

.PHONY: build-init
build-init:
	mkdir -p "$(BUILD_DIR)"
	mkdir -p "$(DIST_DIR)"

.PHONY: clean
clean:
	rm -rf "$(BUILD_DIR)" "$(DIST_DIR)"
