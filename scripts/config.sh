#!/usr/bin/env bash

# =============================================================================
# Zenon Node Configuration
#
# This configuration file contains all settings for the Zenon node deployment.
# Environment variables set before sourcing this file will override these defaults.
# =============================================================================

# -----------------------------------------------------------------------------
# Terminal Settings
# These settings ensure proper color support in terminal environments
# -----------------------------------------------------------------------------
if [ -t 1 ]; then
	# Use 256 color support for better visual feedback
	export TERM="${TERM:-xterm-256color}"
	export COLORTERM="${COLORTERM:-truecolor}"
fi

# -----------------------------------------------------------------------------
# Go Installation Settings
# -----------------------------------------------------------------------------
# Go version to install (format: X.Y.Z)
GO_VERSION="${GO_VERSION:-1.23.0}"

# Base URL for downloading Go binaries
GO_DOWNLOAD_BASE_URL="https://go.dev/dl"

# SHA256 checksums for verifying Go downloads
# Update this when changing GO_VERSION
# Format: filename=sha256sum
declare -A GO_CHECKSUMS=(
	["go1.23.0.linux-amd64.tar.gz"]="xxx"
	# ["go1.23.0.linux-arm64.tar.gz"]="checksum_for_linux_arm64"
	# add more checksums as more platforms are supported
)

# -----------------------------------------------------------------------------
# Zenon Repository Settings
# -----------------------------------------------------------------------------
# Main repository URL for go-zenon
ZENON_REPO_URL="${ZENON_REPO_URL:-https://github.com/zenon-network/go-zenon.git}"

# Default branch to build from (master, develop, etc.)
ZENON_BRANCH="${ZENON_BRANCH:-master}"

# Whether to build from source instead of using pre-built binaries
BUILD_SOURCE="${BUILD_SOURCE:-false}"

# Optional: Override repository URL for custom forks
BUILD_SOURCE_URL="${BUILD_SOURCE_URL:-}"

# -----------------------------------------------------------------------------
# Directory Structure
# -----------------------------------------------------------------------------
# Base directory containing all scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Root directory of the project
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Where binaries will be installed
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Directory for znnd blockchain data
DATA_DIR="${DATA_DIR:-/var/lib/zenon}"

# Directory for log files
LOG_DIR="${LOG_DIR:-/var/log/zenon}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/go-zenon.log}"

# -----------------------------------------------------------------------------
# Service Configuration (systemd)
# -----------------------------------------------------------------------------
# Name of the systemd service
SERVICE_NAME="${SERVICE_NAME:-go-zenon}"

# User/Group for running the service
# For production, consider creating a dedicated system user:
# sudo useradd -r -s /bin/false zenon
SERVICE_USER="${SERVICE_USER:-zenon}"
SERVICE_GROUP="${SERVICE_GROUP:-zenon}"

# Service file location
SYSTEMD_SERVICE_DIR="/etc/systemd/system"

# -----------------------------------------------------------------------------
# System Settings
# -----------------------------------------------------------------------------
# Use sudo for operations requiring elevated privileges
SUDO="${SUDO:-sudo}"

# Avoid interactive prompts during package installation
DEBIAN_FRONTEND=noninteractive

# -----------------------------------------------------------------------------
# Architecture Detection (Ubuntu/Linux only)
# -----------------------------------------------------------------------------
UNAME_ARCH="$(uname -m)"
case "$UNAME_ARCH" in
x86_64)
	GO_ARCH="linux-amd64"
	;;
aarch64 | arm64)
	GO_ARCH="linux-arm64"
	;;
*)
	echo "Error: Architecture $UNAME_ARCH is not supported." >&2
	exit 1
	;;
esac

# Construct the Go download URL
GO_URL="${GO_DOWNLOAD_BASE_URL}/go${GO_VERSION}.${GO_ARCH}.tar.gz"

# -----------------------------------------------------------------------------
# Required System Packages
# -----------------------------------------------------------------------------
# Space-separated list of required packages
REQUIRED_PACKAGES="build-essential git curl wget"

# -----------------------------------------------------------------------------
# Export Variables
# -----------------------------------------------------------------------------
# Export all variables for use in other scripts
export GO_VERSION GO_URL GO_ARCH ZENON_REPO_URL ZENON_BRANCH BUILD_SOURCE BUILD_SOURCE_URL \
	INSTALL_DIR DATA_DIR LOG_DIR LOG_FILE SERVICE_NAME SERVICE_USER SERVICE_GROUP SUDO \
	UNAME_ARCH DEBIAN_FRONTEND SCRIPT_DIR PROJECT_ROOT TERM COLORTERM REQUIRED_PACKAGES \
	SYSTEMD_SERVICE_DIR

# Note: GOROOT, GOPATH, and PATH modifications have been moved to environment.sh
# Source it separately after this file if needed
