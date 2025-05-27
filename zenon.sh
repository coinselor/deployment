#!/usr/bin/env bash

set -euo pipefail
trap 'echo "Error: Script failed on line $LINENO" >&2' ERR

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$PROJECT_ROOT/scripts/config.sh"
. "$PROJECT_ROOT/scripts/install-gum.sh"
. "$PROJECT_ROOT/scripts/logging.sh"
. "$PROJECT_ROOT/scripts/utils.sh"
. "$PROJECT_ROOT/scripts/menu.sh"

if [[ $# -eq 0 ]]; then
	show_menu
else
	case "$1" in
	--deploy)
		deploy_go_zenon
		;;
	--build)
		BUILD_SOURCE=true
		if [[ $# -gt 1 ]]; then
			BUILD_SOURCE_URL="$2"
		else
			log_error "Build URL is required for --build option"
			exit 1
		fi
		deploy_go_zenon
		;;
	--restore)
		restore_go_zenon
		;;
	--restart)
		restart_go_zenon
		;;
	--stop)
		stop_go_zenon
		;;
	--start)
		start_go_zenon
		;;
	--monitor)
		monitor_logs
		;;
	--analytics)
		install_grafana
		;;
	--help)
		show_help
		;;
	*)
		show_help
		exit 1
		;;
	esac
fi
