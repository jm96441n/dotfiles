{ ... }:
{
  imports = [
    ./dev-vm-hardware.nix
  ];

  networking.hostName = "dev";

  virtualisation.vmware.guest = {
    enable = true;
    headless = true;
  };

  # Headless: Rex for Mac connects over ssh://johnmaguire@dev (server enabled in mkNixos)
}
