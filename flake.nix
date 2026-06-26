{
  description = "Phenix workspace superflake aggregating all subflakes";

  # Enable submodule support so path: inputs into submodule dirs work
  inputs.self.submodules = true;

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    phenix-pins.url = ./flakes/00-pins/phenix-pins;
    nixpkgs.follows = "phenix-pins/nixpkgs";

    phenix-packages.url = ./flakes/04-pkgs/phenix-packages;
    phenix-packages.inputs.phenix-pins.follows = "phenix-pins";

    phenix-tools.url = ./flakes/02-producers/phenix-tools;
    phenix-tools.inputs.phenix-pins.follows = "phenix-pins";

    phenix-nvim.url = ./flakes/02-producers/phenix-nvim;
    phenix-nvim.inputs.phenix-pins.follows = "phenix-pins";

    phenix-de.url = ./flakes/05-consumers/phenix-de;
    phenix-de.inputs.phenix-pins.follows = "phenix-pins";

    phenix-hosts.url = ./flakes/05-consumers/phenix-hosts;
    phenix-hosts.inputs.phenix-pins.follows = "phenix-pins";

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
        tendMcpPkg = inputs.phenix-tools.packages.${system}."tend-mcp";
        stitchMcpPkg = inputs.phenix-tools.packages.${system}."stitch-mcp";
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
                description = "Run fast Tend checks on staged changes (inside Nix dev shell)";
                entry = "nix develop .#default --command ${tendPkg}/bin/tend check --profile git-hook --staged";
                pass_filenames = false;
                always_run = true;
                stages = [ "pre-commit" ];
              };

              tend-pre-push = {
                enable = true;
                name = "tend pre-push";
                description = "Run medium Tend checks before push (inside Nix dev shell)";
                entry = "nix develop .#default --command ${tendPkg}/bin/tend check --profile pre-push";
                pass_filenames = false;
                always_run = true;
                stages = [ "pre-push" ];
              };

              commit-msg-check = {
                enable = true;
                name = "commit msg check";
                description = "Validate commit message format";
                entry = "nix develop .#default --command bash -c 'cat \"$1\" | head -1 | grep -qE \"^(feat|fix|chore|docs|refactor|test|ci|perf|style|build|revert)(\\(.+\\))?: .+\" || { echo \"FAIL: commit message must start with conventional commit prefix\"; exit 1; }; ! grep -qiF \"phenix-sync\" \"$1\" || { echo \"FAIL: commit message contains obsolete phenix-sync wording\"; exit 1; }' _";
                pass_filenames = false;
                always_run = true;
                stages = [ "commit-msg" ];
              };
            };
          };
        };

        checks = {
          tend-nix-check = pkgs.runCommand "tend-nix-check"
            {
              nativeBuildInputs = [
                tendPkg
                stitchPkg
                pkgs.git
                pkgs.nix
                pkgs.jq
              ] ++ rustToolchain;
            }
            ''
              cp -r ${lib.cleanSource ./.} source
              chmod -R u+w source

              # Materialize all local flake inputs into the workspace copy
              rm -rf source/flakes/00-pins/phenix-pins
              rm -rf source/flakes/02-producers/phenix-tools
              rm -rf source/flakes/02-producers/phenix-nvim
              rm -rf source/flakes/04-pkgs/phenix-packages
              rm -rf source/flakes/05-consumers/phenix-de
              rm -rf source/flakes/05-consumers/phenix-hosts

              mkdir -p source/flakes/00-pins
              mkdir -p source/flakes/02-producers
              mkdir -p source/flakes/04-pkgs
              mkdir -p source/flakes/05-consumers

              cp -rT ${inputs.phenix-pins} source/flakes/00-pins/phenix-pins
              cp -rT ${inputs.phenix-tools} source/flakes/02-producers/phenix-tools
              cp -rT ${inputs.phenix-nvim} source/flakes/02-producers/phenix-nvim
              cp -rT ${inputs.phenix-packages} source/flakes/04-pkgs/phenix-packages
              cp -rT ${inputs.phenix-de} source/flakes/05-consumers/phenix-de
              cp -rT ${inputs.phenix-hosts} source/flakes/05-consumers/phenix-hosts

              chmod -R u+w source

              cd source

              ${tendPkg}/bin/tend validate --profiles

              ${stitchPkg}/bin/stitch graph verify \
                --source locks \
                --workspace . \
                --metadata .stitch/topology.json \
                --strict

              ${tendPkg}/bin/tend check --profile nix-check --offline --locked

              touch $out
            '';
        };

        devShells.test = pkgs.mkShell {
          name = "phenix-test";

          packages = with pkgs; [
            git
            nix
            jq
            ripgrep
            tendPkg
            stitchPkg
          ] ++ rustToolchain;
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
            tendMcpPkg
            stitchMcpPkg
          ] ++ rustToolchain;

          shellHook = ''
            ${config.pre-commit.installationScript}

            # Generate correct opencode.json with Nix store paths
            # Replaces the static dev-mode file on dev shell entry
            cat > opencode.json << 'JSON'
            {
              "$schema": "https://opencode.ai/config.json",
              "mcp": {
                "tend-mcp": {
                  "type": "local",
                  "command": ["${tendMcpPkg}/bin/tend-mcp"],
                  "enabled": true
                },
                "stitch-mcp": {
                  "type": "local",
                  "command": ["${stitchMcpPkg}/bin/stitch-mcp"],
                  "enabled": true
                }
              }
            }
            JSON
            echo "  opencode MCP: tend-mcp=${tendMcpPkg}/bin/tend-mcp"
            echo "  opencode MCP: stitch-mcp=${stitchMcpPkg}/bin/stitch-mcp"

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
