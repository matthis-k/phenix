{ lib, inputs, ... }:
{
  flake = {
    nixosModules = {
      # From phenix-hosts
      phenix-migration-base =
        inputs.phenix-hosts.nixosModules.phenixMigrationBase
          or (throw "phenix-hosts.nixosModules.phenixMigrationBase not available");
      home-manager-bridge =
        inputs.phenix-hosts.nixosModules.homeManagerBridge
          or (throw "phenix-hosts.nixosModules.homeManagerBridge not available");
      sops-bridge =
        inputs.phenix-hosts.nixosModules.sopsBridge
          or (throw "phenix-hosts.nixosModules.sopsBridge not available");
      sops-base =
        inputs.phenix-hosts.nixosModules.sopsBase
          or (throw "phenix-hosts.nixosModules.sopsBase not available");
      nix-base =
        inputs.phenix-hosts.nixosModules.nixBase
          or (throw "phenix-hosts.nixosModules.nixBase not available");
      users-matthisk =
        inputs.phenix-hosts.nixosModules.usersMatthisk
          or (throw "phenix-hosts.nixosModules.usersMatthisk not available");
      locale-de-en =
        inputs.phenix-hosts.nixosModules.localeDeEn
          or (throw "phenix-hosts.nixosModules.localeDeEn not available");
      audio-pipewire =
        inputs.phenix-hosts.nixosModules.audioPipewire
          or (throw "phenix-hosts.nixosModules.audioPipewire not available");
      sudo-wheel-passwordless =
        inputs.phenix-hosts.nixosModules.sudoWheelPasswordless
          or (throw "phenix-hosts.nixosModules.sudoWheelPasswordless not available");

      # From phenix-de
      hyprland-base =
        inputs.phenix-de.nixosModules.hyprland-base
          or (throw "phenix-de.nixosModules.hyprland-base not available");
      nix-cache =
        inputs.phenix-de.nixosModules.nix-cache or (throw "phenix-de.nixosModules.nix-cache not available");
    };

    homeModules = {
      # From phenix-hosts
      users-matthisk-base =
        inputs.phenix-hosts.homeModules.usersMatthiskBase
          or (throw "phenix-hosts.homeModules.usersMatthiskBase not available");
      users-matthisk-ssh =
        inputs.phenix-hosts.homeModules.usersMatthiskSsh
          or (throw "phenix-hosts.homeModules.usersMatthiskSsh not available");

      # From phenix-packages
      dev-tools =
        inputs.phenix-packages.homeModules.devTools
          or (throw "phenix-packages.homeModules.devTools not available");

      # From phenix-de
      hyprland =
        inputs.phenix-de.homeModules.hyprland or (throw "phenix-de.homeModules.hyprland not available");
    };
  };
}
