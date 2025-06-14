#!/usr/bin/env bash

restart_service() {
    stop_service || {
        error_log "Restart failed during stop operation"
        return 1
    }

    start_service || {
        error_log "Restart failed during start operation"
        return 1
    }

    success_log "$ZNNSH_SERVICE_NAME service restarted successfully"
}

export -f restart_service
