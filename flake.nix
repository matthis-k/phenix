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

      perSystem = { system, pkgs, lib, phenixPackages, ... }: let
        toolsPkg = inputs.phenix-tools.packages.${system}.gate;
      in {
        packages.opencode = pkgs.opencode;

        apps.gate = inputs.phenix-tools.apps.${system}.gate;
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
          ] ++ lib.optional (toolsPkg.meta.position or "" != "") toolsPkg;
          shellHook = ''
            echo "Phenix development shell"
            echo "  tools: git gh jq ripgrep fd statix deadnix nixfmt opencode"
            echo "  phenix-tools: available via 'pt' / 'phenix-tools'"
            echo "  stitch: coordinated multi-repo changeset tool"
            echo "  tend: distributed maintenance/check harness"
          '';
        };
      };
    };
}
