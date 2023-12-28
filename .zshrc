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

# Completions
autoload -Uz compinit
[ "$(whoami)" = "tws" ] && compinit -i || compinit
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1
_comp_options+=(globdots)
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=606060"

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

fpath=(~/.zsh/completion $fpath)

###-begin-pm2-completion-###
### credits to npm for the completion file model
#
# Installation: pm2 completion >> ~/.bashrc  (or ~/.zshrc)
#

COMP_WORDBREAKS=${COMP_WORDBREAKS/=/}
COMP_WORDBREAKS=${COMP_WORDBREAKS/@/}
export COMP_WORDBREAKS

if type complete &>/dev/null; then
  _pm2_completion () {
    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$COMP_CWORD" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           pm2 completion -- "${COMP_WORDS[@]}" \
                           2>/dev/null)) || return $?
    IFS="$si"
  }
  complete -o default -F _pm2_completion pm2
elif type compctl &>/dev/null; then
  _pm2_completion () {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                       COMP_LINE="$line" \
                       COMP_POINT="$point" \
                       pm2 completion -- "${words[@]}" \
                       2>/dev/null)) || return $?
    IFS="$si"
  }
  compctl -K _pm2_completion + -f + pm2
fi
###-end-pm2-completion-###

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Python Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Commands
ALIAS_FILE="$HOME/.aliases"
[ -f $ALIAS_FILE ] && source $ALIAS_FILE
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"
[ -f "/opt/ros/humble/setup.zsh" ] && source /opt/ros/humble/setup.zsh

export PATH="$HOME/.bin:$HOME/.local/bin:/usr/local/sbin:$PATH"
[ -x "$(command yarn global bin)" ] && export PATH="$(yarn global bin):$PATH"
export EDITOR=vi
export HISTIGNORE="pwd:ls:cd"
export JAVA_HOME="/usr/lib/jvm/default-java"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"

bindkey '^R' history-incremental-search-backward
