{ inputs, lib, ... }: {
  perSystem = { pkgs, system, ... }: let
    nix-wrapper-modules = inputs.nix-wrapper-modules;
    phenix-tools = inputs.phenix-tools;

    mkMcpServer = name: pkgAttr: {
      type = "local";
      command = [ "${phenix-tools.packages.${system}."${pkgAttr}"}/bin/${name}" ];
      enabled = true;
    };

    wrappedOpencode = nix-wrapper-modules.wrappers.opencode.wrap {
      inherit pkgs;

      settings = {
        "$schema" = "https://opencode.ai/config.json";
        autoupdate = false;
        mcp = {
          tend-mcp = mkMcpServer "tend-mcp" "tend-mcp";
          stitch-mcp = mkMcpServer "stitch-mcp" "stitch-mcp";
        };
      };

      envDefault.OPENCODE_DISABLE_AUTOUPDATE = "1";
    };
  in {
    packages.default = wrappedOpencode;
  };
}
