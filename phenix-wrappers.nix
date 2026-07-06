{ inputs, ... }:
{
  perSystem = { system, ... }: {
    phenixWrapped = {
      opencode = inputs.phenix-agent-harness.packages.${system}.opencode;
      pi = inputs.phenix-agent-harness.packages.${system}.pi;
      tend = inputs.phenix-tend.packages.${system}.tend;
      stitch = inputs.phenix-stitch.packages.${system}.stitch;
    };
  };
}
