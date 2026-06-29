#!/usr/bin/env bash
# ============================================================================
#  Shared helpers for the Hyprland installer (sourced by install.sh).
# ============================================================================

# ---- colours ----------------------------------------------------------------
if [[ -t 1 ]]; then
    C_RESET=$'\e[0m'; C_BOLD=$'\e[1m'; C_DIM=$'\e[2m'
    C_RED=$'\e[31m'; C_GREEN=$'\e[32m'; C_YELLOW=$'\e[33m'
    C_BLUE=$'\e[34m'; C_MAGENTA=$'\e[35m'; C_CYAN=$'\e[36m'
else
    C_RESET=""; C_BOLD=""; C_DIM=""; C_RED=""; C_GREEN=""
    C_YELLOW=""; C_BLUE=""; C_MAGENTA=""; C_CYAN=""
fi

log_step()    { printf '\n%s%s==>%s %s%s%s\n' "$C_BOLD" "$C_MAGENTA" "$C_RESET" "$C_BOLD" "$*" "$C_RESET"; }
log_info()    { printf '   %s::%s %s\n'  "$C_BLUE"   "$C_RESET" "$*"; }
log_success() { printf '   %sok%s %s\n'  "$C_GREEN"  "$C_RESET" "$*"; }
log_warn()    { printf '   %s!!%s %s\n'  "$C_YELLOW" "$C_RESET" "$*" >&2; }
log_error()   { printf '   %sxx%s %s\n'  "$C_RED"    "$C_RESET" "$*" >&2; }
die()         { log_error "$*"; exit 1; }

# ---- prompts ----------------------------------------------------------------
confirm() {
    # confirm "Question?"  ->  returns 0 (yes) / 1 (no)
    if [[ "${ASSUME_YES:-0}" == "1" ]]; then return 0; fi
    local prompt="${1:-Continue?}" reply
    read -r -p "$(printf '%s?%s %s [y/N] ' "$C_YELLOW" "$C_RESET" "$prompt")" reply
    [[ "$reply" =~ ^([yY]|[yY][eE][sS])$ ]]
}

# ---- small utilities --------------------------------------------------------
has_cmd()         { command -v "$1" &>/dev/null; }
is_pkg_installed(){ pacman -Qq "$1" &>/dev/null; }

# Print package names from a list file, ignoring comments and blank lines.
read_pkglist() {
    [[ -f "$1" ]] || return 0
    sed -e 's/#.*//' -e 's/[[:space:]]\+$//' "$1" | awk 'NF'
}

# Back up a path into $BACKUP_DIR (timestamped) before we overwrite it.
backup_if_exists() {
    local target="$1"
    [[ -e "$target" || -L "$target" ]] || return 0
    mkdir -p "$BACKUP_DIR"
    log_warn "Backing up $target -> $BACKUP_DIR/"
    mv -f "$target" "$BACKUP_DIR/" 2>/dev/null \
        || cp -a "$target" "$BACKUP_DIR/" 2>/dev/null || true
}

# Find a theme/icon directory by case-insensitive glob in the usual locations.
find_theme_dir() {
    # find_theme_dir <pattern> <subdir: themes|icons>
    local pattern="$1" sub="$2"
    find "$HOME/.local/share/$sub" "$HOME/.$sub" "/usr/share/$sub" \
        -maxdepth 1 -type d -iname "$pattern" 2>/dev/null | head -n1
}
