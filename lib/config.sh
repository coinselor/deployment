#!/bin/bash -e

# Global variables
BUILD_SOURCE=false
BUILD_SOURCE_URL=""

# Go configuration
ARCH=$(uname -m)
GO_URL=""
GO_VERSION=1.23.0

if [[ "$ARCH" == "x86_64" ]]; then
	GO_URL="https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz"
fi

# ARM Support TODO
# if [[ "$ARCH" == "arm64" ]]; then
#     GO_URL="https://go.dev/dl/go$GO_VERSION.linux-arm64.tar.gz"
# fi

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
