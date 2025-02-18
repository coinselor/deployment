#!/bin/bash -e

# Global variables
BUILD_SOURCE=false
BUILD_SOURCE_URL=""

# Go configuration
ARCH=$(uname -m)
case "$ARCH" in
x86_64 | amd64)
	GO_ARCH="amd64"
	ZENON_ARCH="linux-amd64"
	;;
aarch64 | arm64)
	GO_ARCH="arm64"
	ZENON_ARCH="linux-arm64"
	;;
esac
GO_VERSION=1.23.0
GO_URL="https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"

if [[ "$GO_URL" == "" ]]; then
	echo "Error: $ARCH architecture is not supported."
	exit 1
fi

# Node configuration defaults
DEFAULT_ZENON_REPO="https://github.com/zenon-network/go-zenon.git"
DEFAULT_ZENON_BRANCH="master"
DEFAULT_ZENON_BINARY="znnd"
DEFAULT_ZENON_SERVICE="go-zenon"

DEFAULT_HYPERQUBE_REPO="https://github.com/hypercore-one/hyperqube_z.git"
DEFAULT_HYPERQUBE_BRANCH="hyperqube_z"
DEFAULT_HYPERQUBE_BINARY="hqzd"
DEFAULT_HYPERQUBE_SERVICE="go-hyperqube"

# Active configuration (will be set based on flags)
ACTIVE_NODE_TYPE="zenon" # default node type
ACTIVE_REPO=""
ACTIVE_BRANCH=""
ACTIVE_BINARY=""
ACTIVE_SERVICE=""
CUSTOM_REPO_URL=""

# Function to set active configuration
set_node_config() {
	local node_type=$1

	case $node_type in
	"zenon")
		ACTIVE_REPO=$DEFAULT_ZENON_REPO
		ACTIVE_BRANCH=$DEFAULT_ZENON_BRANCH
		ACTIVE_BINARY=$DEFAULT_ZENON_BINARY
		ACTIVE_SERVICE=$DEFAULT_ZENON_SERVICE
		;;
	"hyperqube")
		ACTIVE_REPO=$DEFAULT_HYPERQUBE_REPO
		ACTIVE_BRANCH=$DEFAULT_HYPERQUBE_BRANCH
		ACTIVE_BINARY=$DEFAULT_HYPERQUBE_BINARY
		ACTIVE_SERVICE=$DEFAULT_HYPERQUBE_SERVICE
		;;
	esac

	# Override repo URL if custom URL provided
	if [ -n "$CUSTOM_REPO_URL" ]; then
		ACTIVE_REPO=$CUSTOM_REPO_URL
	fi
}
