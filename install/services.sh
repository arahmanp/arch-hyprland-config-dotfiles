#!/usr/bin/env bash
# Enable system/user services and configure the SDDM login manager.

enable_services() {
    log_step "Enabling system & user services"

    sudo systemctl enable NetworkManager.service     && log_success "NetworkManager enabled."
    sudo systemctl enable bluetooth.service           && log_success "Bluetooth enabled."

    if is_pkg_installed power-profiles-daemon; then
        sudo systemctl enable power-profiles-daemon.service 2>/dev/null \
            && log_success "power-profiles-daemon enabled."
    fi

    # Global volume/brightness/caps-lock OSD backend.
    if [[ -f /usr/lib/systemd/system/swayosd-libinput-backend.service ]]; then
        sudo systemctl enable swayosd-libinput-backend.service 2>/dev/null \
            && log_success "swayosd-libinput-backend enabled."
    fi

    # PipeWire/WirePlumber are per-user, socket-activated services.
    systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null \
        && log_success "PipeWire user services enabled." \
        || log_info "PipeWire user services will auto-start on first login."

    configure_sddm
}

configure_sddm() {
    log_step "Configuring SDDM (login manager)"

    # --- Install the Catppuccin SDDM theme from upstream releases (non-fatal) ---
    local flavor="mocha" accent="mauve" ver="v1.1.2"
    local theme="catppuccin-${flavor}-${accent}"
    local zip="catppuccin-${flavor}-${accent}-sddm.zip"
    local url="https://github.com/catppuccin/sddm/releases/download/${ver}/${zip}"
    local tmp; tmp="$(mktemp -d)"
    local theme_ok=0

    if has_cmd curl && has_cmd unzip && curl -fsSL "$url" -o "$tmp/$zip" 2>/dev/null; then
        sudo mkdir -p /usr/share/sddm/themes
        if sudo unzip -oq "$tmp/$zip" -d /usr/share/sddm/themes 2>/dev/null \
           && [[ -d "/usr/share/sddm/themes/$theme" ]]; then
            theme_ok=1
            log_success "Installed SDDM theme '$theme'."
        fi
    fi
    rm -rf "$tmp"

    sudo mkdir -p /etc/sddm.conf.d
    if [[ "$theme_ok" == "1" ]]; then
        printf '[Theme]\nCurrent=%s\n' "$theme" | sudo tee /etc/sddm.conf.d/10-theme.conf >/dev/null
    else
        log_warn "Using SDDM's default theme (could not fetch the Catppuccin theme)."
    fi

    # A larger default cursor for HiDPI-friendliness on the greeter.
    printf '[Theme]\nCursorTheme=Bibata-Modern-Classic\nCursorSize=24\n' \
        | sudo tee /etc/sddm.conf.d/20-cursor.conf >/dev/null

    sudo systemctl enable sddm.service && log_success "SDDM enabled (graphical login)."
}
