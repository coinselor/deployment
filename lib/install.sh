#!/bin/bash -e

install_dependencies() {
	echo "Installing dependencies..."

	# Check if make is installed
	if ! command -v make &>/dev/null; then
		echo "make could not be found"
		echo "Installing make..."
		apt-get install -y make
	fi

	# Check if gcc is installed
	if ! command -v gcc &>/dev/null; then
		echo "gcc could not be found"
		echo "Installing gcc..."
		apt-get install -y gcc
	fi

	# Check if jq is installed
	if ! command -v jq &>/dev/null; then
		echo "jq could not be found"
		echo "Installing jq..."
		apt-get install -y jq
	fi
}

install_go() {
	echo "Checking for existing Go installation..."

	# Check and rename existing go directory
	rename_existing_dir "go"

	echo "Downloading and installing Go..."
	curl -fsSLo "go.tar.gz" "$GO_URL"
	tar -C . -xzf "go.tar.gz"
	rm "go.tar.gz"
	echo "Go installed successfully."
}

install_grafana() {
	echo "Installing Grafana..."
	install_grafana_components
	echo "Grafana installed successfully."
}
