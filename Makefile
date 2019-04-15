PKG_NAME:=github.com/ArtieReus/go-tester
BUILD_DIR:=bin
BINARY:=$(BUILD_DIR)/go-tester
LDFLAGS:=-s -w -X github.com/ArtieReus/go-tester/version.GITCOMMIT=`git rev-parse --short HEAD`


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
	go build -o $(BINARY)_linux -ldflags="$(LDFLAGS)" $(PKG_NAME)
	GOOS=windows GOARCH=amd64 go build -o $(BINARY)_windows.exe -ldflags="$(LDFLAGS)" $(PKG_NAME)

.PHONY: metalint
metalint:
	gometalinter --vendor --disable-all -E goimports -E staticcheck -E ineffassign -E gosec --deadline=60s ./...

.PHONY: release
release:
	echo "set GITHUB_TOKEN to a personal access token that has repo:read permission to run the release task"
	ci/prepare-release
