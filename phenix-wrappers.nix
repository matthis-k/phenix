{ lib, ... }:
{
  perSystem = _: {
    options.phenixWrapped = lib.mkOption {
      type = lib.types.attrsOf lib.types.package;
      default = { };
      description = "Wrapped/packaged tools with embedded configuration";
    };
  };
}
