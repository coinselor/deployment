#!/usr/bin/env bash

# =============================================================================
# install-deps.sh
# Installs the required system dependencies in three phases:
# 1. Minimal dependencies (without using gum)
# 2. Go installation (so we can install gum)
# 3. Gum installation and then main dependencies (with gum available)
#
# This script relies on:
# - config.sh for configuration
# - logging.sh for logging functions
# - install-go.sh for Go installation logic
# =============================================================================

[ -z "$PROJECT_ROOT" ] && echo "Error: config.sh not sourced." >&2 && exit 1
. "$SCRIPT_DIR/logging.sh"

install_minimal_deps() {
	echo "Updating system packages..."
	$SUDO apt-get update -y
	echo "Upgrading system packages..."
	$SUDO apt-get upgrade -y

	# Minimal packages required before installing Go and gum
	local minimal_packages="curl tar"
	for pkg in $minimal_packages; do
		if ! command -v $pkg &>/dev/null; then
			echo "Installing $pkg..."
			$SUDO apt-get install -y $pkg || {
				echo "Error: Failed to install $pkg" >&2
				return 1
			}
		fi
	done
	return 0
}

install_gum() {
	# Check if gum is already installed
	if command -v gum &>/dev/null; then
		success_log "gum is already installed"
		return 0
	fi

	# At this point, Go should be installed
	if ! command -v go &>/dev/null; then
		error_log "Go is not installed. Cannot install gum."
		return 1
	fi

	gum spin --spinner dot --title "Installing gum..." -- \
		go install github.com/charmbracelet/gum@latest || {
		error_log "Failed to install gum"
		return 1
	}

	# Add Go bin to PATH if not already there
	export PATH=$PATH:$(go env GOPATH)/bin

	# Verify gum works
	if ! gum --version &>/dev/null; then
		error_log "Gum installation verification failed"
		return 1
	fi

	success_log "gum installed successfully"
	return 0
}

install_main_dependencies() {
	gum spin --spinner dot --title "Installing remaining system dependencies..." -- sleep 1

	for pkg in $REQUIRED_PACKAGES; do
		# Skip packages already handled in minimal_deps (curl, tar)
		if [[ $pkg == "curl" || $pkg == "tar" ]]; then
			continue
		fi

		if ! command -v $pkg &>/dev/null; then
			gum spin --spinner dot --title "Installing $pkg..." -- $SUDO apt-get install -y $pkg || {
				error_log "Failed to install $pkg"
				return 1
			}
		fi
	done
	return 0
}

# Main logic for install-deps.sh
main() {
	install_minimal_deps || exit 1

	# Now that minimal deps are installed, we can install Go
	. "$SCRIPT_DIR/install-go.sh"
	install_go || exit 1

	# With Go installed, we can install gum
	install_gum || exit 1

	# Now we have gum, we can install remaining dependencies
	install_main_dependencies || exit 1

	success_log "All dependencies installed successfully"
}

main "$@"
