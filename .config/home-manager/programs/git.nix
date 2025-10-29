{ ... }:

{

  home.file = {
    ".githelpers".source = ../../../git/.githelpers;
  };

  programs.git = {
    enable = true;

    settings = {
      # User information
      user = {
        name = "jm96441n";
        email = "john@jmaguire.tech";
      };

      # Git aliases
      aliases = {
        # Recent branches
        rb = "!git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/ | head -20";
        rbr = "!git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/remotes/ | head -20";
        cof = "!git checkout $(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/ | head -21 | fzf)";

        # Code review aliases
        stat = "!git diff --stat $(git merge-base HEAD \"$REVIEW_BASE\")";
        heatmap = "git-heatmap";
        files = "!git diff --name-only $(git merge-base HEAD \"$REVIEW_BASE\") -- :^vendor";
        review = "!nvim -p $(git files) +\"tabdo Gvdiffsplit $REVIEW_BASE\" +\"let g:gitgutter_diff_base = '$REVIEW_BASE'\"";

        # Logging aliases
        head = "!git l -1";
        h = "!git head";
        hp = "!. ~/.githelpers && show_git_head";
        r = "!git l -30";
        ra = "!git r --all";
        l = "!. ~/.githelpers && pretty_git_log";
        la = "!git l --all";

        # Pretty log
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";

        # Commit aliases
        ci = "commit --verbose";
        amend = "commit --verbose --amend";
      };

      # Add interactive settings
      add.interactive.useBuiltin = false;

      # Branch settings
      branch.sort = "-committerdate";

      # Column settings
      column.ui = "auto";

      # Commit settings
      commit.verbose = true;

      # Core settings
      core = {
        excludesfile = "~/.gitignore_global";
        editor = "nvim";
        pager = "delta";
      };

      # Credential settings
      credential.helper = "cache --timeout=3600";

      # Delta (pager) settings
      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
        syntax-theme = "everforest-soft";
      };

      # Diff settings
      diff = {
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
        algorithm = "histogram";
      };

      # Fetch settings
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };

      # Filter settings for LFS
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };

      # Grep settings
      grep.linenumber = true;

      # Help settings
      help.autocorrect = "prompt";

      # Init settings
      init.defaultBranch = "main";

      # Interactive settings
      interactive.diffFilter = "delta --color-only";

      # Merge settings
      merge.conflictstyle = "diff3";

      # Push settings
      push = {
        default = "current";
        autoSetupRemote = true;
        followTags = true;
      };

      # Pull settings
      pull.rebase = true;

      # Rerere settings
      rerere = {
        enabled = true;
        autoupdate = true;
      };

      # Rebase settings
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };

      # Submodule settings
      submodule.recursive = true;

      # URL rewrites
      url."ssh://git@github.com/".insteadOf = "https://github.com/";

      # Conditional includes
      includeIf."gitdir:~/hashi/".path = "~/.dotfiles/git/hashi/.gitconfig";

    };
  };
}
