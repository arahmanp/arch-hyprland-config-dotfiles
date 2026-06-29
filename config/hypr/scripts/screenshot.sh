#!/usr/bin/env bash
# Screenshots via grim + slurp (+ swappy for annotation).
#   screenshot.sh region   -> select a region, save + copy to clipboard
#   screenshot.sh full     -> whole screen, save + copy
#   screenshot.sh swappy   -> select a region and open the annotation editor
set -euo pipefail

mode="${1:-region}"
dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$dir"
file="$dir/shot_$(date +'%Y-%m-%d_%H-%M-%S').png"

note() { command -v notify-send >/dev/null 2>&1 && notify-send -i "$2" "Screenshot" "$1" || true; }

case "$mode" in
    region)
        geom="$(slurp 2>/dev/null)" || exit 0      # cancelled with Esc
        grim -g "$geom" "$file"
        wl-copy < "$file"
        note "Region saved & copied\n$file" "$file"
        ;;
    full|screen)
        grim "$file"
        wl-copy < "$file"
        note "Full screen saved & copied\n$file" "$file"
        ;;
    swappy)
        geom="$(slurp 2>/dev/null)" || exit 0
        grim -g "$geom" - | swappy -f -            # swappy handles save/copy
        ;;
    *)
        echo "usage: screenshot.sh [region|full|swappy]" >&2
        exit 2
        ;;
esac
