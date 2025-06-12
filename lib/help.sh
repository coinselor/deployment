#!/usr/bin/env bash

show_help() {
    
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

    gum style \
        --foreground "gray" --align center --width 70 --margin "1 0" \
        "A script to automate the setup, management, and restoration of Zenon Network infrastructure."
    
    echo
    gum style --foreground "dimgray" "USAGE:"
    gum style --indent 2 "zenon.sh [COMMAND] [ARGUMENTS]"
    echo
    
    gum style --foreground "dimgray" "COMMANDS:"
    
    local opts=(
        "(no arguments)|Show the interactive menu for Zenon."
        "hyperqube|Show the interactive menu for HyperQube."
        "--deploy [type] [repo] [branch]|Deploy a node. 'type' can be 'zenon' (default) or 'hyperqube'. 'repo' and 'branch' are optional."
        "--restore [type]|Restore a node. 'type' can be 'zenon' (default) or 'hyperqube'."
        "--restart [type]|Restart the node service. 'type' can be 'zenon' (default) or 'hyperqube'."
        "--stop [type]|Stop the node service. 'type' can be 'zenon' (default) or 'hyperqube'."
        "--start [type]|Start the node service. 'type' can be 'zenon' (default) or 'hyperqube'."
        "--monitor [type]|Monitor node logs. 'type' can be 'zenon' (default) or 'hyperqube'."
        "--analytics|Show analytics dashboard."
        "--help|Display this help message."
    )
    
    for opt in "${opts[@]}"; do
        IFS="|" read -r flag description <<<"$opt"
        gum style --indent 2 "$(gum style --foreground "green" "$flag")"
        gum style --indent 4 --foreground "gray" "$description"
    done
}

export -f show_help