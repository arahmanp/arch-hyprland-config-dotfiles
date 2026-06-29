#!/usr/bin/env bash
# Keybinding cheat-sheet shown in fuzzel. Bound to SUPER+F1.
set -euo pipefail

cat <<'EOF' | fuzzel --dmenu --prompt 'Keybinds  ' --width 64 --lines 30 >/dev/null || true
─── Applications ───────────────────────────────────────────
SUPER + Return            Terminal (kitty)
SUPER + E                 File manager (Thunar)
SUPER + B                 Browser (Firefox)
SUPER + D  /  SUPER+Space  App launcher (fuzzel)
SUPER + V                 Clipboard history
SUPER + N                 Notification panel
SUPER + L                 Lock screen
SUPER + SHIFT + E         Power menu
SUPER + SHIFT + W         Change wallpaper
SUPER + F1                This cheat-sheet
─── Windows ────────────────────────────────────────────────
SUPER + Q                 Close window
SUPER + F                 Fullscreen
SUPER + SHIFT + F         Maximize (keep bar)
SUPER + SHIFT + Space     Toggle floating
SUPER + C                 Center window
SUPER + P                 Pseudo-tile
SUPER + J                 Toggle split direction
SUPER + G                 Toggle window group
SUPER + SHIFT + R         Reload Hyprland config
─── Focus / Move / Resize ──────────────────────────────────
SUPER + Arrows            Move focus
SUPER + SHIFT + Arrows    Move window
SUPER + CTRL + Arrows     Resize window
SUPER + drag (mouse)      Move / resize floating
─── Workspaces ─────────────────────────────────────────────
SUPER + 1..0              Go to workspace 1..10
SUPER + SHIFT + 1..0      Send window to workspace
SUPER + Scroll / , .      Cycle workspaces
SUPER + S                 Toggle scratchpad
SUPER + SHIFT + S         Send window to scratchpad
─── Screenshots ────────────────────────────────────────────
Print                     Region -> save + clipboard
SHIFT + Print             Region -> annotate (swappy)
SUPER + Print             Full screen -> save + clipboard
─── Media / Volume / Brightness ────────────────────────────
Volume / Brightness keys  Adjust with on-screen display
SUPER + = / -             Volume up / down
Play/Pause/Next/Prev keys Media control
EOF
