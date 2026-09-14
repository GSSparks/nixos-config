#!/usr/bin/env bash

set -euo pipefail

# CONFIG
WINDOW_TITLE="Meet"

# FUNCTIONS
focus_meet_window() {
  wmctrl -a "$WINDOW_TITLE"
  sleep 0.2
}

send_ctrl_key() {
  local key_code=$1
  # Ctrl = 29
  ydotool key 29:1 "$key_code":1 29:0 "$key_code":0
}

# USAGE
usage() {
  echo "Usage: $0 [mic|cam|leave]"
  exit 1
}

# MAIN
[[ $# -ne 1 ]] && usage

focus_meet_window

case "$1" in
  mic)
    send_ctrl_key 32  # D
    ;;
  cam)
    send_ctrl_key 18  # E
    ;;
  leave)
    send_ctrl_key 17  # W
    ;;
  *)
    usage
    ;;
esac

