{ lib, ... }:
let
  inherit (lib) types;
  compose = lib.foldr lib.composeExtensions (_self: _super: { });
in
{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      options = {
        phenix = {
          overlays = lib.mkOption {
            type = types.listOf types.raw;
            default = [ ];
            description = "Overlays contributed by Phenix subflakes";
          };

          mcp.useDevBinaries = lib.mkOption {
            type = types.bool;
            default = false;
            description = ''
              Use local debug binaries for MCP servers instead of Nix store paths.
            '';
          };
        };

        phenixWrapped = lib.mkOption {
          type = types.attrsOf types.package;
          default = { };
          description = "Wrapped tools contributed by Phenix subflakes";
        };
      };

      config =
        let
          merged = pkgs.extend (compose config.phenix.overlays);
          waylandApps = {
            phenix-wl-copy = {
              program = "${pkgs.wl-clipboard}/bin/wl-copy";
              description = "Copy Wayland clipboard data";
            };
            phenix-wl-paste = {
              program = "${pkgs.wl-clipboard}/bin/wl-paste";
              description = "Read Wayland clipboard data";
            };
            phenix-grim = {
              program = "${pkgs.grim}/bin/grim";
              description = "Capture a Wayland screenshot";
            };
            phenix-slurp = {
              program = "${pkgs.slurp}/bin/slurp";
              description = "Select a Wayland screen region";
            };
            phenix-swappy = {
              program = "${pkgs.swappy}/bin/swappy";
              description = "Annotate a Wayland screenshot";
            };
            phenix-tesseract = {
              program = "${pkgs.tesseract}/bin/tesseract";
              description = "Run OCR with Tesseract";
            };
          };
        in
        {
          _module.args.phenixPackages = merged;

          packages = lib.mapAttrs' (name: value: {
            name = "phenix-${name}";
            inherit value;
          }) (merged.phenix or { });

          apps = lib.mapAttrs (_name: app: {
            type = "app";
            inherit (app) program;
            meta.description = app.description;
          }) waylandApps;
        };
    };
}
