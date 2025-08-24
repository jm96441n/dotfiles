{ config, ... }:

{
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

      # useful shortcuts for editing config files
      "zr" = "vim ~/.dotfiles/runcom/.zshrc";
      "txr" = "vim ~/.dotfiles/runcom/.tmux.conf";

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
        # "fzf-tab"
        "git"
        "git-extras"
        "git-prompt"
        "kubectl"
        "terraform"
        "tmux"
        "tmuxinator"
        # "zsh-autosuggestions"
        # "zsh-syntax-highlighting"
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
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
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
