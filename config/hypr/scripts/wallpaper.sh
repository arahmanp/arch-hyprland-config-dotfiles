#!/usr/bin/env bash
# Apply a wallpaper on every monitor via hyprpaper IPC.
#   wallpaper.sh             -> random from ~/Pictures/Wallpapers
#   wallpaper.sh random      -> random
#   wallpaper.sh /path/img   -> that specific image
set -euo pipefail

WALL_DIR="${WALL_DIR:-$HOME/Pictures/Wallpapers}"
arg="${1:-random}"

note() { command -v notify-send >/dev/null 2>&1 && notify-send -i preferences-desktop-wallpaper "Wallpaper" "$1" || true; }

pick_random() {
    find "$WALL_DIR" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
        2>/dev/null | shuf -n1
}

if [[ "$arg" == "random" || -z "$arg" ]]; then
    WALL="$(pick_random || true)"
else
    WALL="$arg"
fi

if [[ -z "${WALL:-}" || ! -f "$WALL" ]]; then
    note "No wallpaper found in $WALL_DIR"
    exit 0
fi

# Make sure hyprpaper is up (start it and wait for the IPC socket).
if ! hyprctl hyprpaper listloaded >/dev/null 2>&1; then
    hyprpaper >/dev/null 2>&1 &
    for _ in $(seq 1 50); do
        hyprctl hyprpaper listloaded >/dev/null 2>&1 && break
        sleep 0.1
    done
fi

hyprctl hyprpaper preload "$WALL" >/dev/null 2>&1 || true

# Apply to all monitors (empty target = all), then per-monitor as a fallback.
hyprctl hyprpaper wallpaper ",$WALL" >/dev/null 2>&1 || true
while read -r mon; do
    [[ -n "$mon" ]] && hyprctl hyprpaper wallpaper "$mon,$WALL" >/dev/null 2>&1 || true
done < <(hyprctl monitors 2>/dev/null | awk '/^Monitor/{print $2}')

# Free memory used by previously-loaded images.
hyprctl hyprpaper unload unused >/dev/null 2>&1 || true
