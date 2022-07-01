#!/bin/sh/

alias dotfiles="/usr/bin/git --git-dir=$HOME/.df/ --work-tree=$HOME"
git clone --bare git@github.com:tws4793/dotfiles.git $HOME/.df
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout
