---
title: opencode
type: note
permalink: newxos/opencode
---

# Phenix OpenCode Workflow

This document describes the intended Phenix workflow.

It is an **ought-state** document. Items not yet implemented must be tracked in [`roadmap.md`](./roadmap.md).

## Purpose

OpenCode should not be used as an unconstrained repo-editing agent.

For Phenix, OpenCode should behave like a structured implementation coordinator:

```text
intake
  -> discovery
  -> ownership decision
  -> change contract
  -> implementation
  -> gate execution
  -> invariant review
  -> simplification review
  -> final report
```

## Strategy: repo-local (only)

Phenix uses **repo-local** OpenCode configuration. This is the sole strategy.

Rules:

- The default `opencode` wrapper remains general-purpose and is never modified for Phenix.
- No separate `phenix-opencode` wrapper is created unless the existing Nix tooling already has a clean wrapper pattern that does not duplicate repo-local definitions.
- No Nix wrapper writes to `~/.config/opencode`.
- Phenix agents and commands are available when running `opencode` inside the Phenix repo via `.opencode/`.
- If a wrapper is ever added, it must not duplicate repo-local agent definitions.

## Configuration layout

```text
.opencode/
  agents/
    phenix-coordinator.md
    phenix-explorer.md
    phenix-architect.md
    phenix-toolsmith.md
    phenix-gatekeeper.md
    phenix-reviewer.md
    phenix-simplifier.md
  commands/
    phenix-foundation.md
    phenix-task.md
  skills/
    phenix-architecture/
      SKILL.md
    phenix-tooling/
      SKILL.md
```

## Commands

### `/phenix-foundation`

Used for foundation work only:

* guardrails
* OpenCode config
* dev shells
* test runner
* gate infrastructure
* docs
* roadmap

It must not migrate real `newxos` features.

### `/phenix-task`

General future entrypoint for Phenix work.

It must still follow the strict workflow:

1. intake
2. discovery
3. ownership decision
4. change contract
5. implementation
6. gate execution
7. invariant review
8. simplification review
9. final report

## Agents

### `phenix-coordinator`

Primary agent.

Coordinates work and enforces the phase protocol.

Must not rush directly into edits.

### `phenix-explorer`

Read-only subagent.

Finds files, patterns, checks, docs, and relevant ownership.

No edits.

### `phenix-architect`

Read-only subagent.

Decides repo boundaries and architectural invariants.

No edits.

### `phenix-toolsmith`

Implementation subagent for tooling and dev environment only.

May work on:

* dev shells
* wrappers
* CLI skeletons
* gate runner
* JSON schema
* docs

Must not migrate real system features.

### `phenix-gatekeeper`

Check/test subagent.

Runs checks, diagnoses failures, and proposes regression guards.

Must never claim a check passed unless it actually ran.

### `phenix-reviewer`

Read-only consistency reviewer.

Checks changed files against Phenix architecture.

### `phenix-simplifier`

Read-only YAGNI/debt reviewer.

Looks for:

* copied `newxos` debt
* broad abstractions
* compatibility layers
* stale docs
* duplicated logic
* unnecessary options

## Agent permissions

Preferred default posture:

| Agent                | Read | Edit |          Bash | Task/Subagent |
| -------------------- | ---: | ---: | ------------: | ------------: |
| `phenix-coordinator` |  yes |  ask |           ask |           yes |
| `phenix-explorer`    |  yes |   no | ask/read-only |            no |
| `phenix-architect`   |  yes |   no |            no |            no |
| `phenix-toolsmith`   |  yes |  ask |           ask |            no |
| `phenix-gatekeeper`  |  yes |  ask |           ask |            no |
| `phenix-reviewer`    |  yes |   no | ask/read-only |            no |
| `phenix-simplifier`  |  yes |   no | ask/read-only |            no |

## Final report format

Every OpenCode task should end with:

```md
## Summary

## Files changed

## Checks run

## Checks not run

## Invariant review

## Roadmap updates

## Remaining gaps
```