{ pkgs, ... }:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "johnmaguire" ];
  };
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.johnmaguire = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "video"
    ];
    linger = true;
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 ..." ];
  };
  security.sudo.wheelNeedsPassword = false;

  programs.zsh.enable = true;
  programs.sway.enable = true;
  services.gnome.gnome-keyring.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
  ];

  system.stateVersion = "25.11";
}
