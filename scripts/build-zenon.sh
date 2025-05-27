#!/usr/bin/env bash

[ -z "$PROJECT_ROOT" ] && echo "Error: config.sh not sourced." && exit 1
. "$SCRIPT_DIR/logging.sh"
. "$SCRIPT_DIR/utils.sh"

get_branches() {
    local repo_url=$1
    git ls-remote --heads "$repo_url" | awk '{print $2}' | sed 's|refs/heads/||'
}

select_branch() {
    local branches=("$@")
    echo "Available branches:"
    select branch in "${branches[@]}"; do
        if [ -n "$branch" ]; then
            success_log "You selected branch: $branch"
            selected_branch="$branch"
            break
        else
            error_log "Invalid selection. Please try again."
        fi
    done
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

    stop_znnd_if_running

    if [ "$BUILD_SOURCE" = true ]; then
      if gum confirm "Would you like to use a custom repository?" --default=false; then
            repo_url=$(gum input --placeholder "Enter repository URL (e.g. https://github.com/user/repo.git)")
            if [ -z "$repo_url" ]; then
                repo_url="$ZENON_REPO_URL"
                info_log "Using default repository: $repo_url"
            else
                info_log "Using custom repository: $repo_url"
            fi
        else
            info_log "Using default repository: $repo_url"
        fi

        info_log "Fetching branches from repository..."
        branches_array=($(get_branches "$repo_url"))
        
        if [ ${#branches_array[@]} -eq 0 ]; then
            error_log "No branches found in repository"
            return 1
        fi

        select_branch "${branches_array[@]}"
        branch=$selected_branch
    fi

    gum spin --spinner dot --title "Checking for existing go-zenon directory..." -- \
        rename_existing_dir "go-zenon"

    gum spin --spinner dot --title "Cloning branch '$branch' from repository..." -- \
        git clone -b "$branch" "$repo_url" go-zenon || {
        error_log "Failed to clone repository"
        return 1
    }

    cd go-zenon || {
        error_log "Failed to enter go-zenon directory"
        return 1
    }

    gum spin --spinner dot --title "Building go-zenon..." -- \
        env GO111MODULE=on ../go/bin/go build -o build/znnd ./cmd/znnd || {
        error_log "Failed to build go-zenon"
        return 1
    }

    gum spin --spinner dot --title "Installing znnd binary..." -- \
        $SUDO cp build/znnd "$INSTALL_DIR/" || {
        error_log "Failed to install znnd binary"
        return 1
    }

    success_log "go-zenon successfully built and installed"
}
