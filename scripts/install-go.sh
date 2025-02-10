#!/usr/bin/env bash

# =============================================================================
# Install Go
# Downloads and installs the specified Go version.
# =============================================================================

[ -z "$PROJECT_ROOT" ] && echo "Error: config.sh not sourced." && exit 1
. "$SCRIPT_DIR/logging.sh"
. "$SCRIPT_DIR/utils.sh"

setup_go_env() {
    export GOROOT="${PROJECT_ROOT}/go"
    export GOPATH="${PROJECT_ROOT}"
    export PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"
}

check_go_installation() {
    setup_go_env
    if command -v go &>/dev/null; then
        local current_version
        current_version=$(go version | awk '{print $3}' | sed 's/go//')
        if [[ "$current_version" == "$GO_VERSION" ]]; then
            success_log "Go $GO_VERSION is already installed"
            return 0
        else
            warn_log "Found Go $current_version, but $GO_VERSION is required"
            return 1
        fi
    else
        warn_log "Go is not installed"
        return 1
    fi
}

install_go() {
    success_log "Checking for existing Go installation..."
    if check_go_installation; then
        return 0
    fi

    rename_existing_dir "go"
    success_log "Downloading and installing Go..."
    curl -fsSLo "go.tar.gz" "$GO_URL"
    verify_checksum "go${GO_VERSION}.${GO_ARCH}.tar.gz" "go.tar.gz" || {
        rm go.tar.gz
        return 1
    }
    tar -C . -xzf "go.tar.gz"
    rm "go.tar.gz"

    setup_go_env
    success_log "Go installed successfully."
    success_log "Go version: $(go version)"
}
