{ inputs, ... }:
{
  perSystem = { system, ... }: {
    phenixWrapped = {
      pi = inputs.phenix-agent-harness.packages.${system}.pi;
      tend = inputs.phenix-tend.packages.${system}.tend;
      stitch = inputs.phenix-stitch.packages.${system}.stitch;
    };
  };
}
