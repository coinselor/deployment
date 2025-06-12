#!/usr/bin/env bash

deploy() {
    local debug=""
    if [[ "$ZNNSH_DEBUG" = true ]]; then
        debug="--show-output"
    fi

    gum spin --spinner meter --title "Installing system dependencies..." $debug -- bash -c "install_dependencies" || {
        error_log "Failed to install system dependencies"
        return 1
    }

    gum spin --spinner meter --title "Installing Go..." $debug -- bash -c "install_go" || {
        error_log "Failed to install Go"
        return 1
    }

    gum spin --spinner meter --title "Building binary..." $debug -- bash -c "clone_and_build" || {
        error_log "Failed to build binary"
        return 1
    }

    gum spin --spinner meter --title "Configuring service..." $debug -- bash -c "create_service" || {
        error_log "Failed to configure service"
        return 1
    }

    if [ "$ZNNSH_NODE_TYPE" = "hyperqube" ]; then
        gum spin --spinner meter --title "Modifying HyperQube config..." $debug -- bash -c "modify_hyperqube_config" || {
            error_log "Failed to modify HyperQube config"
            return 1
        }
    fi

    gum spin --spinner meter --title "Starting $ZNNSH_SERVICE_NAME service..." $debug -- bash -c "start_service" || {
        error_log "Failed to start $ZNNSH_SERVICE_NAME service"
        return 1
    }

    success_log "$ZNNSH_SERVICE_NAME service started successfully"
}