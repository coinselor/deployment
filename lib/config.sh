#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

ZNNSH_HARDWARE_ARCH=$(uname -m)
export ZNNSH_BUILD_ARCH
ZNNSH_BUILD_ARCH=$(dpkg --print-architecture)
export ZNNSH_HARDWARE_ARCH


export ZNNSH_GUM_VERSION="${ZNNSH_GUM_VERSION:=0.16.1}"
export ZNNSH_GUM_URL="https://github.com/charmbracelet/gum/releases/download/v${ZNNSH_GUM_VERSION}/gum_${ZNNSH_GUM_VERSION}_${ZNNSH_BUILD_ARCH}.deb"
export ZNNSH_GUM_LOGS="${ZNNSH_GUM_LOGS:=true}"

export GUM_LOG_LEVEL_FOREGROUND="#ffffff"
export GUM_LOG_LEVEL_BACKGROUND="#0061EB"


export ZNNSH_GO_VERSION="${ZNNSH_GO_VERSION:=1.23.0}"
if [[ "$ZNNSH_HARDWARE_ARCH" == "x86_64" ]]; then
    ZNNSH_GO_URL="https://go.dev/dl/go$ZNNSH_GO_VERSION.linux-amd64.tar.gz"
else
    echo "Error: $ZNNSH_HARDWARE_ARCH architecture is not supported."
    exit 1
fi
export ZNNSH_GO_URL


export ZNNSH_DEBUG="${ZNNSH_DEBUG:=false}"
export ZNNSH_LOG_FILE="${ZNNSH_LOG_FILE:=$ZNNSH_DEPLOYMENT_DIR/.znnsh.log}"
export ZNNSH_INTERACTIVE_MODE="${ZNNSH_INTERACTIVE_MODE:=true}"

export ZNNSH_INSTALL_DIR="${ZNNSH_INSTALL_DIR:=/usr/local/bin}"
export ZNNSH_BUILD_SOURCE="${ZNNSH_BUILD_SOURCE:=false}"
export ZNNSH_BUILD_URL="${ZNNSH_BUILD_URL:=}"
export ZNNSH_BUILD_BRANCH="${ZNNSH_BUILD_BRANCH:=master}"


export ZNNSH_NODE_TYPE="${ZNNSH_NODE_TYPE:="zenon"}"
export ZNNSH_REPO_URL="${ZNNSH_REPO_URL:="https://github.com/zenon-network/go-zenon.git"}"
export ZNNSH_BRANCH_NAME="${ZNNSH_BRANCH_NAME:="master"}"
export ZNNSH_BINARY_NAME="${ZNNSH_BINARY_NAME:="znnd"}"
export ZNNSH_SERVICE_NAME="${ZNNSH_SERVICE_NAME:="go-zenon"}"


declare -A ZNNSH_DEFAULT_NODE_CONFIG=(
  [zenon_repo]="https://github.com/zenon-network/go-zenon.git"
  [zenon_branch]="master"
  [zenon_binary]="znnd"
  [zenon_service]="go-zenon"
  
  [hyperqube_repo]="https://github.com/hypercore-one/hyperqube_z.git"
  [hyperqube_branch]="hyperqube_z"
  [hyperqube_binary]="hqzd"
  [hyperqube_service]="go-hyperqube"
)

export ZNNSH_DEFAULT_NODE_CONFIG



























# # Environment variables set before sourcing this file will override these defaults.

# REQUIRED_PACKAGES="build-essential git curl wget"


# ZENON_REPO_URL="${ZENON_REPO_URL:-https://github.com/zenon-network/go-zenon.git}"
# ZENON_BRANCH="${ZENON_BRANCH:-master}"
# GO_VERSION="${GO_VERSION:-1.23.0}"
# GO_DOWNLOAD_BASE_URL="https://go.dev/dl"
# declare -A GO_CHECKSUMS=(
# 	["go1.24.1.linux-amd64.tar.gz"]="cb2396bae64183cdccf81a9a6df0aea3bce9511fc21469fb89a0c00470088073"
# )

# INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
# DATA_DIR="${DATA_DIR:-/var/lib/zenon}"
# LOG_DIR="${LOG_DIR:-/var/log/zenon}"
# LOG_FILE="${LOG_FILE:-${LOG_DIR}/go-zenon.log}"


# SERVICE_NAME="${SERVICE_NAME:-go-zenon}"

# # User/Group for running the service
# # For production, consider creating a dedicated system user:
# # sudo useradd -r -s /bin/false zenon
# SERVICE_USER="${SERVICE_USER:-zenon}"
# SERVICE_GROUP="${SERVICE_GROUP:-zenon}"

# # Service file location
# SYSTEMD_SERVICE_DIR="/etc/systemd/system"


# # -----------------------------------------------------------------------------
# # Architecture Detection (Ubuntu/Linux only)
# # -----------------------------------------------------------------------------
# UNAME_ARCH="$(uname -m)"
# case "$UNAME_ARCH" in
# x86_64)
# 	GO_ARCH="linux-amd64"
# 	;;
# aarch64 | arm64)
# 	GO_ARCH="linux-arm64"
# 	;;
# *)
# 	echo "Error: Architecture $UNAME_ARCH is not supported." >&2
# 	exit 1
# 	;;
# esac

# # Construct the Go download URL
# GO_URL="${GO_DOWNLOAD_BASE_URL}/go${GO_VERSION}.${GO_ARCH}.tar.gz"

