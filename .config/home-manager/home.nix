{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "johnmaguire";
  home.homeDirectory = "/home/johnmaguire";

  # This value determines the Home Manager release that your configuration is
  # compatible with
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Packages that should be installed to the user profile
  home.packages = with pkgs; [
    # CLI tools
    autojump
    bat
    curl
    delta # for git pager
    direnv
    eza
    fd
    fzf
    fastfetch
    git
    git-extras
    git-lfs
    htop
    jq
    kubectl
    mako
    mise
    neovim
    nixfmt-rfc-style
    ripgrep
    starship
    tmux
    tree
    terraform
    unzip
    vim
    wget
  ];

  imports = [
    ./programs/git.nix
    ./programs/mako.nix
    ./programs/ssh-agent.nix
    ./programs/zsh.nix
    ./programs/bat.nix
    ./programs/starship.nix
  ];

  # Dotfiles as plain files
  home.file = {

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
