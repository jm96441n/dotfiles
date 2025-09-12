{ ... }:

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
          "~/.ssh/hashi"
          "~/.ssh/github_rsa"
        ];
      };
    };
  };
}
