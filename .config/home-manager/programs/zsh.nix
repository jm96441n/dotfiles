{ config, pkgs, ... }:

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
        "fzf-tab"
        "git"
        "git-extras"
        "git-prompt"
        "kubectl"
        "terraform"
        "tmux"
        "tmuxinator"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
      ];
    };
    initContent = ''
      # User configuration
      DOTFILES_DIR="$HOME/dotfiles"

      # Finally we can source the dotfiles (order matters)
      for DOTFILE in "$DOTFILES_DIR"/system/.{function,private_function,private_env,private_alias,completion,custom}; do
        [ -f "$DOTFILE" ] && . "$DOTFILE"
      done

      # Fastfetch on terminal start
      if command -v fastfetch >/dev/null 2>&1; then
          fastfetch
      fi

      # Custom key bindings
      bindkey -s ^f "tmux-sessionizer\n"
      bindkey -s ^bd "tmux-sessionizer ~/dotfiles\n"

      . /etc/profile.d/nix.sh

      export PATH="/home/johnmaguire/.nix-profile/bin:$PATH"
      export PATH="/nix/var/nix/profiles/default/bin:$PATH"
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
}
