{
  description = "Phenix workspace superflake aggregating all subflakes";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.follows = "phenix-pins/nixpkgs";
    phenix-pins.url = "github:matthis-k/phenix-pins";

    phenix-packages.url = "github:matthis-k/phenix-packages";
    phenix-packages.inputs.phenix-pins.follows = "phenix-pins";

    phenix-de.url = "github:matthis-k/phenix-de";
    phenix-de.inputs.phenix-pins.follows = "phenix-pins";

    phenix-nvim.url = "github:matthis-k/phenix-nvim";
    phenix-nvim.inputs.phenix-pins.follows = "phenix-pins";

    phenix-hosts.url = "github:matthis-k/phenix-hosts";
    phenix-hosts.inputs.phenix-pins.follows = "phenix-pins";

    # TODO: switch back to github: when both repos are pushed
    phenix-tools.url = "git+file:./phenix-tools";
    # phenix-tools.url = "github:matthis-k/phenix-tools";
    # phenix-tools.inputs.phenix-pins.follows = "phenix-pins";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      imports = [
        ./phenix-module.nix
        inputs.phenix-packages.flakeModules.default
        inputs.phenix-de.flakeModules.default
        inputs.phenix-nvim.flakeModules.default
        inputs.phenix-hosts.flakeModules.default
        inputs.phenix-tools.flakeModules.default
      ];

      perSystem = { system, pkgs, lib, phenixPackages, ... }: {
        packages.opencode = pkgs.opencode;

        apps.tend = inputs.phenix-tools.apps.${system}.tend;
        apps.stitch = inputs.phenix-tools.apps.${system}.stitch;
        apps.default = inputs.phenix-tools.apps.${system}.stitch;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            git
            gh
            jq
            ripgrep
            fd
            statix
            deadnix
            nixfmt-rfc-style
            opencode
            inputs.phenix-tools.packages.${system}.tend
            inputs.phenix-tools.packages.${system}.stitch
          ];
          shellHook = ''
            echo "Phenix development shell"
            echo "  tools: git gh jq ripgrep fd statix deadnix nixfmt opencode"
            echo "  tend: distributed maintenance/check harness"
            echo "  stitch: coordinated multi-repo git tool"
          '';
        };
      };
    };
}
