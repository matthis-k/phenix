{
  description = "Phenix workspace superflake aggregating all subflakes";

  nixConfig = {
    extra-substituters = [ "https://hyprland.cachix.org" ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    phenix-pins = {
      url = "github:matthis-k/phenix-pins";
      inputs.flake-parts.follows = "flake-parts";
    };
    nixpkgs.follows = "phenix-pins/nixpkgs";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    phenix-packages = {
      url = "github:matthis-k/phenix-packages";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    phenix-stitch = {
      url = "github:matthis-k/phenix-stitch";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    phenix-conductor = {
      url = "github:matthis-k/phenix-conductor";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        phenix-stitch.follows = "phenix-stitch";
      };
    };

    phenix-harness = {
      url = "github:matthis-k/phenix-harness";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        phenix-conductor.follows = "phenix-conductor";
      };
    };

    phenix-tools = {
      url = "github:matthis-k/phenix-tools";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        phenix-stitch.follows = "phenix-stitch";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    phenix-nvim = {
      url = "github:matthis-k/phenix-nvim";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        phenix-conductor.follows = "phenix-conductor";
        phenix-harness.follows = "phenix-harness";
      };
    };

    phenix-de = {
      url = "github:matthis-k/phenix-de";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "phenix-pins/home-manager";
      };
    };

    phenix-hosts = {
      url = "github:matthis-k/phenix-hosts";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "phenix-pins/home-manager";
        sops-nix.follows = "phenix-pins/sops-nix";
        disko.follows = "disko";
        phenix-de.follows = "phenix-de";
        phenix-conductor.follows = "phenix-conductor";
        phenix-harness.follows = "phenix-harness";
        phenix-nvim.follows = "phenix-nvim";
      };
    };

    phenix-shell = {
      url = "github:matthis-k/phenix-shell";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        ./phenix-re-exports.nix
        ./workspace-apps.nix
      ];

      perSystem =
        { pkgs, system, ... }:
        let
          stitch = inputs.phenix-tools.packages.${system}.stitch;
          stitchMcp = inputs.phenix-tools.packages.${system}.stitch-mcp;
          workspace = inputs.phenix-tools.packages.${system}.phenix-workspace;
          phenixDev = inputs.phenix-tools.packages.${system}.phenix-dev;
          conductor = inputs.phenix-conductor.packages.${system}.default;
          harness = inputs.phenix-harness.packages.${system}.default;
        in
        {
          packages = {
            inherit stitch;
            phenix = harness;
            phenix-conductor = conductor;
            phenix-harness = harness;
            phenix-dev = phenixDev;
            phenix-workspace = workspace;
            stitch-mcp = stitchMcp;
            default = stitch;
          };

          apps = {
            stitch = inputs.phenix-tools.apps.${system}.stitch;
            stitch-mcp = inputs.phenix-tools.apps.${system}.stitch-mcp;
            phenix = inputs.phenix-harness.apps.${system}.default;
            phenix-conductor = inputs.phenix-conductor.apps.${system}.default;
            phenix-harness = inputs.phenix-harness.apps.${system}.default;
            phenix-shell = inputs.phenix-de.apps.${system}.phenix-shell;
            default = inputs.phenix-tools.apps.${system}.stitch;
          };

          devShells = {
            shared = inputs.phenix-shell.devShells.${system}.default;
            default = pkgs.mkShell {
              name = "phenix-workspace";
              packages = [
                pkgs.devenv
                pkgs.git
                pkgs.gh
                pkgs.jq
                pkgs.ripgrep
                pkgs.fd
                phenixDev
                harness
                stitch
                workspace
              ];
              shellHook = ''
                echo "Phenix workspace"
                echo "  local Nix:   nix run .#nixdev -- flake check"
                echo "  init repos:  nix run .#init-workspace"
                echo "  maintenance: devenv test"
                echo "  fixes:       devenv tasks run maintenance:fix"
                echo "  stitch:      $(stitch --version 2>/dev/null || echo '?')"
              '';
            };
          };
        };
    };
}
