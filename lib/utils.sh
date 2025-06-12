#!/usr/bin/env bash

set_node_config() {
	local node_type="${1:-zenon}"

	if [[ "$node_type" != "zenon" && "$node_type" != "hyperqube" ]]; then
    error_log "Invalid node type: $node_type. Using default: zenon"
    node_type="zenon"
  	fi

	export ZNNSH_NODE_TYPE="$node_type"
	export ZNNSH_REPO_URL="${ZNNSH_DEFAULT_NODE_CONFIG[${node_type}_repo]}"
	export ZNNSH_BRANCH_NAME="${ZNNSH_DEFAULT_NODE_CONFIG[${node_type}_branch]}"
	export ZNNSH_BINARY_NAME="${ZNNSH_DEFAULT_NODE_CONFIG[${node_type}_binary]}"
	export ZNNSH_SERVICE_NAME="${ZNNSH_DEFAULT_NODE_CONFIG[${node_type}_service]}"
}

verify_checksum() {
    local filename="$1"
    local downloaded_file="$2"

    local expected_checksum="${GO_CHECKSUMS[$filename]}"
    if [ -z "$expected_checksum" ]; then
        error_log "No checksum found for $filename"
        return 1
    fi

    local actual_checksum
    actual_checksum=$(sha256sum "$downloaded_file" | cut -d' ' -f1)

    if [ "$actual_checksum" != "$expected_checksum" ]; then
        error_log "Checksum verification failed for $filename"
        error_log "Expected: $expected_checksum"
        error_log "Got:      $actual_checksum"
        return 1
    fi

    return 0
}

stop_node_if_running() {
    if systemctl is-active --quiet "$ZNNSH_SERVICE_NAME"; then
        echo "Stopping $ZNNSH_SERVICE_NAME service..."
        systemctl stop "$ZNNSH_SERVICE_NAME"
        echo "$ZNNSH_SERVICE_NAME service stopped."
    else
        echo "$ZNNSH_SERVICE_NAME service is not running."
    fi
}

rename_existing_dir() {
    local dir_name=$1
    if [ -d "$dir_name" ]; then
        local timestamp
        timestamp=$(date +"%Y%m%d%H%M%S")
        mv "$dir_name" "${dir_name}-${timestamp}"
        success_log "Renamed existing '$dir_name' to '${dir_name}-${timestamp}'."
    fi
}

check_go_installation() {
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
