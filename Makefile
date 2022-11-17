# Makefile for projects using go mod.

#V := 1 # When V is set, print commands and build progress.

ARCHES     := 386 amd64 arm64
OSES       := linux
BIN        := bin
RELEASE    := release
TMPDIR     := tmp
OTHERFILES :=
GO         := go
MODULE     := $(shell $(GO) list -m)
V          := 0

all: release ; $(info $(M) Making all…) @ ## Make all

build: dirs ; $(info $(M) Building all binaries…) @ ## Build all
	$Q for arch in $(ARCHES) ; do \
		for os in $(OSES); do \
			CGO_ENABLED=0 GOOS=$$os GOARCH=$$arch $(GO) build $(VERSION_FLAGS) -o $(BIN)/$(basename $(MODULE))-$$os-$$arch ; \
		done ; \
	done

release: clean build ; $(info $(M) Making releases…) @ ## Make releases
	$Q for arch in $(ARCHES) ;  do \
		for os in $(OSES) ; do \
			rm -rf $(TMPDIR)/* ; \
			for file in ${OTHERFILES} ""; do \
				[ -n "$$file" ] || continue; \
				cp -a $$file $(TMPDIR)/; \
			done ; \
			cp -a $(BIN)/$(MODULE)-$$os-$$arch $(TMPDIR)/ ; \
			tar -cz -C $(TMPDIR)/ -f $(RELEASE)/$(MODULE)-$$os-$$arch-$(VERSION).tar.gz \. ; \
		done ; \
	done

##### =====> Utility targets <===== #####

.PHONY: dirs clean gen setup

dirs: ; $(info $(M) Making dirs…) @ ## Make Dirs
	@mkdir -p $(BIN) $(RELEASE) $(TMPDIR)

clean: ; $(info $(M) Making clean…) @ ## Make clean
	$Q rm -rf $(BIN)
	$Q rm -rf $(RELEASE)/*-$(VERSION)*
	$Q rm -rf $(TMPDIR)

gen: ; $(info $(M) Making generate…) @ ## Make generate
	$Q $(GO) generate

setup: ; $(info $(M) Making setup (go mod init)…) @ ## Make setup
	$Q $(GO) mod init

.PHONY: all build release

##### =====> Internals <===== #####
Q             := $(if $(filter 1,$V),,@)
M             := $(shell if [ "$$(tput colors 2> /dev/null || echo 0)" -ge 8 ]; then printf "\033[34;1m▶\033[0m"; else printf "▶"; fi)
VERSION       := $(shell git describe --tags --always --dirty="-dev")
DATE          := $(shell date -u '+%Y-%m-%d-%H%M UTC')
VERSION_FLAGS := -ldflags='-s -w -X "main.Version=$(VERSION)" -X "main.BuildDate=$(DATE)"'
