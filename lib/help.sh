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
        "A deployment script to automate the setup and management of Zenon Network infrastructure."
    
    echo
    gum style --foreground "dimgray" "USAGE:"
    gum style --margin "4 0" "sudo ./zenon.sh [COMMAND] [ARGUMENTS]"
    echo
    
    gum style --foreground "dimgray" "COMMANDS:"
    
    local opts=(
        "(no commands/arguments)|Show the interactive menu for Zenon Network."
        "hyperqube|Show the interactive menu for HyperQube Network."
        "--deploy [type] [repository] [branch]|Deploy a node. 'type' can be 'zenon' (default) or 'hyperqube'. 'repository' and 'branch' are optional."
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
        gum style --margin "2 0" "$(gum style --foreground "green" "$flag")"
        gum style --margin "4 0" --foreground "gray" "$description"
    done
}

export -f show_help