#!/usr/bin/env bash

install_prerequisites() {
    local packages=("apt-transport-https" "software-properties-common" "wget" "curl" "jq" "gpg")
    local missing_packages=()
    
    for package in "${packages[@]}"; do
        if ! dpkg -l "$package" >/dev/null 2>&1; then
            missing_packages+=("$package")
        fi
    done
    
    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        info_log "All prerequisite packages already installed."
        return 0
    fi
    
    info_log "Installing missing packages: ${missing_packages[*]}"
    
    apt-get update -qq || { error_log "Failed to update package lists"; return 1; }
    apt-get install -y "${missing_packages[@]}" || { 
        error_log "Failed to install prerequisite packages"; return 1; }
    
    success_log "Prerequisite packages installed."
}


install_node_exporter() {
    if systemctl is-active --quiet node_exporter; then
        info_log "Node Exporter already running – skipping installation."
        return 0
    fi

    if [[ -f /usr/local/bin/node_exporter ]]; then
        info_log "Node Exporter binary exists, starting service..."
        systemctl daemon-reload
        systemctl enable --now node_exporter
        return 0
    fi

    info_log "Installing Node Exporter ${ZNNSH_NODE_EXPORTER_VERSION}…"
    curl -fsSL -o "/tmp/node_exporter.tar.gz" \
        "https://github.com/prometheus/node_exporter/releases/download/v${ZNNSH_NODE_EXPORTER_VERSION}/node_exporter-${ZNNSH_NODE_EXPORTER_VERSION}.linux-amd64.tar.gz" || {
        error_log "Unable to download Node Exporter"; return 1; }

    tar -xzf /tmp/node_exporter.tar.gz -C /tmp
    install -m 0755 "/tmp/node_exporter-${ZNNSH_NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" /usr/local/bin/

    if ! id node_exporter >/dev/null 2>&1; then
        useradd -rs /bin/false node_exporter
    fi

    if [[ ! -f /etc/systemd/system/node_exporter.service ]]; then
        cat <<EOF >/etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
    fi

    systemctl daemon-reload
    systemctl enable --now node_exporter

    rm -rf "/tmp/node_exporter.tar.gz" "/tmp/node_exporter-${ZNNSH_NODE_EXPORTER_VERSION}.linux-amd64"
    success_log "Node Exporter installed."
}


install_prometheus() {
    if systemctl is-active --quiet prometheus; then
        info_log "Prometheus already running – skipping installation."
        return 0
    fi

    if [[ -f /usr/local/bin/prometheus ]]; then
        info_log "Prometheus binary exists, starting service..."
        systemctl daemon-reload
        systemctl enable --now prometheus
        return 0
    fi

    info_log "Installing Prometheus ${ZNNSH_PROMETHEUS_VERSION}…"

    mkdir -p /etc/prometheus /var/lib/prometheus
    curl -fsSL -o "/tmp/prometheus.tar.gz" \
        "https://github.com/prometheus/prometheus/releases/download/v${ZNNSH_PROMETHEUS_VERSION}/prometheus-${ZNNSH_PROMETHEUS_VERSION}.linux-amd64.tar.gz" || {
        error_log "Unable to download Prometheus"; return 1; }

    tar -xzf /tmp/prometheus.tar.gz -C /tmp
    local SRC="/tmp/prometheus-${ZNNSH_PROMETHEUS_VERSION}.linux-amd64"
    install -m 0755 "${SRC}/prometheus" "${SRC}/promtool" /usr/local/bin/
    
    [[ ! -d /etc/prometheus/consoles ]] && cp -r "${SRC}/consoles" /etc/prometheus/
    [[ ! -d /etc/prometheus/console_libraries ]] && cp -r "${SRC}/console_libraries" /etc/prometheus/
    [[ ! -f /etc/prometheus/prometheus.yml ]] && cp "${SRC}/prometheus.yml" /etc/prometheus/prometheus.yml

    if ! id prometheus >/dev/null 2>&1; then
        useradd -rs /bin/false prometheus
    fi
    if [[ ! -f /etc/systemd/system/prometheus.service ]]; then
        cat <<EOF >/etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/

[Install]
WantedBy=multi-user.target
EOF
    fi

    chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
    systemctl daemon-reload
    systemctl enable --now prometheus

    rm -rf /tmp/prometheus.tar.gz "${SRC}"

    if ! grep -q 'job_name: "node"' /etc/prometheus/prometheus.yml; then
        info_log "Adding Node Exporter scrape config to Prometheus."
        cat <<EOT >>/etc/prometheus/prometheus.yml

  - job_name: "node"
    static_configs:
      - targets: ["localhost:9100"]
EOT
        systemctl restart prometheus
    fi

    success_log "Prometheus installed."
}

