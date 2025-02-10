#!/usr/bin/env bash

# =============================================================================
# Logging Utilities
# Provides error_log, warn_log, success_log functions using gum.
# =============================================================================

error_log() {
    gum log --level error "$@" >&2
}

warn_log() {
    gum log --level warn "$@" >&2
}

success_log() {
    gum log --level info "✓ $@"
}
