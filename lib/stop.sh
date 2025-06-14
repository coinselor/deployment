#!/usr/bin/env bash

stop_service() {
    if ! systemctl is-active --quiet "$ZNNSH_SERVICE_NAME"; then
        info_log "$ZNNSH_SERVICE_NAME service is not running"
        return 0
    fi

    if systemctl stop "$ZNNSH_SERVICE_NAME"; then
        success_log "$ZNNSH_SERVICE_NAME service stopped successfully"
    else
        error_log "Failed to stop $ZNNSH_SERVICE_NAME service"
        return 1
    fi
}

export -f stop_service
