{
  description = "Phenix workspace superflake aggregating all subflakes";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    phenix-pins.url = "github:matthis-k/phenix-pins";

    phenix-packages.url = "github:matthis-k/phenix-packages";
    phenix-packages.inputs.phenix-pins.follows = "phenix-pins";

    phenix-shell.url = "github:matthis-k/phenix-shell";
    phenix-shell.inputs.phenix-pins.follows = "phenix-pins";

    phenix-nvim.url = "github:matthis-k/phenix-nvim";
    phenix-nvim.inputs.phenix-pins.follows = "phenix-pins";

    phenix-hosts.url = "github:matthis-k/phenix-hosts";
    phenix-hosts.inputs.phenix-pins.follows = "phenix-pins";

    phenix-tools.url = "github:matthis-k/phenix-tools";
    phenix-tools.inputs.phenix-pins.follows = "phenix-pins";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { system, ... }: {
        apps.sync = inputs.phenix-tools.apps.${system}.sync;
        apps.default = inputs.phenix-tools.apps.${system}.sync;
      };
    };
}
