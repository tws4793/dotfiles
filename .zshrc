# Git
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )

setopt prompt_subst
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' formats '%b:%8.8i'

# Prompt
custom_prompt() {
    local current_time='%* '
    local error_code='%(?..%F{red}%?%f )'
    local pointer='%F{%(?.green.red)}>%f '
    local current_info='%~ '
    #local current_info='%n@%m %~ '
    local new_line=$'\n'

    echo "%B%F{8}$current_time$current_info\$vcs_info_msg_0_$new_line$pointer%f%b"
}
PROMPT=$(custom_prompt)

setopt hist_ignore_space

# Commands
ALIAS_FILE="$HOME/.aliases"
[ -f $ALIAS_FILE ] && source $ALIAS_FILE

export PATH="/usr/local/opt/openjdk/bin:$PATH"
[ -f "/Users/tws/.ghcup/env" ] && source "/Users/tws/.ghcup/env" # ghcup-env

# Completions
autoload -Uz compinit
[ "$(whoami)" = "tws" ] && compinit -i || compinit
zstyle ':completion::complete:*' gain-privileges 1
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=606060"
