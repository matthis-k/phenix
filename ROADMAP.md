# Phenix roadmap

## Current status

Phenix has a complete configuration baseline for the laptop and desktop. The root flake
aggregates locked Phenix repositories and re-exports both concrete NixOS configurations.

Evaluation and CI parity are established. Real-hardware activation, rollback, and
behavioral acceptance remain before the legacy monolith can be archived.

## Completed baseline

### Desktop

- [x] Hyprland Lua configuration and keymap engine
- [x] Phenix Shell source, package, service, launcher, and IPC naming
- [x] Kitty, Fish, Starship, Stylix/Catppuccin, and Zen Browser configuration
- [x] Wayland screenshot, annotation, clipboard, and OCR utilities
- [x] Reusable NixOS and Home Manager desktop modules

### Hosts

- [x] `matthisk-laptop-phenix` NixOS configuration
- [x] `matthisk-desktop-phenix` NixOS configuration
- [x] Hardware, boot, resume, encrypted storage, and Disko layouts
- [x] Home Manager, user, SSH, GitHub, SOPS, locale, audio, and sudo policy
- [x] Bluetooth, NetworkManager, Avahi, LocalSend, and NordVPN
- [x] Desktop Ollama, Open WebUI, Caddy, and Kokoro TTS
- [x] Neovim and Pi installation through their owning flakes
- [x] `phenix ai`, `phenix switch`, and `phenix reload-shell` workstation commands

### Aggregate

- [x] Root input graph follows validated repository revisions
- [x] Strict Stitch graph verification
- [x] Tend v2 contracts and permanent CI
- [x] Complete module and concrete-host re-exports
- [x] Phenix-native names across active repositories

## Required before hardware cutover

- [ ] Provision or confirm each host's SOPS age identity outside the repository
- [ ] Build and activate the laptop configuration
- [ ] Build and activate the desktop configuration
- [ ] Verify boot, encrypted storage, resume, graphics, display manager, and rollback
- [ ] Verify NordVPN login, dedicated-IP autoconnect, LAN discovery, and LocalSend
- [ ] Verify Phenix Shell startup, launcher, notifications, clipboard, screenshots, and OCR
- [ ] Verify desktop Ollama, Open WebUI, Caddy certificate trust, and Kokoro TTS
- [ ] Confirm SSH and GitHub secret ownership and modes

## Remaining functional gaps

- [ ] Installer media and first-install workflow
- [ ] Complete Phenix Shell runtime/IPC launcher case harness in CI
- [ ] Explicit behavioral parity tests for the wrapped Neovim configuration
- [ ] Decide whether any legacy CLI or memory workflow remains useful beyond Stitch,
      Tend, Pi, and the new `phenix` workstation command

Archive the legacy monolith only after both machines have activated successfully and the
rollback path has been exercised.
