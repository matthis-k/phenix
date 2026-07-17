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

    phenix-agent-harness = {
      url = "github:matthis-k/phenix-agent-harness";
      inputs = {
        phenix-pins.follows = "phenix-pins";
        phenix-stitch.follows = "phenix-stitch";
        nixpkgs.follows = "nixpkgs";
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
        phenix-nvim.follows = "phenix-nvim";
        phenix-agent-harness.follows = "phenix-agent-harness";
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

      imports = [ ./phenix-re-exports.nix ];

      perSystem =
        { pkgs, system, ... }:
        let
          stitch = inputs.phenix-tools.packages.${system}.stitch;
          stitchMcp = inputs.phenix-tools.packages.${system}.stitch-mcp;
          opencode = inputs.phenix-tools.packages.${system}.opencode;
          pi = inputs.phenix-agent-harness.packages.${system}.pi;
        in
        {
          packages = {
            inherit stitch opencode pi;
            stitch-mcp = stitchMcp;
            default = stitch;
          };

          apps = {
            stitch = inputs.phenix-tools.apps.${system}.stitch;
            stitch-mcp = inputs.phenix-tools.apps.${system}.stitch-mcp;
            opencode = inputs.phenix-tools.apps.${system}.opencode;
            pi = {
              type = "app";
              program = "${pi}/bin/pi";
            };
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
                pi
                stitch
              ];
              shellHook = ''
                echo "Phenix workspace"
                echo "  maintenance: devenv test"
                echo "  fixes:       devenv tasks run maintenance:fix"
                echo "  stitch:      $(stitch --version 2>/dev/null || echo '?')"
              '';
            };
          };
        };
    };
}
