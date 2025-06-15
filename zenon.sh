#!/usr/bin/env bash

set -euo pipefail
trap 'echo "Error: Script failed on line $LINENO of $BASH_SOURCE" >&2' ERR

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

ZNNSH_DEPLOYMENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ZNNSH_DEPLOYMENT_DIR

source "$ZNNSH_DEPLOYMENT_DIR/lib/environment.sh"

main() {

    if [[ $# -eq 0 ]]; then
        show_menu
        exit 0
    fi

    if [[ "$1" == "hyperqube" && $# -eq 1 ]]; then
        set_node_config "hyperqube"
        show_menu
        exit 0
    fi

    export ZNNSH_INTERACTIVE_MODE="false"


    case $1 in
        --deploy)
            shift
            local custom_repo
            local custom_branch
            local node_type="zenon"
            
            if [[ $# -gt 0 && ("$1" == "zenon" || "$1" == "hyperqube") ]]; then
                node_type="$1"
                shift
            fi
            
            if [[ $# -gt 0 && "$1" != -* ]]; then
                custom_repo="$1"
                shift
                
                if [[ $# -gt 0 && "$1" != -* ]]; then
                    custom_branch="$1"
                    shift
                fi
            fi
            
            set_node_config "$node_type"
            if [[ -n "$custom_repo" ]]; then
                export ZNNSH_REPO_URL="$custom_repo"
            fi
            if [[ -n "$custom_branch" ]]; then
                export ZNNSH_BRANCH_NAME="$custom_branch"
            fi
            deploy
            ;;
            
        --restore)
            shift
            local node_type="zenon"
            
            if [[ $# -gt 0 && ("$1" == "zenon" || "$1" == "hyperqube") ]]; then
                node_type="$1"
                shift
            fi
            
            set_node_config "$node_type"
            restore
            ;;
            
        --restart)
            shift
            local node_type="zenon"
            
            if [[ $# -gt 0 && ("$1" == "zenon" || "$1" == "hyperqube") ]]; then
                node_type="$1"
                shift
            fi
            
            set_node_config "$node_type"
            restart_service
            ;;
            
        --stop)
            shift
            local node_type="zenon"
            
            if [[ $# -gt 0 && ("$1" == "zenon" || "$1" == "hyperqube") ]]; then
                node_type="$1"
                shift
            fi
            
            set_node_config "$node_type"
            stop_service
            ;;
            
        --start)
            shift
            local node_type="zenon"
            
            if [[ $# -gt 0 && ("$1" == "zenon" || "$1" == "hyperqube") ]]; then
                node_type="$1"
                shift
            fi
            
            set_node_config "$node_type"
            start_service
            ;;
            
        --monitor)
            shift
            local node_type="zenon"
            
            if [[ $# -gt 0 && ("$1" == "zenon" || "$1" == "hyperqube") ]]; then
                node_type="$1"
                shift
            fi
            
            set_node_config "$node_type"
            monitor_service
            ;;
            
        --resync)
            shift
            local node_type="zenon"
            
            if [[ $# -gt 0 && ("$1" == "zenon" || "$1" == "hyperqube") ]]; then
                node_type="$1"
                shift
            fi
            
            set_node_config "$node_type"
            resync_node
            ;;
            
        --analytics)
            shift
            local node_type="zenon"
            if [[ $# -gt 0 && ("$1" == "zenon" || "$1" == "hyperqube") ]]; then
                node_type="$1"
                shift
            fi
            set_node_config "$node_type"
            analytics
            ;;
            
        --help)
            show_help   
            ;;
            
        *)
            show_help
            ;;
    esac
    
    exit 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi