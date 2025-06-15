#!/usr/bin/env bash

TEMP_DIR="$ZNNSH_BACKUP_DIR/temp"
FOLDERS=("nom" "network" "consensus" "cache")

backup_node() {
    local service="$ZNNSH_SERVICE_NAME"
    local node_dir
    if [[ "${ZNNSH_NODE_TYPE}" == "hyperqube" ]]; then
        node_dir="/root/.hqzd"
    else
        node_dir="/root/.znn"
    fi


    info_log "Using backup directory: $ZNNSH_BACKUP_DIR (Keeping $ZNNSH_MAX_BACKUPS copies)"

    mkdir -p "$ZNNSH_BACKUP_DIR" "$TEMP_DIR" "$RESTORE_DIR"

    if [[ "${ZNNSH_INTERACTIVE_MODE:-true}" != "true" ]] && (( ZNNSH_BACKUP_CADENCE_DAYS > 0 )); then
        local last_backup
           last_backup=$(find "$ZNNSH_BACKUP_DIR" -name "${service}_backup_*.tar.gz" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2- || true)
        if [[ -n "$last_backup" ]]; then
            local last_epoch now_epoch diff_days
            last_epoch=$(date -r "$last_backup" +%s)
            now_epoch=$(date +%s)
            diff_days=$(( (now_epoch - last_epoch) / 86400 ))
            if (( diff_days < ZNNSH_BACKUP_CADENCE_DAYS )); then
                info_log "Skipping backup – cadence ${ZNNSH_BACKUP_CADENCE_DAYS}d not reached (last ${diff_days}d ago)."
                return 0
            fi
        fi
    fi

    local avail used_percent
    avail=$(df -k "$ZNNSH_BACKUP_DIR" | tail -1 | awk '{print $4}')
    used_percent=$(df -k "$ZNNSH_BACKUP_DIR" | tail -1 | awk '{print $5}' | sed 's/%//')
    
    info_log "Disk space: $((avail/1024)) MB available (${used_percent}% used)"
    
    if (( avail < ZNNSH_MIN_FREE_SPACE_KB )); then
        warn_log "Low disk space detected. Attempting cleanup..."
        prune_old_backups "$ZNNSH_SERVICE_NAME"
        
        avail=$(df -k "$ZNNSH_BACKUP_DIR" | tail -1 | awk '{print $4}')
        if (( avail < ZNNSH_MIN_FREE_SPACE_KB )); then
            error_log "Insufficient disk space even after cleanup: $((avail/1024)) MB available"
            return 1
        fi
    fi

    stop_service

    local ts backup_file hash_file
    ts=$(date +"%m-%d-%y_%H%M%S")
    backup_file="${service}_backup_${ts}.tar.gz"
    hash_file="${backup_file%.tar.gz}.hash"

    info_log "Copying node data…"
    rm -rf "${TEMP_DIR:?}"/*
    cd "$node_dir" || { error_log "Cannot cd to $node_dir"; return 1; }
    for folder in "${FOLDERS[@]}"; do
        if [[ -d $folder ]]; then
            cp -a "$folder" "$TEMP_DIR/" || { error_log "Failed to copy $folder"; return 1; }
        else
            info_log "Skipping missing $folder"
        fi
    done

    start_service

    info_log "Creating archive $backup_file…"
    cd "$TEMP_DIR" || { error_log "Cannot cd to $TEMP_DIR"; return 1; }
    tar -czf "$ZNNSH_BACKUP_DIR/$backup_file" .

    sha256sum "$ZNNSH_BACKUP_DIR/$backup_file" | awk '{print $1}' > "$ZNNSH_BACKUP_DIR/$hash_file"

    rm -rf "${TEMP_DIR:?}"/*

    success_log "Backup completed: $backup_file"

    prune_old_backups "$service"

    if [[ "${ZNNSH_INTERACTIVE_MODE:-true}" == "true" ]]; then
        if gum confirm "Would you like to set up recurring backups?"; then

            local input_max cadence_choice days hour_input
            input_max=$(gum input --placeholder "$ZNNSH_MAX_BACKUPS" --prompt "Max backups to keep (1-30) ➜ " || echo "")
            if [[ -n "$input_max" && "$input_max" =~ ^[1-9][0-9]?$ && "$input_max" -le 30 ]]; then
                ZNNSH_MAX_BACKUPS="$input_max"
            fi
            cadence_choice=$(printf "none\ndaily\nweekly\ncustom" | gum choose --cursor.foreground 46 --header "Select backup cadence" || echo "daily")
            case "$cadence_choice" in
              none)   ZNNSH_BACKUP_CADENCE_DAYS=0;;
              daily)  ZNNSH_BACKUP_CADENCE_DAYS=1;;
              weekly) ZNNSH_BACKUP_CADENCE_DAYS=7;;
              custom)
                  days=$(gum input --placeholder "0" --prompt "Days between backups (0-365) ➜ " || echo "0")
                  if [[ "$days" =~ ^[0-9]+$ && "$days" -le 365 ]]; then
                     ZNNSH_BACKUP_CADENCE_DAYS="$days"
                  fi;;
            esac
          
            hour_input=$(gum input --placeholder "2" --prompt "Hour of day (0-23) to run backup ➜ " || echo "")
            if [[ "$hour_input" =~ ^([0-9]|1[0-9]|2[0-3])$ ]]; then
                export ZNNSH_BACKUP_HOUR="$hour_input"
            else
                unset ZNNSH_BACKUP_HOUR
                error_log "Invalid hour input. Backup will run at a random time between 2–4 AM."
            fi
            setup_cron_job "$service"
        fi
    fi
}

setup_cron_job() {
    local service="$1"
    
    local hash minute hour minute_pad
    hash=$(printf '%s' "${HOSTNAME}${service}" | sha256sum | cut -c1-4)
    minute=$(( 0x${hash:0:2} % 60 ))          # 0-59
    if [[ -n "${ZNNSH_BACKUP_HOUR:-}" ]]; then
        hour="${ZNNSH_BACKUP_HOUR}"
    else
        hour=$(( 2 + (0x${hash:2:2} % 3) ))   # 2-4
    fi
    minute_pad=$(printf '%02d' "$minute")

    local cron_file="/etc/cron.d/znnsh_backup_${service}"
    local cmd="${BASH_SOURCE[0]%/*}/../zenon.sh --backup ${ZNNSH_NODE_TYPE} --max-backups ${ZNNSH_MAX_BACKUPS} --cadence ${ZNNSH_BACKUP_CADENCE_DAYS}"

    echo "$minute $hour * * * root $cmd >> /var/log/znnsh-backup.log 2>&1" > "$cron_file"
    chmod 644 "$cron_file"
    success_log "Recurring backups scheduled for ${hour}:${minute_pad} via cron (file: $cron_file)"
}



prune_old_backups() {
    local service="$1"
    local keep=$(( ZNNSH_MAX_BACKUPS ))

    find "$ZNNSH_BACKUP_DIR" -maxdepth 1 -type f -name "${service}_backup_*.tar.gz" \
        -printf '%T@ %p\0' | sort -znr | tail -z -n +$((keep + 1)) | cut -z -d' ' -f2- | \
        while IFS= read -r -d '' f; do
            info_log "Removing old backup $(basename "$f")"
            rm -f -- "$f" "${f%.tar.gz}.hash"
        done
}

export -f backup_node setup_cron_job prune_old_backups