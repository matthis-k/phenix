{ lib, ... }: let
  inherit (lib) types;
in {
  perSystem = { ... }: {
    options.phenixWrapped = lib.mkOption {
      type = types.attrsOf types.package;
      default = {};
      description = "Wrapped/packaged tools with embedded configuration";
    };
  };
}