install_grafana() {
    if systemctl is-active --quiet grafana-server; then
        info_log "Grafana already running – skipping installation."
        return 0
    fi

    if dpkg -l grafana >/dev/null 2>&1; then
        info_log "Grafana package already installed, starting service..."
        systemctl enable --now grafana-server
        wait_for_grafana
        return 0
    fi

    info_log "Installing Grafana…"

    mkdir -p /etc/apt/keyrings/
    
    if [[ ! -f /etc/apt/keyrings/grafana.gpg ]]; then
        curl -fsSL https://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
    fi
    
    if [[ ! -f /etc/apt/sources.list.d/grafana.list ]]; then
        echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
            | tee /etc/apt/sources.list.d/grafana.list >/dev/null
        apt-get update -qq
    fi
    
    apt-get install -y grafana || { error_log "Failed to install Grafana"; return 1; }

    systemctl enable --now grafana-server

    wait_for_grafana
    success_log "Grafana installed."
}


wait_for_grafana() {
    local timeout=60
    if curl -fsS http://localhost:3000 >/dev/null 2>&1; then
        return 0
    fi
    until curl -fsS http://localhost:3000 >/dev/null 2>&1; do
        ((timeout--)) || { error_log "Grafana did not start in time"; return 1; }
        sleep 1
    done
    return 0
}


configure_prometheus_datasource() {
    info_log "Configuring Prometheus datasource in Grafana…"
    
    local existing_ds
    existing_ds=$(curl -fsS -u "$ZNNSH_GRAFANA_ADMIN_USER:$ZNNSH_GRAFANA_ADMIN_PASSWORD" \
        http://localhost:3000/api/datasources/name/Prometheus 2>/dev/null)
    
    if [[ -n "$existing_ds" ]]; then
        info_log "Prometheus datasource already exists."
        return 0
    fi
    
    curl -fsS -X POST -H "Content-Type: application/json" \
      -u "$ZNNSH_GRAFANA_ADMIN_USER:$ZNNSH_GRAFANA_ADMIN_PASSWORD" \
      -d '{"name":"Prometheus","type":"prometheus","url":"http://localhost:9090","access":"proxy","isDefault":true}' \
      http://localhost:3000/api/datasources >/dev/null 2>&1 || {
        warn_log "Failed to configure Prometheus datasource"; return 1; }
    
    success_log "Prometheus datasource configured."
}

install_infinity_plugin() {
    if grafana-cli plugins ls | grep -q yesoreyeram-infinity-datasource; then
        info_log "Infinity plugin already installed."
        return 0
    fi
    
    info_log "Installing Infinity datasource plugin…"
    grafana-cli plugins install yesoreyeram-infinity-datasource "$ZNNSH_INFINITY_PLUGIN_VERSION" || {
        warn_log "Failed to install Infinity plugin"; return 1; }
    chown -R grafana:grafana /var/lib/grafana/plugins
    systemctl restart grafana-server
    wait_for_grafana
    success_log "Infinity plugin installed."
}

configure_infinity_datasource() {
    info_log "Configuring Infinity datasource in Grafana…"
    
    local existing_ds
    existing_ds=$(curl -fsS -u "$ZNNSH_GRAFANA_ADMIN_USER:$ZNNSH_GRAFANA_ADMIN_PASSWORD" \
        http://localhost:3000/api/datasources/name/yesoreyeram-infinity-datasource 2>/dev/null)
    
    if [[ -n "$existing_ds" ]]; then
        info_log "Infinity datasource already exists."
        return 0
    fi
    
    curl -fsS -X POST -H "Content-Type: application/json" \
      -u "$ZNNSH_GRAFANA_ADMIN_USER:$ZNNSH_GRAFANA_ADMIN_PASSWORD" \
      -d '{"name":"yesoreyeram-infinity-datasource","type":"yesoreyeram-infinity-datasource","access":"proxy"}' \
      http://localhost:3000/api/datasources >/dev/null 2>&1 || {
        warn_log "Failed to configure Infinity datasource"; return 1; }
    
    success_log "Infinity datasource configured."
}


