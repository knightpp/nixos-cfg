{ config, pkgs, lib, ... }: {
  users.users = {
    root = {
      initialHashedPassword = "$6$pgzhN8I3kJ1O35mZ$dzoVn596Htt3Jc7S1ftGyRnoxHmqvNpY.ZKtN3c/j5y0K3ZlbpwbaMaA6Mw5XnuVQxrDQ0184dkMtZp98thXU1";
    };
    knightpp = {
      isNormalUser = true;
      group = "knightpp";
      extraGroups = [ "nixoscfg" "networkmanager" "systemd-journal" ];
      initialHashedPassword = "$6$pgzhN8I3kJ1O35mZ$dzoVn596Htt3Jc7S1ftGyRnoxHmqvNpY.ZKtN3c/j5y0K3ZlbpwbaMaA6Mw5XnuVQxrDQ0184dkMtZp98thXU1";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG86t/Sa1mUjJtz7my7fhS0UvK3za5JCOyTw4u58rwvv Personal SSH"
      ];
    };
  };
  users.groups = {
    knightpp = { };
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
      # sessionPath = [
      #  "$HOME/.local/bin"
      #  "$HOME/go/bin"
      # ];
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
    # TODO: test whether this works with NixOS modules
    news.display = "show";

    xdg = {
      userDirs = {
        enable = true;
        createDirectories = true;
      };

      # KDE specific hack to make it use needed locale
      configFile = lib.mkIf config.desktop-environment.kde.enable {
        "plasma-localerc".text = ''
          [Formats]
          LANG=uk_UA.UTF-8

          [Translations]
          LANGUAGE=uk_UA:en_GB:en_US
        '';
      };
    };

    programs = {
      bash = {
        enable = true;
        initExtra = ''
          if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z $BASH_EXECUTION_STRING ]]
          then
          	shopt -q login_shell && LOGIN_OPTION="--login" || LOGIN_OPTION=""
          	exec fish $LOGIN_OPTION
          fi
        '';
      };
      mpv = lib.mkIf config.desktop-environment.enable {
        enable = true;
        config = {
          ao = "pipewire";
          vo = "gpu";
          profile = "gpu-hq";
          hwdec = "auto";

          msg-color = "yes"; # color log messages on terminal
          cache = "yes"; # uses a large seekable RAM cache even for local input.
          # cache-secs=300 # uses extra large RAM cache (needs cache=yes to make it useful).
          demuxer-max-back-bytes = "20M"; # sets fast seeking
          demuxer-max-bytes = "80M"; # sets fast seeking
        };
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
      fish = {
        enable = true;
        plugins = [
          {
            name = "fzf.fish";
            src = pkgs.fetchFromGitHub {
              owner = "PatrickF1";
              repo = "fzf.fish";
              rev = "9876f5f74aab7f58b0359341dc26bf4a0f2e9021";
              sha256 = "sha256-Aqr6+DcOS3U1R8o9Mlbxszo5/Dy9viU4KbmRGXo95R8=";
            };
          }
        ];
        shellAbbrs = {
          gs = "git status";
          gd = "git diff";
        };
        # HACK: without this Ctrl+R does not use plugin's version of search
        interactiveShellInit = ''
          fzf_configure_bindings
        '';
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
      };
    };
  };
}
