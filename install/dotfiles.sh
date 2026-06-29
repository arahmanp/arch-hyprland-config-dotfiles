#!/usr/bin/env bash
# Deploy config files to ~/.config (with backups) and wire up the shell.

deploy_dotfiles() {
    log_step "Deploying configuration to ~/.config"
    mkdir -p "$HOME/.config"

    local src="$REPO_DIR/config" entry name dest
    [[ -d "$src" ]] || die "config/ directory not found in repo."

    for entry in "$src"/* "$src"/.[!.]*; do
        [[ -e "$entry" ]] || continue
        name="$(basename "$entry")"
        dest="$HOME/.config/$name"
        backup_if_exists "$dest"
        cp -aT "$entry" "$dest" 2>/dev/null || cp -a "$entry" "$HOME/.config/"
        log_success "Installed ~/.config/$name"
    done

    # Make all helper scripts executable.
    if [[ -d "$HOME/.config/hypr/scripts" ]]; then
        chmod +x "$HOME/.config/hypr/scripts/"*.sh 2>/dev/null || true
    fi

    install_bashrc_block

    # Create XDG user dirs (Downloads, Pictures, Documents, …).
    if has_cmd xdg-user-dirs-update; then xdg-user-dirs-update 2>/dev/null || true; fi
    mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Pictures/Wallpapers"

    log_success "Configuration deployed."
}

install_bashrc_block() {
    local rc="$HOME/.bashrc"
    local marker="# >>> hyprland-config shell setup >>>"
    touch "$rc"
    if grep -qF "$marker" "$rc" 2>/dev/null; then
        log_info "Shell setup already present in ~/.bashrc (left unchanged)."
        return
    fi
    log_info "Adding shell enhancements to ~/.bashrc"
    cat >> "$rc" <<'EOF'

# >>> hyprland-config shell setup >>>
# Added by the Hyprland installer. Safe to edit; the installer won't duplicate it.
case $- in
  *i*)
    command -v starship >/dev/null && eval "$(starship init bash)"
    command -v zoxide   >/dev/null && eval "$(zoxide init bash)"
    [ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
    [ -f /usr/share/fzf/completion.bash ]   && source /usr/share/fzf/completion.bash
    if command -v eza >/dev/null; then
      alias ls='eza --group-directories-first --icons'
      alias ll='eza -lah --group-directories-first --icons'
      alias la='eza -a   --group-directories-first --icons'
      alias lt='eza --tree --level=2 --icons'
    fi
    command -v bat >/dev/null && alias cat='bat --paging=never'
    alias grep='grep --color=auto'
    alias ..='cd ..'
    alias ...='cd ../..'
    alias update='sudo pacman -Syu'
    alias cleanup='sudo pacman -Rns $(pacman -Qtdq 2>/dev/null) 2>/dev/null; paccache -r 2>/dev/null'
  ;;
esac
# <<< hyprland-config shell setup <<<
EOF
    log_success "Shell enhancements added to ~/.bashrc"
}
