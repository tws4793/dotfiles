# bash-completion (needs bash 4.2+)
if [ "${BASH_VERSINFO[0]}" -ge 4 ] && ! shopt -oq posix; then
    for f in \
        /usr/share/bash-completion/bash_completion \
        /etc/bash_completion \
        "${HOMEBREW_PREFIX:-/nonexistent}/etc/profile.d/bash_completion.sh"; do
        if [ -r "$f" ]; then
            . "$f"
            break
        fi
    done
    unset f
fi

# Closest to zsh's menu completion: list matches on the first Tab, include dotfiles
bind 'set show-all-if-ambiguous on'
bind 'set match-hidden-files on'
bind 'set colored-stats on'
