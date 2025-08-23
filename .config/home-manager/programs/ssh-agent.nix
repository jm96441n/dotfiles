{ config, pkgs, ... }:

{
  # Declarative SSH agent service
  services.ssh-agent.enable = true;

  # SSH configuration - declaratively manage keys
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    
    # Declaratively add your SSH keys
    matchBlocks = {
      "*" = {
        identityFile = [
          "~/.ssh/github_rsa"
          "~/.ssh/hashi"
        ];
        addKeysToAgent = "yes";
      };
    };
  };
}
