#!/usr/bin/env bash

verify_cpu() {
    local cores
    cores=$(nproc)
    if (( cores < 4 )); then
        error_log "Only $cores CPU cores detected. Minimum 4 required."
        return 1
    fi
    success_log "CPU check passed ($cores cores)"
}

verify_memory() {
    local mem_total_kb mem_avail_kb
    mem_total_kb=$(grep -i '^MemTotal:' /proc/meminfo | awk '{print $2}')
    mem_avail_kb=$(grep -i '^MemAvailable:' /proc/meminfo | awk '{print $2}')

    local mem_total_gb mem_avail_gb
    mem_total_gb=$(( mem_total_kb / 1024 / 1024 ))
    mem_avail_gb=$(( mem_avail_kb / 1024 / 1024 ))

    if (( mem_total_gb < 4 )); then
        error_log "Total RAM ${mem_total_gb}GiB detected. Minimum 4GiB required."
        return 1
    fi
    if (( mem_avail_gb < 2 )); then
        warn_log "Only ${mem_avail_gb}GiB free memory available. 2GiB recommended."
    fi

    success_log "Memory check passed (${mem_total_gb}GiB total, ${mem_avail_gb}GiB free)"
}

verify_ntp() {
    local conf_file="/etc/systemd/timesyncd.conf"

    if [[ ! -f $conf_file ]]; then
        info_log "timesyncd.conf not found. Creating default file."
        echo -e "[Time]\nNTP=time.cloudflare.com" > "$conf_file"
    fi

    if ! grep -qi "^\s*\[Time\]\s*$" "$conf_file"; then
        info_log "Adding [Time] section to timesyncd.conf"
        printf '\n[Time]\n' >> "$conf_file"
    fi

    if grep -qi "^\s*NTP=\s*time.cloudflare.com\s*$" "$conf_file"; then
        success_log "NTP already configured (time.cloudflare.com)"
    else
        info_log "Setting Cloudflare NTP server in timesyncd.conf"
        sed -i -E '/^\s*NTP=/Id' "$conf_file"
        sed -i -E '/^\s*\[Time\]\s*$/a NTP=time.cloudflare.com' "$conf_file"
        systemctl restart systemd-timesyncd.service
        success_log "NTP configuration applied and timesyncd restarted"
    fi
}

verify_internet() {
    local connected=false
    if ping -c1 -W2 1.1.1.1 >/dev/null 2>&1; then
        connected=true
    elif curl -fsSL --max-time 5 https://www.google.com/generate_204 >/dev/null; then
        connected=true
    fi

    if ! $connected; then
        error_log "No outbound Internet connectivity detected"
        return 1
    fi

    success_log "Internet connectivity"
}

run_preflight() {
    gum style \
        --border-foreground 239 \
        --foreground 239 \
        "==== PRE-FLIGHT CHECKS ===="
    info_log "Running pre-flight checks…"

    verify_cpu || exit 1
    verify_memory || exit 1
    verify_ntp || exit 1
    verify_internet || exit 1
}

export -f verify_cpu verify_memory verify_ntp verify_internet run_preflight
