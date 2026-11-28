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

  # Personal Rex server as a systemd user service (single-user machine; the
  # shared server runs terminals as the rex user, whose shell is nologin).
  # Socket: /run/user/1000/rex/server.sock — point rex-rune there.
  home-manager.users.johnmaguire = {
    programs.rex.enable = true;
    services.rex.enable = true;
  };
  # Keep the user service (and rex sessions) alive after logout.
  users.users.johnmaguire.linger = true;

  hardware.enableRedistributableFirmware = true;
  services.power-profiles-daemon.enable = true;
  services.fwupd.enable = true;
}
