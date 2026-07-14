{
  description = "Phenix workspace superflake aggregating all subflakes";

  nixConfig = {
    extra-substituters = [ "https://hyprland.cachix.org" ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    phenix-pins = {
      url = "github:matthis-k/phenix-pins";
      inputs.flake-parts.follows = "flake-parts";
    };
    nixpkgs.follows = "phenix-pins/nixpkgs";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    phenix-packages = {
      url = "github:matthis-k/phenix-packages";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        phenix-tend.follows = "phenix-tend";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    phenix-tend = {
      url = "github:matthis-k/phenix-tend";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    phenix-stitch = {
      url = "github:matthis-k/phenix-stitch";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        phenix-tend.follows = "phenix-tend";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    phenix-nvim = {
      url = "github:matthis-k/phenix-nvim";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        phenix-tend.follows = "phenix-tend";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    phenix-de = {
      url = "github:matthis-k/phenix-de";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        phenix-tend.follows = "phenix-tend";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "phenix-pins/home-manager";
      };
    };

    phenix-hosts = {
      url = "github:matthis-k/phenix-hosts/cleanup/den-flake-structure";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        phenix-tend.follows = "phenix-tend";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "phenix-pins/home-manager";
        sops-nix.follows = "phenix-pins/sops-nix";
        disko.follows = "disko";
        phenix-de.follows = "phenix-de";
        phenix-nvim.follows = "phenix-nvim";
        phenix-agent-harness.follows = "phenix-agent-harness";
      };
    };

    phenix-agent-harness = {
      url = "github:matthis-k/phenix-agent-harness";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        phenix-tend.follows = "phenix-tend";
        phenix-stitch.follows = "phenix-stitch";
        nixpkgs.follows = "nixpkgs";
      };
    };

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        ./phenix-module.nix
        ./phenix-wrappers.nix
        ./phenix-re-exports.nix
        ./phenix-helpers.nix
        inputs.phenix-packages.flakeModules.default
        inputs.phenix-de.flakeModules.default
        inputs.phenix-nvim.flakeModules.default
        inputs.phenix-tend.flakeModules.default
        inputs.phenix-stitch.flakeModules.default
        inputs.phenix-agent-harness.flakeModules.default
        inputs.git-hooks-nix.flakeModule
      ];

      perSystem =
        {
          system,
          pkgs,
          lib,
          config,
          ...
        }:
        let
          tendPkg = inputs.phenix-tend.packages.${system}.tend;
          stitchPkg = inputs.phenix-stitch.packages.${system}.stitch;
          piPkg = inputs.phenix-agent-harness.packages.${system}.pi;
          rustToolchain = [
            pkgs.cargo
            pkgs.rustc
            pkgs.rustfmt
            pkgs.clippy
          ];
        in
        {
          phenix = {
            inherit tendPkg stitchPkg;
          };

          packages.pi = piPkg;

          apps = {
            tend = inputs.phenix-tend.apps.${system}.tend;
            stitch = inputs.phenix-stitch.apps.${system}.stitch;
            phenix-shell = inputs.phenix-de.apps.${system}.phenix-shell;
            default = inputs.phenix-stitch.apps.${system}.stitch;
          };

          pre-commit = {
            check.enable = false;

            settings.hooks = {
              tend-pre-commit = {
                enable = true;
                name = "tend pre-commit";
                description = "Run the staged root checks through Tend";
                entry = "${pkgs.nix}/bin/nix develop .#default --command ${tendPkg}/bin/tend check --profile git-hook --context local";
                pass_filenames = false;
                always_run = true;
                stages = [ "pre-commit" ];
              };

              tend-pre-push = {
                enable = true;
                name = "tend pre-push";
                description = "Run the complete root pre-push gate through Tend";
                entry = "${pkgs.nix}/bin/nix develop .#default --command ${tendPkg}/bin/tend check --profile pre-push --context local";
                pass_filenames = false;
                always_run = true;
                stages = [ "pre-push" ];
              };
            };
          };

          checks.tend-nix-check =
            pkgs.runCommand "tend-nix-check"
              {
                nativeBuildInputs = [
                  tendPkg
                  stitchPkg
                  pkgs.git
                  pkgs.jq
                  pkgs.nix
                  pkgs.nixfmt
                  pkgs.statix
                  pkgs.deadnix
                ]
                ++ rustToolchain;
              }
              ''
                cp -r ${lib.cleanSource ./.} source
                chmod -R u+w source
                cd source

                export HOME=$TMPDIR/home
                mkdir -p "$HOME"
                export NIX_STATE_DIR=$TMPDIR/nix-state
                mkdir -p "$NIX_STATE_DIR/profiles"
                export NIX_PATH=nixpkgs=${pkgs.path}

                git init --quiet
                git add -A

                ${stitchPkg}/bin/stitch graph verify --workspace . --source locks --strict
                ${tendPkg}/bin/tend check --profile git-hook --context local

                touch "$out"
              '';

          devShells.test = pkgs.mkShell {
            name = "phenix-test";
            packages =
              with pkgs;
              [
                git
                nix
                jq
                ripgrep
                tendPkg
                stitchPkg
              ]
              ++ rustToolchain;
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = [ config.pre-commit.devShell ];

            packages =
              with pkgs;
              [
                git
                gh
                jq
                ripgrep
                fd
                statix
                deadnix
                nixfmt
                piPkg
                tendPkg
                stitchPkg
              ]
              ++ rustToolchain;

            shellHook = ''
              ${config.pre-commit.installationScript}
              ${config.phenix.shellHook}
            '';
          };
        };
    };
}
