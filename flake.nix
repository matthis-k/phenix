{
  description = "Phenix workspace superflake aggregating all subflakes";

  nixConfig = {
    extra-substituters = [ "https://hyprland.cachix.org" ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    phenix-flake-ci.url = "github:matthis-k/phenix-flake-ci";
    phenix-pins = {
      url = "github:matthis-k/phenix-pins";
      inputs.phenix-flake-ci.follows = "phenix-flake-ci";
    };
    flake-parts.follows = "phenix-pins/flake-parts";
    nixpkgs.follows = "phenix-pins/nixpkgs";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    phenix-packages = {
      url = "github:matthis-k/phenix-packages";
      inputs = {
        phenix-flake-ci.follows = "phenix-flake-ci";
        phenix-pins.follows = "phenix-pins";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    phenix-stitch = {
      url = "github:matthis-k/phenix-stitch";
      inputs = {
        phenix-flake-ci.follows = "phenix-flake-ci";
        phenix-pins.follows = "phenix-pins";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    phenix-tools = {
      url = "github:matthis-k/phenix-tools";
      inputs = {
        phenix-flake-ci.follows = "phenix-flake-ci";
        phenix-pins.follows = "phenix-pins";
        phenix-stitch.follows = "phenix-stitch";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    phenix-nvim = {
      url = "github:matthis-k/phenix-nvim";
      inputs = {
        phenix-flake-ci.follows = "phenix-flake-ci";
        phenix-pins.follows = "phenix-pins";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    phenix-de = {
      url = "github:matthis-k/phenix-de";
      inputs = {
        phenix-flake-ci.follows = "phenix-flake-ci";
        phenix-pins.follows = "phenix-pins";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "phenix-pins/home-manager";
      };
    };

    phenix-agent-harness = {
      url = "github:matthis-k/phenix-agent-harness";
      inputs = {
        phenix-flake-ci.follows = "phenix-flake-ci";
        phenix-pins.follows = "phenix-pins";
        phenix-stitch.follows = "phenix-stitch";
        nixpkgs.follows = "nixpkgs";
      };
    };

    phenix-hosts = {
      url = "github:matthis-k/phenix-hosts";
      inputs = {
        phenix-flake-ci.follows = "phenix-flake-ci";
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
        phenix-flake-ci.follows = "phenix-flake-ci";
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
        ./development.nix
      ];

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        let
          stitch = inputs.phenix-tools.packages.${system}.stitch;
          stitchMcp = inputs.phenix-tools.packages.${system}.stitch-mcp;
          phenix = inputs.phenix-tools.packages.${system}.phenix;
          workspace = inputs.phenix-tools.packages.${system}.phenix-workspace;
          phenixDev = inputs.phenix-tools.packages.${system}.phenix-dev;
          pi = inputs.phenix-agent-harness.packages.${system}.pi;
          piStore = inputs.phenix-agent-harness.packages.${system}.pi-store;
          piDev = inputs.phenix-agent-harness.packages.${system}.pi-dev;
        in
        {
          packages = {
            inherit stitch phenix pi;
            phenix-dev = phenixDev;
            phenix-workspace = workspace;
            pi-store = piStore;
            pi-dev = piDev;
            stitch-mcp = stitchMcp;
            default = stitch;
          };

          apps = {
            stitch = inputs.phenix-tools.apps.${system}.stitch;
            stitch-mcp = inputs.phenix-tools.apps.${system}.stitch-mcp;
            phenix = inputs.phenix-tools.apps.${system}.phenix;
            pi = {
              type = "app";
              program = "${pi}/bin/pi";
            };
            pi-store = {
              type = "app";
              program = "${piStore}/bin/pi-store";
            };
            pi-dev = {
              type = "app";
              program = "${piDev}/bin/pi-dev";
            };
            phenix-shell = inputs.phenix-de.apps.${system}.phenix-shell;
            default = inputs.phenix-tools.apps.${system}.stitch;
          };

          devShells = {
            shared = inputs.phenix-shell.devShells.${system}.default;
            default = pkgs.mkShell {
              name = "phenix-workspace";
              packages = [
                pkgs.git
                pkgs.gh
                pkgs.jq
                pkgs.ripgrep
                pkgs.fd
                phenixDev
                pi
                stitch
                workspace
                config.packages.phenix-maintenance
              ];
              shellHook = ''
                ${config.packages.phenix-maintenance.phenixMaintenance.gitHooks.shellHook or ""}
                echo "Phenix workspace"
                echo "  init repos:  nix run .#init-workspace -- --dry-run"
                echo "  maintenance: maintenance all"
                echo "  fixes:       maintenance fix"
                echo "  stitch:      $(stitch --version 2>/dev/null || echo '?')"
              '';
            };
          };
        };
    };
}
