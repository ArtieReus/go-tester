PKG_NAME:=github.com/ArtieReus/go-tester
BUILD_DIR:=bin
BINARY:=$(BUILD_DIR)/go-tester
BUILD_IMAGE := go-tester
TARGETS:=linux/amd64 windows/amd64

GO_TESTER_BIN_TPL:=go-tester_{{.OS}}_{{.Arch}}
ifneq ($(BUILD_VERSION),)
LDFLAGS:=-s -w -X github.com/ArtieReus/go-tester/version.GITCOMMIT=`git rev-parse --short HEAD`
GO_TESTER_BIN_TPL:=go-tester_$(BUILD_VERSION)_{{.OS}}_{{.Arch}}
endif


.PHONY: help
help:
	@echo
	@echo "Available targets:"
	@echo "  * build             - build the binary, output to $(BINARY)"
	@echo "  * metalint          - run metalint checks"
	@echo "  * release           - release candidate"


.PHONY: build
build:
	@mkdir -p $(BUILD_DIR)
	go build -o $(BINARY) -ldflags="$(LDFLAGS)" $(PKG_NAME)
# 	go build -o $(BINARY)_linux -ldflags="$(LDFLAGS)" $(PKG_NAME)
	GOOS=windows GOARCH=amd64 go build -o $(BINARY)_windows_amd64.exe -ldflags="$(LDFLAGS)" $(PKG_NAME)
	GOOS=linux GOARCH=amd64 go build -o $(BINARY)_linux_amd64 -ldflags="$(LDFLAGS)" $(PKG_NAME)

.PHONY: build-image
build-image:
	docker build -t $(BUILD_IMAGE) .

.PHONY: metalint
metalint:
	gometalinter --vendor --disable-all -E goimports -E staticcheck -E ineffassign -E gosec --deadline=60s ./...

.PHONY: release
release:
	echo "set GITHUB_TOKEN to a personal access token that has repo:read permission to run the release task"
	ci/prepare-release

.PHONY: cross
cross:
	@# -w omit DWARF symbol table -> smaller
	@# -s stip binary
	docker run \
		--rm \
		-v $(CURDIR):/go/src/$(PKG_NAME) \
		-w /go/src/$(PKG_NAME) \
		$(BUILD_IMAGE) \
		make cross-compile TARGETS="$(TARGETS)" BUILD_VERSION=$(BUILD_VERSION)

.PHONY: cross-compile
cross-compile:
	gox -osarch="$(TARGETS)" -output="bin/$(GO_TESTER_BIN_TPL)" -ldflags="$(LDFLAGS)" $(PKG_NAME)
