#!/usr/bin/env bash

error_log() {
    if [[ "$ZNNSH_GUM_LOGS" == "true" ]]; then
        gum log --time Kitchen --level error --prefix="Zenon.sh" "$@"
        gum log --time Kitchen --level error --prefix="Zenon.sh" -o "$ZNNSH_LOG_FILE" "$@"
    else
        printf "[ERROR] %s\n" "$*" | tee -a "$ZNNSH_LOG_FILE" >&2
    fi
}

warn_log() {
    if [[ "$ZNNSH_GUM_LOGS" == "true" ]]; then
        gum log --time Kitchen --level warn --prefix="Zenon.sh" "$@"
        gum log --time Kitchen --level warn --prefix="Zenon.sh" -o "$ZNNSH_LOG_FILE" "$@"
    else
        printf "[WARN] %s\n" "$*" | tee -a "$ZNNSH_LOG_FILE" >&2
    fi
}

info_log() {
    if [[ "$ZNNSH_GUM_LOGS" == "true" ]]; then
        gum log --time Kitchen --level info --prefix="Zenon.sh" "$@"
        gum log --time Kitchen --level info --prefix="Zenon.sh" -o "$ZNNSH_LOG_FILE" "$@"
    else
        printf "[INFO] %s\n" "$*" | tee -a "$ZNNSH_LOG_FILE"
    fi
}
success_log() {
    if [[ "$ZNNSH_GUM_LOGS" == "true" ]]; then
        gum log --time Kitchen --level info --prefix="Zenon.sh" "✓ $*"
        gum log --time Kitchen --level info --prefix="Zenon.sh" -o "$ZNNSH_LOG_FILE" "✓ $*"
    else
        printf "✓ %s\n" "$*" | tee -a "$ZNNSH_LOG_FILE"
    fi
}

export -f error_log warn_log info_log success_log