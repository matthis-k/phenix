{ inputs, ... }:
{
  flake = {
    nixosConfigurations = inputs.phenix-hosts.nixosConfigurations;

    nixosModules = {
      default = inputs.phenix-hosts.nixosModules.default;
      workstation = inputs.phenix-hosts.nixosModules.workstation;
      laptop = inputs.phenix-hosts.nixosModules.laptop;
      desktopHost = inputs.phenix-hosts.nixosModules.desktop;
      homeManager = inputs.phenix-hosts.nixosModules.homeManager;
      sops = inputs.phenix-hosts.nixosModules.sops;
      nix = inputs.phenix-hosts.nixosModules.nix;
      userMatthisk = inputs.phenix-hosts.nixosModules.userMatthisk;
      locale = inputs.phenix-hosts.nixosModules.locale;
      audio = inputs.phenix-hosts.nixosModules.audio;
      sudo = inputs.phenix-hosts.nixosModules.sudo;
      networking = inputs.phenix-hosts.nixosModules.networking;
      localSend = inputs.phenix-hosts.nixosModules.localSend;
      devMode = inputs.phenix-hosts.nixosModules.devMode;
      nordvpn = inputs.phenix-hosts.nixosModules.nordvpn;
      llmServer = inputs.phenix-hosts.nixosModules.llmServer;

      desktop = inputs.phenix-de.nixosModules.default;
      hyprland = inputs.phenix-de.nixosModules.hyprland;
      hyprlandCache = inputs.phenix-de.nixosModules.hyprlandCache;
      stylix = inputs.phenix-de.nixosModules.stylix;
      fish = inputs.phenix-de.nixosModules.fish;
      waylandTools = inputs.phenix-de.nixosModules.waylandTools;
    };

    homeModules = {
      default = inputs.phenix-hosts.homeModules.default;
      matthisk = inputs.phenix-hosts.homeModules.matthisk;
      matthiskBase = inputs.phenix-hosts.homeModules.matthiskBase;
      matthiskSsh = inputs.phenix-hosts.homeModules.matthiskSsh;
      git = inputs.phenix-hosts.homeModules.git;
      devTools = inputs.phenix-packages.homeModules.devTools;

      desktop = inputs.phenix-de.homeModules.default;
      hyprland = inputs.phenix-de.homeModules.hyprland;
      stylix = inputs.phenix-de.homeModules.stylix;
      fish = inputs.phenix-de.homeModules.fish;
      kitty = inputs.phenix-de.homeModules.kitty;
      quickshell = inputs.phenix-de.homeModules.quickshell;
      waylandTools = inputs.phenix-de.homeModules.waylandTools;
      zenBrowser = inputs.phenix-de.homeModules.zenBrowser;
    };
  };
}
