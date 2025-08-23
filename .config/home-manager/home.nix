{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "johmaguire";
  home.homeDirectory = "/home/johnmaguire";

  # This value determines the Home Manager release that your configuration is
  # compatible with
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Packages that should be installed to the user profile
  home.packages = with pkgs; [
    # CLI tools
    autojump
    bat
    curl
    delta  # for git pager
    direnv
    exa
    fd
    fzf
    fastfetch
    git
    git-extras
    git-lfs
    htop
    jq
    kubectl
    mise
    neovim
    nixfmt-rfc-style
    ripgrep
    starship
    tmux
    tree
    tmuxinator
    terraform
    unzip
    vim
    wget
  ];

  imports = [
    "./programs/git.nix"
    "./programs/zsh.nix"
    "./programs/ssh-agent.nix"
  ];

  
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      "reload"="exec zsh"

      # Directory traversal
      ".."="cd .."
      "..."="cd ../.."
      "...."="cd ../../.."

      # eza
      "ls"="eza --icons -x -a --group-directories-first"
      "ll"="eza --icons -a -l"
      "lt"="eza --tree"
      "ltl"="eza --tree -L"
      "lr"="eza --recurse"

      # cht.sh
      "cht"="tmux-cht"


      # Map vim to use neovim
      "v"="nvim"

      # useful shortcuts for editing config files
      "zr"="vim ~/.dotfiles/runcom/.zshrc"
      "txr"="vim ~/.dotfiles/runcom/.tmux.conf"

      # common typos
      "gaap"="gapa"
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    oh-my-zsh = { # "ohMyZsh" without Home Manager
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
    initExtra = ''
      # User configuration
      DOTFILES_DIR="$HOME/dotfiles"

      # Finally we can source the dotfiles (order matters)
      for DOTFILE in "$DOTFILES_DIR"/system/.{function,private_function,path,private_env,private_alias,completion,custom}; do
        [ -f "$DOTFILE" ] && . "$DOTFILE"
      done

      # Fastfetch on terminal start
      if command -v fastfetch >/dev/null 2>&1; then
          fastfetch
      fi

      # Custom key bindings
      bindkey -s ^f "tmux-sessionizer\n"
      bindkey -s ^bd "tmux-sessionizer ~/dotfiles\n"
    '';
  };


  # Dotfiles as plain files
  home.file = {
    ".vimrc".text = ''
      set number
      set relativenumber
      set tabstop=2
      set shiftwidth=2
      set expandtab
      " Add your vim config here
    '';
    
    # You can also source existing dotfiles
    # ".tmux.conf".source = ./dotfiles/tmux.conf;
  };


  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    ZSH_PATH = "${pkgs.zsh}/bin/zsh";
    SHELL = "${pkgs.zsh}/bin/zsh";
    DOTFILES_DIR = "$HOME/dotfiles";
  };
}
