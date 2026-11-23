{ pkgs, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "johnmaguire";
  users.users.johnmaguire.home = "/Users/johnmaguire";

  homebrew = {
    enable = true;
    # Removes any cask not listed here
    onActivation.cleanup = "zap";
    casks = [
      "deezer"
      "ghostty"
      "omniwm"
      "signal"
      "slack"
      "zen"
    ];
  };

  fonts.packages = [ pkgs.nerd-fonts.fira-code ];

  # Match sway's input block: ctrl:nocaps, repeat_delay 200, repeat_rate 25
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 13; # units of 15ms
    KeyRepeat = 3;
  };

  system.stateVersion = 6;
}
