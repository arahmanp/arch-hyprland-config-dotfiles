#!/usr/bin/env bash
# Install oh-my-zsh + powerlevel10k, deploy the zsh config, and make zsh default.

setup_shell() {
    log_step "Setting up Zsh (oh-my-zsh + powerlevel10k)"

    if ! has_cmd zsh; then
        log_warn "zsh is not installed; skipping shell setup."
        return
    fi

    # --- Deploy ~/.zshrc and ~/.p10k.zsh (with backups) ---
    local home_src="$REPO_DIR/home" f dest
    if [[ -d "$home_src" ]]; then
        shopt -s dotglob nullglob
        for f in "$home_src"/*; do
            [[ -f "$f" ]] || continue
            dest="$HOME/$(basename "$f")"
            backup_if_exists "$dest"
            cp -a "$f" "$dest"
            log_success "Installed ~/$(basename "$f")"
        done
        shopt -u dotglob nullglob
    fi

    # --- oh-my-zsh (framework) ---
    local ZSH_DIR="$HOME/.oh-my-zsh"
    if [[ -d "$ZSH_DIR" ]]; then
        log_info "oh-my-zsh already present."
    else
        log_info "Cloning oh-my-zsh…"
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR" \
            && log_success "Installed oh-my-zsh." \
            || log_warn "Could not clone oh-my-zsh — zsh will use the built-in fallback in ~/.zshrc."
    fi

    # --- powerlevel10k theme + plugin symlinks (only if oh-my-zsh exists) ---
    if [[ -d "$ZSH_DIR" ]]; then
        mkdir -p "$ZSH_DIR/custom/themes" "$ZSH_DIR/custom/plugins"

        local p10k_dir="$ZSH_DIR/custom/themes/powerlevel10k"
        if [[ -d "$p10k_dir" ]]; then
            log_info "powerlevel10k already present."
        else
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir" \
                && log_success "Installed powerlevel10k." \
                || log_warn "Could not clone powerlevel10k — a packaged prompt is used as fallback."
        fi

        # Use the pacman-installed plugins (auto-updated by pacman) inside oh-my-zsh.
        _link_omz_plugin zsh-autosuggestions    /usr/share/zsh/plugins/zsh-autosuggestions
        _link_omz_plugin zsh-syntax-highlighting /usr/share/zsh/plugins/zsh-syntax-highlighting
    fi

    # --- Make zsh the login shell ---
    local zsh_path user current
    zsh_path="$(command -v zsh)"
    user="${USER:-$(id -un)}"
    current="$(getent passwd "$user" 2>/dev/null | cut -d: -f7 || true)"
    if [[ "$current" == "$zsh_path" ]]; then
        log_success "zsh is already your default shell."
    elif sudo chsh -s "$zsh_path" "$user" 2>/dev/null; then
        log_success "Default shell changed to zsh (takes effect at next login)."
    else
        log_warn "Could not change the default shell automatically. Run:  chsh -s $zsh_path"
    fi
}

_link_omz_plugin() {
    local name="$1" target="$2"
    local link="$HOME/.oh-my-zsh/custom/plugins/$name"
    [[ -d "$target" ]] || { log_warn "$name not found at $target (skipping)."; return; }
    [[ -e "$link" || -L "$link" ]] && return 0
    ln -s "$target" "$link" && log_success "Linked $name into oh-my-zsh."
}
