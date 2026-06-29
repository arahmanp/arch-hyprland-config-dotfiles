# ============================================================================
#  ~/.zshrc  ·  oh-my-zsh + powerlevel10k  (Hyprland desktop)
# ============================================================================

# ---- Powerlevel10k instant prompt (must stay near the top) -----------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---- History ----------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS SHARE_HISTORY INC_APPEND_HISTORY
setopt AUTO_CD INTERACTIVE_COMMENTS PROMPT_SUBST

# ---- oh-my-zsh --------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle ':omz:update' mode auto            # keep oh-my-zsh updated automatically
DISABLE_MAGIC_FUNCTIONS=true              # avoids paste slowdowns
plugins=(git sudo archlinux zsh-autosuggestions zsh-syntax-highlighting)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  # --- Fallback when oh-my-zsh isn't installed: load packaged bits directly ---
  autoload -Uz compinit && compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
  for _f in \
      /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
      /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme \
      /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
    [[ -r "$_f" ]] && source "$_f"
  done
  unset _f
fi

# Extra completions (from the zsh-completions package)
[[ -d /usr/share/zsh/plugins/zsh-completions/src ]] && fpath+=(/usr/share/zsh/plugins/zsh-completions/src)

# ---- CLI tools --------------------------------------------------------------
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
[[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -r /usr/share/fzf/completion.zsh ]]   && source /usr/share/fzf/completion.zsh

# ---- Aliases ----------------------------------------------------------------
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

# ---- Powerlevel10k prompt configuration (pre-built — no wizard) -------------
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
