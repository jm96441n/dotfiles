{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./homelab-hardware.nix ];

  networking.hostName = "homelab";
  # Required by ZFS; any stable 8-hex-digit value.
  networking.hostId = "2e37df79";

  networking.firewall.allowedTCPPorts = [ 8080 ];

  # Media files are owned by uid/gid 1000; keep them matching.
  users.users.johnmaguire.uid = 1000;
  users.groups.johnmaguire.gid = 1000;
  users.users.johnmaguire.group = "johnmaguire";

  # ZFS: import the existing pool; its datasets keep their own mountpoints.
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "mediapool" ];
  services.zfs.autoScrub.enable = true;
  services.zfs.zed.settings.ZED_NOTIFY_VERBOSE = true;

  # RTX 3050 (Ampere): headless NVENC for containers.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };
  hardware.nvidia-container-toolkit.enable = true;

  virtualisation.docker.autoPrune.enable = true;

  # Secrets: encrypted in secrets/homelab.yaml. sshd is off, so sops-nix uses its
  # own age key, generated on first boot. Get its recipient with:
  #   sudo nix shell nixpkgs#age -c age-keygen -y /var/lib/sops-nix/key.txt
  sops = {
    defaultSopsFile = ../secrets/homelab.yaml;
    age.sshKeyPaths = [ ];
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = true;
    secrets.sonarr_api_key = { };
    secrets.radarr_api_key = { };
    templates."media-stack.env".content = ''
      SONARR_API_KEY=${config.sops.placeholder.sonarr_api_key}
      RADARR_API_KEY=${config.sops.placeholder.radarr_api_key}
    '';
  };

  # Media stack: docker compose, managed by systemd. A changed compose file
  # triggers `up -d` on rebuild so only changed containers get recreated.
  systemd.services.media-stack =
    let
      compose = "${pkgs.docker}/bin/docker compose -p johnmaguire -f ${./homelab-docker-compose.yaml} --env-file ${
        config.sops.templates."media-stack.env".path
      }";
    in
    {
      wantedBy = [ "multi-user.target" ];
      requires = [ "docker.service" ];
      after = [
        "docker.service"
        "network-online.target"
        "zfs-mount.service"
      ];
      wants = [ "network-online.target" ];
      unitConfig.RequiresMountsFor = "/home/johnmaguire/hdd/media";
      reloadIfChanged = true;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${compose} up -d --remove-orphans";
        ExecReload = "${compose} up -d --remove-orphans";
        ExecStop = "${compose} down";
      };
    };

  # No sshd here: log in with Tailscale SSH (`sudo tailscale up --ssh` once).
  services.openssh.enable = lib.mkForce false;
  services.tailscale.enable = true;

  # Token-based Cloudflare tunnel (same as `cloudflared service install <token>` on Fedora).
  # Token lives outside the repo: /etc/cloudflared/token (root, mode 600).
  systemd.services.cloudflared = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared --no-autoupdate tunnel run --token-file %d/token";
      LoadCredential = "token:/etc/cloudflared/token";
      Restart = "on-failure";
      DynamicUser = true;
    };
  };

  services.smartd.enable = true;
  services.fwupd.enable = true;

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
