{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.home-manager.tools;
in
{
  options.modules.home-manager.tools = {
    enable = lib.mkEnableOption "Tools";
    interactive = lib.mkEnableOption "interactive";
  };

  config =
    let
      interactive = lib.mkIf cfg.interactive {
        home = {
          packages = builtins.attrValues {
            inherit (pkgs)
              nil
              nix-init
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
              go-tools
              gopls
              delve
              gomodifytags
              # Rust
              rustup
              # Elixir
              elixir
              elixir-ls
              #
              taplo # toml LSP
              ;
          };
        };

        programs = {
          gh.enable = true;
          go.enable = true;
        };

        xdg.configFile."ghostty/config".text = ''
          theme = GruvboxDark
          # I launch fish from bash, so autodetect does not work
          shell-integration = fish
          # cursor feature sets cursor to blinking bar forcibly
          shell-integration-features = no-cursor, sudo, title
          cursor-style = block
          # font-size = 12
          font-family = FiraCode Nerd Font
          auto-update = off

          keybind = alt+m=goto_split:left
          keybind = alt+n=goto_split:bottom
          keybind = alt+e=goto_split:top
          keybind = alt+i=goto_split:right

          keybind = alt+s=new_split:auto
          keybind = alt+h=new_split:down
          keybind = alt+l=new_split:right

          keybind = alt+p=write_scrollback_file:paste
          keybind = alt+b=write_scrollback_file:open

          keybind = page_up=scroll_page_up
          keybind = page_down=scroll_page_down
        '';

        # Provide offline documentation for home-manager
        manual.html.enable = true;
      };

      server = lib.mkIf cfg.enable {
        home = {
          sessionVariables = {
            EDITOR = "${pkgs.helix}/bin/hx"; # also can be configured with "defaultEditor", but does not work
            PAGER = "${pkgs.less} -FRX";
          };
          sessionPath = [ "$HOME/.local/bin" ];

          packages = builtins.attrValues {
            inherit (pkgs.fishPlugins) # install fish plugins system wide
              fzf-fish
              autopair
              done
              ;

            inherit (pkgs)
              du-dust
              tokei
              nvd # nix differ
              gitui
              jujutsu # better git
              watchman # jj needs it to monitor fs
              ;
          };
        };

        xdg.configFile."jj/config.toml".source =
          let
            toml = pkgs.formats.toml { };
          in
          toml.generate "config.toml" {
            "$schema" = "https://jj-vcs.github.io/jj/latest/config-schema.json";

            user = {
              name = "Danylo Kondratiev";
              email = "knightpp@proton.me";
            };

            core = {
              fsmonitor = "watchman";
              watchman.register_snapshot_trigger = false;
            };

            ui = {
              default-command = "log";
              diff.tool = [
                "${lib.getExe pkgs.difftastic}"
                "--color=always"
                "$left"
                "$right"
              ];

              movement = {
                # changes jj next, jj prev to always --edit
                # edit = true
              };
            };

            git = {
              # Prevent pushing anything explicitly labeled "private"
              private-commits = "description(glob:'private:*')";
            };

            aliases = {
              mb = [
                "bookmark"
                "move"
                "--from"
                "heads(::@- & bookmarks())"
                "--to"
                "@-"
              ];
            };

            # see fileset syntax https://jj-vcs.github.io/jj/latest/filesets/
            fix.tools = {
              gofumpt = {
                command = [
                  "${lib.getExe pkgs.gofumpt}"
                  "$path"
                ];
                patterns = [ "glob:'**/*.go' ~ (vendor/ & glob:'**/mocks/**')" ];
              };

              prettier = {
                command = [
                  "${lib.getExe pkgs.nodePackages.prettier}"
                  "$path"
                ];
                patterns = [ "(glob:'**/*.yaml' & glob:'**/*.yml' & glob:'**/*.md') ~ vendor/" ];
              };

              nix = {
                command = [
                  "${lib.getExe pkgs.nixfmt-rfc-style}"
                  "--filename=$path"
                ];
                patterns = [ "glob:'**/*.nix' ~ vendor/" ];
              };
            };
          };

        manual.html.enable = lib.mkDefault false;
        news.display = "show";

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
              gu = "gitui";
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
            settings = import ./helix-settings.nix { inherit lib; };
            ignores = [
              "vendor"
              "node_modules"
              "_build"
            ];

            languages = {
              # see https://github.com/helix-editor/helix/blob/master/languages.toml
              language-server = {
                elixir-ls = {
                  config = {
                    elixirLS.autoBuild = true;
                    elixirLS.dialyzerEnabled = true;
                    elixirLS.suggestSpecs = true;
                  };
                };

                gopls = {
                  config = {
                    "ui.documentation.hints" = {
                      assignVariableTypes = false;
                      compositeLiteralFields = false;
                      constantValues = false;
                      functionTypeParameters = false;
                      parameterNames = false;
                      rangeVariableTypes = false;
                    };

                    "ui.diagnostic.staticcheck" = true;
                    "ui.diagnostic.analyses" = {
                      useany = true;
                      unusedvariable = true;
                    };
                    "formatting.gofumpt" = true;
                  };
                };
              };
              language = [
                {
                  name = "nix";
                  auto-format = true;
                  formatter.command = "${lib.getExe pkgs.nixfmt-rfc-style}";
                }
                {
                  name = "go";
                  auto-format = true;
                  # formatter.command = "${lib.getExe pkgs.gofumpt}";
                }
                {
                  name = "elixir";
                  auto-format = true;
                  diagnostic-severity = "hint";
                  language-servers = [ "elixir-ls" ];
                }
                {
                  name = "heex";
                  language-servers = [ "elixir-ls" ];
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
                process_memory_as_value = true;
                group_processes = true;
                unnormalized_cpu = true;
                enable_cache_memory = true;
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
              push.autoSetupRemote = true;
            };
            lfs.enable = true;

            aliases = {
              co = "checkout";
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
              sudo.disabled = true;
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
            ignores = [
              "vendor/"
              ".git/"
              "node_modules/"
            ];
          };

          ripgrep.enable = true;

          atuin = {
            enable = true;
            enableBashIntegration = false;
            flags = [ "--disable-up-arrow" ];
          };

          direnv = {
            enable = true;

            enableBashIntegration = false;
            enableNushellIntegration = false;
            enableZshIntegration = false;

            nix-direnv.enable = true;
          };
        };
      };
    in
    lib.mkMerge [
      server
      interactive
    ];
}
