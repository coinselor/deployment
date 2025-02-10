#!/usr/bin/env bash

[ -z "$PROJECT_ROOT" ] && echo "Error: config.sh not sourced." && exit 1
. "$SCRIPT_DIR/logging.sh"

restore_go_zenon() {
    local restore_script="go-zenon_restore.sh"
    local restore_url="https://gist.githubusercontent.com/0x3639/05c6e2ba6b7f0c2a502a6bb4da6f4746/raw/ff4343433b31a6c85020c887256c0fd3e18f01d9/restore.sh"

    gum spin --spinner dot --title "Downloading restore script..." -- \
        wget -O "$restore_script" "$restore_url" || {
        error_log "Failed to download restore script"
        return 1
    }

    gum spin --spinner dot --title "Setting execute permissions..." -- \
        chmod +x "$restore_script" || {
        error_log "Failed to set execute permissions"
        rm -f "$restore_script"
        return 1
    }

    gum spin --spinner dot --title "Running restore script..." -- \
        ./"$restore_script" || {
        error_log "Restore script failed"
        rm -f "$restore_script"
        return 1
    }

    gum spin --spinner dot --title "Cleaning up temporary files..." -- \
        rm -f "$restore_script"

    success_log "go-zenon restored from bootstrap"
}
