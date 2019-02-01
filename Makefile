# Makefile for projects using go mod.


#V := 1 # When V is set, print commands and build progress.

ARCHES:=386 amd64 arm64
OSES:=linux
BINARY:=mybinary

all: release

build:
	$Q for arch in $(ARCHES) ; do \
		for os in $(OSES); do \
			CGO_ENABLED=0 GOOS=$$os GOARCH=$$arch go build $(VERSION_FLAGS) -a -installsuffix cgo -o ./bin/$(BINARY)-$$os-$$arch $(IMPORT_PATH); \
		done ; \
	done

release: clean build
	$Q mkdir -p ./release
	$Q for arch in $(ARCHES) ;  do \
		for os in $(OSES) ; do \
		rm -rf ./tmp/$(BINARY) ; \
		mkdir -p ./tmp/$(BINARY) ; \
		cp -a ./bin/$(BINARY)-$$os-$$arch ./tmp/$(BINARY)/$(BINARY) ; \
		tar -cz -C ./tmp -f ./release/$(BINARY)-$$os-$$arch-$(VERSION).tar.gz ./$(BINARY) ; \
		done ; \
	done

##### =====> Utility targets <===== #####

.PHONY: clean gen setup

clean:
	$Q rm -rf bin
	$Q rm -rf /release/*-$(VERSION)*

gen:
	@echo "Running go generate"
	$Q go generate
	@echo "Done!"

setup:
	@echo "Running go mod init"
	$Q go mod init
	@echo "Done!"

.PHONY: all build release

##### =====> Internals <===== #####

Q                := $(if $V,,@)
IMPORT_PATH      := $(shell awk -F" " '$$1=="module"{print $$2;exit;}' go.mod)
VERSION          := $(shell git describe --tags --always --dirty="-dev")
DATE             := $(shell date -u '+%Y-%m-%d-%H%M UTC')
VERSION_FLAGS    := -ldflags='-s -w -X "main.Version=$(VERSION)" -X "main.BuildTime=$(DATE)"'
