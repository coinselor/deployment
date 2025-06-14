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
    echo
    local description_md="A deployment script to automate the setup and management of **Zenon Network** infrastructure."
    gum format --type markdown "$description_md"

    gum style --border "rounded" --foreground "#A9A9A9" --border-foreground "#A9A9A9" --align "center" --width 61 --padding "0 1" --margin "1 0" "INTERACTIVE"

    gum style --foreground "#00FF00" "USAGE:"
    gum style --foreground "#00FF00" "sudo ./zenon.sh [COMMAND]"
    echo
    gum format --type markdown "**COMMAND** can be 'zenon' (default) or 'hyperqube'."
    echo

    gum style --foreground "#A9A9A9" "COMMANDS:"
    
    printf "%-12s %s\n" "zenon" "Show the interactive menu for Zenon Network." \
                         "hyperqube" "Show the interactive menu for HyperQube Network."

    gum style --border "rounded" --foreground "#A9A9A9" --border-foreground "#A9A9A9" --align "center" --width 61 --padding "0 1" --margin "2 0 1 0" "NON-INTERACTIVE"

    gum style --foreground "#00FF00" "USAGE:"
    gum style --foreground "#00FF00" "sudo ./zenon.sh [COMMAND] [ARGUMENTS]"
    echo
    local usage_details="**COMMAND** is a flag prefixed with '--' (e.g., --deploy)
**TYPE** can be 'zenon' (default) or 'hyperqube'
**REPOSITORY** is an **optional** HTTPS git URL
**BRANCH** is an **optional** and case-sensitive git branch name"
    
    gum format --type markdown "$usage_details"
    echo
    gum style --foreground "#A9A9A9" "COMMANDS:"

    printf "%-40s %s\n" "--deploy [type] [repository] [branch]" "Deploy a node." \
                               "--restore [type]" "Restore a node from the latest snapshot." \
                               "--restart [type]" "Restart the node service." \
                               "--stop [type]" "Stop the node service." \
                               "--start [type]" "Start the node service." \
                               "--monitor [type]" "Monitor node logs in real-time." \
                               "--resync [type]" "Resync the node from genesis." \
                               "--analytics" "Show the analytics dashboard." \
                               "--help" "Display this help message."

    gum style --foreground "240" --align "center" --width 61 --margin "1 0" --italic "The Future is Encrypted. Only You Can Decrypt It!"
    gum style --foreground "240" --align "center" --width 61 --margin "0 0" --italic "—Zenon Network"
}

export -f show_help