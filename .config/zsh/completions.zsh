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
