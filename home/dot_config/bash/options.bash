# History (mirrors ~/.config/zsh/options.zsh)
HISTFILE="$HOME/.bash_history"
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignorespace:ignoredups
HISTIGNORE='pwd:ls:cd'
shopt -s histappend checkwinsize
shopt -s globstar 2>/dev/null # bash 4+
