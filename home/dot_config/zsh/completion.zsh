# fpath must be complete before compinit runs
fpath=(~/.zsh/completion $fpath)
[ -n "$HOMEBREW_PREFIX" ] && fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)

autoload -Uz compinit
compinit -i # -i: skip (don't prompt about) group-writable dirs, e.g. Homebrew's
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1
_comp_options+=(globdots)
