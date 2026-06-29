#!/usr/bin/env bash
# Pre-flight environment checks.

preflight() {
    log_step "Running pre-flight checks"

    [[ "$(uname -s)" == "Linux" ]] || die "This installer must run on Linux (Arch)."
    has_cmd pacman || die "pacman not found. This installer is for Arch Linux / Arch-based distros."

    if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
        die "Do not run this as root. Run as your normal user — it uses sudo only when needed."
    fi
    has_cmd sudo || die "sudo is required. Install it and add your user to the 'wheel' group, then re-run."

    log_info "Requesting sudo (you may be prompted for your password)…"
    sudo -v || die "Could not obtain sudo privileges."

    log_info "Checking internet connectivity…"
    if ! ping -c1 -W3 archlinux.org &>/dev/null \
       && ! curl -fsS --max-time 6 https://archlinux.org >/dev/null 2>&1; then
        die "No internet connection. Connect first (try 'nmtui' or 'iwctl') and re-run."
    fi

    # Friendly heads-up if a different compositor/DE is already in use.
    if [[ -d "$HOME/.config/hypr" ]]; then
        log_warn "An existing ~/.config/hypr was found — it will be backed up, not deleted."
    fi

    log_success "Pre-flight checks passed."
}
