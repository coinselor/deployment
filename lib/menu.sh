#!/usr/bin/env bash

show_menu() {
    local current_node_type="${ZNNSH_NODE_TYPE:-zenon}"
    local choice

    local network_name="Zenon Network"
    local network_name_short="Zenon"
    local binary_name="znnd"
    local service_name="go-zenon"
    local menu_subtitle="Zenon Network"

    if [[ "$current_node_type" == "hyperqube" ]]; then
        network_name="HyperQube Network"
        network_name_short="HyperQube"
        binary_name="hqzd"
        service_name="go-hyperqube"
        menu_subtitle="HyperQube Network"
    fi

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
        "An Independent Script."

    gum style \
        --foreground 242 \
        --align center \
        --width 61 \
        "MODE: $menu_subtitle"

    echo

    options=(
        "deploy → Set up a $network_name node"
        "restart → Restart the $service_name service" 
        "stop → Stop the $service_name service"
        "start → Start the $service_name service"
        "monitor → View $binary_name logs in real-time"
        "backup → Backup $binary_name data"
        "restore → Restore $network_name_short from bootstrap"
        "analytics → Set up a Grafana dashboard"
        "exit"
    )

    choice=$(printf "%s\n" "${options[@]}" | gum choose \
        --header="$(gum style --foreground 242 --padding "1 1" "CHOOSE AN ACTION:")" \
        --header.foreground="242" \
        --cursor.foreground="46" \
        --selected.foreground="46" \
        --height=15)

    choice=$(echo "$choice" | awk '{print $1}')

    case "$choice" in
        "deploy")
            deploy
            ;;
        "restart")
            restart
            ;;
        "stop")
            stop
            ;;
        "start")
            start
            ;;
        "monitor")
            monitor
            ;;
        "backup")
            backup
            ;;
        "restore")
            restore
            ;;
        "analytics")
            analytics
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