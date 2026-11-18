# GUI apps for NixOS desktops. On Fedora these come from dnf/flatpak (install/packages.sh).
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    chromium
    firefox
    obsidian
    signal-desktop
    slack
  ];
}
