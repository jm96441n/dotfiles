{ config, pkgs, ... }:

let
  jj-extra = pkgs.fetchFromGitHub {
    owner = "imp";
    repo = "jj-extra";
    rev = "66787451896bbfabe7219b39aa54336ff5677b6a";
    sha256 = "sha256-jKPBkTFOhS5q4H4XW+oPCIspmiX6qJYlKEy+HjmbztY=";
  };
in
{

  home.file = {
    ".oh-my-zsh/custom/plugins/fzf-tab" = {
      source = pkgs.fetchFromGitHub {
        owner = "Aloxaf";
        repo = "fzf-tab";
        rev = "v1.2.0";
        sha256 = "sha256-q26XVS/LcyZPRqDNwKKA9exgBByE0muyuNb0Bbar2lY=";
      };
      recursive = true;
    };
    ".oh-my-zsh/custom/plugins/zsh-autosuggestions" = {
      source = pkgs.fetchFromGitHub {
        owner = "zsh-users";
        repo = "zsh-autosuggestions";
        rev = "85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5";
        sha256 = "sha256-KmkXgK1J6iAyb1FtF/gOa0adUnh1pgFsgQOUnNngBaE=";
      };
      recursive = true;
    };
    ".oh-my-zsh/custom/plugins/zsh-syntax-highlighting" = {
      source = pkgs.fetchFromGitHub {
        owner = "zsh-users";
        repo = "zsh-syntax-highlighting";
        rev = "5eb677bb0fa9a3e60f0eff031dc13926e093df92";
        sha256 = "sha256-KRsQEDRsJdF7LGOMTZuqfbW6xdV5S38wlgdcCM98Y/Q=";
      };
      recursive = true;
    };
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    sessionVariables = {
      GOPATH = "$HOME/go";
      GOPRIVATE = "github.com/hashicorp/*";
      FZF_DEFAULT_COMMAND = "rg --files --hidden -g \"!.git/\"";
      # To apply the command to CTRL-T as well
      FZF_CTRL_T_COMMAND = "fd --type directory";
    };

    shellAliases = {
      "reload" = "exec zsh";

      # Directory traversal
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # eza
      "ls" = "eza --icons -x -a --group-directories-first";
      "ll" = "eza --icons -a -l";
      "lt" = "eza --tree";
      "ltl" = "eza --tree -L";
      "lr" = "eza --recurse";

      # cht.sh
      "cht" = "tmux-cht";

      # Map vim to use neovim
      "v" = "nvim";

      # common typos
      "gaap" = "gapa";

      "tcig" = "tmux-sessionizer $HOME/hashi/cloud-infragraph";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    oh-my-zsh = {
      # "ohMyZsh" without Home Manager
      enable = true;
      plugins = [
        "autojump"
        "direnv"
        "fzf"
        # "fzf-tab"
        "git"
        "git-extras"
        "git-prompt"
        "kubectl"
        "terraform"
        "tmux"
        "tmuxinator"
        # "zsh-syntax-highlighting"
      ];
    };
    initContent = ''
      # User configuration
      DOTFILES_DIR="$HOME/.dotfiles"


      # Finally we can source the dotfiles (order matters)
      for DOTFILE in "$DOTFILES_DIR"/system/.{function,private_function,private_env,private_alias}; do
        [ -f "$DOTFILE" ] && . "$DOTFILE"
      done

      # Fastfetch on terminal start
      if command -v fastfetch >/dev/null 2>&1; then
          fastfetch
      fi

      # Custom key bindings
      bindkey -s ^f "tmux-sessionizer\n"
      bindkey -s ^bd "tmux-sessionizer ~/dotfiles\n"

      source ${jj-extra}/jj-extra.plugin.zsh
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fastfetch.enable = true;
}
