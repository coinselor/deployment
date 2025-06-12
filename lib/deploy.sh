#!/usr/bin/env bash

deploy() {
    local debug=""
    if [[ "$ZNNSH_DEBUG" = true ]]; then
        debug="--show-output"
    fi

    gum spin --spinner meter --title "Installing system dependencies..." $debug -- install_dependencies || {
        error_log "Failed to install system dependencies"
        return 1
    }

    gum spin --spinner meter --title "Installing Go..." $debug -- install_go || {
        error_log "Failed to install Go"
        return 1
    }

    gum spin --spinner meter --title "Building binary..." $debug -- clone_and_build || {
        error_log "Failed to build binary"
        return 1
    }

    gum spin --spinner meter --title "Configuring service..." $debug -- create_service || {
        error_log "Failed to configure service"
        return 1
    }

    if [ "$ZNNSH_NODE_TYPE" = "hyperqube" ]; then
        gum spin --spinner meter --title "Modifying HyperQube config..." $debug -- modify_hyperqube_config || {
            error_log "Failed to modify HyperQube config"
            return 1
        }
    fi

    gum spin --spinner meter --title "Starting $ZNNSH_SERVICE_NAME service..." $debug -- start_service || {
        error_log "Failed to start $ZNNSH_SERVICE_NAME service"
        return 1
    }

    success_log "$ZNNSH_SERVICE_NAME service started successfully"
}