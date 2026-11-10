# GUI apps for NixOS desktops. On Fedora these come from dnf/flatpak (install/packages.sh).
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    chromium
    firefox
    obsidian
    signal-desktop
    slack
  ];
}
