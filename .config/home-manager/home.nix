{
  config,
  pkgs,
  ...
}:
# let
# nixGLWrap =
# pkg:
# pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
# mkdir $out
# ln -s ${pkg}/* $out
# rm $out/bin
# mkdir $out/bin
# for bin in ${pkg}/bin/*; do
# wrapped_bin=$out/bin/$(basename $bin)
# echo "exec ${nixGLPackages.nixGLNvidia}/bin/nixGLNvidia $bin \$@" > $wrapped_bin
# chmod +x $wrapped_bin
# done
# '';
# in

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
    desktopEntries = {
      # ghostty = {
      # name = "Ghostty";
      # genericName = "Terminal Emulator";
      # exec = "ghostty"; # Just use the wrapped version
      # terminal = false;
      # categories = [
      # "System"
      # "TerminalEmulator"
      # ];
      # icon = "utilities-terminal";
      # };
    };
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
    actionlint
    awscli2
    autoconf
    autojump
    ansible
    ast-grep
    bat
    bison
    bitwarden-cli
    claude-code
    cmake
    curl
    consul
    delta # for git pager
    direnv
    eza
    fastfetch
    fd
    ffmpeg
    flameshot
    fzf
    gcc
    gh
    git
    git-extras
    git-lfs
    # ghostty
    gnumake
    gomplate
    hcp
    helm
    helix
    hub
    htop
    icomoon-feather
    imagemagick
    jujutsu
    j
    lazygit
    lua5_1
    lua51Packages.luarocks-nix
    k9s
    kitty
    kubectl
    localstack
    mako
    mariadb
    meson
    mise
    neovim
    nerd-fonts.fira-code
    nixfmt-rfc-style
    nmap
    packer
    peek
    powertop
    postgresql
    python3
    ranger
    ripgrep
    sentry-cli
    sshuttle
    starship
    strace
    stylua
    squawk
    tmux
    tree
    terraform
    unzip
    vault
    vlc
    vim
    wget
    yq

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
    ".config/helix" = {
      source = ../helix;
      recursive = true;
    };
    ".config/mcphub" = {
      source = ../mcphub;
      recursive = true;
    };
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
    ".config/ranger" = {
      source = ../ranger;
      recursive = true;
    };
    ".config/kitty" = {
      source = ../kitty;
      recursive = true;
    };
    ".config/opencode" = {
      source = ../opencode;
      recursive = true;
    };
    ".config/k9s" = {
      source = ../k9s;
      recursive = true;
    };
    ".config/jj" = {
      source = ../jj;
      recursive = true;
    };
    ".config/ghostty/config".source = ../ghostty/config;
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    ZSH_PATH = "${pkgs.zsh}/bin/zsh";
    SHELL = "${pkgs.zsh}/bin/zsh";
    DOTFILES_DIR = "$HOME/.dotfiles";
    GOLANG_PROTOBUF_REGISTRATION_CONFLICT = "ignore";
  };

  # These are only sourced on login, they are not set when
  # starting a new shell session
  home.sessionPath = [
    "/bin"
    "/usr/bin"
    "/usr/local/bin"
    "$DOTFILES_DIR/bin"
    "$HOME/bin"
    "/sbin"
    "/usr/sbin"
    "/usr/local/sbin"
    "$HOME/hashi/cloud-sre/bin"
    "$HOME/go/bin"
    "$HOME/.local/bin"
    "$HOME/.local/bin/nvim/bin"
    "$HOME/.cargo/bin"
    "$HOME/.opencode/bin"
  ];

  home.file = {
    "projects/ast-grep-mcp" = {
      source = pkgs.fetchFromGitHub {
        owner = "ast-grep";
        repo = "ast-grep-mcp";
        rev = "main";
        sha256 = "sha256-cn+bKrnQbTeWd3kE5NZ2FnxxS+juQZsH1NqYEPBtEOo=";
      };
      recursive = true;
    };
  };
  # Display management
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target"; # This ensures it waits for the graphical session
    settings = [
      {
        profile = {
          name = "external-dp3";
          outputs = [
            {
              criteria = "DP-3";
              status = "enable";
              mode = "3440x1440";
              position = "0,0";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        };
      }

      # Profile for when external monitor DP-4 is connected
      {
        profile = {
          name = "external-dp4";
          outputs = [
            {
              criteria = "DP-4";
              status = "enable";
              mode = "3440x1440";
              position = "0,0";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        };
      }

      {
        profile = {
          name = "external-dp5";
          outputs = [
            {
              criteria = "DP-5";
              status = "enable";
              mode = "3440x1440";
              position = "0,0";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        };
      }

      {
        profile = {
          name = "external-dp6";
          outputs = [
            {
              criteria = "DP-6";
              status = "enable";
              mode = "3440x1440";
              position = "0,0";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        };
      }

      {
        profile = {
          name = "wayland-laptop";
          outputs = [
            {
              criteria = "WL-1";
              status = "enable";
              position = "0,0";
            }
          ];
        };
      }

      # Profile for when only laptop screen is available
      {
        profile = {
          name = "laptop-only";
          outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              position = "0,0";
            }
          ];
        };
      }
    ];
  };

  services.gnome-keyring.enable = true;

  # services.swayidle.enable = true; # Idle management

  xdg.portal.config.common.default = "*";

}
