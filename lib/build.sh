#!/usr/bin/env bash

install_dependencies() {
    echo "Installing dependencies..."

    if ! command -v make &> /dev/null; then
        echo "make could not be found"
        echo "Installing make..."
        apt install -y make
    fi

    if ! command -v gcc &> /dev/null; then
        echo "gcc could not be found"
        echo "Installing gcc..."
        apt install -y gcc
    fi

    if ! command -v jq &> /dev/null; then
        echo "jq could not be found"
        echo "Installing jq..."
        apt install -y jq
    fi
}

install_go() {

    local go_bin="$ZNNSH_DEPLOYMENT_DIR/go/bin/go"
    local desired_version="go$ZNNSH_GO_VERSION"

    if [[ -x "$go_bin" ]]; then
        local current_version
        current_version="$("$go_bin" version | awk '{print $3}')"
        if [[ "$current_version" == "$desired_version" ]]; then
            info_log "Go $ZNNSH_GO_VERSION already installed – skipping download."
            return 0
        else
            info_log "Found Go version $current_version, expected $desired_version – re-installing."
            rename_existing_dir "go"
        fi
    fi

    info_log "Downloading and installing Go..."
    curl -fsSLo "go.tar.gz" "$ZNNSH_GO_URL"
    tar -C "$ZNNSH_DEPLOYMENT_DIR" -xzf "go.tar.gz"
    rm "go.tar.gz"
    success_log "Go installed successfully."
}

get_branches() {
    local repo_url=$1
    local branches
    
    info_log "Fetching branches from $repo_url"
    
    branches=$(gum spin --spinner meter --spinner.foreground 46 --title "Fetching branches..." -- \
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
    
    gum style \
        --foreground 245 \
        --align center \
        --width 70 \
        --margin "1 0" \
        "Branch Selection"
    
    selected_branch=$(printf "%s\n" "${branches[@]}" | gum choose \
        --header="$(gum style --foreground 242 --padding "1 1" "SELECT A BRANCH:")" \
        --cursor.foreground="46" \
        --selected.foreground="46")
    
    if [ -n "$selected_branch" ]; then
        success_log "You selected branch: $selected_branch"
    else
        error_log "No branch selected, using default"
        selected_branch="master"
    fi
}

clone_and_build() {
    local repo_url=${1:-"$ZNNSH_REPO_URL"}
    local branch=${2:-"$ZNNSH_BRANCH_NAME"}
    local node_dir="${ZNNSH_DEFAULT_NODE_CONFIG[${ZNNSH_NODE_TYPE}_service]}"
    local build_title="BUILD: ${ZNNSH_NODE_TYPE^} Network from Source"
    
    stop_node_if_running

    if [ "$ZNNSH_INTERACTIVE_MODE" = true ]; then

        gum style \
            --border "rounded" \
            --border-foreground "#00FF00" \
            --foreground "#00FF00" \
            --margin "1 0" \
            -- "$build_title"
        
        if [[ "$ZNNSH_NODE_TYPE" == "zenon" ]]; then
            repo_options=(
                "zenon-network → https://github.com/zenon-network/go-zenon.git"
                "hypercore-one → https://github.com/hypercore-one/go-zenon.git"
                "custom → Provide a custom repository URL"
            )
        elif [[ "$ZNNSH_NODE_TYPE" == "hyperqube" ]]; then
            repo_options=(
                "hypercore-one → https://github.com/hypercore-one/hyperqube_z.git"
                "custom → Provide a custom repository URL"
            )
        fi
        repo_choice=$(printf "%s\n" "${repo_options[@]}" | gum choose \
            --header="$(gum style --foreground 242 --padding "1 1" "SELECT A REPOSITORY:")" \
            --cursor.foreground="46" \
            --selected.foreground="46")
    
        repo_type=$(echo "$repo_choice" | awk -F' →' '{print $1}')
        
        case "$repo_type" in
            "zenon-network")
                repo_url="${ZNNSH_DEFAULT_NODE_CONFIG[zenon_repo]}"
                info_log "Selected Zenon Network repository"
                ;;
            "hypercore-one")
                if [[ "$ZNNSH_NODE_TYPE" == "zenon" ]]; then
                    repo_url="https://github.com/hypercore-one/go-zenon.git"
                else
                    repo_url="${ZNNSH_DEFAULT_NODE_CONFIG[hyperqube_repo]}"
                fi
                info_log "Selected Hypercore One repository"
                ;;
            "custom")
                repo_url=$(gum input \
                    --width 70 \
                    --placeholder "Enter repository URL (e.g. https://github.com/user/repo.git)" \
                    --cursor.foreground="46")
                
                if [ -z "$repo_url" ]; then
                    repo_url="${ZNNSH_DEFAULT_NODE_CONFIG[${ZNNSH_NODE_TYPE}_repo]}"
                    info_log "No URL provided, using default: $repo_url"
                else
                    info_log "Using custom repository: $repo_url"
                fi
                ;;
            *)
                repo_url="${ZNNSH_DEFAULT_NODE_CONFIG[${ZNNSH_NODE_TYPE}_repo]}"
                info_log "Using default repository: $repo_url"
                ;;
        esac

        mapfile -t branches_array < <(get_branches "$repo_url")
        
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

    gum style \
        --foreground 242 \
        --align center \
        --width 70 \
        --margin "1 0" \
        "Build Process"
    
    rename_existing_dir "${node_dir}" || {
        error_log "Failed to prepare directories"
        return 1
    }

    info_log "Cloning branch '$branch' from repository..."
    gum spin --spinner meter --spinner.foreground 46 --title "Cloning branch '$branch' from repository..." -- \
        git clone -b "$branch" "$repo_url" "${node_dir}" || {
        error_log "Failed to clone repository"
        return 1
    }

    cd "${node_dir}" || {
        error_log "Failed to enter ${node_dir} directory"
        return 1
    }

    info_log "Building ${ZNNSH_BINARY_NAME}..."
    gum spin --spinner minidot --title "Building ${ZNNSH_BINARY_NAME}..." -- \
        env GO111MODULE=on ../go/bin/go build -o "build/${ZNNSH_BINARY_NAME}" "./cmd/${ZNNSH_BINARY_NAME}" || {
        error_log "Failed to build ${ZNNSH_BINARY_NAME}"
        return 1
    }

    info_log "Installing ${ZNNSH_BINARY_NAME} binary..."
    gum spin --spinner line --title "Installing ${ZNNSH_BINARY_NAME} binary..." -- \
        cp "build/${ZNNSH_BINARY_NAME}" "$ZNNSH_INSTALL_DIR/" || {
        error_log "Failed to install ${ZNNSH_BINARY_NAME} binary"
        return 1
    }

    success_log "Build completed successfully"
    echo '# Welcome Home :alien:' | gum format -t emoji | gum format -t markdown
    
    return 0
}

