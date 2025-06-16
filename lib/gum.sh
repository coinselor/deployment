#!/usr/bin/env bash

if command -v gum &>/dev/null; then
	return 0
fi

if ! command -v wget &>/dev/null; then
    apt install -y wget >> "$ZNNSH_LOG_FILE" 2>&1
fi

wget -qO /tmp/gum.deb "$ZNNSH_GUM_URL" >> "$ZNNSH_LOG_FILE" 2>&1
apt install -y /tmp/gum.deb >> "$ZNNSH_LOG_FILE" 2>&1
rm /tmp/gum.deb

if ! command -v gum &>/dev/null; then
	echo "Error: gum installation failed." >&2
	exit 1
fi

