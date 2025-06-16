#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

ZNNSH_HARDWARE_ARCH=$(uname -m)
export ZNNSH_BUILD_ARCH
ZNNSH_BUILD_ARCH=$(dpkg --print-architecture)
export ZNNSH_HARDWARE_ARCH


export ZNNSH_GUM_VERSION="${ZNNSH_GUM_VERSION:=0.16.1}"
export ZNNSH_GUM_URL="https://github.com/charmbracelet/gum/releases/download/v${ZNNSH_GUM_VERSION}/gum_${ZNNSH_GUM_VERSION}_${ZNNSH_BUILD_ARCH}.deb"
export ZNNSH_GUM_LOGS="${ZNNSH_GUM_LOGS:=true}"

export GUM_LOG_LEVEL_FOREGROUND="#0061EB"
export GUM_LOG_TIME_FOREGROUND="239"
export GUM_LOG_PREFIX_FOREGROUND="250"
export GUM_CONFIRM_PROMPT_FOREGROUND="#FFFFFF"
export GUM_CONFIRM_SELECTED_FOREGROUND="#000000"
export GUM_CONFIRM_SELECTED_BACKGROUND="#00FF00"
export GUM_INPUT_CURSOR_FOREGROUND="#000000"
export GUM_INPUT_CURSOR_BACKGROUND="#00FF00"

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
export ZNNSH_ZNN_DIR="${ZNNSH_ZNN_DIR:=/root/.znn}"
export ZNNSH_HQZD_DIR="${ZNNSH_HQZD_DIR:=/root/.hqzd}"
export ZNNSH_HQZD_GENESIS_URL="${ZNNSH_HQZD_GENESIS_URL:=https://gist.githubusercontent.com/georgezgeorgez/32edacf2681d7491169342cd8c698cdb/raw/f02295d4616f09b6cf606e0306fa501ad09856ba/genesis.json}"

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

export ZNNSH_BACKUP_DIR="${ZNNSH_BACKUP_DIR:=/backup}"
export ZNNSH_MAX_BACKUPS="${ZNNSH_MAX_BACKUPS:=7}"
export ZNNSH_BACKUP_CADENCE_DAYS="${ZNNSH_BACKUP_CADENCE_DAYS:=0}"
export ZNNSH_MIN_FREE_SPACE_KB="${ZNNSH_MIN_FREE_SPACE_KB:=15728640}"  # 15 GB

export ZNNSH_NODE_EXPORTER_VERSION="${ZNNSH_NODE_EXPORTER_VERSION:=1.6.1}"
export ZNNSH_PROMETHEUS_VERSION="${ZNNSH_PROMETHEUS_VERSION:=2.47.0}"
export ZNNSH_INFINITY_PLUGIN_VERSION="${ZNNSH_INFINITY_PLUGIN_VERSION:=2.10.0}"
export ZNNSH_GRAFANA_ADMIN_USER="${ZNNSH_GRAFANA_ADMIN_USER:=admin}"
export ZNNSH_GRAFANA_ADMIN_PASSWORD="${ZNNSH_GRAFANA_ADMIN_PASSWORD:=admin}"