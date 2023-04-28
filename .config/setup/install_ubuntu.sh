#!/bin/bash

# Set no password
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/$USER

# Update clock
timedatectl set-local-rtc 1

# Update
sudo apt update
sudo apt upgrade -y

# Install packages
sudo apt install -y curl tmux vim zsh git xsel rename tree bat p7zip-full gnome-tweaks openssh-server nmap neofetch pulseaudio chrome-gnome-shell gnome-shell-extension-prefs

# Install Chrome
curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O
sudo apt install -y ./google-chrome-stable_current_amd64.deb
rm -v ./google-chrome-stable_current_amd64.deb

# Setup dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.df/ --work-tree=$HOME"
git clone --bare https://github.com/tws4793/dotfiles.git $HOME/.df
dotfiles config --local status.showUntrackedFiles no
dotfiles remote set-url git@github.com:tws4793/dotfiles.git
dotfiles checkout

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
nvm install --lts
corepack enable

# Install pyenv
curl https://pyenv.run | bash

# Install docker
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker $USER

# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install zoom
curl -fsSL https://zoom.us/client/5.14.5.2430/zoom_amd64.deb -O
sudo apt install ./zoom_amd64.deb
rm -v ./zoom_amd64.deb

# Install VSCode
# curl -fsSL https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 -O

# Install anydesk
wget -O- https://keys.anydesk.com/repos/DEB-GPG-KEY | gpg --dearmor | sudo tee /etc/apt/keyrings/anydesk-keyring.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/anydesk-keyring.gpg] http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
