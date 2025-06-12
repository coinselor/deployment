#!/usr/bin/env bash

show_help() {
    gum style --foreground "245" --padding "1 1" -- "$(cat <<'ASCII'
 _____  _____   _   _    ___    _   _             _
|__  / | ____| | \ | |  / _ \  | \ | |      ___  | |__
  / /  |  _|   |  \| | | | | | |  \| |     / __| | '_ \
 / /_  | |___  | |\  | | |_| | | |\  |  _  \__ \ | | | |
/____| |_____| |_| \_|  \___/  |_| \_| (_) |___/ |_| |_|
ASCII
)"

    gum style \
        --foreground "242" \
        --align "center" \
        --width 61 \
        "An Independent Script."

    local zenon_network_styled
    zenon_network_styled=$(gum style --foreground "green" --bold "Zenon Network")
    gum style \
        --foreground "#808080" --align "center" --width 70 --margin "1 0 1 0" \
        "A deployment script to automate the setup and management of ${zenon_network_styled} infrastructure."

    gum style --border "rounded" --align "center" --padding "0 1" --margin "1 0" \
        -- "INTERACTIVE"

    local i_usage_title
    i_usage_title=$(gum style --foreground "#A9A9A9" "USAGE:")
    local i_usage_line1
    i_usage_line1=$(gum style --margin "0 0 0 9" "sudo ./zenon.sh [COMMAND]")
    local i_usage_line2
    i_usage_line2=$(gum style --foreground "#808080" --margin "0 0 0 9" "Command can be 'zenon' (default) or 'hyperqube'.")
    gum join --align left --vertical "$i_usage_title" "$i_usage_line1" "$i_usage_line2"
    
    gum style --foreground "#A9A9A9" --margin "1 0 0 0" "INTERACTIVE COMMANDS:"
    
    local interactive_commands=(
        "zenon|Show the interactive menu for Zenon Network."
        "hyperqube|Show the interactive menu for HyperQube Network."
    )

    for cmd_with_desc in "${interactive_commands[@]}"; do
        IFS="|" read -r cmd description <<<"$cmd_with_desc"
        local styled_cmd
        styled_cmd=$(gum style --foreground "green" --width 35 -- "$cmd")
        local styled_desc
        styled_desc=$(gum style --foreground "#808080" -- "$description")
        gum join --align "left" "$styled_cmd" "$styled_desc"
    done

    gum style --border "rounded" --border-foreground "green" --align "center" --padding "0 1" --margin "2 0 1 0" \
        -- "NON-INTERACTIVE"
    
    local n_usage_title
    n_usage_title=$(gum style --foreground "#A9A9A9" "USAGE:")
    local n_usage_line1
    n_usage_line1=$(gum style --margin "0 0 0 9" "sudo ./zenon.sh [COMMAND] [ARGUMENTS]")
    local n_usage_desc1
    n_usage_desc1=$(gum style --foreground "#808080" --margin "0 0 0 9" "COMMAND is a flag prefixed with '--' (e.g., --deploy).")
    local n_usage_desc2
    n_usage_desc2=$(gum style --foreground "#808080" --margin "0 0 0 9" "TYPE can be 'zenon' (default) or 'hyperqube'.")
    local n_usage_desc3
    n_usage_desc3=$(gum style --foreground "#808080" --margin "0 0 0 9" "REPOSITORY is an optional HTTPS/SSH git URL.")
    local n_usage_desc4
    n_usage_desc4=$(gum style --foreground "#808080" --margin "0 0 0 9" "BRANCH is a case-sensitive git branch name.")
    gum join --align left --vertical "$n_usage_title" "$n_usage_line1" "$n_usage_desc1" "$n_usage_desc2" "$n_usage_desc3" "$n_usage_desc4"
    
    gum style --foreground "#A9A9A9" --margin "1 0 0 0" "NON-INTERACTIVE COMMANDS:"

    local non_interactive_commands=(
        "--deploy [type] [repo] [branch]|Deploy a node."
        "--restore [type]|Restore a node from the latest snapshot."
        "--restart [type]|Restart the node service."
        "--stop [type]|Stop the node service."
        "--start [type]|Start the node service."
        "--monitor [type]|Monitor node logs in real-time."
        "--analytics|Show the analytics dashboard."
        "--help|Display this help message."
    )

    for cmd_with_desc in "${non_interactive_commands[@]}"; do
        IFS="|" read -r cmd description <<<"$cmd_with_desc"
        local styled_cmd
        styled_cmd=$(gum style --foreground "green" --width 35 -- "$cmd")
        local styled_desc
        styled_desc=$(gum style --foreground "#808080" -- "$description")
        gum join --align "left" "$styled_cmd" "$styled_desc"
    done
}

export -f show_help