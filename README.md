# dotfiles

This repo contains my personal dotfiles.

As with any dotfiles, this is always a work in progress.

It uses the [git bare repo method](https://www.atlassian.com/git/tutorials/dotfiles): the repo lives in `~/.df` and your home directory is the work tree. [`.config/setup/setup.sh`](.config/setup/setup.sh) sets up a new machine end to end and is safe to re-run.

| Platform | What `setup.sh` does after checking out the dotfiles |
| --- | --- |
| macOS | Installs Homebrew and everything in [`Brewfile`](.config/setup/Brewfile) |
| Ubuntu / Debian | Installs Ansible and runs [`linux.yml`](.config/setup/linux.yml) |
| Fedora | Same as Ubuntu, using `dnf` |
| WSL | Same as Ubuntu/Fedora, but skips GNOME apps, the hardware clock and Docker Engine |

If a file the dotfiles track already exists (for example a default `~/.zshrc`), it is moved to `~/.df-backup/<timestamp>/` before checkout.

## New Mac

1. Open Terminal and run:

   ```console
   curl -fsSL https://raw.githubusercontent.com/tws4793/dotfiles/main/.config/setup/setup.sh -o /tmp/setup.sh
   bash /tmp/setup.sh
   ```

2. If a dialog asks to install the Xcode Command Line Tools, finish that install and run `bash /tmp/setup.sh` again. Git comes with those tools.
3. Enter your password when the Homebrew installer asks for it. `brew bundle` then installs the Brewfile, which can take a while.
4. Open a new terminal.

## New Ubuntu / Debian

1. Install curl (Ubuntu Desktop doesn't include it):

   ```console
   sudo apt install -y curl
   ```

2. Download and run the setup script:

   ```console
   curl -fsSL https://raw.githubusercontent.com/tws4793/dotfiles/main/.config/setup/setup.sh -o /tmp/setup.sh
   bash /tmp/setup.sh
   ```

   Add `--nopasswd` to enable passwordless sudo (`bash /tmp/setup.sh --nopasswd`). It's off by default, and re-running without the flag turns it off again.

3. When Ansible asks for the `BECOME password`, enter your sudo password.
4. Make zsh your login shell, then log out and back in (this also applies the `docker` group):

   ```console
   chsh -s "$(command -v zsh)"
   ```

The playbook keeps the hardware clock in local time, for dual-booting with Windows. To turn that off, set `local_rtc: false` at the top of [`linux.yml`](.config/setup/linux.yml).

## New Fedora

Same as Ubuntu, without step 1, since Fedora includes curl:

```console
curl -fsSL https://raw.githubusercontent.com/tws4793/dotfiles/main/.config/setup/setup.sh -o /tmp/setup.sh
bash /tmp/setup.sh            # or: bash /tmp/setup.sh --nopasswd
chsh -s "$(command -v zsh)"   # then log out and back in
```

Docker is installed from Docker's Fedora repository and enabled at boot.

## New WSL

1. In PowerShell (as Administrator), install WSL with Ubuntu, then restart if asked and create your Linux user:

   ```powershell
   wsl --install -d Ubuntu
   ```

2. For Docker, install Docker Desktop on Windows and turn on **Settings → Resources → WSL integration** for your distro. The playbook doesn't install Docker Engine inside WSL.
3. Inside WSL, follow the [Ubuntu steps](#new-ubuntu--debian) (or the [Fedora steps](#new-fedora) for a Fedora distro). WSL is detected automatically, so GNOME apps, the hardware clock and Docker Engine are skipped.

## Day to day

```console
dotfiles status                 # the dotfiles alias works like git
dotfiles add -u && dotfiles commit -m "..." && dotfiles push
```

- **Update everything:** re-run `~/.config/setup/setup.sh`.
- **macOS packages:** `HOMEBREW_BUNDLE_FILE` points at the Brewfile, so plain `brew bundle` (install missing), `brew bundle check` and `brew bundle cleanup` work from anywhere.
- **Pushing:** the repo is cloned over HTTPS and then switched to SSH, so add an SSH key to GitHub before you push.
