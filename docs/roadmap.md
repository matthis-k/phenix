---
title: roadmap
type: note
permalink: newxos/roadmap
---

# Phenix Roadmap

This is the persistent implementation checklist for the Phenix workspace.

The docs describe the intended workflow.
This roadmap tracks what is documented, implemented, enforced, missing, deferred, or intentionally not started.

Keep this file current.
Do not bury roadmap state inside one-off chat logs or historical notes.

## Roadmap status rule

For rules and systems, distinguish between:

- documented: the intended rule exists in docs
- implemented: code/config exists
- enforced: a deterministic check verifies it

Do not mark an item done merely because it is documented if the item describes implementation or enforcement.

Example:

```md
## Root repo rule

- [x] Documented
- [ ] Implemented
- [ ] Enforced by gate
```

## Phase 1: Guardrails and OpenCode

Goal:
Make the repo safe for agentic work before any migration.

### Ought-state docs

- [x] `docs/README.md`
- [x] `docs/guardrails.md`
- [x] `docs/opencode.md`
- [x] `docs/testing.md`
- [x] `docs/migration.md`
- [x] `docs/roadmap.md`

### Root repo rule

- [x] Documented
- [x] Implemented
- [ ] Enforced by gate

### Repository ownership rules

- [x] Documented
- [x] Implemented
- [ ] Enforced by gate

### Wrapper-first rule

- [x] Documented
- [ ] Implemented
- [ ] Enforced by gate

### Repo-local OpenCode config

- [x] `.opencode/agents/phenix-coordinator.md`
- [x] `.opencode/agents/phenix-explorer.md`
- [x] `.opencode/agents/phenix-architect.md`
- [x] `.opencode/agents/phenix-toolsmith.md`
- [x] `.opencode/agents/phenix-gatekeeper.md`
- [x] `.opencode/agents/phenix-reviewer.md`
- [x] `.opencode/agents/phenix-simplifier.md`
- [x] `.opencode/commands/phenix-foundation.md`
- [x] `.opencode/commands/phenix-task.md`
- [x] `.opencode/skills/phenix-architecture/SKILL.md`
- [x] `.opencode/skills/phenix-tooling/SKILL.md`

### OpenCode wrapper strategy

- [x] Default `opencode` remains general
- [x] Phenix config is repo-local by default
- [x] No writes to `~/.config/opencode`
- [x] No accidental global OpenCode pollution

### Dev shell

- [x] `nix develop` works
- [ ] common tools are available
- [ ] `opencode` is available if intended
- [x] `tend` and `stitch` tools are available via `nix run .#tend` / `nix run .#stitch`

## Phase 2: Testing and gate tooling

Goal:
Make correctness deterministic enough that future agents can be constrained by checks.

### Check runner (migrated to `tend`)

- [x] `tend plan` — show which checks would run
- [x] `tend run` — execute checks
- [x] `tend explain` — explain failures (MCP)
- [x] `tend status` — config health

Legacy `pt gate` / `phenix-tools gate` replaced.

### Distributed check files (migrated to `.tend.json`)

- [x] Canonical file name documented: `.tend.json`
- [x] Recursive discovery
- [x] Explicit `--config` / `-c`
- [x] Deterministic merge order
- [x] Duplicate ID detection
- [x] `.phenix-checks.json` retired (migration note in place)

### Basic schema

- [x] `version`
- [x] `scope`
- [x] `checks`
- [x] `id`
- [x] `description`
- [x] `group`
- [x] `tags`
- [x] `when.paths`
- [x] `workdir`
- [x] `command`
- [x] `expect.status`

### Changed-file routing

- [x] Unstaged diff
- [x] Staged diff
- [x] Documented behavior around `HEAD`
- [x] No AI-based check routing

### Output

- [x] detailed failure output
- [x] pass/fail/skipped summary
- [x] useful exit codes

### Initial checks (migrated to `.tend.json`)

- [x] docs presence (includes MCP routing docs)
- [x] OpenCode config presence
- [x] no-legacy-gate-runner guard
- [x] no-sync-json-consumption guard
- [x] no-legacy-nix-gate-export guard
- [x] no-root-flake-apps-gate guard
- [x] no-mcp-stub-commit-sync guard
- [x] mcp-routing-docs-exist guard
- [ ] Nix formatting if already passable
- [ ] Nix static analysis if already passable
- [ ] flake check if already passable

## Phase 3: Migration readiness

Goal:
Prepare for migration without migrating real features during the foundation pass.

- [x] Define first migration slice selection criteria
- [x] Define migration change contract template
- [x] Define wrapper-first migration checklist
- [x] Define module surface checklist
- [x] Define host enablement checklist
- [x] Define migration gate requirements
- [x] Identify candidate first migrations:
  - [x] simple package wrapper
  - [ ] simple module consuming wrapper
  - [ ] simple host enablement