create_service() {
    echo "Checking if $ZNNSH_SERVICE_NAME.service is already set up..."

    if systemctl is-active --quiet "$ZNNSH_SERVICE_NAME"; then
        echo "$ZNNSH_SERVICE_NAME.service is already active. Skipping setup."
        return
    fi

    if [ -e "/etc/systemd/system/$ZNNSH_SERVICE_NAME.service" ]; then
        echo "$ZNNSH_SERVICE_NAME.service already exists, but it's not active. Setting it up..."
    else
        echo "Creating $ZNNSH_SERVICE_NAME.service..."
        cat << EOF > "/etc/systemd/system/$ZNNSH_SERVICE_NAME.service"
[Unit]
Description=$ZNNSH_BINARY_NAME service
After=network.target
[Service]
LimitNOFILE=32768
User=root
Group=root
Type=simple
SuccessExitStatus=SIGKILL 9
ExecStart=/usr/local/bin/$ZNNSH_BINARY_NAME
ExecStop=/usr/bin/pkill -9 $ZNNSH_BINARY_NAME
Restart=on-failure
TimeoutStopSec=10s
TimeoutStartSec=10s
[Install]
WantedBy=multi-user.target
EOF
    fi

    systemctl daemon-reload
    systemctl enable "$ZNNSH_SERVICE_NAME.service"
    echo "$ZNNSH_SERVICE_NAME.service is set up."
}


modify_hyperqube_config() {
    local config_file="/root/.hqzd/config.json"
    
    if [ ! -f "$config_file" ]; then
        echo "The config.json file does not exist. You should create it."
        return 1
    fi

    echo "Modifying HyperQube config.json..."

    jq '.Net.ListenPort = 45995' "$config_file" > "$config_file.tmp" && mv "$config_file.tmp" "$config_file"
    echo "Updated ListenPort to 45995 in config.json"
}


export -f install_dependencies
export -f install_go
export -f modify_hyperqube_config