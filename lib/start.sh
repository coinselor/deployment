#!/usr/bin/env bash

start_service() {
    if ! systemctl list-unit-files --type=service | grep -q "^${ZNNSH_SERVICE_NAME}\.service"; then
        error_log "$ZNNSH_SERVICE_NAME service is not installed (unit file missing)"
        return 1
    fi

    if systemctl is-active --quiet "$ZNNSH_SERVICE_NAME"; then
        info_log "$ZNNSH_SERVICE_NAME service is already running"
        return 0
    fi

    if systemctl start "$ZNNSH_SERVICE_NAME" >>"$ZNNSH_LOG_FILE" 2>&1; then
        success_log "$ZNNSH_SERVICE_NAME service started successfully"
    else
        error_log "Failed to start $ZNNSH_SERVICE_NAME service"
        return 1
    fi
}

export -f start_service