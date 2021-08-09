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
prompt_detailed() {
    local items=(
        '%*'
        '%F{%(!.red.green)}%n%f'
        '%~'
        \$vcs_info_msg_0_
        '\n%F{%(?.green.red)}>%f'
    )
    echo "%B%F{8}$items %f%b"
}
PROMPT=$(prompt_detailed)

setopt hist_ignore_space

# Commands
ALIAS_FILE="$HOME/.aliases"
[ -f $ALIAS_FILE ] && source $ALIAS_FILE

export PATH="/usr/local/opt/openjdk/bin:$PATH"
[ -f "/Users/tws/.ghcup/env" ] && source "/Users/tws/.ghcup/env" # ghcup-env

# Completions
autoload -Uz compinit
[ "$(whoami)" = "tws" ] && compinit -i || compinit
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1
_comp_options+=(globdots)
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=606060"
