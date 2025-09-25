#!/bin/bash

# Auto-pick the right client
if command -v ddcutil-client &>/dev/null; then
  DDC="ddcutil-client"
elif command -v ddcutilc &>/dev/null; then
  DDC="ddcutilc"
else
  DDC="ddcutil"
fi

DISPLAY=1 # your MSI external monitor
STEP=5    # how much to change brightness

# Get current brightness (absolute number 0–100)
get_current() {
  $DDC --display $DISPLAY getvcp 10 2>/dev/null |
    grep -oP 'current value =\s*\K[0-9]+'
}

# Clamp value between 0–100
clamp() {
  local val=$1
  if ((val < 0)); then val=0; fi
  if ((val > 100)); then val=100; fi
  echo $val
}

# Send desktop notification
notify_user() {
  local value=$1
  notify-send -e \
    -h string:x-canonical-private-synchronous:brightness_notif \
    -h int:value:$value \
    -u low -i display-brightness-symbolic \
    "Screen Brightness" "$value%"
}

case "$1" in
up)
  current=$(get_current)
  new=$((current + STEP))
  new=$(clamp $new)
  $DDC --display $DISPLAY setvcp 10 $new
  notify_user "$new"
  ;;
down)
  current=$(get_current)
  new=$((current - STEP))
  new=$(clamp $new)
  $DDC --display $DISPLAY setvcp 10 $new
  notify_user "$new"
  ;;
set)
  if [[ -n "$2" ]]; then
    new=$(clamp "$2")
    $DDC --display $DISPLAY setvcp 10 $new
    notify_user "$new"
  else
    echo "Usage: $0 set <value>"
    exit 1
  fi
  ;;
get)
  get_current
  ;;
*)
  echo "Usage: $0 {up|down|get|set <value>}"
  exit 1
  ;;
esac
