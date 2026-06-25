{
  description = "Phenix workspace superflake aggregating all subflakes";

  inputs = {
    phenix-pins.url = "path:./phenix-pins";

    phenix-packages.url = "path:./phenix-packages";
    phenix-packages.inputs.phenix-pins.follows = "phenix-pins";

    phenix-shell.url = "path:./phenix-shell";
    phenix-shell.inputs.phenix-pins.follows = "phenix-pins";
    phenix-shell.inputs.phenix-packages.follows = "phenix-packages";

    phenix-nvim.url = "path:./phenix-nvim";
    phenix-nvim.inputs.phenix-pins.follows = "phenix-pins";
    phenix-nvim.inputs.phenix-packages.follows = "phenix-packages";

    phenix-hosts.url = "path:./phenix-hosts";
    phenix-hosts.inputs.phenix-pins.follows = "phenix-pins";
    phenix-hosts.inputs.phenix-packages.follows = "phenix-packages";
    phenix-hosts.inputs.phenix-shell.follows = "phenix-shell";
    phenix-hosts.inputs.phenix-nvim.follows = "phenix-nvim";

    phenix-tools.url = "path:./phenix-tools";
    phenix-tools.inputs.phenix-pins.follows = "phenix-pins";
  };

  outputs = inputs: {
    apps.x86_64-linux = {
      sync = inputs.phenix-tools.apps.x86_64-linux.sync;
      default = inputs.phenix-tools.apps.x86_64-linux.sync;
    };
  };
}
