#!/usr/bin/env bash
# Install official-repo packages (one transaction) then AUR packages (per-pkg).

install_packages() {
    log_step "Installing packages from the official repositories"

    local pac=()
    mapfile -t pac < <(read_pkglist "$REPO_DIR/packages/pacman.txt")
    [[ ${#pac[@]} -gt 0 ]] || die "No packages found in packages/pacman.txt"

    log_info "${#pac[@]} repo packages requested (already-installed ones are skipped)."
    sudo pacman -S --needed --noconfirm "${pac[@]}" \
        || die "pacman failed to install the repo packages."
    log_success "Official repository packages installed."

    # ---- AUR ----
    local aur=()
    mapfile -t aur < <(read_pkglist "$REPO_DIR/packages/aur.txt")

    if [[ -z "${AUR_HELPER:-}" || ${#aur[@]} -eq 0 ]]; then
        log_warn "Skipping AUR packages (no helper or none listed)."
        return
    fi

    log_step "Installing AUR packages with $AUR_HELPER"
    local p
    for p in "${aur[@]}"; do
        if is_pkg_installed "$p"; then
            log_success "$p already installed."
            continue
        fi
        log_info "Building/installing $p …"
        if "$AUR_HELPER" -S --needed --noconfirm "$p"; then
            log_success "Installed $p."
        else
            log_warn "Could not install AUR package '$p' — continuing (a fallback is used where relevant)."
        fi
    done
}