dashboard_exists() {
    local dashboard_title="$1"
    local search_result
    search_result=$(curl -fsS -u "$ZNNSH_GRAFANA_ADMIN_USER:$ZNNSH_GRAFANA_ADMIN_PASSWORD" \
        --get --data-urlencode "query=$dashboard_title" \
        http://localhost:3000/api/search 2>/dev/null)
    
    if [[ -n "$search_result" ]] && [[ "$search_result" != "[]" ]]; then
        return 0  # Dashboard exists
    else
        return 1  # Dashboard doesn't exist
    fi
}

import_dashboard() {
    local json_path="$1"
    local dashboard_title="$2"
    
    if [[ ! -f "$json_path" ]]; then
        error_log "Dashboard json $json_path not found"; return 1; 
    fi

    if [[ -n "$dashboard_title" ]] && dashboard_exists "$dashboard_title"; then
        info_log "Dashboard '$dashboard_title' already exists – skipping import."
        return 0
    fi

    info_log "Importing dashboard from $json_path…"
    
    local payload_file="/tmp/import_dashboard_payload.json"
    cat <<EOF > "$payload_file"
{
  "dashboard": $(cat "$json_path"),
  "folderId": 0,
  "overwrite": true
}
EOF

    curl -fsS -X POST -H "Content-Type: application/json" \
      -u "$ZNNSH_GRAFANA_ADMIN_USER:$ZNNSH_GRAFANA_ADMIN_PASSWORD" \
      -d "@$payload_file" \
      http://localhost:3000/api/dashboards/db >/dev/null 2>&1 || {
        warn_log "Failed to import dashboard $json_path"; return 1; }
    
    rm -f "$payload_file"
    success_log "Dashboard imported successfully."
}


