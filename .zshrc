# Theme
# source $HOME/.config/zsh/agnoster-zsh-theme/agnoster.zsh-theme
# setopt prompt_subst
#
# Git
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
zstyle ':vcs_info:git:*' formats '%b'

# Prompt
PROMPT='%(?.%F{green}有.%F{red}冇%?)%f %B%F{240}%~%f%b %# '
RPROMPT='%D{%d/%m/%y %H:%M:%S}'

# Alias
ALIAS_FILE="$HOME/.aliases"
[ -f $ALIAS_FILE ] && source $ALIAS_FILE

# History
setopt HIST_IGNORE_SPACE

# Completions
autoload -Uz compinit
if [ "$(whoami)" = "tws" ]; then
    compinit -i
else
    compinit
fi
setopt COMPLETE_ALIASES
zstyle ':completion::complete:*' gain-privileges 1
