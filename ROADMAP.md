# Phenix Roadmap

## Current status

Phenix now has a complete **configuration migration baseline** for the two existing
NewXOS workstations. The root flake aggregates remote, locked Phenix repositories
and re-exports both concrete NixOS configurations.

This is not yet a release declaration. Evaluation and CI parity are established;
real-hardware activation, rollback, and behavioral acceptance remain before the old
`newxos` repository can be archived.

## Workspace model

- The root `phenix` repository is a pure integration superflake.
- Feature implementation belongs in the owning repository:
  - `phenix-de` — desktop packages and NixOS/Home Manager desktop modules
  - `phenix-hosts` — concrete systems, hardware, storage, users, secrets, and host services
  - `phenix-nvim` — wrapped Neovim package and configuration
  - `phenix-agent-harness` — Pi coding-agent runtime and configuration
  - `phenix-packages` — shared development packages and Home Manager package modules
  - `phenix-tend` — deterministic repository verification
  - `phenix-stitch` — multi-repository graph and Git coordination
- Root inputs are remote `github:matthis-k/*` flakes. The root `flake.lock` is the
  authoritative aggregate revision set.
- Child inputs follow the corresponding root inputs wherever they represent the same
  dependency. This prevents the aggregate from validating a different dependency graph
  than the individual repositories.

## Completed migration baseline

### Desktop

- [x] Hyprland Lua configuration and keymap engine
- [x] Quickshell desktop source and user service
- [x] Kitty, Fish, Starship, Stylix/Catppuccin, and Zen Browser configuration
- [x] Wayland screenshot, annotation, clipboard, and OCR utilities
- [x] Aggregate and individually reusable NixOS/Home Manager desktop modules
- [x] Desktop package, module, and keymap checks

### Hosts

- [x] `matthisk-laptop-newxos` NixOS configuration
- [x] `matthisk-desktop-newxos` NixOS configuration
- [x] Hardware, kernel, boot loader, Plymouth, and resume configuration
- [x] Encrypted LUKS/LVM/Disko storage layouts
- [x] Home Manager, user, SSH, Git/GitHub, SOPS, locale, audio, and sudo configuration
- [x] Bluetooth, NetworkManager, Avahi, LocalSend, and NordVPN configuration
- [x] Desktop Ollama, Open WebUI, Caddy, and Kokoro TTS services
- [x] Neovim and Pi harness installation through their owning flakes
- [x] Both concrete systems evaluate in repository CI

### Aggregate

- [x] Root input graph follows the final migrated repository revisions
- [x] Strict Stitch lock-derived graph verification
- [x] Tend v2 verification contracts and permanent CI across the aggregate repositories
- [x] Complete NixOS and Home Manager module re-exports
- [x] Concrete host re-exports through the root flake
- [x] Root `nix flake check` validates the composed graph

## Replacement acceptance gates

The Phenix graph is a valid declarative replacement candidate when all gates below are
complete. Evaluation success alone does not prove that every runtime behavior works on
physical hardware.

### Required before cutover

- [ ] Provision or confirm each host's SOPS age identity outside the repository
- [ ] Build and activate the laptop configuration on the laptop
- [ ] Build and activate the desktop configuration on the desktop
- [ ] Verify boot, encrypted storage, resume, graphics, display manager, and rollback
- [ ] Verify NordVPN login, dedicated-IP autoconnect, LAN discovery, and LocalSend
- [ ] Verify desktop shell startup, launcher, notifications, clipboard, screenshots, and OCR
- [ ] Verify desktop-only Ollama, Open WebUI, Caddy certificate trust, and Kokoro TTS
- [ ] Confirm SSH and GitHub credentials are readable with the expected ownership and modes

### Functional gaps still to migrate or replace

- [ ] Installer media and the old live-USB/first-install workflow
- [ ] Full Quickshell runtime/IPC and launcher case test harness from `newxos`
- [ ] Explicit parity tests for the wrapped Neovim configuration
- [ ] Decide whether the old NewXOS CLI and Basic Memory workflow are still required;
      migrate them only if they provide behavior not covered by Stitch, Tend, or Pi
- [ ] Replace remaining `newxos.*`, `NEWXOS_*`, and `*-newxos` compatibility names after
      successful hardware cutover
- [ ] Remove compatibility imports and duplicated migration-era settings after runtime proof
- [ ] Decide whether `phenix-packages` remains an aggregator or receives additional shared
      package ownership

## Architecture follow-up

Configuration preservation took precedence over redesign during migration. After the
hardware acceptance gates pass:

1. Remove compatibility names and aliases.
2. Consolidate repeated host declarations that are demonstrably identical.
3. Keep hardware, storage, and machine policy explicit even when similar.
4. Add behavior-level tests before moving or abstracting desktop source files.
5. Archive `newxos` only after the Phenix rollback path has been exercised.

## Verification policy

- Every repository owns its local Tend manifest and permanent CI.
- The root verifies the locked aggregate and downstream composition.
- `nix flake check` must remain valid on every merged root revision.
- Root input updates must point only to repository revisions that passed their own CI.
- Temporary migration workflows and generated diagnostics must not remain on `main`.
