#!/usr/bin/env bash

restart_service() {
    stop_service || {
        error_log "Restart failed during stop operation"
        return 1
    }

    local max_attempts=10
    local attempt=0
    while [[ $attempt -lt $max_attempts ]]; do
        if ! systemctl is-active --quiet "$ZNNSH_SERVICE_NAME"; then
            break
        fi
        attempt=$((attempt + 1))
        sleep 0.5
    done
    
    if [[ $attempt -eq $max_attempts ]]; then
        error_log "Timed out waiting for $ZNNSH_SERVICE_NAME to stop"
        return 1
    fi

    start_service || {
        error_log "Restart failed during start operation"
        return 1
    }

    success_log "$ZNNSH_SERVICE_NAME service restarted successfully"
}

export -f restart_service
