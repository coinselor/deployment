#!/usr/bin/env bash

show_help() {
    
    gum style \
        --foreground "245" --padding "1 1" \
        -- "$(cat <<'ASCII'
 _____  _____   _   _    ___    _   _             _
|__  / | ____| | \ | |  / _ \  | \ | |      ___  | |__
  / /  |  _|   |  \| | | | | | |  \| |     / __| | '_ \
 / /_  | |___  | |\  | | |_| | | |\  |  _  \__ \ | | | |
/____| |_____| |_| \_|  \___/  |_| \_| (_) |___/ |_| |_|
ASCII
)"

    gum style --foreground "242" --align "center" --width 61 "An independent script."

    local desc_p1
    desc_p1=$(gum style --foreground "#808080" "A deployment script to automate the setup and management of ")
    local desc_p2
    desc_p2=$(gum style --foreground "green" --bold "Zenon Network")
    local desc_p3
    desc_p3=$(gum style --foreground "#808080" " infrastructure.")
    
    local final_desc
    final_desc=$(gum join --align "left" "$desc_p1" "$desc_p2" "$desc_p3")

    gum style --align "center" --width 70 --margin "1 0 1 0" -- "$final_desc"

    local usage_title
    usage_title=$(gum style --foreground "#A9A9A9" "USAGE:")
    local usage_command
    usage_command=$(gum style --margin "0 0 0 4" "sudo ./zenon.sh [COMMAND] [ARGUMENTS]")
    gum join --align "left" --vertical "$usage_title" "$usage_command"

    gum style --foreground "#A9A9A9" --margin "1 0 0 0" "COMMANDS:"

    local commands=(
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

    for cmd_with_desc in "${commands[@]}"; do
        IFS="|" read -r cmd description <<<"$cmd_with_desc"
        
        local styled_cmd
        styled_cmd=$(gum style --foreground "#00FF00" --width 35 -- "$cmd")
        
        local styled_desc
        styled_desc=$(gum style --foreground "#808080" -- "$description")

        gum join --align "left" "$styled_cmd" "$styled_desc"
    done
}

export -f show_help