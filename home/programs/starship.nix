{ ... }:

{
  programs.starship = {
    enable = true;

    settings = {
      # Get editor completions based on the config schema
      "$schema" = "https://starship.rs/config-schema.json";

      # Inserts a blank line between shell prompts
      add_newline = true;

      # Replace the "❯" symbol in the prompt with "➜"
      character = {
        success_symbol = "[➜](bold green)";
      };

      aws = {
        format = ''\[[$symbol($profile)(\($region\))(\[$duration\])]($style)\]'';
      };

      c = {
        format = ''\[[$symbol($version(-$name))]($style)\]'';
      };

      cmake = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      cmd_duration = {
        format = ''\[[⏱ $duration]($style)\]'';
      };

      cobol = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      conda = {
        format = ''\[[$symbol$environment]($style)\]'';
      };

      crystal = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      daml = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      dart = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      deno = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      docker_context = {
        format = ''\[[$symbol$context]($style)\]'';
      };

      dotnet = {
        format = ''\[[$symbol($version)(🎯 $tfm)]($style)\]'';
      };

      elixir = {
        format = ''\[[$symbol($version \(OTP $otp_version\))]($style)\]'';
      };

      elm = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      erlang = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      gcloud = {
        format = ''\[[$symbol$account(@$domain)(\($region\))]($style)\]'';
      };

      git_branch = {
        disabled = true;
        format = ''\[[$symbol$branch]($style)\]'';
      };

      git_status = {
        disabled = true;
        format = ''([\[$all_status$ahead_behind\]]($style))'';
      };

      git_commit = {
        disabled = true;
      };

      git_metrics = {
        disabled = true;
      };

      golang = {
        style = "bold #83c092";
        format = ''\[[$symbol($version)]($style)\]'';
      };

      haskell = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      helm = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      hg_branch = {
        format = ''\[[$symbol$branch]($style)\]'';
      };

      java = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      julia = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      kotlin = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      kubernetes = {
        format = ''\[[$symbol$context( \($namespace\))]($style)\]'';
      };

      lua = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      memory_usage = {
        format = ''\[$symbol[$ram( | $swap)]($style)\]'';
      };

      nim = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      nix_shell = {
        format = ''\[[$symbol$state( \($name\))]($style)\]'';
      };

      nodejs = {
        disabled = true;
        format = ''\[[$symbol($version)]($style)\]'';
      };

      ocaml = {
        format = ''\[[$symbol($version)(\($switch_indicator$switch_name\))]($style)\]'';
      };

      openstack = {
        format = ''\[[$symbol$cloud(\($project\))]($style)\]'';
      };

      package = {
        format = ''\[[$symbol$version]($style)\]'';
      };

      perl = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      php = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      pulumi = {
        format = ''\[[$symbol$stack]($style)\]'';
      };

      purescript = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      python = {
        style = "bold #dbbc7f";
        format = ''\[[''${symbol}''${pyenv_prefix}(''${version})(\($virtualenv\))]($style)\]'';
      };

      raku = {
        format = ''\[[$symbol($version-$vm_version)]($style)\]'';
      };

      red = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      ruby = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      rust = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      scala = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      spack = {
        format = ''\[[$symbol$environment]($style)\]'';
      };

      sudo = {
        format = ''\[[as $symbol]($style)\]'';
      };

      swift = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      terraform = {
        format = ''\[[$symbol$workspace]($style)\]'';
      };

      time = {
        format = ''\[[$time]($style)\]'';
      };

      username = {
        format = ''\[[$user]($style)\]'';
      };

      vagrant = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      vlang = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      zig = {
        format = ''\[[$symbol($version)]($style)\]'';
      };

      # custom module for jj status
      custom = {
        jj = {
          description = "The current jj status";
          when = "jj --ignore-working-copy root";
          symbol = "🥋 ";
          command = ''
            jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
              separate(" ",
                change_id.shortest(4),
                bookmarks,
                "|",
                concat(
                  if(conflict, "💥"),
                  if(divergent, "🚧"),
                  if(hidden, "👻"),
                  if(immutable, "🔒"),
                ),
                raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
                raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                  truncate_end(29, description.first_line(), "…"),
                  "(no description set)",
                ) ++ raw_escape_sequence("\x1b[0m"),
              )
            '
          '';
        };

        git_status = {
          when = "! jj --ignore-working-copy root";
          command = "starship module git_status";
          style = ""; # This disables the default "(bold green)" style
          description = "Only show git_status if we're not in a jj repo";
        };

        git_commit = {
          when = "! jj --ignore-working-copy root";
          command = "starship module git_commit";
          style = "";
          description = "Only show git_commit if we're not in a jj repo";
        };

        git_metrics = {
          when = "! jj --ignore-working-copy root";
          command = "starship module git_metrics";
          description = "Only show git_metrics if we're not in a jj repo";
          style = "";
        };

        git_branch = {
          when = "! jj --ignore-working-copy root";
          command = "starship module git_branch";
          description = "Only show git_branch if we're not in a jj repo";
          style = "";
        };
      };

    };
  };
}
