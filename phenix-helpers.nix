{ lib, ... }:
let
  inherit (lib) types;
in
{
  perSystem =
    { config, pkgs, ... }:
    {
      options.phenix = {
        helperPackages = lib.mkOption {
          type = types.listOf types.package;
          default = [ ];
          description = "Common packages for Phenix development shells";
        };

        tendPkg = lib.mkOption {
          type = types.nullOr types.package;
          default = null;
          description = "Tend package used by root development helpers";
        };

        stitchPkg = lib.mkOption {
          type = types.nullOr types.package;
          default = null;
          description = "Stitch package used by root development helpers";
        };

        shellHook = lib.mkOption {
          type = types.lines;
          default = "";
          description = "Common Phenix development-shell initialization";
        };
      };

      config.phenix = {
        helperPackages = with pkgs; [
          git
          nix
          jq
          ripgrep
          fd
          statix
          deadnix
          nixfmt
        ];

        shellHook =
          let
            tend = config.phenix.tendPkg;
            stitch = config.phenix.stitchPkg;
            hasTend = tend != null;
            hasStitch = stitch != null;
          in
          ''
            ${lib.optionalString hasTend ''
              repo-hook() {
                ${tend}/bin/tend check --profile git-hook --context local "$@"
              }
              repo-pushgate() {
                ${tend}/bin/tend check --profile pre-push --context local "$@"
              }
              repo-check() {
                ${tend}/bin/tend check --profile manual --context local "$@"
              }
              repo-fix() {
                ${tend}/bin/tend check --profile fix --context local "$@"
              }
              export -f repo-hook repo-pushgate repo-check repo-fix 2>/dev/null || true
            ''}

            ${lib.optionalString hasStitch ''
              repo-hooks-plan() {
                ${stitch}/bin/stitch hooks plan --all "$@"
              }
              repo-install-all-hooks() {
                ${stitch}/bin/stitch hooks install --all "$@"
              }
              export -f repo-hooks-plan repo-install-all-hooks 2>/dev/null || true
            ''}

            echo "Phenix development shell"
            ${lib.optionalString hasTend ''
              echo "  tend: $(tend --version 2>/dev/null || echo 'available')"
              echo "  repo-hook           -> tend check --profile git-hook --context local"
              echo "  repo-pushgate       -> tend check --profile pre-push --context local"
              echo "  repo-check          -> tend check --profile manual --context local"
              echo "  repo-fix            -> tend check --profile fix --context local"
            ''}
            ${lib.optionalString hasStitch ''
              echo "  stitch: $(stitch --version 2>/dev/null || echo 'available')"
              echo "  repo-hooks-plan     -> stitch hooks plan --all"
              echo "  repo-install-all-hooks -> stitch hooks install --all"
            ''}
          '';
      };
    };
}
