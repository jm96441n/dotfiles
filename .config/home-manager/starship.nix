{ ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      character = {
        symbol = "[➜](bold green) ";
      };
      aws = {
        format = "\[[$symbol($profile)(\($region\))(\[$duration\])]($style)\]";
      };
      c = {
        format = "\[[$symbol($version(-$name))]($style)\]";
      };
      cmake = {
        format = "\[[$symbol($version)]($style)\]";
      };
      cmd_duration = {
        format = "\[[⏱ $duration]($style)\]";
      };
      docker_context = {
        format = "\[[$symbol$context]($style)\]";
      };
      gcloud = {
        format = "\[[$symbol$account(@$domain)(\($region\))]($style)\]";
      };
      git_branch = {
        format = "\[[$symbol$branch]($style)\]";
      };
      git_status = {
        format = "([\[$all_status$ahead_behind\]]($style))";
      };
      golang = {
        style = "bold #83c092";
        format = "\[[$symbol($version)]($style)\]";
      };
      kubernetes = {
        format = "\[[$symbol$context( \($namespace\))]($style)\]";
      };
      lua = {
        format = "\[[$symbol($version)]($style)\]";
      };
      nix_shell = {
        format = "\[[$symbol$state( \($name\))]($style)\]";
      };
      python = {
        style = "bold #dbbc7f";
        format = "\[[$symbol$pyenv_prefix($version)(\($virtualenv\))]($style)\]";
      };
      ruby = {
        format = "\[[$symbol($version)]($style)\]";
      };
      rust = {
        format = "\[[$symbol($version)]($style)\]";
      };
      sudo = {
        format = "\[[as $symbol]\]";
      };
      terraform = {
        format = "\[[$symbol$workspace]($style)\]";
      };
      time = {
        format = "[$time]($style) ";
      };
      username = {
        format = "\[[$user]($style)\]";
      };
    };
  };
}
