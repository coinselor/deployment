#!/usr/bin/env bash

resync_node() {
    local data_dir
    if [[ "$ZNNSH_NODE_TYPE" == "zenon" ]]; then
        data_dir="${ZNNSH_ZNN_DIR:-$HOME/.znn}"
    elif [[ "$ZNNSH_NODE_TYPE" == "hyperqube" ]]; then
        data_dir="${ZNNSH_HQZD_DIR:-$HOME/.hqzd}"
    else
        error_log "Unknown node type: $ZNNSH_NODE_TYPE"
        return 1
    fi

    if [[ "${ZNNSH_INTERACTIVE_MODE:-true}" == "true" ]]; then
        if ! gum confirm $'This option will delete all local data\nand force a full resync from genesis.\n\nThis is a destructive operation.\n\nAre you sure you want to continue?\n'; then
            warn_log "Resync cancelled by user"
            return 0
        fi
    fi

    local was_active="false"
    if systemctl is-active --quiet "$ZNNSH_SERVICE_NAME"; then
        was_active="true"
        info_log "$ZNNSH_SERVICE_NAME service is running, attempting to stop before resync…"
        stop_service || {
            error_log "Failed to stop $ZNNSH_SERVICE_NAME service; aborting resync"
            return 1
        }
    fi

        local dirs=("network" "nom" "consensus" "log")
    local removed=0
    for dir in "${dirs[@]}"; do
        local target="$data_dir/$dir"
        if [ -d "$target" ]; then
            rm -rf "$target"
            ((removed++))
            success_log "Deleted $target"
        else
            info_log "Directory $target does not exist; skipping"
        fi
    done

    if (( removed > 0 )); then
        success_log "$removed data director$( [[ $removed -eq 1 ]] && echo 'y' || echo 'ies') removed for $ZNNSH_NODE_TYPE. The node will resync from genesis on next start."
    else
        info_log "No data directories needed deletion for $ZNNSH_NODE_TYPE."
    fi

    if [[ "$was_active" == "true" ]]; then
        info_log "Restarting $ZNNSH_SERVICE_NAME service…"
        start_service || {
            error_log "Failed to restart $ZNNSH_SERVICE_NAME service after resync"
            return 1
        }
    fi
}

export -f resync_node