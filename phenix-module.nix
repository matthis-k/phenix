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
            description = "List of overlays contributed by phenix subflakes";
          };

          mcp = {
            useDevBinaries = lib.mkOption {
              type = types.bool;
              default = false;
              description = ''
                Use local debug binaries for MCP servers instead of Nix store paths.
                When true, commands point to local tend/stitch target/debug binaries.
                When false (default), commands point to Nix store paths.
              '';
            };
          };
        };

        phenixWrapped = lib.mkOption {
          type = types.attrsOf types.package;
          default = { };
          description = "Phenix wrapped tools merged from subflake modules";
        };
      };

      config =
        let
          merged = pkgs.extend (compose config.phenix.overlays);
        in
        {
          _module.args.phenixPackages = merged;

          packages =
            (lib.mapAttrs' (name: value: {
              name = "phenix-${name}";
              inherit value;
            }) (merged.phenix or { }))
            // { };

          apps =
            let
              waylandApps = {
                phenix-wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
                phenix-wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
                phenix-grim = "${pkgs.grim}/bin/grim";
                phenix-slurp = "${pkgs.slurp}/bin/slurp";
                phenix-swappy = "${pkgs.swappy}/bin/swappy";
                phenix-tesseract = "${pkgs.tesseract}/bin/tesseract";
              };
            in
            lib.mapAttrs (_name: program: {
              type = "app";
              inherit program;
            }) waylandApps;
        };
    };
}
