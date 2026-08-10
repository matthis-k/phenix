{ inputs, ... }:
{
  perSystem =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      maintenanceLib = inputs.phenix-flake-ci.lib;
      repositoryRoot = ''
        repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
        cd "$repo_root"
      '';

      sourceCi = {
        enable = true;
        stage = "source";
        name = "Source";
        timeoutMinutes = 30;
      };
      productCi = {
        enable = true;
        stage = "product";
        name = "Product";
        timeoutMinutes = 60;
        needs = [ "source" ];
      };

      maintenance = maintenanceLib.mkMaintenance {
        name = "maintenance";
        description = "Phenix workspace maintenance";
        ci.github = {
          enable = true;
          outputName = "phenix-maintenance";
        };
        gitHooks = {
          enable = true;
          preCommit = [ "fix" ];
        };
        commands = {
          all = {
            description = "Run the complete validation graph";
            exec = ''
              "$0" check
              "$0" test
            '';
          };

          check = {
            description = "Run source validation";
            order = [
              "nix-format"
              "statix"
              "deadnix"
              "actionlint"
              "boundary"
              "workflow-sync"
            ];
            commands = {
              nix-format = {
                description = "Nix formatting";
                ci = sourceCi // { stepName = "Nix formatting"; };
                runtimeInputs = pkgs: [
                  pkgs.findutils
                  pkgs.git
                  pkgs.nixfmt
                ];
                exec = ''
                  ${repositoryRoot}
                  find . -type f -name '*.nix' \
                    -not -path './.git/*' \
                    -not -path './result*/*' \
                    -print0 |
                    xargs -0 -r nixfmt --check
                '';
              };

              statix = {
                description = "Nix static analysis";
                ci = sourceCi // { stepName = "Statix"; };
                runtimeInputs = pkgs: [
                  pkgs.git
                  pkgs.statix
                ];
                exec = ''
                  ${repositoryRoot}
                  statix check --ignore '.git/**'
                '';
              };

              deadnix = {
                description = "Unused Nix code";
                ci = sourceCi // { stepName = "Deadnix"; };
                runtimeInputs = pkgs: [
                  pkgs.deadnix
                  pkgs.git
                ];
                exec = ''
                  ${repositoryRoot}
                  deadnix --fail --no-lambda-arg --no-lambda-pattern-names
                '';
              };

              actionlint = {
                description = "GitHub Actions syntax";
                ci = sourceCi // { stepName = "Actionlint"; };
                runtimeInputs = pkgs: [
                  pkgs.actionlint
                  pkgs.findutils
                  pkgs.git
                ];
                exec = ''
                  ${repositoryRoot}
                  find .github/workflows -type f \
                    \( -name '*.yml' -o -name '*.yaml' \) -print0 |
                    xargs -0 -r actionlint
                '';
              };

              boundary = {
                description = "Keep the root a workspace aggregator";
                ci = sourceCi // { stepName = "Repository boundary"; };
                runtimeInputs = pkgs: [
                  pkgs.coreutils
                  pkgs.git
                ];
                exec = ''
                  ${repositoryRoot}
                  test ! -e phenix-module.nix
                  test ! -e phenix-wrappers.nix
                  test ! -e phenix-helpers.nix
                  test ! -d crates
                  test ! -e Cargo.toml
                  test ! -e Cargo.lock
                '';
              };

              workflow-sync = {
                description = "Committed workflow matches the maintenance declaration";
                ci = sourceCi // { stepName = "Generated workflow"; };
                runtimeInputs = pkgs: [
                  pkgs.diffutils
                  pkgs.git
                  pkgs.nix
                ];
                exec = ''
                  ${repositoryRoot}
                  current_system="$(nix eval --impure --raw --expr builtins.currentSystem)"
                  generated="$(mktemp)"
                  trap 'rm -f "$generated"' EXIT
                  nix eval --raw \
                    ".#packages.$current_system.phenix-maintenance.phenixMaintenance.ci.github.workflow" \
                    > "$generated"
                  diff -u .github/workflows/ci.yml "$generated"
                '';
              };
            };
          };

          test = {
            description = "Run functional workspace integration tests";
            order = [ "workspace" ];
            commands.workspace = {
              description = "Execute the root workspace discovery dry-run";
              ci = productCi // { stepName = "Workspace dry run"; };
              runtimeInputs = pkgs: [
                pkgs.git
                pkgs.nix
              ];
              exec = ''
                ${repositoryRoot}
                HOME="$(mktemp -d)" nix run .#init-workspace -- --dry-run >/dev/null
              '';
            };
          };

          fix = {
            description = "Apply deterministic Nix normalization";
            runtimeInputs = pkgs: [
              pkgs.deadnix
              pkgs.findutils
              pkgs.git
              pkgs.nixfmt
              pkgs.statix
            ];
            exec = ''
              ${repositoryRoot}
              statix fix
              deadnix --edit --no-lambda-arg --no-lambda-pattern-names
              find . -type f -name '*.nix' \
                -not -path './.git/*' \
                -not -path './result*/*' \
                -print0 |
                xargs -0 -r nixfmt
            '';
          };
        };
      };

      maintenancePackage = maintenanceLib.mkMaintenancePackage {
        inherit pkgs maintenance;
      };

      stitch = inputs.phenix-tools.packages.${system}.stitch;
      workspace = inputs.phenix-tools.packages.${system}.phenix-workspace;
      phenixDev = inputs.phenix-tools.packages.${system}.phenix-dev;
      pi = inputs.phenix-agent-harness.packages.${system}.pi;
    in
    {
      packages.phenix-maintenance = maintenancePackage.package;
      apps.phenix-maintenance = maintenancePackage.app;

      devShells.default = pkgs.mkShell {
        name = "phenix-workspace";
        packages = [
          pkgs.git
          pkgs.gh
          pkgs.jq
          pkgs.ripgrep
          pkgs.fd
          phenixDev
          pi
          stitch
          workspace
          maintenancePackage.package
        ];
        shellHook = ''
          ${maintenancePackage.shellHook}

          echo "Phenix workspace"
          echo "  init repos:  nix run .#init-workspace -- --dry-run"
          echo "  maintenance: maintenance all"
          echo "  fixes:       maintenance fix"
          echo "  stitch:      $(stitch --version 2>/dev/null || echo '?')"
        '';
      };
    };
}
