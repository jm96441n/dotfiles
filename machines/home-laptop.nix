{ ... }:
{
  imports = [
    ./home-laptop-hardware.nix
    ./desktop.nix
  ];

  networking.hostName = "home-laptop";
  # Powersave causes WiFi latency spikes (SSH lag over tailscale).
  networking.networkmanager.wifi.powersave = false;

  # Quadro T1000 (Turing). BIOS is set to Discrete Graphics, so NVIDIA drives
  # everything; sway refuses NVIDIA without --unsupported-gpu.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    powerManagement.enable = true;
  };
  programs.sway.extraOptions = [ "--unsupported-gpu" ];
  # Text console + greetd on the NVIDIA card (otherwise a black screen with a cursor).
  boot.kernelParams = [ "nvidia-drm.fbdev=1" ];

  services.tailscale.enable = true;

  services.rex.enable = true;
  users.users.johnmaguire.extraGroups = [ "rex" ];

  # Login server maps local uid 1000 to a Rex server running as johnmaguire.
  # Without it the shared server runs terminals as the rex user (shell nologin).
  services.rex.loginServer = {
    enable = true;
    accounts.johnmaguire.principals = [ "peer:1000" ];
    defaults."peer:1000" = "johnmaguire";
  };

  hardware.enableRedistributableFirmware = true;
  services.power-profiles-daemon.enable = true;
  services.fwupd.enable = true;
}
