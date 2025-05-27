#!/usr/bin/env bash

[ -z "$PROJECT_ROOT" ] && echo "Error: config.sh not sourced." && exit 1
. "$SCRIPT_DIR/logging.sh"
. "$SCRIPT_DIR/build-zenon.sh"
. "$SCRIPT_DIR/restore.sh"
. "$SCRIPT_DIR/service.sh"
. "$SCRIPT_DIR/grafana.sh"

show_menu() {
    local choice

    gum style \
        --foreground 245 \
        --padding "1 1" \
        -- "$(cat <<'ASCII'
 _____  _____   _   _    ___    _   _             _
|__  / | ____| | \ | |  / _ \  | \ | |      ___  | |__
  / /  |  _|   |  \| | | | | | |  \| |     / __| | '_ \
 / /_  | |___  | |\  | | |_| | | |\  |  _  \__ \ | | | |
/____| |_____| |_| \_|  \___/  |_| \_| (_) |___/ |_| |_|
ASCII
)"

    gum style \
        --foreground 242 \
        --align center \
        --width 61 \
        "An independent script."

    echo

    options=(
        "deploy → Set up a Zenon Network node"
        "build → Build from a GitHub repository"
        "restore → Restore go-zenon from bootstrap"
        "restart → Restart the go-zenon service"
        "stop → Stop the go-zenon service"
        "start → Start the go-zenon service"
        "monitor → View znnd logs in real-time"
        "analytics → Set up Grafana analytics dashboard"
        "exit"
    )

    choice=$(printf "%s\n" "${options[@]}" | gum choose \
        --header="$(gum style --foreground 242 --padding "1 1" "CHOOSE AN ACTION:")" \
        --header.foreground="242" \
        --cursor.foreground="46" \
        --selected.foreground="46" \
        --height=15)

    choice=$(echo "$choice" | awk '{print $1}') # extract the command

    case "$choice" in
        "deploy")
            deploy_go_zenon
            ;;
        "build")
            BUILD_SOURCE=true
            clone_and_build_go_zenon
            ;;
        "restore")
            restore_go_zenon
            ;;
        "restart")
            restart_go_zenon
            ;;
        "stop")
            stop_go_zenon
            ;;
        "start")
            start_go_zenon
            ;;
        "monitor")
            monitor_logs
            ;;
        "analytics")
            install_grafana
            ;;
        "exit")
            exit 0
            ;;
    esac

    if [[ "$choice" != "exit" ]]; then
        echo
        gum confirm "Return to main menu?" && show_menu
    fi
}

show_help() {
    gum style \
        --foreground "green" --border double --align center --width 50 --margin "1 2" --padding "1 2" \
        "Zenon.sh - A Deployment Script for Zenon Network"

    gum style \
        --foreground "gray" --align center --width 70 --margin "1 2" \
        "A script to automate the setup, management, and restoration of Zenon Network infrastructure."

    echo
    gum style --foreground "dimgray" "USAGE:"
    gum style --indent 2 "zenon.sh [OPTIONS]"
    echo

    gum style --foreground "dimgray" "OPTIONS:"
    local opts=(
        "--deploy|Deploy and set up the Zenon Network"
        "--buildSource [URL]|Build from a specific source repository"
        "--restore|Restore go-zenon from bootstrap"
        "--restart|Restart the go-zenon service"
        "--stop|Stop the go-zenon service"
        "--start|Start the go-zenon service"
        "--status|Monitor znnd logs"
        "--grafana|Install Grafana"
        "--help|Display this help message"
    )

    for opt in "${opts[@]}"; do
        IFS="|" read -r flag description <<<"$opt"
        gum style --indent 2 "$(gum style --foreground "green" "$flag")"
        gum style --indent 4 --foreground "gray" "$description"
    done
}

deploy_go_zenon() {
    if [[ $(id -u) -ne 0 ]]; then
        error_log "This command requires root privileges"
        return 1
    fi

    local steps=(
        "Installing system dependencies"
        "Setting up Go environment"
        "Building go-zenon"
        "Configuring service"
        "Starting service"
    )

    for step in "${steps[@]}"; do
        gum spin --spinner dot --title "$step..." -- sleep 1
    done

    . "$SCRIPT_DIR/install-deps.sh"
    install_dependencies || {
        error_log "Failed to install dependencies"
        return 1
    }

    # Check gum again now that deps are installed
    silently_check_gum || {
        error_log "Failed to setup gum"
        return 1
    }

    . "$SCRIPT_DIR/install-go.sh"
    install_go || {
        error_log "Failed to install Go"
        return 1
    }

    clone_and_build_go_zenon || {
        error_log "Failed to build go-zenon"
        return 1
    }

    . "$SCRIPT_DIR/service.sh"
    create_service || {
        error_log "Failed to create service"
        return 1
    }

    start_go_zenon || {
        error_log "Failed to start service"
        return 1
    }

    success_log "go-zenon deployed successfully"
}
