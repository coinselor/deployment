#!/usr/bin/env bash

start() {
    local debug=""
    if [[ "$ZNNSH_DEBUG" = true ]]; then
        debug="--show-output"
    fi

    gum spin --spinner meter --title "Starting $ZNNSH_SERVICE_NAME service..." $debug -- systemctl start "$ZNNSH_SERVICE_NAME" || {
        error_log "Failed to start $ZNNSH_SERVICE_NAME service"
        return 1
    }

    success_log "$ZNNSH_SERVICE_NAME service started successfully"
}