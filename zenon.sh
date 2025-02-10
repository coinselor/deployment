#!/bin/bash -e
# go-zenon.sh - Main entry point

# Display ASCII Art for Zenon Network
cat <<'EOF'
 ______                             _
|___  /                            | |
   / /  ___ _ __   ___  _ __    ___| |__
  / /  / _ \ '_ \ / _ \| '_ \  / __| '_ \
./ /__|  __/ | | | (_) | | | |_\__ \ | | |
\_____/\___|_| |_|\___/|_| |_(_)___/_| |_|

 _   _      _                      _             __  ___  ___                           _
| \ | |    | |                    | |           / _| |  \/  |                          | |
|  \| | ___| |___      _____  _ __| | __   ___ | |_  | .  . | ___  _ __ ___   ___ _ __ | |_ _   _ _ __ ___
| . ` |/ _ \ __\ \ /\ / / _ \| '__| |/ /  / _ \|  _| | |\/| |/ _ \| '_ ` _ \ / _ \ '_ \| __| | | | '_ ` _ \
| |\  |  __/ |_ \ V  V / (_) | |  |   <  | (_) | |   | |  | | (_) | | | | | |  __/ | | | |_| |_| | | | | | |
\_| \_/\___|\__| \_/\_/ \___/|_|  |_|\_\  \___/|_|   \_|  |_/\___/|_| |_| |_|\___|_| |_|\__|\__,_|_| |_| |_|
EOF

# Source all library files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/install.sh"
source "$SCRIPT_DIR/lib/service.sh"
source "$SCRIPT_DIR/lib/node.sh"
source "$SCRIPT_DIR/lib/restore.sh"
source "$SCRIPT_DIR/lib/grafana.sh"
source "$SCRIPT_DIR/lib/help.sh"

# Check for flags
if [[ $# -eq 0 ]]; then
	set_node_config "zenon"
	deploy_node
else
	while [[ "$1" != "" ]]; do
		case $1 in
		--deploy)
			shift
			if [[ "$1" == "--hq" ]]; then
				ACTIVE_NODE_TYPE="hyperqube"
				shift
				if [[ "$1" != "" && "$1" != -* ]]; then
					CUSTOM_REPO_URL="$1"
					shift
				fi
			else
				ACTIVE_NODE_TYPE="zenon"
				if [[ "$1" != "" && "$1" != -* ]]; then
					CUSTOM_REPO_URL="$1"
					shift
				fi
			fi
			set_node_config "$ACTIVE_NODE_TYPE"
			deploy_node
			exit
			;;
		--buildSource)
			BUILD_SOURCE=true
			shift
			if [[ "$1" != "" && "$1" != -* ]]; then
				BUILD_SOURCE_URL="$1"
				shift
			fi
			set_node_config "zenon" # Explicitly set to zenon
			deploy_node
			exit
			;;
		--restore)
			restore_node
			exit
			;;
		--restart)
			restart_node
			exit
			;;
		--stop)
			shift
			if [[ "$1" == "--hq" ]]; then
				stop_node "hyperqube"
			else
				stop_node "zenon"
			fi
			exit
			;;
		--start)
			shift
			if [[ "$1" == "--hq" ]]; then
				start_node "hyperqube"
			else
				start_node "zenon"
			fi
			exit
			;;
		--status)
			shift
			if [[ "$1" == "--hq" ]]; then
				monitor_logs "hyperqube"
			else
				monitor_logs "zenon"
			fi
			exit
			;;
		--grafana)
			install_grafana
			exit
			;;
		--help)
			show_help
			exit
			;;
		*)
			echo "Invalid option: $1"
			echo "Usage: $0 [--deploy] [--buildSource [URL]] [--restore] [--restart] [--stop] [--start] [--status] [--grafana] [--help]"
			exit 1
			;;
		esac
	done
fi
