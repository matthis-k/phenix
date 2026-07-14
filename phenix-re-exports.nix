{ inputs, ... }:
{
  flake = {
    # phenix-hosts.flakeModules.default already contributes its normalized
    # NixOS and Home Manager module surfaces directly to the root flake.
    nixosModules = {
      desktop = inputs.phenix-de.nixosModules.default;
      hyprland = inputs.phenix-de.nixosModules.hyprland;
      hyprlandCache = inputs.phenix-de.nixosModules.hyprlandCache;
    };

    homeModules = {
      devTools = inputs.phenix-packages.homeModules.devTools;
      hyprland = inputs.phenix-de.homeModules.hyprland;
    };
  };
}
