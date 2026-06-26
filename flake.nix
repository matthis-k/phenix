{
  description = "Phenix workspace superflake aggregating all subflakes";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.follows = "phenix-pins/nixpkgs";
    phenix-pins.url = "github:matthis-k/phenix-pins";

    phenix-packages.url = "github:matthis-k/phenix-packages";
    phenix-packages.inputs.phenix-pins.follows = "phenix-pins";

    phenix-de.url = "github:matthis-k/phenix-de";
    phenix-de.inputs.phenix-pins.follows = "phenix-pins";

    phenix-nvim.url = "github:matthis-k/phenix-nvim";
    phenix-nvim.inputs.phenix-pins.follows = "phenix-pins";

    phenix-hosts.url = "github:matthis-k/phenix-hosts";
    phenix-hosts.inputs.phenix-pins.follows = "phenix-pins";

    # TODO: switch back to github: when both repos are pushed
    phenix-tools.url = "git+file:./flakes/02-producers/phenix-tools";
    # phenix-tools.url = "github:matthis-k/phenix-tools";
    # phenix-tools.inputs.phenix-pins.follows = "phenix-pins";

    git-hooks-nix.url = "github:cachix/git-hooks.nix";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      imports = [
        ./phenix-module.nix
        inputs.phenix-packages.flakeModules.default
        inputs.phenix-de.flakeModules.default
        inputs.phenix-nvim.flakeModules.default
        inputs.phenix-hosts.flakeModules.default
        inputs.phenix-tools.flakeModules.default
        inputs.git-hooks-nix.flakeModule
      ];

      perSystem = { system, pkgs, lib, config, ... }:
      let
        tendPkg = inputs.phenix-tools.packages.${system}.tend;
        stitchPkg = inputs.phenix-tools.packages.${system}.stitch;
        rustToolchain = [ pkgs.cargo pkgs.rustc pkgs.rustfmt pkgs.clippy ];
      in {
        packages.opencode = pkgs.opencode;

        apps.tend = inputs.phenix-tools.apps.${system}.tend;
        apps.stitch = inputs.phenix-tools.apps.${system}.stitch;
        apps.default = inputs.phenix-tools.apps.${system}.stitch;

        pre-commit = {
          check.enable = true;

          settings = {
            hooks = {
              tend-pre-commit = {
                enable = true;
                name = "tend pre-commit";
                description = "Run fast Tend checks on staged changes";
                entry = "${tendPkg}/bin/tend check --profile git-hook --staged";
                pass_filenames = false;
                always_run = true;
                stages = [ "pre-commit" ];
              };

              tend-pre-push = {
                enable = true;
                name = "tend pre-push";
                description = "Run medium Tend checks before push";
                entry = "${tendPkg}/bin/tend check --profile pre-push";
                pass_filenames = false;
                always_run = true;
                stages = [ "pre-push" ];
              };
            };
          };
        };

        checks = {
          tend-nix-check = pkgs.runCommand "tend-nix-check"
            {
              nativeBuildInputs = [
                tendPkg
                pkgs.git
              ] ++ rustToolchain;
            }
            ''
              cp -r ${lib.cleanSource ./.} source
              chmod -R u+w source

              # Merge submodule content from the flake input
              cp -rT ${inputs.phenix-tools} source/flakes/02-producers/phenix-tools
              chmod -R u+w source/flakes/02-producers/phenix-tools

              cd source

              ${tendPkg}/bin/tend validate --profiles

              ${tendPkg}/bin/tend check --profile nix-check --offline --locked

              touch $out
            '';
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [
            config.pre-commit.devShell
          ];

          packages = with pkgs; [
            git
            gh
            jq
            ripgrep
            fd
            statix
            deadnix
            nixfmt-rfc-style
            opencode
            tendPkg
            stitchPkg
          ] ++ rustToolchain;

          shellHook = ''
            ${config.pre-commit.installationScript}

            repo-hook() {
              ${tendPkg}/bin/tend check --profile git-hook --staged "$@"
            }

            repo-pushgate() {
              ${tendPkg}/bin/tend check --profile pre-push "$@"
            }

            repo-check() {
              ${tendPkg}/bin/tend check --profile manual "$@"
            }

            repo-fix() {
              ${tendPkg}/bin/tend check --profile fix "$@"
            }

            export -f repo-hook repo-pushgate repo-check repo-fix 2>/dev/null || true

            echo "Phenix development shell"
            echo "  tools: git gh jq ripgrep fd statix deadnix nixfmt opencode"
            echo "  tend: distributed maintenance/check harness"
            echo "  stitch: coordinated multi-repo git tool"
            echo "  repo-hook      -> tend check --profile git-hook --staged"
            echo "  repo-pushgate  -> tend check --profile pre-push"
            echo "  repo-check     -> tend check --profile manual"
            echo "  repo-fix       -> tend check --profile fix"
          '';
        };
      };
    };
}
