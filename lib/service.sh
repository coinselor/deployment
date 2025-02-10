#!/bin/bash -e

# Function to stop node service if running
stop_node_if_running() {
	if systemctl is-active --quiet "$ACTIVE_SERVICE"; then
		echo "Stopping $ACTIVE_SERVICE service..."
		systemctl stop "$ACTIVE_SERVICE"
		echo "$ACTIVE_SERVICE service stopped."
	else
		echo "$ACTIVE_SERVICE service is not running."
	fi
}

# Function to start node service
start_node() {
	local node_type=${1:-"zenon"} # Default to zenon if no argument
	set_node_config "$node_type"
	echo "Starting $ACTIVE_SERVICE service..."
	systemctl start "$ACTIVE_SERVICE"
	echo "$ACTIVE_SERVICE started successfully."
}

# Function to stop node service
stop_node() {
	local node_type=${1:-"zenon"} # Default to zenon if no argument
	set_node_config "$node_type"
	echo "Stopping $ACTIVE_SERVICE..."
	systemctl stop "$ACTIVE_SERVICE"
	echo "$ACTIVE_SERVICE stopped successfully."
}

# Function to restart node service
restart_node() {
	echo "Restarting $ACTIVE_SERVICE..."
	systemctl restart "$ACTIVE_SERVICE"
	echo "$ACTIVE_SERVICE restarted successfully."
}

# Function to monitor logs
monitor_logs() {
	local node_type=${1:-"zenon"} # Default to zenon if no argument
	set_node_config "$node_type"
	echo "Monitoring $ACTIVE_BINARY logs. Press Ctrl+C to stop."
	tail -f /var/log/syslog | grep "$ACTIVE_BINARY"
}
