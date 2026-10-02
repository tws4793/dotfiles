# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
HISTORY_IGNORE='(pwd|ls|cd)'
setopt hist_ignore_space hist_ignore_dups inc_append_history extended_history

# Emacs keys at the prompt, as in bash. (zsh would otherwise pick vi keys whenever
# $EDITOR contains "vi", which differs between a fresh terminal and tmux.)
bindkey -e
bindkey '^R' history-incremental-search-backward

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic
