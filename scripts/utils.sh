#!/usr/bin/env bash

# =============================================================================
# Utility Functions
# - Checksum verification
# - Architecture checks, etc.
# =============================================================================

# Source config and logging if not already sourced
[ -z "$PROJECT_ROOT" ] && echo "Error: config.sh not sourced." && exit 1

# verify_checksum(filename, downloaded_file)
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

rename_existing_dir() {
    local dir_name=$1
    if [ -d "$dir_name" ]; then
        local timestamp=$(date +"%Y%m%d%H%M%S")
        mv "$dir_name" "${dir_name}-${timestamp}"
        success_log "Renamed existing '$dir_name' to '${dir_name}-${timestamp}'."
    fi
}

detect_service_system() {
    if command -v systemctl &>/dev/null && pidof systemd &>/dev/null; then
        echo "systemd"
    else
        echo "process"
    fi
}
