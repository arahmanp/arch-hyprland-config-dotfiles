#!/usr/bin/env bash
# ============================================================================
#   ARCH  +  HYPRLAND   —   automated desktop installer
#
#   One-shot Hyprland desktop installer for Arch Linux (Intel iGPU edition).
#
#   Installs and fully configures a complete, themed Hyprland desktop:
#   compositor, login manager, bar, launcher, notifications, lock/idle,
#   audio, bluetooth, screenshots, clipboard, theming and everyday apps.
#
#   After it finishes: reboot and log in — nothing else to configure.
#
#   Usage:  ./install.sh [options]
#     -y, --yes          Assume "yes" to prompts (unattended)
#         --no-aur       Skip AUR packages / AUR helper
#         --skip-update  Skip the initial full system upgrade
#         --skip-mirrors Skip refreshing pacman mirrors with reflector
#     -h, --help         Show this help
# ============================================================================
set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Self-heal Windows (CRLF) line endings on all repo text files ------------
# (Harmless on already-LF files; makes the repo safe to run if copied via Windows.)
if command -v sed >/dev/null 2>&1; then
    find "$REPO_DIR" -type f \
        \( -name '*.sh' -o -name '*.conf' -o -name '*.ini' -o -name '*.css' \
        -o -name '*.json' -o -name '*.jsonc' -o -name '*.rasi' -o -name '*.toml' \
        -o -name '*.kvconfig' -o -name '*.txt' -o -name 'layout' \
        -o -name '*.zsh' -o -name '.zshrc' -o -name '.zshenv' -o -name '.zprofile' \) \
        -print0 2>/dev/null | xargs -0 -r sed -i 's/\r$//' 2>/dev/null || true
fi

# --- Defaults / flags --------------------------------------------------------
export ASSUME_YES=0
NO_AUR=0
SKIP_UPDATE=0
SKIP_MIRRORS=0
AUR_HELPER=""
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
export NO_AUR AUR_HELPER BACKUP_DIR REPO_DIR

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)       ASSUME_YES=1 ;;
        --no-aur)       NO_AUR=1 ;;
        --skip-update)  SKIP_UPDATE=1 ;;
        --skip-mirrors) SKIP_MIRRORS=1 ;;
        -h|--help)      sed -n '3,18p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "Unknown option: $1 (try --help)"; exit 2 ;;
    esac
    shift
done

# --- Load helpers and step modules ------------------------------------------
# shellcheck source=lib/common.sh
source "$REPO_DIR/lib/common.sh"
for mod in preflight aur packages services dotfiles theming wallpapers shell; do
    # shellcheck source=/dev/null
    source "$REPO_DIR/install/$mod.sh"
done

# --- Pretty error trap -------------------------------------------------------
on_error() {
    local ec=$?
    log_error "Aborted (exit $ec) on line ${BASH_LINENO[0]}: ${BASH_COMMAND}"
    log_warn  "Anything backed up is in: $BACKUP_DIR"
    exit "$ec"
}
trap on_error ERR

# --- Keep sudo alive for the whole run --------------------------------------
keep_sudo_alive() {
    sudo -v
    ( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &
    SUDO_KEEPALIVE_PID=$!
}

banner() {
    printf '%s' "$C_MAGENTA$C_BOLD"
    cat <<'EOF'

   ┌──────────────────────────────────────────────────────────┐
   │   Hyprland desktop installer  ·  Arch Linux · Intel iGPU   │
   └──────────────────────────────────────────────────────────┘
EOF
    printf '%s\n' "$C_RESET"
}

main() {
    banner
    preflight

    log_info "This will install ~$(read_pkglist "$REPO_DIR/packages/pacman.txt" | wc -l) repo packages"
    log_info "and deploy a full Hyprland configuration to ~/.config."
    log_info "Existing configs are backed up to: $BACKUP_DIR"
    if ! confirm "Proceed with installation"; then
        die "Cancelled by user."
    fi

    keep_sudo_alive

    if [[ "$SKIP_MIRRORS" != "1" ]]; then refresh_mirrors; fi
    if [[ "$SKIP_UPDATE"  != "1" ]]; then update_system;  fi

    ensure_aur_helper
    install_packages
    generate_wallpapers
    deploy_dotfiles
    apply_theming
    setup_shell
    enable_services

    # Stop the sudo keepalive.
    [[ -n "${SUDO_KEEPALIVE_PID:-}" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true

    print_done
}

refresh_mirrors() {
    log_step "Refreshing pacman mirrorlist (reflector)"
    if has_cmd reflector; then
        sudo reflector --latest 20 --protocol https --sort rate \
            --save /etc/pacman.d/mirrorlist 2>/dev/null \
            && log_success "Mirrorlist updated." \
            || log_warn "reflector failed; keeping current mirrorlist."
    else
        log_info "reflector not installed yet; skipping (it will be installed later)."
    fi
}

update_system() {
    log_step "Updating the system (pacman -Syu)"
    sudo pacman -Syu --noconfirm
    log_success "System up to date."
}

print_done() {
    cat <<EOF

$C_GREEN$C_BOLD   ✔ All done!$C_RESET

   Your complete Hyprland desktop is installed and configured.

   $C_BOLD Next steps $C_RESET
     1. Reboot:           $C_CYAN sudo reboot $C_RESET
     2. At the SDDM login screen, pick the $C_BOLD Hyprland$C_RESET session
        (top-left selector) and log in.
     3. Press $C_BOLD SUPER + F1$C_RESET any time for the keybinding cheat-sheet.

   Your shell is now $C_BOLD zsh + oh-my-zsh + powerlevel10k$C_RESET (pre-configured —
   no wizard). It activates at your next login; the prompt is ready to go.

   $C_BOLD Handy first keys $C_RESET
     SUPER + Return ........ terminal          SUPER + D ......... app launcher
     SUPER + E ............. file manager       SUPER + B ......... browser
     SUPER + Q ............. close window       SUPER + L ......... lock screen
     SUPER + SHIFT + E ..... power menu         Print ............. screenshot

   Backups of any previous config: $C_CYAN$BACKUP_DIR$C_RESET
   Everything lives in ~/.config — tweak freely. Enjoy!

EOF
}

main "$@"
