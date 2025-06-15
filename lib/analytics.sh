#!/usr/bin/env bash

analytics() {
    local debug=""
    if [[ "$ZNNSH_DEBUG" = true ]]; then
        debug="--show-output"
    fi

    gum style --border-foreground 239 --foreground 239 "==== ANALYTICS STACK SETUP ===="

    gum spin --spinner meter --spinner.foreground 46 --title "Installing prerequisites…" $debug -- \
        bash -c "install_prerequisites" || {
        error_log "Failed to install prerequisites"; return 1; }

    gum spin --spinner meter --spinner.foreground 46 --title "Installing Node Exporter…" $debug -- \
        bash -c "install_node_exporter" || { error_log "Failed to install Node Exporter"; return 1; }

    gum spin --spinner meter --spinner.foreground 46 --title "Installing Prometheus…" $debug -- \
        bash -c "install_prometheus" || { error_log "Failed to install Prometheus"; return 1; }

    gum spin --spinner meter --spinner.foreground 46 --title "Installing Grafana…" $debug -- \
        bash -c "install_grafana" || { error_log "Failed to install Grafana"; return 1; }

    gum spin --spinner meter --spinner.foreground 46 --title "Configuring Grafana datasources…" $debug -- \
        bash -c "configure_prometheus_datasource && install_infinity_plugin && configure_infinity_datasource" || {
        error_log "Failed to configure datasources/plugins"; return 1; }

    gum spin --spinner meter --spinner.foreground 46 --title "Importing dashboards…" $debug -- \
        bash -c "import_default_dashboards" || {
        warn_log "Some dashboards failed to import"; }

    success_log "Analytics stack installed successfully. Access Grafana at http://<host>:3000 (admin/admin)."
}

export -f analytics

