#!/usr/bin/env bash
# Install Ansible and apply ubuntu.yml. Safe to re-run.
# Usage: install_ubuntu.sh [--nopasswd]
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
    sudo apt-get update
    sudo apt-get install -y ansible-core
fi

ansible-playbook -i localhost, -c local -K \
    -e "{\"nopasswd_sudo\": $nopasswd}" \
    "$(dirname "$0")/ubuntu.yml"
