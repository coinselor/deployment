#!/usr/bin/env bash

[ -z "$PROJECT_ROOT" ] && echo "Error: config.sh not sourced." && exit 1
. "$SCRIPT_DIR/logging.sh"

install_grafana() {
    success_log "Installing Grafana..."

    GITHUB_REPO=$(git config --get remote.origin.url | sed 's/.*github.com[:\/]\(.*\)\.git/\1/')
    GITHUB_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    GRAFANA_SCRIPT_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}/grafana.sh"

    wget -O grafana.sh "$GRAFANA_SCRIPT_URL"
    chmod +x grafana.sh
    ./grafana.sh
    success_log "Grafana installed successfully."
}
