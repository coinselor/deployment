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
    gum style --foreground "242" --align "center" --width 61 "An Independent Script."
    
    local styled_zenon
    styled_zenon=$(gum style --foreground "#00FF00" --bold "Zenon Network")
    echo "A deployment script to automate the setup and management of ${styled_zenon} infrastructure." | gum style --foreground "#808080" --align "center" --width 70 --margin "1 0"

    gum style --border "rounded" --border-foreground "#00FF00" --align "center" --padding "0 1" --margin "1 0" "INTERACTIVE"

    local i_usage
    i_usage=$(
        printf "%s\n" \
            "USAGE:" \
            "         sudo ./zenon.sh [COMMAND]" \
            "         Command can be 'zenon' (default) or 'hyperqube'."
    )
    echo "$i_usage" | gum style --margin "0 0 1 0"

    gum style --foreground "#A9A9A9" "INTERACTIVE COMMANDS:"
    local interactive_commands=(
        "zenon|Show the interactive menu for Zenon Network."
        "hyperqube|Show the interactive menu for HyperQube Network."
    )
    for cmd_with_desc in "${interactive_commands[@]}"; do
        IFS="|" read -r cmd description <<<"$cmd_with_desc"
        local styled_cmd
        styled_cmd=$(printf "%s" "$cmd" | gum style --foreground "#00FF00" --width 35)
        local styled_desc
        styled_desc=$(printf "%s" "$description" | gum style --foreground "#808080")
        gum join --align "left" "$styled_cmd" "$styled_desc"
    done

    gum style --border "rounded" --border-foreground "#00FF00" --align "center" --padding "0 1" --margin "2 0 1 0" "NON-INTERACTIVE"

    local n_usage
    n_usage=$(
        printf "%s\n" \
            "USAGE:" \
            "         sudo ./zenon.sh [COMMAND] [ARGUMENTS]" \
            "         COMMAND is a flag prefixed with '--' (e.g., --deploy)." \
            "         TYPE can be 'zenon' (default) or 'hyperqube'." \
            "         REPOSITORY is an optional HTTPS git URL." \
            "         BRANCH is a case-sensitive git branch name."
    )
    echo "$n_usage" | gum style --margin "0 0 1 0"

    gum style --foreground "#A9A9A9" "NON-INTERACTIVE COMMANDS:"
    local non_interactive_commands=(
        "--deploy [type] [repository] [branch]|Deploy a node."
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
        styled_cmd=$(printf "%s" "$cmd" | gum style --foreground "#00FF00" --width 35)
        local styled_desc
        styled_desc=$(printf "%s" "$description" | gum style --foreground "#808080")
        printf "%s\n%s" "$styled_cmd" "$styled_desc" | gum join --align "left"
    done
}

export -f show_help