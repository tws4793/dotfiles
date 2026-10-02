# Aliases and functions for interactive bash and zsh. POSIX syntax.
# Machine-specific ones go in ~/.config/shell/local.sh (untracked).

# Dotfiles repo: `dotfiles status`, `dotfiles commit -am ...`, `dotfiles push`
alias dotfiles='chezmoi git --'

# Platform
case "$(uname -s)" in
    Linux)
        alias ls='ls --color=auto'
        alias rmswap='sudo swapoff -a && sudo swapon -a'
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

# Files
alias la='ls -A'
alias ll='ls -lh'
alias lla='ls -lhA'
alias grep='grep --color=auto'
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -v'
alias ln='ln -iv'
mcd() { mkdir -p -- "$1" && cd -- "$1" || return; }
mtouch() { mkdir -p -- "$1" && touch -- "$1/$2"; }
# Append .txt to each file: mrename *.log
mrename() { for file in "$@"; do mv -- "$file" "$file.txt"; done; }

# shred can't reliably erase files on SSDs or journaling/copy-on-write filesystems;
# use full-disk encryption for that. Default 3 passes, then zero, then delete.
command -v shred >/dev/null 2>&1 && alias shred='shred -fvuz'

# System
alias off='sudo shutdown -h now'
alias reboot='sudo shutdown -r now'

# Tools
command -v batcat >/dev/null 2>&1 && alias bat='batcat'
alias g='git'

# AWS CLI in Docker, only when it isn't installed (brew install awscli)
if ! command -v aws >/dev/null 2>&1; then
    aws() {
        set -- public.ecr.aws/aws-cli/aws-cli "$@"
        # -t only on a terminal, so `aws ... | jq` works
        if [ -t 0 ] && [ -t 1 ]; then set -- -t "$@"; fi
        docker run --rm -i \
            -v "$HOME/.aws:/root/.aws" -v "$PWD:/aws" \
            -e AWS_PROFILE -e AWS_REGION -e AWS_DEFAULT_REGION \
            -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN \
            "$@"
    }
fi

# Network
porttest() { curl "portquiz.net:$1"; }
cheat() { curl "cht.sh/$1"; }
ipaddress() { curl -4 "ifconfig.co/$1"; }

# Fun (needs the otsaw-rnd1 SSH host and sox's `play`)
alias harp='ssh otsaw-rnd1 "cat ~/Downloads/harp.mp3" | play --type mp3 -'
alias rickroll='ssh otsaw-rnd1 "cat ~/Downloads/rickroll.mp3" | play --type mp3 -'

# Docker
alias dps='docker ps -a'
alias di='docker images'
alias drm='docker container prune'
alias drmi='docker rmi -f'
alias drun='docker run --rm'
alias dalias='alias | grep docker'
alias docker-compose='docker compose'
alias dc='docker compose'
alias dcb='docker compose build'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
# Shell into a container: bash if it has it, else sh
dbash() { docker exec -it "$1" sh -c 'command -v bash >/dev/null && exec bash || exec sh'; }
