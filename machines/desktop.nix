{ pkgs, ... }:
{
  programs.sway.enable = true;
  services.gnome.gnome-keyring.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
  };

  # Tools the sway/waybar/wofi configs call. On Fedora these come from dnf.
  environment.systemPackages = with pkgs; [
    ghostty
    grim
    jq
    pulseaudio # pactl
    slurp
    swaybg
    waybar
    wl-clipboard
    wofi
  ];

  # Audio (volume keys use pactl).
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
