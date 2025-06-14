#!/usr/bin/env bash

monitor_service() {
    if ! systemctl is-active --quiet "$ZNNSH_SERVICE_NAME"; then
        warn_log "$ZNNSH_SERVICE_NAME service is not running. Nothing to monitor."
        return 0
    fi

    gum style --border normal --margin "1" --padding "1 2" --border-foreground="#00FF00" "Monitoring $ZNNSH_SERVICE_NAME logs. Press Ctrl+C to stop."
    journalctl -u "$ZNNSH_SERVICE_NAME.service" -f --no-pager
}

export -f monitor_service