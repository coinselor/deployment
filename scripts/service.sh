#!/usr/bin/env bash

[ -z "$PROJECT_ROOT" ] && echo "Error: config.sh not sourced." && exit 1
. "$SCRIPT_DIR/logging.sh"
. "$SCRIPT_DIR/utils.sh"

create_service() {
    SERVICE_SYSTEM=$(detect_service_system)

    if [ "$SERVICE_SYSTEM" = "systemd" ]; then
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            warn_log "$SERVICE_NAME service is already running. Stopping it first..."
            systemctl stop "$SERVICE_NAME"
        fi

        $SUDO tee "${SYSTEMD_SERVICE_DIR}/${SERVICE_NAME}.service" >/dev/null <<EOF
[Unit]
Description=znnd service
After=network.target

[Service]
LimitNOFILE=32768
User=$SERVICE_USER
Group=$SERVICE_GROUP
Type=simple
SuccessExitStatus=SIGKILL 9
ExecStart=${INSTALL_DIR}/znnd
ExecStop=/usr/bin/pkill -9 znnd
Restart=on-failure
TimeoutStopSec=10s
TimeoutStartSec=10s

[Install]
WantedBy=multi-user.target
EOF

        gum spin --spinner dot --title "Reloading systemd daemon..." -- \
            $SUDO systemctl daemon-reload || {
            error_log "Failed to reload systemd daemon"
            return 1
        }

        gum spin --spinner dot --title "Enabling $SERVICE_NAME service..." -- \
            $SUDO systemctl enable "$SERVICE_NAME.service" || {
            error_log "Failed to enable $SERVICE_NAME service"
            return 1
        }

    else
        cat >"$HOME/start-$SERVICE_NAME.sh" <<EOF
#!/bin/bash
mkdir -p $DATA_DIR
exec ${INSTALL_DIR}/znnd --datadir $DATA_DIR
EOF
        chmod +x "$HOME/start-$SERVICE_NAME.sh"
        success_log "Created start script at $HOME/start-$SERVICE_NAME.sh"
    fi

    success_log "Service configuration completed"
    return 0
}

start_go_zenon() {
    SERVICE_SYSTEM=$(detect_service_system)

    if [ "$SERVICE_SYSTEM" = "systemd" ]; then
        success_log "Starting $SERVICE_NAME service..."
        $SUDO systemctl start "$SERVICE_NAME" || {
            error_log "Failed to start $SERVICE_NAME service"
            systemctl status "$SERVICE_NAME"
            return 1
        }
    else
        success_log "Starting $SERVICE_NAME process..."
        nohup "$HOME/start-$SERVICE_NAME.sh" >"$LOG_FILE" 2>&1 &
        echo $! >"/tmp/$SERVICE_NAME.pid"
        sleep 2
        if [ -f "/tmp/$SERVICE_NAME.pid" ] && kill -0 $(cat "/tmp/$SERVICE_NAME.pid") 2>/dev/null; then
            success_log "$SERVICE_NAME process started"
        else
            error_log "Failed to start $SERVICE_NAME process"
            return 1
        fi
    fi
    return 0
}

stop_go_zenon() {
    SERVICE_SYSTEM=$(detect_service_system)

    if [ "$SERVICE_SYSTEM" = "systemd" ]; then
        success_log "Stopping $SERVICE_NAME service..."
        $SUDO systemctl stop "$SERVICE_NAME" || {
            error_log "Failed to stop $SERVICE_NAME service"
            systemctl status "$SERVICE_NAME"
            return 1
        }
    else
        if [ -f "/tmp/$SERVICE_NAME.pid" ]; then
            success_log "Stopping $SERVICE_NAME process..."
            kill $(cat "/tmp/$SERVICE_NAME.pid")
            rm -f "/tmp/$SERVICE_NAME.pid"
            success_log "$SERVICE_NAME process stopped"
        else
            warn_log "$SERVICE_NAME process is not running"
        fi
    fi
    return 0
}

restart_go_zenon() {
    SERVICE_SYSTEM=$(detect_service_system)

    if [ "$SERVICE_SYSTEM" = "systemd" ]; then
        success_log "Restarting $SERVICE_NAME service..."
        $SUDO systemctl restart "$SERVICE_NAME" || {
            error_log "Failed to restart $SERVICE_NAME service"
            systemctl status "$SERVICE_NAME"
            return 1
        }
    else
        stop_go_zenon
        start_go_zenon
    fi
    return 0
}

monitor_logs() {
    echo "Monitoring znnd logs. Press Ctrl+C to stop."
    tail -f "$LOG_FILE"
}
