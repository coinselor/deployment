#!/usr/bin/env bash

start_service() {
    if systemctl is-active --quiet "$ZNNSH_SERVICE_NAME"; then
        info_log "$ZNNSH_SERVICE_NAME service is already running"
        return 0
    fi

    if systemctl start "$ZNNSH_SERVICE_NAME"; then
        success_log "$ZNNSH_SERVICE_NAME service started successfully"
    else
        error_log "Failed to start $ZNNSH_SERVICE_NAME service"
        return 1
    fi
}

export -f start_service