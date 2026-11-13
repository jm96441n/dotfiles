# Dotfiles

Personal Fedora (Wayland) setup, managed with [Nix](https://nixos.org/) + [Home Manager](https://github.com/nix-community/home-manager) flakes.

## Layout

| Path | What |
|------|------|
| `install.sh` | Bootstrap: dnf packages, Nix, Home Manager, mise |
| `install/` | `packages.sh` (dnf repos/packages, Docker, NVIDIA), SSH key + GitHub key helpers |
| `.config/home-manager/` | `flake.nix`, `home.nix` (packages), `programs/` (zsh, git, starship, bat, mako, ssh-agent) |
| `.config/` | App configs: sway, waybar, wofi, kanshi, ghostty, kitty, tmux, nvim, helix, jj, k9s, ranger, mise |
| `.config/{opencode,claude,pi,mcphub,herdr}` | AI coding agent configs |
| `bin/` | Scripts: `dotfiles`, `tmux-sessionizer`, `tmux-cht`, `git-heatmap`, `git-new-branch`, `review`, etc. |
| `git/` | Extra git config |
| `system/` | Env files (private env written here at install) |
| `wallpaper/`, `everforest_colors` | Theme assets |

## Stack

- **WM**: sway + waybar + wofi + mako + kanshi
- **Shell**: zsh + starship
- **Terminal**: ghostty / kitty + tmux
- **Editor**: neovim (helix also configured)
- **VCS**: git + jujutsu
- **Runtimes**: mise
- **Tools**: see `home.packages` in [home.nix](./.config/home-manager/home.nix)

## Install

```sh
sudo dnf upgrade
git clone https://github.com/jm96441n/dotfiles.git ~/.dotfiles
GITHUB_TOKEN=... bash ~/.dotfiles/install.sh
```

## The `dotfiles` command

```
clean    Clean up caches (dnf, nix, mise)
edit     Open dotfiles in $EDITOR
help     This help message
switch   Apply home-manager config
update   Update dnf, flake inputs, home-manager, mise
```

## Credits

The [dotfiles community](https://dotfiles.github.io) and [webpro](https://github.com/webpro/dotfiles).
