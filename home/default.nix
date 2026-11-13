{
  config,
  lib,
  pkgs,
  hunk,
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

  news.display = "silent";

  # Packages that should be installed to the user profile
  home.packages = with pkgs; [
    # Cursor theme (sway/wlroots fallback is tiny)
    adwaita-icon-theme

    # CLI tools
    acli
    actionlint
    awscli2
    autoconf
    autojump
    ansible
    ast-grep
    bat
    bison
    bitwarden-cli
    cmake
    codegraph
    curl
    consul
    dolt
    delta # for git pager
    devbox
    direnv
    dolt
    eza
    fastfetch
    fd
    ffmpeg
    fzf
    grim
    gcc
    gh
    git
    git-extras
    git-lfs
    # ghostty
    gnumake
    gomplate
    hcp
    kubernetes-helm
    helix
    herdr
    hub
    hunk.packages.${pkgs.stdenv.hostPlatform.system}.default
    htop
    icomoon-feather
    imagemagick
    jujutsu
    lazygit
    lua5_1
    lua51Packages.luarocks-nix
    k9s
    kitty
    kubectl
    mako
    mariadb
    meson
    mise
    neovim
    nerd-fonts.fira-code
    nixfmt
    nmap
    opencode
    packer
    peek
    pnpm
    powertop
    postgresql
    python3
    ranger
    ripgrep
    sentry-cli
    slurp
    sops
    sshuttle
    ssh-to-age
    starship
    strace
    stylua
    squawk
    tmux
    tree
    terraform
    unzip
    vagrant
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
    ".tmux.conf".source = ../.config/tmux/.tmux.conf;
    ".tmux.conf.local".source = ../.config/tmux/.tmux.conf.local;
    ".default-gems".source = ../.config/mise/.default-gems;
    ".default-npm-packages".source = ../.config/mise/.default-npm-packages;
    ".default-python-packages".source = ../.config/mise/.default-python-packages;
    ".default-go-packages".source = ../.config/mise/.default-go-packages;
    ".config/mise/config.toml".source = ../.config/mise/mise.toml;
    ".config/helix" = {
      source = ../.config/helix;
      recursive = true;
    };
    ".config/mcphub" = {
      source = ../.config/mcphub;
      recursive = true;
    };
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/.config/nvim";
      recursive = true;
    };
    ".config/wofi" = {
      source = ../.config/wofi;
      recursive = true;
    };
    ".config/waybar" = {
      source = ../.config/waybar;
      recursive = true;
    };
    ".config/sway" = {
      source = ../.config/sway;
      recursive = true;
    };
    ".config/ranger" = {
      source = ../.config/ranger;
      recursive = true;
    };
    ".config/kitty" = {
      source = ../.config/kitty;
      recursive = true;
    };
    ".config/opencode" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/.config/opencode";
      recursive = true;
    };
    ".pi" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/.config/pi";
      recursive = true;
    };
    ".config/k9s" = {
      source = ../.config/k9s;
      recursive = true;
    };
    ".config/jj" = {
      source = ../.config/jj;
      recursive = true;
    };
    ".config/herdr/config.toml".source = ../.config/herdr/config.toml;
    # Nix fills in the zsh path (~/.nix-profile on Fedora, /etc/profiles on NixOS).
    ".config/ghostty/config".text = builtins.readFile ../.config/ghostty/config + ''
      command = ${config.programs.zsh.package}/bin/zsh
    '';
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "32";
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

  # Display management
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target"; # This ensures it waits for the graphical session
    settings = [

      {
        profile = {
          name = "external-dp2";
          outputs = [
            {
              criteria = "DP-2";
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
