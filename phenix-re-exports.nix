{ inputs, ... }:
{
  flake = {
    nixosConfigurations = inputs.phenix-hosts.nixosConfigurations;

    nixosModules = {
      default = inputs.phenix-hosts.nixosModules.default;
      homeManager = inputs.phenix-hosts.nixosModules.homeManager;
      sops = inputs.phenix-hosts.nixosModules.sops;
      nix = inputs.phenix-hosts.nixosModules.nix;
      userMatthisk = inputs.phenix-hosts.nixosModules.userMatthisk;
      locale = inputs.phenix-hosts.nixosModules.locale;
      audio = inputs.phenix-hosts.nixosModules.audio;
      sudo = inputs.phenix-hosts.nixosModules.sudo;

      desktop = inputs.phenix-de.nixosModules.default;
      hyprland = inputs.phenix-de.nixosModules.hyprland;
      hyprlandCache = inputs.phenix-de.nixosModules.hyprlandCache;
    };

    homeModules = {
      matthisk = inputs.phenix-hosts.homeModules.matthisk;
      matthiskSsh = inputs.phenix-hosts.homeModules.matthiskSsh;
      devTools = inputs.phenix-packages.homeModules.devTools;
      hyprland = inputs.phenix-de.homeModules.hyprland;
    };
  };
}
