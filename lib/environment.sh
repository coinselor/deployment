#!/usr/bin/env bash

ZNNSH_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ZNNSH_LIB_DIR

source "$ZNNSH_LIB_DIR/config.sh"
source "$ZNNSH_LIB_DIR/gum.sh"
source "$ZNNSH_LIB_DIR/logging.sh"
source "$ZNNSH_LIB_DIR/utils.sh"
source "$ZNNSH_LIB_DIR/menu.sh"
source "$ZNNSH_LIB_DIR/help.sh"
source "$ZNNSH_LIB_DIR/build.sh"
source "$ZNNSH_LIB_DIR/start.sh"
source "$ZNNSH_LIB_DIR/stop.sh"
source "$ZNNSH_LIB_DIR/restart.sh"
source "$ZNNSH_LIB_DIR/resync.sh"
source "$ZNNSH_LIB_DIR/monitor.sh"
source "$ZNNSH_LIB_DIR/deploy.sh"
source "$ZNNSH_LIB_DIR/grafana.sh"
source "$ZNNSH_LIB_DIR/analytics.sh"
source "$ZNNSH_LIB_DIR/preflight.sh"

if gum spin --spinner meter --spinner.foreground 46 \
        --title "Initiating Spacecraft pre-flight checks..." \
        --show-output \
        -- bash -c "run_preflight"; then
    success_log "Pre-flight checks complete. Systems nominal. Go for launch."
else
    error_log "Failed to run pre-flight checks"
    return 1
fi