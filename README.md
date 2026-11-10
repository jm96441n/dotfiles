# Dotfiles

Personal NixOS + Fedora (Wayland) setup, managed with [Nix](https://nixos.org/) + [Home Manager](https://github.com/nix-community/home-manager) flakes.

## Layout

| Path                                        | What                                                                                                                                                |
| ------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `install.sh`                                | Bootstrap: dnf packages, Nix, Home Manager, mise                                                                                                    |
| `install/`                                  | `packages.sh` (dnf repos/packages, Docker, NVIDIA), SSH key + GitHub key helpers                                                                    |
| `flake.nix`, `Makefile`                     | NixOS machines + Home Manager; `make switch` etc.                                                                                                   |
| `machines/`                                 | NixOS configs: `shared.nix`, `home-laptop.nix` (ThinkPad P1 Gen 3), `dev-vm.nix` (VMware on Mac), `desktop-apps.nix` (GUI apps, home-laptop only), `homelab.nix` (ZFS + docker compose media server) |
| `secrets/`, `.sops.yaml`                    | sops-encrypted secrets (age); edit with `sops secrets/homelab.yaml`                                                                                 |
| `home/`                                     | Home Manager: `default.nix` (packages), `programs/` (zsh, git, starship, bat, mako, ssh-agent)                                                      |
| `.config/`                                  | App configs: sway, waybar, wofi, kanshi, ghostty, kitty, tmux, nvim, helix, jj, k9s, ranger, mise                                                   |
| `.config/{opencode,claude,pi,mcphub,herdr}` | AI coding agent configs                                                                                                                             |
| `bin/`                                      | Scripts: `dotfiles`, `tmux-sessionizer`, `tmux-cht`, `git-heatmap`, `git-new-branch`, `review`, etc.                                                |
| `git/`                                      | Extra git config                                                                                                                                    |
| `system/`                                   | Env files (private env written here at install)                                                                                                     |
| `wallpaper/`, `everforest_colors`           | Theme assets                                                                                                                                        |

## Stack

- **WM**: sway + waybar + wofi + mako + kanshi
- **Shell**: zsh + starship
- **Terminal**: ghostty / kitty + tmux
- **Editor**: neovim (helix also configured)
- **VCS**: git + jujutsu
- **Runtimes**: mise
- **Tools**: see `home.packages` in [home/default.nix](./home/default.nix)

## Install: home-laptop (ThinkPad P1 Gen 3, NixOS)

1. BIOS: leave **Config → Display → Graphics Device** on **Discrete Graphics** (config assumes NVIDIA-only; sway runs with `--unsupported-gpu`).
2. Run the graphical NixOS installer. User `johnmaguire`, any password, disk encryption optional.
3. Reboot, then:
   ```sh
   nix-shell -p git gnumake
   git clone https://github.com/jm96441n/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles && make bootstrap HOST=home-laptop
   ```
4. Reboot. tuigreet starts sway.
5. Commit `machines/home-laptop-hardware.nix`.

## Install: homelab (ThinkStation P520, NixOS)

The ZFS pool `mediapool` (`sda`/`sdb`/`sdc`) is imported as-is; only `nvme0n1` is reinstalled.

**Before wiping Fedora**

- Back up off the NVMe: Docker named volumes (`/var/lib/docker/volumes`), the cloudflared tunnel token (`systemctl cat cloudflared`), anything else in `~` or `/etc` you want.
- `sudo zpool export mediapool`

**Install**

1. Run the graphical NixOS installer onto **`nvme0n1` only**. User `johnmaguire`.
2. Reboot, then:
   ```sh
   nix-shell -p git gnumake
   git clone https://github.com/jm96441n/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles && make bootstrap HOST=homelab
   ```
   If the pool isn't imported after reboot: `sudo zpool import -f mediapool`.
3. Join Tailscale with SSH enabled (sshd is off on this host):
   ```sh
   sudo tailscale up --ssh
   ```
4. Cloudflare tunnel token:
   ```sh
   sudo install -d -m 700 /etc/cloudflared
   sudo install -m 600 /dev/stdin /etc/cloudflared/token <<< '<token>'
   sudo systemctl restart cloudflared
   ```

**Secrets** (`media-stack` can't start until the host can decrypt them)

5. From another machine with your age key, get homelab's sops key over Tailscale SSH:
   ```sh
   ssh homelab sudo nix shell nixpkgs#age -c age-keygen -y /var/lib/sops-nix/key.txt
   ```
6. Add it to `.sops.yaml` (uncomment the `homelab` entries), re-encrypt and commit:
   ```sh
   sops updatekeys secrets/homelab.yaml
   ```
7. On homelab: pull, then `make switch`. Check with `systemctl status media-stack` and `docker ps`.
8. Check GPU transcoding: `docker exec jellyfin nvidia-smi`.

**Back up** `/var/lib/sops-nix/key.txt`. Without it a reinstall needs steps 5–7 again.

## Secrets

- Encrypted with [sops-nix](https://github.com/Mic92/sops-nix) + age. Recipients are in `.sops.yaml`.
- Edit: `sops secrets/homelab.yaml`. After adding a recipient: `sops updatekeys secrets/homelab.yaml`.
- Media stack compose file: `machines/homelab-docker-compose.yaml`. Rebuilding with a changed file runs `docker compose up -d`.

## Make targets

```
switch      nixos-rebuild switch for this host
bootstrap   first run on a fresh install (copies hardware config)
home        home-manager switch (non-NixOS)
update      nix flake update
clean       garbage-collect nix, prune mise
```

## Install: work laptop (Fedora, home-manager only)

```sh
sudo dnf upgrade
git clone https://github.com/jm96441n/dotfiles.git ~/.dotfiles
GITHUB_TOKEN=... bash ~/.dotfiles/install.sh
```

Day to day: `make home`. Fedora packages: `sudo dnf upgrade`.

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
