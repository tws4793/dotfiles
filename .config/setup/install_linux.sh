#!/usr/bin/env bash
# Install Ansible and apply linux.yml (Ubuntu/Debian, Fedora, WSL). Safe to re-run.
# Usage: install_linux.sh [--nopasswd]
#   --nopasswd  enable passwordless sudo (default: off; re-run without it to turn it off)
set -euo pipefail

nopasswd=false
for arg in "$@"; do
    case "$arg" in
        --nopasswd) nopasswd=true ;;
        -h|--help) sed -n '3,4p' "$0" | sed 's/^# //'; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

if ! command -v ansible-playbook >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y ansible-core
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y ansible-core
    else
        echo "No supported package manager (apt-get or dnf) found." >&2
        exit 1
    fi
fi

ansible-playbook -i localhost, -c local -K \
    -e "{\"nopasswd_sudo\": $nopasswd}" \
    "$(dirname "$0")/linux.yml"
