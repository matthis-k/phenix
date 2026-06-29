{
  description = "Phenix workspace superflake aggregating all subflakes";

  # Enable submodule support so path: inputs into submodule dirs work
  inputs.self.submodules = true;

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    phenix-pins.url = ./flakes/00-pins/phenix-pins;
    nixpkgs.follows = "phenix-pins/nixpkgs";

    phenix-packages = {
      url = ./flakes/04-pkgs/phenix-packages;
      inputs.phenix-pins.follows = "phenix-pins";
    };

    phenix-tend = {
      url = ./flakes/02-producers/phenix-tend;
      inputs.phenix-pins.follows = "phenix-pins";
    };
    phenix-stitch = {
      url = ./flakes/02-producers/phenix-stitch;
      inputs.phenix-pins.follows = "phenix-pins";
      inputs.phenix-tend.follows = "phenix-tend";
    };

    phenix-nvim = {
      url = ./flakes/02-producers/phenix-nvim;
      inputs.phenix-pins.follows = "phenix-pins";
    };

    phenix-de = {
      url = ./flakes/05-consumers/phenix-de;
      inputs.phenix-pins.follows = "phenix-pins";
    };

    phenix-hosts = {
      url = ./flakes/05-consumers/phenix-hosts;
      inputs.phenix-pins.follows = "phenix-pins";
    };

    phenix-opencode = {
      url = ./flakes/03-integrations/phenix-opencode;
      inputs = {
        phenix-pins.follows = "phenix-pins";
        phenix-tend.follows = "phenix-tend";
        phenix-stitch.follows = "phenix-stitch";
      };
    };

    git-hooks-nix.url = "github:cachix/git-hooks.nix";
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
        inputs.phenix-packages.flakeModules.default
        inputs.phenix-de.flakeModules.default
        inputs.phenix-nvim.flakeModules.default
        inputs.phenix-hosts.flakeModules.default
        inputs.phenix-tend.flakeModules.default
        inputs.phenix-stitch.flakeModules.default
        inputs.phenix-opencode.flakeModules.default
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
          rustToolchain = [
            pkgs.cargo
            pkgs.rustc
            pkgs.rustfmt
            pkgs.clippy
          ];
        in
        {
          packages.opencode = inputs.phenix-opencode.packages.${system}.default;

          apps = {
            tend = inputs.phenix-tend.apps.${system}.tend;
            stitch = inputs.phenix-stitch.apps.${system}.stitch;
            default = inputs.phenix-stitch.apps.${system}.stitch;
          };

          pre-commit = {
            check.enable = false;

            settings = {
              hooks = {
                tend-pre-commit = {
                  enable = true;
                  name = "tend pre-commit";
                  description = "Run fast Tend checks on staged changes (inside Nix dev shell)";
                  entry = "nix develop .#default --command ${tendPkg}/bin/tend check --profile git-hook --staged --affected-dag";
                  pass_filenames = false;
                  always_run = true;
                  stages = [ "pre-commit" ];
                };

                tend-pre-push = {
                  enable = true;
                  name = "tend pre-push";
                  description = "Run medium Tend checks with affected-DAG before push (inside Nix dev shell)";
                  entry = "${pkgs.nix}/bin/nix develop .#default --command ${tendPkg}/bin/tend check --profile pre-push --affected-dag";
                  pass_filenames = false;
                  always_run = true;
                  stages = [ "pre-push" ];
                };

              };
            };
          };

          checks = {
            tend-nix-check =
              pkgs.runCommand "tend-nix-check"
                {
                  nativeBuildInputs = [
                    tendPkg
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

                  ${tendPkg}/bin/tend validate --profiles
                  ${tendPkg}/bin/tend check --profile nix-check --offline --locked

                  touch $out
                '';
          };

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
            inputsFrom = [
              config.pre-commit.devShell
            ];

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
                inputs.phenix-opencode.packages.${system}.default
                tendPkg
                stitchPkg
              ]
              ++ rustToolchain;

            shellHook = ''
              ${config.pre-commit.installationScript}

              repo-hook() {
                ${tendPkg}/bin/tend check --profile git-hook --staged --affected-dag "$@"
              }

              repo-pushgate() {
                ${tendPkg}/bin/tend check --profile pre-push --affected-dag "$@"
              }

              repo-check() {
                ${tendPkg}/bin/tend check --profile manual "$@"
              }

              repo-fix() {
                ${tendPkg}/bin/tend check --profile fix "$@"
              }

              repo-hooks-plan() {
                ${stitchPkg}/bin/stitch hooks plan --all "$@"
              }

              repo-install-all-hooks() {
                ${stitchPkg}/bin/stitch hooks install --all "$@"
              }

              export -f repo-hook repo-pushgate repo-check repo-fix repo-hooks-plan repo-install-all-hooks 2>/dev/null || true

              echo "Phenix development shell"
              echo "  tools: git gh jq ripgrep fd statix deadnix nixfmt opencode"
              echo "  tend: distributed maintenance/check harness"
              echo "  stitch: coordinated multi-repo git tool"
              echo "  repo-hook           -> tend check --profile git-hook --staged --affected-dag"
              echo "  repo-pushgate       -> tend check --profile pre-push --affected-dag"
              echo "  repo-check          -> tend check --profile manual"
              echo "  repo-fix            -> tend check --profile fix"
              echo "  repo-hooks-plan     -> stitch hooks plan --all"
              echo "  repo-install-all-hooks -> stitch hooks install --all"
            '';
          };
        };
    };
}
