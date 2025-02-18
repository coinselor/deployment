#!/bin/bash -e

clone_and_build_node() {
	stop_node_if_running

	if [ "$BUILD_SOURCE" = false ]; then
		repo_url=$ACTIVE_REPO
		branch=$ACTIVE_BRANCH
	else
		# If BUILD_SOURCE_URL is empty, prompt for repo URL
		if [ -z "$CUSTOM_REPO_URL" ]; then
			echo "Enter the GitHub repository URL (default: $ACTIVE_REPO):"
			read -r repo_url
			repo_url=${repo_url:-$ACTIVE_REPO}
		else
			repo_url=$CUSTOM_REPO_URL
		fi

		get_branches "$repo_url"
		branches_array=($branches)

		if [ ${#branches_array[@]} -eq 0 ]; then
			echo "No branches found. Exiting."
			exit 1
		fi

		select_branch "${branches_array[@]}"
		branch=$selected_branch
	fi

	local repo_dir="${ACTIVE_SERVICE}"
	echo "Checking for existing $repo_dir directory..."
	rename_existing_dir "$repo_dir"

	echo "Cloning branch '$branch' from repository '$repo_url'..."
	git clone -b "$branch" "$repo_url" "$repo_dir"
	echo "Clone completed."

	cd "$repo_dir" || exit

	if [[ "$BUILD_SOURCE" == "true" ]]; then
		# Build from source
		GO111MODULE=on ../go/bin/go build -o "build/$ACTIVE_BINARY" "./cmd/$ACTIVE_BINARY"
	else
		# Download prebuilt binary
		echo "Downloading prebuilt binary for $ZENON_ARCH"
		wget -q "https://github.com/zenon-network/go-zenon/releases/download/v${VERSION}/znnd-${ZENON_ARCH}.tar.gz"
		tar -xzf znnd-${ZENON_ARCH}.tar.gz -C /usr/local/bin/
		rm znnd-${ZENON_ARCH}.tar.gz
	fi

	cp "build/$ACTIVE_BINARY" /usr/local/bin/
}

create_service() {
	echo "Checking if $ACTIVE_SERVICE.service is already set up..."

	if systemctl is-active --quiet "$ACTIVE_SERVICE"; then
		echo "$ACTIVE_SERVICE.service is already active. Skipping setup."
		return
	fi

	if [ -e /etc/systemd/system/"$ACTIVE_SERVICE".service ]; then
		echo "$ACTIVE_SERVICE.service already exists, but it's not active. Setting it up..."
	else
		echo "Creating $ACTIVE_SERVICE.service..."
		cat <<EOF >/etc/systemd/system/"$ACTIVE_SERVICE".service
[Unit]
Description=$ACTIVE_BINARY service
After=network.target
[Service]
LimitNOFILE=32768
User=root
Group=root
Type=simple
SuccessExitStatus=SIGKILL 9
ExecStart=/usr/local/bin/$ACTIVE_BINARY
ExecStop=/usr/bin/pkill -9 $ACTIVE_BINARY
Restart=on-failure
TimeoutStopSec=10s
TimeoutStartSec=10s
[Install]
WantedBy=multi-user.target
EOF
	fi

	systemctl daemon-reload
	systemctl enable "$ACTIVE_SERVICE".service
	echo "$ACTIVE_SERVICE.service is set up."
}

modify_hyperqube_config() {
	local config_file="/root/.hqzd/config.json"

	if [ ! -f "$config_file" ]; then
		echo "The config.json file does not exist. You should create it."
		return 1
	fi

	echo "Modifying HyperQube config.json..."
	# Use jq to modify the ListenPort
	jq '.Net.ListenPort = 45995' "$config_file" >"$config_file.tmp" && mv "$config_file.tmp" "$config_file"
	echo "Updated ListenPort to 45995 in config.json"
}

deploy_node() {
	error_string=("Error: This command has to be run with superuser privileges (under the root user on most systems).")
	if [[ $(id -u) -ne 0 ]]; then
		echo "${error_string[@]}" >&2
		exit 1
	fi

	install_dependencies
	install_go
	clone_and_build_node
	create_service

	# If this is a HyperQube deployment, modify the config
	if [ "$ACTIVE_NODE_TYPE" = "hyperqube" ]; then
		modify_hyperqube_config
	fi

	start_node "$ACTIVE_NODE_TYPE"
}
