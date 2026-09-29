# Aliases and functions for interactive bash and zsh. POSIX syntax.

# Dotfiles repo: `dotfiles status`, `dotfiles commit -am ...`, `dotfiles push`
alias dotfiles='chezmoi git --'

# Main
case "$(uname -s)" in
    Linux)
        alias ls='ls --color=auto'
    ;;
    Darwin)
        alias ls='ls -G'
        alias battery='pmset -g batt'
    ;;
esac

# Clipboard: pbcopy/pbpaste everywhere (macOS has them built in)
if [ -n "${WSL_DISTRO_NAME-}" ]; then
    alias pbcopy='clip.exe'
    alias pbpaste="powershell.exe -NoProfile -Command Get-Clipboard | tr -d '\r'"
elif [ -n "${WAYLAND_DISPLAY-}" ] && command -v wl-copy >/dev/null 2>&1; then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste --no-newline'
elif command -v xsel >/dev/null 2>&1; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
fi

# Base
alias la='ls -A'
alias ll='ls -l'
alias lla='ls -lA'
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -v'
alias ln='ln -iv'
mcd() { mkdir -p -- "$1" && cd -- "$1" || return; }
mrename() { for file in $1; do mv -- "$file" "${file}.txt"; done; }
mtouch() { mkdir -p -- "$1" && touch -- "$1/$2"; }

alias shred='shred -fvuzn 35'
alias whereami='echo $PWD'
alias off='sudo shutdown now'
alias reboot='sudo shutdown -r now'
alias rmswap='sudo swapoff -a; sudo swapon -a;'

command -v batcat >/dev/null 2>&1 && alias bat='batcat'

alias g='git'

alias aws='docker run --rm -it -v "$HOME/.aws:/root/.aws:ro" -v "$(pwd):/aws" public.ecr.aws/aws-cli/aws-cli'
alias harp='ssh otsaw-rnd1 "cat ~/Downloads/harp.mp3" | play --type mp3 -'
alias rickroll='ssh otsaw-rnd1 "cat ~/Downloads/rickroll.mp3" | play --type mp3 -'

porttest() { curl "portquiz.net:$1"; }
cheat() { curl "cht.sh/$1"; }
ipaddress() { curl -4 "ifconfig.co/$1"; }

# Docker / Podman
alias dps='docker ps -a'
alias di='docker images'
alias drm='docker rm $(docker ps -aqf status=exited)'
alias drmi='docker rmi -f'
alias drun='docker run --rm'
alias dalias='alias | grep docker'
alias docker-compose='docker compose'
alias dc='docker compose'
alias dcb='docker compose build'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
dbash() { docker exec -it "$1" bash; }
