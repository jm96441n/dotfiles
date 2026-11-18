{ ... }:

{
  # Declarative SSH agent service
  services.ssh-agent.enable = true;

  # SSH configuration - declaratively manage keys
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        IdentityFile = [ "~/.ssh/github_rsa" ];
      };
    };
  };
}
