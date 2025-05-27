#!/usr/bin/env bash

# =============================================================================
# Logging Utilities
# Provides error_log, warn_log, info_log, success_log functions using gum.
# =============================================================================

error_log() {
    gum log --time rfc822 --level error "$@" >&2
}

warn_log() {
    gum log --time rfc822 --level warn "$@" >&2
}

info_log() {
    gum log --time rfc822 --level info "$@"
}

success_log() {
    gum log --time rfc822 --level info "✓ $@"
}
