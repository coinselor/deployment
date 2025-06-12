#!/usr/bin/env bash

stop() {
    local debug=""
    if [[ "$ZNNSH_DEBUG" = true ]]; then
        debug="--show-output"
    fi

    gum spin --spinner meter --title "Stopping $ZNNSH_SERVICE_NAME service..." $debug -- systemctl stop "$ZNNSH_SERVICE_NAME" || {
        error_log "Failed to stop $ZNNSH_SERVICE_NAME service"
        return 1
    }

    success_log "$ZNNSH_SERVICE_NAME service stopped successfully"
}