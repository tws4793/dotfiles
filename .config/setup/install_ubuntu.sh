#!/bin/bash

# Set no password
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/$USER

# Update clock
timedatectl set-local-rtc 1

# Update
sudo apt update
sudo apt upgrade -y

# Install packages
sudo apt install -y curl tmux vim zsh git xsel tree gnome-tweaks openssh-server

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
nvm install node
corepack enable

# Install pyenv
curl https://pyenv.run | bash

# Install docker
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker $USER

sudo curl -L "https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Setup dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.df/ --work-tree=$HOME"
git clone --bare https://github.com/tws4793/dotfiles.git $HOME/.df
dotfiles config --local status.showUntrackedFiles no
dotfiles remote set-url git@github.com:tws4793/dotfiles.git
dotfiles checkout