- [x] Explicitly defer complex migrations:
  - [-] full Hyprland stack
  - [-] full shell stack
  - [-] secrets
  - [-] VPN/networking
  - [-] complex browser profile management
  - [-] global theming system

## Phase 4: First real migration

Goal:
Incremental NewXOS feature adoption into Phenix subflakes, chunk by chunk.

### Completed chunks

#### Chunk 1 — API groundwork (phenix-pins, phenix-hosts, root)
- [x] Add `home-manager` and `sops-nix` provider pins to phenix-pins
- [x] Create disabled/inert `phenix-hosts` NixOS/HM module APIs:
  `nixosModules.{default, phenixMigrationBase, homeManagerBridge, sopsBridge}`
- [x] Add `packages.phenix-migration-info` (inert status package)
- [x] Root input pass-through and lock coordination
- [x] `nix flake check` passes
- [x] Committed (no push)

#### Chunk 2 — phenix-hosts base module surfaces
- [x] Add NixOS modules (all opt-in, disabled by default):
  `sopsBase`, `nixBase`, `usersMatthisk`, `localeDeEn`,
  `audioPipewire`, `sudoWheelPasswordless`
- [x] Add HM modules (all opt-in):
  `usersMatthiskBase`, `usersMatthiskSsh`
- [x] Preserve Chunk 1 exports
- [x] `nix flake check` + `tend verify` pass
- [x] Committed (no push)

#### Chunk 3 — phenix-packages dev-tools
- [x] Export 18 curated dev tool packages (git, gh, ripgrep, fd, fzf, bat,
  eza, delta, jq, htop, btop, tmux, lazygit, zoxide, curl, wget, unzip, starship)
- [x] Create opt-in `homeModules.devTools` HM module
- [x] `nix flake check` + `tend verify` pass
- [ ] Committed

#### Chunk 4 — phenix-de Hyprland + cache modules
- [x] Create `nixosModules.hyprland-base` (Hyprland, XDG portal, SDDM, env vars)
- [x] Create `nixosModules.nix-cache` (Hyprland cachix + extensible cache config)
- [x] Create `homeModules.hyprland` (full keybinds, input, decorations, animations)
- [x] `nix flake check` + `tend verify` pass
- [ ] Committed

#### Chunk 5 — Root re-exports
- [x] Create `phenix-re-exports.nix` aggregating sub-flake NixOS (11) and HM (4) modules
- [x] Wire into root `flake.nix` imports
- [x] `nix flake check` passes
- [ ] Committed

### Deferred for later chunks
- [ ] Host enablement (nixosConfigurations)
- [ ] Full Home Manager configuration
- [ ] Secrets/sops activation
- [ ] Shell/browser/VPN/LLM/TTS features
- [ ] Live USB/hardware work
- [ ] Full Stylix/theming
- [ ] CLI/workflow scripts
- [ ] Quickshell/newshell
- [ ] Zen Browser
- [ ] NordVPN
- [ ] CUDA configuration

### Remaining checklist
- [ ] Chunk 7: Documentation finalization (this file)
- [ ] Review for copied debt
- [ ] Commit all remaining dirty chunks

## Permanent guardrails

These must remain true throughout the project:

### Root repo remains orchestration-only

- [x] Documented
- [x] Implemented
- [ ] Enforced by gate

### Feature ownership remains explicit

- [x] Documented
- [x] Implemented
- [ ] Enforced by gate

### Dendritic structure is preserved

- [x] Documented
- [x] Implemented
- [ ] Enforced by gate

### Wrapper-first model is preferred

- [x] Documented
- [ ] Implemented
- [ ] Enforced by gate

### No accidental global OpenCode pollution

- [x] Documented
- [x] Implemented
- [ ] Enforced by gate

### No big-bang migration

- [x] Documented
- [x] Implemented
- [ ] Enforced by gate

### No expected-failing default gates

- [x] Documented
- [x] Implemented
- [x] Enforced by gate

### Durable workflow blackboard and ledgers

- [x] Documented
- [ ] Implemented
- [ ] Enforced by gate

### Workflow-depth routing

- [x] Documented
- [ ] Implemented
- [ ] Enforced by gate

### Optional specialist critics

- [x] Documented
- [ ] Implemented
- [ ] Enforced by gate

### Stitch commit/sync coordinator policy

- [x] Documented
- [x] Implemented
- [ ] Enforced by gate

### Partitioned implementer handoffs

- [x] Documented
- [ ] Implemented
- [ ] Enforced by gate

### Roadmap remains updated

- [x] Documented
- [x] Implemented
- [ ] Enforced by gate
