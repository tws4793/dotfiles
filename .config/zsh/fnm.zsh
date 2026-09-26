# fnm (Fast Node Manager): replaces nvm.
# --use-on-cd switches Node automatically when entering a dir with .nvmrc/.node-version
# (replaces the old load-nvmrc chpwd hook).
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --version-file-strategy=recursive --resolve-engines --shell zsh)"
fi

[ -x "$(command -v yarn)" ] && export PATH="$(yarn global bin):$PATH"
