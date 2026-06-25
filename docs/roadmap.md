---
title: roadmap
type: note
permalink: newxos/roadmap
---

# Phenix Roadmap

This is the persistent implementation checklist for the Phenix workspace.

The docs describe the intended workflow.
This roadmap tracks what is implemented, missing, deferred, or intentionally not started.

Keep this file current.
Do not bury roadmap state inside one-off chat logs or historical notes.

## Status markers

Use:

- [ ] not started
- [~] in progress
- [x] done
- [!] blocked
- [-] intentionally deferred

Where relevant, items distinguish three states:

- **[D]** documented — the intended rule exists in docs
- **[I]** implemented — code/config exists
- **[E]** enforced — a deterministic check verifies it

Do not mark an item done merely because it is documented, if the item describes implementation or enforcement.

## Phase 1: Guardrails and OpenCode

Goal:
Make the repo safe for agentic work before any migration.

- [x] Create docs as ought-state:
  - [x] `docs/README.md`
  - [x] `docs/guardrails.md`
  - [x] `docs/opencode.md`
  - [x] `docs/testing.md`
  - [x] `docs/migration.md`
  - [x] `docs/roadmap.md`
- [x] Establish root repo rule:
  - [x] root `phenixos` is orchestration-only
  - [x] root does not contain migrated feature implementation
  - [x] feature ownership is documented
- [x] Add repo-local OpenCode config:
  - [x] `.opencode/agents/phenix-coordinator.md`
  - [x] `.opencode/agents/phenix-explorer.md`
  - [x] `.opencode/agents/phenix-architect.md`
  - [x] `.opencode/agents/phenix-toolsmith.md`
  - [x] `.opencode/agents/phenix-gatekeeper.md`
  - [x] `.opencode/agents/phenix-reviewer.md`
  - [x] `.opencode/agents/phenix-simplifier.md`
- [x] Add OpenCode commands:
  - [x] `.opencode/commands/phenix-foundation.md`
  - [x] `.opencode/commands/phenix-task.md`
- [x] Add OpenCode skills:
  - [x] `.opencode/skills/phenix-architecture/SKILL.md`
  - [x] `.opencode/skills/phenix-tooling/SKILL.md`
- [x] Decide OpenCode wrapper strategy:
  - [x] default wrapper remains general
  - [x] Phenix config is repo-local
  - [x] no writes to `~/.config/opencode`
- [~] Add or update dev shell:
  - [~] `nix develop` works (flake shell is functional)
  - [ ] common tools are available
  - [ ] `opencode` is available if intended
  - [~] `phenix` tool is available via `nix run .#gate` or `nix run .#sync`
- [x] Add initial agent workflow docs:
  - [x] command usage
  - [x] agent roles
  - [x] final report format
  - [x] no-migration rule for foundation phase

## Phase 2: Testing and gate tooling

Goal:
Make correctness deterministic enough that future agents can be constrained by checks.

- [x] Choose canonical check file name:
  - [x] `.phenix-checks.json`
- [x] Implement `phenix gate` skeleton:
  - [x] `phenix gate list`
  - [x] `phenix gate all`
  - [x] `phenix gate changed`
  - [x] `phenix gate id <id>`
- [x] Add config discovery:
  - [x] recursive discovery
  - [x] explicit `--config` / `-c`
  - [x] deterministic merge order
  - [x] duplicate ID detection
- [x] Add basic schema support:
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
- [x] Add changed-file routing:
  - [x] unstaged diff
  - [x] staged diff
  - [x] documented behavior around `HEAD`
- [x] Add useful output:
  - [x] detailed failure output
  - [x] pass/fail/skipped summary
  - [x] useful exit codes
- [x] Add initial checks:
  - [x] Nix formatting
  - [x] Nix static analysis
  - [x] flake check
  - [x] OpenCode config presence
  - [x] docs presence
  - [x] gate runner self-test
- [x] Add gate docs:
  - [x] schema example
  - [x] CLI examples
  - [x] changed-file behavior
  - [x] pre-commit/repo-gate usage
- [x] Avoid overbuilding:
  - [x] no output verification plugins yet
  - [x] no complex workflow DSL yet
  - [x] no AI-based check routing

## Phase 3: Migration readiness

Goal:
Prepare for migration without migrating real features during the foundation pass.

- [x] Define first migration slice selection criteria
- [x] Define migration change contract template
- [x] Define wrapper-first migration checklist
- [x] Define module surface checklist
- [x] Define host enablement checklist
- [x] Define migration gate requirements
- [~] Identify candidate first migrations:
  - [x] simple package wrapper (e.g., `foot` terminal wrapper)
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

These must remain true throughout the project.

Three-state tracking:

- **[D]** documented in docs
- **[I]** implemented in code/config
- **[E]** enforced by a deterministic gate

| Guardrail | D | I | E |
| --------- | - | - | - |
| Root repo is orchestration-only | D | I | |
| Feature ownership is explicit | D | I | |
| Dendritic structure is preserved | D | I | |
| Wrapper-first model is preferred | D | I | |
| No accidental global OpenCode pollution | D | I | |
| No writes to user config from Nix wrappers | D | I | |
| No big-bang migration | D | I | |
| No expected-failing default gates | D | I | |
| No stale docs pretending to be current | D | I | |
| Roadmap remains updated | D | I | |
| No edits to `newxos` outside migration passes | D | I | |
| `~/phenix/newxos` is read-only reference | D | | |