{ lib, inputs, ... }: let
  inherit (lib) types;
  compose = lib.foldr lib.composeExtensions (self: super: { });
in {
  perSystem = { config, pkgs, system, ... }: {
    options.phenix = {
      overlays = lib.mkOption {
        type = types.listOf types.raw;
        default = [];
        description = "List of overlays contributed by phenix subflakes";
      };

      mcp = {
        useDevBinaries = lib.mkOption {
          type = types.bool;
          default = false;
          description = ''
            Use local debug binaries for MCP servers instead of Nix store paths.
            When true, commands point to ./phenix-tools/target/debug/ binaries.
            When false (default), commands point to Nix store paths.
          '';
        };
      };
    };

    config = let
      merged = pkgs.extend (compose config.phenix.overlays);

      phenixToolsPkgs = inputs.phenix-tools.packages.${system};

      mkMcpServer = name: pkgAttr: {
        type = "local";
        command = if config.phenix.mcp.useDevBinaries
          then [ "./phenix-tools/target/debug/${name}" ]
          else [ "${phenixToolsPkgs."${pkgAttr}"}/bin/${name}" ];
        enabled = true;
      };
    in {
      _module.args.phenixPackages = merged;

      packages = (lib.mapAttrs' (name: value: {
        name = "phenix-${name}";
        value = value;
      }) (merged.phenix or { })) // {};
    };
  };
}
