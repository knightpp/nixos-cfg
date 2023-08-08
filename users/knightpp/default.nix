{
  config,
  pkgs,
  lib,
  ...
}: {
  users.users = {
    root = {
      initialHashedPassword = "$6$pgzhN8I3kJ1O35mZ$dzoVn596Htt3Jc7S1ftGyRnoxHmqvNpY.ZKtN3c/j5y0K3ZlbpwbaMaA6Mw5XnuVQxrDQ0184dkMtZp98thXU1";
    };
    knightpp = {
      shell = pkgs.fish;
      isNormalUser = true;
      group = "knightpp";
      extraGroups = [
        "nixoscfg"
        "networkmanager"
        "systemd-journal"
        "dialout" # for serial ports (esp32)
      ];
      initialHashedPassword = "$6$pgzhN8I3kJ1O35mZ$dzoVn596Htt3Jc7S1ftGyRnoxHmqvNpY.ZKtN3c/j5y0K3ZlbpwbaMaA6Mw5XnuVQxrDQ0184dkMtZp98thXU1";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG86t/Sa1mUjJtz7my7fhS0UvK3za5JCOyTw4u58rwvv Personal SSH"
      ];
    };
  };
  users.groups = {
    knightpp = {};
  };

  home-manager.users.knightpp = {
    home = {
      stateVersion = config.system.stateVersion;
      language = {
        base = "uk_UA.UTF-8";
        messages = "en_US.UTF-8";
      };
      shellAliases = {
        gs = "git status";
      };
      sessionVariables = {
        DOCKER_HOST = "unix:///var/run/user/1000/podman/podman.sock";
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

    xdg = {
      userDirs = {
        enable = true;
        createDirectories = true;
      };
    };

    programs = {
      bash.enable = true;

      fish = {
        enable = true;
        shellAbbrs = {
          gs = "git status";
          gd = "git diff";
        };
        interactiveShellInit = ''
          set fish_greeting
        '';
      };

      neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
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

      broot = {
        enable = true;
        enableFishIntegration = true;
      };

      exa = {
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
        enableFishIntegration = false; # I use custom fish plugin for fuzzy search
        enableZshIntegration = false;
      };
    };
  };
}
