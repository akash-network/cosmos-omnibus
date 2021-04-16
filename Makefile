KAVA_VERSION  ?= v0.14.1
GAIAD_VERSION ?= v4.2.1
DVPN_VERSION  ?= v0.5.0
AKASH_VERSION ?= v0.12.1

BUILD_DIR := $(PWD)/build
DIST_DIR  := $(PWD)/dist

DOCKER_IMAGE := ghcr.io/ovrclk/cosmos-omnibus

.PHONY: build-all
build-all: build-kava build-gaia build-dvpn build-akash

.PHONY: image-all
image-all: image-kava image-gaia image-dvpn image-akash

.PHONY: build-kava
build-kava: build-init
	git clone https://github.com/Kava-Labs/kava.git "$(BUILD_DIR)/kava"
	cd "$(BUILD_DIR)/kava" && \
	git checkout "$(KAVA_VERSION)" && \
	GOBIN="$(DIST_DIR)" make install

.PHONY: image-kava
image-kava: build-kava
	docker build . --tag $(DOCKER_IMAGE):kava \
		--build-arg PROJECT=kava \
		--build-arg PROJECT_VERSION=$(KAVA_VERSION) \
		--build-arg PROJECT_BIN=kvd

.PHONY: build-gaiad
build-gaiad: build-init
	curl -sL "https://github.com/cosmos/gaia/releases/download/$(GAIAD_VERSION)/gaiad-$(GAIAD_VERSION)-linux-amd64" \
		> "$(DIST_DIR)/gaiad"
	chmod a+x "$(DIST_DIR)/gaiad"

.PHONY: image-gaiad
image-gaiad: build-gaiad
	docker build . --tag $(DOCKER_IMAGE):gaiad \
		--build-arg PROJECT=gaiad \
		--build-arg PROJECT_VERSION=$(GAIAD_VERSION) \
		--build-arg PROJECT_BIN=gaiad

.PHONY: build-dvpn
build-dvpn: build-init
	git clone https://github.com/sentinel-official/hub.git "$(BUILD_DIR)/dvpn-hub"
	cd "$(BUILD_DIR)/dvpn-hub" && \
		mkdir -p dist && \
		PATH=$$PATH:./dist GOBIN=$$PWD/dist make tools install && \
		cp dist/sentinelhub "$(DIST_DIR)"

.PHONY: image-dvpn
image-dvpn: build-dvpn
	docker build . --tag $(DOCKER_IMAGE):dvpn \
		--build-arg PROJECT=dvpn \
		--build-arg PROJECT_VERSION=$(DVPN_VERSION) \
		--build-arg PROJECT_BIN=sentinelhub

.PHONY: build-akash
build-akash: build-init
	curl -sL "https://raw.githubusercontent.com/ovrclk/akash/$(AKASH_VERSION)/godownloader.sh" | \
		sh -s -- -b "$(DIST_DIR)" "$(AKASH_VERSION)"

.PHONY: image-akash
image-akash: build-akash
	docker build . --tag $(DOCKER_IMAGE):akash \
		--build-arg PROJECT=akash \
		--build-arg PROJECT_VERSION=$(AKASH_VERSION) \
		--build-arg PROJECT_BIN=akash

.PHONY: build-init
build-init:
	mkdir -p "$(BUILD_DIR)"
	mkdir -p "$(DIST_DIR)"

.PHONY: clean
clean:
	rm -rf "$(BUILD_DIR)" "$(DIST_DIR)"
