{ pkgs, ... }:
{
  imports = [
    ./dev-vm-hardware.nix
    ./desktop.nix
  ];

  networking.hostName = "dev";

  virtualisation.vmware.guest.enable = true;

  # VM boots straight into sway
  services.greetd.settings.initial_session = {
    command = "sway";
    user = "johnmaguire";
  };

  # VMware's virtual GPU needs software cursors under wlroots
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
}
