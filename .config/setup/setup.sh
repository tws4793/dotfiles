#!/usr/bin/env bash
# Bootstrap dotfiles (bare repo in ~/.df) on a fresh machine. Safe to re-run.
# Usage: setup.sh [--nopasswd]   (flag is passed to install_ubuntu.sh on Linux)
set -euo pipefail

DF_DIR="$HOME/.df"
DF_HTTPS="https://github.com/tws4793/dotfiles.git"
DF_SSH="git@github.com:tws4793/dotfiles.git"

dotfiles() { git --git-dir="$DF_DIR" --work-tree="$HOME" "$@"; }

# macOS: git ships with the Xcode Command Line Tools
if [[ "$(uname -s)" == "Darwin" ]] && ! xcode-select -p >/dev/null 2>&1; then
    echo "Installing Xcode Command Line Tools; re-run this script once it finishes."
    xcode-select --install
    exit 1
fi

# Ubuntu: git isn't always preinstalled
if [[ "$(uname -s)" == "Linux" ]] && ! command -v git >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y git
fi

# Clone over HTTPS (no SSH key needed yet), then switch remote to SSH for pushing
if [[ ! -d "$DF_DIR" ]]; then
    git clone --bare "$DF_HTTPS" "$DF_DIR"
    dotfiles remote set-url origin "$DF_SSH"
fi
dotfiles config --local status.showUntrackedFiles no

# Back up any existing files that would block checkout
if ! dotfiles checkout 2>/dev/null; then
    backup="$HOME/.df-backup/$(date +%Y%m%d-%H%M%S)"
    echo "Backing up conflicting files to $backup"
    dotfiles ls-tree -r --name-only HEAD | while IFS= read -r f; do
        if [[ -e "$HOME/$f" ]]; then
            mkdir -p "$backup/$(dirname "$f")"
            mv "$HOME/$f" "$backup/$f"
        fi
    done
    dotfiles checkout
fi

# macOS: Homebrew + Brewfile (brew bundle skips anything already installed)
if [[ "$(uname -s)" == "Darwin" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # A fresh install isn't on PATH yet
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        [[ -x "$b" ]] && eval "$("$b" shellenv)" && break
    done
    brew update
    brew bundle --file "$HOME/.config/setup/Brewfile"
fi

# Ubuntu: packages and system config via Ansible
if [[ "$(uname -s)" == "Linux" ]]; then
    "$HOME/.config/setup/install_ubuntu.sh" "$@"
fi