import_default_dashboards() {
    local tmp_json=/tmp/node_exporter_dashboard.json
    if ! dashboard_exists "Node Exporter Full"; then
        if curl -fsSL "https://grafana.com/api/dashboards/1860/revisions/latest/download" -o "$tmp_json"; then
            import_dashboard "$tmp_json" "Node Exporter Full"
        else
            warn_log "Failed to download Node Exporter dashboard"
        fi
    else
        info_log "Node Exporter dashboard already exists – skipping."
    fi

    if [[ "$ZNNSH_NODE_TYPE" == "hyperqube" && ! $(dashboard_exists "HQZD Dashboard") ]]; then
        local hqzd_local=""
        if [[ -n "$ZNNSH_DEPLOYMENT_DIR" && -f "$ZNNSH_DEPLOYMENT_DIR/dashboards/hqzd.json" ]]; then
            hqzd_local="$ZNNSH_DEPLOYMENT_DIR/dashboards/hqzd.json"
        fi
        if [[ -z "$hqzd_local" ]]; then
            local script_dir
            script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            if [[ -f "$script_dir/../dashboards/hqzd.json" ]]; then
                hqzd_local="$script_dir/../dashboards/hqzd.json"
            fi
        fi

        if [[ -n "$hqzd_local" ]]; then
            info_log "Importing local hqzd dashboard from $hqzd_local"
            local hqzd_payload="/tmp/import_hqzd_dashboard.json"
            cat <<EOF > "$hqzd_payload"
{
  "dashboard": $(cat "$hqzd_local"),
  "folderId": 0,
  "overwrite": true,
  "inputs": [{
    "name": "DS_YESOREYERAM-INFINITY-DATASOURCE",
    "type": "datasource",
    "pluginId": "yesoreyeram-infinity-datasource",
    "value": "yesoreyeram-infinity-datasource"
  }]
}
EOF
            curl -fsS -X POST -H "Content-Type: application/json" \
              -u "$ZNNSH_GRAFANA_ADMIN_USER:$ZNNSH_GRAFANA_ADMIN_PASSWORD" \
              -d "@$hqzd_payload" \
              http://localhost:3000/api/dashboards/import >/dev/null 2>&1 && \
              success_log "HQZD dashboard imported successfully from local copy." || \
              warn_log "Failed to import local hqzd dashboard"
            rm -f "$hqzd_payload"
        fi
    fi

    if ! dashboard_exists "ZNND Dashboard"; then
        local znnd_local=""
        if [[ -n "$ZNNSH_DEPLOYMENT_DIR" && -f "$ZNNSH_DEPLOYMENT_DIR/dashboards/znnd.json" ]]; then
            znnd_local="$ZNNSH_DEPLOYMENT_DIR/dashboards/znnd.json"
        fi
        if [[ -z "$znnd_local" ]]; then
            local script_dir
            script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            if [[ -f "$script_dir/../dashboards/znnd.json" ]]; then
                znnd_local="$script_dir/../dashboards/znnd.json"
            fi
        fi

        if [[ -n "$znnd_local" ]]; then
            info_log "Importing local znnd dashboard from $znnd_local"
            local znnd_payload="/tmp/import_znnd_dashboard.json"
            cat <<EOF > "$znnd_payload"
{
  "dashboard": $(cat "$znnd_local"),
  "folderId": 0,
  "overwrite": true,
  "inputs": [{
    "name": "DS_YESOREYERAM-INFINITY-DATASOURCE",
    "type": "datasource",
    "pluginId": "yesoreyeram-infinity-datasource",
    "value": "yesoreyeram-infinity-datasource"
  }]
}
EOF
            curl -fsS -X POST -H "Content-Type: application/json" \
              -u "$ZNNSH_GRAFANA_ADMIN_USER:$ZNNSH_GRAFANA_ADMIN_PASSWORD" \
              -d "@$znnd_payload" \
              http://localhost:3000/api/dashboards/import >/dev/null 2>&1 && \
              success_log "ZNND dashboard imported successfully from local copy." || \
              warn_log "Failed to import local znnd dashboard"
            rm -f "$znnd_payload"
        fi
    fi

    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
        local GITHUB_REPO
        GITHUB_REPO=$(git config --get remote.origin.url | sed 's/.*github.com[:\/]\(.*\)\.git/\1/' 2>/dev/null)
        local GITHUB_BRANCH
        GITHUB_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        
        if [[ -n "$GITHUB_REPO" ]] && [[ -n "$GITHUB_BRANCH" ]]; then
            local node_dash_url="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}/dashboards/${dashboard_json}"
            local tmp_node_dash=/tmp/${dashboard_json}

            # Determine node-specific dashboard variables
            local dashboard_title
            local dashboard_json
            if [[ "$ZNNSH_NODE_TYPE" == "hyperqube" ]]; then
                dashboard_title="HQZD Dashboard"
                dashboard_json="hqzd.json"
            else
                dashboard_title="ZNND Dashboard"
                dashboard_json="znnd.json"
            fi

            local node_dash_url="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}/dashboards/${dashboard_json}"
            local tmp_node_dash="/tmp/${dashboard_json}"

            if ! dashboard_exists "$dashboard_title"; then
                if curl -fsSL "$node_dash_url" -o "$tmp_node_dash" 2>/dev/null; then
                    local znnd_payload="/tmp/import_znnd_dashboard.json"
                    cat <<EOF > "$znnd_payload"
{
  "dashboard": $(cat "$tmp_node_dash"),
  "folderId": 0,
  "overwrite": true,
  "inputs": [{
    "name": "DS_YESOREYERAM-INFINITY-DATASOURCE",
    "type": "datasource",
    "pluginId": "yesoreyeram-infinity-datasource",
    "value": "yesoreyeram-infinity-datasource"
  }]
}
EOF
                    curl -fsS -X POST -H "Content-Type: application/json" \
                      -u "$ZNNSH_GRAFANA_ADMIN_USER:$ZNNSH_GRAFANA_ADMIN_PASSWORD" \
                      -d "@$znnd_payload" \
                      http://localhost:3000/api/dashboards/import >/dev/null 2>&1 && \
                      success_log "$dashboard_title imported successfully." || \
                      warn_log "Failed to import $dashboard_title"
                    rm -f "$znnd_payload"
                else
                    info_log "Dashboard not found at $node_dash_url – skipping."
                fi
            else
                info_log "$dashboard_title already exists – skipping."
            fi
        else
            info_log "Could not determine git repository info – skipping znnd dashboard."
        fi
    else
        info_log "Not in a git repository – skipping znnd dashboard."
    fi
}

export -f install_prerequisites install_node_exporter install_prometheus install_grafana wait_for_grafana configure_prometheus_datasource install_infinity_plugin configure_infinity_datasource dashboard_exists import_dashboard import_default_dashboards