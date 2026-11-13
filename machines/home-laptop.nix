{ ... }:
{
  imports = [
    ./home-laptop-hardware.nix
    ./desktop.nix
  ];

  networking.hostName = "home-laptop";

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

  hardware.enableRedistributableFirmware = true;
  services.power-profiles-daemon.enable = true;
  services.fwupd.enable = true;
}
