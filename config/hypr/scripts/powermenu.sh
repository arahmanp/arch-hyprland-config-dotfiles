#!/usr/bin/env bash
# Power menu. Uses wlogout if installed, otherwise a fuzzel fallback.
set -euo pipefail

if command -v wlogout >/dev/null 2>&1; then
    if pgrep -x wlogout >/dev/null 2>&1; then
        pkill -x wlogout
        exit 0
    fi
    exec wlogout -p layer-shell
fi

# ---- Fallback: fuzzel menu ----
choice="$(printf '%s\n' \
    '  Lock' \
    '  Logout' \
    '  Suspend' \
    '  Reboot' \
    '  Shutdown' \
    | fuzzel --dmenu --prompt 'Power  ' --width 18 --lines 5)" || exit 0

case "$choice" in
    *Lock*)     loginctl lock-session || hyprlock ;;
    *Logout*)   hyprctl dispatch exit ;;
    *Suspend*)  systemctl suspend ;;
    *Reboot*)   systemctl reboot ;;
    *Shutdown*) systemctl poweroff ;;
esac
