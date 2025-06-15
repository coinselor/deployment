#!/usr/bin/env bash

RESTORE_DIR="$ZNNSH_BACKUP_DIR/restore"
FOLDERS=("nom" "network" "consensus" "cache")

restore_node() {
    local service="$ZNNSH_SERVICE_NAME"
    local node_dir
    if [[ "${ZNNSH_NODE_TYPE}" == "hyperqube" ]]; then
        node_dir="/root/.hqzd"
    else
        node_dir="/root/.znn"
    fi

    mkdir -p "$RESTORE_DIR"

    local backup_file="${1:-}"

    if [[ -z "$backup_file" ]]; then

        if [[ "${ZNNSH_INTERACTIVE_MODE:-true}" == "true" ]]; then
            
            local -a files
            mapfile -t -d '' files < <(find "$ZNNSH_BACKUP_DIR" -maxdepth 1 -type f -name "${service}_backup_*.tar.gz" \
                -printf '%T@ %p\0' | sort -znr | head -z -n 50 | cut -z -d' ' -f2-)
            if (( ${#files[@]} == 0 )); then
                error_log "No backups found for $service in $ZNNSH_BACKUP_DIR"
                return 1
            fi
            
            local choices=""
            for f in "${files[@]}"; do
                choices+="$(basename "${f%.tar.gz}")\n"
            done
            local chosen
            chosen=$(printf "%b" "$choices" | gum choose --height 15 --cursor.foreground 46 --header "Select backup to restore") || { error_log "No selection"; return 1; }
            backup_file="$ZNNSH_BACKUP_DIR/${chosen}.tar.gz"
        else
            error_log "--backup-file <filename> required in non-interactive mode"
            return 1
        fi
    else
        if [[ "$backup_file" != *.tar.gz ]]; then
            backup_file="$ZNNSH_BACKUP_DIR/${backup_file}.tar.gz"
        fi
    fi

    if [[ ! -f "$backup_file" ]]; then
        error_log "Backup file $backup_file not found"
        return 1
    fi

    local hash_file="${backup_file%.tar.gz}.hash"
    if [[ ! -f "$hash_file" ]]; then
        error_log "Hash file missing for $backup_file"
        return 1
    fi

    info_log "Verifying backup integrity…"
    local calculated stored
    calculated=$(sha256sum "$backup_file" | awk '{print $1}')
    stored=$(cat "$hash_file")
    if [[ "$calculated" != "$stored" ]]; then
        error_log "Integrity check failed for $backup_file"
        return 1
    fi

    stop_service "$service"

    info_log "Backing up existing node directory (safety snapshot)"
    for folder in "${FOLDERS[@]}"; do
        if [[ -d "$node_dir/$folder" ]]; then
            mv "$node_dir/$folder" "$RESTORE_DIR/${folder}.bak.$(date +%s)" || warn_log "Failed to move $folder"
        fi
    done

    info_log "Extracting backup…"
    mkdir -p "$node_dir"
    tar -xzf "$backup_file" -C "$node_dir"

    success_log "${ZNNSH_SERVICE_NAME} data restored successfully."

    start_service "$service"
}

export -f restore_node
