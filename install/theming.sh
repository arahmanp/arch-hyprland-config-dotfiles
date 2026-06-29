#!/usr/bin/env bash
# Apply GTK / icon / cursor / Qt theming with graceful fallbacks.

apply_theming() {
    log_step "Applying themes (GTK · icons · cursor · Qt)"

    # ---- GTK theme: Catppuccin Mocha if present, else Adwaita-dark ----
    local gtk_theme="Adwaita-dark" found
    found="$(find_theme_dir '*catppuccin*mocha*' themes)"
    [[ -n "$found" ]] && gtk_theme="$(basename "$found")"

    # ---- Cursor: Bibata if present, else Adwaita ----
    local cursor_theme="Bibata-Modern-Classic"
    if [[ -z "$(find_theme_dir 'Bibata-Modern-Classic' icons)" ]]; then
        cursor_theme="Adwaita"
        log_warn "Bibata cursor not found; using Adwaita cursor."
    fi

    local icon_theme="Papirus-Dark"
    [[ -n "$(find_theme_dir 'Papirus-Dark' icons)" ]] || icon_theme="Adwaita"
    local cursor_size=24
    local ui_font="Noto Sans 11"

    # ---- GTK 3 & GTK 4 settings.ini ----
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    local gtk_ini
    gtk_ini="$(cat <<EOF
[Settings]
gtk-theme-name=$gtk_theme
gtk-icon-theme-name=$icon_theme
gtk-cursor-theme-name=$cursor_theme
gtk-cursor-theme-size=$cursor_size
gtk-font-name=$ui_font
gtk-application-prefer-dark-theme=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
EOF
)"
    printf '%s\n' "$gtk_ini" > "$HOME/.config/gtk-3.0/settings.ini"
    printf '%s\n' "$gtk_ini" > "$HOME/.config/gtk-4.0/settings.ini"

    # ---- Default XDG cursor (works for XWayland & most toolkits) ----
    mkdir -p "$HOME/.icons/default" "$HOME/.local/share/icons/default"
    printf '[Icon Theme]\nInherits=%s\n' "$cursor_theme" > "$HOME/.icons/default/index.theme"
    cp -f "$HOME/.icons/default/index.theme" "$HOME/.local/share/icons/default/index.theme"

    # ---- gsettings (libadwaita / GNOME apps honour these) ----
    if has_cmd gsettings; then
        local gi=org.gnome.desktop.interface
        gsettings set $gi color-scheme 'prefer-dark'      2>/dev/null || true
        gsettings set $gi gtk-theme    "$gtk_theme"        2>/dev/null || true
        gsettings set $gi icon-theme   "$icon_theme"       2>/dev/null || true
        gsettings set $gi cursor-theme "$cursor_theme"     2>/dev/null || true
        gsettings set $gi cursor-size  "$cursor_size"      2>/dev/null || true
        gsettings set $gi font-name    "$ui_font"          2>/dev/null || true
        gsettings set $gi monospace-font-name 'JetBrainsMono Nerd Font 11' 2>/dev/null || true
    fi

    # ---- Default applications ----
    if has_cmd xdg-settings; then
        xdg-settings set default-web-browser firefox.desktop 2>/dev/null || true
    fi
    if has_cmd xdg-mime; then
        xdg-mime default thunar.desktop inode/directory 2>/dev/null || true
    fi

    log_success "Themes applied — GTK: $gtk_theme · icons: $icon_theme · cursor: $cursor_theme"
}
