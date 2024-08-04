{pkgs, ...}: {
  home = {
    sessionVariables = {
      EDITOR = "${pkgs.helix}/bin/hx"; # also can be configured with "defaultEditor", but does not work
    };

    packages = builtins.attrValues {
      inherit
        (pkgs)
        du-dust
        tokei
        alejandra
        nil
        nix-init
        nvd # nix differ
        nurl # generates nix fetcher expressions based on url
        nix-output-monitor # nom
        
        # linker and C/C++ compiler
        
        gcc
        gdb
        # zig
        
        zig
        zls
        lldb # DAP
        # GO
        
        go
        go-tools
        gopls
        delve
        gomodifytags
        # Rust
        
        rustup
        # Elixir
        
        elixir
        elixir-ls
        ;

      inherit
        (pkgs.fishPlugins) # install fish plugins system wide
        fzf-fish
        autopair
        done
        ;
    };
  };

  programs = {
    bash = {
      enable = true;
      enableVteIntegration = true;

      initExtra = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
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
      defaultEditor = false;
      settings = import ./helix-settings.nix;
      ignores = ["vendor" "node_modules"];

      languages = {
        # see https://github.com/helix-editor/helix/blob/master/languages.toml
        language-server.elixir-ls = {
          config = {
            elixirLS.autoBuild = true;
            elixirLS.dialyzerEnabled = true;
            elixirLS.suggestSpecs = true;
          };
        };
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${pkgs.alejandra}/bin/alejandra";
          }
          {
            name = "go";
            auto-format = true;
            formatter.command = "${pkgs.gofumpt}/bin/gofumpt";
          }
          {
            name = "elixir";
            auto-format = true;
            diagnostic-severity = "Hint";
          }
        ];
      };
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
      enableBashIntegration = false;
      enableFishIntegration = false;
    };

    fd = {
      enable = true;
      ignores = ["vendor/" ".git/" "node_modules/"];
    };

    gh.enable = true;

    ripgrep.enable = true;

    atuin = {
      enable = true;
      enableBashIntegration = false;
      flags = ["--disable-up-arrow"];
    };
  };

  # See https://editorconfig.org/
  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        trim_trailing_whitespace = true;
        insert_final_newline = true;
        max_line_width = 100;
        indent_style = "space";
        indent_size = 4;
      };
      "*.go" = {
        indent_style = "tab";
      };
    };
  };

  # Provide offline documentation for home-manager
  manual.html.enable = true;
  news.display = "show";
}
