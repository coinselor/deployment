#!/usr/bin/env bash

error_log() {
    if [[ "$ZNNSH_GUM_LOGS" == "true" ]]; then
        gum log --time Kitchen --level error --prefix="Zenon.sh" "$@" >&2
    else
        printf "[ERROR] %s\n" "$*" >&2
    fi
}

warn_log() {
    if [[ "$ZNNSH_GUM_LOGS" == "true" ]]; then
        gum log --time Kitchen --level warn --prefix="Zenon.sh" "$@" >&2
    else
        printf "[WARN] %s\n" "$*" >&2
    fi
}

info_log() {
    if [[ "$ZNNSH_GUM_LOGS" == "true" ]]; then
        gum log --time Kitchen --level info --prefix="Zenon.sh" "$@"
    else
        printf "[INFO] %s\n" "$*"
    fi
}
success_log() {
    if [[ "$ZNNSH_GUM_LOGS" == "true" ]]; then
        gum log --time Kitchen --level info --prefix="Zenon.sh" "✓ $*"
    else
        printf "✓ %s\n" "$*"
    fi
}

export -f error_log
export -f warn_log
export -f info_log
export -f success_log