{
  config,
  pkgs,
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
        "docker"
        "plugdev" # probably for qmk keyboards
        "dialout" # for serial ports (esp32)
        config.users.groups.keys.name # sops
      ];
      initialHashedPassword = "$6$pgzhN8I3kJ1O35mZ$dzoVn596Htt3Jc7S1ftGyRnoxHmqvNpY.ZKtN3c/j5y0K3ZlbpwbaMaA6Mw5XnuVQxrDQ0184dkMtZp98thXU1";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG86t/Sa1mUjJtz7my7fhS0UvK3za5JCOyTw4u58rwvv Personal SSH"
      ];
    };
  };
  users.groups = {
    knightpp = {};
    plugdev = {};
  };
  nix.settings.trusted-users = ["knightpp"];

  home-manager.users.knightpp = {
    home = {
      stateVersion = config.system.stateVersion;
      shellAliases = {
        gs = "git status";
      };

      sessionVariables = {
        EDITOR = "hx";
      };

      packages = import ./home/packages.nix pkgs;
    };

    programs = import ./home/programs.nix pkgs;

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
  };
}
