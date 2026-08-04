{
  config,
  pkgs,
  ...
}:

let
  # Sync script kept in the Nix store so the whole thing is declarative.
  syncScript = pkgs.writeShellScriptBin "pi-memory-sync" ''
    set -euo pipefail

    REPO="''${PI_MEMORY_REPO:-$HOME/.pi-memory}"
    cd "$REPO"

    # First commit on a brand-new repo
    if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
      git add -A
      git commit -m "Initialize pi-memory" >/dev/null
    fi

    git add -A
    if ! git diff --cached --quiet; then
      git commit -m "memory: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >/dev/null
    fi

    # Reconcile with remote, then push. Don't fail the unit on a flaky network.
    git pull --rebase --autostash >/dev/null 2>&1 || true
    git push origin HEAD
  '';
in
{
  systemd.user.services.pi-memory-sync = {
    Unit = {
      Description = "Commit and push pi-memory repo";
      Wants = [ "network-online.target" ];
      After = [ "network-online.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${syncScript}/bin/pi-memory-sync";
      Environment = [ "GIT_SSH_COMMAND=ssh -o BatchMode=yes" ];
    };
  };

  systemd.user.timers.pi-memory-sync = {
    Unit.Description = "Hourly commit and push of pi-memory repo";
    Timer = {
      OnBootSec = "2min";
      OnUnitInactiveSec = "1h";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
