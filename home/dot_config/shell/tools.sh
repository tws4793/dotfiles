# Tool integrations for interactive bash and zsh. Source after completion is set up.

if [ -n "${ZSH_VERSION-}" ]; then
    _shell=zsh
elif [ -n "${BASH_VERSION-}" ]; then
    _shell=bash
else
    return 0
fi

# fnm (Fast Node Manager); --use-on-cd switches Node when entering a dir with .nvmrc/.node-version
if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd --version-file-strategy=recursive --resolve-engines --shell "$_shell")"
fi

if command -v uv >/dev/null 2>&1; then
    eval "$(uv generate-shell-completion "$_shell")"
fi

if command -v pm2 >/dev/null 2>&1; then
    . "$HOME/.config/shell/pm2.sh"
fi

unset _shell
