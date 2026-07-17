{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      workspace = inputs.phenix-tools.packages.${system}.phenix-workspace;
      app = name: command:
        let
          wrapper = pkgs.writeShellApplication {
            inherit name;
            runtimeInputs = [ workspace ];
            text = ''exec phenix-workspace ${command} "$@"'';
          };
        in
        {
          type = "app";
          program = "${wrapper}/bin/${name}";
        };
      inventoryCheck = pkgs.runCommand "phenix-workspace-inventory" {
        nativeBuildInputs = [ workspace ];
      } ''
        export HOME="$TMPDIR"
        phenix-workspace --root ${inputs.self} init --dry-run > "$out"
        grep -q 'phenix-stitch' "$out"
        grep -q 'phenix-tools' "$out"
      '';
    in
    {
      checks = {
        phenix-workspace-package = workspace;
        phenix-workspace-inventory = inventoryCheck;
      };

      apps = {
        init-workspace = app "init-workspace" "init";
        sync-workspace = app "sync-workspace" "sync";
        clean-workspace = app "clean-workspace" "clean";
        dev = app "phenix-dev" "dev";
        check-local = app "check-local" "check";
        workspace-overrides = app "workspace-overrides" "overrides";
      };
    };
}
