{ inputs, ... }: {
  perSystem = { system, ... }: {
    phenixWrapped.opencode = inputs.phenix-opencode.packages.${system}.default;
  };
}
