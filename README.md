# dotfiles

This repo contains my personal dotfiles.

As with any dotfiles, this is always a work in progress.

## Setup

This set of dotfiles uses the git bare method.

Run the following commands:

```console
$ alias dotfiles="/usr/bin/git --git-dir=$HOME/.df/ --work-tree=$HOME"
$ git clone --bare git@github.com:tws4793/dotfiles.git $HOME/.df
$ dotfiles config --local status.showUntrackedFiles no
$ dotfiles checkout
```

## Resources

- https://www.ackama.com/blog/posts/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained
