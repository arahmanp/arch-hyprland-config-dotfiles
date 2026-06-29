# ============================================================================
#  Powerlevel10k — pre-built config (Catppuccin Mocha, lean two-line prompt)
#  Shipped ready-to-use so the `p10k configure` wizard never runs.
#  Re-run `p10k configure` any time to regenerate this file your way.
# ============================================================================

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  autoload -Uz is-at-least && is-at-least 5.1 || return

  # ---- Prompt layout -------------------------------------------------------
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs newline prompt_char)
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status command_execution_time background_jobs
    virtualenv node_version time
  )

  # ---- General / lean style ------------------------------------------------
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always

  # ---- OS icon -------------------------------------------------------------
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND='#cba6f7'

  # ---- Prompt character (❯ / ❮) --------------------------------------------
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#a6e3a1'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#f38ba8'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

  # ---- Directory -----------------------------------------------------------
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='#89b4fa'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#b4befe'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false

  # ---- Git / VCS -----------------------------------------------------------
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#a6e3a1'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#f9e2af'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#94e2d5'
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND='#f38ba8'
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND='#6c7086'

  # ---- Exit status (only on error) -----------------------------------------
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#f38ba8'
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND='#f38ba8'
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false

  # ---- Command execution time ----------------------------------------------
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#fab387'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  # ---- Background jobs -----------------------------------------------------
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='#94e2d5'
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false

  # ---- Language / env segments ---------------------------------------------
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND='#f9e2af'
  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND='#a6e3a1'
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true

  # ---- Clock ---------------------------------------------------------------
  typeset -g POWERLEVEL9K_TIME_FOREGROUND='#6c7086'
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
