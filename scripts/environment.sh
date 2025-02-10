#!/usr/bin/env bash

# =============================================================================
# Zenon Environment Setup
# 
# This script sets up the Go environment variables and PATH modifications.
# It should be sourced after config.sh.
# =============================================================================

# Ensure config.sh has been sourced
if [ -z "$SCRIPT_DIR" ]; then
    echo "Error: config.sh must be sourced before environment.sh" >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# Go Environment Variables
# -----------------------------------------------------------------------------
# Set GOROOT to our local Go installation
export GOROOT="${PROJECT_ROOT}/go"

# Set GOPATH to our project root
export GOPATH="${PROJECT_ROOT}"

# Add Go binary directories to PATH
export PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"

# Optional: Set GOCACHE to a specific location
# export GOCACHE="${PROJECT_ROOT}/.cache/go-build"

# Optional: Set GOMODCACHE to a specific location
# export GOMODCACHE="${PROJECT_ROOT}/.cache/go-mod"
