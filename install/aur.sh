#!/usr/bin/env bash
# Ensure an AUR helper exists (installs paru-bin if not).

ensure_aur_helper() {
    log_step "Ensuring an AUR helper is available"

    if has_cmd paru; then AUR_HELPER=paru; log_success "Found paru."; return; fi
    if has_cmd yay;  then AUR_HELPER=yay;  log_success "Found yay.";  return; fi

    if [[ "${NO_AUR:-0}" == "1" ]]; then
        AUR_HELPER=""
        log_warn "No AUR helper and --no-aur given: AUR packages will be skipped."
        return
    fi

    log_info "No AUR helper found — installing 'paru' (paru-bin) from the AUR…"
    sudo pacman -S --needed --noconfirm base-devel git \
        || die "Failed to install base-devel/git (needed to build AUR packages)."

    local tmp
    tmp="$(mktemp -d)"
    git clone --depth=1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin" \
        || die "Failed to clone paru-bin from the AUR."
    ( cd "$tmp/paru-bin" && makepkg -si --noconfirm ) \
        || die "Failed to build/install paru."
    rm -rf "$tmp"

    has_cmd paru || die "paru installation did not complete successfully."
    AUR_HELPER=paru
    log_success "Installed paru."
}
