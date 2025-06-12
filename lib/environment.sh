#!/usr/bin/env bash

ZNNSH_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$ZNNSH_LIB_DIR/config.sh"
source "$ZNNSH_LIB_DIR/gum.sh"
source "$ZNNSH_LIB_DIR/logging.sh"
source "$ZNNSH_LIB_DIR/utils.sh"
source "$ZNNSH_LIB_DIR/menu.sh"
source "$ZNNSH_LIB_DIR/help.sh"
source "$ZNNSH_LIB_DIR/build.sh"
source "$ZNNSH_LIB_DIR/start.sh"
source "$ZNNSH_LIB_DIR/stop.sh"
source "$ZNNSH_LIB_DIR/monitor.sh"
source "$ZNNSH_LIB_DIR/deploy.sh"


