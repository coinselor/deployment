#!/usr/bin/env bash

start_service() {
    if ! systemctl status "$ZNNSH_SERVICE_NAME" &>/dev/null; then
        [[ $? -eq 4 ]] && { error_log "$ZNNSH_SERVICE_NAME service does not exist"; return 1; }
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