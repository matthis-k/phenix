---
title: roadmap
type: note
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
- [x] `phenix` tool is available via `nix run .#gate` or `nix run .#sync`

## Phase 2: Testing and gate tooling

Goal:
Make correctness deterministic enough that future agents can be constrained by checks.

### Gate command

- [x] `phenix gate` exists as `phenix-tools gate`
- [x] `phenix gate list`
- [x] `phenix gate all`
- [x] `phenix gate changed`
- [x] `phenix gate id <id>`

### Distributed check files

- [x] Canonical file name documented: `.phenix-checks.json`
- [x] Recursive discovery
- [x] Explicit `--config` / `-c`
- [x] Deterministic merge order
- [x] Duplicate ID detection

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

### Initial checks

- [x] docs presence
- [x] OpenCode config presence
- [x] gate runner self-test
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
Start only after Phases 1 and 2 are usable.

- [ ] Select first migration slice
- [ ] Inspect `newxos` source
- [ ] Inspect Phenix target repo
- [ ] Write change contract
- [ ] Implement wrapper/package part
- [ ] Add module surface only if needed
- [ ] Add host enablement only if needed
- [ ] Add checks
- [ ] Run gates
- [ ] Update docs/roadmap
- [ ] Review for copied debt

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

### Roadmap remains updated

- [x] Documented
- [x] Implemented
- [ ] Enforced by gate