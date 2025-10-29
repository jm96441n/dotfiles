{ ... }:

{
  # Declarative SSH agent service
  services.ssh-agent.enable = true;

  # SSH configuration - declaratively manage keys
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Declaratively add your SSH keys
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        identityFile = [
          "~/.ssh/github_rsa"
        ];
      };
    };
  };
}
