# Dotfiles!
A collection of shell configs, aliases, functions, Git tooling, and a fully declarative setup for a new Linux machine — managed with [Nix](https://nixos.org/) + [Home Manager](https://github.com/nix-community/home-manager).

> **Note:** This is now a Linux-first (Wayland) setup. The old macOS/Homebrew install paths are no longer maintained.

## What's Included

### Desktop Environment (Wayland)
  * [Sway](https://swaywm.org/) — tiling window manager (+ swayidle, swaylock, swaybg)
  * [Waybar](https://github.com/Alexays/Waybar) — status bar
  * [Wofi](https://hg.sr.ht/~scoopta/wofi) — launcher
  * [Kanshi](https://gitlab.freedesktop.org/emersion/kanshi) — display configuration
  * [Mako](https://github.com/emersion/mako) — notifications

### Shell & Terminal
  * [ZSH](https://www.zsh.org/) + [Oh My Zsh](https://ohmyz.sh/) (custom plugins: fzf-tab, zsh-autosuggestions, zsh-syntax-highlighting, jj-extra)
  * [Starship](https://starship.rs/) prompt
  * [Ghostty](https://ghostty.org/) (primary terminal, built via Nix overlay) + [Kitty](https://sw.kovidgoyal.net/kitty/)
  * [Tmux](https://github.com/tmux/tmux/wiki)

### Editors
  * [Neovim](https://neovim.io/)
  * [Helix](https://helix-editor.com/)

### Languages (via [mise](https://mise.jdx.dev/))
  * Node 23.11.0
  * Go 1.26.2
  * Python 3.13.3
  * Rust 1.94.1
  * Lua 5.1

### CLI Tools (managed by Home Manager)
  * [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [fd](https://github.com/sharkdp/fd), [ripgrep](https://github.com/BurntSushi/ripgrep), [fzf](https://github.com/junegunn/fzf)
  * [Jujustu (jj)](https://github.com/jj-vcs/jj) + [lazygit](https://github.com/jesseduffield/lazygit) + [git-delta](https://github.com/dandavison/delta)
  * [direnv](https://direnv.net/), [fastfetch](https://github.com/fastfetch-cli/fastfetch), [tree](https://en.wikipedia.org/wiki/Tree_(command)), [ranger](https://github.com/ranger/ranger)
  * [k9s](https://k9scli.io/), [kubectl](https://kubernetes.io/docs/reference/kubectl/), [gh](https://cli.github.com/)
  * HashiCorp: [terraform](https://developer.hashicorp.com/terraform), [vault](https://developer.hashicorp.com/vault), [consul](https://developer.hashicorp.com/consul), [packer](https://developer.hashicorp.com/packer), [helm](https://helm.sh/), [hcp](https://developer.hashicorp.com/hcp), [gomplate](https://docs.gomplate.ca/)
  * ...and more. See [`home.nix`](./.config/home-manager/home.nix) for the full list.

### GUI Apps (via Flatpak)
  * [Obsidian](https://obsidian.md/), [Spotify](https://open.spotify.com/), [Signal](https://signal.org/), [Zen Browser](https://zen-browser.app/), [Slack](https://slack.com/)

## Repository Layout
```
.config/                 # Application configs (mostly symlinked by Home Manager)
  home-manager/          # Nix flake + home.nix + per-program modules
    programs/            # git, zsh, bat, mako, starship, ssh-agent
  sway/ waybar/ wofi/    # Wayland desktop
  ghostty/ kitty/        # Terminals
  nvim/ helix/           # Editors
  mise/                  # Language versions + default packages per language
  jj/                    # Jujutsu config
  k9s/ ranger/ mcphub/   # Other tools
  pi/ opencode/          # Coding-agent configs
bin/                     # Personal scripts (dotfiles, tmux-sessionizer, review, ...)
git/                     # Git helpers + HashiCorp identity config
install/                 # System package + setup scripts
system/                  # .alias, .function (sourced by zsh)
wallpaper/               # Backgrounds
```

## Install

> The install path targets **Fedora** (using `dnf` for system/kernel/driver packages and GPU-stack deps), layered with Nix + Home Manager for user packages.

1. **Update the system:**
  ```bash
  sudo dnf upgrade
  ```

2. **Clone the repo:**
  ```bash
  git clone git@github.com:jm96441n/dotfiles.git ~/.dotfiles
  ```

3. **Run the installer.** A GitHub access token is required (used to set up an SSH key and write `system/.private_env`):
  ```bash
  export GITHUB_TOKEN="ghp_..."
  source ~/.dotfiles/install.sh
  ```

This will:
  * Install system packages via `dnf` ([`install/packages.sh`](./install/packages.sh)) — Sway stack, NVIDIA drivers, dev libraries, Docker, etc.
  * Install [Nix](https://nixos.org/) (Determinate Systems installer) and [Home Manager](https://github.com/nix-community/home-manager)
  * Apply the Home Manager configuration from the flake
  * Run `mise install` for language toolchains

SSH keys can be pulled from Bitwarden separately with [`install/pull-ssh-keys.sh`](./install/pull-ssh-keys.sh).

## Making Changes

After editing anything under `.config/home-manager/`, apply it with:
```bash
home-manager switch --flake ~/.config/home-manager#"$USER"
```

Configs symlinked out-of-store (e.g. `nvim`, `pi`) are picked up live without a switch.

## Credits

The [dotfiles community](https://dotfiles.github.io) and [webpro](https://github.com/webpro/dotfiles) who I've adapted these from.
