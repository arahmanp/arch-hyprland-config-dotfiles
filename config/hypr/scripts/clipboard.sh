#!/usr/bin/env bash
# Clipboard history picker (cliphist + fuzzel). Bound to SUPER+V.
set -euo pipefail

sel="$(cliphist list | fuzzel --dmenu --prompt 'Clipboard  ' --width 70 --lines 12)" || exit 0
[[ -n "$sel" ]] || exit 0
printf '%s' "$sel" | cliphist decode | wl-copy
