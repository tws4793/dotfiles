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
        #'%*'
        '%F{%(!.red.green)}%n%f'
        '%F{8}%~%f'
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
GHCUP="$HOME/.ghcup/env"
[ -f $GHCUP ] && source $GHCUP
[ -f "/opt/ros/humble/setup.zsh" ] && source /opt/ros/humble/setup.zsh

export PATH="$HOME/.bin:$HOME/.local/bin:/usr/local/sbin:$PATH"
export EDITOR=vi
export HISTIGNORE="pwd:ls:cd"
export JAVA_HOME="/usr/lib/jvm/default-java"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"

bindkey '^R' history-incremental-search-backward
