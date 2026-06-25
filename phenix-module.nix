{ lib, ... }: let
  inherit (lib) types;
  compose = lib.foldr lib.composeExtensions (self: super: { });
in {
  perSystem = { config, pkgs, ... }: {
    options.phenix.overlays = lib.mkOption {
      type = types.listOf types.raw;
      default = [];
      description = "List of overlays contributed by phenix subflakes";
    };

    config = let
      merged = (pkgs.extend (compose config.phenix.overlays)).phenix or { };
    in {
      _module.args.phenixPackages = merged;

      packages = lib.mapAttrs' (name: value: {
        name = "phenix-${name}";
        value = value;
      }) merged;
    };
  };
}
