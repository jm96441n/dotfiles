{ ... }:
{
  imports = [ ./home-laptop-hardware.nix ];

  networking.hostName = "home-laptop";

  # Quadro T1000 (Turing). BIOS is set to Discrete Graphics, so NVIDIA drives
  # everything; sway refuses NVIDIA without --unsupported-gpu.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    powerManagement.enable = true;
  };
  programs.sway.extraOptions = [ "--unsupported-gpu" ];

  hardware.enableRedistributableFirmware = true;
  services.power-profiles-daemon.enable = true;
  services.fwupd.enable = true;
}
