# dotfiles

My personal dotfiles for macOS (Apple Silicon and Intel), Linux (Ubuntu/Debian, Fedora, and any other distro for the dotfiles themselves) and WSL, managed with [chezmoi](https://www.chezmoi.io/).

- **One shell setup for bash and zsh.** Environment, aliases and tool hooks are plain POSIX files shared by both. Each shell adds only its own options, completion and the same two-line prompt. macOS uses zsh only, so the bash files aren't installed there.
- **The same tmux everywhere.** One `~/.tmux.conf`, with no OS-specific paths. tpm and its plugins are installed for you.
- **Optional tiling window manager.** i3 or sway on Linux; AeroSpace (same keys as i3) or Amethyst on macOS. Skipped on WSL.
- **Packages.** A Brewfile on macOS and an Ansible playbook on Linux. chezmoi re-runs them whenever they change.

## New machine

```console
sh -c "$(curl -fsSL https://raw.githubusercontent.com/tws4793/dotfiles/main/install.sh)"
```

This installs chezmoi, clones this repo over HTTPS, asks a few questions, installs packages and applies the dotfiles. It's safe to re-run. Any file it would overwrite is first moved to `~/.dotfiles-backup/<timestamp>/`.

| Question | Choices | Default |
| --- | --- | --- |
| Tiling window manager | macOS: `none`, `aerospace`, `amethyst`; Linux: `none`, `i3`, `sway`; not asked on WSL | `none` |
| Login shell (Linux and WSL; always zsh on macOS) | `zsh`, `bash`, `unchanged` | `zsh` |
| Install packages (Homebrew or Ansible) | yes / no | yes |
| Passwordless sudo (Linux only) | yes / no | no |

The answers are saved in `~/.config/chezmoi/chezmoi.toml`. To answer them again, run `chezmoi init --prompt && chezmoi apply`.

Per platform:

- **macOS:** If a dialog asks to install the Xcode Command Line Tools, let it finish. Enter your password when Homebrew asks for it. `brew bundle` then installs the [Brewfile](setup/Brewfile).
- **Ubuntu / Debian:** Ubuntu Desktop has no curl, so run `sudo apt install -y curl` first. Ansible asks for your sudo (`BECOME`) password, then runs [`setup/linux.yml`](setup/linux.yml).
- **Fedora:** Same as Ubuntu, but curl is already installed.
- **Other distros:** The dotfiles apply as normal. Package installation is skipped with a message, so install zsh, tmux and neovim yourself.
- **WSL:** In an Administrator PowerShell, run `wsl --install -d Ubuntu` (or use a Fedora distro), then follow the Linux steps inside WSL. WSL is detected automatically, so the playbook skips GNOME, the hardware clock and Docker Engine. For Docker, install Docker Desktop and turn on *Settings → Resources → WSL integration*.

**Packages are optional.** Answer *no* to "Install packages" (or use a distro without a playbook) and chezmoi never runs Homebrew or Ansible; the dotfiles still apply. Tools the config uses (zsh, tmux, neovim, fnm, uv, git) are only picked up if they're installed, and tmux's plugin manager arrives on the next `chezmoi apply` once git and tmux exist. The playbook also runs on its own, without chezmoi (see the top of [`setup/linux.yml`](setup/linux.yml)).

When it finishes, open a new terminal. If your login shell changed, log out and back in; this also picks up the `docker` group on Linux.

## Day to day

chezmoi keeps the repo in `~/.local/share/chezmoi` and writes the files into `$HOME`.

```console
chezmoi edit ~/.zshrc          # edit the source file, then...
chezmoi apply                  # ...write it to $HOME (also re-runs changed package scripts)
chezmoi re-add                 # or: edit files in $HOME directly, then copy them back into the repo
chezmoi diff                   # what apply would change
chezmoi update                 # git pull + apply

dotfiles status                # the dotfiles alias is git, run in the repo
dotfiles commit -am "..." && dotfiles push
```

- **Push over SSH:** the repo fetches over HTTPS and pushes over SSH, so add an SSH key to GitHub before pushing.
- **macOS packages:** `HOMEBREW_BUNDLE_FILE` points at the Brewfile in the repo. Plain `brew bundle`, `brew bundle check` and `brew bundle cleanup` work from anywhere, and `brew bundle dump --force` writes straight into the repo.
- **Machine-specific settings** (a work laptop's proxy, extra aliases, PATH entries) go in `~/.config/shell/local.sh`, which both shells source last, `~/.tmux.local.conf`, which tmux loads before its plugins, and `~/.config/git/local`, which `~/.gitconfig` includes last (e.g. an `includeIf` for a work identity). None of them is tracked, and all are optional.

## Layout

```
install.sh                     bootstrap: install chezmoi, back up conflicts, apply
setup/Brewfile                 macOS packages
setup/linux.yml                Linux packages and system settings (Ansible)
home/                          everything under here maps to $HOME (see .chezmoiroot)
  .chezmoi.toml.tmpl           the setup questions
  .chezmoiignore               which files each machine gets (e.g. only the chosen WM)
  .chezmoiexternal.toml        tpm
  .chezmoiscripts/             package install, tmux plugins, login shell
  dot_profile                  login env for sh/bash (and graphical sessions)
  dot_bash_profile, dot_bashrc bash entry points (Linux and WSL only)
  dot_zshenv, dot_zprofile, dot_zshrc  zsh entry points
  dot_config/shell/            shared by bash and zsh: env.sh, aliases.sh, tools.sh
  dot_config/bash/             bash only: options, completion, prompt (Linux and WSL only)
  dot_config/zsh/              zsh only: options, completion, prompt
  dot_tmux.conf                tmux
  dot_config/i3, sway, aerospace   tiling window managers
  dot_amethyst.yml             Amethyst (macOS)
  dot_config/nvim, dot_vimrc   editors
  dot_local/bin/               scripts on PATH (notebook)
  dot_gitconfig, dot_config/git/ignore
```

chezmoi's naming: `dot_x` becomes `.x`, `executable_x` is installed as executable, and a `.tmpl` file is rendered per machine (for example, `env.sh.tmpl` holds the Brewfile path). Files these dotfiles used to install and no longer do are listed in `.chezmoiremove`, and `chezmoi apply` deletes them.

## Shells

Both shells load the same pieces in the same order: `env.sh`, then shell-specific options, completion and prompt, then `aliases.sh`, `tools.sh` (fnm, uv, pm2, SDKMAN) and `local.sh`.

- **Environment:** `env.sh` puts Homebrew, then `~/.local/bin` and `~/.bin`, first on `PATH`. It's safe to source repeatedly and survives macOS's `path_helper`. It picks `EDITOR` (nvim, then vim, then vi) and finds `JAVA_HOME` on macOS, Debian and Fedora.
- **bash:** Linux and WSL only; on macOS the bash files aren't installed.
- **zsh:** Uses emacs keys at the prompt, the same as bash, whatever `$EDITOR` is.
- **Clipboard:** `pbcopy`/`pbpaste` work everywhere. They map to `clip.exe` on WSL, `wl-copy` on Wayland and `xsel` on X11.

## tmux

The config is the same on every platform. It doesn't set `default-shell`, so tmux uses your login shell. `M-h/j/k/l`, `M-n/p` and `M-c` need your terminal to send Option as Meta on macOS:

- **Terminal.app:** Settings → Profiles → Keyboard → *Use Option as Meta key*
- **iTerm2:** Settings → Profiles → Keys → *Left Option key: Esc+*
- **Ghostty:** `macos-option-as-alt = true`
- **WezTerm:** `send_composed_key_when_left_alt_is_pressed = false`

## Jupyter notebooks

`notebook` starts JupyterLab in the current directory, using [uv](https://docs.astral.sh/uv/) (installed on every platform). Ctrl-C stops it.

- **Inside a uv project** (a `pyproject.toml` in this directory or above), it runs `uv run --with jupyterlab jupyter lab`. The notebook sees exactly the project's dependencies, and JupyterLab isn't added to `pyproject.toml`.
- **Anywhere else**, it uses a cached environment with JupyterLab plus `$NOTEBOOK_PACKAGES` (default `numpy pandas matplotlib`). To choose your own, run `NOTEBOOK_PACKAGES="polars seaborn" notebook`.
- **`notebook --container [IMAGE]`** runs a [Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/) image with podman or Docker, for heavy stacks you'd rather not install. `IMAGE` can be a short name (`scipy`, `tensorflow`, `pytorch`) or a full image name. The current directory is mounted at `~/work`, files you create there belong to you, and it listens on `127.0.0.1:$NOTEBOOK_PORT` (default 8888).

Other arguments go to JupyterLab, for example `notebook --no-browser`. To add a package to a project for good, run `uv add <pkg>`. VS Code can also open `.ipynb` files directly, using the same project environment.

## Tiling window managers

Pick one at setup (or later with `chezmoi init --prompt`). The package scripts install it, and only its config is written.

| | Linux (X11) | Linux (Wayland) | macOS | macOS |
| --- | --- | --- | --- | --- |
| WM | i3 | sway | [AeroSpace](https://github.com/nikitabobko/AeroSpace) | [Amethyst](https://github.com/ianyh/Amethyst) |
| Style | manual tree (split, stack, tab) | same as i3 | same as i3 | automatic layouts (xmonad-style) |
| Config | `~/.config/i3/config` | `~/.config/sway/config` | `~/.config/aerospace/aerospace.toml` | `~/.amethyst.yml` |
| Modifier | Super | Super | Ctrl+Alt | Option+Shift (Amethyst's default) |
| Terminal | urxvt + tmux | foot + tmux | Terminal.app | — |

**i3, sway and AeroSpace** use the same keys: `$mod+j/k/l/;` to focus, `+Shift` to move, `$mod+h/v` to split, `$mod+s/w/e` for layouts, `$mod+1…0` for workspaces, `$mod+r` to resize and `$mod+Shift+q` to close. On macOS, `$mod` is Ctrl+Alt rather than Alt or Cmd. Alt alone would take tmux's `M-` keys, and Cmd would take `Cmd-H`, `Cmd-Q` and `Cmd-1…9`.

**Amethyst** keeps its own default keys: Option+Shift+`j/k` to focus, `+Ctrl` to swap, `Space` to cycle layouts, `a/s/d/f` for tall/wide/fullscreen/column, `h/l` to resize the main pane, and Option+Shift+Ctrl+`1…0` to send a window to a Space. It takes Option+Shift+`n/p`, so tmux's `M-N`/`M-P` don't reach tmux; `M-n`/`M-p` do the same thing there. Only settings that differ from Amethyst's defaults go in `~/.amethyst.yml` (repeating a default hotkey there can stop it working); restart Amethyst after editing.

**Which one on macOS?** AeroSpace if you want the same muscle memory as i3/sway on Linux: manual splits, and its own instant-switching workspaces instead of macOS Spaces. Amethyst if you prefer windows arranged for you and native Spaces and Mission Control; moving windows between Spaces relies on macOS and can be less reliable.

After installing sway, choose *Sway* on your login screen. After installing AeroSpace or Amethyst, grant it Accessibility access when macOS asks.

## Moving an existing machine from the old bare repo (`~/.df`)

1. Commit and push anything left in `~/.df`.
2. Run the install command above. It moves `~/.df` and the old files it tracked (`~/.aliases`, `~/.gitignore`, `~/README.md`, `~/.config/zsh/{base,fnm,pm2,completions}.zsh`, `~/.config/setup`) into `~/.dotfiles-backup/<timestamp>/`, and backs up anything chezmoi replaces.
3. Open a new terminal. When you're happy, delete `~/.dotfiles-backup`.

The `dotfiles` alias still works for git commands. Use `chezmoi add <file>` instead of `dotfiles add`.

## CI

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs on every push:

- shellcheck, an Ansible syntax check, and i3/sway config validation
- the Linux playbook, run for real on Ubuntu
- a dotfiles install on Ubuntu, Fedora and macOS, which then starts each shell (bash and zsh on Linux, zsh on macOS) and tmux and checks for errors
