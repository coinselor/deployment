#!/usr/bin/env bash

error_log() {
    if [[ "$ZNNSH_GUM_LOGS" == "true" ]]; then
        gum log --time Kitchen --level error "$@" >&2
    else
        printf "[ERROR] %s\n" "$*" >&2
    fi
}

warn_log() {
    if [[ "$ZNNSH_GUM_LOGS" == "true" ]]; then
        gum log --time Kitchen --level warn "$@" >&2
    else
        printf "[WARN] %s\n" "$*" >&2
    fi
}

info_log() {
    if [[ "$ZNNSH_GUM_LOGS" == "true" ]]; then
        gum log --time Kitchen --level info "$@"
    else
        printf "[INFO] %s\n" "$*"
    fi
}
success_log() {
    if [[ "$ZNNSH_GUM_LOGS" == "true" ]]; then
        gum log --time Kitchen --level info "✓ $*"
    else
        printf "✓ %s\n" "$*"
    fi
}
