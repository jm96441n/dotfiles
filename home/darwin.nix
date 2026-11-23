# Minimal macOS home: dev tooling lives in dev-vm, not here.
{ ... }:
{
  home.stateVersion = "25.11";

  xdg.configFile."ghostty/config".source = ../.config/ghostty/config;
  # Read-only symlink: edit the file in the repo, not from OmniWM's Settings window.
  xdg.configFile."omniwm/settings.toml".source = ../.config/omniwm/settings.toml;
}
