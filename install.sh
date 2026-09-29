#!/bin/sh
# Bootstrap these dotfiles on a new machine: macOS, Linux (Ubuntu/Debian, Fedora, others) or WSL.
# Safe to re-run. Any extra arguments go to `chezmoi init` (e.g. --branch <name>).
#
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/tws4793/dotfiles/main/install.sh)"
set -eu

REPO="tws4793/dotfiles"
PUSH_URL="git@github.com:$REPO.git"
BIN="$HOME/.local/bin"

if command -v chezmoi >/dev/null 2>&1; then
    chezmoi="$(command -v chezmoi)"
else
    chezmoi="$BIN/chezmoi"
    if [ ! -x "$chezmoi" ]; then
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN"
    fi
fi

# Clone over HTTPS and ask the per-machine questions (no SSH key needed yet)
"$chezmoi" init "$REPO" "$@"

# Move aside anything chezmoi would overwrite, instead of prompting per file
backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
changes="$("$chezmoi" status --include=files,symlinks)"
printf '%s\n' "$changes" | while IFS= read -r line; do
    case "$line" in
        ?M*) f="${line#???}" ;;
        *) continue ;;
    esac
    [ -e "$HOME/$f" ] || continue
    mkdir -p "$backup/$(dirname "$f")"
    mv "$HOME/$f" "$backup/$f"
    echo "Backed up ~/$f to $backup/"
done

# Retire the old bare repo (~/.df) and files it managed that no longer exist here
if [ -d "$HOME/.df" ]; then
    mkdir -p "$backup/.config/zsh" "$backup/.config"
    for f in .df .aliases .gitignore README.md \
        .config/zsh/base.zsh .config/zsh/fnm.zsh .config/zsh/pm2.zsh .config/zsh/completions.zsh \
        .config/setup; do
        if [ -e "$HOME/$f" ]; then
            mv "$HOME/$f" "$backup/$f"
            echo "Moved old bare-repo file ~/$f to $backup/"
        fi
    done
fi

"$chezmoi" apply

# Fetch over HTTPS, push over SSH (add an SSH key to GitHub before pushing)
if command -v git >/dev/null 2>&1; then
    "$chezmoi" git -- remote set-url --push origin "$PUSH_URL"
fi

echo "Done. Open a new terminal (or log out and back in if your login shell changed)."
