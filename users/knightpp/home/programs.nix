{
  bash = {
    enable = true;
    initExtra = ''
      shopt -q login_shell && LOGIN_OPTION="--login" || LOGIN_OPTION=""
      exec fish $LOGIN_OPTION
    '';
  };

  fish = {
    enable = true;

    shellAbbrs = {
      gs = "git status";
      gd = "git diff";
    };

    interactiveShellInit = ''
      set fish_greeting
    '';

    functions = {
      gitignore = "curl -sL https://www.gitignore.io/api/$argv";
    };
  };

  helix = {
    enable = true;
    settings = import ./helix-settings.nix;
  };

  bat = {
    enable = true;
    config = {
      map-syntax = [
        "*.jenkinsfile:Groovy"
        "*.props:Java Properties"
      ];
      pager = "less -FR";
      theme = "TwoDark";
    };
  };

  bottom = {
    enable = true;
    settings = {
      flags = {
        mem_as_value = true;
        group_processes = true;
        unnormalized_cpu = true;
      };
    };
  };

  eza = {
    enable = true;
    enableAliases = true;
    extraOptions = [
      "--group-directories-first"
    ];
    git = true;
  };

  git = {
    enable = true;
    difftastic.enable = true;
    extraConfig = {
      init.defaultbranch = "main";
      rerere.enabled = true;
      column.ui = "auto";
      branch.sort = "-committerdate";
      fetch.writeCommitGraph = true;
      core.fsmonitor = true;
    };

    userName = "Danylo Kondratiev";
    userEmail = "knightpp@proton.me";
  };

  starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      gcloud.disabled = true;
      character = {
        success_symbol = "[λ](bold green)";
        error_symbol = "[λ](bold red)";
      };
      git_metrics.disabled = true;
    };
  };

  tealdeer = {
    enable = true;
  };

  fzf = {
    enable = true;
    enableFishIntegration = false; # I use custom fish plugin for fuzzy search
  };

  fd = {
    enable = true;
    ignores = ["vendor/" ".git/" "node_modules/"];
  };

  gh.enable = true;

  ripgrep.enable = true;

  atuin.enable = true;
}
