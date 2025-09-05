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
  targets.genericLinux.enable = true;

  # Ensure XDG directories are properly set
  xdg = {
    enable = true;
    mime.enable = true;
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Packages that should be installed to the user profile
  home.packages = with pkgs; [
    # CLI tools
    autoconf
    autojump
    ansible
    ast-grep
    bat
    bison
    bitwarden-cli
    chromium
    cmake
    curl
    claude-code
    delta # for git pager
    direnv
    eza
    fastfetch
    fd
    ffmpeg
    firefox
    fzf
    gcc
    gh
    ghostty
    git
    git-extras
    git-lfs
    helm
    hub
    htop
    icomoon-feather
    imagemagick
    jq
    lazygit
    k9s
    kitty
    kubectl
    gnumake
    mako
    meson
    mise
    neovim
    nerd-fonts.fira-code
    nixfmt-rfc-style
    nmap
    peek
    powertop
    python3
    ranger
    ripgrep
    slack
    starship
    strace
    stylua
    tmux
    tree
    terraform
    unzip
    vlc
    vim
    wget
    yq

    # Media/Graphics
    flameshot

    sway
    swayidle
    swaylock
    swaybg
    waybar
    grim
    slurp
    wofi
    mako
    wl-clipboard
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk

    # Development Libraries (some may work)
    openssl
    sqlite
    zlib

  ];

  fonts.fontconfig.enable = true;

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
    ".tmux.conf".source = ../tmux/.tmux.conf;
    ".tmux.conf.local".source = ../tmux/.tmux.conf.local;
    ".default-gems".source = ../mise/.default-gems;
    ".default-npm-packages".source = ../mise/.default-npm-packages;
    ".default-python-packages".source = ../mise/.default-python-packages;
    ".default-go-packages".source = ../mise/.default-go-packages;
    ".config/mise/config.toml".source = ../mise/mise.toml;
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/.config/nvim";
      recursive = true;
    };
    ".config/wofi" = {
      source = ../wofi;
      recursive = true;
    };
    ".config/waybar" = {
      source = ../waybar;
      recursive = true;
    };
    ".config/sway" = {
      source = ../sway;
      recursive = true;
    };
    ".config/kanshi" = {
      source = ../kanshi;
      recursive = true;
    };
    ".config/ranger" = {
      source = ../ranger;
      recursive = true;
    };
    ".config/kitty" = {
      source = ../kitty;
      recursive = true;
    };
    ".config/k9s" = {
      source = ../k9s;
      recursive = true;
    };
    ".config/ghostty/config".source = ../ghostty/config;
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    ZSH_PATH = "${pkgs.zsh}/bin/zsh";
    SHELL = "${pkgs.zsh}/bin/zsh";
    DOTFILES_DIR = "$HOME/.dotfiles";
  };

  home.sessionPath = [
    "/bin"
    "/usr/bin"
    "/usr/local/bin"
    "$DOTFILES_DIR/bin"
    "$HOME/bin"
    "/sbin"
    "/usr/sbin"
    "/usr/local/sbin"
    "$HOME/go/bin"
    "$HOME/.local/bin"
    "$HOME/.local/bin/nvim/bin"
    "$HOME/.cargo/bin"
  ];

  services.kanshi.enable = true; # Display management
  services.swayidle.enable = true; # Idle management

  xdg.portal.config.common.default = "*";
}
