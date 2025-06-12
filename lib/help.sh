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
    
    local description_md="A deployment script to automate the setup and management of **Zenon Network** infrastructure."
    gum format --type markdown "$description_md" | gum style --foreground "#808080" --align "center" --width 70 --margin "1 0"

    gum style --border "rounded" --border-foreground "#00FF00" --align "center" --width 61 --padding "0 1" --margin "1 0" "INTERACTIVE"

    gum format --type markdown "**USAGE:**" | gum style --foreground "#00FF00" --margin "0 0 0 0"
    gum format --type markdown "\`sudo ./zenon.sh [COMMAND]\`" | gum style --foreground "#00FF00" --margin "0 0 0 8"
    echo
    gum style --foreground "#A9A9A9" --margin "0 0 1 10" "COMMAND can be 'zenon' (default) or 'hyperqube'."

    gum style --foreground "#A9A9A9" "INTERACTIVE COMMANDS:"
    
    printf "%s\n" \
        $'Command\tDescription' \
        $'zenon\tShow the interactive menu for Zenon Network.' \
        $'hyperqube\tShow the interactive menu for HyperQube Network.' | \
        gum table | gum style --margin "0 0 1 0"

    gum style --border "rounded" --border-foreground "#00FF00" --align "center" --width 61 --padding "0 1" --margin "2 0 1 0" "NON-INTERACTIVE"

    gum format --type markdown "**USAGE:**" | gum style --foreground "#00FF00" --margin "0 0 0 0"
    gum format --type markdown "\`sudo ./zenon.sh [COMMAND] [ARGUMENTS]\`" | gum style --foreground "#00FF00" --margin "0 0 0 8"
    
    local usage_details="**COMMAND** is a flag prefixed with '--' (e.g., --deploy)
**TYPE** can be 'zenon' (default) or 'hyperqube'
**REPOSITORY** is an **optional** HTTPS git URL
**BRANCH** is an **optional** and case-sensitive git branch name"
    
    gum format --type markdown "$usage_details" | gum style --foreground "#A9A9A9" --margin "0 0 1 9"


    gum style --foreground "#A9A9A9" "NON-INTERACTIVE COMMANDS:"

    printf "%s\n" \
        $'Command\tDescription' \
        $'--deploy [type] [repository] [branch]\tDeploy a node.' \
        $'--restore [type]\tRestore a node from the latest snapshot.' \
        $'--restart [type]\tRestart the node service.' \
        $'--stop [type]\tStop the node service.' \
        $'--start [type]\tStart the node service.' \
        $'--monitor [type]\tMonitor node logs in real-time.' \
        $'--analytics\tShow the analytics dashboard.' \
        $'--help\tDisplay this help message.' | \
        gum table | gum style --margin "0 0 1 0"

    gum style --foreground "240" --align "center" --width 61 --margin "1 0" --italic "The Future is Encrypted. Only You Can Decrypt It!"
    gum style --foreground "240" --align "center" --width 61 --margin "0 0" --italic "—Zenon Network"
}

export -f show_help