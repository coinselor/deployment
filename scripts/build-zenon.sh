#!/usr/bin/env bash

[ -z "$PROJECT_ROOT" ] && echo "Error: config.sh not sourced." && exit 1
. "$SCRIPT_DIR/logging.sh"
. "$SCRIPT_DIR/utils.sh"

get_branches() {
    local repo_url=$1
    local branches
    
    info_log "Fetching branches from $repo_url"
    
    # Use gum spin to show progress while fetching branches
    branches=$(gum spin --spinner dot --title "Fetching branches..." -- \
        bash -c "git ls-remote --heads '$repo_url' | awk '{print \$2}' | sed 's|refs/heads/||'")
    
    if [ -z "$branches" ]; then
        error_log "No branches found or unable to connect to repository"
        return 1
    fi
    
    echo "$branches"
    return 0
}

select_branch() {
    local branches=("$@")
    
    gum style --foreground 212 --border normal --border-foreground 212 --align center --width 50 --margin "1 2" --padding "0 1" \
        "Select a Branch"
    
    selected_branch=$(printf "%s\n" "${branches[@]}" | gum choose \
        --header="$(gum style --foreground 242 --padding "0 1" "Available branches from repository:")" \
        --header.foreground="242" \
        --cursor.foreground="46" \
        --selected.foreground="46" \
        --height=15)
    
    if [ -n "$selected_branch" ]; then
        success_log "You selected branch: $selected_branch"
    else
        error_log "No branch selected, using default"
        selected_branch="master" # Fallback to a default branch
    fi
}

stop_znnd_if_running() {
    SERVICE_SYSTEM=$(detect_service_system)
    if [ "$SERVICE_SYSTEM" = "systemd" ]; then
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            success_log "Stopping $SERVICE_NAME service..."
            systemctl stop "$SERVICE_NAME"
            success_log "$SERVICE_NAME service stopped."
        else
            warn_log "$SERVICE_NAME service is not running."
        fi
    else
        if [ -f "/tmp/$SERVICE_NAME.pid" ]; then
            PID=$(cat /tmp/$SERVICE_NAME.pid)
            if kill -0 "$PID" 2>/dev/null; then
                success_log "Stopping $SERVICE_NAME process..."
                kill "$PID"
                rm -f /tmp/$SERVICE_NAME.pid
                success_log "$SERVICE_NAME process stopped."
            else
                warn_log "$SERVICE_NAME process is not running."
                rm -f /tmp/$SERVICE_NAME.pid
            fi
        else
            warn_log "$SERVICE_NAME process is not running."
        fi
    fi
}

clone_and_build_go_zenon() {
    local repo_url=${1:-"$ZENON_REPO_URL"}
    local branch=${2:-"$ZENON_BRANCH"}

    gum style \
        --foreground 45 --align center --width 70 --margin "1 2" --padding "1 2" \
        "Building Zenon Node from Source"
    
    stop_znnd_if_running

    if [ "$BUILD_SOURCE" = true ]; then
        gum style --foreground 212 --align left --width 70 --margin "1 0" "Select Repository Source"
        
        if gum confirm "Would you like to use a custom repository?" --default=false; then
            repo_url=$(gum input --width 70 --placeholder "Enter repository URL (e.g. https://github.com/user/repo.git)")
            if [ -z "$repo_url" ]; then
                repo_url="$ZENON_REPO_URL"
                info_log "Using default repository: $repo_url"
            else
                info_log "Using custom repository: $repo_url"
            fi
        else
            info_log "Using default repository: $repo_url"
        fi

        branches_array=($(get_branches "$repo_url"))
        
        if [ ${#branches_array[@]} -eq 0 ]; then
            error_log "No branches found in repository"
            return 1
        fi

        select_branch "${branches_array[@]}"
        branch=$selected_branch
    else
        info_log "Using repository: $repo_url"
        info_log "Using branch: $branch"
    fi

    gum style --foreground 212 --align left --width 70 --margin "1 0" "Build Process"
    
    gum spin --spinner dot --title "Checking for existing go-zenon directory..." -- \
        rename_existing_dir "go-zenon" || {
        error_log "Failed to prepare directories"
        return 1
    }

    info_log "Cloning branch '$branch' from repository..."
    gum spin --spinner monkey --title "Cloning branch '$branch' from repository..." -- \
        git clone -b "$branch" "$repo_url" go-zenon || {
        error_log "Failed to clone repository"
        return 1
    }

    cd go-zenon || {
        error_log "Failed to enter go-zenon directory"
        return 1
    }

    info_log "Building go-zenon..."
    gum spin --spinner minidot --title "Building go-zenon..." -- \
        env GO111MODULE=on ../go/bin/go build -o build/znnd ./cmd/znnd || {
        error_log "Failed to build go-zenon"
        return 1
    }

    info_log "Installing znnd binary..."
    gum spin --spinner line --title "Installing znnd binary..." -- \
        $SUDO cp build/znnd "$INSTALL_DIR/" || {
        error_log "Failed to install znnd binary"
        return 1
    }

    success_log "Build completed successfully"
    echo '# Welcome Home :alien:' | gum format -t emoji | gum format -t markdown
    
    return 0
}
